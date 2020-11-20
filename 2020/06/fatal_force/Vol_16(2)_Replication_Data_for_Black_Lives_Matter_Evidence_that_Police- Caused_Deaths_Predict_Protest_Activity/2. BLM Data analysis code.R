##################
## Data analysis code for
## Black Lives Matter: Evidence that Police-Caused Deaths Predict Protest Activity
## Vanessa Williamson, Kris-Stella Trump, Katherine Einstein
## February 2018
## Corresponding author vwilliamson@brookings.edu 
##################

## This code uses a 'master' file that lists US cities with population over 30k, their political and demographic characteristics, and the frequency of BLM protests and deaths caused by police. 

## Code tested in R version 3.4.1

## Don't forget to set your working directory

#Create log file
sink(file="Data_analysis_log.txt")

## Packages
library(MASS)
library(car)
library(vcd)
library(pscl)
library(stargazer)
library(AER)
library(DHARMa)

## Import data: protest activity in cities with >30k population
BLM30k <- read.csv("BLM_cities.csv")

##################
## Look at the raw data 
##################
head(BLM30k)

#Plot key data (number of protests)
plot(BLM30k$tot.protests)
table(BLM30k$tot.protests)
hist(BLM30k[BLM30k$tot.protests>0,"tot.protests"])
plot(log(BLM30k$tot.protests+1))
summary(BLM30k$tot.protests)
var(BLM30k$tot.protests)
#Long tail with a lot of zeroes. But distribution looks like an event count, and does not have indisputable outliers. Mean and variance are clearly not the same, which indicates that the 'raw' distribution may be negative binomial rather than Poisson. 

#Check the raw distribution 
distplot(BLM30k$tot.protests, type=c("poisson"))
distplot(BLM30k$tot.protests, type=c("nbinom"))
#Unlike above, this visualization implies that the data may be a slightly better fit for Poisson. But this is still a first cut with no controls. Below, we will add controls and compare the conditional fit for Poisson, negative binomial, and zero-inflated negative binomial specifications.

#Look at number of attendees (for descriptive purposes - this is not used for analysis)
plot(BLM30k$tot.attend)
plot(BLM30k[BLM30k$tot.attend>0,"tot.attend"])
plot(log(BLM30k$tot.attend+1))
#in addition to a lot of zeros, this one looks more log-normal
BLM30k$name[BLM30k$tot.attend>10000]
#Big cities have the most attendees

#Pairwise relationship: poverty and protest activity
plot(BLM30k$PovertyRate, BLM30k$tot.protests)
plot(BLM30k[BLM30k$tot.protests>0,"PovertyRate"], BLM30k[BLM30k$tot.protests>0,"tot.protests"])
plot(BLM30k$BlackPovertyRate, BLM30k$tot.protests)
plot(BLM30k[BLM30k$tot.protests>0,"BlackPovertyRate"], BLM30k[BLM30k$tot.protests>0,"tot.protests"])
#this all looks very quadratic, as resource theory would have it.

#Pairwise relationship: percent Black and protest activity
plot(BLM30k$Per_Black, BLM30k$tot.protests)
plot(BLM30k[BLM30k$tot.protests>0,"Per_Black"], BLM30k[BLM30k$tot.protests>0,"tot.protests"])
#this also looks quadratic - but resource constraint in majority Black areas is an obvious unaccounted for confound here:
cor(BLM30k$Per_Black, BLM30k$PovertyRate)

#Pairwise relationship: Black per capita deaths and protest activity
plot(BLM30k$deaths_black_pc, BLM30k$tot.protests)
#Visual relationship ambiguous, with one point in the middle of the distribution that is rather far from the others and may be an outlier. Below we will directly address the issue of outliers in the context of model fit.

#Correlation table for key variables 
key_vars <- as.data.frame(BLM30k[,c("tot.protests","TotalPop", "pop.density", "Per_Black", "BlackPovertyRate","per_ba","collegeenrollpc", "dem_share","mayorrep","NAACPyears","blackmayor", "deaths_black_pc", "deaths_pc")])
colnames(key_vars) <- c("Number of protests", "Population", "Population Density", "Percent Black", "Black Poverty Rate", "Percent college-educated", "College students (% of population)","Democratic vote share", "Republican Mayor","Years of NAACP activity", "Black mayor","Black police-caused deaths",  "Police-caused deaths")
cors <- cor(key_vars, use="complete.obs")
write.csv(cors, file="correlationmatrixBLM.csv")

