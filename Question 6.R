# Load necessary libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(gridExtra)

# Define UI
ui <- fluidPage(
  titlePanel(title = ""),
  sidebarLayout(
    sidebarPanel(
      selectInput("geom", "Geom", choices = c("Histogram", "FreqPoly", "Density"), multiple = TRUE, selected = NULL),
      checkboxInput("advanced", "Advanced"),
      conditionalPanel(
        condition = "input.advanced == true",
        numericInput("hist_binwidth", "Histogram Binwidth", value = 0.1, min = 0.1, step = 0.1),
        numericInput("freqpoly_binwidth", "Frequency Polygon Binwidth", value = 0.1, min = 0.1, step = 0.1),
        numericInput("density_binwidth", "Density Plot Binwidth", value = 0.1, min = 0.1, step = 0.1)
      )
    ),
    mainPanel(plotOutput("plot"))
  )
)

# Define server logic
server <- function(input, output) {
  output$plot <- renderPlot({
    plots <- list()
    
    if ("Histogram" %in% input$geom) {
      plots$histogram <- ggplot(data = iris, mapping = aes(x = Sepal.Length)) +
        geom_histogram(binwidth = input$hist_binwidth) +
        labs(title = "")
    }
    
    if ("FreqPoly" %in% input$geom) {
      plots$freqpoly <- ggplot(data = iris, mapping = aes(x = Sepal.Length)) +
        geom_freqpoly(binwidth = input$freqpoly_binwidth) +
        labs(title = "")
    }
    
    if ("Density" %in% input$geom) {
      plots$density <- ggplot(data = iris, mapping = aes(x = Sepal.Length)) +
        geom_density(bw = input$density_binwidth) +
        labs(title = "")
    }
    
    if (length(plots) > 0) {
      do.call(grid.arrange, c(plots, ncol = 2))
    }
  })
}

# Run the application
shinyApp(ui, server)
