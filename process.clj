(ns parser
  (:require [instaparse.core :as insta]
            [clojure.java.io :as io]
            [clojure.string :as str]
            [clojure.java.shell :as sh]
            [clojure.data.xml :as xml]
            [clojure.data.csv :as csv]
            [clojure.edn :as edn]
            [sigel.xslt.core :as xslt]
            [sigel.xpath.core :as xpath]
            [sigel.xslt.elements :as xsl]
            [sigel.saxon :refer [processor]]
            [clojure.spec.alpha :as s]
            [clojure.spec.test.alpha :as stest]
            [clj-http.client :as httpclient]
            ))

(def infile (io/as-file (io/resource "0050.txt")))
(def teifile (io/file "0050-tei.xml"))
(def nerfile (io/file "0050-ner.xml"))

(defn getencoding [path]
  (str/trim (:out (sh/sh "file" "-b" "--mime-encoding" (str path) ))))

(defn readdatafile []
  (let [encoding (getencoding infile)
        ]
    (slurp infile :encoding encoding)))

(def indata (readdatafile))

(def parser (insta/parser (io/resource "parser.bnf") :output-format :enlive))

(def inparse (insta/parse parser indata))

(def inparse-xml (xml/emit-str inparse))

(defn xmltotei [xmltext basename]
  (let [xslt-to-tei (xslt/compile-xslt (io/resource "parse-to-tei.xsl"))
        ]
    (xslt/transform xslt-to-tei {:basename basename} xmltext )))

(def teidoc (xmltotei inparse-xml "0050"))

(def teicompiler
  "Create an XPath compiler"
  (xpath/compiler))


(xpath/set-default-namespace! teicompiler "http://www.tei-c.org/ns/1.0")

(defn selectteichildrenwithid
  "Selects TEI children that have xml:id set

  At this point of the conversion process, this is valid only for TEI
  elements that contain recognized works.
  "
  [dt]
  (seq (xpath/select teicompiler dt "//TEI[@xml:id]" ())))

(def teidocs
  "Select the children, return as sequence"
  (selectteichildrenwithid teidoc))

(def metadatafile "Lönnrot-corpus-metadata.tsv")

