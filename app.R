# Load libraries so they are available
library("shiny")
library("tidyverse")
library("ggplot2")
library("dplyr")

source("my_server.R")
source("my_ui.R")

shinyApp(ui = my_ui, server = my_server)

