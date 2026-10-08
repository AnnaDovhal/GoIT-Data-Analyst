# Cohort Analysis — PostgreSQL

## Overview

This project demonstrates a cohort analysis of user activity using PostgreSQL.

The analysis groups users into cohorts based on their registration month and tracks their activity over subsequent months. The SQL workflow also includes data cleaning and standardization of inconsistent date formats before performing the cohort analysis.

## Dataset

The analysis uses two raw datasets:

- `cohort_users_raw` — user registration data and promotional signup information
- `cohort_events_raw` — user activity events


## Analysis Objective

The main goal of the analysis is to understand user activity over time by:

- grouping users into monthly registration cohorts;
- tracking user activity after registration;
- calculating the number of months between registration and activity;
- comparing cohorts based on promotional signup status;
- counting unique active users for each cohort and month offset.

## Data Preparation

The raw data contains dates in different formats, including different separators and both two-digit and four-digit years.

The SQL script performs the following data cleaning steps:

- removes leading and trailing spaces using `TRIM`;
- extracts the date portion from datetime strings using `SPLIT_PART`;
- standardizes date separators using `REGEXP_REPLACE`;
- identifies different date formats using regular expressions;
- converts cleaned strings into dates using `TO_DATE`;
- excludes records with invalid or missing dates;
- removes test events;
- excludes events that occurred before user registration.

## Cohort Analysis

Users are grouped into cohorts based on their registration month.

The analysis calculates:

- `cohort_month` — month when the user registered;
- `activity_month` — month when the user performed an event;
- `month_offset` — number of months between registration and activity;
- `users_total` — number of unique users active in each cohort and month.

The analysis also separates users based on `promo_signup_flag`.

## SQL Techniques Used

- Common Table Expressions (CTEs)
- `CASE WHEN`
- `TRIM`
- `SPLIT_PART`
- `REGEXP_REPLACE`
- Regular expressions
- `TO_DATE`
- `DATE_TRUNC`
- `EXTRACT`
- Date calculations
- `JOIN ... USING`
- Filtering with `WHERE`
- `COUNT(DISTINCT ...)`
- `GROUP BY`
- `ORDER BY`

## Query Structure

The SQL analysis is organized into several steps:

1. **Explore the raw tables**
2. **Clean and standardize user registration dates**
3. **Clean and standardize event dates**
4. **Join users with their events**
5. **Calculate cohort and activity months**
6. **Calculate the month offset**
7. **Aggregate unique active users**
8. **Filter the analysis period and produce the final cohort dataset**

## Project Files

* `cohort_analysis.sql` — SQL query used to clean, transform, join, and aggregate the raw data.
* `cohort_analysis.xlsx` — spreadsheet containing the cohort tables and conclusion.
* `README.md` — project documentation.

## Tools

- PostgreSQL
- Data Cleaning
- Cohort Analysis
- Exploratory Data Analysis
  


