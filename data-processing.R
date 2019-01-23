# Load required packages
library(curl)
library(readxl)
library(readr)
library(tidyr)
library(dplyr)

# Create data folder and download the data file if they don't already exist.
data_url_old <- "http://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&5609011.xls&5609.0&Time%20Series%20Spreadsheet&FAF9288289AB4F11CA257F1500123742&0&Oct%202015&09.12.2015&Latest"
data_url_old2 <- "http://www.abs.gov.au/ausstats/meisubs.nsf/log?openagent&5609011.xls&5609.0&Time%20Series%20Spreadsheet&2252D837852C2C56CA257F3A00189B4F&0&Nov%202015&15.01.2016&Latest"
data_url <- "http://www.abs.gov.au/ausstats/meisubs.nsf/log?openagent&5609011.xls&5609.0&Time%20Series%20Spreadsheet&D30BA82E02D34A2ACA25838400152F1F&0&November%202018&17.01.2019&Latest"
data_local <- file.path("data", "ABS-5609.0-HousingFinance-Table11.xls")
if(!file.exists("data")) {
  dir.create("data")
}
if(!file.exists(data_local)) {
  curl_download(data_url, data_local)
}

# Read the Excel sheet, then tidy and prepare the data.
housing_finance_data <-
  read_excel(
    data_local,
    "Data1",
    skip = 9
  ) %>%
  select(
    -A2413058R,
    -A2413066R,
    -A2413074R
  ) %>%
  rename(
    data_month = `Series ID`,
    `A2413051X.Original.Owner Occupation.Owner Occupation: Construction of dwellings` = A2413051X,
    `A2413052A.Original.Owner Occupation.Owner Occupation: Purchase of new dwellings` = A2413052A,
    `A2413053C.Original.Owner Occupation.Owner Occupation: Refinancing of established dwellings` = A2413053C,
    `A2413054F.Original.Owner Occupation.Owner Occupation: Purchase of other established dwellings` = A2413054F,
    `A2413055J.Original.Investment Housing.Investment Housing: Construction of dwellings for rent and resale` = A2413055J,
    `A2413056K.Original.Investment Housing.Investment Housing: Purchase for rent or resale by individuals` = A2413056K,
    `A2413057L.Original.Investment Housing.Investment Housing: Purchase for rent or resale by others` = A2413057L,
    `A2413059T.Seasonally Adjusted.Owner Occupation.Owner Occupation: Construction of dwellings` = A2413059T,
    `A2413060A.Seasonally Adjusted.Owner Occupation.Owner Occupation: Purchase of new dwellings` = A2413060A,
    `A2413061C.Seasonally Adjusted.Owner Occupation.Owner Occupation: Refinancing of established dwellings` = A2413061C,
    `A2413062F.Seasonally Adjusted.Owner Occupation.Owner Occupation: Purchase of other established dwellings` = A2413062F,
    `A2413063J.Seasonally Adjusted.Investment Housing.Investment Housing: Construction of dwellings for rent and resale` = A2413063J,
    `A2413064K.Seasonally Adjusted.Investment Housing.Investment Housing: Purchase for rent or resale by individuals` = A2413064K,
    `A2413065L.Seasonally Adjusted.Investment Housing.Investment Housing: Purchase for rent or resale by others` = A2413065L,
    `A2413067T.Trend.Owner Occupation.Owner Occupation: Construction of dwellings` = A2413067T,
    `A2413068V.Trend.Owner Occupation.Owner Occupation: Purchase of new dwellings` = A2413068V,
    `A2413069W.Trend.Owner Occupation.Owner Occupation: Refinancing of established dwellings` = A2413069W,
    `A2413070F.Trend.Owner Occupation.Owner Occupation: Purchase of other established dwellings` = A2413070F,
    `A2413071J.Trend.Investment Housing.Investment Housing: Construction of dwellings for rent and resale` = A2413071J,
    `A2413072K.Trend.Investment Housing.Investment Housing: Purchase for rent or resale by individuals` = A2413072K,
    `A2413073L.Trend.Investment Housing.Investment Housing: Purchase for rent or resale by others` = A2413073L
  ) %>%
  gather(
    series,
    commitments,
    `A2413051X.Original.Owner Occupation.Owner Occupation: Construction of dwellings`:
      `A2413073L.Trend.Investment Housing.Investment Housing: Purchase for rent or resale by others`
  ) %>%
  separate(
    series,
    into = c("series_id", "data_series", "borrower_type", "purpose"),
    sep = "\\."
  ) %>%
  mutate(
    series_id = factor(series_id),
    data_series = factor(data_series),
    borrower_type = factor(borrower_type),
    purpose = factor(purpose),
    commitments = replace(commitments, which(commitments == 0), NA)
  ) %>%
  mutate(
    commitments = commitments/1000000
  )

# Save the processed data in a file that the Shiny app can load.
write_csv(housing_finance_data, file.path("data", "housing-finance.csv"))
