This repository contains the codes to produce various figures indicating labor market polarization in aggregate level and MSA level considering all workers and only US-born workers. \
**References**: Figure 7 in Autor (2019), Figure 7 in Davis et al. (2020).

## Data Source
### Main Census Data
Following Autor (2019), we use U.S. Census of Population data for 1970, 1980, 1990, and 2000, and pooled American Community Survey (ACS) data for years 2014 through 2016, 
sourced from [IPUMS USA Ruggles et al. (2020)](https://usa.ipums.org/usa/index.shtml).
* Important variables:
  * YEAR	Census year
  * STATEFIP	State (FIPS code)
  * COUNTYFIP	County (FIPS code)
  * CNTYGP98	County group, 1980. **Note**: only for 1980 due to the missing county FIPS code.
  * Person weight
  * AGE	Age. **Note**: consider 16-64 workers.
  * BPL (general)	Birthplace [general version]. **Note**: bpl<100 indicates US-born.
  * CLASSWKRD (detailed)	Class of worker [detailed version]. **Note**: to indicate non-public sectors.
  * OCC	Occupation
  * WKSWORK1	Weeks worked last year. **Note**: not available in 2014-2016 ACS and use "wkswork2" instead.
  * WKSWORK2	Weeks worked last year, intervalled
  * UHRSWORK	Usual hours worked per week 
  * INCWAGE	Wage and salary income

### Occupational Classification Crosswalk
All the crosswalk files are included in each section's data directory "dta\occ\..."
#### 1. "occ1990dd"
The occ1990dd occupation classification, developed by Prof Dorn, aggregates U.S. Census occupation codes to a balanced panel of occupations for the 1980, 1990, and 2000 Census, as well as 2005 ACS. 
For the year 2015, we used pooled ACS data 2014-2016 following Autor (2019), the Census occupation codes are divided by 10 and matched to crosswalk file of 2005 ACS.
The crosswalk files obtaining "occ1990dd" could be found on [Prof David Dorn's website](https://www.ddorn.net/data.htm), which are also included in the files "dta\occ\occ[year]_occ1990dd".

#### 2. PCS Classification
We need to match census occ codes for each year to "occ1990dd" and then match it to French classification PCS.
The crosswalk file matching "occ1990dd" to PCS codes are included in the file "dta\occ\occ1990dd_pcs".

### MSA Crosswalk
We first use 2015 MSAs definition because it changes over time and pin down each MSA population at 2015 as run variable. 
We use county groups to match 1980 MSAs and state & county FIPS codes to match 1990-2015 MSAs. 
For Jul. 2015 [definition](https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html) and [population](https://www.census.gov/data/tables/time-series/demo/popest/2010s-total-metro-and-micro-statistical-areas.html) data, we collect the data from the website of US Census Bureau. 
The cleaned MSA crosswalk files are included in "dta\msa_list_2015" and MSA names for plotting "dta\cityname".

## Sections
### 1. Private Occ
The directory includes the codes for producing **the Percentage Point Changes of High and Middle-paid in MSAs**, 1990-2015 and 1980-2015, for (1) workers for wages or salary in private sectors "private"; (2) broader workers in non-public sectors "nonpubic". Specially, in do files:
* "msa[year].do" is for cleaning the original census data and merging occ definitions to calculate employment shares for each MSA and each year. **Note**: the outputs are saved in "...\dta\shempl\shempl_[year]".
* "2merge_all.do" is the second step to merge 1980-2015 year data together to form a panel and add the run variable MSA population in 2015. **Note**: the outputs are saved in "...\dta\workfile9015_(USborn)_..."
* "3plot_change.do" is the third step to calculate the changes for L, M, H jobs and plot. **Note**: the figures are saved in "...\dta\fig" and "...\dta\gph".
* "4ttest.do" is the forth step to obtain the t-statistics to test the changes.

### 2. Private&Public Occ
This section is distinct from **1. Private Occ** regarding the treatment of raw census dataset (whether include all occupations or just non-public occupations). The directory also includes smoothing kernal plots instead of bin-scattered plots.

### 3. Reproduce Autor
The directory includes codes (data treatment) and cleaned datasets in order to reproduce Fig 7 in Autor (2019) from raw census datasets.

## Potential Issues
### 1. The degree of polarization is relatively small using PCS definition.

