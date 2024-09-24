# Load required libraries
library(shiny)
library(ggplot2)
library(shinyjs)

# Load the economics dataset from ggplot2 package
data("economics")

# Define the Shiny app UI
ui <- fluidPage(
  useShinyjs(),  # Initialize shinyjs
  
  
  # Date slider input
  sliderInput("dateInput", "Date Range",
              min = as.Date(min(economics$date)),
              max = as.Date(max(economics$date)),
              value = as.Date(min(economics$date)),
              step = 30,
              animate = animationOptions(interval = 1000, loop = TRUE),
              timeFormat = "%b %Y",
              width = "60%"),
  
  plotOutput("savingsPlot")
)

# Define the server logic
server <- function(input, output, session) {
  
  # Function to filter data based on date selection
  filtered_data <- reactive({
    min_date <- min(economics$date)
    selected_date <- input$dateInput
    
    economics_filtered <- economics[economics$date >= min_date & economics$date <= selected_date, ]
    if (nrow(economics_filtered) == 1) {
      economics_filtered <- rbind(economics_filtered, economics_filtered)
    }
    
    economics_filtered
  })
  
  # Reactive timer for auto-refreshing
  autoInvalidate <- reactiveTimer(500, session)
  
  # Render the plot based on filtered data
  output$savingsPlot <- renderPlot({
    ggplot(filtered_data(), aes(x = date, y = psavert)) +
      geom_line() +
      labs(title = "Personal Savings Rate (Monthly)",
           x = "",
           y = "") +
      scale_x_date(date_labels = "%b %Y") +
      theme_minimal()
  })
  
  # Event to handle 'Play' button functionality
  observeEvent(input$playButton, {
    shinyjs::disable("playButton")
    
    isolate({
      while (input$playButton > 0 && input$dateInput < max(economics$date)) {
        input$dateInput <- input$dateInput + 30
        autoInvalidate()
        Sys.sleep(0.3) 
      }
    })
    
    shinyjs::enable("playButton")
  })
}

# Run the Shiny app
shinyApp(ui, server)
