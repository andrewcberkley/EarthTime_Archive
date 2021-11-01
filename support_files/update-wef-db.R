setwd(file.path(Sys.getenv('my_dir')))

library(DBI)

Rwefsigapi::set_si_db_credentials("username", "password")

con <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = "earthtime",
  host = "192.168.166.56",
  port = 5432,
  user = "username",
  password = "password"
)

df_stories <- readxl::read_excel("Insight_Areas_with_EarthTime_Stories.xlsx", sheet = 1, col_names = TRUE)

DBI::dbWriteTable(con, "list-stories", df_stories, overwrite = TRUE)
#DBI::(dbReadTable(con, "list-stories"))
#Rwefsigapi::close_connection("DBI", con) 
dbDisconnect(con)

tail(df_stories)

#db_table_check <- as.data.frame(dbReadTable(con, "list-stories"))