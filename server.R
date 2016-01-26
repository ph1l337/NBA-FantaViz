#*****Libraries******
library(shiny)
library(dplyr)
library(data.table)
library(shinyjs)
#****Requires*******
require(rCharts)
#****Sources********
source("generalUtils.r", local=TRUE)
#Nothing yet.

#***Related to File upload Tab.
options(shiny.maxRequestSize = 9*1024^2) #File Upload Max Size (9MB now)

#***Related to Players Tab
options(RCHART_WIDTH = 800)

#Will be connected later with FileUpload

gameday <- dplyr::tbl_df(data.table(read.csv("data/gameday.csv",stringsAsFactors=FALSE))) #Original gameday dataset submitted.
#gameday101 <- read.csv("data/gameday101.csv")  #Processed, used for 101 graph.
#gamedayTableZone <- read.csv("data/gamedayTable.csv") #Processed used for Scatterplot.

players <- dplyr::tbl_df(data.table(read.csv("data/players.csv",stringsAsFactors=FALSE)))


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

  #creating data.frame for gamedayTable
  gamedayTable<-dplyr::tbl_df(data.table(data.frame(Away = character(),
                                                       Home = character(),
                                                       Away.Score = double(),
                                                       Home.Score = double(),
                                                       stringsAsFactors=FALSE
                              )))

  #creating data.frame for gamedayTableZone
  gamedayTableZone<-dplyr::tbl_df(data.table(data.frame(Away = character(),
                                                    Home = character(),
                                                    Away.Score = double(),
                                                    Home.Score = double(),
                                                    Total.Points=double(),
                                                    Difference=double(),
                                                    Game.Ranking=double(),
                                                    stringsAsFactors=FALSE
  )))
  
  #creating data.frame for gameday101
  gameday101<-dplyr::tbl_df(data.table(data.frame(Team = character(),
                                                  Score = double(),
                                                  stringsAsFactors=FALSE
  )))

  #Processing players dataset
for(i in 1:nrow(players)){
  players_barplot[(i*3)-2,] <- c(players$Position[i],players$Name[i],players$Salary[i],players$Team[i],players$vsTeam[i],players$Minutes.Average[i],"Floor",players$Floor.Points[i])
  players_barplot[(i*3)-1,] <- c(players$Position[i],players$Name[i],players$Salary[i],players$Team[i],players$vsTeam[i],players$Minutes.Average[i],"Projected",players$Projected.Points[i])
  players_barplot[(i*3),] <- c(players$Position[i],players$Name[i],players$Salary[i],players$Team[i],players$vsTeam[i],players$Minutes.Average[i],"Ceiling",players$Ceiling.Points[i])
}
players_barplot$Points <- as.numeric(players_barplot$Points)
players_barplot$Minutes.Average <- as.numeric(players_barplot$Minutes.Average)
players_barplot$Salary<- as.numeric(players_barplot$Salary)

players_barplot <- transform(players_barplot, Points.Salary = (Points/Salary)*1000)
players_barplot <- transform(players_barplot, Points.Minute = (Points/Minutes.Average))

#Processing gamedayTable 
for(i in 1:nrow(gameday)){
  gamedayTable[i,] <- c(gameday$Away[i],gameday$Home[i],gameday$Away.Score[i],gameday$Home.Score[i])
}

gamedayTable$Away.Score <- as.numeric(gamedayTable$Away.Score)
gamedayTable$Home.Score <- as.numeric(gamedayTable$Home.Score)


gamedayTable <- transform(gamedayTable, Total.Points = (Home.Score+Away.Score))
gamedayTable <- transform(gamedayTable, Difference = abs((Home.Score-Away.Score)))
gamedayTable <- transform(gamedayTable, Game.Ranking = gameRanking(Home.Score,Away.Score))

#Processing gamedayTableZone
for(i in 1:nrow(gameday)){
  gamedayTableZone[i,] <- c(gamedayTable$Away[i],gamedayTable$Home[i],gamedayTable$Away.Score[i],gamedayTable$Home.Score[i],gamedayTable$Total.Points[i],
                            gamedayTable$Difference[i], gamedayTable$Game.Ranking[i])
}

GameZ <<- "Cold"
Game.Zone.Column = sapply(gamedayTable$Game.Ranking, function(x) {
  if(x<2) GameZ = "Very Cold"
  if(x>8) GameZ = "Very Hot"
  if(x<8 && x>7) GameZ = "Hot"
  if(x<7 && x>4) GameZ = "Medium"
  if(x<5 && x>2) GameZ = "Cold"
  return(GameZ)
})
gamedayTableZone["Game.Zone"] <- Game.Zone.Column

#Processing gameday101
for(i in 1:nrow(gameday)){
  gameday101[(i*2)-1,] <- c(gameday$Away[i], gameday$Away.Score[i])
  gameday101[(i*2),] <- c(gameday$Home[i], gameday$Home.Score[i])
}
gameday101$Score <- as.numeric(gameday101$Score)

