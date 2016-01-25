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
             sidebarLayout(
               sidebarPanel(
                 selectInput("gameOption", "Choose an option:", 
                             choices = c("Total Points / Team", "Game Closeness Ranking"),
                             selected = "Total Points / Team"),
                 
                 helpText("Total Points / Team: Compare total amount of expected points",
                          "on the full dataset."),
                 helpText("Game Closeness Ranking: Compare which game will be closer.",
                          "How is this calculated? (New window link)")
               ),
               
               # Show a summary of the dataset and an HTML table with the
               # requested number of observations. Note the use of the h4
               # function to provide an additional header above each output
               # section.
               mainPanel(
                 h4("Predicted results"),
                 div(DT::dataTableOutput("summary"), style = "font-size:80%"),
                 
                 #Should change depending on the selected option
                 h4("Total Points / Team"),
                 rCharts::showOutput("games1","nvd3") 
               )
             )
      )
))