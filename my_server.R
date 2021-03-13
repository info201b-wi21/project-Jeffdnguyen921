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

SSDB_df_adjusted <- SSDB_Raw_Data_df %>%
  unite("location", City, State, sep = ", ")

SSDB_df_adjusted <-  left_join(SSDB_df_adjusted, us_city_state_city, by = "location")

SSDB_df_adjusted <- SSDB_df_adjusted %>%
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

SSDB_Final_df <- left_join(SSDB_df_adjusted, Casualties_df, by = "Incident_ID")

SSDB_Final_df <- SSDB_Final_df %>%
  mutate(Casualties = Fatal + Wounded + `Minor Injuries`)
SSDB_Final_df <- SSDB_Final_df[!duplicated(SSDB_Final_df[,c("Date", "School")]),]

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

###########################################################################################

United_States_Shape <- map_data("state")

Shootings_by_County_fips <- SSDB_Final_df %>%
  select(county_fips, Date, Casualties, School, location)
Shootings_by_County_fips <- left_join(Shootings_by_County_fips, us_city_state_city, by = c("county_fips", "location"))

Shootings_by_County_fips <- Shootings_by_County_fips %>%
  filter(lng > -140) %>%
  select(Date, county_fips, location, School, state_name, lat, lng, Casualties) %>%
  mutate(year = as.numeric(str_sub(Date, 1, 4)))

Shootings_by_County_fips[c("Casualties")][is.na(Shootings_by_County_fips[c("Casualties")])] <- 0

Shootings_by_County_fips <- Shootings_by_County_fips %>%
  mutate(info = paste("Date: ", Date, "\nLocation: ", location, "\nSchool: ", School, "\nCasualties: ", Casualties, sep = ""))

####################################################################################################
q1_unemployment_df <- select(Unemployment_df, county_fips, area_name, Med_HH_Income_Percent_of_State_Total_2019)
q1_only_counties <- Unemployment_df[grep("County", q1_unemployment_df$area_name),]

#Q1 proportion ######################################################################################################
us_city_state_city <- us_cities %>%
  unite("location", city, state_id, sep = ", ") %>% 
  select(location, county_fips, lat, lng)

SSDB_df <- SSDB_Raw_Data_df %>%
  unite("location", City, State, sep = ", ") %>%
  inner_join(us_city_state_city, by = "location")%>%
  rename(campus_location = Location)%>%
  select(Incident_ID, county_fips, Date, School, School_Level, campus_location, location, Situation, Targets, Accomplice,
         Officer_Involved, Bullied, Domestic_Violence, Gang_Related, Shots_Fired,
         weapontype) %>% 
  unique()

q1_county_weapon_income_df <- SSDB_df %>%
  select(county_fips, weapontype) %>%
  inner_join(q1_only_counties, by = "county_fips") %>% 
  select(weapontype, Med_HH_Income_Percent_of_State_Total_2019)

###### low class
q1_low_rifle <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 < 81.65) %>%
  mutate(is_rifle = weapontype == "Rifle" | weapontype == "Multiple Rifles") %>%
  summarise(total = n(), rifles = sum(is_rifle, na.rm = TRUE), proportion = (rifles / total) * 100) %>%
  pull(proportion)

q1_low_handgun <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 < 81.65) %>% 
  mutate(is_handgun = weapontype == "Handgun" | weapontype == "Multiple Handguns") %>% 
  summarise(total = n(), handgun = sum(is_handgun, na.rm = TRUE), proportion = (handgun / total) * 100) %>% 
  pull(proportion)

q1_low_shotgun <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 < 81.65) %>% 
  mutate(is_shotgun = weapontype == "Shotgun" | weapontype == "Multiple Shotguns") %>% 
  summarise(total = n(), shotgun = sum(is_shotgun, na.rm = TRUE), proportion = (shotgun / total) * 100) %>% 
  pull(proportion)

q1_unknown_low <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 < 81.65) %>% 
  mutate(is_unknown = weapontype == "Unknown" | weapontype == "Multiple Unknown" | weapontype == "Other") %>% 
  summarise(total = n(), unknown = sum(is_unknown, na.rm = TRUE), proportion = (unknown / total) * 100) %>% 
  pull(proportion)


##### mid class
q1_mid_rifle <- q1_county_weapon_income_df %>% 
  filter(Med_HH_Income_Percent_of_State_Total_2019 >= 81.65, Med_HH_Income_Percent_of_State_Total_2019 <= 93.05) %>% 
  mutate(is_rifle = weapontype == "Rifle" | weapontype == "Multiple Rifles") %>% 
  summarise(total = n(), rifles = sum(is_rifle, na.rm = TRUE), proportion = (rifles / total) * 100)%>% 
  pull(proportion)

