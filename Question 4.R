# Load necessary libraries
library(shiny)
library(openintro)
library(dplyr)

# Attach the 'county' dataset (consider avoiding attach() for better practice)
data(county)

# Define the user interface
ui <- fluidPage(
  fluidRow(
    selectInput(
      "state",
      label = "Select a State",
      choices = list("(ALL)", "States" = unique(state))
    ),
    selectInput("name", label = "Select a County", choices = name)
  ),
  fluidRow(
    DT::dataTableOutput(outputId = "plot")
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Update county selection based on state selection
  observe({
    if (input$state == "(ALL)") {
      updateSelectInput(
        session,
        "name",
        label = "Select a County",
        choices = unique(county$name)
      )
    } else {
      updateSelectInput(
        session,
        "name",
        label = ifelse(
          input$state == "Alaska",
          "Select a Borough",
          ifelse(
            input$state == "Louisiana",
            "Select a Parish",
            "Select a County"
          )
        ),
        choices = county[state == input$state, ]$name
      )
    }
  })
  
  # Function to filter data based on user input
  filtered <- reactive({
    if (input$state == "(ALL)") {
      return(subset(county, name == input$name))
    } else {
      return(subset(county, state == input$state & name == input$name))
    }
  })
  
  # Render the data table output
  output$plot <- DT::renderDataTable({
    filtered_data <- filtered()
    if (!is.null(filtered_data)) {
      filtered_data <- filtered_data %>%
        select(
          c(
            "state", "poverty", "homeownership", "unemployment_rate",
            "median_edu", "per_capita_income", "median_hh_income"
          )
        )
      DT::datatable(
        filtered_data,
        options = list(
          pageLength = 5,
          searching = FALSE,
          lengthChange = FALSE,
          info = FALSE,
          paging = FALSE
        )
      )
    } else {
      return(NULL)
    }
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
