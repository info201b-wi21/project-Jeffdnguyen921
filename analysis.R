library(dplyr)
library(ggplot2)
library(readr)
library(tidyverse)

SSDB_Raw_Data_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Raw_Data_Compiled.csv?token=ASLKMK4FWIIAM7YWLDYYV6DAH4CY2")
Victim_df <- read.csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Victim_Raw_Data.csv?token=ASLKMK6AE6ERKLKXHWTRAJTAH47BW")
Unemployment_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/Unemployment.Compiled.csv?token=ASLKMK2CIMZKQEZ2I2AZ65DAH4KC2")
us_cities <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/uscities.csv?token=ASLKMK4UTUNAYL7DBRIZLG3AH4J3E")

features <- colnames(us_cities)

# Put together the casualties of each match shooting by shooting ID
Casualties_df <- Victim_df %>%
  select(incidentid, injury) %>%
  rename(Incident_ID = incidentid) %>%
  rename(Victim_outcome = injury )%>%
  mutate(Victim_outcome = ifelse(Victim_outcome %in% "", "None", Victim_outcome)) %>% 
  #https://stackoverflow.com/questions/47562321/split-one-variable-into-multiple-variables-in-r
  mutate(people = 1) %>%
  pivot_wider(names_from = Victim_outcome, values_from = people, values_fn = sum, values_fill = 0)

# joining county_fips in school_schooting database using a complete USA  
# location dataset so that SSDB and Unemployment both have county fips.
us_city_state_city <- us_cities %>%
  unite("location", city, state_id, sep = ", ") %>%
  select(location, county_fips)

SSDB_df <- SSDB_Raw_Data_df %>%
  unite("location", City, State, sep = ", ") %>%
  inner_join(us_city_state_city, by = "location")%>%
  rename(campus_location = Location)%>%
  select(Incident_ID, county_fips, Date, School, campus_location, location, Situation, Targets, Accomplice,
         Officer_Involved, Bullied, Domestic_Violence, Gang_Related, Shots_Fired,
         weapontype)

#joining county_fips in school_schooting database using a complete USA
SSDB_Final_df <- left_join(SSDB_df, Casualties_df, by = "Incident_ID")

# rename so unemployment_df and SSDB both have 'county_fips' column
Unemployment_df <- Unemployment_df %>%
  rename(county_fips = fips_txt)

# Select columns that are necessary to do analysis 
Unemployment_df <- Unemployment_df %>%
select(county_fips, area_name, Unemployment_rate_2000, Unemployment_rate_2001, 
       Unemployment_rate_2002, Unemployment_rate_2003, Unemployment_rate_2004, 
       Unemployment_rate_2005, Unemployment_rate_2006, Unemployment_rate_2007, 
       Unemployment_rate_2008, Unemployment_rate_2009, Unemployment_rate_2010, 
       Unemployment_rate_2011, Unemployment_rate_2012, Unemployment_rate_2013, 
       Unemployment_rate_2014, Unemployment_rate_2015, Unemployment_rate_2016, 
       Unemployment_rate_2017, Unemployment_rate_2018, Unemployment_rate_2019, 
       Median_Household_Income_2019, Med_HH_Income_Percent_of_State_Total_2019)

# Merge unemployment data with SSDB
SSDB_Unemployment_df <- SSDB_df %>%
  inner_join(Unemployment_df)

## Creating The First Plot #############################################################################

Shooting_Over_Time_DF <- SSDB_Final_df %>%
  mutate(year = str_sub(SSDB_Final_df$Date, 1, 4)) %>%
  group_by(year) %>%
  summarise(occurences = n())

Shooting_Over_Time_plot <- 
  ggplot(Shooting_Over_Time_DF, mapping = aes(x = year, y = occurences, group = 1, color = occurences)) +
    geom_line(size = 0.75) +
    labs(title = "Number of School Shootings Throughout the Years",
       x = "Year",
       y = "Occurences") +
    scale_x_discrete(breaks = seq(1970, 2021, by = 5))

## Done ################################################################################################
    

  

  
