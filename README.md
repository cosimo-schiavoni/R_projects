# DSE_R_PROJECT - SCHIAVONI COSIMO 15/04
READ ME

***Functional content

The  project contains a shiny app mabe with R.
The aim of the project is to create an easy and remotely accessible tool for Air quality analysis in China.
The app performs a dinamically configurable linear geogrphical weighted linear regression, which relates the effects of economical phenomena to air quality emissions/density
indexes.
The Linear regression is geographically weighted in the sense that the user can choose the number of closest provinces to take into consideration (by defining a bandwidth),
which have an impact on data basing on their geographical distance with respect to the selected province (basing on the application of a kernel bivariate adaptative funcion).

***Command line:

      runGitHub ("R_projects", "cosimo-schiavoni", ref = "main")

***libraries:

install.packages('shiny', dependencies = TRUE)
install.packages('ggplot2', dependencies = TRUE)
install.packages('DT', dependencies = TRUE)
install.packages('spdep', dependencies = TRUE)
install.packages('rgdal', dependencies = TRUE)
install.packages('rgeos', dependencies = TRUE)
install.packages('GWmodel', dependencies = TRUE)
install.packages('plm', dependencies = TRUE)
install.packages('plotly', dependencies = TRUE)

In order to run run the code, make sure to possess the right library set.

***Data Origin (2000 - 2015):

Official data from 22 Chinese provinces (Hebei, Shanxi. Liaoning, Jilin, Heilongjiang, Jiangsu,Zhejiang, Anhui, Fujian, Jiangxi, Shandong, Henan, Hubei, Hunan, Guangdong,
Hainan, Sichuan, Guizhou, Yunnan, Shaanxi, Gansu, and Qinghai), 5 autonomous regions (Guangxi, Inner Mongolia, Ningxia, Xinjiang, and Tibet), and 4 municipalities 
(Beijing, Shanghai, Chongqing, and Tianjin).

1. Population: 
    official data about the total number of the resident Chinese population at the yearend (10.000 persons) is provided by China Statistical Yearbook at a provincial level.
    Data is assumed to be correct and no need of adjustment is required for this project.The expectations could foresee both a positive and a negative effect on the environment. 
    The positive effect could be due to the fact that higher population density normally requires higher levels of resources and energy consumption, hence resulting in 
    environment degradation (Scale Effect). On the contrary, higher population density could create more social concern, hence resulting in the establishment of more stringent
    environment regulations, which should normally reduce the environmental pressure (S.F. Wang et al. 2015).

2. Real Gross Regional Product Per Capita (Real GRPPC): 
      official data about the Chinese economic performance (Gross Regional Product, 100 million Yuan) at a provincial level is provided by China Statistical Yearbook. 
      When analyzing economical time series,inflation effect through years is one of the main causes of biased estimations, because of this reason it is necessary to 
      adjust normal GRP for price variations, and to find out the real GRP. To this extent, the Consumer Price Index (CPI), provided by the same official sources
      at the provincial level, has been employed, taking into consideration 1997 as a base year (CPI1997 = 100). 
      As far as CPI is normally calculated on average variations, basing on prices and quantities for a wide variety of different product and service categories, 
      the expenditure approach has been employed in GRP observations, in order to have an higher accuracy in the adjustment process. Once that real provincial GRP
      has been estimated, data has been divided by the amount of population in that area, hence resulting in the estimation of the real GRPPC, which has been employed 
      as an important economic development index in this research. The main information provided by this variable is the value level of products and services averagely 
      produced and available in a single economy per person. It is supposed that higher the average value, higher the level of economic development, given that people 
      could benefit from more products and services, hence potentially living in better conditions.

3. Sulphur Dioxide (SO2): 
      official data about total Sulphur Dioxide emissions (tons) is provided by China Statistical Yearbook at a provincial level. Data have been assumed to be correct and no 
      need of adjustment was required for this project.

4. Particulate Matters 2.5 (PM2.5): 
      official data about Particulate Matters average concentration with a diameter of 2.5 μm or less is provided by The OECD database 
      at a provincial level. In the dataset provided, data are missing for the year 2014, while data from 2015 are estimated values. In order to fulfill the missing values, 
      interpolation has been employed, through the calculation of the mean of the values between 2015 and 2013.
      
5. Carbon Dioxide (CO2): as far as regards Carbon Dioxide (Mt), official data are missing, so the IPCC (Intergovernmental Panel on Climate Change) framework has been employed
in order to compute estimated values (Tier 2 approach)*. In this regard, data provided by The Chinese Energy Statistical Yearbook have been used, by taking into consideration 
the consumption (10000 tons) of 8 main energy sources at a provincial level:
             - Coal: hard, black substance that is dug from the earth in pieces, and can be burned to produce heat. (Cambridge Dictionary);
             - Coke: a solid, grey substance that is burned as a fuel, left after coal is heated and the gas and tar removed (Cambridge Dictionary);
             - Crude Oil: Crude oil is a mineral oil consisting of a mixture of hydrocarbons of natural origin, being yellow to black in color, of variable density and 
                          viscosity. (IPCC Guidelines);
             - Gasoline: refined petroleum used as fuel for internal combustion engines. (Oxford Dictionary)
             - Kerosene: Kerosene comprises refined petroleum distillate intermediate in volatility between gasoline and gas/diesel oil. (IPCC guidelines);
             - Diesel Oil: diesel oil includes heavy gas oils. Gas oils are obtained from the lowest fraction from atmospheric distillation of crude oil, while heavy gas
                           oils are obtained by vacuum predistillations of the residual from atmospheric distillation. Several grades are available depending on uses: 
                           diesel oil for diesel compression ignition (cars, trucks, marine, etc.), light heating oil for industrial and commercial uses, and other gas 
                           oil including heavy gas oils. (IPCC Guidelines);                                       
             - Fuel Oil: This heading defines oils that make up the distillation residue. It comprises all residual fuel oils, including those obtained by blending. 
                         (IPCC Guidelines);
             - Natural Gas: Natural gas should include blended natural gas (sometimes also referred to as Town Gas or City Gas), a high calorific value gas obtained as a 
                            blend of natural gas with other gases derived from other primary products, and usually distributed through the natural gas grid. (IPCC Guidelines).

