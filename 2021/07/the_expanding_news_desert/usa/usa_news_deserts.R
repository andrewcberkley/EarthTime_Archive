setwd(file.path(Sys.getenv('my_dir'),'2021/07/the_expanding_news_desert/usa'))

usa_news_desert <- read.csv("news_desert_columbia_journalism_review.csv")

usa_news_desert <- usa_news_desert[,c(6,3,4,9,10)]