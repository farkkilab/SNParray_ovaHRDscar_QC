#Made by Fernando Perez-Villatoro
#Script for calculating nomalized LSTs by inferred whole genome duplications (WGD) according to: Christinat, Yann, et al. JCO Precision Oncology 2023: e2200555.
#The nLSTs are calculated as follow:  nLST = LST − kW, where W is the number of WGD
#The LTS are by defined by T. popova et al, 2012 and adopted by Telli et al, 2016

###########################Importing libraries#########################
library(dplyr)


############################Defining inputs############################
#Reading file with ploidy per sample inferred by ASCAT and with LSTs defined by T.popova et al, 2012 and used adopted by Telli et al, 2016
scars.ploidy <- "L:/ltdk_farkkila/Projects/SNP-arrays_results/Raw_and_intermediante_files_fernando/Oncosys_and_others/20250515_Tartu_PARP/QC-scars-info_PARP_2025May.csv"

#Scaling factor for WGD and LST defined by Christinat, Yann, et al. 2023
#The scaling factor used in the next formula `nLST = LST − kW`, where W is the number of WGD
k <- 3.5

#The name of column with ploidy values
ploidy.col <- "ASCAT.ploidy"

#The name of column with LTS by defined by T.popova et al, 2012 and used adopted by Telli et al, 2016
LST.col <- "Telli.LSTs"

#Defining your output filename. The output file will be created in the same folder as the input
output <- "QC_ovaHRDscar_nLSTs.csv"


#############################Calculating normalized LSTs##########################
scars.df <- read.table(scars.ploidy, header = TRUE, sep=",")

#Checking that input file has the needed columns and columns names
if(!all(c(ploidy.col, LST.col) %in% colnames(scars.df))){
  stop("Either the column defined by ploidy.col or LST.col is not present in your input file. 
       Redefine these variable names or add these columns to your input file")
}

#Changing the ploidy and LSTs to numeric, this will introduce NA in non.numeric values
scars.df[,ploidy.col] <- as.numeric(scars.df[,ploidy.col])
scars.df[,LST.col] <- as.numeric(scars.df[,LST.col])


#Calculating WGD as done  by  Christinat, Yann, et al. 2023, and defined by Carter SL, et al, Nat Biotechnol, 2012
scars.df <- scars.df %>% mutate(WGD = case_when(.data[[ploidy.col]] <= 2.2 ~ 0,
                                          (.data[[ploidy.col]] > 2.2 & .data[[ploidy.col]] <= 3.4) ~ 1,
                                          .data[[ploidy.col]] > 3.4 ~ 2,
                                          .default=NA))

#Calculating nLSTs as nLST = LST − kW, where W is the number of WGD
scars.df$nLSTs <- scars.df[,LST.col] - k * scars.df$WGD
print("nLSTs were successfully calculated!")


#Writing results to file. It will be created in the same directory as the input file
write.table(scars.df, paste0(dirname(scars.ploidy), "/",output), row.names = FALSE, sep=",")
print(paste0("Your results are saved in the file: ", dirname(scars.ploidy), "/",output))
