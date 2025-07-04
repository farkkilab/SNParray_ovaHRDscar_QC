#By Fernando Perez
#Use this script to calculate allele specific copy numbers (allele imbalances) using ASCAT3
#As input is necessary to have a file with BAF and LogR per SNP position, see more info about the input in the ASCAT software webpage:
#https://www.mdanderson.org/research/departments-labs-institutes/labs/van-loo-laboratory/resources.html#ASCAT

#Also necessary to have the call rates per sample generated with GenomeStudio
#Also needed a sample sheet, with the same information to the one used in GenomeStudio, but in an R friendly csv format
#If another software was used instead of GenomeStudio, adapt your files in the format, use the example files as guide.
#Also neccesary to have the replication  timing files generated by each SNP-array

#This script is separated in different blocks, run one after another one

#Each script block will save intermediate results in a tables
#In the last block all intermediate result tables will be read and merged to generate a final result table

#Preferably check ASCAT tutorial before running  this script: https://github.com/VanLoo-lab/ascat

################################ Loading packages and functions ###############################################
#Install first devtools and the next packages
library(usethis)
library(devtools)
#remove.packages("ASCAT")
#devtools::install_github('VanLoo-lab/ascat/ASCAT')
library(ASCAT)
library(ggplot2)
#Install ovaHRDscar as this:
#install_github('farkkilab/ovaHRDscar')
library(ovaHRDscar)
library(dplyr)
library(ggrepel)

#Add the path where you have your repository SNParray_ovaHRDscar_QC (scripts) cloned
repo.path <- "C:/Users/anharkon/Documents/HRD-consensus project/SNParray_ovaHRDscar_QC/"


#Next script is in the folder where you cloned the repository
#Loading script with functions
source(paste0(repo.path, "functions_QC_BAF_LOG.R"))

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
################################## Declare your input variables ####################################################
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#This is the folder where you have all the files LogR, BAF
#In this folder a new folder will be created with results
Project_folder <- "D:/users/fperez/SNP-arrays_results/Oncosys_and_others/20250515_Tartu_PARP/"

#The next block of files must be inside the Project_folder!!

#Name for LogRratio and BAF autosome files
Tumor_LogR_pre <- "LogRratio_samples.txt"
Tumor_BAF_pre <- "BAF_samples.txt"

#Sample sheet file with the Sample_ID (arrayIDs) in the first column, and samples names under the column Sample_Name, this file is generated for every SNParray batch it should be in CSV format
samplesheet <- "Sample_sheet.csv"

#Callrate values generated by genomeStudio
callrates <- "Samples_QC.txt"

#GCcorrection file, is a file for each SNParray, was generated using the LogRcorrection module that is part of ASCAT3
#Those files are already generated by Fer an ready to use in a folder
#These files are not needed to be in Project_folder
GCcorrectionfile <- "D:/users/fperez/SNP-arrays_results/Utils/GCcontent_GSAv3.txt"
ReplicationTiming <- "D:/users/fperez/SNP-arrays_results/Utils/ReplicationTiming_GSAv3.txt"

#Next variable is important for calibration with ASCAT, it referst to the type of SNP-array used
#Other common options: "IlluminaGSAv3", "IlluminaGSAv2", "AffyCytoScanHD"
SNParray <- "IlluminaGSAv3"
#Check inside /mnt/d/users/fperez/HRD/SNP_Arrays/ascat-master/ASCAT/R for more SNP array options

#Outputfiles suffix, the most relevant is the ASCAT_segments file, this is the input for the HRDscar script
Suffix <- "PARP_2025May"

####Checking if your files exists in the right path
#Checking the folder
check_file_exists(Project_folder)
#Checking the files
for (f in c(Tumor_LogR_pre, Tumor_BAF_pre, samplesheet, callrates)){
  check_file_exists(paste0(Project_folder,"/",f))
}

#Creating output directory for ASCAT
ascat.output.dir <- paste0(Project_folder,"/ASCAT/")
print(paste0("ASCAT files will be stored in: ", ascat.output.dir))
dir.create(ascat.output.dir)

#Checking if samplesheet and callrates have the right column names
samp.sheet <- read.table(paste0(Project_folder, samplesheet), header = TRUE, sep= ",")
call.rates <- read.table(paste0(Project_folder, callrates), header = TRUE, sep= "\t")

if(!(all(c("Sample_ID", "Sample_Name") %in% colnames(samp.sheet)))){
  stop(paste0("Input file ", samplesheet, " is missing the columns Sample_ID or Sample_Name"))
}

