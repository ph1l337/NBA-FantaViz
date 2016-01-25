#*****Libraries******
library(shiny)
library(dplyr)
#****Requires*******
require(rCharts)
#****Sources********
#Nothing yet.

#***Related to File upload Tab.
options(shiny.maxRequestSize = 9*1024^2) #File Upload Max Size (9MB now)

#***Related to Players Tab
#options(RCHART_WIDTH = 700)

#Will be connected later with FileUpload
gameday <- read.csv("data/gameday.csv")
totalPoints_Game <- read.csv("data/gamedayProcessed1.csv") 
gameCR <- read.csv("data/gamedayProcessed1.csv") 
players <- read.csv("data/players.csv", sep = ";")
players_barplot <- read.csv("data/players_barplot.csv", sep=";")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #***********Server side for players tab.*************
  output$chart1 <- renderChart({
    if(input$var=="Points"){
     p1 <- nPlot(Points ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart")
     p1$yAxis(axisLabel = "Points")
    }
    
    if(input$var=="Points/Salary"){
     p1 <- nPlot(Points.Salary ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart")
     p1$yAxis(axisLabel = "Points/Salary * 10000")
    }
    
    p1$addParams(height = 1000, dom = 'chart1', title = "players")
    p1$chart(stacked = TRUE,margin = list(left=150, right = 70, bottom = 100), color = c('#ffb729','#ff353e','#519399'))
    p1$xAxis(width = 300)
    
    return(p1)
    
  })
  #Maybe We should change the tap1 name, this is not tab1 anymore. 
  #I think naming according to use might be better (players, games or file uploader)
  output$tab1 <- DT::renderDataTable({
    players.tableData <- data.frame(players$Name,players$Position,players$Salary)
    DT::datatable(players.tableData,options =list(paging = FALSE))
  })
  
  #**********Server side for file upload tab.*********
  output$contents <- renderTable({
    inFile <- input$file1
    #inFile2 <- input$file2
    
    if (is.null(inFile))
      return(NULL)
    
    #read.csv(inFile$datapath, header = input$header,
    #         sep = input$sep, quote = input$quote)
    read.csv(inFile$datapath)
  })
  
  #********* Server side for games ******************
  datasetInput <- reactive({
    switch(input$gameOption,
           "Total Points / Team" = totalPoints_Game,
           "Game Closeness Ranking" = gameCR)
  })
  
  # Generate a summary of the dataset
  output$summary <- DT::renderDataTable(
    DT::datatable(gameday, options = list(paging = FALSE, searching=FALSE, autoWidth = TRUE,
                                          columnDefs = list(list(width = '60px', targets = "_all"))))
  )
    
  #output$summary <- renderDataTable({
  #  dataset <- datasetInput()
  #  })
  # Show the first "n" observations set to 20 default
  #output$view <- renderTable({
  #  head(datasetInput(), n = 20)
 
  
    output$games1 <- renderChart({ 
  
      p2 <- nPlot(Points ~ Team, data = totalPoints_Game, type = "multiBarChart")
      p2$yAxis(axisLabel = "Points")
      p2$xAxis(axisLabel = "Teams")
      p2$addParams(height = 300, dom = 'games1', title = "games" )
      p2$chart(showControls=FALSE, margin = list(left=100, right = 70, bottom = 100))
      #options(RCHART_WIDTH = 400)
      return(p2)
      
  })
})
