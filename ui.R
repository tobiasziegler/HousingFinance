
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

# Load required packages
library(readr)
library(dplyr)
library(lubridate)
library(rCharts)

shinyUI(fluidPage(

  # Application title
  titlePanel("Australian Housing Finance Explorer"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    position = "right",
    
    sidebarPanel(
      sliderInput(
        "timeline",
        label = h3("Timeline"),
        sep = "",
        min = 1975,
        max = 2018,
        value = c(1975,2018)
      ),
      radioButtons(
        "data_series",
        label = h3("Data Series"),
        choices = list(
          "Original",
          "Seasonally Adjusted",
          "Trend"
        ),
        selected = "Original"
      ),
      radioButtons(
        "chart_display",
        label = h3("Charts Display"),
        choices = list(
          "Commitments ($billions) - Line Chart" = "line",
          "Proportions by Category - Area Chart" = "area"
        )
      ),
      h3("Instructions"),
      p("These charts show the Australian Bureau of Statistics' Housing Finance data, which estimate the monthly lending commitments made by financial institutions for housing."),
      p("The first chart shows lending for owner-occupied housing vs lending for investment properties (for rental or resale). The second shows more detailed breakdown, including construction of new dwellings, purchase of existing dwellings or refinancing of existing loans."),
      p("Use the controls above to select a time range, data series and the type of display."),
      h3("Data Source"),
      a(href="http://www.abs.gov.au/ausstats/abs@.nsf/mf/5609.0", "5609.0 - Housing Finance, Australia, Table 11."),
      p("NB: Some categories of lending were not recorded in earlier parts of the dataset.")
      
    ),

    # Show a plot of the generated time series
    mainPanel(
      h3("Lending Commitments by Borrower Type"),
      showOutput("financeByBorrower", "nvd3"),
      h3("Lending Commitments by Borrower and Purpose"),
      showOutput("financeByPurpose", "nvd3")
    )
  )
))
