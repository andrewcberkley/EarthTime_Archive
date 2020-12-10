setwd(file.path(Sys.getenv('my_dir'),'2019/10/Taxes/'))

#library(data.table)
library(tidyverse)

# TID_full_comments <- read.csv("C:/Users/ABERK/Desktop/TID_full_comments_20191006/TID_full_comments.csv", header = TRUE, sep = "|", comment.char="#", stringsAsFactors=FALSE)

# TID_full_comments_clean <- TID_full_comments[,c(2,3,6,8)]

# df <- TID_full_comments_clean %>%
#     group_by(year) %>%
#     mutate(idx = row_number()) %>%
#     spread(year, rate) %>%
#     select(-idx)

REV_31102019112946759 <- read.csv("REV_31102019112946759.csv")

df <- REV_31102019112946759[grep("TAXGDP", REV_31102019112946759[,"VAR"]),]
df2 <- df[,c(7,9,17)]

df3 <- df2 %>%
    group_by(YEA) %>%
    mutate(idx = row_number()) %>%
    spread(YEA, Value) %>%
    select(-idx)

coalesce_by_column <- function(df) {
   return(dplyr::coalesce(!!! as.list(df)))
}

df4 <- df3 %>%
   group_by(COU) %>%
   summarise_all(return(dplyr::coalesce(!!! as.list(df3))))