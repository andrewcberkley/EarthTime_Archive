setwd(file.path(Sys.getenv('my_dir'),'2021/08/arizona_migrant_deaths/'))

suppressWarnings(ogis_migrant_deaths <- readxl::read_excel("ogis_migrant_deaths.xlsx"))

clean_df <- ogis_migrant_deaths[,c(1,5,18,19)]

library(reticulate)
#suppressWarnings(use_python("C:/ProgramData/Anaconda3/", required = TRUE))
#py_config()
#py_install("pandas")

source_python('arizona_migrant_deaths_dotmap_creation.py')
#py_last_error()