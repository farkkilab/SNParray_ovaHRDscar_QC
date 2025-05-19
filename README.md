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

Example of input LogRratio file
```
Name	Chr	Position	206064570174_R01C01.Log R Ratio	206064570174_R01C02.Log R Ratio	206064570174_R02C01.Log R Ratio	206064570174_R02C02.Log R Ratio	206064570174_R03C01.Log R Ratio	206064570174_R10C02.Log R Ratio	206064570174_R03C02.Log R Ratio	206064570174_R11C01.Log R Ratio	206064570174_R04C01.Log R Ratio	206064570174_R04C02.Log R Ratio	206064570174_R11C02.Log R Ratio	206064570174_R12C01.Log R Ratio	206064570174_R12C02.Log R Ratio	206064570174_R05C01.Log R Ratio	206064570174_R05C02.Log R Ratio	206064570174_R06C01.Log R Ratio	206064570174_R06C02.Log R Ratio	206064570174_R07C01.Log R Ratio	206064570174_R07C02.Log R Ratio	206064570174_R08C01.Log R Ratio	206064570174_R08C02.Log R Ratio	206064570174_R09C01.Log R Ratio	206064570174_R09C02.Log R Ratio	206064570174_R10C01.Log R Ratio
IlmnSeq_17:43099552_IlmnFwd	1	0	0.7191634	1.232309	0.6488559	0.7817191	0.6213158	0.6429217	0.5512549	0.7079162	0.705276	0.6701797	0.9380691	0.5576202	0.7030863	0.6027012	0.6959698	0.5450346	1.124111	0.5086232	0.7135237	0.7958611	1.034548	1.268045	0.6614875	0.5556911
IlmnSeq_17:43099552_IlmnFwd_IlmnDup	1	0	0.8655574	1.179978	0.7319136	0.8444639	0.6306585	0.7473103	0.6258497	0.6979511	0.8552735	0.7017136	0.9402447	0.6885636	0.740797	0.7270788	0.7331293	0.5639323	1.222433	0.4660039	0.6853693	0.8570293	0.9934208	1.362574	0.579665	0.5547479
rs9701055	1	630053	0.3893069	0.5379636	0.3871996	0.4364024	0.4511624	0.3668727	0.4669874	0.316742	0.4920027	0.4962164	0.1777317	0.3415704	0.4077463	0.4062677	0.4710341	0.4507235	0.6615481	0.472096	0.4945696	0.5795947	0.5849816	0.7296833	0.5153152	-0.07950793
rs9651229	1	632287	0.4435982	0.9377586	0.5331625	0.6015976	0.4818882	0.3493343	0.4979472	0.4521202	0.5898902	0.4980383	0.6990404	0.550526	0.5657884	0.5108349	0.6440192	0.4231185	0.9356945	0.3098097	0.5584352	0.5642474	0.6614115	0.9411695	0.5881542	0.5340207

```


**2. Call rates for each sample generated with GenomeStudio:**