##################
## Descriptive statistics
##################


####Note: Figure 1 - Over-time frequency of Black Lives Matter Protests - is produced in the code "BLM data preparation code" (because the plot visualizes protest data prior to geographic aggregation).


##### Table 1: Summary Statistics of Key Variables, Localities with Populations over 30,000
summary(BLM30k$Per_Black)
summary(BLM30k$BlackPovertyRate)
summary(BLM30k$per_ba)
summary(BLM30k$collegeenrollpc)
summary(BLM30k$dem_share)
summary(BLM30k$deaths)
summary(BLM30k$deaths_pc)
summary(BLM30k$deaths_black)
summary(BLM30k$deaths_black_pc)
summary(BLM30k$tot.protests)

#### Table 2 - Cities by police-caused deaths and protests, all cities with population >30k

##How many cities with/without protests
table(BLM30k$anyprotests) #1358 cities with population over 30k, 1172 without protests, 186 with protests
sum(BLM30k$tot.protests) #674 protests in these cities 
BLM30k[BLM30k$tot.protests>47,] #Max protests: 50 in NYC
dim(BLM30k) #1358 cities
#any deaths
sum(BLM30k$deaths==0) #909 cities without any deaths recorded
sum(BLM30k$deaths>0) #448 cities with at least one death recorded
#any deaths and protests
sum(BLM30k$anyprotests==0 & BLM30k$deaths==0) #830 with neither deaths nor protests
sum(BLM30k$anyprotests==1 & BLM30k$deaths==0) #79 with no deaths but at least one protest
sum(BLM30k$anyprotests==0 & BLM30k$deaths>0) #342 cities with deaths but no protests
sum(BLM30k$anyprotests==1 & BLM30k$deaths>0) #107 cities with deaths and protests
#black deaths
sum(BLM30k$deaths_black==0) #1200 cities without any Black deaths recorded
sum(BLM30k$deaths_black>0) #158 cities with at least one Black death recorded
#black deaths and protests
sum(BLM30k$anyprotests==0 & BLM30k$deaths_black==0) #1084 with neither Black deaths nor protests
sum(BLM30k$anyprotests==1 & BLM30k$deaths_black==0) #116 with no Black deaths but at least one protest
sum(BLM30k$anyprotests==0 & BLM30k$deaths_black>0) #88 cities with Black deaths but no protests
sum(BLM30k$anyprotests==1 & BLM30k$deaths_black>0) #70 cities with deaths and protests
#unarmed deaths during observation year
sum(BLM30k$deathduring==1) #101 
sum(BLM30k$deathduring==1 & BLM30k$anyprotest==1) #41
sum(BLM30k$deathduring==1 & BLM30k$anyprotest==0) #60
sum(BLM30k$deathduring==0 & BLM30k$anyprotest==1) #145
sum(BLM30k$deathduring==0 & BLM30k$anyprotest==0) #1112



#### Table SI1 (Supplemental Information) - Cities by police-caused deaths and protests, excluding cities that experienced at least one police-caused death of an unarmed person during the protest observation period. 

#pull out subset of cities with no deaths during observation year
BLM30k.nd <- BLM30k[BLM30k$deathduring==0,]

#any deaths and protests
sum(BLM30k.nd$deaths==0, na.rm=T) #872
sum(BLM30k.nd$deaths>0, na.rm=T) #385
sum(BLM30k.nd$anyprotests==0 & BLM30k.nd$deaths==0, na.rm=T) #799 with neither deaths nor protests
sum(BLM30k.nd$anyprotests==1 & BLM30k.nd$deaths==0, na.rm=T) #73 with no deaths but at least one protest
sum(BLM30k.nd$anyprotests==0 & BLM30k.nd$deaths>0, na.rm=T) #313 cities with deaths but no protests
sum(BLM30k.nd$anyprotests==1 & BLM30k.nd$deaths>0, na.rm=T) #72 cities with deaths and protests

