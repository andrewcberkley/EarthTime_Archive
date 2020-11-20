##################
## Data preparation code for
## Black Lives Matter: Evidence that Police-Caused Deaths Predict Protest Activity
## Vanessa Williamson, Kris-Stella Trump, Katherine Einstein
## February 2018 
## Corresponding author vwilliamson@brookings.edu 
##################

## This code takes raw data files (see readme for full list), including an original dataset of BLM protests, and outputs a data frame ready for analysis (The analysis can be found in the file "2. BLM Data analysis code")

## Code tested in R version 3.4.1

## Don't forget to set your working directory

#Create log file
sink(file="Data_preparation_log.txt")

###############
## LOAD DATA ##
###############

#Load packages
library(foreign)
library(MASS)

#####Load:
#####Deaths by police, 1/1/2013-8/9/2014. 
deaths <- read.csv("policedeaths_2013.01.01-2014.08.09.csv")
dim(deaths) #1730 deaths
#This dataset does not include 45 deaths that could not be matched to a Census location.
dim(deaths[deaths$Cause.of.death!="Vehicle",]) #1637 deaths when exclude vehicle deaths

#Aggregate deaths by location (Census FIPS code)
n_deaths <- data.frame(table(deaths$Id2))
colnames(n_deaths) <- c("FIPS", "deaths")
head(n_deaths) 
#show number of locations
dim(n_deaths) 

#Aggregate unarmed deaths by location (Census FIPS code)
deaths.u <- deaths[deaths$unarmed=="Unarmed" & deaths$Cause.of.death!="Vehicle",] 
dim(deaths.u)
n_deaths_unarmed <- data.frame(table(deaths.u$Id2))
colnames(n_deaths_unarmed) <- c("FIPS", "deaths_unarmed")
dim(n_deaths_unarmed) 
sum(n_deaths_unarmed$deaths_unarmed) #235 unarmed deaths

# Aggregate unarmed deaths by location, black
table(deaths$vrace)
deaths.bu <- deaths[deaths$unarmed=="Unarmed" & deaths$Cause.of.death!="Vehicle" & deaths$vrace=="Black",]
dim(deaths.bu) 
n_deaths_unarmed_black <- data.frame(table(deaths.bu$Id2))
colnames(n_deaths_unarmed_black) <- c("FIPS", "deaths_unarmed_black")
dim(n_deaths_unarmed_black) 
sum(n_deaths_unarmed_black$deaths_unarmed_black) #80 unarmed black deaths

# Aggregate all deaths by location, black
deaths.b <- deaths[deaths$vrace=="Black" & deaths$Cause.of.death!="Vehicle",]
dim(deaths.b) # 439 deaths
n_deaths_black <- data.frame(table(deaths.b$Id2))
colnames(n_deaths_black) <- c("FIPS", "deaths_black")
dim(n_deaths_black) 
sum(n_deaths_black$deaths_black) #439 black deaths

# Aggregate not unarmed deaths by location, black
deaths.ab <- deaths[deaths$vrace=="Black" & deaths$Cause.of.death!="Vehicle" & deaths$unarmed!="Unarmed",]
dim(deaths.ab) # 359 deaths
n_deaths_armed_black <- data.frame(table(deaths.ab$Id2))
colnames(n_deaths_armed_black) <- c("FIPS", "deaths_armed_black")
dim(n_deaths_armed_black) 
sum(n_deaths_armed_black$deaths_armed_black)

#####Load:
#####A list of deaths that occurred during the year of protest observation
deathsd <- read.csv("policedeaths_during.csv")
deaths.u <- deathsd[deathsd$unarmed=="Unarmed" & deathsd$Cause.of.death!="Vehicle",] 
n_protestyear_unarmed <- data.frame(table(deaths.u$Id2))
colnames(n_protestyear_unarmed) <- c("FIPS", "deaths_protestyear_unarmed")
dim(n_protestyear_unarmed) # 169 cities had an unarmed police-caused death during period of protest observation
sum(n_protestyear_unarmed$deaths_protestyear_unarmed) # 197 unarmed deaths in this period
n_protestyear <- data.frame(table(deathsd$Id2))
colnames(n_protestyear) <- c("FIPS", "deaths_protestyear")
dim(n_protestyear) # 727 cities had any police-caused deaths during period of protest observation
sum(n_protestyear$deaths_protestyear) # 1097 police-caused deaths in this period

#####Load:
#####Protest dataset
protests <- read.csv("BLM_protests_2014.08.09-2015.08.09.csv")
dim(protests)
colnames(protests)

