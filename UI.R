#*****Libraries*****
library(shinyjs)
#****Requires*******
require(rCharts)
#****Sources********
#Nothing yet.

options(RCHART_LIB = 'polycharts')

shinyUI(

  fluidPage(
    shinyjs::useShinyjs(),
    shinyjs::extendShinyjs(text = "shinyjs.refresh = function() { location.reload(); }"),
    list(tags$head(HTML('<link rel="icon", href="MyIcon.png",
                        type="image/png" />'))),
    div(style="padding: 0px 0px; width: '100%'",
        titlePanel(
          title="", windowTitle="NBA FantaViz"
        )
    ),


  navbarPage(title = div(img(src="resources/nba-fantaviz.png", width=82, heigth = 35),"NBA FantaViz"),
      #********* INPUT TAB****************
      tabPanel("Input",
               sidebarLayout(
                 sidebarPanel(
                   fileInput('file1', 'Upload players file',
                             accept = c(
                               'text/csv',
                               'text/comma-separated-values',
                               'text/tab-separated-values',
                               'text/plain',
                               '.csv',
                               '.tsv'
                             )
                   ),
                   fileInput('file2', 'Upload gameday file',
                             accept = c(
                               'text/csv',
                               'text/comma-separated-values',
                               'text/tab-separated-values',
                               'text/plain',
                               '.csv',
                               '.tsv'
                             )
                   ),
                   tags$hr(),
                   checkboxInput('header', 'Header', TRUE),
                   radioButtons('sep', 'Separator',
                                c(Comma=',',
                                  Semicolon=';',
                                  Tab='\t'),
                                ','),
                   radioButtons('quote', 'Quote',
                                c(None='',
                                  'Double Quote'='"',
                                  'Single Quote'="'"),
                                '"'),
                   tags$hr(),

                   p('You can use the templates for players and games:',
                    a(href = 'resources/playersTemplate.csv', 'playersTemplate.csv'), ',',
                    a(href = 'resources/gamedayTemplate.csv', 'gamedayTemplate.csv')),



                   tags$hr(),
                   actionButton("reset", "Reload Demo Data")
                 ),
                 mainPanel(
                  helpText("Here you can see the data loaded into the application."),
                   tabsetPanel(
                     tabPanel("players",
                      tableOutput('contents1')),
                     tabPanel("gameday",
                              tableOutput('contents2'))
                   )
                 )
               )
   ),
   #********* PLAYERS TAB ****************
   tabPanel("Players",
            fluidPage(
              fluidRow(column(width=4,
                              
                              h3("Attributes"),
                              helpText("Choose the attributes on how you want to compare the players."),

                              #          selectInput("day",
                              #                      label = "Choose a game day",
                              #                      choices = c("Points", "Points/Salary"),
                              #                      selected = "Points"),
                              radioButtons("player_attr",
                                           label = "Choose an attribute",
                                           choices = c("Points", "Points/Salary","Points/Minute"),
                                           selected = "Points",
                                           inline = T)
                             
                        ),


                       column(width=4,
                              h3("Filters"),
                              uiOutput("salary_filter"),br(),
                              helpText("You can select which projections are being displayed by clicking on the points."),
                              div(img(src="resources/graph_help.png", width=150, height = 30))

                       ),

                       column(width=4,
                         br(),br(),br(),
#                        selectInput("sorting",
#                                    label="Sorty by",
#                                    choices = c("Projected","Floor","Ceiling"),
#                                    selected = "Projected"
#                                    ),
                        uiOutput("choose_team"),
                        helpText("Hint: you can deselect several teams by clicking on one and clicking on another while holding shift.")
               
                         ),
              fluidRow(
               ),
              fluidRow(tags$hr(),
                       helpText("Note: Names of the players will apear when less than 50 are displayed or when hovering the mouse over the bar",align="center"),
                       br(),br(),
                       br()),
              fluidRow(column(12,

                       rCharts::showOutput("chart1","nvd3")
                  )
                )
              )
              #,
              #   fluidRow(
              #     column(7,
              #            DT::dataTableOutput('tab1')
              #     )
              #   )
            )),

    #********* GAMES TAB ****************
    tabPanel("Games",
             fluidPage(
               fluidRow(
                 h3("Daily Information", align="center"),
                 div(DT::dataTableOutput("summary"), style = "font-size:90%")
               ),

               fluidRow(
                 br(),br(), br(),br(),

                 h3("Teams Over/Under compared to Median", align="center"),
                 helpText("The average points scored by a team in a game is 101. This plot shows the difference against that median", align="center"),

                 rCharts::showOutput("games1","nvd3")
               ),

               fluidRow(
                 h3("Closeness Ranking vs Total Points ", align="center"),
                 helpText("This plot shows total expected points in a game against how close a game is expected to be", align="center"),
                 rCharts::showOutput("games2","nvd3")
               )
            )
      ),
      #********* About TAB ****************
      tabPanel("About",
         fluidPage()
      )
)))
