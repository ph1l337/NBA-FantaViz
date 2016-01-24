#*****Libraries******
library(shiny)
library(dplyr)
#****Requires*******
require(rCharts)
#****Sources********
#Nothing yet.


options(RCHART_WIDTH = 700)
#source("helpers.R")
players <- read.csv("data/players.csv", sep = ";")
players_barplot <- read.csv("data/players_barplot.csv", sep=";")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
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
  output$tab1 <- DT::renderDataTable({
    players.tableData <- data.frame(players$Name,players$Position,players$Salary)
    DT::datatable(players.tableData,options =list(paging = FALSE))
  })
  })