#Convert date to proper format
protests$date2 <- as.character(protests$date)
protests$date <- as.Date(protests$date2, "%m/%d/%y")
protests$date2 <- NULL

###Pause from data wrangling to create:
###Figure 1: protests over time

#overtime plot
#prep data so that the zero protest days are also in there
protest_dates <- as.data.frame(table(protests$date))
colnames(protest_dates) <- c("date", "n_protests")
protest_dates$date <- as.Date(as.character(protest_dates$date))
head(protest_dates)

timeframe <- as.data.frame(seq(as.Date("2014-08-08"), as.Date("2015-08-10"), by="days"))
colnames(timeframe) <- c("date")
timeframe$date <- as.Date(as.character(timeframe$date))
head(timeframe)

overtime_protests <- merge(protest_dates, timeframe, by="date", all.y=T)
overtime_protests[is.na(overtime_protests$n_protests),"n_protests"] <- 0
summary(overtime_protests$n_protests, na.rm=T)

overtime_protests$foo <- seq(1,368)
#matching mp values to date values by using foo.
#10th of every month for a label -> day numbers 3,95,187,276,368.
mp <- barplot(overtime_protests$n_protests, ylim=c(0,100), ylab="Number of BLM protests per day")
pdf("Overtime_Protests.pdf")
barplot(overtime_protests$n_protests, ylim=c(0,100), las=1, ylab="Number of BLM protests per day")
axis(1, at=mp[c(3,95,187,276,368)], labels=c("Aug '14","Nov '14","Feb '15","May '15", "Aug '15"))
dev.off()

###Continue data preparation

#Create number protest attendees by FIPS (state + place)
attendance_data <- as.data.frame(cbind(sort(unique(protests$FIPS)), rowsum(protests$popnum, group=protests$FIPS, na.rm=T)), na.rm=T)
colnames(attendance_data) <- c("FIPS", "tot.attend")
head(attendance_data)

#Create number protests by FIPS
n_protests <- data.frame(table(protests$FIPS))
colnames(n_protests) <- c("FIPS", "tot.protests")
head(n_protests)
dim(n_protests)

#####Load:
#####NAACP chapters by year, between 1912-1964
naacp <- read.csv("NAACP Chapters By Year.csv")
colnames(naacp)  <- c("X", "FIPS", "NAACPyears")

#####Load:
#####Mayoral Partisanship and race
temp <- read.csv("Mayoral Partisanship.csv")
mayors <- temp[, colnames(temp) %in% c("FIPS", "MayorPartisanship", "Black")]

#####Load:
#####City level partisanship 
citypart <- read.csv("City_Votes.csv")
head(citypart) # variable of interest is "dem_share"
# connecting state and place FIPS (adding 0s)
citypart$FIPS_PLACE2 <- paste(citypart$FIPS_ST, citypart$FIPS_PLACE, sep="")
temp <- citypart$FIPS_PLACE
dig3 <- which(citypart$FIPS_PLACE < 1000)
temp2 <- paste("00", citypart$FIPS_PLACE[dig3], sep="")
temp3 <- paste(citypart$FIPS_ST[dig3], temp2, sep="")
dig4 <- which(citypart$FIPS_PLACE < 10000 & citypart$FIPS_PLACE>=1000)
temp4 <- paste("0", citypart$FIPS_PLACE[dig4], sep="")
temp5 <- paste(citypart$FIPS_ST[dig4], temp4, sep="")
citypart$FIPS_PLACE2[dig3] <- temp3
citypart$FIPS_PLACE2[dig4] <- temp5
colnames(citypart)[colnames(citypart)=="FIPS_PLACE2"] <- "FIPS"

# Note that there are four repeated FIPS codes in the dataset, with same FIPS codes but different dem_shares.
reps <- citypart$FIPS[which(duplicated(citypart$FIPS))]
citypart[citypart$FIPS %in% reps,]
#Looking into it, these are likely four locales in Florida. They all have populations below 30k, so we choose to drop them, as doing so will not affect analyses. 
citypart <- citypart[duplicated(citypart$FIPS)==FALSE,]
dim(citypart)

#####Load:
#####College enrollment data
coll <- read.csv("College Summary Data by FIPS.csv")
colnames(coll)[colnames(coll) %in% "fips"] <- "FIPS"

#####Load:
#####ACS data on cities w population over 30k
citydata <- read.csv("2014ACSData.csv")
names(citydata)
summary(citydata$TotalPop)
sum(citydata$TotalPop>30000, na.rm=T)
#1358 cities larger than 30000. Keep all cities in the data for now for some descriptive statistics below. 

