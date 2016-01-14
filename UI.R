shinyUI(fluidPage(
  titlePanel("NBA FantaViz"),

  
  fluidRow(
    column(width = 4,
           selectInput(inputId = "gender",
                       label = "Choose Gender",
                       choices = c("Male", "Female"),
                       selected = "Male"),
           selectInput(inputId = "type",
                       label = "Choose Chart Type",
                       choices = c("multiBarChart", "multiBarHorizontalChart"),
                       selected = "multiBarChart"),
           checkboxInput(inputId = "stack",
                         label = strong("Stack Bars?"),
                         value = FALSE)
    ),
    column(width = 5, offset = 0,
           showOutput("myChart")
    )
  )
))
  
  

