setwd(file.path(Sys.getenv('my_dir'),'2021/05/profiles_of_individual_radicalization_in_the_united_states'))

library(tidyverse)

#Omit rows containing specific column of NA
#https://stackoverflow.com/questions/11254524/omit-rows-containing-specific-column-of-na
completeFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[, desiredCols])
  return(data[completeVec, ])
}

df <- readxl::read_excel("PIRUS_Public_May2020.xlsx")
lat_long <- read.csv("us-zip-code-latitude-and-longitude.csv", sep=";")

#States Renamed
lat_long$State[lat_long$State == "AL"] <- "Alabama"
lat_long$State[lat_long$State == "AK"] <- "Alaska"
lat_long$State[lat_long$State == "AZ"] <- "Arizona"
lat_long$State[lat_long$State == "AR"] <- "Arkansas"
lat_long$State[lat_long$State == "CA"] <- "California"
lat_long$State[lat_long$State == "CO"] <- "Colorado"
lat_long$State[lat_long$State == "CT"] <- "Connecticut"
lat_long$State[lat_long$State == "DE"] <- "Delaware"
lat_long$State[lat_long$State == "FL"] <- "Florida"
lat_long$State[lat_long$State == "GA"] <- "Georgia"
lat_long$State[lat_long$State == "HI"] <- "Hawaii"
lat_long$State[lat_long$State == "ID"] <- "Idaho"
lat_long$State[lat_long$State == "IL"] <- "Illinois"
lat_long$State[lat_long$State == "IN"] <- "Indiana"
lat_long$State[lat_long$State == "IA"] <- "Iowa"
lat_long$State[lat_long$State == "KS"] <- "Kansas"
lat_long$State[lat_long$State == "KY"] <- "Kentucky"
lat_long$State[lat_long$State == "LA"] <- "Louisiana"
lat_long$State[lat_long$State == "ME"] <- "Maine"
lat_long$State[lat_long$State == "MD"] <- "Maryland"
lat_long$State[lat_long$State == "MA"] <- "Massachusetts"
lat_long$State[lat_long$State == "MI"] <- "Michigan"
lat_long$State[lat_long$State == "MN"] <- "Minnesota"
lat_long$State[lat_long$State == "MS"] <- "Mississippi"
lat_long$State[lat_long$State == "MO"] <- "Missouri"
lat_long$State[lat_long$State == "MT"] <- "Montana"
lat_long$State[lat_long$State == "NE"] <- "Nebraska"
lat_long$State[lat_long$State == "NV"] <- "Nevada"
lat_long$State[lat_long$State == "NH"] <- "New Hampshire"
lat_long$State[lat_long$State == "NJ"] <- "New Jersey"
lat_long$State[lat_long$State == "NM"] <- "New Mexico"
lat_long$State[lat_long$State == "NY"] <- "New York"
lat_long$State[lat_long$State == "NC"] <- "North Carolina"
lat_long$State[lat_long$State == "ND"] <- "North Dakota"
lat_long$State[lat_long$State == "OH"] <- "Ohio"
lat_long$State[lat_long$State == "OK"] <- "Oklahoma"
lat_long$State[lat_long$State == "OR"] <- "Oregon"
lat_long$State[lat_long$State == "PA"] <- "Pennsylvania"
lat_long$State[lat_long$State == "RI"] <- "Rhode Island"
lat_long$State[lat_long$State == "SC"] <- "South Carolina"
lat_long$State[lat_long$State == "SD"] <- "South Dakota"
lat_long$State[lat_long$State == "TN"] <- "Tennessee"
lat_long$State[lat_long$State == "TX"] <- "Texas"
lat_long$State[lat_long$State == "UT"] <- "Utah"
lat_long$State[lat_long$State == "VT"] <- "Vermont"
lat_long$State[lat_long$State == "VA"] <- "Virginia"
lat_long$State[lat_long$State == "WA"] <- "Washington"
lat_long$State[lat_long$State == "WV"] <- "West Virginia"
lat_long$State[lat_long$State == "WI"] <- "Wisconsin"
lat_long$State[lat_long$State == "WY"] <- "Wyoming"