#black deaths and protests
sum(BLM30k.nd$deaths_black==0, na.rm=T) #1135 cities without any Black deaths recorded
sum(BLM30k.nd$deaths_black>0, na.rm=T) #122 cities with at least one Black death recorded
#black deaths and protests
sum(BLM30k.nd$anyprotests==0 & BLM30k.nd$deaths_black==0, na.rm=T) #1038 with neither Black deaths nor protests
sum(BLM30k.nd$anyprotests==1 & BLM30k.nd$deaths_black==0, na.rm=T) #97 with no Black deaths but at least one protest
sum(BLM30k.nd$anyprotests==0 & BLM30k.nd$deaths_black>0, na.rm=T) #74 cities with Black deaths but no protests
sum(BLM30k.nd$anyprotests==1 & BLM30k.nd$deaths_black>0, na.rm=T) #48 cities with deaths and protests



#################
## MODEL DIAGNOSTICS  
#################

#The model that presents our main results predicts the number of protests in a city as a function of Black per capita deaths at the hands of police, and includes relevant control variables. We use this main model to assess whether a Poisson, negative binomial, or zero-inflated negative binomial specification fits the data best.

#Poisson
main.poisson <- glm(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k, family=poisson(link="log"))
summary(main.poisson)
dispersiontest(main.poisson)
#The dispersion tests suggests that true dispersion is greater than one, violating a poisson assumption. 

#Fit negative binomial next.
#Negative binomial
main.nb <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k, link=log)
summary(main.nb) 

#Directly compare the poisson and negative binomial models
pchisq(2 * (logLik(main.nb) - logLik(main.poisson)), df = 1, lower.tail = FALSE)
#The chi-sq probability approaches zero. This suggests that the negative binomial model is a significantly better fit than the poisson model.

##Zero-Inflation Check
main.zero <- zeroinfl(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k)
summary(main.zero)
#This gives a warning and does not produce standard errors for the black poverty rate variables. This may be due to a lack of sufficient variation across poverty/protest variables to separate out "true" and "false" zeros. This speaks against using this model, but we will run a diagnostic to confirm. 

#Compare zero-inflated model to negative binomial
vuong(main.nb, main.zero)
#AIC finds no significant difference, BIC indicates that the non-inflated model is a better fit. 

#Use DHARMa package for an alternative test of zero inflation (using simulations from the original nb model, therefore not relying on the above-estimated zero-inflation model that didn't produce all standard errors)
simulationOutput <- simulateResiduals(fittedModel = main.nb, n = 250)
testZeroInflation(simulationOutput)
#Does not find significantly more zeroes than expected

#In conclusion: decide to go with the negative binomial as best fit for our data.

######
## Outliers
#####

# Removing outliers (based on the main model as specified above)

#Pull out cook's distances
cooksd <- cooks.distance(main.nb, drop=F)

#Plot
plot(cooksd, pch="*", cex=2, main="Influential Obs by Cooks distance")  # plot cook's distance
#None of the cook's distances are >1. Below are two more rules of thumb plotted: 4*mean, and 4/n
abline(h = 4*mean(cooksd, na.rm=T), col="red")  # add cutoff line
abline(h = 4/(1358-133), col="blue")  # add 2nd cutoff line
#add labels
text(x=1:length(cooksd)+1, y=cooksd, labels=ifelse(cooksd>4*mean(cooksd, na.rm=T),names(cooksd),""), col="red")  

#What is that one most influential observation?
BLM30k[646,] #Beavercreek City, OH

#Visualization shows many influential observations. How many?

sum(cooksd>(4*mean(cooksd, na.rm=T))) #55
sum(cooksd>4/(1358-133)) #69
#There are many influential observations; suspect that these will be disproportionately cities with protests, which we know drive the results given that there are relatively few of them. Explore this next.

#Create an indicator for high influence observations using the more conservative estimate
largecook <- as.data.frame(cooksd[cooksd>4/(1358-133)])
largecooknames <- as.numeric(rownames(largecook))
BLM30k[largecooknames,"influential"] <- 1
BLM30k$influential[is.na(BLM30k$influential)] <- 0
sum(BLM30k$influential)

#How many of the influential observations have protests?
table(BLM30k$tot.protests>1, BLM30k$influential)
#Excluding influential data points by this measure would drop 41 of total 92 instances where protests occurred. Conversely, it would drop 28 of 1266 observations where protests did not occur. Given that the event of interest is scarce, it seems unsurprising that places where protests did occur are disproportionately influential for the regression results. We make the judgment call that these seem like "fair" influences on the outcome rather than unreasonable outliers, and only remove the one very clear outlier (Observation 646, Beavercreek City OH). 