q1_mid_handgun <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 >= 81.65, Med_HH_Income_Percent_of_State_Total_2019 <= 93.05) %>% 
  mutate(is_handgun = weapontype == "Handgun" | weapontype == "Multiple Handguns") %>% 
  summarise(total = n(), handgun = sum(is_handgun, na.rm = TRUE), proportion = (handgun / total) * 100) %>% 
  pull(proportion)

q1_mid_shotgun <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 >= 81.65, Med_HH_Income_Percent_of_State_Total_2019 <= 93.05) %>% 
  mutate(is_shotgun = weapontype == "Shotgun" | weapontype == "Multiple Shotguns") %>% 
  summarise(total = n(), shotgun = sum(is_shotgun, na.rm = TRUE), proportion = (shotgun / total) * 100) %>% 
  pull(proportion)

q1_unknown_med <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 >= 81.65, Med_HH_Income_Percent_of_State_Total_2019 <= 93.05) %>% 
  mutate(is_unknown = weapontype == "Unknown" | weapontype == "Multiple Unknown" | weapontype == "Other") %>% 
  summarise(total = n(), unknowns = sum(is_unknown, na.rm = TRUE), proportion = (unknowns / total) * 100) %>% 
  pull(proportion)

#### high class
q1_high_rifle <- q1_county_weapon_income_df %>% 
  filter(Med_HH_Income_Percent_of_State_Total_2019 > 93.05) %>% 
  mutate(is_rifle = weapontype == "Rifle" | weapontype == "Multiple Rifles") %>% 
  summarise(total = n(), rifles = sum(is_rifle, na.rm = TRUE), proportion = (rifles / total) * 100) %>% 
  pull(proportion)

q1_high_handgun <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 > 93.05) %>%
  mutate(is_handgun = weapontype == "Handgun" | weapontype == "Multiple Handguns") %>% 
  summarise(total = n(), handgun = sum(is_handgun, na.rm = TRUE), proportion = (handgun / total) * 100) %>% 
  pull(proportion)

q1_high_shotgun <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 > 93.05) %>%
  mutate(is_shotgun = weapontype == "Shotgun" | weapontype == "Multiple Shotguns") %>% 
  summarise(total = n(), shotgun = sum(is_shotgun, na.rm = TRUE), proportion = (shotgun / total) * 100) %>% 
  pull(proportion)

q1_unknown_high <- q1_county_weapon_income_df %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 > 93.05) %>% 
  mutate(is_unknown = weapontype == "Unknown" | weapontype == "Multiple Unknown" | weapontype == "Other") %>% 
  summarise(total = n(), unknown = sum(is_unknown, na.rm = TRUE), proportion = (unknown / total) * 100) %>% 
  pull(proportion)

q1_class <- c("Low", "Med", "High")
q1_proportion_known <- 100-(sum(q1_unknown_low, q1_unknown_med, q1_unknown_high))
q1_proportion_rifle <- c(q1_low_rifle, q1_mid_rifle, q1_high_rifle)
q1_proportion_handgun <- c(q1_low_handgun, q1_mid_handgun, q1_high_handgun)
q1_proportion_shotgun <-c(q1_low_shotgun, q1_mid_shotgun, q1_high_shotgun)
q1_proportion_unknown <- data.frame(group = c("Known", "Unknown"), value = c(80.22386, 19.77614))

q1_weapontype_rate <- data.frame(q1_class, q1_proportion_rifle, q1_proportion_handgun, q1_proportion_shotgun) %>%
  rename(Rifle = q1_proportion_rifle, Handgun = q1_proportion_handgun, Shotgun = q1_proportion_shotgun)
q1_weapontype_rate$q1_class <- factor(q1_weapontype_rate$q1_class, levels = c("Low", "Med", "High"))

######################################### Q4 WRANGLING ######################################################

us_city_state_city <- us_cities %>%
  unite("location", city, state_id, sep = ", ") %>% 
  select(location, county_fips, lat, lng)

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
  #https://stackoverflow.com/questions/47562321/split-one-variable-into-multiple-variables-in-r
  mutate(people = 1) %>%
  pivot_wider(names_from = Victim_outcome, values_from = people, values_fn = sum, values_fill = 0)

SSDB_Victim_df <- left_join(SSDB_df, Casualties_df, by = "Incident_ID")

SSDB_casualty_df <- SSDB_Victim_df%>%
  unique()

SSDB_officer_df <- SSDB_casualty_df %>% 
  select(county_fips, Officer_Involved)

unemployment_county_income_df <- Unemployment_df %>% 
  select(county_fips, Med_HH_Income_Percent_of_State_Total_2019) %>% 
  drop_na()

SSDB_officer_involvement_income_df <- SSDB_officer_df %>% 
  inner_join(unemployment_county_income_df, by ="county_fips") %>% 
  select(Officer_Involved, Med_HH_Income_Percent_of_State_Total_2019)

officer_present <- c("Yes", "No")
#############################################################################################################

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

####################################################################################################
############ Numerical Analysis #############################

Shootings_Unemployment_Analysis <- left_join(SSDB_Final_df, Unemployment_df, by = "county_fips")

