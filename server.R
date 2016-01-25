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
options(RCHART_WIDTH = 700)

#Will be connected later with FileUpload
gameday <- read.csv("data/gameday.csv",sep=",")
totalPoints_Game <- read.csv("data/gameday.csv",sep=";") 
gameCR <- read.csv("data/gameday.csv",sep=";")
players <- read.csv("data/players.csv", sep = ";")
players_barplot <- read.csv("data/players_barplot.csv", sep=";")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #***********Server side for players tab.*************
  output$chart1 <- renderChart({
    if(input$var=="Points"){
     p1 <- nPlot(Points ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart")
    }
    
    if(input$var=="Points/Salary"){
     p1 <- nPlot(Points.Salary ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart", stacked=TRUE)
    
    }
    p1$addParams(height = 800, dom = 'chart1', title = "players")
    p1$chart(stacked = TRUE,margin = list(left=150, right = 70), color = c('#ffb729','#ff353e','#519399'))
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
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })
  
  # Show the first "n" observations set to 20 default
  output$view <- renderTable({
    head(datasetInput(), n = 20)
  })
})