BLM30k <- BLM30k[-646,]

#Refit model
main.nb <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k, link=log)
summary(main.nb) 

######
## Plotting fitted values and residuals
#####

#Plot outcome against fitted values
plot(main.nb$y, main.nb$fitted.values)
#not bad

#Plot residuals against fitted values
#Use the DHARMa package for adjusted qq plots
set.seed(5972057) #for exact reproducibility of the simulation
simulationOutput <- simulateResiduals(fittedModel = main.nb, n = 250)
plotSimulatedResiduals(simulationOutput = simulationOutput)
#The QQ plot looks good. Quantile lines start appropriately but top ones converge a bit to the bottom one where there are fewer observations. According to DHARMa, some variation here is tolerable and may arise by chance. 

#A more formal test of heteroskedasticity:
testUniformity(simulationOutput)
#Also looks good.


#################
## REGRESSIONS  ##
#################


#####
## Table 3
#####

#Main model (as specified and tested above) is presented as model 2 in table 3. 
#Below, the model specifications are numbered (3_1, 3_2, etc) to match Table 3 in the manuscript.

# MODEL 1: Basic model of resource mobilization and opportunity structure
nb.3_1 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share , data=BLM30k, link=log)
summary(nb.3_1) 

# MODEL 2: Adding black deaths
nb.3_2 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k, link=log)
summary(nb.3_2) 

# MODEL 3: Using all police-caused deaths instead (victims of any race)
nb.3_3 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_pc, data=BLM30k, link=log)
summary(nb.3_3) 

#####
### Exploring additional opportunity structure variables
#####

#We hypothesized that additional variables to capture opportunity structure would be relevant, but on analysis discovered that these variables do not significantly improve our models. The analyses that led us to this conclusion are below and reported in Table 3, models 4-6.

# MODEL 4: Adding additional opportunity structure variables to Model 1.
nb.3_4 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + NAACPyears + blackmayor, data=BLM30k, link=log)
summary(nb.3_4) 

#Look at improved fit as result of these additional variables 
#Start by fitting models that build the opportunity structure variables in one by one
nb.3_4a <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep, data=BLM30k, link=log)
nb.3_4b <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + NAACPyears, data=BLM30k, link=log)

anova(nb.3_1, nb.3_4a,nb.3_4b,nb.3_4, test="Chisq")
#The variables for mayor partisanship, NAACP, and mayor race do not significantly improve model fit. Below, we repeat this test with additional rigor: with our main grievance variable also in the model, and when restricting analysis to observations that can be included in all models, in order to make models strictly comparable.


#First we add grievance measure to the models with multiple opportunity variables, expanding Model 2
nb.3_5a <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + deaths_black_pc , data=BLM30k, link=log)
nb.3_5b <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + NAACPyears + deaths_black_pc, data=BLM30k, link=log)
#MODEL 5: grievance entered with all opportunity variables
nb.3_5 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + NAACPyears + blackmayor + deaths_black_pc, data=BLM30k, link=log)

anova(nb.3_2, nb.3_5a,nb.3_5b,nb.3_5, test="Chisq")
#As above, these additional variables do not improve model fit. 

#For completeness, also report this regression with all deaths.
# MODEL 6: Using all police-caused deaths instead (victims of any race)
nb.3_6 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + NAACPyears + blackmayor + deaths_pc, data=BLM30k, link=log)
summary(nb.3_6) 

#### One last test before printing results. The chi-sq comparison of model fit may give inaccurate results because between model iterations (in particular, when adding mayoral race data), some observations are dropped due to missingness. Below, we fit the reduced and full opportunity structure models onto a reduced dataset, eliminating this problem. 

#Remove observations where some data is missing, to evaluate equivalent models 
sum(is.na(BLM30k$blackmayor))
sum(is.na(BLM30k$NAACPyears))
sum(is.na(BLM30k$mayorrep))
sum(is.na(BLM30k$deaths_black_pc))
sum(is.na(BLM30k$dem_share))
sum(is.na(BLM30k$collegeenrollpc))
sum(is.na(BLM30k$per_ba))
sum(is.na(BLM30k$BlackPovertyRate))
sum(is.na(BLM30k$Per_Black))
sum(is.na(BLM30k$pop.density))
sum(is.na(BLM30k$TotalPop))
    
