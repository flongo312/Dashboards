library(shiny)
library(plotly)
library(ggplot2)
library(dplyr)
library(DT)
library(scales)
library(shinydashboard)

# Load data
billionaires_data <- read.csv("/Users/frank/Desktop/Classes/QMB_6304_Data_Visualization/Term Project/Dataset/Forbes Billionaires.csv")
forbes_data <- read.csv("/Users/frank/Desktop/Classes/QMB_6304_Data_Visualization/Term Project/Dataset/Forbes Billionaires.csv")
Forbes <- read.csv("/Users/frank/Desktop/Classes/QMB_6304_Data_Visualization/Term Project/Dataset/Forbes Billionaires.csv")
Forbes$Networth <- as.numeric(Forbes$Networth)
forbes_data$Age <- as.numeric(as.character(forbes_data$Age))

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Forbes Billionaires Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Top Billionaires", tabName = "top_billionaires", icon = icon("users")),
      menuItem("Age Analysis", tabName = "age_analysis", icon = icon("chart-bar")),
      menuItem("Industry Comparison", tabName = "industry_comparison", icon = icon("industry"))
    )
  ),
  dashboardBody(
    tabItems(
      # Tab 1: Top Billionaires
      tabItem(
        tabName = "top_billionaires",
        fluidPage(
          titlePanel("Who are the top billionaires?", windowTitle = "Billionaires App"),
          sidebarLayout(
            sidebarPanel(
              style = "background-color: #f9f9f9; border-radius: 5px; padding: 15px; box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);",
              tags$h4("Filter Data", style = "color: #333;"),
              selectInput("country_filter", "Filter by Country", choices = c("All", unique(billionaires_data$Country))),
              selectInput("industry_filter", "Filter by Industry", choices = c("All", unique(billionaires_data$Industry)))
            ),
            mainPanel(
              tabsetPanel(
                tabPanel("Top Billionaires", 
                         plotlyOutput("treemap", height = "calc(100vh - 200px)")),
                tabPanel("Billionaires Table",
                         br(),
                         fluidRow(
                           column(width = 6,
                                  actionButton("show_all_btn", "Show All", class = "btn btn-primary")),
                           column(width = 6,
                                  downloadButton("download_filtered_data", "Download Data", class = "btn btn-success"))
                         ),
                         br(),
                         DTOutput("billionaires_table"))
              )
            )
          )
        )
      ),
      # Tab 2: Age Analysis
      tabItem(
        tabName = "age_analysis",
        fluidPage(
          titlePanel("How does age play a factor?"),
          sidebarLayout(
            sidebarPanel(
              width = 3,
              h4("Select Age Range:", style = "font-weight: bold;"),
              sliderInput(
                "age_range",
                label = "Age Range:",
                min = 0,
                max = 110,
                value = c(0, 110),
                width = "100%",
                ticks = TRUE,
                step = 1
              ),
              br(),
              p("Slide to view billionaires within a specific age range.", style = "font-size: 14px;"),
              p("Data source: Forbes Billionaires Dataset", style = "font-size: 12px; color: #777;")
            ),
            mainPanel(
              width = 9,
              fluidRow(
                tabsetPanel(
                  id = "tabset",
                  tabPanel(
                    "Average Net Worth by Age Group",
                    plotOutput("net_worth_bar_chart", width = "100%", height = "500px")
                  ),
                  tabPanel(
                    "Age Distribution of Billionaires",
                    plotOutput("age_frequency_plot", width = "100%", height = "500px")
                  )
                )
              )
            )
          )
        )
      ),
      # Tab 3: Industry Comparison
      tabItem(
        tabName = "industry_comparison",
        fluidPage(
          titlePanel("Which industries have the highest average net worths?"),
          sidebarLayout(
            sidebarPanel(
              selectizeInput(
                "industry_select", "Select Industries:",
                choices = c("All", unique(Forbes$Industry)),
                selected = "All",
                multiple = TRUE,
                options = list(maxItems = 10, placeholder = "Select industries")
              ),
              p("Select multiple industries to compare their distributions."),
              hr(),
              p("This visualization illustrates the distribution of net worth among billionaires based on industries."),
              p("The boxplots display the quartiles, while the red points represent the average net worth in each selected industry.")
            ),
            mainPanel(
              plotOutput("boxplot", width = "100%", height = "70vh"),
              br(),
              verbatimTextOutput("tooltip_info")
            )
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Tab 1: Top Billionaires
  filtered_billionaires <- reactive({
    billionaires_filtered <- billionaires_data
    
    if (input$country_filter != "All") {
      billionaires_filtered <- filter(billionaires_filtered, Country %in% input$country_filter)
    }
    if (input$industry_filter != "All") {
      billionaires_filtered <- filter(billionaires_filtered, Industry %in% input$industry_filter)
    }
    
    billionaires_filtered <- billionaires_filtered %>%
      arrange(desc(Networth)) %>%
      slice(1:15)
  })
  
  output$treemap <- renderPlotly({
    top_15_billionaires <- filtered_billionaires()
    
    min_networth <- min(top_15_billionaires$Networth)
    max_networth <- max(top_15_billionaires$Networth)
    top_15_billionaires$normalized_networth <- 1 - ((top_15_billionaires$Networth - min_networth) / (max_networth - min_networth))
    
    top_15_billionaires$Labels <- paste(top_15_billionaires$Name, "")
    
    plot_ly(
      data = top_15_billionaires,
      type = "treemap",
      labels = ~Labels,
      ids = ~Name,
      parents = "",
      values = ~Networth,
      hoverinfo = "text",
      text = ~paste(
        "<b>Name:</b> ", Name, "<br>",
        "<b>Net Worth:</b> $", format(Networth, big.mark = ",", scientific = FALSE), "<br>",
        "<b>Age:</b> ", Age, "<br>",
        "<b>Country:</b> ", Country,
        "<br><b>Source:</b> ", Source,
        "<br><b>Industry:</b> ", Industry
      ),
      hoverlabel = list(bgcolor = "white", font = list(color = "black")),
      marker = list(
        colorscale = list(
          c(0, 1),
          c("rgb(214, 234, 248)", "rgb(27, 117, 187)")
        ),
        color = ~normalized_networth,
        line = list(color = "white", width = 0.5)
      ),
      textfont = list(color = "black", family = "Arial", size = 14),
      pathbar = list(visible = FALSE)
    ) %>%
      layout(
        title = "Top 15 Billionaires by Net Worth",
        margin = list(l = 40, r = 40, b = 40, t = 60),
        plot_bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "white"
      )
  })
  
  output$billionaires_table <- renderDT({
    filtered_billionaires()
  })
  
  observeEvent(input$show_all_btn, {
    output$billionaires_table <- renderDT({
      billionaires_data
    })
  })
  
  output$download_filtered_data <- downloadHandler(
    filename = function() {
      "filtered_billionaires.csv"
    },
    content = function(file) {
      write.csv(filtered_billionaires(), file, row.names = FALSE)
    }
  )
  
  # Tab 2: Age Analysis
  filtered_data <- reactive({
    validate(
      need(input$age_range[1] <= input$age_range[2], "Invalid age range. Please select a valid range.")
    )
    data <- forbes_data %>%
      filter(Age >= input$age_range[1] & Age <= input$age_range[2])
    data
  })
  
  output$net_worth_bar_chart <- renderPlot({
    data <- filtered_data()
    data %>%
      group_by(age_group = cut(Age, 
                               breaks = c(0, 30, 40, 50, 60, 70, 80, 90, 100, 120),
                               labels = c("0-30", "31-40", "41-50", "51-60", "61-70", "71-80", "81-90", "91-100", "101-120")),
               include.lowest = TRUE) %>%
      summarise(avg_net_worth = mean(Networth, na.rm = TRUE)) %>%
      ggplot(aes(x = as.character(age_group), y = avg_net_worth)) +
      geom_bar(stat = "identity", color = "#34495E", fill = "#3498DB") +
      geom_text(aes(label = paste0("$", round(avg_net_worth, 1), "B")), 
                vjust = -0.5, size = 4, color = "black") +
      labs(title = "Average Net Worth Across Age Groups",
           x = "Age Group",
           y = "Average Net Worth (in billions)") +
      theme_minimal(base_size = 14) +
      # Modify theme elements for better readability
      theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 20, color = "#2C3E50"),
            axis.title = element_text(size = 16, color = "#2C3E50"),
            axis.text = element_text(size = 14, color = "#2C3E50"),
            axis.line = element_line(color = "#2C3E50"),
            panel.background = element_rect(fill = "#EAECEE"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank())
  })
  
  output$age_frequency_plot <- renderPlot({
    data <- filtered_data()
    data %>%
      ggplot(aes(x = Age)) +
      geom_bar(color = "#34495E", fill = "#3498DB") +
      geom_density(aes(y = after_stat(count)), color = "#C0392B", alpha = 0.5, size = 1.5, fill = NA) +
      labs(title = "Age Distribution of Billionaires",
           x = "Age",
           y = "Number of Billionaires") +
      theme_minimal(base_size = 14) +
      # Modify theme elements for better readability
      theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 20, color = "#C0392B"),
            axis.title = element_text(size = 16, color = "#2C3E50"),
            axis.text = element_text(size = 14, color = "#2C3E50"),
            axis.line = element_line(color = "#2C3E50"),
            panel.background = element_rect(fill = "#EAECEE"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank())
  })
  
  # Tab 3: Industry Comparison
  filtered_data_industry <- reactive({
    req(input$industry_select)
    if ("All" %in% input$industry_select) {
      return(Forbes)
    } else {
      Forbes %>%
        filter(Industry %in% input$industry_select)
    }
  })
  
  output$tooltip_info <- renderText({
    req(input$industry_select)
    if (length(input$industry_select) == 0 || ("All" %in% input$industry_select)) {
      return("Please select one or more industries.")
    } else {
      selected_data <- filtered_data_industry()
      info <- paste(
        "Selected Industries: ", paste(input$industry_select, collapse = ", "), "\n",
        "Average Net Worth: ", scales::dollar(mean(selected_data$Networth)), " billions\n",
        "Median Net Worth: ", scales::dollar(median(selected_data$Networth)), " billions\n",
        "Number of Billionaires: ", nrow(selected_data), "\n"
      )
      info
    }
  })
  
  output$boxplot <- renderPlot({
    req(input$industry_select)
    plot_data <- isolate(filtered_data_industry())
    ggplot(plot_data, aes(x = Industry, y = Networth)) +
      geom_boxplot(outlier.shape = NA, fill = "#5DADE2", color = "#2980B9") +
      geom_jitter(aes(color = Industry), width = 0.2, size = 2, alpha = 0.6) +
      stat_summary(fun = mean, geom = "point", shape = 18, size = 4, color = "#E74C3C", position = position_dodge(width = 0.75)) +
      labs(title = ifelse("All" %in% input$industry_select, "Net Worth Distribution Among Different Industries", "Net Worth Distribution in Selected Industries"),
           x = "Industry", y = "Net Worth (in billions)") +
      scale_y_log10(labels = dollar_format()) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(size = 10, angle = 45, hjust = 1, color = "#34495E"),
        axis.text.y = element_text(size = 10, color = "#34495E"),
        axis.title = element_text(size = 12, color = "#34495E"),
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5, color = "#34495E"),
        panel.grid = element_blank(),
        legend.position = "none" 
      )
  })
}

# Run the application
shinyApp(ui = ui, server = server)