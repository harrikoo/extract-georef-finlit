# extract-georef-finlit

Code samples for the paper Extracting Geographical References from
Finnish Literature

The whole codebase running the processes is a Clojure-based service,
which contains mostly boiler-place code to manage running the
processes described in <file:process.org>. It contains many system-
and implementation specific code related to managing the local
services.

This codebase in impractical to include in this repository. It is not
easily adaptable for running elsewhere.

The files included in this repository contain the work that is most
relevant for the actual processing of the data.

The file <file:process.org> is an annotated document describing the
code that converts the plain text files first to TEI/XML, and then
runs the texts through TurkuNLP-teams language parser and NER tools.

The file <file:process.clj> contains code as runnable Clojure
program. See <file:process.org> for details on using this code.