lat_long$City <- trimws(lat_long$City, "right")
lat_long$city_state <- paste0(lat_long$City," ",lat_long$State)

df$Loc_Plot_City1 <- trimws(df$Loc_Plot_City1, "right")
df$city_state <- paste0(df$Loc_Plot_City1," ",df$Loc_Plot_State1)

df$lat <- lat_long[match(df$city_state, lat_long$city_state), 4]
df$long <- lat_long[match(df$city_state, lat_long$city_state), 5]

df2 <- df[,c(1,2,3,7,147,148,6,22,36,38,40,45,52,53,54,101,107,108,127)]

#Plot_Target
#Description: If the individual's first publically known extremist activity included a violent plot, enter the target type or intended target type of the plot. Select up to three target types. If unknown, list -99. If there is no violent plot or no specific plot target, list -88.
df2$Plot_Target[df2$Plot_Target==1] <- "Businesses"
df2$Plot_Target[df2$Plot_Target==2] <- "Government (general)"
df2$Plot_Target[df2$Plot_Target==3] <- "Police"
df2$Plot_Target[df2$Plot_Target==4] <- "Military"
df2$Plot_Target[df2$Plot_Target==5] <- "Abortion related"
df2$Plot_Target[df2$Plot_Target==6] <- "Airports & aircraft"
df2$Plot_Target[df2$Plot_Target==7] <- "Government (diplomatic)"
df2$Plot_Target[df2$Plot_Target==8] <- "Educational institution"
df2$Plot_Target[df2$Plot_Target==9] <- "Food or water supply"
df2$Plot_Target[df2$Plot_Target==10] <- "Journalists & media"
df2$Plot_Target[df2$Plot_Target==11] <- "Maritime (includes ports and maritime facilities)"
df2$Plot_Target[df2$Plot_Target==12] <- "Non-governmental organization"
df2$Plot_Target[df2$Plot_Target==13] <- "Other (e.g., ambulances, firefighters)"
df2$Plot_Target[df2$Plot_Target==14] <- "Private citizens & property"
df2$Plot_Target[df2$Plot_Target==15] <- "Religious figures/institutions"
df2$Plot_Target[df2$Plot_Target==16] <- "Telecommunication"
df2$Plot_Target[df2$Plot_Target==17] <- "Terrorists/non-state militia"
df2$Plot_Target[df2$Plot_Target==18] <- "Tourists"
df2$Plot_Target[df2$Plot_Target==19] <- "Transportation"
df2$Plot_Target[df2$Plot_Target==20] <- "Utilities"
df2$Plot_Target[df2$Plot_Target==-99] <- "Unknown"
df2$Plot_Target[df2$Plot_Target==-88] <- "Not Applicable (i.e., no plot)"

#Internet_Radicalization
#Description: What role did the internet play in the individual's radicalization?
df2$Internet_Radicalization[df2$Internet_Radicalization==0] <- "No known role of the internet in individual's radicalization"
df2$Internet_Radicalization[df2$Internet_Radicalization==1] <- "Internet played a role but was not the primary means of radicalization (e.g. internet resources were used to reaffirm or advance pre-existing radical beliefs)"
df2$Internet_Radicalization[df2$Internet_Radicalization==2] <- "Internet was the primary means of radicalization for the individual (e.g. initial exposure to ideology and subsequent radicalization occurred online"
df2$Internet_Radicalization[df2$Internet_Radicalization==-99] <- "Unknown"
df2$Internet_Radicalization[df2$Internet_Radicalization==-88] <- "Not Applicable (radicalization occurred before 1995)"

