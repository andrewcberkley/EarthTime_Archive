setwd(file.path(Sys.getenv('my_dir'),'2021/10/un_blue_helmets'))

casualties <- read.csv("odp_noticas.csv")
#contributions_rank <- read.csv("odp_contributionranks.csv")
contributions_gender <- read.csv("odp_contributionsbygender.csv")

as.data.frame(table(contributions_gender$Contributing_Country))

ipi_data <- read.csv("international_peace_institute_peacekeeping_database.csv")