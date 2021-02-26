library("readr")
library("tidyverse")
library("dplyr")
library("ggplot2")

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

# Merge victim data with SSDB
SSDB_casualty_df <- SSDB_df%>%
  inner_join(SSDB_Victim_df)


########################### SECTION 3 ##########################################
View(Unemployment_df)
View(SSDB_casualty_df)

# Q1: Are rifles more prevalent in shootings in higher income areas?
  
# Need to trim each data set to which columns I need
    # For SSDB: county_fips, weapontype
      # need to remove rows that are not rifle or multiple rifle
    # For unemployment: county_fips, MED_HH_INCOME % state total
SSDB_casualty_county_rifle_df <- SSDB_casualty_df %>% 
  select(county_fips, weapontype) %>% 
  group_by(weapontype) %>% #is this necessary?
  filter(weapontype == "Rifle" | weapontype == "Multiple Rifles")
View(SSDB_casualty_county_rifle_df) #REMOVE

unemployment_county_income_df <- Unemployment_df %>% 
  select(county_fips, Med_HH_Income_Percent_of_State_Total_2019) %>% 
  drop_na()
View(unemployment_county_income_df) #REMOVE

# Need to combine SSDB county fips to Unemployment county fips
county_rifle_income_df <- SSDB_casualty_county_rifle %>% 
  inner_join(unemployment_county_income, by = "county_fips")
View(county_rifle_income_df)

# Q2: Does income affect the number of casualties in a mass shooting?

# Need to trim each data set to which columns I need
  # For SSDB: county_fips, fatal, wounded, minor injuries, none
  # For unemployment: county_fips, med_HH_income % state total

SSDB_county_casualties_df <- SSDB_casualty_df %>% 
  select(county_fips, None, `Minor Injuries`, Wounded, Fatal)
View(SSDB_county_casualties_df)

# Combine SSDB county casualties with unemployment county income
county_casualties_income_df <- SSDB_county_casualties_df %>% 
  inner_join(unemployment_county_income, by ="county_fips")
View(county_casualties_income_df)

# Q3: Of high income areas, are there more shootings at elementary, middle or high schools?

# For SSDB: county_fips, school level
# For Unemployment: county_fips, med_HH_income % state total == high income

# First create a school shooting df that has school level
SSDB_df_school_level <- SSDB_df_state_city%>%
  inner_join(us_city_state_city, by = "location")%>%
  rename(campus_location = Location)%>%
  select(Incident_ID, county_fips, Date, School, School_Level, campus_location, location, Situation, Targets, Accomplice,
         Officer_Involved, Bullied, Domestic_Violence, Gang_Related, Shots_Fired,
         weapontype)

# SSDB: county_fips, school level
county_school_df <- SSDB_df_school_level %>% 
  select(county_fips, School_Level)
View(county_school_df)

# STILL NEED TO FILTER FOR HIGH INCOME AREAS
# Find average medium income household benchmark (taken from 3 person assumption)
us_household_income_by_tier_df <- read_csv(Users/lukamarceta/Downloads/data-LuVX3.csv)

county_high_income_df <- 

# Combine
county_school_income_df <- county_school_df %>% 
  inner_join(unemployment_county_income, by ="county_fips")
View(county_school_income_df)