if(!(all(c("Index", "Sample.ID", "Call.Rate") %in% colnames(call.rates)))){
  stop(paste0("Input file ", callrates, " is missing the columns Index or Sample.ID or Call.Rate"))
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
############################### Sorting BAF and Log.R.ratio signal files ###########################################
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#BAF and Log.R.ratio files need to be sorted by chromosome position
#Only probes from autosomes  and X chromosome will be selected

Tumor_LogR="LogRratio_samples_autosomes.txt"
Tumor_BAF="BAF_samples_autosomes.txt"

#Sorting for LogRratio files
sort_select_autosomes(paste0(Project_folder, Tumor_LogR_pre), paste0(Project_folder,Tumor_LogR),
                      input.type="Log.R.Ratio")


#Sorting for BAF files
sort_select_autosomes(paste0(Project_folder, Tumor_BAF_pre), paste0(Project_folder,Tumor_BAF),
                      input.type="B.Allele.Freq")


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
############################## Running ASCAT to get allele imbalances #############################################
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

####Checking if your files exists in the right path
#Checking the folder
check_file_exists(Project_folder)
#Checking the files
for (f in c(Tumor_LogR, Tumor_BAF)){
  check_file_exists(paste0(Project_folder,"/",f))
}


#Next lines are created based on ASCAT tutorial

#Loading files and generating ASCAT object
ascat.bc = ascat.loadData(Tumor_LogR_file = paste0(Project_folder,Tumor_LogR),
                          Tumor_BAF_file = paste0(Project_folder,Tumor_BAF),
                          genomeVersion = "hg38")

#Correction of signal instensity according to GC and replication timing
#According to the files previously generated GCcorrectionfile and ReplicationTiming
ascat.bc = ascat.correctLogR(ascat.bc, GCcontentfile = GCcorrectionfile,
                             replictimingfile = ReplicationTiming)

ascat.plotRawData(ascat.bc, img.prefix = "BAFplot_after_correction_", img.dir = ascat.output.dir)

gg = ascat.predictGermlineGenotypes(ascat.bc, platform = SNParray, img.dir = ascat.output.dir) #creates image files "tumorSep*.png"
ascat.bc = ascat.aspcf(ascat.bc, ascat.gg=gg, out.dir = ascat.output.dir)
ascat.plotSegmentedData(ascat.bc, img.dir = ascat.output.dir)

ascat.output = ascat.runAscat(ascat.bc, img.dir = ascat.output.dir, img.prefix = "NEW_ASCATtest")
#max_purity = 0.93 This was used in the purity_threshold

#Checking for which samples there was not segmentation result from ASCAT
input.samples <- ascat.bc$samples
output.samples <-  names(ascat.output$ploidy)
missing.samples <- input.samples[which(!input.samples %in% output.samples)]

#Extracting ploidy and purity values
ploidy.samples <- round(ascat.output$ploidy,2)
purity.samples <- ascat.output$purity

#Adding label of Failed in the purity and ploidy estimation
if(length(missing.samples) >= 1){
  print(paste0("ASCAT failed for the next sample: ", missing.samples))
  failed.vector <- rep("Failed", length(missing.samples))
  names(failed.vector) <- missing.samples
  ploidy.samples <- c(ploidy.samples, failed.vector)
  purity.samples <- c(purity.samples, failed.vector)
}

ploidy.purity.df <- data.frame(sample=gsub(".Log.R.Ratio", "", names(ploidy.samples)), ASCAT.ploidy=ploidy.samples,
                               ASCAT.purity=purity.samples)


write.table(ascat.output$segments, file = paste0(ascat.output.dir, "ASCAT_segments_", Suffix,".txt"), row.names=FALSE)
write.table(ploidy.samples, file = paste0(ascat.output.dir, "ASCAT_ploidy_", Suffix, ".txt"))
write.table(purity.samples, file = paste0(ascat.output.dir,"ASCAT_purity_", Suffix, ".txt"))


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######################################### Calculate the scars  #####################################################
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


###Formatting segments from ASCAT to make them compatible with ovaHRDscar package: https://github.com/farkkilab/ovaHRDscar
segments <- ascat.output$segments
segments <- segments[which(!is.na(segments[,5])),]

segs <- data.frame(SampleID = segments[,1],
                   Chromosome = paste("chr",segments[,2],sep=""),
                   Start_position = segments[,3],
                   End_position = segments[,4],
                   total_cn = (segments[,5] + segments[,6]),
                   A_cn  = segments[,5],
                   B_cn = segments[,6])


############## Calculating scars in input segments for Hercules ##############
#Firstly getting HRDscars using Telli et al 2016 criteria
telli.scars <- get.ovaHRDscars(segs, chrominfo = "grch38", LOH_windos = c(15,500),
                               LST_segSize = 10e6, LST_mindistance = 3e6)
#Then running ovaHRDscar (new criteria)
ovaHRD.scars <- get.ovaHRDscars(segs, chrominfo = "grch38")
df.telli.scars <- as.data.frame(telli.scars)
df.ovaHRD.scars <- as.data.frame(ovaHRD.scars)

#Removing from the names the .Log.R.Ratio that was added by GenomeStudio to each sample
row.names(df.ovaHRD.scars)<- gsub(".Log.R.Ratio", "", row.names(df.ovaHRD.scars))
row.names(df.telli.scars) <- gsub(".Log.R.Ratio", "", row.names(df.telli.scars))

#Writing intermediate table with Telli et al, 2016 metrics scars and ovaHRDscars in the Project_folder
write.table(df.telli.scars, file=paste0(Project_folder, "Telli_scars_", Suffix,".txt"), sep=",", row.names = TRUE)
write.table(df.ovaHRD.scars, file=paste0(Project_folder, "ovaHRDscars_", Suffix,".txt"), sep=",", row.names = TRUE)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
########################################### Calculate MAPD  ########################################################
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#Reading sample sheet, first columns should match samples IDs in the LogR file
samp.sheet <- read.table(file=paste0(Project_folder, samplesheet), sep=",", header = TRUE)


#Reading LogR file generate with GenomeStudio
LogR <- read.csv(file=paste0(Project_folder,Tumor_LogR), header=TRUE, sep="\t")

samples <- colnames(LogR)[4:ncol(LogR)]
#Removing the last ".Log.R.Ratio" that genomeStudio add to the LogRratio files

shortnames <- sapply(samples, function(x){
  gsub('.Log.R.Ratio', '', x)
})

#Checking if sample names are missing
#Is quite common that R sometimes add an X in the beginning of column names that start with number of other characters
#Then the next ifs will just remove the first characters to see if those matched to the produced by ovaHRDscar
#This problem is not produced with ASCAT, so ASCAT names will not have that X in  the beginning
#An warning will be produced if the samples are not matching
#If the warning is persistent, manually fix the sample names to match to the ones produced by ASCAT
if(shortnames[1] %in% row.names(df.ovaHRD.scars)){
  print("Sample names are matching")
}else{
  print(paste("Sample names are not matching next is missing:", shortnames[1]))
  print("Removing the first string to find match")
  if(substring(shortnames[1],2) %in% row.names(df.ovaHRD.scars)){
      print("Sample names are matching after removing first string")
      print("Proceding to remove first string in sample names")
      shortnames <- sapply(shortnames, function(x){substring(x,2)})
  }else{
    warning(paste("Sample names are not matching next is missing:", shortnames[1]))
  }
}

#Calculating MAPD using the defined function
MAPDs.LogR <- get.MAPD(LogR, samples)
df <- data.frame(sample=c(samples), name=c(shortnames),
                 MAPD = c(MAPDs.LogR), id=factor(rep(1,length(samples))))

df.names <- merge(df, samp.sheet, by.x = "name", by.y = "Sample_ID", all.x = TRUE)
df.names.ids <- df.names[,c("MAPD","name","Sample_Name")]
write.table(df.names.ids, file = paste0(Project_folder,"MAPD_", Suffix, ".txt"), row.names = FALSE)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
################################## Merging all results and info in to one file  ####################################
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#Merge call-rates, MAPD and scar-values for each sample
#Call rates file was created by GenomeStudio
call.rates <- read.table(file=paste0(Project_folder,callrates), sep="\t", header=TRUE)
call.rates.set <- call.rates %>% select(any_of(c("Index","Sample.ID","Call.Rate")))


#Merging MAPD with the table with sample names
calls.mapd <- merge(df.names.ids, call.rates.set, by.x="name", by.y="Sample.ID")

#Renaming col.names of Telli scars to distinguish it from ovaHRDscar metrics
colnames(df.telli.scars) <- c("Telli.LOH","Telli.LSTs","Telli.nTAIs","Telli.HRDsum")

#Merging the MAPD calculation with ovaHRDscar results per samples
aux.file <- merge(calls.mapd, df.ovaHRD.scars, by.x = "name", by.y="row.names", all.x=TRUE)

#Now merging the Telli scars, with the MAP and ovaHRDscar
calls.mapd.scars <- merge(aux.file, df.telli.scars, by.x = "name", by.y="row.names", all.x=TRUE)

#Now merging with the purity and ploidy file
calls.mapd.scars.purity <- merge(calls.mapd.scars, ploidy.purity.df,  by.x = "name", by.y="sample", all.x=TRUE)

#Remove a non relevant column called Index
#The next dataframe is  the final result table
calls.mapd.scars.purity <- calls.mapd.scars.purity %>% select(-any_of("Index"))

#Writing the final results in the next table
write.table(calls.mapd.scars.purity, file = paste0(Project_folder,"QC-scars-info_", Suffix, ".csv"), row.names = FALSE, sep=",")
print(paste0("Final results generated in: ", Project_folder,"QC-scars-info_", Suffix, ".csv"))
