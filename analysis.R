library(readr)
library(dplyr)
library(tidyverse)

SSDB_Raw_Data_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Raw_Data_Compiled.csv?token=ANELWSYOWTETEWDUQQXVQQLAH3BWK")
Unemployment_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/Unemployment.csv?token=ANELWS4YK7YOILJLXLUBSPLAHTDI2")

#### Displays for part 2 ####

SSDB_display_table <- SSDB_Raw_Data_df[1:5,] %>%
  select(Incident_ID, Date, School, School_Level, City, State, Location, Time_Period, Summary, Narrative, Situation, Targets)

Unemployment_display_table <- Unemployment_df[c(37, 23789, 891, 4570, 37097),]
  