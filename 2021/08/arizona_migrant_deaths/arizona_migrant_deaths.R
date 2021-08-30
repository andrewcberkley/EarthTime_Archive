setwd(file.path(Sys.getenv('my_dir'),'2021/08/arizona_migrant_deaths/'))

ogis_migrant_deaths <- read.csv("ogis_migrant_deaths.csv")



library(reticulate)
#suppressWarnings(use_python("C:/ProgramData/Anaconda3/", required = TRUE))
#py_config()
#py_install("pandas")

source_python('PIRUS_dotmap_creation.py')
#py_last_error()