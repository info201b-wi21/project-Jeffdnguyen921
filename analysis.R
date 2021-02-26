library(readr)
library(tidyverse)
library(dplyr)

SSDB_Raw_Data_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Raw_Data_Compiled.csv?token=ASLKMK4FWIIAM7YWLDYYV6DAH4CY2")

Victim_df <- read.csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Victim_Raw_Data.csv?token=ASLKMK6AE6ERKLKXHWTRAJTAH47BW")

Unemployment_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/Unemployment.Compiled.csv?token=ASLKMK2CIMZKQEZ2I2AZ65DAH4KC2")

us_cities <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/uscities.csv?token=ASLKMK4UTUNAYL7DBRIZLG3AH4J3E")

features <- colnames(us_cities)

# Put together the casualties of each match shooting by shooting ID
Casualties_df <- Victim_df%>%
  select(incidentid, injury)%>%
  rename(Incident_ID = incidentid)%>%
  rename(Victim_outcome = injury)%>%
  mutate(Victim_outcome = ifelse(Victim_outcome %in% "", "None", Victim_outcome)) %>% #https://stackoverflow.com/questions/47562321/split-one-variable-into-multiple-variables-in-r
  mutate(people = 1)%>%
  pivot_wider(names_from = Victim_outcome, values_from = people, values_fn = sum, values_fill = 0)

# joining county_fips in school_schooting database using a complete USA  
# location dataset so that SSDB and Unemployment both have county fips.

us_city_state_city <- us_cities %>%
  unite("location", city, state_id, sep = ", ") %>%
  select(location, county_fips)

SSDB_df_state_city <- SSDB_Raw_Data_df %>%
  unite("location", City, State, sep = ", ")

SSDB_df <- SSDB_df_state_city%>%
  inner_join(us_city_state_city, by = "location")%>%
  rename(campus_location = Location)%>%
  select(Incident_ID, county_fips, Date, School, campus_location, location, Situation, Targets, Accomplice,
         Officer_Involved, Bullied, Domestic_Violence, Gang_Related, Shots_Fired,
         weapontype)

# joining county_fips in school_schooting database using a complete USA

SSDB_Victim_df <- Casualties_df%>%
  inner_join(SSDB_df, by = "Incident_ID")

# rename so unemployment_df and SSDB both have 'county_fips' column

Unemployment_df <- Unemployment_df%>%
  rename(county_fips = fips_txt)

# Select columns that are necessary to do analysis 

Unemployment_df <- Unemployment_df%>%
select(county_fips, area_name, Unemployment_rate_2000, Unemployment_rate_2001, 
       Unemployment_rate_2002, Unemployment_rate_2003, Unemployment_rate_2004, 
       Unemployment_rate_2005, Unemployment_rate_2006, Unemployment_rate_2007, 
       Unemployment_rate_2008, Unemployment_rate_2009, Unemployment_rate_2010, 
       Unemployment_rate_2011, Unemployment_rate_2012, Unemployment_rate_2013, 
       Unemployment_rate_2014, Unemployment_rate_2015, Unemployment_rate_2016, 
       Unemployment_rate_2017, Unemployment_rate_2018, Unemployment_rate_2019, 
       Median_Household_Income_2019, Med_HH_Income_Percent_of_State_Total_2019)

# Merge unemployment data with SSDB
SSDB_victim_ <- SSDB_df%>%
  inner_join(Unemployment_df)

# sample tables
School_Shooting <- SSDB_Victim_df%>%
  select(Date, School, location, Situation, Wounded, Fatal, None)

Unemployment_Income <- Unemployment_df%>%
  select(area_name, Unemployment_rate_2019, Median_Household_Income_2019, 
         Med_HH_Income_Percent_of_State_Total_2019)

#2.2 Summary Statistics 

## mean, max school shootings
SS_incidents_2019 <- SSDB_df %>%
  filter(Date >= "2019-01-01" & Date <= "2019-12-31") %>%
  length()
  
SS_casulties <- SSDB_Victim_df %>%
  filter(Date >= "2019-01-01" & Date <= "2019-12-31") %>%
  summarise(Fatal = sum(Fatal), Wounded = sum(Wounded)) %>%
  as.list()

gun_type <- SSDB_df %>%
  distinct(weapontype) %>%
  drop_na() %>%
  filter(weapontype == "Handgun" | weapontype == "Rifle" | weapontype == "Shotgun") %>%
  as.list()

SS_description_2019 <- list(SS_incidents_2019, SS_casulties, gun_type)
  
## mean, max unemployment data 2019
us_unemployment_2019 <- slice(Unemployment_df, 1) %>%
  select(Unemployment_rate_2019, Median_Household_Income_2019)

max_us_unemployment_2019 <- Unemployment_df %>%
  select(area_name, county_fips, Unemployment_rate_2019, Median_Household_Income_2019,
         Med_HH_Income_Percent_of_State_Total_2019) %>%
  summarise(max_unemployment = max(Unemployment_rate_2019, na.rm = T),
            max_household_income = max(Median_Household_Income_2019, na.rm = T),
            max_percent_of_state = max(Med_HH_Income_Percent_of_State_Total_2019,  na.rm = T))

unemployment_description_2019 <- list(as.list(max_us_unemployment_2019), as.list(us_unemployment_2019))


  





