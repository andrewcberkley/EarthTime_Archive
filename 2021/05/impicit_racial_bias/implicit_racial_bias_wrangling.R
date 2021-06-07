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

for (fileNumber in fileNumbers)
{
  shortFileName <- tail(strsplit(fileNames[fileNumber],"/")[[1]],1)
  csvFileName <-  paste("/cleaned/",sub(paste("\\.", "sav", sep = ""), "", shortFileName),".", "csv", sep = "")
  dataset1 = read.spss(fileNames[fileNumber], to.data.frame=TRUE)
  #This way of loading sav doesnt work in my machine, so commenting out for testing
  #dataset1 <- data.frame(as.data.set(spss.system.file(file.path(fileNames[fileNumber]))))
  #Get the fields that you are interested in
  #For some reason this first column was not capitalised in my data
  #2004 ethnic 2005 ethnic 2006 ethnic ethnicityomb raceomb # ethnic2007 ethnicityomb raceomb
  #Getting raceomb from 2007 file onwards # 2006 have some issues ie if fileNumber>2
  #Ignoring "raceombmulti","ethnicityomb" for now as these fields are not present in all files
  #dd <- dataset1[,c("d_biep.white_good_all","countrycit","countryres","raceomb","raceombmulti","ethnicityomb")]
  #if(fileNumber>3) {
    df <- dataset1[,c("D_biep.White_Good_all","country","ethnic")]
    colnames(df)[which(names(df) == "raceomb")] <- "ethnic"
  #} else { 
    #df <- dataset1[,c("D_biep.White_Good_all","countrycit","countryres","ethnicityomb")]
  #}
  write.csv(df, file.path(csvFileName))
}

setwd(file.path(Sys.getenv('my_dir'),'2021/05/impicit_racial_bias/implicit_bias_project_implicit_harvard_university/race_iat_public/'))
test <- read.spss("Race IAT.public.2007.sav", to.data.frame=TRUE)
df <- test[,c("D_biep.White_Good_all","country","ethnic")]