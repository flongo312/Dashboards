# Load necessary libraries
library(socviz)
library(shiny)
library(ggplot2)
library(dplyr)

# Load data
data("opiates")
attach(opiates)

# Define UI
ui <- fluidPage(
  mainPanel(
    selectInput("state", 
                label = "State",
                choices = list(
                  "Northeast" = unique(opiates$state[region == "Northeast"]),
                  "Midwest" = unique(opiates$state[region == "Midwest"]),
                  "West" = unique(opiates$state[region == "West"]),
                  "South" = unique(opiates$state[region == "South"])
                )),
    plotOutput("death_rate_plot")
  )
)

# Define server logic
server <- function(input, output) {
  output$death_rate_plot <- renderPlot({
    filtered <- opiates[opiates$state == input$state, ]
    ggplot(filtered, aes(x = year, y = adjusted)) +
      geom_line() +
      labs(title = "Adjusted Death Rate (Yearly)", x = "", y = "") +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
