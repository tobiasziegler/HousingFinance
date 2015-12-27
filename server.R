
# This is the server logic for a Shiny web application.
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

series = c("Original", "Seasonally Adjusted", "Trend")

# Load the dataset created by data-processing.R
housing_finance <- readr::read_csv(file.path("data", "housing-finance.csv")) %>%
  mutate(
    data_month = as.Date(data_month),
    series_id = factor(series_id),
    data_series = factor(data_series),
    borrower_type = factor(borrower_type),
    purpose = factor(purpose)
  )

shinyServer(function(input, output) {

  output$financeByBorrower <- renderChart2({
    
    hf_subset_aggregate <- housing_finance %>%
      filter(
        data_series == input$data_series,
        year(data_month) >= input$timeline[1],
        year(data_month) <= input$timeline[2]
      ) %>%
      group_by(borrower_type, data_month) %>%
      summarise(commitments = sum(commitments, na.rm = TRUE))
    
    if(input$chart_display == "line") {
      hf_total <- hf_subset_aggregate %>%
        group_by(data_month) %>%
        summarise(commitments = sum(commitments, na.rm = TRUE)) %>%
        mutate(borrower_type = "Total")
      hf_subset_aggregate <- bind_rows(hf_subset_aggregate, hf_total)
      housing_finance_by_borrower <- nPlot(
        commitments ~ data_month,
        group = "borrower_type",
        data = hf_subset_aggregate,
        type = "lineChart"
      )
      housing_finance_by_borrower$set(width = 640)
      housing_finance_by_borrower$xAxis(tickFormat = "#!function(d) {return d3.time.format('%Y-%m')(new Date( d * 86400000 ));}!#")
      housing_finance_by_borrower$chart(forceY = c(0, max(hf_subset_aggregate$commitments)))
    }
    else {
      hf_subset_aggregate <- hf_subset_aggregate %>%
        group_by(data_month, borrower_type) %>%
        summarise(commitments = commitments) %>%
        mutate(prop = commitments / sum(commitments))
      housing_finance_by_borrower <- nPlot(
        prop ~ data_month,
        group = "borrower_type",
        data = hf_subset_aggregate,
        type = "stackedAreaChart"
      )
      housing_finance_by_borrower$set(width = 640)
      housing_finance_by_borrower$xAxis(tickFormat = "#!function(d) {return d3.time.format('%Y-%m')(new Date( d * 86400000 ));}!#")
      housing_finance_by_borrower$chart(forceY = c(0, 1))
      
    }
    return(housing_finance_by_borrower)
    
  })
  
  output$financeByPurpose <- renderChart2({
    
    hf_subset <- housing_finance %>%
      filter(
        data_series == input$data_series,
        year(data_month) >= input$timeline[1],
        year(data_month) <= input$timeline[2]
      )

    if(input$chart_display == "line") {
      hf_total <- hf_subset %>%
        group_by(data_month) %>%
        summarise(commitments = sum(commitments, na.rm = TRUE)) %>%
        mutate(purpose = "Total")
      hf_subset <- bind_rows(hf_subset, hf_total)
      housing_finance_by_purpose <- nPlot(
        commitments ~ data_month,
        group = "purpose",
        data = hf_subset,
        type = "lineChart"
      )
      housing_finance_by_purpose$set(width = 640)
      housing_finance_by_purpose$xAxis(tickFormat = "#!function(d) {return d3.time.format('%Y-%m')(new Date( d * 86400000 ));}!#")
      housing_finance_by_purpose$chart(forceY = c(0, max(hf_subset$commitments)))
    } else {
      hf_subset <- hf_subset %>%
        group_by(data_month, purpose) %>%
        summarise(commitments = commitments, na.rm = TRUE) %>%
        mutate(prop = commitments / sum(commitments, na.rm = TRUE))
      housing_finance_by_purpose <- nPlot(
        prop ~ data_month,
        group = "purpose",
        data = hf_subset,
        type = "stackedAreaChart"
      )
      housing_finance_by_purpose$set(width = 640)
      housing_finance_by_purpose$xAxis(tickFormat = "#!function(d) {return d3.time.format('%Y-%m')(new Date( d * 86400000 ));}!#")
      housing_finance_by_purpose$chart(forceY = c(0, 1))
    }
    
    return(housing_finance_by_purpose)
    
  })

})
