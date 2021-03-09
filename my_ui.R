library(shiny)

Question2(Quang) <- tabPanel(
  "Question 2",
  titlePanel(strong("Shootings")),
  p("This map looks at the number of casualties for each shooting mapped over income."),
  sidebarLayout(
    sidebarPanel(
      textInput(inputId = "state2", label = "What state would you like to view? (Default is all)"),
      sliderInput("years2", label = h3("What Years Would you like to view?"), min = 1970, 
                  max = 2021, value = c(1980, 2000)),
      checkboxInput("incomeGradient", label = "Income Gradient", value = TRUE)
    ),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", plotlyOutput("question2"))
      )
    )
  )
)

my_ui <- navbarPage(
  Question2(Quang)
)