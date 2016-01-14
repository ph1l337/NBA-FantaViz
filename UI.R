shinyUI(fluidPage(
  titlePanel("NBA FantaViz"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("TBD.")
      
#       selectInput("var", 
#                   label = "Choose a variable to display",
#                   choices = c("Percent White", "Percent Black",
#                               "Percent Hispanic", "Percent Asian"),
#                   selected = "Percent White"),
#       
#       sliderInput("range", 
#                   label = "Range of interest:",
#                   min = 0, max = 100, value = c(0, 100))
        ),
    mainPanel(plotOutput("lineUp"))
  )
))