#*****Libraries******
library(shiny)
library(dplyr)
library(data.table)
#****Requires*******
require(rCharts)
#****Sources********
#Nothing yet.

#***Related to File upload Tab.
options(shiny.maxRequestSize = 9*1024^2) #File Upload Max Size (9MB now)

#***Related to Players Tab
options(RCHART_WIDTH = 700)

#Will be connected later with FileUpload
gameday <- read.csv("data/gamedayOption2.csv")
gamedayTable <- read.csv("data/gamedayTable.csv") 
gameday101 <- read.csv("data/gameday101.csv") 
gamedayCloseness <- read.csv("data/gamedayTable.csv")
players <- dplyr::tbl_df(data.table(read.csv("data/players.csv",stringsAsFactors=FALSE)))
# players_barplot<- read.csv("data/players_barplot.csv", sep=";")


#creating data.frame for barplot
  players_barplot<-dplyr::tbl_df(data.table(data.frame(Position = character(),
                              Name = character(),
                              Salary = integer(),
                              Team = character(),
                              vsTeam = character(),
                              Minutes.Average = double(),
                              Points.Type = character(),
                              Points = double(),
                              stringsAsFactors=FALSE
                              )))

for(i in 1:nrow(players)){
  players_barplot[(i*3)-2,] <- c(players$Position[i],players$Name[i],players$Salary[i],players$Team[i],players$vsTeam[i],players$Minutes.Average[i],"Floor",players$Floor.Points[i])
  players_barplot[(i*3)-1,] <- c(players$Position[i],players$Name[i],players$Salary[i],players$Team[i],players$vsTeam[i],players$Minutes.Average[i],"Projected",players$Projected.Points[i])
  players_barplot[(i*3),] <- c(players$Position[i],players$Name[i],players$Salary[i],players$Team[i],players$vsTeam[i],players$Minutes.Average[i],"Ceiling",players$Ceiling.Points[i])
}
players_barplot$Points <- as.numeric(players_barplot$Points)
players_barplot$Minutes.Average <- as.numeric(players_barplot$Minutes.Average)
players_barplot$Salary<- as.numeric(players_barplot$Salary)

players_barplot <- transform(players_barplot, Points.Salary = (Points/Salary)*10000)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  #***********Server side for players tab.*************
  output$chart1 <- renderChart({
    
    players.toPlot <- dplyr::filter(players_barplot, Salary >= input$salary[1] , (Salary <= input$salary[2]))
#     players.toPlot <- dplyr::arrange(players.toPlot, Points)
    
   
    if(input$var=="Points"){
     p1 <- nPlot(Points ~ Name, group = 'Points.Type', data = players.toPlot, type = "multiBarHorizontalChart")
     p1$yAxis(axisLabel = "Points")
    }
    
    if(input$var=="Points/Salary"){
     p1 <- nPlot(Points.Salary ~ Name, group = 'Points.Type', data = players.toPlot, type = "multiBarHorizontalChart")
     p1$yAxis(axisLabel = "Points/Salary * 10000")
    }
    
    p1$addParams(height = 2000, dom = 'chart1', title = "players")
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
  # Table View
  output$summary <- DT::renderDataTable(
    DT::datatable(gamedayTable, options = list(paging = FALSE, searching=FALSE, autoWidth = TRUE,
                                          columnDefs = list(list(width = '80px', targets = "_all"))))
  )
  
  # 101 View
  output$games1 <- renderChart({ 
      p2 <- nPlot(Points ~ Team, data = gameday101, type = "multiBarChart")
      p2$yAxis(axisLabel = "Points")
      p2$xAxis(axisLabel = "Teams")
      p2$addParams(height = 300, dom = 'games1', title = "games" )
      p2$chart(showControls=FALSE, margin = list(left=100, right = 70, bottom = 0))
      #options(RCHART_WIDTH = 400)
      return(p2)
      
  })
  
  
  # Closeness View
  output$games2 <- renderChart2({ 
    p2 <- nPlot(Points ~ Team, data = gameday101 , type = 'scatterChart') 
    #p2$yAxis(axisLabel = "Points")
    p2$xAxis(axisLabel = "Teams")
    #p2$addParams(height = 300, dom = 'games1', title = "games" )
    #p2$chart(showControls=FALSE, margin = list(left=100, right = 70, bottom = 100))
    #options(RCHART_WIDTH = 400)
    return(p2)
    
  })
  
  
})
