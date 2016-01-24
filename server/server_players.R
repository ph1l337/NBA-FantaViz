output$chart1 <- renderChart({
    if(input$var=="Points"){
    p1 <- nPlot(Points ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart")
    p1$addParams(height = 800, dom = 'chart1',
                 title = "players")
    }

    if(input$var=="Points/Salary"){
    p1 <- nPlot(Points.Salary ~ Name, group = 'Type', data = players_barplot, type = "multiBarHorizontalChart", stacked=TRUE)
    p1$addParams(height = 800, dom = 'chart1',
                   title = "players")
    }

    p1$chart(stacked = TRUE,margin = list(left=200))
    p1$xAxis(width = 300)
    return(p1)

  })
  output$tab1 <- DT::renderDataTable({
    players.tableData <- data.frame(players$Name,players$Position,players$Salary)
    DT::datatable(players.tableData,options =list(paging = FALSE))
  })
