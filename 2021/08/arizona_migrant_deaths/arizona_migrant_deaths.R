setwd(file.path(Sys.getenv('my_dir'),'2021/08/arizona_migrant_deaths/'))

suppressWarnings(ogis_migrant_deaths <- readxl::read_excel("ogis_migrant_deaths.xlsx"))

clean_df <- ogis_migrant_deaths[,c(1,5,18,19)]
clean_df$Dummy_Number <- 10
write.csv(clean_df, "arizona_migrant_deaths.csv", row.names = FALSE, na = "")

library(reticulate)
#suppressWarnings(use_python("C:/ProgramData/Anaconda3/", required = TRUE))
#py_config()
#py_install("pandas")

source_python('arizona_migrant_deaths_dotmap.py')
#py_last_error()