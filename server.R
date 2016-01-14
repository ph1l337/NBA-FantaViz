library(shiny)

source("helpers.R")
# players <- 
# game <-

# Define server logic required to draw a histogram
shinyServer(
  function(input, output) {
    output$map <- renderPlot({
      data <- switch(input$var,
                     "Percent White" = counties$white,
                     "Percent Black" = counties$black,
                     "Percent Hispanic" = counties$hispanic,
                     "Percent Asian" = counties$asian)
      title <- paste(switch(input$var, "Percent White" = "% of white",
                                       "Percent Black" = "% black",
                                       "Percent Hispanic" = "% ofhispanic",
                                       "Percent Asian" = "% ofasian"),"people")
      col <- switch(input$var,
                    "Percent White" = "darkgreen",
                    "Percent Black" = "black",
                    "Percent Hispanic" = "darkred",
                    "Percent Asian" = "darkblue")
      percent_map(var=data, color=col , legend.title= title, min=input$range[1] , max=input$range[2] )
    })
  }
)