6. Foreign Direct Investments (FDI): 
      data about Foreign Direct investments is provided by the China Statistical Yearbook at a provincial level. In order to take into consideration this variable, Total
      Investment of Foreign Funded Enterprises31 (USD million) data has been adopted and no need of adjustment is required for the aim of this project. The expectation is that 
      a great concentration of FDI could stimulate the investments of pollutant production sites in developing countries, as a result of profitable outsourcing strategies 
      pursued by developed countries (Pollution Heaven theory). In fact, poorer countries are normally characterized by lower production costs (labor in particular) and 
      lower environmental stringency.

7. Trade Openness (TO): 
      The Trade Openness index is basically an index calculated through the ratio between the Total Trade (Import and Export) and Total Real Gross Regional Product (RGRP). 
      In order to calculate this index, data about Import, Export and GRP have been collected by China Statistical Yearbook at a provincial level. To this extent, “Total Value
      of Imports and Exports of operating units(1,000 US dollars)” and “Total Value of Exports of operating units(1,000 US dollars)” have been adopted, while Real GRP has
      been converted from Yuan to USD (average yearly exchange rate has been calculated from 2000 to 2015, monthly data are provided by The Federal Reserve Bank). Trade openness
      is a good index of the impact of trade in an economy, in fact it gives the indication of the dependence of domestic producers on foreign markets, and of foreign consumers
      on the domestic supply. Normally per capita income and trade openness are supposed to be correlated: the more the level of trade openness rises, the more capita income 
      increases, but following a decreasing path in time (Online Trade Outcomes Indicators – The world Bank, 2013). Evidence of positive correlations have been shoved also
      between TO and Productivity, basing this theory on the main assumption that an opened market causes the spread of the competition, resulting hence in a higher output/input
      relationship (JaeBin Ahn and Romain Duval, 2017). Despite these phenomena, the introduction of the Trade Openness index is not new, for instance it can be found in the
      research carried out by J. He and H. Wang in 2012. The expectation is strictly related to the one presented for FDI. In fact, given the above described incentivizing 
      mechanism for outsourcing a production chain to developing countries, it can be expected that then the output would be traded with other economies. This phenomenon seems
      to particularly fit Chinese economic model, which is the first exporter in the world. The main concern is that China could have gained high trade margins by exploiting 
      its competitive advantage in pollution intensive goods. Moreover, it has to be considered the role of the logistic sector, which is supposed to require high levels of 
      energy consumption for transportation.
      
8. Energy Intensity (EI): 
      Energy Intensity Index has been calculated through the adoption of total Power Generation (100 mln kwh) data, directly provided by China Statistical Yearbook at a
      provincial level. Given that EI is supposed to be an efficiency index, data has been divided by the RGRP, in order to follow the typical Input/output framework. The index
      is actually calculating the amount of power (Kwh) produced by each unit of Real Gross Regional Product (Yuan). The expectation in this case is given to the energy sector 
      composition characteristics in China. In fact, as far as the main energy source has been for many years the lowquality coal, a high EI ratio could give the measure of the
      importance of the impact of energy (especially dirty energy) on the economy. If the ratio is low, the efficiency of the energy sector is meant to be high, hence resulting
      in higher environment quality. This index I meant to measure the Technique Effect, which is the effect of a different production technique on the environmental quality.

9. Industrial Capital - Labor Ratio (KL): 
      data about Capital and Labor are provided by China Statistical Yearbook at a provincial level, from 1999 to 2018. In particular, Total Value of Industrial Fixed Assets 
      (100 mln Yuan) and Total Wage Bill of Employed persons in Urban units (100 mln Yuan) have been introduced in order to compute the index. As far as regards the Capital-
      Labor Rario, the expectation is that contrarily to the Pollution Heaven theory, by which China could be expected to specialize in pollution intensive industries, the 
      extremely rich endowment in labor force suggests the specialization in less-polluting industries (basing on the comparative advantage hypothesis). This can be used as an 
      index to measure the Composition Effect, which is the share of dirty goods on the total output, basing on the assumption that higher capital intensity should lead to more-
      pollution intensity industries.

***Navigation

On the right-hand side, the app is composed by 2 main analysis components:
1. Regression Result Box: Shows the statistical result of the linear regression between the selected dependent and independent variables;
2. Box Plot: shows a graphical representation of the relationship between the selected variables.

On the left-hand side, the prompt commands are available:
1. Selection of the Province: the user can select the province of interest;
2. Selection of the period: the user can restrict the analysis to a limited time period;
3. Selection of the Bandwidth: the bandwidth is used as an internal parameter in order to define the geographical extension of the weighting Kernel Function and it defines the                                  number of closest provinces to be included. In this regard, closest provinces have higher weights on data as far as they affect more the           
                               environmental conditions of the selected province.
4. Selecrtion of layout components: the user can decide the color of lines and dots, show/hide the interval confident range.