#Social_Media
#Description: Is there evidence that online social media played a role in the individual's radicalization and/or mobilization? Online social media is defined as any form of electronic communication through which users create online communities to share information, ideas, personal messages, and other content, such as videos and images. This variable is distinct from Internet_Radicalization in that it emphasizes online user-to-user communication, rather than passively viewing content hosted by an online domain.
df2$Social_Media[df2$Social_Media==0] <- "No"
df2$Social_Media[df2$Social_Media==1] <- "Yes, it played a role but was not the primary means of radicalization or mobilization"
df2$Social_Media[df2$Social_Media==2] <- "Yes, it was the primary means of radicalization for the individual (e.g., initial exposure to ideology and subsequent radicalization occurred over online social media)"
df2$Social_Media[df2$Social_Media==-99] <- "Unknown"
df2$Social_Media[df2$Social_Media==-88] <- "Not Applicable (radicalization/mobilization occurred before 2005)"

#Social_Media_Platform
#Description: If there is evidence that online social media played a role in the individual's radicalization and/or mobilization, which social media platforms did he/she use?
df2$Social_Media_Platform1[df2$Social_Media_Platform1==1] <- "Facebook"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==2] <- "Twitter"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==3] <- "YouTube"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==4] <- "Vimeo"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==5] <- "Instagram"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==6] <- "Flickr"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==7] <- "Tumblr"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==8] <- "Imgur"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==9] <- "Snapchat"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==10] <- "Google Plus"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==11] <- "Skype"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==12] <- "LinkedIn"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==13] <- "MySpace"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==14] <- "4chan"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==15] <- "Reddit"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==16] <- "Ask.fm"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==17] <- "WhatsApp"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==18] <- "Surespot"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==19] <- "Telegram"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==20] <- "Kik"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==21] <- "Paltalk"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==22] <- "VK"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==23] <- "Diaspora"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==24] <- "JustPaste.it"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==25] <- "SoundCloud"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==26] <- "Personal blogging websites (e.g., Wordpress, Blogger, LiveJournal, etc.)"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==27] <- "Other non-encrypted software"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==28] <- "Other encrypted software/unspecified encrypted software"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==-99] <- "Unknown"
df2$Social_Media_Platform1[df2$Social_Media_Platform1==-88] <- "Not Applicable (radicalization/mobilization occurred before 2005)"

#Social_Media_Activities
#Description: If there is evidence that online social media played a role in the individual's radicalization and/or mobilization, which types of social media-related activities did the individual participate in?
df2$Social_Media_Activities1[df2$Social_Media_Activities1==1] <- "Consuming content (passive)"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==2] <- "Disseminating content (i.e., sharing, spreading existing content)"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==3] <- "Participating in extremist dialogue (i.e., creating unsophisticated content)"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==4] <- "Creating propaganda/content (e.g., creating extremist manifestos, propaganda videos, etc.)"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==5] <- "Directly communicating with members of extremist group(s) to establish relationship/acquire information on extremist ideology (no communication on specific travel plans or plot)"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==6] <- "Directly communicating with members of extremist group(s) to facilitate foreign travel"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==7] <- "Directly communicating with members of extremist group(s) to facilitate domestic attack"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==-99] <- "Unknown"
df2$Social_Media_Activities1[df2$Social_Media_Activities1==-88] <- "Not Applicable (radicalization/mobilization occurred before 2005)"

#Radicalization_Islamist
#Description: Did the individual become radicalized as part of an Islamist or jihadist movement?
df2$Radicalization_Islamist[df2$Radicalization_Islamist==0] <- "No"
df2$Radicalization_Islamist[df2$Radicalization_Islamist==1] <- "Yes"
df2$Radicalization_Islamist[df2$Radicalization_Islamist==-99] <- "Unknown"

#Radicalization_Far_Right
#Description: Did the individual become radicalized as part of a right-wing movement?
df2$Radicalization_Far_Right[df2$Radicalization_Far_Right==0] <- "No"
df2$Radicalization_Far_Right[df2$Radicalization_Far_Right==1] <- "Yes"
df2$Radicalization_Far_Right[df2$Radicalization_Far_Right==-99] <- "Unknown"

#Radicalization_Far_Left
#Description: Did the individual become radicalized as part of a left-wing movement?
df2$Radicalization_Far_Left[df2$Radicalization_Far_Left==0] <- "No"
df2$Radicalization_Far_Left[df2$Radicalization_Far_Left==1] <- "Yes"
df2$Radicalization_Far_Left[df2$Radicalization_Far_Left==-99] <- "Unknown"

