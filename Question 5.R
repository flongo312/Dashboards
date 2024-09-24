# Load necessary libraries
library(shiny)
library(shinydashboard)
library(ggplot2)

# Define UI
ui <- fluidPage(
  titlePanel(title = ""),
  sidebarLayout(
    sidebarPanel(
      selectInput("geom", "Geom", choices = c("Histogram" = "geom_histogram",
                                              "FreqPoly" = "geom_freqpoly",
                                              "Density" = "geom_density")),
      checkboxInput("advanced", "Advanced"),
      conditionalPanel(
        condition = "input.advanced == true",
        numericInput("binwidth", "Bin Width", value = 0.1, min = 0.1, step = 0.1)
      )
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$plot <- renderPlot({
    ggplot(data = iris, mapping = aes(x = Sepal.Length)) +
      switch(input$geom,
             geom_histogram = geom_histogram(binwidth = input$binwidth),
             geom_freqpoly = geom_freqpoly(binwidth = input$binwidth),
             geom_density = geom_density(bw = input$binwidth)) +
      labs(title = "")
  })
}

# Run the application
shinyApp(ui, server)
