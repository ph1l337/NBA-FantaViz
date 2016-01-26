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
            fluidPage(
              fluidRow(column(width=4,
                              h3("Introduction"),
                              helpText("Blaa")),
                       column(width=4,
                        h3("Attributes"),
                        helpText("Choose the attributes on how you want to compare the players"),
                        
                       #          selectInput("day",
                       #                      label = "Choose a game day",
                       #                      choices = c("Points", "Points/Salary"),
                       #                      selected = "Points"),
                       selectInput("player_attr",
                                   label = "Choose a variable",
                                   choices = c("Points", "Points/Salary"),
                                   selected = "Points")
                       ),
                       column(width=4,
                         h3("Filter"),
#                        selectInput("sorting",
#                                    label="Sorty by",
#                                    choices = c("Projected","Floor","Ceiling"),
#                                    selected = "Projected"
#                                    ),
                       
                        sliderInput("salary", "Salary:",
                                   min = 0, max = 15000, value = c(0,15000)),
                        uiOutput("choose_team")
                         ),
                        column(width=4)),
              fluidRow(
                br(),br(),br(),
                helpText("Note: Names of the players will apear when less than 50 are displayed or when hovering the mouse over the bar",align="center"),
                br(),br(),br(),br(),br()),
              fluidRow(
              
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
               fluidRow(
                 h3("Daily Information", align="center"),
                 div(DT::dataTableOutput("summary"), style = "font-size:90%")
               ),
               
               fluidRow(
                 h3("Teams Over/Under media", align="center"),
                 rCharts::showOutput("games1","nvd3") 
               ),
               
               fluidRow(
                 h3("Closeness Ranking vs Total Points ", align="center"),
                 rCharts::showOutput("games2","nvd3") 
               )
            )
      ),
      #********* About TAB ****************
      tabPanel("About",
         fluidPage()
      )
))