setwd(file.path(Sys.getenv('my_dir'),'2021/05/impicit_racial_bias/'))

library(foreign)
library(memisc)
library(plyr)
library(dplyr)

## Loop for..
## 1) Iteratively get all the raw statistical file from 'raw' folder 
## 2) Generate csv file and put under 'cleansed' folder for further processing
#fileNames <- Sys.glob(paste("implicit_bias_project_implicit_harvard_university/race_iat_public/*.", "sav", sep = ""))
#fileNumbers <- seq(fileNames)
#memory.limit(size=407070)
#setwd(file.path(Sys.getenv('my_dir'),'2021/05/impicit_racial_bias/cleaned_datea_race_iat_public/'))
#for (fileNumber in fileNumbers)
#{
#  shortFileName <- tail(strsplit(fileNames[fileNumber],"/")[[1]],1)
#  csvFileName <-  paste("cleaned_datea_race_iat_public/", sub(paste("\\.", "sav", sep = ""), "", shortFileName),".", "csv", sep = "")
#  dataset1 = read.spss(fileNames[fileNumber], to.data.frame=TRUE)

#  if (fileNames == "Race IAT.public.2002-2003.sav|Race IAT.public.2004.sav") {
#    df <- dataset1[,c("D_biep.White_Good_all","country","ethnic")]
#    colnames(df)[which(names(df) == "raceomb")] <- "ethnic"
#    } else if (fileNames == "Race IAT.public.2005.sav|Race IAT.public.2006.sav")  {
#      df <- dataset1[,c("D_biep.White_Good_all","countrycit","countryres","ethnic")] 
#      } else if (fileNames == "Race IAT.public.2017.sav|Race IAT.public.2018.sav|Race IAT.public.2019.sav|Race IAT.public.2020.sav")  {
#        df <- dataset1[,c("D_biep.White_Good_all","countrycit_num","countryres_num","ethnic")] 
#        }else {
#          df <- dataset1[,c("D_biep.White_Good_all","countrycit","countryres","ethnicityomb")]
#        }
#  write.csv(df, csvFileName)
#}

###### cleaning the csv files for unwanted entries in countrycit ######
setwd(file.path(Sys.getenv('my_dir'),'2021/05/impicit_racial_bias/cleaned_datea_race_iat_public/'))

fileNames <- list.files(path = file.path(getwd()), pattern = "*.csv")
fileNumbers <- seq(fileNames)

for (fileNumber in fileNumbers)
{
  #csvFileName <-  paste(sub(paste("\\.", "csv", sep = ""), "", fileNames[fileNumber]),".", "csv", sep = "")
  df = read.csv(file.path(fileNames[fileNumber]), header=TRUE)
  df2 <- df[!df$countrycit %in% c(". ","  ",".",".   ","    "),]
  ## Remove the white spaces infront of countrycodes ##
  df22 <- data.frame(lapply(df2, trimws))
  ## removing an unwanted column carried over
  cols.dont.want <- "X"
  df3 <- df22[, ! names(df22) %in% cols.dont.want, drop = F]
  xx<-fileNames[fileNumber]
  #xx <- paste(dataloc,"/cleansed/",tail(strsplit(fileNames[fileNumber],"/")[[1]],1),sep="")
  write.csv(df3, xx, row.names=FALSE, quote=FALSE)
}

###### Additional processing for 2015 file ######
## Seperating 2015 file to new format and old format files ##

df <- read.csv(file.path(dataloc,'cleansed',"RaceIAT_public_2015.csv"), header=TRUE)
df2 <- df[grepl(pattern="[[:digit:]]", df$countrycit)|grepl(pattern="[[:digit:]]", df$countryres), ]
dfdig <- df2[!grepl(pattern="-9", df2$countrycit), ]
dfalp <- df[grepl(pattern="[[:alpha:]]", df$countrycit) & !grepl(pattern="[[:digit:]]", df$countryres), ]
write.csv(dfdig, file.path(dataloc,"cleansed","RaceIAT_public_2015_digit.csv"), row.names=FALSE, quote=FALSE)
write.csv(dfalp, file.path(dataloc,"cleansed","RaceIAT_public_2015_alpha.csv"), row.names=FALSE, quote=FALSE)
#Deleting the old file to replace with the processed file
fn <- file.path(dataloc,"cleansed","Race IAT.public.2015.csv")
if (file.exists(fn)) file.remove(fn)