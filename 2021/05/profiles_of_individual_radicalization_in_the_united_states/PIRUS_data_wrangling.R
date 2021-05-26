setwd(file.path(Sys.getenv('my_dir'),'2021/05/profiles_of_individual_radicalization_in_the_united_states'))

df <- readxl::read_excel("PIRUS_Public_May2020.xlsx")