#Missingness comes from three variables.
BLM30k.reduced <- BLM30k[(is.na(BLM30k$blackmayor)==F & is.na(BLM30k$dem_share)==F & is.na(BLM30k$pop.density)==F),]

#Repeat analysis with this dataset
#model with grievance but not additional opp vars
nb.3_2.red <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k.reduced, link=log)

#Add opp vars one at a time
nb.3_5a.red <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share+ mayorrep + deaths_black_pc, data=BLM30k.reduced, link=log)
nb.3_5b.red <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + NAACPyears + deaths_black_pc, data=BLM30k.reduced, link=log)
nb.3_5.red <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep + NAACPyears + blackmayor + deaths_black_pc, data=BLM30k.reduced, link=log)

anova(nb.3_2.red, nb.3_5a.red,nb.3_5b.red,nb.3_5.red, test="Chisq")
#As above, these additional variables do not improve model fit. 

###Conclude that the three additional opportunity structure variables do not significantly improve model fit. 

########
####Print Table 3 output
######
stargazer(nb.3_1,nb.3_2,nb.3_3,nb.3_4,nb.3_5,nb.3_6, type="text", dep.var.labels="Number of protests", covariate.labels = c("Population (log)", "Population density (log)", "Percent Black", "Black Poverty Rate", "Black Poverty Rate (squared)", "Percent college-educated", "College students (% of population)", "Democratic vote share", "Black police-caused deaths (per 10,000)", "Police-caused deaths (per 10,000)", "Republican mayor", "Years of NAACP activity", "Black mayor", "Constant"), out="table3.htm")



#######################
## SOLIDARITY PROTESTS ##
#######################

#What happens if we look at cities that did not have an unarmed death during the protest year? These cities do not have a "catalyst"-like event during the year, so these towns can be thought of as holding "solidarity protests". 
#In the manuscript, these models are presented in Table SI2 (in Supplemental Information). We number them as "SI2_1" etc below.

nb.SI2_1 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share, data=BLM30k.nd, link=log)
summary(nb.SI2_1) 

nb.SI2_2 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k.nd, link=log)
summary(nb.SI2_2)

nb.SI2_3 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc +  dem_share + deaths_pc, data=BLM30k.nd, link=log)
summary(nb.SI2_3)


########
####Print Table SI2 output
######
stargazer(nb.SI2_1,nb.SI2_2,nb.SI2_3, type="text", dep.var.labels="Number of protests", covariate.labels = c("Population (log)", "Population density (log)", "Percent Black", "Black Poverty Rate", "Black Poverty Rate (squared)", "Percent college-educated", "College students (% of population)", "Democratic vote share", "Black police-caused deaths (per 10,000)", "Police-caused deaths (per 10,000)", "Constant"), out="tableSI2.htm")



#####################
## MODELS APPENDIX  ##
#####################

# Table SI3 - adding a dummy for cities with particularly high per capita rates of violent crime
nb.SI3 <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc + crime, data=BLM30k, link=log)
summary(nb.SI3) 
# Print Table SI3 output
stargazer(nb.SI3, type="text", dep.var.labels="Number of protests", covariate.labels = c("Population (log)", "Population density (log)", "Percent Black", "Black Poverty Rate", "Black Poverty Rate (squared)", "Percent college-educated", "College students (% of population)", "Democratic vote share", "Black police-caused deaths (per 10,000)", "High violent crime (dummy)", "Constant"), out="tableSI3.htm")



# Model 3_4 -  Opp structure variables tested when added individually
nb.3_4c <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + mayorrep, data=BLM30k, link=log)
summary(nb.3_4c) 

nb.3_4d <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + blackmayor, data=BLM30k, link=log)
summary(nb.3_4d) 

nb.3_4e <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + NAACPyears, data=BLM30k, link=log)
summary(nb.3_4e) 
  
# Robustness check: fit logit models predicting whether any protest activity occurred (0 = no protests, 1 = at least one protest)
#Full dataset
m3_2.logit <- glm(anyprotests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k, family=binomial(link="logit"))
summary(m3_2.logit)

m3_3.logit <- glm(anyprotests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_pc, data=BLM30k, family=binomial(link="logit"))
summary(m3_3.logit)