#####Load:
#####Proxy for crime levels: 100 U.S. cities (population over 25,000) with highest per capita violent crime rates. Note we further restricted this to cities with population over 30,000 (to match our main analysis) which is why there are only 91 most dangerous cities listed here.
crimedata <- read.csv("crime.csv")
crimedata <- crimedata[,c("FIPS", "ranked100")]




################
## MERGE DATA ##
################

#Merge protest activity with ACS data
head(citydata)
head(n_protests)
BLM <- merge(citydata, n_protests, by="FIPS", all=T)
#Specify that places without BLM protest data had zero protests (in our protest dataset)
BLM$tot.protests[is.na(BLM$tot.protests)] <- 0

#Check the data
dim(BLM)-dim(citydata) #This gives 1 additional observation, i.e. non-matching FIPS.
sum(is.na(citydata$Geography.x))
sum(is.na(BLM$Geography.x)) 
missingFIPS <- BLM[is.na(BLM$Geography.x),"FIPS"]
missingFIPS <- protests[protests$FIPS %in% missingFIPS,c("city", "ST", "FIPS")]
missingFIPS # Wyckoff NJ 3483050 - this location's FIPS code does not appear in the ACS dataset. We exclude the location from analysis, but since it is smaller than 30,000, this will not affect our main analysis.

#Add attendance 
BLM <- merge(BLM, attendance_data, by="FIPS", all.x=T)
BLM$tot.attend[is.na(BLM$tot.attend)==1] <- 0

#Add in number of police deaths by city in year prior to death of Michael Brown 
BLM <- merge(BLM, n_deaths, by="FIPS", all.x=T)
table(BLM$deaths, useNA="always")
BLM$deaths[is.na(BLM$deaths)==1] <- 0

# Adding in count of unarmed deaths prior to protest year
BLM <- merge(BLM, n_deaths_unarmed, by="FIPS", all.x=T)
table(BLM$deaths_unarmed, useNA="always")
BLM$deaths_unarmed[is.na(BLM$deaths_unarmed)==1] <- 0

# Adding in count of unarmed black deaths prior to protest year
BLM <- merge(BLM, n_deaths_unarmed_black, by="FIPS", all.x=T)
table(BLM$deaths_unarmed_black, useNA="always")
BLM$deaths_unarmed_black[is.na(BLM$deaths_unarmed_black)==1] <- 0

# Adding in count of armed black deaths prior to protest year
BLM <- merge(BLM, n_deaths_armed_black, by="FIPS", all.x=T)
table(BLM$deaths_armed_black, useNA="always")
BLM$deaths_armed_black[is.na(BLM$deaths_armed_black)==1] <- 0

# Adding in count of black deaths prior to protest year
BLM <- merge(BLM, n_deaths_black, by="FIPS", all.x=T)
table(BLM$deaths_black, useNA="always")
BLM$deaths_black[is.na(BLM$deaths_black)==1] <- 0

# Adding in count of unarmed deaths during protest year
BLM <- merge(BLM, n_protestyear, by="FIPS", all.x=T)
table(BLM$deaths_protestyear, useNA="always")
BLM$deaths_protestyear[is.na(BLM$deaths_protestyear)] <- 0

# Adding in count of total deaths during protest year
BLM <- merge(BLM, n_protestyear_unarmed, by="FIPS", all.x=T)
table(BLM$deaths_protestyear_unarmed, useNA="always")
BLM$deaths_protestyear_unarmed[is.na(BLM$deaths_protestyear_unarmed)] <- 0

#Checks
dim(BLM)
sum(BLM$deaths)
sum(BLM$deaths_unarmed)
sum(BLM$deaths_unarmed_black)
sum(BLM$deaths_armed_black)
sum(BLM$deaths_black)
sum(BLM$deaths_protestyear)
sum(BLM$deaths_protestyear_unarmed)

# Adding in NAACP chapters
BLM <- merge(BLM, naacp, by="FIPS", all.x=T)
BLM$NAACPyears[is.na(BLM$NAACPyears)] <- 0
sum(BLM$NAACPyears)

# Adding in mayoral Partisanship and Race
BLM <- merge(BLM, mayors, by="FIPS", all.x=T)
colnames(BLM)[colnames(BLM)=="Black"] <- "blackmayor"
colnames(BLM)

# Adding in city partisanship
BLM <- merge(BLM, citypart, by="FIPS", all.x=T)

# Adding in college enrollment 
BLM <- merge(BLM, coll, by="FIPS", all.x=T)
BLM$pop[is.na(BLM$pop)] <- 0
BLM$hbcu[is.na(BLM$hbcu)] <- 0
BLM$hbcu2[is.na(BLM$hbcu2)] <- 0

