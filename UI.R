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
                         a(href = 'https://drive.google.com/file/d/0BynAfCMCfe3wOFRIcjVibl9oaHc/view?usp=sharing', 'playersTemplate.csv'), ',',
                          a(href = 'https://drive.google.com/file/d/0BynAfCMCfe3waGxDaUNrTFFvcUE/view?usp=sharing', 'gamedayTemplate.csv')
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
   
    #********* GAMES TAB ****************
    tabPanel("Games",
             sidebarLayout(
               sidebarPanel(
                 selectInput("dataset", "Choose an option:", 
                             choices = c("Total Points / Team", "Game Closeness Ranking"),
                             selected = "Total Points / Team"),
                 
                 helpText("Total Points / Team: Compare total amount of expected points",
                          "on the full dataset."),
                 helpText("Game Closeness Ranking: Compare which game will be closer.",
                          "How is this calculated? (New window link)"), #ADD LINK TO SMALL WINDOW
                 
                 submitButton("Update View")
               ),
               
               # Show a summary of the dataset and an HTML table with the
               # requested number of observations. Note the use of the h4
               # function to provide an additional header above each output
               # section.
               mainPanel(
                 h4("Summary"),
                 verbatimTextOutput("summary"),
                 
                 #Should change depending on the selected option
                 h4("Total Points / Team"),
                 tableOutput("view")
               )
             )
      )
))