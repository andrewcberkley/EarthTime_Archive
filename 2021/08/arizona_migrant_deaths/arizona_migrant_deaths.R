setwd(file.path(Sys.getenv('my_dir'),'2021/08/arizona_migrant_deaths/'))

library(reticulate)
#suppressWarnings(use_python("C:/ProgramData/Anaconda3/", required = TRUE))
#py_config()
#py_install("pandas")

suppressWarnings(ogis_migrant_deaths <- readxl::read_excel("ogis_migrant_deaths.xlsx"))

clean_df <- ogis_migrant_deaths[,c(1,5,18,19)]
clean_df$`Reporting Date` <- as.Date(clean_df$`Reporting Date`)
clean_df$Dummy_Number <- 10
final_df <- na.omit(clean_df)

as.data.frame(table(ogis_migrant_deaths$`Cause of Death`))
as.data.frame(table(ogis_migrant_deaths$`OME Determined COD`))

write.csv(final_df, "arizona_migrant_deaths.csv", row.names = FALSE, na = "")

source_python('arizona_migrant_deaths_dotmap.py')
#py_last_error()