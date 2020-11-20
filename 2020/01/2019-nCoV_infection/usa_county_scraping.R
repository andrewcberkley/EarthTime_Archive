###Inspired By: https://github.com/tidyverse/rvest/issues/12

library(rvest)
library(tidyverse)
library(data.table)

nodes <- "C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/2019-nCoV_infection/coronavirus_1point3acres_26-03-2020.html" %>% #March 26
	read_html %>%
	#html_nodes("div.jsx-522312921.state-table") #March 14
	#html_nodes("div.jsx-1168542486.state-table") #March 15, 16, 17, 18, 19, 20, 21
	#html_nodes("div.jsx-314244412.state-table") #March 22, 23
	html_nodes("div.jsx-564222390.state-table") #March 24, 25, 26


column <- function(x) nodes %>% 
	html_node(xpath = x) %>% 
	html_text()

mytable <- list()
mytable$location <- rep(c(1:55), each = 100) 
mytable$county <- rep(c(1:100), times = 55) 
comboTable <- data.table( location = mytable$location, county = mytable$county)

pb <- progress_estimated(nrow(comboTable))

pull_covid_19_cases <- function(location, county){
	pb$tick()$print()
	data.frame(
		#state = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[3]/div[",location,"]/div[1]/span[1]")), #March 14
		#state = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[4]/div[",location,"]/div[1]/span[1]")), #March 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
		state = column(paste0("/html/body/div[1]/div/div[6]/div[2]/div[1]/div[5]/div[",location,"]/div[1]/span[1]")), #March 26

		#county = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[3]/div[",location,"]/div[2]/div[",county,"]/span[1]")), #March 14
		#county = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[4]/div[",location,"]/div[2]/div[",county,"]/span[1]")), #March 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
		county = column(paste0("/html/body/div[1]/div/div[6]/div[2]/div[1]/div[5]/div[",location,"]/div[2]/div[",county,"]/span[1]")), #March 26

		#confirmed = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[3]/div[",location,"]/div[2]/div[",county,"]/span[2]")), #March 14
		#confirmed = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[4]/div[",location,"]/div[2]/div[",county,"]/span[2]")), #March 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
		confirmed = column(paste0("/html/body/div[1]/div/div[6]/div[2]/div[1]/div[5]/div[",location,"]/div[2]/div[",county,"]/span[2]")), #March 26
								   /html/body/div[1]/div/div[6]/div[2]/div[1]/div[5]/div[2           ]/div[2]/div[1]/span[2]
								   
		#deaths = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[3]/div[",location,"]/div[2]/div[",county,"]/span[3]")), #March 14
		#deaths = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[4]/div[",location,"]/div[2]/div[",county,"]/span[3]")), #March 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
		deaths = column(paste0("/html/body/div[1]/div/div[6]/div[2]/div[1]/div[5]/div[",location,"]/div[2]/div[",county,"]/span[3]")), #March 26
								
		#case_fatality_rate = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[3]/div[",location,"]/div[2]/div[",county,"]/span[4]")), #March 14
		#case_fatality_rate = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[4]/div[",location,"]/div[2]/div[",county,"]/span[4]")), #March 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
		case_fatality_rate = column(paste0("/html/body/div[1]/div/div[6]/div[2]/div[1]/div[5]/div[",location,"]/div[2]/div[",county,"]/span[4]")), #March 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25

		#soure = column(paste0("/html/body/div[1]/div/div[5]/div[2]/div[1]/div[4]/div[",location,"]/div[2]/div[",county,"]/span[5]")),
		stringsAsFactors = FALSE
		)
}

data <- Map(pull_covid_19_cases, comboTable$location, comboTable$county) 

data1 <- rbindlist(data, fill = TRUE)

processed_cases <- data1[complete.cases(data1), ]

processed_cases$state <- as.character(processed_cases$state)
processed_cases$county <- as.character(processed_cases$county)
processed_cases$confirmed <- gsub(",", "", processed_cases$confirmed) #Remove commas for thousands place
#processed_cases$confirmed <- as.numeric(gsub("\\+.*","",processed_cases$confirmed)) #March 14, 17
processed_cases$confirmed <- as.numeric(processed_cases$confirmed) #March 15, 16, 18, 19, 20, 21, 22, 23, 24, 25
processed_cases$deaths <- as.numeric(processed_cases$deaths)
processed_cases$case_fatality_rate <- as.numeric(sub("%","",processed_cases$case_fatality_rate))/100

processed_cases$helper <- paste0(processed_cases$county, "|", processed_cases$state)
processed_cases <- processed_cases[, c(6,2,1,3,4,5)]
processed_cases$helper <- trimws(processed_cases$helper, which = "right")