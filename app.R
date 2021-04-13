library(shiny)

# Define UI for miles per gallon app ----
ui <- pageWithSidebar(
  
  # App title ----
  headerPanel("EKC CURVE IN CHINA"),
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    
    # Input: Selector for variable to plot against mpg ----
    selectInput("Province", "Variable:", 
                c("Shanghai" = "Shanghai",
                  "Beijing" = "Beijing"))), 
    sliderInput("num", "Number:",min = 0, max = 5,step=1,value=c(1,2)),
    
    # Main panel for displaying outputs ----
    mainPanel()
  )
  
  # Define server logic to plot various variables against mpg ----
  server <- function(input, output) {
    
  }
  
  shinyApp(ui, server)