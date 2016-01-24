#*****Libraries*****
#Nothing yet.
#****Requires*******
require(rCharts)
#****Sources********
#Nothing yet.

options(RCHART_LIB = 'polycharts')

shinyUI(navbarPage("NBA FantaViz",       
      tabPanel("Input",
              sidebarLayout(
                  sidebarPanel(
                      fileInput('file1', 'Choose players file to upload',
                          accept = c(
                           'text/csv',
                           'text/comma-separated-values',
                            '.csv'
                          )
                      ),
                       #For second file create second fileInput
                       #fileInput('file2', 'Choose games file to upload',
                       #          accept = c(
                       #            'text/csv',
                       #            'text/comma-separated-values',
                       #            '.csv'
                       #          )
                       #),
                        p('You can use the templates for players and games:',
                         a(href = 'https://drive.google.com/file/d/0BynAfCMCfe3wOFRIcjVibl9oaHc/view?usp=sharing', 'playersTemplate.csv'), ',',
                          a(href = 'https://drive.google.com/file/d/0BynAfCMCfe3waGxDaUNrTFFvcUE/view?usp=sharing', 'gamedayTemplate.csv')
                        )
                   ),
                   mainPanel(
                         tableOutput('contents')
                   )
              )
   ),
   
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