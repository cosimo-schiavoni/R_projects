library(shiny)
library(ggplot2)
library(DT)
library(spdep)
library(rgdal)
library(rgeos)
library(GWmodel)
library(plm)

Panel1 <- read.csv('CO2.csv',sep=",")
#View(Panel1)

#Upload distances file
distances <- read.csv('distances.csv')
#View(distances)

#Define the Bandwidth
Bandwidth=10

#Define variables to weight
Province = Panel1["Province"]
ID = Panel1["ID"]
Year= Panel1["Year"]
CO2 = Panel1["CO2"]
RGRPPC = Panel1["RGRPPC"]
RGRPPC2 = Panel1["RGRPPC2"]
RGRPPC3 = Panel1["RGRPPC3"]
POP = Panel1["POP"]
FDI = Panel1["FDI"]
TO = Panel1["TO"]
T = Panel1["T"]
EI = Panel1["EI"]
KL = Panel1["KL"]
EU = Panel1["EU"]

#Separate distances columns for each province
Beijingdist <- distances["Beijing"]
#View(Beijingdist)

#Create a vector of distances for each province
Beijing = as.matrix(Beijingdist, ncol=1)
#print(Beijing)

#Creating a weighting vector for each province through a bisquare Kernel function
Beijingw = gw.weight(Beijing, Bandwidth, kernel = "bisquare", adaptive=TRUE)
#View(Beijingw)

#Create 1 weighted panel per each province
PanelBeijing = data.frame(Province, ID, Year, (Beijingw*CO2),(Beijingw*RGRPPC),(Beijingw*RGRPPC2),(Beijingw*RGRPPC3),(Beijingw*POP),(Beijingw*FDI),(Beijingw*TO),(Beijingw*T),(Beijingw*EI),(Beijingw*KL),(Beijingw*EU))
#View(PanelBeijing)

#set panel data per each province
pdataBeijing <- plm.data(PanelBeijing, index=c("ID", "Year"))
#View(pdataBeijing)


# 3SLS - GWPR Beijing
eqCO2 <- CO2 ~ RGRPPC | lag(RGRPPC) 
eqRGRPPC <- RGRPPC ~ CO2 | lag(CO2) 
r1 <- plm(list(CO2.Emissions = eqCO2,
               RGRPPC.Development = eqRGRPPC),
          data= pdataBeijing, index = 30, model = "random",
          inst.method = "baltagi", random.method = "nerlove",
          random.dfcor = c(1, 1))
summary(r1)

#complete model
eqEQ <- CO2 ~ RGRPPC + RGRPPC2 + RGRPPC3 | lag(POP) + lag(RGRPPC) + lag (RGRPPC2) + lag (RGRPPC3) + lag (FDI) + lag (TO) +  lag (EI) + lag (KL)  
eqRGRPPC <- RGRPPC ~ CO2 | lag(CO2)  
r1 <- plm(list(EQ.Emissions = eqEQ, 
                       RGRPPC.Development = eqRGRPPC), 
                  data= pdataBeijing, index = 30, model = "random",
                  inst.method = "baltagi", random.method = "nerlove", 
                  random.dfcor = c(1, 1)) 
summary(r1) 



# Define UI for miles per gallon app ----
ui <- pageWithSidebar(
  
  # App title ----
  headerPanel("EKC CURVE IN CHINA"),
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    
    # Input: Selector for variable to plot against mpg ----
    selectInput("variable", "Province:", 
                c("Shanghai" = "Shanghai",
                  "Beijing" = "Beijing")),
    
  sliderInput("integer", "Period:",min = 1999, max = 2015,step=1,value=c(1999,2015),sep = "")
  
  ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      fluidPage(DTOutput('Panel1')),
      
    )
  )
  
  # Define server logic to plot various variables against mpg ----
  server <- function(input, output) {
    #output$Panel1 = renderDT(Panel1, options = list(lengthChange = FALSE))
    

    
  }
  
  shinyApp(ui, server)