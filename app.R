install.packages('shiny', dependencies = TRUE)
install.packages('ggplot2', dependencies = TRUE)
install.packages('DT', dependencies = TRUE)
install.packages('spdep', dependencies = TRUE)
install.packages('rgdal', dependencies = TRUE)
install.packages('rgeos', dependencies = TRUE)
install.packages('GWmodel', dependencies = TRUE)
install.packages('plm', dependencies = TRUE)
install.packages('plotly', dependencies = TRUE)

library(shiny)
library(ggplot2)
library(DT)
library(spdep)
library(rgdal)
library(rgeos)
library(GWmodel)
library(plm)
library(plotly)
library(readxl)
library(dplyr)
library(lubridate)


#Upload panel dataset
Panel1 <- read.csv('Data.csv',sep=",")
#View(Panel1)

#Upload distances file (between provinces)
distances <- read.csv('distances.csv')
#View(distances)


# Define UI
ui <- pageWithSidebar(
  
  # App title
  headerPanel("Air quality analysis in China"),
  
  # Sidebar panel for inputs
  sidebarPanel(
    
    # Input: Selector for variable to plot against
    selectInput(inputId = "Prov", "Province:", 
                c("Anhui" = "Anhui",
                  "Beijing" = "Beijing",
                  "Chongqing" = "Chongqing",
                  "Fujian" = "Fujian",
                  "Gansu" = "Gansu",
                  "Guangdong" = "Guangdong",
                  "Guangxi" = "Guangxi",
                  "Guizhou" = "Guizhou",
                  "Hainan" = "Hainan",
                  "Hebei" = "Hebei",
                  "Heilongjiang" = "Heilongjiang",
                  "Henan" = "Henan",
                  "Hubei" = "Hubei",
                  "Hunan" = "Hunan",
                  "Inner Mongolia" = "Inner Mongolia",
                  "Jiangsu" = "Jiangsu",
                  "Jiangxi" = "Jiangxi",
                  "Jilin" = "Jilin",
                  "Liaoning" = "Liaoning",
                  "Ningxia" = "Ningxia",
                  "Qinghai" = "Qinghai",
                  "Shaanxi" = "Shaanxi",
                  "Shandong" = "Shandong",
                  "Shanghai" = "Shanghai",
                  "Shanxi" = "Shanxi",
                  "Sichuan" = "Sichuan",
                  "Tianjin" = "Tianjin",
                  "Xinjiang" = "Xinjiang",
                  "Yunnan" = "Yunnan",
                  "Zhejiang" = "Zhejiang")),
    
    selectInput(inputId = "Col_line", "Line color:", 
                c("Grey"="grey",
                  "Black" = "black",
                  "Red" = "red",
                  "Green" = "green",
                  "Blue" = "blue")),
    selectInput(inputId = "Col_dots", "Dots color:", 
                c( "Blue" = "blue",
                   "Black" = "black",
                   "Red" = "red",
                   "Grey"="grey",
                   "Green" = "green")),
    
    #Define the Period prompt
    sliderInput(inputId = "Period", "Period:",min = 2000, max = 2015,step=1,value=c(2000,2015),sep = ""),
    #Define the Bandwidth prompt
    sliderInput(inputId = "Band", "Bandwidth:",min = 15, max = 30,step= 1,value = 30,sep = ""),
    #Define the Dependent and independent variables prompt
    selectInput(inputId = "y", label = "Dependent Variable:", 
                choices = names(Panel1[,c(4:6)])),
    selectInput(inputId = "x", label = "Independent Variable:",
                choices = names(Panel1[,c(7:14)])),
    tags$b("Plot:"),
    checkboxInput("se", "Add confidence interval around the regression line", TRUE) 

  ),
  
  # Main panel for displaying outputs
  mainPanel(
    
    tags$b("Compute parameters in R:"),
    verbatimTextOutput("summary"),
    br(),
    tags$b("Regression plot:"),
    uiOutput("results"),
    plotlyOutput("plot"),
    br(),
    tags$b("Interpretation:"),
    uiOutput("interpretation"),
    br(),
    br()
    
  )
)