#"Solidarity protests" dataset
mSI2_2.logit <- glm(anyprotests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k.nd, family=binomial(link="logit"))
summary(mSI2_2.logit)

mSI2_3.logit <- glm(anyprotests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_pc, data=BLM30k.nd, family=binomial(link="logit"))
summary(mSI2_3.logit)


# Relationship between unarmed black deaths and protest activity is not significant, but data is sparse (45 cities with such a death). Interestingly, the insignificant point estimate is twice as high as for all black deaths.

dub.nb <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + unarmed_deaths_black_pc, data=BLM30k, link=log)
summary(dub.nb) 

#The coefficient on black deaths does not change much when unarmed deaths are also included
dub2.nb <- glm.nb(tot.protests ~ log(TotalPop) + log(pop.density) + Per_Black + BlackPovertyRate + I(BlackPovertyRate^2) + per_ba + collegeenrollpc + dem_share + deaths_black_pc + unarmed_deaths_black_pc, data=BLM30k, link=log)
summary(dub2.nb) 


###################
## INTERPRETATION  ##
###################

# Based on the main model (Model 2 in Table 3):
summary(nb.3_2) 

# Creating variables within dataframe (for predict function)
BLM30k$logTotalPop <- log(BLM30k$TotalPop)
BLM30k$logpop.density <- log(BLM30k$pop.density)
BLM30k$sqBlackPovertyRate <- BLM30k$BlackPovertyRate^2
colnames(BLM30k)

nb._2.p <- glm.nb(tot.protests ~ logTotalPop + logpop.density + Per_Black + BlackPovertyRate + sqBlackPovertyRate + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k, link=log)
summary(nb._2.p) 

attach(BLM30k)
newdata1 <- data.frame(logTotalPop=11.5, logpop.density=mean(logpop.density, na.rm=T), Per_Black=mean(Per_Black, na.rm=T), BlackPovertyRate=mean(BlackPovertyRate, na.rm=T), sqBlackPovertyRate=mean(sqBlackPovertyRate, na.rm=T), per_ba=mean(per_ba, na.rm=T), collegeenrollpc=mean(collegeenrollpc, na.rm=T), dem_share=mean(dem_share, na.rm=T), deaths_black_pc=c(0, 0.1, 0.2))
newdata1$phat <- predict(nb._2.p, newdata1, type="response")
newdata1$phat[2]/newdata1$phat[1]
detach(BLM30k)

#reading this, remember that deaths per capita variable is in units of "deaths per 10,000 inhabitants" 
newdata1[2,"phat"]/newdata1[1,"phat"]
# In a city of 100,000, holding all other variables at their means, going from no unarmed black deaths to one unarmed black death  increased the likelihood of protest by about 23%. It is worth remembering however, that the likelihood of protest remained small -- our model predicts that about one in ten cities of that size and demographic makeup would hold a protest at all. 

BLM30k.nd <- BLM30k[BLM30k$deathduring==0,] 
# rerunning so we have the new variables

nb.SI2_2.p <- glm.nb(tot.protests ~ logTotalPop + logpop.density + Per_Black + BlackPovertyRate + sqBlackPovertyRate + per_ba + collegeenrollpc + dem_share + deaths_black_pc, data=BLM30k.nd, link=log)
summary(nb.SI2_2.p)

attach(BLM30k.nd)
newdata2 <- data.frame(logTotalPop=11.5, logpop.density=mean(logpop.density, na.rm=T), Per_Black=mean(Per_Black, na.rm=T), BlackPovertyRate=mean(BlackPovertyRate, na.rm=T), sqBlackPovertyRate=mean(sqBlackPovertyRate, na.rm=T), per_ba=mean(per_ba, na.rm=T), collegeenrollpc=mean(collegeenrollpc, na.rm=T), dem_share=mean(dem_share, na.rm=T), deaths_black_pc=c(0, 0.1, 0.2))
newdata2$phat <- predict(nb.SI2_2.p, newdata2, type="response")
newdata2$phat[2]/newdata2$phat[1]
detach(BLM30k.nd)
newdata2[2,"phat"]/newdata2[1,"phat"]

# Turning to the models exclusively for "solidarity" cities, holding all other variables at their means, going from zero to one police-caused death of a black person in a city of 100,000 predicts a 31% increase in protest activity. 



