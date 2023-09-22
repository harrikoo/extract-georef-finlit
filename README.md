# extract-georef-finlit

Code samples for the paper Extracting Geographical References from
Finnish Literature

The whole codebase running the processes is a Clojure-based service,
which contains mostly boiler-place code to manage running the
processes described in [process.org](process.org). It contains many system-
and implementation specific code related to managing the local
services.

This codebase in impractical to include in this repository. It is not
easily adaptable for running elsewhere.

The files included in this repository contain the work that is most
relevant for the actual processing of the data.

The file [process.org](process.org) is an annotated document describing the
code that converts the plain text files first to TEI/XML, and then
runs the texts through TurkuNLP-teams language parser and NER tools.

The file [process.clj](process.clj) contains code as runnable Clojure
program. See [process.org](process.org) for details on using this code.

The original dataset for this tool is: Kiiskinen, Harri, & Nivala, Asko. (2023). 
Atlas of the Finnish Literature project dataset (v1.0.0) [Data set]. Zenodo. 
https://doi.org/10.5281/zenodo.8365866

