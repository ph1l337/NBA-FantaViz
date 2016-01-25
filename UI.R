#*****Libraries*****
#Nothing yet.
#****Requires*******
require(rCharts)
#****Sources********
#Nothing yet.

options(RCHART_LIB = 'polycharts')

shinyUI(navbarPage("NBA FantaViz", 
      #********* INPUT TAB****************
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
                         a(href = 'resources/playersTemplate.csv', 'playersTemplate.csv'), ',',
                          a(href = 'resources/gamedayTemplate.csv', 'gamedayTemplate.csv')
                        )
                   ),
                   mainPanel(
                         tableOutput('contents')
                   )
              )
   ),
   #********* PLAYERS TAB ****************
   tabPanel("Players",
            sidebarLayout(
              sidebarPanel(
                        helpText("Choose, whether you want to look at the absolute point or the points related to their salary."),
                        
                       #          selectInput("day",
                       #                      label = "Choose a game day",
                       #                      choices = c("Points", "Points/Salary"),
                       #                      selected = "Points"),
                       selectInput("var",
                                   label = "Choose a variable",
                                   choices = c("Points", "Points/Salary"),
                                   selected = "Points"),
#                        selectInput("sorting",
#                                    label="Sorty by",
#                                    choices = c("Projected","Floor","Ceiling"),
#                                    selected = "Projected"
#                                    ),
                       
                       sliderInput("salary", "Salary:",
                                   min = 15000, max = 55000, value = c(0,100000))
                       ),
              
                      
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
   
    #********* GAMES TAB ****************
    tabPanel("Games",
             fluidPage(
               mainPanel(
                 h4("Daily Information"),
                 div(DT::dataTableOutput("summary"), style = "font-size:90%"),
                 
                 h4("Teams Over/Under media"),
                 rCharts::showOutput("games1","nvd3"), 
                 
                 h4("Closeness Ranking vs Total Points "),
                 rCharts::showOutput("games2","nvd3") 
               )
             )
      ),
      #********* About TAB ****************
      tabPanel("About",
         fluidPage()
      )
))