#setwd("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK")
#setwd("C:/Users/ABERK/Box/Internal_ Strategic Intelligence/EarthTime/")

Rwefsigapi::set_si_db_credentials("aberk", "password")
con <- Rwefsigapi::open_si_db_connection("DBI", "earthtime")

#df_stories <- dplyr::tibble(openxlsx::readWorkbook("Insight_Areas_with_EarthTime_Stories.xlsx", sheet = 1)) #Error: Failed to fetch row: ERROR:  type "c" does not exist at character 63
df_stories <- readxl::read_excel("C:/Users/ABERK/Box/Internal_ Strategic Intelligence/EarthTime/Insight_Areas_with_EarthTime_Stories.xlsx", sheet = 1, col_names = TRUE)

DBI::dbWriteTable(con, "list-stories", df_stories, overwrite = TRUE)
#DBI::(dbReadTable(con, "list-stories"))
Rwefsigapi::close_connection("DBI", con) 
tail(df_stories)