(defn getmetadata [lonnrotid]
  (let [id (Integer/parseInt lonnrotid)
        ]
    (with-open [reader (io/reader (io/resource metadatafile)) ]
      (->> (csv/read-csv reader :separator \tab :quote \ß)
           (drop 1)
           (filter #(= (Integer/parseInt (nth % 0)) id))
           (into [])
           ))))

(def metadata (getmetadata "0050"))

(defn processone [xmls metadata]
  (let [author (str (nth metadata 3) " " (nth metadata 4))
        title (str (nth metadata 2))
        year (str (nth metadata 7))
        xsltmeta (xslt/compile-xslt (io/resource "tei-update-metadata.xsl"))
        filebase (xpath/value-of teicompiler xmls "./@xml:id" ())
        ]
    (xslt/transform 
     xsltmeta
     {:docid filebase :author author :title title :year year }
     xmls
     )))

(defn processdata [id dtc metadata]
  (map processone dtc metadata)
  )

(defn setmetadata
  "Set metadata for all works in parse and save to file."
  []
  (let [metacount (count metadata)
        ]
    (cond 
      (= metacount (count teidocs)) (processdata "0050" teidocs metadata)
      (= (count teidocs) (+ metacount 1)) (processdata "0050" (drop 1 teidocs) metadata)
      true nil)))

(def teidocs-meta (setmetadata))

(def teidoc1 (first teidocs-meta))

(defn textname [xml]
  (str (first (xpath/select teicompiler teidoc1 "//title/text()" ()))
   " by "
       (first (xpath/select teicompiler teidoc1 "//author/text()" ())) ". "))

(defn numberoftokens [xml]
  (count (seq (xpath/select teicompiler xml "//(w|pc|num)" ()))))

(defn textreport [xml]
  (println (str "Text: " (textname xml)  "Number of tokens: " (numberoftokens xml))))

(textreport teidoc1)

(defn write-saxon-xml-to-file
  "In order to preserve spaces in the XML, the default serialization of
  Clojure XML libraries is not good. Therefore, we use Saxon-specific
  serializer."
  [xml df]
  (let [ser (.newSerializer processor df)
        ]
    (.serializeNode ser xml)
    (.close ser)))

(write-saxon-xml-to-file teidoc1 teifile)

(def config (edn/read-string (slurp (io/resource "config.edn"))))

(def ner-api (:ner-api config))
(def parser-api (:parser-api config))
(def xpath-tei-comp (xpath/compiler processor "http://www.tei-c.org/ns/1.0" () ))

(defn file-to-par-wordlists
  "Extract tokens from TEI file, return a list chunked by paragraph

  Arguments:
  - any object implementing the sigel XMLSource protocol
    [sigel.protocols/XMLSource]
  Returns:
  - a lazy sequence of vectors."
  [file]
  {:pre [(extends? sigel.protocols/XMLSource (type file))]
   :post [(seq? %)]}
  (let [xslt (xslt/compile-xslt (io/resource "tei-extract-tokens-chunk-p.xsl"))
        ]
    (map str/split-lines
    (as-> (xslt/transform xslt file) d
        (str d)
        (str/split d #"(?m)###par")
        (filter not-empty d)
        ))))

(defn tei-id-from-file
  "Get the root TEI xml:id from file

  Arguments:
  - any object implementing the sigel XMLSource protocol
    [sigel.protocols/XMLSource]
  Returns:
  - a string"
  [file]
  {:pre [(extends? sigel.protocols/XMLSource (type file))]
   :post [(string? %)]
   }
  (xpath/value-of (xpath/select xpath-tei-comp file "/TEI/@xml:id" []) "."))

(defn wordlist-to-tokens
  "Extract tokens from id-token vector

  Arguments:
  - Collection of tab-separated id token string
  Returns:
  - string of newline separated tokens"
  [wl]
  {:pre [(coll? wl)
         (every? string? wl)]
   :post [(string? %)]
   }
  (str/join "\n"  (map #(second (str/split % #"\t")) wl))
  )

(defn wordlist-to-tokens-ws
    "Extract tokens from id-token vector

  Arguments:
  - Collection of tab-separated id token string
  Returns:
  - string of whitespace separated tokens"
  [wl]
  {:pre [(coll? wl)
         (every? string? wl)]
   :post [(string? %)]}
  (str/join " "  (map #(second (str/split % #"\t")) wl))
  )

(defn tokenlist-ner [tl]
  "Run NER process for list of tokens."
  (str/split-lines
   (:body
    (httpclient/post ner-api {:form-params {:text tl :tokenized "true"}})
    )))

(defn tokenlist-parse [tl]
  "Run parse process for list of tokens"
  (str/split-lines
   (:body
    (httpclient/post parser-api {:body tl :socket-timeout 300000 :connection-timeout 300000}))))

(defrecord Word-NerdataRec [id word type])
(s/def ::word_nerdatarecord
  (s/keys :req-un [::id ::word ::type]))

(defn merge-nertoken-word
  "Merge token type with token id

  Used to merge the NER detections back to the original data. This
  performs one single merge, this has to be mapped to two lists at a
  time: first containing the NER result data, the second containing
  the original token list with id's.
  
  Arguments:
  - string of word and type, from the NER process
  - string of id and word, from the original tokenlist
  Returns:
  - a Word-TokentypeRec, with id, word and type"
  [nerresult originaldata]
  {:pre [(s/valid? string? nerresult)
         (s/valid? string? originaldata)]
   :post [(s/valid? ::word_nerdatarecord %)]} 
  (let [[nertoken nertype] (str/split nerresult #"\t" 2)
        [wordid origword] (str/split originaldata #"\t" 2)
        ]
    (when (not (= nertoken origword)) (throw (ex-info "NER-data not aligned with token data")))
    (->Word-NerdataRec wordid nertoken nertype)

    ))

(defrecord Word-ParsedataRec [id word lemma upos xpos feats head deprel deps misc])
(s/def ::word_parsedatarec
  (s/keys :req-un [::id ::word ::lemma ::upos ::xpos ::feats ::head ::deprel ::deps ::misc]))

(defn merge-parse-word
  "Merge parse data with token id

  Used to merge the parse result fields (ConLL-U) with the token id.

  Arguments:
  - string of parse result in ConLL-U format
  - string of id and word, from the original tokenlist
  Return:
  - A Word-ParsedataRec record with id, word, and parsedata"
  [parseresult originaldata]
  {:pre [(s/valid? string? parseresult)
         (s/valid? string? originaldata)]
   :post [(s/valid? ::word_parsedatarec %)]}
  (let [[id form lemma upos xpos feats head deprel deps misc] (str/split parseresult #"\t")
        [wordid wordword] (str/split originaldata #"\t" 2)
        ]
    (when (not (= form wordword)) (throw (ex-info "Parse-data not aligned with token data")))

    (->Word-ParsedataRec wordid form lemma upos xpos feats head deprel deps misc)
    ))

(defn merge-nerlist-wordlist
  "Merge result from NER with the original wordlist

  Arguments:
  - list of NER results
  - list of words from TEI text
  Returns:
  - list of words with NER data
  "
  [nerresultlist wl]
  (map merge-nertoken-word nerresultlist wl))

(defn merge-parselist-wordlist
  "Merge results from parse process with original wordlist

  Expects parse data in ConLL-U format
  Arguments:
  - parse results
  - wordlist
  Returns:
  - wordlist with parse results added
  "
  [pl wl]
  (map merge-parse-word pl wl))

(defn process-ner-wordlist
  "Combines the NER process for a wordlist"
  [wl]
  {:pre [(s/valid? (s/coll-of string?) wl)]
   :post [(s/valid? (s/coll-of ::word_nerdatarecord) %)] 
   }
  (-> wl
      (wordlist-to-tokens)
      (tokenlist-ner)
      (merge-nerlist-wordlist wl)
      (vec)

      ))

(s/fdef process-ner-wordlist
  :args (s/cat :wl (s/coll-of string?))
  :ret (s/coll-of (s/cat :id string? :word string? :type string?))
  )

(defn process-ner-wordlists
  "Combined the NER process for a collection of wordlists

  This function is to be used if the data is in chunked wordlists.
  "
  [wls]
  (reduce into (map process-ner-wordlist wls)))

(defn process-lemma-wordlist
  "This combines the lemmatization for a wordlist"
  [wl]
  {:pre [(s/valid? (s/coll-of string?) wl)]
   :post [(s/valid? (s/coll-of ::word_parsedatarec) %)]}
  (-> wl
      (wordlist-to-tokens-ws)
      (tokenlist-parse)
      (merge-parselist-wordlist wl)
      ))

(s/fdef process-lemma-wordlist
  :args (s/cat :wl (s/coll-of string?))
  :ret (s/coll-of ::word_parsedatarec)
  )

(defn process-lemma-wordlists
  "Combines the parse/lemmatizatin process for a collection of wordlists.

  This should be used in case the data is in chunked wordlists"
  [wls]
  (reduce into (map process-lemma-wordlist wls)))

(defn select-ontonotesNE-type
  "Filter nerdata list for entries with a particular entity type

  Arguments:
  - list of ner-data results
  - string with the Ontonotes-NE entity type
  Results:
  - filtered list of ner-data results
  "
  [nerdatalist entitytype]
  {:pre [(s/valid? (s/coll-of ::word_nerdatarecord) nerdatalist)]
   :post [(s/valid? (s/coll-of ::word_nerdatarecord) %)]
   }
  (filter #(re-matches (re-pattern (str "[BI]-" entitytype)) (:type %)) nerdatalist))

(defn collect-ners [nerdatalist entitytype]
  (let [bname (str "B-" entitytype)
        iname (str "I-" entitytype)
        ]
    (loop [datalist nerdatalist
           resultlist (vector)
           ]
      (if (empty? datalist)
        resultlist
        (let [type (:type (first datalist))
              ]
          (if (= type bname)
            (recur (rest datalist)
                   (cons [(str (:id (first datalist)))] resultlist))
            (if (= type iname)
              (recur (rest datalist) (cons (conj (first resultlist) (str (:id (first datalist)))) (rest resultlist)))
              (throw (ex-info (str "Unexpected data " (first datalist)))))))))))
    

(defn get-annotations-for-entitytype
  [nerdatalist entitytype]
  {:pre [(s/valid? (s/coll-of ::word_nerdatarecord) nerdatalist)]
   :post [(s/valid? (s/coll-of (s/coll-of string?)) %)]}
  (-> nerdatalist
        (select-ontonotesNE-type entitytype) ; replace with correct filter(s)! This is faster to develo with
        (collect-ners entitytype)
        ))

(defn get-annotations-for-annotationtype
  "Selects all annotations for one annotation type

  "
  [nerdatalist annotation]
  (let [entitytype (:ontonotesNE annotation)]
    (get-annotations-for-entitytype nerdatalist entitytype)))
 



(defn idseq
  [entitytype xmlid n]
  (cons (str xmlid "-annotation-" entitytype "-" n) (lazy-seq (idseq entitytype xmlid (inc n)))))

(defn idseq-annotationtype [annotype xmlid n]
  (let [entitytype (:nametypeattribute annotype)]
    (idseq entitytype xmlid n)))

(defn process-map-entry
  "Create map from single annotation data"
  [pers xmlid]
  {:pre [(s/valid? (s/coll-of string?) pers)]
   }
  {:key (first pers) :xmlid xmlid :other (rest pers)})

(defn create-processing-list
  [persl entitytype xmlid]
  (map process-map-entry
         (reverse persl)
         (idseq entitytype xmlid 1)
         ))

(defn create-process-list-annotationtype [persl annotype xmlid]
  (let [entitytype (:nametypeattribute annotype)]
    (create-processing-list persl entitytype xmlid)
  ))

(defn create-skip-list [persl]
  (reduce into #{} (map rest persl)))


(defn procentry-to-param-map [entry]
  (str "\"" (:key entry) "\" : map{ \"xmlid\" : \"" (:xmlid entry) "\", \"other\" : ("
       (str/join ", " (map #(str "\"" % "\"") (:other entry))) ")}"))

(defn processlist-to-param-map [procl]
  (str "map{" (str/join ", " (map procentry-to-param-map procl)) " }"))

(defn skiplist-to-param-map [skipl]
  (str "(" (str/join ", " (map #(str "\"" % "\"") skipl)) ")"))

(defn proc-lemmaentry-to-param-map
  [e]
  (str "\"" (:id e) "\" : map { \"lemma\" : \"" (:lemma e) "\", \"upos\" : \"" (:upos e) "\", \"feats\" : \"" (:feats e) "\" }\n" ))

(def forbiddenlemmas
  "List of characters that indicate incorrect lemmas

  Presence of any of these characters in the lemma returned from the
  NLP parser usually indicates that the original text also has
  problems. These characters cause trouble when trying to encode the
  texts for use in TEI files, so easiest solution is to drop any
  lemmas containing these characters."
  #{"\"" "'" "\\" })

(defn lemmalist-to-param-map
  "Process list of lemmas to xsl param string.

   Use the occasion to remove PUNCT entries from lemmas. These are
  useless in the end data, and are difficult to encode correctly in
  XPath.
   "
  [lemmalist]
  (let [ll1 (filter
             #(and
               (not= "PUNCT" (:upos %))
               (not (contains? forbiddenlemmas (:lemma %))))
             lemmalist)
        ]
    (str "map{"
         (str/join ", " (map proc-lemmaentry-to-param-map ll1))
         " }")))

(defn create-param-map [persl entitytype xmlid]
  {:processlist (processlist-to-param-map (create-processing-list persl entitytype xmlid))
   :skiplist (skiplist-to-param-map (create-skip-list persl))
   :elementname "name"
   :nametype entitytype})

(defn create-param-lemmamap [lemmalist]
  {:lemmamap (lemmalist-to-param-map lemmalist)})

(defn transform-xml-with [params sf]
  (let [xslt (xslt/compile-xslt (io/resource "tei-update-token.xsl"))
        ]

    (xslt/transform xslt params sf)))

(defn transform-xml-with-lemma [params sf]
  (let [xslt (xslt/compile-xslt (io/resource "tei-update-token-with-lemma.xsl"))
        ]
    (xslt/transform xslt params sf)))

(defn write-transform-result-to-file
  "It is difficult to user transform-to-file when you want to pipe transforms.

  Therefore, this function can be used at the end of the pipeline."
  [transform df]
  (let [ser (.newSerializer processor df)
        ]
    (.serializeNode ser transform)
    (.close ser)))

(defn process-annotype
  "Chainable transform

  "
  [xmlin reclist entitytype xmlid]
  (let [types (get-annotations-for-entitytype reclist entitytype)
        param-map (create-param-map types entitytype xmlid)
        ]
    (tap> entitytype)
    (transform-xml-with param-map xmlin)))

(defn process-parsedata
  "Chainable transform for updating lemma data etc."
  [xmlin lemmalist]
  (let [param-map (create-param-lemmamap lemmalist)
        ]
    (transform-xml-with-lemma param-map xmlin)))

(def annotationtypes
  "List of OntonoteNE annotation types processed."
  '("PERSON" "NORP" "FAC" "ORG" "GPE" "LOC" "PRODUCT" "EVENT" "WORK_OF_ART" "LAW" "LANGUAGE" "DATE" "TIME" "PERCENT" "MONEY" "QUANTITY" "ORDINAL" "CARDINAL"))

(defn ner-tei-file
  "Runs the ner- and lemmatization processes for one file in source dataset.

  This is created for use by external clients, so the arguments are
  plain strings. The datasets are expected to be present in the local
  directory tree, or whatever Java is able to access using a pathname.

  The TEI/XML file described by the 'filename' argument is processed
  with the NER- and lemmatization toolchains, and the resulting
  TEI/XML is places in the datadirectory of the destination dataset."
  [sourcefile destinationfile]
  (let [
        xmlid (tei-id-from-file sourcefile)
        wordlists-par (file-to-par-wordlists sourcefile)
        nerlist (process-ner-wordlists wordlists-par)
        lemmalist (process-lemma-wordlists wordlists-par)
        ]
    (tap> (str "ner-tei-file: Processing " sourcefile " to " destinationfile " for file id " xmlid "."))
    (as-> sourcefile sf
      (reduce #(process-annotype %1 nerlist %2 xmlid) sf annotationtypes)
      (process-parsedata sf lemmalist)
      (write-transform-result-to-file sf destinationfile)
      )
    ))

(ner-tei-file teifile nerfile)