#Employment_Status
#Description: What was the subject's employment status at the time of exposure?
df2$Employment_Status[df2$Employment_Status==1] <- "Employed"
df2$Employment_Status[df2$Employment_Status==2] <- "Self-employed"
df2$Employment_Status[df2$Employment_Status==3] <- "Unemployed, looking for work"
df2$Employment_Status[df2$Employment_Status==4] <- "Unemployed, not looking for work"
df2$Employment_Status[df2$Employment_Status==5] <- "Student"
df2$Employment_Status[df2$Employment_Status==6] <- "Retired"
df2$Employment_Status[df2$Employment_Status==-99] <- "Unknown"

#Social_Stratum_Adulthood
#Description: In what social stratum did this individual fall in adulthood?
df2$Social_Stratum_Adulthood[df2$Social_Stratum_Adulthood==1] <- "Low (e.g. receives welfare, lives close to the poverty line, regularly unemployed or at best works a blue collar job, lives in subsidized housing)"
df2$Social_Stratum_Adulthood[df2$Social_Stratum_Adulthood==2] <- "Middle (e.g. does not receive welfare, lives in lower-middle or middle class neighborhood, has steady professional employment, owns or holds a mortgage on a house, has college degree)"
df2$Social_Stratum_Adulthood[df2$Social_Stratum_Adulthood==3] <- "High (e.g. works a high-income, white-collar job, lives and owns a house in a middle or upper class neighborhood, can afford luxury items, has college degree or is self-employed as a successful entrepreneur)"
df2$Social_Stratum_Adulthood[df2$Social_Stratum_Adulthood==-99] <- "Unknown"
df2$Social_Stratum_Adulthood[df2$Social_Stratum_Adulthood==-88] <- "Not Applicable (if exposure occurred before the individual turned 18 years old)"

#Aspirations
#Description: Did the individual have clear educational or career aspirations?
df2$Aspirations[df2$Aspirations==0] <- "No"
df2$Aspirations[df2$Aspirations==1] <- "Yes, but did not attempt to achieve them (e.g., talked about becoming a lawyer but never enrolled in college)"
df2$Aspirations[df2$Aspirations==2] <- "Yes, had aspirations, but failed to achieve them"
df2$Aspirations[df2$Aspirations==3] <- "Yes, achieved aspirations prior to public exposure"
df2$Aspirations[df2$Aspirations==-99] <- "Unknown"

#Relationship_Troubles
#Description: Did subject typically have difficulty finding or maintaining romantic relationships?
df2$Relationship_Troubles[df2$Relationship_Troubles==0] <- "No"
df2$Relationship_Troubles[df2$Relationship_Troubles==1] <- "Yes"
df2$Relationship_Troubles[df2$Relationship_Troubles==-99] <- "Unknown"

#Other Cleaning
df2$Terrorist_Group_Name1[df2$Terrorist_Group_Name1 == -99] <- "Unknown"
df2$Terrorist_Group_Name1[df2$Terrorist_Group_Name1 == -88] <- NA
df2$Loc_Plot_State1[df2$Loc_Plot_State1 == -99] <- "Unknown"
df2$Loc_Plot_City1[df2$Loc_Plot_City1 == -99] <- "Unknown"

df2$Date_Exposure <- gsub("\\-.*","",df2$Date_Exposure)
df2$Date_Exposure <- as.numeric(df2$Date_Exposure)

#Remove rows without coordiantes
df3 <- completeFun(df2, "lat")

df2_cleaned <- df2 %>%
  group_by(Date_Exposure) %>%
  mutate(idx = row_number()) %>%
  spread(Date_Exposure, Social_Media_Platform1) %>%
  select(-idx)

Radicalization_Islamist <- df2[grep("Yes",df2$Radicalization_Islamist),]
Radicalization_Far_Right <- df2[grep("Yes",df2$Radicalization_Far_Right),]
Radicalization_Far_Left <- df2[grep("Yes",df2$Radicalization_Far_Left),]