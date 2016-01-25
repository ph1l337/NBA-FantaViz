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
players <- read.csv("data/players.csv", sep = ";")
players_barplot <- read.csv("data/players_barplot.csv", sep=";")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  #Server side for players tab.
  output$chart1 <- renderChart({
    if(input$var=="Points"){
     p1 <- nPlot(Points ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart")
     p1$yAxis(axisLabel = "Points")
    }
    
    if(input$var=="Points/Salary"){
     p1 <- nPlot(Points.Salary ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart")
     p1$yAxis(axisLabel = "Points/Salary * 10000")
    }
    
    p1$addParams(height = 800, dom = 'chart1', title = "players")
    p1$chart(stacked = TRUE,margin = list(left=150, right = 70, bottom = 100), color = c('#ffb729','#ff353e','#519399'))
    p1$xAxis(width = 300)
    
    return(p1)
    
  })
  output$tab1 <- DT::renderDataTable({
    players.tableData <- data.frame(players$Name,players$Position,players$Salary)
    DT::datatable(players.tableData,options =list(paging = FALSE))
  })
  
  #Server side for file upload tab.
  output$contents <- renderTable({
    inFile <- input$file1
    #inFile2 <- input$file2
    
    if (is.null(inFile))
      return(NULL)
    
    #read.csv(inFile$datapath, header = input$header,
    #         sep = input$sep, quote = input$quote)
    read.csv(inFile$datapath)
  })
  
})
