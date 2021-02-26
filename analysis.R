library(dplyr)
library(ggplot2)
library(readr)
library(tidyverse)
library(maps)

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
  select(location, county_fips, lat, lng)

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

Unemployment_Over_Time_df <- as.numeric(Unemployment_df[1,3:22])
Unemployment_Over_Time_df <- data.frame(unemployment = Unemployment_Over_Time_df, year = c(
  2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015,
  2016, 2017, 2018, 2019)) %>%
  select(year, unemployment)

Unemployment_Over_Time_plot <- 
  ggplot(Unemployment_Over_Time_df, mapping = aes(x = year, y = unemployment, group = 1, color = unemployment)) +
  geom_line(size = 0.75) +
  labs(title = "Unemployment % over the years (national)",
       x = "Year",
       y = "Unemployment") +
  scale_x_continuous(breaks = seq(2000, 2019, by = 2)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1))
  
  
## Done ################################################################################################
    
##Second Plot Income by county ####################################################################
  
us_cities_county_state <- us_cities %>%
  mutate(county_state = tolower(paste(county_name, state_name, sep = ", "))) %>%
  select(county_state, county_fips)

United_States_Unemployment_df <- map_data("county") %>%
  mutate(county_state = paste(subregion, region, sep = ", "))

United_States_Unemployment_df <- left_join(United_States_Unemployment_df, us_cities_county_state, by = "county_state")

Unemployment_fips <- Unemployment_df %>%
  select(county_fips, Med_HH_Income_Percent_of_State_Total_2019)

United_States_Unemployment_df <- left_join(United_States_Unemployment_df, Unemployment_fips, by = "county_fips")

United_States_Unemployment_plot <-
  ggplot(data = United_States_Unemployment_df) +
  geom_polygon(mapping = aes(x = long, y = lat, group = group, fill = Med_HH_Income_Percent_of_State_Total_2019)) +
  coord_quickmap() +
  labs(title = "Median Household Income percent state total",
       x = "",
       y = "",
       caption = "Displays the median household income of the county when compared to the state average. A number of
       200% percent means that county is making double the median household income of the state.") +
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(),
        axis.ticks.y = element_blank(), axis.text.y = element_blank(),
        plot.background = element_rect(fill = "#f5f5f2", color = NA),
        panel.background = element_rect(fill = "#f5f5f2", color = NA),
        legend.position = c(0.12, 0.09)) +
  scale_fill_distiller(palette = "YlOrBr", direction = 1,trans = "log", 
                       breaks=c(50,100,150,200), name="% Income", 
                       guide = guide_legend( keyheight = unit(3, units = "mm"), 
                       keywidth=unit(8, units = "mm"), label.position = "bottom", 
                       title.position = 'top', nrow=1))

##############################################################################################################
  
##Third Plot Shooting by areas ####################################################################

United_States_Shape <- map_data("state")

Shootings_by_County_fips <- SSDB_Final_df %>%
  select(county_fips)
Shootings_by_County_fips <- left_join(Shootings_by_County_fips, us_city_state_city, by = "county_fips")

Shootings_by_County_fips <- Shootings_by_County_fips %>%
  filter(lng > -140)

Shootings_by_Location_plot <-
  ggplot() +
    geom_polygon(data = United_States_Shape, aes(x = long, y = lat, group = group), fill = "grey", alpha = 1) +
    geom_point(data = Shootings_by_County_fips, aes(x = lng, y = lat), size = 0.75, color = "firebrick4") +
    theme_void() +
    labs(title = "Shootings All Over The U.S.",
         caption = "Each dot represents a school shooting. The shootings range from 1970 to 2021.") +
    theme(plot.title = element_text(size= 22, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm"))) +
    coord_quickmap()

#################################################################################################
