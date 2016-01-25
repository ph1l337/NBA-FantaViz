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
options(RCHART_WIDTH = 800)

#Will be connected later with FileUpload
gameday <- read.csv("data/gamedayOption2.csv")
gamedayTable <- read.csv("data/gamedayTable.csv") 
gameday101 <- read.csv("data/gameday101.csv") 
gamedayTableZone <- read.csv("data/gamedayTableZone.csv") 
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

players_barplot <- transform(players_barplot, Points.Salary = (Points/Salary)*1000)



shinyServer(function(input, output) {
  
  
  #***********Dynamic UI elements*************
  output$choose_team <- renderUI({
    teams <- c("ALL")
    teams <- c(teams,unique(players$Team))
    selectInput("choose_team", "Team:", teams)
  })
  
  
  #***********Server side for players tab.*************
  output$chart1 <- renderChart({
    
    players.toPlot <- dplyr::filter(players_barplot, (Salary >= input$salary[1]) , (Salary <= input$salary[2]))
    if(input$choose_team != "ALL"){
    players.toPlot <- dplyr::filter(players_barplot, (Team == input$choose_team))  
    }
   
#     players.toPlot <- dplyr::arrange(players.toPlot, Points)

    if(input$player_attr=="Points"){
     p1 <- nPlot(Points ~ Name, group = 'Points.Type', data = players.toPlot, type = "multiBarChart")
     p1$yAxis(axisLabel = "Points")
     
    }
    
    if(input$player_attr=="Points/Salary"){
     p1 <- nPlot(Points.Salary ~ Name, group = 'Points.Type', data = players.toPlot, type = "multiBarChart")
     p1$yAxis(axisLabel = "Points/Salary * 1000")
     
    }
    
    p1$addParams(height = 400, width = 1200, dom = 'chart1', title = "players")
    p1$chart(stacked = TRUE,margin = list(left=100, right = 70, bottom = 150), color = c('#ff353e','#ffb729','#519399'))
    p1$xAxis(width = 300)
    p1$chart(reduceXTicks = FALSE,rotateLabels=-45)
   
    # p1$xAxis(staggerLabels = TRUE)
    
    #50
    if(nrow(players.toPlot)/3>55){
      p1$chart(showXAxis=FALSE)
    }
#     if(players.toPlot<=50){
#       p1$chart(showXAxis=TRUE)
#     }
    
#     
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
      p2$chart(reduceXTicks = FALSE)
      p2$xAxis(staggerLabels = TRUE)
      
      #options(RCHART_WIDTH = 400)
      return(p2)
      
  })
  
  
  # Closeness View
  output$games2 <- renderChart2({ 
    gamedayTableZone$Game.Zone <- factor(gamedayTableZone$Game.Zone, levels = c("Very Hot", "Hot", "Medium", "Cold", "Very Cold"), ordered = TRUE) # re-order the factors
    gamedayTableZone <- gamedayTableZone[order(gamedayTableZone$Game.Zone), ] # re-order the variables
    
    p2 <- nPlot(Total.Points ~ Difference, data = gamedayTableZone, group='Game.Zone',type = 'scatterChart') 
    p2$yAxis(axisLabel = "Total Points")
    p2$xAxis(axisLabel = "Point Difference")
    #p2$chart(size = '#! function(d){return d.Game.Ranking} !#')
    p2$chart(sizeRange = c(300,300))
    p2$chart(showControls = FALSE)
    p2$chart( xDomain = sort(range(gamedayTableZone$Difference),decreasing=T) )
    #p2$addParams(height = 300, dom = 'games1', title = "games" )
    #p2$chart(showControls=FALSE, margin = list(left=100, right = 70, bottom = 100))
    #options(RCHART_WIDTH = 400)
    return(p2)
    
  })
  
  
})