# Define server logic to plot various variables against mpg ----
server <- function(input, output) {
  
  
  select_period <- reactive({
    Panel1 %>%
      #filter(Stock == input$Stock_selector & between(year(Date), input$Date_range_selector[1], input$Date_range_selector[2]))
      filter(Province==input$Prov & between(Year, input$Period[1], input$Period[2]))
  })
  
  
  #Define variables to weight
  Province = Panel1["Province"]
  ID = Panel1["ID"]
  Year= Panel1["Year"]
  CO2 = Panel1["CO2"]
  SO2 = Panel1["SO2"]
  PM2.5 = Panel1["PM2.5"]
  RGRPPC = Panel1["RGRPPC"]
  POP = Panel1["POP"]
  FDI = Panel1["FDI"]
  TO = Panel1["TO"]
  T = Panel1["T"]
  EI = Panel1["EI"]
  KL = Panel1["KL"]
  EU = Panel1["EU"]
  
  output$summary <- renderPrint({
    
    #Define input province and bandwidth variables
    prov <- (input$Prov)
    Band <- (input$Band)
    
    #Separate distance columns for each province
    provdist <- paste(prov, "dist", sep="")
    provdist <- distances[prov]
    #View(provdist)
    
    #Create a vector of distances for each province
    provmatr <- paste(prov, "matr", sep="") 
    provmatr = as.matrix(provdist, ncol=1)
    #View(provmatr)
    
    #Creating a weighting vector for each province through a bisquare Kernel function
    provgw <- paste(prov, "gw", sep="") 
    provgw = gw.weight(provmatr, Band, kernel = "bisquare", adaptive=TRUE)
    #View(provgw)
    
    #Create 1 weighted panel per each province
    Panelprov <- paste("Panel", prov, sep="") 
    Panelprov = data.frame(Province, ID, Year, (provgw*CO2),(provgw*SO2),(provgw*PM2.5),(provgw*RGRPPC),(provgw*POP),(provgw*FDI),(provgw*TO),(provgw*T),(provgw*EI),(provgw*KL),(provgw*EU))
    #View(Panelprov)  
    
    
    select_period <- reactive({
      Panelprov %>%
        filter(Province==input$Prov & between(Year, input$Period[1], input$Period[2]))
    })
    
    dat <- select_period()
    
    r1 <- reactive({
      lm(dat[,names(dat) %in% input$y] ~ dat[,names(dat) %in% input$x])
    })
    summary(r1())
    
  })
  
  
  
  output$results <- renderUI({
    
    
    #Define input province and bandwidth variables
    prov <- (input$Prov)
    Band <- (input$Band)
    
    #Separate distance columns for each province
    provdist <- paste(prov, "dist", sep="")
    provdist <- distances[prov]
    #View(provdist)
    
    #Create a vector of distances for each province
    provmatr <- paste(prov, "matr", sep="") 
    provmatr = as.matrix(provdist, ncol=1)
    #View(provmatr)
    
    #Creating a weighting vector for each province through a bisquare Kernel function
    provgw <- paste(prov, "gw", sep="") 
    provgw = gw.weight(provmatr, Band, kernel = "bisquare", adaptive=TRUE)
    #View(provgw)
    
    #Create 1 weighted panel per each province
    Panelprov <- paste("Panel", prov, sep="") 
    Panelprov = data.frame(Province, ID, Year, (provgw*CO2),(provgw*SO2),(provgw*PM2.5),(provgw*RGRPPC),(provgw*POP),(provgw*FDI),(provgw*TO),(provgw*T),(provgw*EI),(provgw*KL),(provgw*EU))
    #View(Panelprov)    
    
    select_period <- reactive({
      Panelprov %>%
        filter(Province==input$Prov & between(Year, input$Period[1], input$Period[2]))
    })
    
    
    
    dat <- select_period()
    

    y <- dat[,names(dat) %in% input$y]
    x <- dat[,names(dat) %in% input$x]
    fit <- lm(y ~ x)
    withMathJax(
      paste0(
        "Adj. \\( R^2 = \\) ", round(summary(fit)$adj.r.squared, 3),
        ", \\( \\beta_0 = \\) ", round(fit$coef[[1]], 3),
        ", \\( \\beta_1 = \\) ", round(fit$coef[[2]], 3),
        ", P-value ", "\\( = \\) ", signif(summary(fit)$coef[2, 4], 3)
      )
    )
  })
  
  output$interpretation <- renderUI({
    
    #Define input province and bandwidth variables
    prov <- (input$Prov)
    Band <- (input$Band)
    
    #Separate distance columns for each province
    provdist <- paste(prov, "dist", sep="")
    provdist <- distances[prov]
    #View(provdist)
    
    #Create a vector of distances for each province
    provmatr <- paste(prov, "matr", sep="") 
    provmatr = as.matrix(provdist, ncol=1)
    #View(provmatr)
    
    #Creating a weighting vector for each province through a bisquare Kernel function
    provgw <- paste(prov, "gw", sep="") 
    provgw = gw.weight(provmatr, Band, kernel = "bisquare", adaptive=TRUE)
    #View(provgw)
    
    #Create 1 weighted panel per each province
    Panelprov <- paste("Panel", prov, sep="") 
    Panelprov = data.frame(Province, ID, Year, (provgw*CO2),(provgw*SO2),(provgw*PM2.5),(provgw*RGRPPC),(provgw*POP),(provgw*FDI),(provgw*TO),(provgw*T),(provgw*EI),(provgw*KL),(provgw*EU))
    #View(Panelprov)  
    
    select_period <- reactive({
      Panelprov %>%
        filter(Province==input$Prov & between(Year, input$Period[1], input$Period[2]))
    })
    
    
    
    dat <- select_period()
    
    
   y <- dat[,names(dat) %in% input$y]
    x <- dat[,names(dat) %in% input$x]
    fit <- lm(y ~ x)
    if (summary(fit)$coefficients[1, 4] < 0.05 & summary(fit)$coefficients[2, 4] < 0.05) {
      withMathJax(
        paste0("(Make sure the assumptions for linear regression (independance, linearity, normality and homoscedasticity) are met before interpreting the coefficients.)"),
        br(),
        paste0("For a (hypothetical) value of ", input$xlab, " = 0, the mean of ", input$ylab, " = ", round(fit$coef[[1]], 3), "."),
        br(),
        paste0("For an increase of one unit of ", input$xlab, ", ", input$ylab, ifelse(round(fit$coef[[2]], 3) >= 0, " increases (on average) by ", " decreases (on average) by "), abs(round(fit$coef[[2]], 3)), ifelse(abs(round(fit$coef[[2]], 3)) >= 2, " units", " unit"), ".")
      )
    } else if (summary(fit)$coefficients[1, 4] < 0.05 & summary(fit)$coefficients[2, 4] >= 0.05) {
      withMathJax(
        paste0("(Make sure the assumptions for linear regression (independance, linearity, normality and homoscedasticity) are met before interpreting the coefficients.)"),
        br(),
        paste0("For a (hypothetical) value of ", input$xlab, " = 0, the mean of ", input$ylab, " = ", round(fit$coef[[1]], 3), "."),
        br(),
        paste0("\\( \\beta_1 \\)", " is not significantly different from 0 (p-value = ", round(summary(fit)$coefficients[2, 4], 3), ") so there is no significant relationship between ", input$xlab, " and ", input$ylab, ".")
      )
    } else if (summary(fit)$coefficients[1, 4] >= 0.05 & summary(fit)$coefficients[2, 4] < 0.05) {
      withMathJax(
        paste0("(Make sure the assumptions for linear regression (independance, linearity, normality and homoscedasticity) are met before interpreting the coefficients.)"),
        br(),
        paste0("\\( \\beta_0 \\)", " is not significantly different from 0 (p-value = ", round(summary(fit)$coefficients[1, 4], 3), ") so when ", input$xlab, " = 0, the mean of ", input$ylab, " is not significantly different from 0."),
        br(),
        paste0("For an increase of one unit of ", input$xlab, ", ", input$ylab, ifelse(round(fit$coef[[2]], 3) >= 0, " increases (on average) by ", " decreases (on average) by "), abs(round(fit$coef[[2]], 3)), ifelse(abs(round(fit$coef[[2]], 3)) >= 2, " units", " unit"), ".")
      )
    } else {
      withMathJax(
        paste0("(Make sure the assumptions for linear regression (independance, linearity, normality and homoscedasticity) are met before interpreting the coefficients.)"),
        br(),
        paste0("\\( \\beta_0 \\)", " and ", "\\( \\beta_1 \\)", " are not significantly different from 0 (p-values = ", round(summary(fit)$coefficients[1, 4], 3), " and ", round(summary(fit)$coefficients[2, 4], 3), ", respectively) so the mean of ", input$ylab, " is not significantly different from 0.")
      )
    }
  })
  
  
  #Design a scatter plot with regression line
  output$plot <- renderPlotly({
    
    #Define input province and bandwidth variables
    prov <- (input$Prov)
    Band <- (input$Band)
    
    #Separate distance columns for each province
    provdist <- paste(prov, "dist", sep="")
    provdist <- distances[prov]
    #View(provdist)
    
    #Create a vector of distances for each province
    provmatr <- paste(prov, "matr", sep="") 
    provmatr = as.matrix(provdist, ncol=1)
    #View(provmatr)
    
    #Creating a weighting vector for each province through a bisquare Kernel function
    provgw <- paste(prov, "gw", sep="") 
    provgw = gw.weight(provmatr, Band, kernel = "bisquare", adaptive=TRUE)
    #View(provgw)
    
    #Create 1 weighted panel per each province
    Panelprov <- paste("Panel", prov, sep="") 
    Panelprov = data.frame(Province, ID, Year, (provgw*CO2),(provgw*SO2),(provgw*PM2.5),(provgw*RGRPPC),(provgw*POP),(provgw*FDI),(provgw*TO),(provgw*T),(provgw*EI),(provgw*KL),(provgw*EU))
    #View(Panelprov)    
    
    select_period <- reactive({
      Panelprov %>%
        #filter(Stock == input$Stock_selector & between(year(Date), input$Date_range_selector[1], input$Date_range_selector[2]))
        filter(Province==input$Prov & between(Year, input$Period[1], input$Period[2]))
    })
    
    
    
    dat <- select_period()
    

    y <- dat[,names(dat) %in% input$y]
    x <- dat[,names(dat) %in% input$x]
    fit <- lm(y ~ x , data = dat)
    p <- ggplot(dat, aes(x = x, y = y)) +
      geom_point(color = input$Col_dots) +
      stat_smooth(method = "lm", se = input$se, color=input$Col_line) +
      ylab(input$ylab) +
      xlab(input$xlab) +
      theme_minimal()
    ggplotly(p)
  })
  
  
}

# Run the application
shinyApp(ui = ui, server = server)