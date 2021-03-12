library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)

Introduction <- tabItem(
  tabName = "intro",
  fluidPage(
    # setBackgroundImage(
    #   src = "https://cdn.wallpapersafari.com/29/17/EcC9kU.jpg",
    #   shinydashboard = TRUE
    # ),
    titlePanel(h1(strong("Intro"))),
    sidebarLayout(position = "right",
                  sidebarPanel(
                    h2("Datasets"),
                    h4(tags$a(href="https://www.chds.us/ssdb/data-map/", 
                              "K-12 School Shooting comprehensive list")),
                    h4(tags$a(href="https://www.census.gov/data/datasets/2017/demo/saipe/2017-school-districts.html", 
                              "% of Students Living in Proverty by School District in 2017-2018 School Year")),
                    h4(tags$a(href="https://github.com/washingtonpost/data-school-shootings/blob/master/school-shootings-data.csv", 
                              "School Shooting Data from Washington Post")),
                    h4(tags$a(href="https://www.ers.usda.gov/data-products/county-level-data-sets/download-data/", 
                              "Median household income and Unemployment for US, States, and Counties"))
                  ),
                  mainPanel(
                    h2(strong("Problem Domain")),
                    h4("Our proposal seeks to investigate the relationship between income and school shootings. 
           Our group has defined a school shooting as \"any time a gun goes off in an academic setting.\" 
           The database we have selected is the only comprehensive list of all school shootings in America.
           The definition of a school shooting is abstract and the Center for Homeland Defense and Security 
           acknowledges the limitations of their list, disclosing the ambiguity of a school shooting requires 
           a compassionate mindset to take in myriad variables. Casting a \"wide net\" to catch as many 
           incidents as possible. The phenomena recorded in each incident are diverse, including \"Bullying,\"
           \"Illegal Activity,\" \"Indiscriminate/Targeted\". Moreover, each incident has a reliability score that 
           is found by assessing the credibility of the source."),
                    br(),
                    h4("The other data set we gathered as a proxy to the 
           wealth of each school is a comprehensive list of the proportion of students who live below the 
           poverty line in each public school district. The data set is from the federal census bureau. 
           A 2017 mapping survey was carried out and is consistent with the population and income estimates 
           from the American Community Survey, a survey that gathers information on ancestry, educational 
           attainment, and income."),
                    br(),
                    h4("Although our group's intention is to merely summarize and consolidate 
           wealth and school shooting incidents, we are interested in whether there are any differences 
           in motivation, weapon, or legal ramifications."),
                    br(),
                    h4("Income inequality and mass shootings in the United States"),
                    h4(tags$a(href="https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-019-7490-x", 
                              "https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-019-7490-x")),
                    br(),
                    h4("Income Inequality, Household Income, and Mass Shooting in the United States"),
                    h4(tags$a(href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6199901/", 
                              "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6199901/"))
                  )
    )
  )
)

Question2DemoTab <- tabItem(
  tabName = "Casualties",
  fluidPage(
    titlePanel("Casualties in Regard to Income"),
    sidebarLayout(
      sidebarPanel(
        textInput(inputId = "state2", label = "What state would you like to view? (Default is all)"),
        sliderInput("years2", label = h3("What years would you like to view?"), min = 1970, 
                    max = 2021, value = c(1980, 2000)),
        checkboxInput("incomeGradient", label = "Income Gradient", value = TRUE)
      ),
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Plot", shinycssloaders::withSpinner(plotlyOutput("question2", height = "600px", width = "800px"))),
                    tabPanel("Details", h4("This map shows plots the income of the general counties against the school 
                    shootings that have occured there. A darker map color represents a county with
                    a higher average income. The lighter a county the lower the average income. The
                    shootings are interactive displaying details with just a hover. Additionally
                    the bigger the green circle representing each shooting, the more casualties the
                    shooting had."))
        )
      )
    )
  )
)

sideBar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Introduction", tabName = "intro"),
    menuItem("Casualties by Income", tabName = "Casualties"),
    menuItem("Occurences at each School Level", tabName = "")
  )
)

body <- dashboardBody(
  tabItems(
    Introduction,
    Question2DemoTab
  )
)

my_ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "School Shootings"),
  sideBar,
  body
)