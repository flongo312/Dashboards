# Load necessary libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)

# Define UI
ui <- fluidPage(
  fluidRow(
    box(
      width = 12,
      sliderInput(
        "date_range", "Date Range:",
        min = min(economics$date),
        max = max(economics$date),
        value = c(min(economics$date), max(economics$date)),
        timeFormat = "%b %Y"
      )
    ),
    box(
      width = 12,
      dataTableOutput("table")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  filtered_data <- reactive({
    filter(
      economics,
      date >= input$date_range[1] & date <= input$date_range[2]
    )
  })
  
  output$table <- renderDataTable({
    datatable(filtered_data())
  })
}

# Run the application
shinyApp(ui, server)
