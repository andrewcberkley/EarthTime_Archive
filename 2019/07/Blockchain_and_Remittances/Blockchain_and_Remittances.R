#Bitcoin Accepting Venues Data
library(tidyverse)
library(httr)
library(jsonlite)
library(anytime)
library(zoo)

path <- "https://coinmap.org/api/v1/venues/"
request <- GET(url = path)
response <- content(request, as = "text", encoding = "UTF-8")
bitcoin_venues_df <- fromJSON(response, flatten = TRUE) %>% data.frame()
bitcoin_venues_df$venues.created_on <- anytime(bitcoin_venues_df$venues.created_on)
bitcoin_venues_df <- bitcoin_venues_df[,c(1,5,2,3,4)]
colnames(bitcoin_venues_df) <- c("Name", "Latitude", "Longitude", "Year", "Category")
bitcoin_venues_df$Year <- sub(" .*", "", bitcoin_venues_df$Year)
bitcoin_venues_df$Count <- 1

df2 <- bitcoin_venues_df %>%
    group_by(Year) %>%
    mutate(idx = row_number()) %>%
    spread(Year, Count) %>%
    select(-idx)

df2[5:11] <- t(apply(df2[5:11], 1, function(x) na.locf(x, fromLast = F, na.rm = F)))

write.csv(df2, "bitcoin_venues.csv", na = "", row.names = FALSE)

#Bilateral Remittance Matricies
library(gdata)
library(xlsx)
library(glue)
library(purrr)
library(tidyr)

download.file("http://pubdocs.worldbank.org/pubdocs/publicdoc/2015/9/895701443117529385/Bilateral-Remittance-Matrix-2010.xlsx", destfile = "~/BilateralRemittanceMatrix2010.xlsx", mode='wb')
download.file("http://pubdocs.worldbank.org/pubdocs/publicdoc/2015/9/919711443117529856/Bilateral-Remittance-Matrix-2011.xlsx", destfile = "~/BilateralRemittanceMatrix2011.xlsx", mode='wb')
download.file("http://pubdocs.worldbank.org/pubdocs/publicdoc/2015/9/106901443117530403/Bilateral-Remittance-Matrix-2012.xlsx", destfile = "~/BilateralRemittanceMatrix2012.xlsx", mode='wb')
download.file("http://pubdocs.worldbank.org/pubdocs/publicdoc/2015/9/103071443117530921/Bilateral-Remittance-Matrix-2013.xlsx", destfile = "~/BilateralRemittanceMatrix2013.xlsx", mode='wb')
download.file("http://pubdocs.worldbank.org/pubdocs/publicdoc/2015/10/936571445543163012/bilateral-remittance-matrix-2014.xlsx", destfile = "~/BilateralRemittanceMatrix2014.xlsx", mode='wb')
download.file("http://pubdocs.worldbank.org/en/892861508785913333/bilateralremittancematrix2015-Oct2016.xlsx", destfile = "~/BilateralRemittanceMatrix2015.xlsx", mode='wb')
download.file("http://www.knomad.org/sites/default/files/2017-11/bilateralremittancematrix2016_Nov2017.xlsx", destfile = "~/BilateralRemittanceMatrix2016.xlsx", mode='wb')
download.file("http://pubdocs.worldbank.org/en/705611533661084197/bilateralremittancematrix2017-Apr2018.xlsx", destfile = "~/BilateralRemittanceMatrix2017.xlsx", mode='wb')

#Bilateral Remittance Estimates for 2010 using Migrant Stocks, Host Country Incomes, and Origin Country Incomes (millions of US$) (By Year)
##Remittance-receiving country (across) in raw dataframe
##Remittance-sending country (down) in raw dataframe

year <- c("2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017")
doc_names <- glue("BilateralRemittanceMatrix{year}.xlsx")

data <- lapply(doc_names, function(x) format(read.xlsx(x, sheetIndex = 1, as.data.frame = TRUE, header = TRUE, startRow = 2, stringsAsFactors = FALSE), scientific = FALSE))
names(data) <- stringr::str_replace(doc_names, pattern = ".xlsx", replacement = "")

combined_data <- map_df(data, ~as.data.frame(.x), .id="Year")

combined_data[,1] <- stringr::str_replace(combined_data[,1], pattern = "BilateralRemittanceMatrix", replacement = "")

colnames(combined_data)[2] <- "Remittance-receiving country (across) & Remittance-sending country (down)"

combined_data <- combined_data[,-c(216:217, 226:227)]

data_long <- gather(combined_data, "Remittance-Receiving Country", "Remittance Amount (millions of USD)", 3:223, factor_key = TRUE)
colnames(data_long)[2] <- "Remittance-Sending Country"

data_long[,4] <- as.numeric(data_long[,4])
data_long[data_long==""] <- NA
data_long[data_long==0] <- NA
data_long[,4] <- format(as.numeric(data_long[,4]), scientific = FALSE)
data_long <- data_long[!grepl("World", data_long[,2]),]
data_long <- data_long[!grepl("WORLD", data_long[,2]),]
data_long[,3] <- gsub("\\.", " ", data_long[,3])
data_long <- data_long[order(data_long[,1]),]

ISO_Country_Codes <- read.csv("./Data_Science_Exploration/ABERK/ISO_Country_Codes.csv", stringsAsFactors=FALSE)
#ISO Code for "Remittance-Sending Country"
data_long[,2] <- ISO_Country_Codes[match(data_long[,2], ISO_Country_Codes[,1]), 2]
#ISO Code for "Remittance-Sending Country"
data_long[,3] <- ISO_Country_Codes[match(data_long[,3], ISO_Country_Codes[,1]), 2]

final_df <- data_long[!grepl("NA", data_long[,4]),]

write.csv(final_df, "bilateral_remittances_2010-2017_long_format.csv", row.names = FALSE)