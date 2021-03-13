officer_present <- c("Yes", "No")

Question4 <- tabPanel(
  "Question 4",
  titlePanel(strong("Does Police Involvement in School Shootings Change Across Income Levels?")),
  p("Graph of police involvement across income levels"),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "Police", label = h3("Were Police Present?"), choices = officer_present, selected = "No"),
      sliderInput(inputId = "Income", label = h3("Income Level"), min = 39.9, max = 234.5, value = c(50.0, 150.0)),
    ),
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Police Involvement by Income", 
                           titlePanel(
                             strong("Percentage of Police Involvement in School Shootings Across Income Levels")),
                           plotOutput("Question4"), textOutput("plotdescription"))
      )
    )
  )
)
Luka_ui <- navbarPage(
  Question4
)

Luka_server <- function(input, output) {
  
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
  
}

shinyApp(ui = Luka_ui, server = Luka_server)
