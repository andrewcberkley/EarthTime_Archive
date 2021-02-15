#setwd("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK")
#setwd("C:/Users/ABERK/Box/Internal_ Strategic Intelligence/EarthTime/")

library(DBI)

Rwefsigapi::set_si_db_credentials("aberk", "password")
#con <- Rwefsigapi::open_si_db_connection("DBI", "earthtime")

con <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = "earthtime",
  host = "192.168.166.56",
  port = 5432,
  user = "aberk",
  password = "password"
)

#df_stories <- dplyr::tibble(openxlsx::readWorkbook("Insight_Areas_with_EarthTime_Stories.xlsx", sheet = 1)) #Error: Failed to fetch row: ERROR:  type "c" does not exist at character 63
df_stories <- readxl::read_excel("C:/Users/ABERK/Box/Internal_ Strategic Intelligence/EarthTime/Insight_Areas_with_EarthTime_Stories.xlsx", sheet = 1, col_names = TRUE)

DBI::dbWriteTable(con, "list-stories", df_stories, overwrite = TRUE)
#DBI::(dbReadTable(con, "list-stories"))
#Rwefsigapi::close_connection("DBI", con) 
dbDisconnect(con)

tail(df_stories)

#db_table_check <- as.data.frame(dbReadTable(con, "list-stories"))