Shootings_Unemployment_Analysis <- Shootings_Unemployment_Analysis %>%
  select(Casualties, Med_HH_Income_Percent_of_State_Total_2019) %>%
  mutate_all(~replace(., is.na(.), 0)) 

High_Income_Casualties <- Shootings_Unemployment_Analysis %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 >= 93.05) %>%
  summarise(average_casualties = mean(Casualties))

Mid_Income_Casualties <- Shootings_Unemployment_Analysis %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 >= 81.65) %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 <= 93.05) %>%
  summarise(average_casualties = mean(Casualties))

Low_Income_Casualties <- Shootings_Unemployment_Analysis %>%
  filter(Med_HH_Income_Percent_of_State_Total_2019 <= 81.65) %>%
  summarise(average_casualties = mean(Casualties))

####################################################################################################

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
      summarise(Occurrence = n())
    paste("This graph shows a histogram outlining the occurrences of shootings at", input$School3, "school levels. 
          relative to the income percentage from", input$Income3[1], "to", input$Income3[2], 
    "and the date from", input$Date3[1], "to", input$Date3[2], "in the United States. Through this we can see how income relates to the occurrences of shootings.
    In the graph we found that many of the shootings happened around the 100% income percentage. This is constant with the constituted average of these school shootings around 98.54%. 
    The income brackets (low, medium, and high) described in the introductions shows that many of the shootings happen at a higher income bracket.
    Getting to the school levels, the highest number of shooting occurrences came at the high school level with 600 occurrences. The lowest number of shooting occurrences came from low income middle schools at 27 occurrences. 
    The three highest shooting years were 2018, 2019, 2020 in this time span the areas where these shootings occurred averaged out to an income of 101.094% constant with other data. 
    Overall there is a misconceptions that shootings happen in poor, underserved communities, according to our data, we found that areas around 100% of their states income are more likely to experience a school shooting, especially in recent years."
    )
  })
  
  output$plot <- renderPlot({
    plot <- ggplot(data=q1_weapontype_rate, mapping = aes_string(x = "q1_class", y = input$weapon, fill = "q1_class")) +
      geom_col() +
      labs(x = "Income Level", y = input$weapon, fill = "") +
      scale_fill_manual(values = c("#d8b365", "#f5f5f5", "#5ab4ac")) +
      scale_y_continuous(labels = scales::percent_format(scale = 1))
    return(plot)
  })
  
  output$plot2 <- renderPlot({
    plot2 <- ggplot(q1_proportion_unknown, aes(x=" ", y=value, fill=group))+
      geom_bar(width = 1, stat = "identity", color = "white") +
      coord_polar("y", start=0) +
      labs(title = "Proportion of Unknown Weapontype", x = "", y = "", fill = "") +
      theme_void() +
      theme(plot.title = element_text(hjust=.5)) +
      scale_fill_manual(values=c("#d8b365", "#f5f5f5"))
    return(plot2)
  })
  
  output$desc1 <- renderText({
    paste("A graphical representation of income level and the proportion of", input$weapon, "use nationwide")
  })
  
  output$Question4 <- renderPlot({
    police_involvement_plot <- SSDB_officer_involvement_income_df %>% 
      mutate(Shootings = 1) %>%
      rename(income_percent = Med_HH_Income_Percent_of_State_Total_2019)%>%
      filter(Officer_Involved == input$Police)%>%
      group_by(Officer_Involved, income_percent)%>%
      summarise(Shootings = n())
    
    p <- ggplot(police_involvement_plot) +
      geom_point(aes(x = income_percent, y = Shootings), color = "Blue") +
      
      labs(
        y = "% Police Involved / Not Involved",
        x = "Income Level")  +
      scale_x_continuous(limits = input$Income) +
      scale_y_continuous(labels = scales::percent_format(scale = 1))
    p
  })
  
  output$plotdescription <- renderText({
    paste("A graphical representation of police involvement across income levels ", input$Income[1], " and ",input$Income[2], ". 
          Users can select whether they'd like to see the percentage of police involvement at each income level, or 
          the percent which police where not involved at each level. According to the data, the middle income bracket 
          had the highest percentage of police involvement at an average 2.65%, followed by the 
          high income bracket at 1.72%, which was in turn followed by the low income bracket at 1.66% average involvement.", sep = "")
  })
  
  output$text2 <- renderText ({
    return (paste("Based on the summary statistics of the data, there appears to be no correlation between
                    income and casualties in school shootings. <br>This is displayed by the fact that in low
                    income areas, the average casualties per shooting is <i>", Low_Income_Casualties$average_casualties,
                  "</i>. <br>The average for middle income areas is <i>", Mid_Income_Casualties$average_casualties,"</i>.<br> The average
                    casualties for high income areas is <i>", High_Income_Casualties$average_casualties, "</i>. <br>As shown, there
                    appears to be no correlation between income and casualties."))
  })
}

