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
                    h4("Note: Income level was calculated from the Medium Household Income as a percentage of the average state income for each county. 
                    The average county had a household income that was 15% below their state average. This alludes to the data being positively skewed. 
                    We chose to use Median Household income as a percentage of state because rent, salary, childcare cost, minimum wage vary from state to state.
Average county income as a percentage of the median overall state income looks at how much a county varies in relation to the state it belongs to. A county with an 
income 86% of the state median income has a median household income 14% below the state's median. This statistic is more easily compared to 
other counties across state lines as you do not need to account for the multitude of variables that indicate prosperity or lack there of. 
Moreover, our group also wanted to look at whether income area affect the magnitude of school shootings. To do this we seperated areas into three balanced income brackets:
low income: counties with median household incomes less than 86.65%  of the state median
middle income: counties with a median household income between 81.65% to 93.05% of the state median
high income: counties with a median income greater than 93.05% of the state median."),
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

Question1_Liza <- tabItem(
  tabName = "Weapon",
  fluidPage(
    titlePanel(strong("Weapon Type")),
    sidebarLayout(
      sidebarPanel(
        radioButtons("weapon",label = "Weapon Type", choices = c("Rifle","Handgun","Shotgun")),
        p("Note: Income level was calculated from the Medium Household Income as a percentage of the average state income for each county. 
        The average county had a household income that was 15% below their state average. This alludes to the data being positively skewed.")
      ),
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Weapon", plotOutput("plot"),
                    p(em("Data is pulled from school shootings since 1970. We found that weapon used is different in each income level. Handguns were the most common weapon used. However,
                    counties with higher income areas were more 12% more likely to use a handgun than a shooter in a lower income area. 
                    In lower income areas, shotguns and rifles were more commonly used than middle or high income areas at 3.9% and 11% 
                    respectively.")),
                    plotOutput("plot2"),
                    p(em("Police forget to record the schooter's weapontype nearly 20% of the time. the difference between missing shooter records between the
                    income levels was not significant")),
                    textOutput("desc1")))
      )
    )
  )
)

Question4 <- tabItem(
  tabName = "Police",
  fluidPage(
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
)

sideBar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Introduction", tabName = "intro"),
    menuItem("Casualties by Income", tabName = "Casualties"),
    menuItem("Weapontype by Income", tabName = "Weapon"),
    menuItem("Police Involvement Across Income", tabName = "Police")
  )
)

body <- dashboardBody(
  tabItems(
    Introduction,
    Question2DemoTab,
    Question1_Liza,
    Question4
  )
)

my_ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "School Shootings"),
  sideBar,
  body
)