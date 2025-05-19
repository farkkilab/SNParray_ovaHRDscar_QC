# SNParray_ovaHRDscar_QC
Script for calculating ovaHRDscar from LogRatio files and BAF files produced with GenomeStudio

## Getting started

### Requirements

- R 4.2.3
- R packages:
  - usethis
  - devtools
  - dplyr
  - ggrepel
  - ovaHRDscar (https://github.com/farkkilab/ovaHRDscar)

In addition you would need ASCAT v3.1.2. This version is stored in our datacloud: https://datacloud.helsinki.fi/index.php/f/54077565
To install this ASCAT version do the next:
1. Download the ascat-master.zip file
2. Decompress the file
3. In case you have another version of ASCAT already installed, uninstall that ASCAT version you have.
4. Install this ASCAT version from R studio in the next way, just replace YOURPATH for your own computer path where you decompressed the ascat-master.zip file.

```
install_local("YOURPATH/ascat-master/ASCAT/", force = TRUE)
```

### Input files

**1. LogR ratio files and BAF files from GenomeStudio:**

From Illumina-SNP arrays raw data the LogR ratio and BAF files can be generated using the Genome Studio software ([link](https://www.illumina.com/techniques/microarrays/array-data-analysis-experimental-design/genomestudio.html)).

Here there is a tutorial about how to prepare a Genome Studio project: <https://www.youtube.com/embed/s23379Gya0Y?autoplay=1&rel=0>

Once that the project is setup and the call rates have been generated, next select the columns necessary for this script and export those in a text file. Here is a tutorial that describe how to select the columns: [link](http://penncnv.openbioinformatics.org/en/latest/user-guide/input/#preparing-input-signal-intensity-files-from-beadstudio-project-files)

Also here there is information about how  to generate the input files: https://docs.google.com/document/d/1mXT1G87VnemVMd0mZsD9MbP4VigF6vtQ/edit


**2. Call rates for each sample generated with GenomeStudio:**



