setwd(file.path(Sys.getenv('my_dir'),'2021/05/profiles_of_individual_radicalization_in_the_united_states'))

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






