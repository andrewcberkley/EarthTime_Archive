setwd(file.path(Sys.getenv('my_dir'),'2021/07/the_expanding_news_desert/usa'))

usa_news_desert <- read.csv("news_desert_columbia_journalism_review.csv")
usa_news_desert <- usa_news_desert[,c(6,3,4,9,10)]

as.data.frame(table(usa_news_desert$total))
#In the United States, 200 counties do not have a local newspaper. Half of all counties--over 1,500--have only one newspaper, usually a weekly.
#Color code by "0", "1", "2+" newspapers in a given county

final_df <- usa_news_desert[,c(1,5,5)]
final_df <- na.omit(final_df)
colnames(final_df) <- c("FIPS", "2020", "2021")

final_df$FIPS <- sprintf("%05d", as.numeric(final_df$FIPS))

write.csv(final_df, "usa_news_deserts_choropleth.csv", row.names = FALSE, na = "")

usa_newspaper_ownership <- read.csv("who_owns_your_newspaper_usc_hussman.csv")
usa_newspaper_ownership <- usa_newspaper_ownership[,c(7,2,8:10)]

as.data.frame(table(usa_newspaper_ownership$Parent.Type))
sum(is.na(usa_newspaper_ownership$Total.Circulation))
colnames(usa_newspaper_ownership) <- c("Newspaper", "Type", "Latitude", "Longitude", "Total_Circulation")

typeList <- split(usa_newspaper_ownership, usa_newspaper_ownership$Type)
for (i in seq_along(typeList)) {
  try({
    filename = paste0(names(typeList)[i], ".csv")
    write.csv(typeList[[i]], filename, na = "", row.names = FALSE)
  })
}

vanishing_newspapers <- read.csv("the_vanishing_daily_newspaper_2004_2016_unc_hussman.csv")