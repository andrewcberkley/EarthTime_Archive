setwd(file.path(Sys.getenv('my_dir'),'2021/08/arizona_migrant_deaths/'))

suppressWarnings(ogis_migrant_deaths <- readxl::read_excel("ogis_migrant_deaths.xlsx"))

library(reticulate)
#suppressWarnings(use_python("C:/ProgramData/Anaconda3/", required = TRUE))
#py_config()
#py_install("pandas")

source_python('PIRUS_dotmap_creation.py')
#py_last_error()