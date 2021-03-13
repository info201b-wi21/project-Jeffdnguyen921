library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readr)
library(maps)
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

##################################################################################################
# Q3: Of high income areas, what are the occurrences of shootings at the different levels of schools?

SSDB_Unemployment_df <- SSDB_Final_df %>%
  inner_join(Unemployment_df)%>%
  select(School_Level, Date, Fatal, Wounded, Med_HH_Income_Percent_of_State_Total_2019)%>%
  mutate(Shootings = 1)%>%
  mutate_if(is.numeric, ~replace(., is.na(.), 0))%>%
  mutate(Dates = as.Date(Date))%>%
  rename(income_percent = Med_HH_Income_Percent_of_State_Total_2019)

All_Schools <- SSDB_Unemployment_df%>%
  filter(School_Level != "Other",
         School_Level != "6-12",
         School_Level != "K-12",
         School_Level != "K-8",
         School_Level != "Unknown")

All_Schools$School_Level <- factor(All_Schools$School_Level,
                                   levels = c("Elementary",
                                              "Middle",
                                              "Junior High",
                                              "High"))

school_levels <- c("All",
                   "Elementary",
                   "Middle",
                   "Junior High",
                   "High")

impact_levels <- c("Occurrences", "Deaths", "Injured")

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
      labs(title = "Shooting Casualties by Income",
           x = "",
           y = "") +
      geom_point(data = Shootings_by_County_fips, aes(x = lng, y = lat, size = Casualties, text = info), color = "springgreen4", alpha = 0.25) +
      scale_size(range = c(1, 7), name = "Casualties") +
      coord_quickmap() +
      scale_fill_distiller(palette = "YlOrBr", direction = 1,trans = "log",
                           breaks=c(50,100,150,200), name= "% Income",
                           guide = guide_legend(keyheight = unit(2, units = "mm"),
                                                keywidth=unit(6, units = "mm"), label.position = "bottom",
                                                title.position = 'top', nrow=1)) +
      theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(),
            axis.ticks.y = element_blank(), axis.text.y = element_blank(),
            plot.background = element_rect(fill = "#f5f5f2", color = NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.title = element_text(size= 22))
    
    United_States_Unemployment_plot <- ggplotly(United_States_Unemployment_plot, tootltip = "info")
    
    return (United_States_Unemployment_plot)
  })
  output$Question3 <- renderPlot({
    Shooting_Levels_plots <- SSDB_Unemployment_df%>%
      filter(Dates >= input$Date3[1], Dates <= input$Date3[2])%>%
      filter(School_Level == input$School3)%>%
      filter(income_percent >= input$Income3[1], income_percent <= input$Income3[2])
    if(input$School3 == "All") {
      Shooting_Levels_plots <- All_Schools%>%
      filter(Dates >= input$Date3[1], Dates <= input$Date3[2])%>%
      filter(income_percent >= input$Income3[1], income_percent <= input$Income3[2])
      
    }
    Occurrence_plot <- ggplot(data = Shooting_Levels_plots, aes(x = income_percent, fill = School_Level, color = School_Level)) + 
      geom_histogram(alpha = 0.5, position = "identity") +
      scale_x_continuous(limits = input$Income3, labels = scales::percent_format(scale = 1)) +
      scale_color_brewer(palette = "Paired") +
      scale_fill_brewer(palette = "Paired") +
      labs(title = "Shootings Across School Levels",
           x = "Income Percentage",
           y = "Occurrences")
    
    return(Occurrence_plot)
  })
  output$desc3 <- renderText({
    question_answer <- SSDB_Unemployment_df%>%
      filter(Dates >= input$Date3[1], Dates <= input$Date3[2])%>%
      filter(School_Level == input$School3)%>%
      filter(income_percent >= input$Income3[1], income_percent <= input$Income3[2])%>%
      group_by(School_Level)%>%
      summarise(Occurrence = n())%>%
      pull(Occurrence)
    paste("This graph shows a histogram outlining the occurrences of shootings at", input$School3, "school levels. 
          relative to the income percentage from", input$Income3[1], "to", input$Income3[2], 
    "and the date from", input$Date3[1], "to", input$Date3[2], "in the United States. For", input$School3, "school levels from", input$Income3[1], "to", input$Income3[2],"and the date from", input$Date3[1], "to", input$Date3[2], 
    "the number of shootings is", question_answer, "in that set. Through this we can see how income relates to the occurrences of shootings.
    In the graph we found that many of the shootings happened around the 100% income percentage. This is constant with the constituted average of these school shootings around 98.54%. 
    The income brackets (low, medium, and high) described in the introductions shows that many of the shootings happen at a higher income bracket.
    Getting to the school levels, the highest number of shooting occurrences came at the high school level with 600 occurrences. The lowest number of shooting occurrences came from low income middle schools at 27 occurrences. 
    The three highest shooting years were 2018, 2019, 2020 in this time span the areas where these shootings occurred averaged out to an income of 101.094% constant with other data. 
    Overall there is a misconceptions that shootings happen in poor, underserved communities, according to our data, we found that areas around 100% of their states income are more likely to experience a school shooting, especially in recent years."
    )
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