library(shiny)
library(dplyr)
require(rCharts)
options(RCHART_WIDTH = 1000)
shinyServer(function(input, output) {
  players <- read.csv("data/players.csv", sep = ";")
  players_barplot <- read.csv("~/Google Drive/Master/Big Data/Assignments/3_Shiny/NBA-FantaViz/data/players_barplot.csv", sep=";")
#   output$chart1 <- renderChart({
#     YEAR = input$year
#     men <- subset(dat2m, gender == "Men" & year == YEAR)
#     women <- subset(dat2m, gender == "Women" & year == YEAR)
#     p1 <- rPlot(x = list(var = "countrycode", sort = "value"), y = "value", 
#                 color = 'gender', data = women, type = 'bar')
#     p1$layer(x = "countrycode", y = "value", color = 'gender', 
#              data = men, type = 'point', size = list(const = 3))
#     p1$addParams(height = 900, dom = 'chart1', 
#                  title = "Percentage of Employed who are Senior Managers")
#     p1$guides(x = list(title = "", ticks = unique(men$countrycode)))
#     p1$guides(y = list(title = "", max = 18))
#     return(p1)
#   })
  
  output$chart1 <- renderChart({
    if(input$var=="Points"){
    p1 <- nPlot(Points ~ Name, group = 'Type', data = players_barplot, type = "multiBarChart")
    p1$addParams(height = 800, dom = 'chart1', 
                 title = "players")
    }
    
    if(input$var=="Points/Salary"){
    p1 <- nPlot(Points.Salary ~ Name, group = 'Type', data = players_barplot, type = "multiBarChart", stacked=TRUE)
    p1$addParams(height = 800, dom = 'chart1', 
                   title = "players")
    }
    
    p1$chart(stacked = TRUE)
    return(p1)
    
  })
  output$tab1 <- DT::renderDataTable({
    players.tableData <- data.frame(players$Name,players$Position,players$Salary)
    DT::datatable(players.tableData,options =list(paging = FALSE))
  })
  })

data