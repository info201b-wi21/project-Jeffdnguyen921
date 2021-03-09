library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readr)
library(maps)
library(rstatix)
library(stringr)
library(plotly)

us_cities <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/uscities.csv?token=ANELWS555GBQNJWKXIFPHS3AJSS7G")
Unemployment_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/Unemployment.Compiled.csv?token=ANELWS342FTH7U7YE626BQ3AJSS4K")
Victim_df <- read.csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Victim_Raw_Data.csv?token=ANELWSYGEH5CGCPASHMCJRDAJSTDM")
SSDB_Raw_Data_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Raw_Data_Compiled.csv?token=ANELWSYOEO5UGRFHV26MPJTAJSSY4")
Unemployment_df <- Unemployment_df %>%
  rename(county_fips = fips_txt)

us_city_state_city <- us_cities %>%
  unite("location", city, state_id, sep = ", ") %>% 
  select(location, county_fips, state_name, lat, lng)

SSDB_df <- SSDB_Raw_Data_df %>%
  unite("location", City, State, sep = ", ") %>%
  inner_join(us_city_state_city, by = "location")%>%
  rename(campus_location = Location)%>%
  select(Incident_ID, county_fips, Date, School, School_Level, campus_location, location, Situation, Targets, Accomplice,
         Officer_Involved, Bullied, Domestic_Violence, Gang_Related, Shots_Fired,
         weapontype) %>% 
  unique()

Casualties_df <- Victim_df %>%
  select(incidentid, injury) %>%
  rename(Incident_ID = incidentid) %>%
  rename(Victim_outcome = injury )%>%
  mutate(Victim_outcome = ifelse(Victim_outcome %in% "", "None", Victim_outcome)) %>% 
  mutate(people = 1) %>%
  pivot_wider(names_from = Victim_outcome, values_from = people, values_fn = sum, values_fill = 0)

SSDB_Final_df <- left_join(SSDB_df, Casualties_df, by = "Incident_ID")

SSDB_Final_df <- SSDB_Final_df %>%
  mutate(Casualties = Fatal + Wounded + `Minor Injuries`)

####################################################################################################

us_cities_county_state <- us_cities %>%
  mutate(county_state = tolower(paste(county_name, state_name, sep = ", "))) %>%
  select(county_state, county_fips) %>%
  add_row(county_state = "piscataquis, maine", county_fips = "23021") %>%
  add_row(county_state = "st louis, minnesota", county_fips = "27137") %>%
  add_row(county_state = "somerset, maine", county_fips = "23025") %>%
  add_row(county_state = "st lawrence, new york", county_fips = "36089") %>%
  add_row(county_state = "dona ana, new mexico", county_fips = "35013")

United_States_Unemployment_df <- map_data("county") %>%
  mutate(county_state = paste(subregion, region, sep = ", "))

United_States_Unemployment_df <- left_join(United_States_Unemployment_df, us_cities_county_state, by = "county_state")

Unemployment_fips <- Unemployment_df %>%
  select(county_fips, Med_HH_Income_Percent_of_State_Total_2019)

United_States_Unemployment_df <- left_join(United_States_Unemployment_df, Unemployment_fips, by = "county_fips")

# United_States_Unemployment_plot <-
#   ggplot(data = United_States_Unemployment_df) +
#   geom_polygon(mapping = aes(x = long, y = lat, group = group, fill = Med_HH_Income_Percent_of_State_Total_2019)) +
#   coord_quickmap() +
#   labs(title = "Median Household Income percent state total",
#        x = "",
#        y = "",
#        caption = "Displays the median household income of the county when compared to the state average. A number of
#        200% means that county is making double the median household income of the state.") +
#   theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(),
#         axis.ticks.y = element_blank(), axis.text.y = element_blank(),
#         plot.background = element_rect(fill = "#f5f5f2", color = NA),
#         panel.background = element_rect(fill = "#f5f5f2", color = NA),
#         legend.position = c(0.12, 0.09)) +
#   scale_fill_distiller(palette = "YlOrBr", direction = 1,trans = "log", 
#                        breaks=c(50,100,150,200), name="% Income", 
#                        guide = guide_legend( keyheight = unit(3, units = "mm"), 
#                                              keywidth=unit(8, units = "mm"), label.position = "bottom", 
#                                              title.position = 'top', nrow=1))

###########################################################################################

United_States_Shape <- map_data("state")