gameday101<- transform(gameday101, Points = (Score-101))

GameQ <<- "Low Score"
Game.Quantity.Column = sapply(gameday101$Points, function(x) {
  if(x < 4 && x > -4) GameQ = "Average Score"
  if(x > 3) GameQ = "High Score"
  if(x < -3) GameQ = "Low Score"
  return(GameQ)
})
gameday101["Game.Quantity"] <- Game.Quantity.Column

  #********SERVER FUNCTION ************
  shinyServer(function(input,output){


  #***********Dynamic UI elements*************
  output$choose_team <- renderUI({
    # teams <- c("ALL")
    teams <- unique(players_barplot$Team)
    selectizeInput("choose_team", "Filter by Teams: \n", choices = teams, selected = teams, multiple = TRUE)
  })

  output$salary_filter <- renderUI({
    sliderInput("salary", "Filter by Salary:",
                min = min(players_barplot$Salary), max = max(players_barplot$Salary), value = c(min(players_barplot$Salary),max(players_barplot$Salary)))
  })


  #**********Server side for file upload tab.*********
  output$contents1 <- renderTable({
    inFile <- input$file1
    #inFile2 <- input$file2

    if (is.null(inFile))
      return(players)


    players <- read.csv(inFile$datapath, header = input$header,
            sep = input$sep, quote = input$quote, stringsAsFactors=FALSE)
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
    players_barplot <- transform(players_barplot, Points.Minute = (Points/Minutes.Average))
    players_barplot <<- players_barplot
    players <<- players

    players
    shinyjs::js$refresh()



  })


  output$contents2 <- renderTable({
    inFile <- input$file2
    #inFile2 <- input$file2

    if (is.null(inFile))
      return(gameday)

    gameday <- read.csv(inFile$datapath, header = input$header,
                        sep = input$sep, quote = input$quote, stringsAsFactors=FALSE)


    ###put transformations here and use <<- to assign to vars outside of function.
    ###Also add the transforamtions in the begginnig, with the demo data.

    gameday <<- gameday

    gameday
    shinyjs::js$refresh()

  })


  #*************Reload Demo Data ************#

  observeEvent(input$reset,{
    # gameday <<- read.csv("data/gamedayOption2.csv")
    gamedayTable <<- read.csv("data/gamedayTable.csv")
    gameday101 <<- read.csv("data/gameday101.csv")
    gamedayTableZone <<- read.csv("data/gamedayTableZone.csv")
    players <<- dplyr::tbl_df(data.table(read.csv("data/players.csv",stringsAsFactors=FALSE)))
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
    players_barplot <- transform(players_barplot, Points.Minute = (Points/Minutes.Average))

    players_barplot <<- players_barplot

    shinyjs::js$refresh()

  })


  #***********Server side for players tab.*************
  output$chart1 <- renderChart({

    players.toPlot <- dplyr::filter(players_barplot, (Salary >= input$salary[1]) , (Salary <= input$salary[2]))
    players.toPlot <- dplyr::filter(players.toPlot, (Team %in% input$choose_team))


#     players.toPlot <- dplyr::arrange(players.toPlot, Points)

    if(input$player_attr=="Points"){
     p1 <- nPlot(Points ~ Name, group = 'Points.Type', data = players.toPlot, type = "multiBarChart")
     p1$yAxis(axisLabel = "Points")

    }

    if(input$player_attr=="Points/Salary"){
     p1 <- nPlot(Points.Salary ~ Name, group = 'Points.Type', data = players.toPlot, type = "multiBarChart")
     p1$yAxis(axisLabel = "Points/Salary * 1000")

    }

    if(input$player_attr=="Points/Minute"){
      p1 <- nPlot(Points.Salary ~ Name, group = 'Points.Type', data = players.toPlot, type = "multiBarChart")
      p1$yAxis(axisLabel = "Points/Minute")
    }



    p1$addParams(height = 600, width = 1200, dom = 'chart1', title = "players")
    p1$chart(stacked = TRUE,margin = list(left=100, right = 70, bottom = 150), color = c('#ff353e','#ffb729','#519399'))
    # p1$xAxis(width = 150)
    p1$chart(reduceXTicks = FALSE,rotateLabels=-45)
    p1$chart(tooltipContent = "#! function(key, val, e, graph){
                return '<h4>' + '<font color=black>'+ val +'</font>'+ '</h4>' + '<p>'+ key + ': ' + '<b>' + e + '</b>' } !#")
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



  #********* Server side for games ******************
  # Table View
  output$summary <- DT::renderDataTable(
    DT::datatable(gamedayTable, options = list(dom='t', autoWidth = TRUE,
                                          columnDefs = list(list(width = '80px', targets = "_all"))))
  )

  # 101 View
  output$games1 <- renderChart({
    gameday101$Game.Quantity <- factor(gameday101$Game.Quantity, levels = c("Low Score", "Average Score", "High Score"), ordered = TRUE) # re-order the factors
    gameday101 <- gameday101[order(gameday101$Game.Quantity), ] # re-order the variables

      p2 <- nPlot(Points ~ Team, data = gameday101, group='Game.Quantity', type = 'multiBarChart')
      p2$yAxis(axisLabel = "Points")
      p2$xAxis(axisLabel = "Teams")
      p2$addParams(height = 600, width = 1200, dom = 'games1', title = "games" )
      p2$chart(showControls=FALSE, margin = list(left=300, right = 270, bottom = 150, top = 150))
      p2$chart(color = c('#5882FA', '#F7BE81', '#FF0000'))
      p2$chart(reduceXTicks = FALSE)
      p2$xAxis(staggerLabels = TRUE)

      #options(RCHART_WIDTH = 400)
      return(p2)

  })


  # Closeness View
  output$games2 <- renderChart2({
    gamedayTableZone$Game.Zone <- factor(gamedayTableZone$Game.Zone, levels = c("Very Cold", "Cold", "Medium", "Hot", "Very Hot"), ordered = TRUE) # re-order the factors
    gamedayTableZone <- gamedayTableZone[order(gamedayTableZone$Game.Zone), ] # re-order the variables

    p2 <- nPlot(Total.Points ~ Difference, data = gamedayTableZone, group='Game.Zone',type = 'scatterChart')
    p2$yAxis(axisLabel = "Total Points")
    p2$xAxis(axisLabel = "Point Difference")
    #p2$chart(size = '#! function(d){return d.Game.Ranking} !#')
    p2$chart(sizeRange = c(300,300))
    p2$chart(showControls=FALSE, margin = list(left=300, right = 270, bottom = 150, top = 150))
    p2$chart( xDomain = sort(range(gamedayTableZone$Difference),decreasing=T) )
    p2$chart(color = c('#0404B4', '#5882FA', '#F7BE81', '#FF8000', '#FF0000'))
    p2$set(height = 600, width = 1200)
    #p2$addParams(height = 300, dom = 'games1', title = "games" )
    #p2$chart(showControls=FALSE, margin = list(left=100, right = 70, bottom = 100))
    #options(RCHART_WIDTH = 400)
    p2$chart(tooltipContent = "#! function(key, x, y, e ){
      var d = e.series.values[e.pointIndex];
      return ' Game: ' + d.Home + ' vs ' + d.Away
      } !#")
    p2$setTemplate(script = sprintf("
      <script type='text/javascript'>
                                    $(document).ready(function(){
                                    draw{{chartId}}()
                                    });
                                    function draw{{chartId}}(){
                                    var opts = {{{ opts }}},
                                    data = {{{ data }}}

                                    if(!(opts.type==='pieChart' || opts.type==='sparklinePlus' || opts.type==='bulletChart')) {
                                    var data = d3.nest()
                                    .key(function(d){
                                    //return opts.group === undefined ? 'main' : d[opts.group]
                                    //instead of main would think a better default is opts.x
                                    return opts.group === undefined ? opts.y : d[opts.group];
                                    })
                                    .entries(data);
                                    }

                                    if (opts.disabled != undefined){
                                    data.map(function(d, i){
                                    d.disabled = opts.disabled[i]
                                    })
                                    }

                                    nv.addGraph(function() {
                                    var chart = nv.models[opts.type]()
                                    .width(opts.width)
                                    .height(opts.height)

                                    if (opts.type != 'bulletChart'){
                                    chart
                                    .x(function(d) { return d[opts.x] })
                                    .y(function(d) { return d[opts.y] })
                                    }


                                    {{{ chart }}}

                                    {{{ xAxis }}}

                                    {{{ x2Axis }}}

                                    {{{ yAxis }}}

                                    d3.select('#' + opts.id)
                                    .append('svg')
                                    .datum(data)
                                    .transition().duration(500)
                                    .call(chart);

                                    nv.utils.windowResize(chart.update);
                                    return chart;
                                    },%s);
                                    };
                                    </script>
                                    "
                                    ,
                                    #here is where you can type your labelling function
                                    "
                                    function(){
                                    //for each circle or point that we have
                                    // add a text label with information
                                    d3.selectAll('.nv-group circle').each(function( ){

                                    d3.select(d3.select(this).node().parentNode).append('text')
                                    .datum( d3.select(this).data() )
                                    .text( function(d) {
                                    //you'll have access to data here so you can
                                    //pick and choose
                                    //as example just join all the info into one line
                                    return Object.keys(d[0]).map(function( key ){
                                    if(key=='Away'){
                                      return( '   ' +  d[0][key] + ' vs ')
                                    }
                                    if(key=='Home'){
                                      return( d[0][key])
                                    }

                                    }).join()
                                    })
                                    .attr('x',d3.select(this).attr('cx'))
                                    .attr('y',d3.select(this).attr('cy'))
                                    .style('pointer-events','none')
                                    })
                                    }
                                    "

    ))

    return(p2)

  })





})
