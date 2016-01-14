library(shiny)

source("helpers.R")
players <- read.csv("data/players.csv")
gameday <- read.csv("data/gameday.csv")

# Define server logic required to draw a histogram
require(rNVD3)
shinyServer(function(input, output) {
  output$myChart <- renderChart({
    hair_eye = as.data.frame(HairEyeColor)
    p6 <- nvd3Plot(Freq ~ Hair | Eye, data = subset(hair_eye, Sex == input$gender), 
                   type = input$type, id = 'myChart', width = 800)
    p6$chart(color = c('brown', 'blue', '#594c26', 'green'), stacked = input$stack)
    return(p6)
  })
})

