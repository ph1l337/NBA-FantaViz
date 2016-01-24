#*****Libraries*****
#Nothing yet.
#****Requires*******
require(rCharts)
#****Sources********
#Nothing yet.

options(RCHART_LIB = 'polycharts')

shinyUI(navbarPage("NBA FantaViz",
   tabPanel("Players",
            sidebarLayout(
              sidebarPanel(
                
                       
                       #          selectInput("day",
                       #                      label = "Choose a game day",
                       #                      choices = c("Points", "Points/Salary"),
                       #                      selected = "Points"),
                       selectInput("var",
                                   label = "Choose a variable",
                                   choices = c("Points", "Points/Salary"),
                                   selected = "Points")),
                mainPanel(
                       rCharts::showOutput("chart1","nvd3")
                )
              )
              #,
              #   fluidRow(
              #     column(7,
              #            DT::dataTableOutput('tab1')
              #     )
              #   )
            ),
            
   
    tabPanel("Games",
             fluidRow()
             
      )
))