# Adding in crime proxy
#First, a data issue fix
#some non-matching FIPS appear in the crime data
check <- crimedata[!(crimedata$FIPS %in% BLM$FIPS),]
#FIPS 1349000 and 1356000
#These should be Macon City, and North Atlanta
check2 <- BLM[grep("Macon",BLM$Geography.x),]
#The ACS dataset has the recently consolidated Macon-Bibb county (1349008) instead, which includes the city of Macon, Georgia
#North Atlanta was disincorporated and is now part of Brookhaven
check3 <- BLM[grep("Brookhaven",BLM$Geography.x),]
#Brookhaven is in the ACS dataset under FIPS 1310944
#These discrepancies are most likely due to data lags in the crime data, resulting in now-unincorporated census designations appearing in it.
#We choose to drop the two outdated FIPS locales in the crime data. Neither place was designated as "most dangerous", so we do not lose information by doing this. 
crimedata <- crimedata[(crimedata$FIPS %in% BLM$FIPS),]
colnames(crimedata) <- c("FIPS", "crime")
#merge
BLM <- merge(BLM, crimedata, by="FIPS", all.x=T)
BLM$crime[is.na(BLM$crime)] <- 0

#Check 
dim(BLM)


#########################
## VARIABLE ADJUSTMENT ##
#########################


#Create a dummy variable for at least one unarmed death during year of protest observation
BLM$deathduring <- 0
BLM$deathduring[BLM$deaths_protestyear_unarmed>0] <- 1

summary(BLM$per_ba)
#Education measure
BLM$per_ba <- as.numeric(as.character(BLM$PercentBachelor.s))
#Poverty
BLM$BlackPovertyRate <- as.numeric(as.character(BLM$BlackPovertyRate))
BLM$PovertyRate <- as.numeric(as.character(BLM$PovertyRate))
#Black percentage of population
BLM$Per_Black <- (BLM$BlackPop/BLM$TotalPop)*100
#Population density
BLM$pop.density <- BLM$TotalPop/BLM$SqMiles

# College population percent of population
BLM$collegeenrollpc <- (BLM$pop/BLM$TotalPop)*100

summary(citydata$TotalPop)
# Mayoral Partisanship
BLM$mayorrep <- 0
BLM$mayorrep[BLM$MayorPartisanship=="R"] <- 1

# Deaths by police per capita
BLM$unarmed_deaths_pc <- (BLM$deaths_unarmed*10000)/BLM$TotalPop 
BLM$unarmed_deaths_pc[which(is.na((BLM$deaths_unarmed*10000)/BLM$TotalPop))] <- 0

BLM$deaths_pc <- (BLM$deaths*10000)/BLM$TotalPop 
BLM$deaths_pc[which(is.na((BLM$deaths*10000)/BLM$TotalPop))] <- 0

BLM$unarmed_deaths_black_pc <- (BLM$deaths_unarmed_black*10000)/BLM$TotalPop
BLM$unarmed_deaths_black_pc[which(is.na((BLM$deaths_unarmed_black*10000)/BLM$TotalPop))] <- 0

BLM$deaths_black_pc <- (BLM$deaths_black*10000)/BLM$TotalPop
BLM$deaths_black_pc[which(is.na((BLM$deaths_black*10000)/BLM$TotalPop))] <- 0
summary(BLM$deaths_black_pc)

# Create a dummy variable for any protests 
BLM$anyprotests <- 0
BLM$anyprotests[BLM$tot.protests!=0] <- 1

############################
## POPULATION RESTRICTION ##
############################

summary(BLM$TotalPop)
summary(BLM[BLM$tot.protests>0,"TotalPop"])
dim(BLM[BLM$tot.protests>0,])
#There are protests in small places also, but lower rate than in large
#Smallest location with protest has pop 1071
BLM[BLM$Total==1071& is.na(BLM$Total)==F,]
#That's Buchanan Dam TX

#Restricting to cities above 30000 in population
BLM30k <- BLM[BLM$Total>=30000 & is.na(BLM$Total)==F,]
dim(BLM30k)
#Cuts sample from 29297 to 1358
sum(BLM30k$tot.protests>0, na.rm=T)
#Also cuts number of places with protests from 233 to 186. 
#80% of places that experience protests are in the 5% of US places that have >30k population

colnames(BLM30k)
BLM30k[1,]
#################
## EXPORT FILE ##
#################

write.csv(BLM30k, file="BLM_cities.csv")

