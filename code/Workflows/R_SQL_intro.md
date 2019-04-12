Getting Data Efficiently from Microsoft Access Databases into R
================
Kristen Sauby, Florida Fish and Wildlife Conservation Commission,
April 12, 2019

-   [Initial Setup](#initial-setup)
    -   [Verify that you are running 32-bit R](#verify-that-you-are-running-32-bit-r)
    -   [Verify that neccessary drivers are installed](#verify-that-neccessary-drivers-are-installed)
        -   [Via R](#via-r)
        -   [Via the ODBC Data Source Administrator](#via-the-odbc-data-source-administrator)
    -   [Installing the Microsoft Access Driver (If Necessary)](#installing-the-microsoft-access-driver-if-necessary)
-   [Connecting to a Microsoft Access Database in R](#connecting-to-a-microsoft-access-database-in-r)
-   [Working With Data From the Database](#working-with-data-from-the-database)
    -   [Read in a Table](#read-in-a-table)
    -   [Manipulate the Data Using `dplyr`](#manipulate-the-data-using-dplyr)
    -   [Merging Tables](#merging-tables)

Initial Setup
=============

You'll need the "odbc" package, which will allow you to set up a connection between R and your database.

``` r
install.packages("odbc")
```

Next, load that package:

``` r
library(odbc)
```

Verify that you are running 32-bit R
------------------------------------

Since we are running 32-bit Microsoft Access on our machines, we also need to verify that we are running 32-bit R. This is easy to verify in RStudio. Go to Tools, then select Global Options.

<img src="https://github.com/kristen-sauby/R_SQL_Workflows/blob/master/code/Workflows/GlobalOptions.png" width="35%" />

Then, if necessary, change the version of R that you are running to the 32-bit version.

<img src="https://github.com/kristen-sauby/R_SQL_Workflows/blob/master/code/Workflows/RStudio32bit.jpg" width="75%" />

Verify that neccessary drivers are installed
--------------------------------------------

### Via R

Examine which drivers are available on your computer. Make sure that "Micorsoft Access Driver (\*.mdb, \*accdb)" is listed.

``` r
sort(unique(odbcListDrivers()[[1]]))
```

    ##  [1] "Driver da Microsoft para arquivos texto (*.txt; *.csv)"
    ##  [2] "Driver do Microsoft Access (*.mdb)"                    
    ##  [3] "Driver do Microsoft dBase (*.dbf)"                     
    ##  [4] "Driver do Microsoft Excel(*.xls)"                      
    ##  [5] "Driver do Microsoft Paradox (*.db )"                   
    ##  [6] "Microsoft Access-Treiber (*.mdb)"                      
    ##  [7] "Microsoft Access dBASE Driver (*.dbf, *.ndx, *.mdx)"   
    ##  [8] "Microsoft Access Driver (*.mdb)"                       
    ##  [9] "Microsoft Access Driver (*.mdb, *.accdb)"              
    ## [10] "Microsoft Access Text Driver (*.txt, *.csv)"           
    ## [11] "Microsoft dBase-Treiber (*.dbf)"                       
    ## [12] "Microsoft dBase Driver (*.dbf)"                        
    ## [13] "Microsoft Excel-Treiber (*.xls)"                       
    ## [14] "Microsoft Excel Driver (*.xls)"                        
    ## [15] "Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)"
    ## [16] "Microsoft ODBC for Oracle"                             
    ## [17] "Microsoft Paradox-Treiber (*.db )"                     
    ## [18] "Microsoft Paradox Driver (*.db )"                      
    ## [19] "Microsoft Text-Treiber (*.txt; *.csv)"                 
    ## [20] "Microsoft Text Driver (*.txt; *.csv)"                  
    ## [21] "ODBC Driver 11 for SQL Server"                         
    ## [22] "SQL Server"                                            
    ## [23] "SQL Server Native Client 11.0"

### Via the ODBC Data Source Administrator

Go to the Windows start menu and find search.

<img src="https://github.com/kristen-sauby/R_SQL_Workflows/blob/master/code/Workflows/Windows_search.png" width="30%" />

Type "odbc". An option should show up allowing you to click "ODBC Data Sources." Click it.

<img src="https://github.com/kristen-sauby/R_SQL_Workflows/blob/master/code/Workflows/odbc.png" width="30%" />

A window will open showing you a list of "User Data Sources." Make sure that the driver "Micorsoft Access Driver (\*.mdb, \*accdb)" is listed.

<img src="https://github.com/kristen-sauby/R_SQL_Workflows/blob/master/code/Workflows/drivers.png" width="60%" />

Installing the Microsoft Access Driver (If Necessary)
-----------------------------------------------------

If the appropriate driver is not installed on your computer, contact your IT contact person to download and install the ["AccessDatabaseEngine.exe"](https://www.microsoft.com/en-us/download/details.aspx?id=54920 "Access Database Engine").

<!--  ## Accessing Microsoft Access Database with .accdb File Extension



## Accessing Microsoft Access Database with .mdb File Extension

Next, make sure that you are running *32-bit* R. In RStudio, go to Tools -> Global Options, and then at the top of the window it will give you the option to change to change the R version. Change it to 32-bit, and restart R.


```r
# this works but doesn't get it in a format usable by dplyr
con <- odbcDriverConnect('Driver={Microsoft Access Driver (*.mdb)};DBQ=C:/Users/Kristen.Sauby/Desktop/Nightlight_20181011.mdb')
```
-->
Connecting to a Microsoft Access Database in R
==============================================

Next, we tell R how to connect with our database, and then assign that database to a name (in this example, "jackalope"). The "Dbq" string tells R exactly where the database is stored. Make sure to change the file path to the file path of your database. You can download the example "EasternJackalope" Access Database [here](https://github.com/kristen-sauby/R_SQL_Workflows/blob/master/EasternJackalope.accdb "Eastern Jackalope Data! =D").

``` r
jackalope <- dbConnect(
    drv = odbc::odbc(), 
    .connection_string = "Driver={Microsoft Access Driver (*.mdb, *.accdb)}; Dbq=C:/Users/Kristen.Sauby/Documents/Projects/Data_Management_Workflows/R_SQL_Workflows/EasternJackalope.accdb"
)
```

Next, we can use the `dbListTables` function to show us the tables that are now available because of our database connection. The tables that we are interested in are "JackalopeInfo" and "JackalopeSurveys."

``` r
dbListTables(jackalope)
```

    ##  [1] "MSysAccessStorage"          "MSysACEs"                  
    ##  [3] "MSysComplexColumns"         "MSysIMEXColumns"           
    ##  [5] "MSysIMEXSpecs"              "MSysNameMap"               
    ##  [7] "MSysNavPaneGroupCategories" "MSysNavPaneGroups"         
    ##  [9] "MSysNavPaneGroupToObjects"  "MSysNavPaneObjectIDs"      
    ## [11] "MSysObjects"                "MSysQueries"               
    ## [13] "MSysRelationships"          "MSysResources"             
    ## [15] "JackalopeInfo"              "JackalopeSurveys"

Working With Data From the Database
===================================

Now that we have established a connection to our database, we can start working with the actual data.

Read in a Table
---------------

We can use the `dbReadTable` in the `DBI` package to read tables into R.

``` r
library(DBI)

JackalopeSurveys <- dbReadTable(jackalope, "JackalopeSurveys")
head(JackalopeSurveys)
```

    ##   Field1 IDNumber          SurveyDate   Weight
    ## 1      1        1 2000-01-01 00:00:00 8186.471
    ## 2      2        1 2000-02-01 00:00:00 8154.164
    ## 3      3        1 2000-03-01 00:00:00 8175.970
    ## 4      4        1 2000-04-01 00:00:00 8128.347
    ## 5      5        1 2000-05-01 00:00:00 8126.915
    ## 6      6        1 2000-06-01 00:00:00 8110.983

Manipulate the Data Using `dplyr`
---------------------------------

First, load the "dplyr" and "dbplyr" packages. The "dplyr" package allows us to process our data by sorting, arranging, and selecting our data. The "dbplyr" package allows the "dplyr" package to work with data in a database.

``` r
library(dplyr)
library(dbplyr)
```

As an example, let's summarize the data in the "JackalopeSurveys" table.

``` r
# load dplyr to run queries

q1 <- tbl(jackalope, "JackalopeSurveys") %>%
  group_by(IDNumber) %>%
  summarise(
    AverageWeight = mean(Weight)
  )
q1
```

    ## # Source:   lazy query [?? x 2]
    ## # Database: ACCESS
    ## #   12.00.0000[admin@ACCESS/C:/Users/Kristen.Sauby/Documents/Projects/Data_Management_Workflows/R_SQL_Workflows/EasternJackalope.accdb]
    ##   IDNumber AverageWeight
    ##      <int>         <dbl>
    ## 1        1         8147.
    ## 2        2         8447.
    ## 3        3         8931.
    ## 4        4         9456.
    ## 5        5         5036.
    ## 6        6         6650.

R will also translate our R code into an SQL query using the `show_query` function:

``` r
show_query(q1)
```

    ## <SQL>
    ## SELECT `IDNumber`, AVG(`Weight`) AS `AverageWeight`
    ## FROM `JackalopeSurveys`
    ## GROUP BY `IDNumber`

Merging Tables
--------------

We can also easily merge tables. For example, let's merge the `JackalopeInfo` and `JackalopeSurveys` tables so that we can group the weight information by the sex of the jackalopes.

``` r
Jackalopes <- tbl(jackalope, "JackalopeInfo") %>%
    merge(
        tbl(jackalope, "JackalopeSurveys"), 
        by="IDNumber"
    )
head(Jackalopes)
```

    ##   IDNumber sex           Site Field1          SurveyDate   Weight
    ## 1        1   M Paynes Prairie      1 2000-01-01 00:00:00 8186.471
    ## 2        1   M Paynes Prairie      2 2000-02-01 00:00:00 8154.164
    ## 3        1   M Paynes Prairie      3 2000-03-01 00:00:00 8175.970
    ## 4        1   M Paynes Prairie      4 2000-04-01 00:00:00 8128.347
    ## 5        1   M Paynes Prairie      5 2000-05-01 00:00:00 8126.915
    ## 6        1   M Paynes Prairie      6 2000-06-01 00:00:00 8110.983

Now we can do fun things with our data, like analysis or plotting.
