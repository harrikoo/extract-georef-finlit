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

# The Project _Atlas of Finnish Literature 1870–1940_

## Project Description

This code was created as part of the project "The Atlas of Finnish
Literature 1870-1940" (funded by Alfred Kordelin Foundation, PI: Asko
Nivala). The aim of the project was to use natural language processing
(NLP) and geographic information systems (GIS) to study the spatiality
of Finnish fiction. Our aim was to investigate what places are
mentioned in the Finnish literature and what kind of maps can be drawn
from this material.

For the project, we collected a large corpus of Finnish fiction from
the 1870s to 1940s. The texts were sourced from Projekti Lönnrot and
Project Gutenberg, so the texts are proofread by human readers and do
not contain OCR noise. We developed a parser to split the works into
chapters based on the metadata we compiled, and to segment collections
of texts into individual works. The resulting XML-TEI documents were
then run through a named entity recognition (NER). NER searched the
text for different names and classified spatial entities into
administrative (GPE), geographical (LOC) and man-made (FAC)
entities. XML-TEI documents were also run through the and part of
speech tagging(POS) algorithm, which searched for lemmata for
words. We needed a lemma to link the results with Wikidata to find the
corresponding geographical coordinates for place names.

A more detailed description of the process and a fully executable
pipeline are published in this repository.

## Contact

Dr. Asko Nivala\
aeniva(at)utu.fi\
Docent of Cultural History\
University of Turku\
Finland

## Research Group

Dr. Harri Kiiskinen (Creator of the dataset and processing pipeline)\
Dr. Asko Nivala (Principal investigator)\
Dr. Jasmine Westerlund (Corpus and metadata collection; data verification)\
Dr. Juhana Saarelainen (Data verification)\
Ville Hietamäki (Web developer)\

## Funding

Alfred Kordelin Foundation – Major Cultural Projects 2022–2024

## Computational Infrastructure

Computational infrastructure was provided by CSC – IT Center for
Science and University of Turku

## Suggested Citation

Kiiskinen, Harri; Nivala, Asko; Saarelainen, Juhana & Westerlund,
Jasmine: "Extracting Geographical References from Finnish
Literature. Fully Automated Processing of Plain-Text Corpora."
Conference Proceedings of 2nd Annual Conference of Computational
Literary Studies, Würzburg 2023.
