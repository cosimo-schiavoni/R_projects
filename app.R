library(shiny)

# Define UI for miles per gallon app ----
ui <- pageWithSidebar(
  
  # App title ----
  headerPanel("EKC CURVE IN CHINA"),
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    
    # Input: Selector for variable to plot against mpg ----
    selectInput("variable", "Variable:", 
                c("Shanghai" = "Shanghai",
                  "Beijing" = "Beijing")),
    
    # Input: Checkbox for whether outliers should be included ----
    checkboxInput()
    
  ),
  
  # Main panel for displaying outputs ----
  mainPanel()
)