Shootings_by_County_fips <- SSDB_Final_df %>%
  select(county_fips, Date, Casualties, School)
Shootings_by_County_fips <- left_join(Shootings_by_County_fips, us_city_state_city, by = "county_fips")

Shootings_by_County_fips <- Shootings_by_County_fips %>%
  filter(lng > -140) %>%
  select(Date, county_fips, location, School, state_name, lat, lng, Casualties) %>%
  mutate(year = as.numeric(str_sub(Date, 1, 4)))

Shootings_by_County_fips[c("Casualties")][is.na(Shootings_by_County_fips[c("Casualties")])] <- 0

Shootings_by_County_fips <- Shootings_by_County_fips %>%
  mutate(info = paste("Date: ", Date, "\nLocation: ", location, "\nSchool: ", School, "\nCasualties: ", Casualties, sep = ""))

# Shootings_by_Location_plot <-
#   ggplot() +    
#   geom_polygon(data = United_States_Shape, aes(x = long, y = lat, group = group), fill = "grey", alpha = 1) +
#   geom_point(data = Shootings_by_County_fips, aes(x = lng, y = lat), size = 0.75, color = "firebrick4") +
#   theme_void() +
#   labs(title = "Shootings All Over The U.S.",
#        caption = "Each dot represents a school shooting. The shootings range from 1970 to 2021.") +
#   theme(plot.title = element_text(size= 22, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm"))) +
#   coord_quickmap()

my_server <- function(input, output) {
  
  output$question2 <- renderPlotly ({
    
    Shootings_by_County_fips <- Shootings_by_County_fips %>%
      filter(year >= input$years2[1]) %>%
      filter(year <= input$years2[2])
    
    if(input$state2 != "") {
      United_States_Unemployment_df <- United_States_Unemployment_df %>%
        filter(region == tolower(input$state2))
      Shootings_by_County_fips <- Shootings_by_County_fips %>%
        filter(tolower(state_name) == tolower(input$state2))
      United_States_Shape <- United_States_Shape %>%
        filter(region == tolower(input$state2))
    }
    
    United_States_Unemployment_plot <-
      ggplot() +
      {if(input$incomeGradient == TRUE) geom_polygon(data = United_States_Unemployment_df, 
                                                     mapping = aes(x = long, y = lat, group = group, 
                                                                   fill = Med_HH_Income_Percent_of_State_Total_2019))} +
      {if(input$incomeGradient == FALSE) geom_polygon(data = United_States_Shape, 
                                                      aes(x = long, y = lat, group = group), 
                                                      fill = "grey", alpha = 1)} +
      geom_point(data = Shootings_by_County_fips, aes(x = lng, y = lat, size = Casualties, text = info), color = "springgreen4", alpha = 0.25) +
      # scale_size(range = c(1, 10)) +
      coord_quickmap() + 
      theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(),
            axis.ticks.y = element_blank(), axis.text.y = element_blank(),
            plot.background = element_rect(fill = "#f5f5f2", color = NA),
            panel.background = element_rect(fill = "#f5f5f2", color = NA),
            legend.position = c(0.12, 0.09)) +
      scale_fill_distiller(palette = "YlOrBr", direction = 1,trans = "log",
                           breaks=c(50,100,150,200), name="% Income",
                           guide = guide_legend( keyheight = unit(2, units = "mm"),
                                                 keywidth=unit(6, units = "mm"), label.position = "bottom",
                                                 title.position = 'top', nrow=1))
    
    United_States_Unemployment_plot <- ggplotly(United_States_Unemployment_plot, tootltip = "info")  
    
    return (United_States_Unemployment_plot)
    
  })
}


# labs(title = "Median Household Income percent state total",
#      x = "",
#      y = "",
#      caption = "Displays the median household income of the county when compared to the state average. A number of
#  200% means that county is making double the median household income of the state.") +
# theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(),
#       axis.ticks.y = element_blank(), axis.text.y = element_blank(),
#       plot.background = element_rect(fill = "#f5f5f2", color = NA),
#       panel.background = element_rect(fill = "#f5f5f2", color = NA),
#       legend.position = c(0.12, 0.09)) +
# scale_fill_distiller(palette = "YlOrBr", direction = 1,trans = "log", 
#                      breaks=c(50,100,150,200), name="% Income", 
#                      guide = guide_legend( keyheight = unit(3, units = "mm"), 
#                                            keywidth=unit(8, units = "mm"), label.position = "bottom", 
#                                            title.position = 'top', nrow=1))