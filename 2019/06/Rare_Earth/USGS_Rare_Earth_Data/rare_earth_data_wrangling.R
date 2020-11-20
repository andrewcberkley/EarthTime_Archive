rare_earth <- read.csv("C:/Users/ABERK/Desktop/Global_REE_occurrence_database_aberk2.csv", stringsAsFactors=FALSE)

library(dplyr)
library(tidyverse)
library(data.table)
library(zoo)

df <- rare_earth %>%
	group_by(Disc_Year) %>%
	mutate(idx = row_number()) %>%
	spread(Disc_Year, Status) %>%
	select(-idx)

df_minus <- df[,-c(1:5)]
df_test2 <- t(apply(df_minus, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
df_plus <- df[,c(1:6)]
final_df <- cbind(df_plus, df_test2)
write.csv(final_df, "rare_earth2.csv", row.names = FALSE)

rare_earth2 <- read.csv("C:/Users/ABERK/Desktop/rare_earth2.csv", stringsAsFactors=FALSE)
colnames(rare_earth2) <- sub('X', '', colnames(rare_earth2))

#coalesce_by_column <- function(df) {
#    return(dplyr::coalesce(!!! as.list(df)))
#}

themeList <- split(rare_earth2, rare_earth2$Status)

list2env(lapply(themeList, as.data.frame.list), .GlobalEnv)
for (i in seq_along(themeList)) {
	try({
		filename = paste(names(themeList)[i], ".csv")
		write.csv(themeList[[i]], filename, na = "", row.names = FALSE)
		})
	}

View(alkaline)
rare_earth <- rare_earth[, -c(1,3)]
View(fluorite)
View(rare_earth)
colnames(rare_earth)
df <- rare_earth %>%
rename(
[,c(5:98) = 1926:2017]
)
df <- colnames(rare_earth)[5:98] <- 1926:2017
sub("X", "", rare_earth[,5:98])
sub("X", "", rare_earth[,c(5:98)])
sub("X", "", rare_earth[,(5:98)])
sub("X", "", rare_earth[,5])
sub("X", "", rare_earth[,5:96])
df<-sub("X", "", rare_earth[,5:96])
df <- rare_earth %>%
rename(
[,c(5:96) = 1926:2017]
)
df <- rare_earth %>%
rename(
[,5:96 = 1926:2017]
)
names(rare_earth) <- sub('X', '', names(rare_earth))
themeList <- split(rare_earth, rare_earth$Deposit_Type)
list2env(lapply(themeList, as.data.frame.list), .GlobalEnv)
for (i in seq_along(themeList)) {
try({
filename = paste(names(themeList)[i], ".csv")
write.csv(themeList[[i]], filename, na = "", row.names = FALSE)
})
}
View(themeList)