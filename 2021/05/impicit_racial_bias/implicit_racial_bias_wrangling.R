setwd(file.path(Sys.getenv('my_dir'),'2021/05/impicit_racial_bias/'))

library(foreign)
library(memisc)
library(plyr)
library(dplyr)

fileNames <- Sys.glob(paste("implicit_bias_project_implicit_harvard_university/race_iat_public/*.", "sav", sep = ""))
fileNumbers <- seq(fileNames)
# Loop for..
# 1) Iteratively get all the raw statistical file from 'raw' folder 
# 2) Generate csv file and put under 'cleansed' folder for further processing

memory.limit(size=407070)

for (fileNumber in fileNumbers)
{
  shortFileName <- tail(strsplit(fileNames[fileNumber],"/")[[1]],1)
  csvFileName <-  paste(sub(paste("\\.", "sav", sep = ""), "", shortFileName),".", "csv", sep = "")
  dataset1 = read.spss(fileNames[fileNumber], to.data.frame=TRUE)

  if (fileNames == "Race IAT.public.2002-2003.sav|Race IAT.public.2004.sav") {
    df <- dataset1[,c("D_biep.White_Good_all","country","ethnic")]
    colnames(df)[which(names(df) == "raceomb")] <- "ethnic"
    } else if (fileNames == "Race IAT.public.2005.sav|Race IAT.public.2006.sav")  {
      df <- dataset1[,c("D_biep.White_Good_all","countrycit","countryres","ethnic")] 
      } else if (fileNames == "Race IAT.public.2017.sav|Race IAT.public.2018.sav|Race IAT.public.2019.sav|Race IAT.public.2020.sav")  {
        df <- dataset1[,c("D_biep.White_Good_all","countrycit_num","countryres_num","ethnic")] 
        }else {
          df <- dataset1[,c("D_biep.White_Good_all","countrycit","countryres","ethnicityomb")]
        }
  write.csv(df, csvFileName)
}
