# Overview
DeclareMiner2 is a sequence-analysis based discovery algorithm for declarative business process models.

It is developed in Java (v.8), tested on Windows and Ubuntu Linux platforms. Test routines are encoded as BASH command scripts. Plots and summary files are generated via R scripts.

# Contents
Contents will be regularly updated. Currently, we provide the full extent of synthetic event logs and performance evaluation material.
  - /evaluation: in this directory all time performance and memory usage reports are stored. The results were gathered from runs on a Ubuntu Linux 12.04 server machine, equipped with Intel Xeon CPU E5-2650 v2 2.60GHz, using eight 64-bit CPU cores and 16GB main memory quota.
  - /event-logs: synthetic event logs used for performance evaluation. Logs were generated with the MINERful declarative process mining toolkit (https://github.com/cdc08x/MINERful). For the sake of space saving, logs are provided within a compressed ZIP package. A BASH script is provided to automatically unzip the file contents into the "synthetic" subdirectory.
  - /jars: the JAR packages containing the implemented software prototype in three different variants (sequential, parallelised over the search space, and parallelised over the database).
  - /test-environment: the testing environment containing scripts and runnable files to conduct the evaluation. Please notice that some configuration parameters listed at the beginning of BASH scripts might need to be changed according to the local machine in which tests are run.

# Authors
  - Core software development: Chiara Di Francescomarino (email: dfmchiara@fbk.eu)
  - Core software development: Fabrizio M. Maggi (email: f.m.maggi@ut.ee)
  - Testing and automations: Claudio Di Ciccio (email: claudio.di.ciccio@wu.ac.at; GitHub: https://github.com/cdc08x)
  - Software development adjunct: Taavi Kala (email: kala@ut.ee)

# Publications
This software is the implementation of an approach which constitutes the main contribution of an article currently under review for publication on the Elsevier Information Systems journal (second round).
The latest published paper describing the non-parallel variant of the software is:
  - T. Kala, F. M. Maggi, C. Di Ciccio and C. Di Francescomarino, "Apriori and Sequence Analysis for Discovering Declarative Process Models," 2016 IEEE 20th International Enterprise Distributed Object Computing Conference (EDOC), Vienna, 2016, pp. 1-9.
http://dx.doi.org/10.1109/EDOC.2016.7579378
