setwd(file.path(Sys.getenv('my_dir'),'2021/08/arizona_migrant_deaths/'))

library(reticulate)
#suppressWarnings(use_python("C:/ProgramData/Anaconda3/", required = TRUE))
#py_config()
#py_install("pandas")

suppressWarnings(ogis_migrant_deaths <- readxl::read_excel("ogis_migrant_deaths_v2.xlsx"))

clean_df <- ogis_migrant_deaths[,c(1,3,5,11,18,19)]
clean_df$`Reporting Date` <- as.Date(clean_df$`Reporting Date`)
clean_df$Dummy_Number <- 10
final_df <- na.omit(clean_df)

as.data.frame(table(ogis_migrant_deaths$`Cause of Death`))
as.data.frame(table(ogis_migrant_deaths$`OME Determined COD`))

write.csv(final_df, "arizona_migrant_all_deaths.csv", row.names = FALSE, na = "")

female_deaths <- clean_df[grep("female",clean_df$Sex),]
deaths_from_exposure <- clean_df[grep("Exposure|Not Reported|Other injury",clean_df$`Cause of Death`),]
skeletal_remains <- clean_df[grep("Skeletal Remains",clean_df$`Cause of Death`),]

write.csv(female_deaths, "arizona_migrant_female_deaths.csv", row.names = FALSE, na = "")
write.csv(deaths_from_exposure, "arizona_migrant_deaths_from_exposure.csv", row.names = FALSE, na = "")
write.csv(skeletal_remains, "arizona_migrant_skeletal_remains.csv", row.names = FALSE, na = "")




source_python('arizona_migrant_deaths_dotmap.py')
#py_last_error()