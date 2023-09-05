# Status of Livelihoods and economies Update

In 2023 we cleaned and prepped the best available data for all sectors and components included in this goal. When newly updated data wasn't available, we re-downloaded and cleaned the previous data source. The old versions of the data prepped by OHI were stored was no longer accessible on All of the cleaned files are now saved in the folder `~/ohiprep_v2023/globalprep/le/v2023/int` in the format sector_component.csv.

More detailed methods and explanations are available in the livelihoods_economies_dataprep.RMD saved in `~/ohiprep_v2023/globalprep/le/v2023`. File paths and data download instructions are also included in the RMD. Included below is a summarry of what was done and what still needs to be done.

For all datasets, except tourism revenue, the current format has one value for each country and year included in the dataset. Tourism uses a pre-cleaned version of the revenue data, so countries have already been converted to regions. We did not do any gapfilling to fill in countries missing from the final data sets, so this will likely need to be done for most of the included data.

# Revenue:

Value in each of these data sets is the total estimated revenue per country in us dollars

### Tourism:

### Fishing (originally Commercial Fishing)

-   This component which was previously just commercial fishing, and has been updated to include all fishing included in the fao capture production database, as this was the best available data source.
-   The capture production database was subset to only marine areas, to ensure that inland fishing was not included.
-   Since the capture production database did not include value we used the ex-vessel price database (acquired from emlab). Which had a yearly global price per ton for each species. This data is derived from the fao commodities database so the species overlapped significantly with those in the fao capture data. I gapfilled this data set using a linear model for each species based on year, and then gapfilled further using an average for isscaap_group. For roughly 5% of species we were not able to gapfill, and no price value was included.

###  Marine Mammal Watching

-   No new data was available for this sector, so previous data from O'Connor et al 2009 was used
-   Data was extracted from a pdf of this paper stored on MAZU
-   For revenue data we attempted to replicate the methods described in the OHI supplemental methods, this involved quantifying the percent of marine mammal watching that was marine vs freshwater, and then multiplying this by total revenue to find total marine revenue.
-   Unlike the other revenue components, value in this data set already includes indirect revenue as this was given in the paper.

### Aquarium Fishing

-   The original data source for aquarium fishing revenue had been updated since this goal was originally calculated: FAO global trade value data.
-   Revenue data was prepared as is described in the methods: export data from the FAO Global Commodities database for 'Ornamental fish' for all available years, ornamental freshwater fish were excluded.

### Mariculture

-   The original data source for revenue from mariculture had been updated. FAO (Aquaculture value).
-   Total revenue from mariculture was calculated by summing value of all marine/brackish species.

### Ocean and Offshore Energy (originally Wave and Renewable Energy)

-   A new data source from OECD was used
-   we used the indicator "All ocean and offshore energy (offshore wind + ocean energy) RD&D, million USD 2021 PPP"
-   The Ocean energy data from OECD is actually the amount country and state governments budget for Ocean energy, and is not specifically revenue. However, it is included as this was the only comprehensive data set available with monetary amounts related to Ocean energy, it may potentially be modified to use as a proxy for revenue.
-   This data set only contains 32 countries, so gap filling will be needed.

# Jobs:

### Fishing

-   We used People employed in fishing sectors excluding inland fisheries, total by occupation rate, thousands from OECD as the primary data set. Additional countries were filled in using the number of fishers data from the FAO 2019 statistical report.
-   It is worth noting that using a value of 1 job for all employment is different from the original methods. Previously these methods were used: "Employment is disaggregated into full-time, parttime, occasional, and unspecified statuses. These categories are defined as full time workers having \> 90% of their time or livelihood from fishing/aquaculture, part time workers are between 30-90% time (or 30-90% of their livelihood) and occasional workers are \< 30% time. Unspecified status workers could fall anywhere from 0-100% time. Taking the midpoints of those ranges, we assume that 1 part time worker = 0.6 full time workers, 1 occasional worker = 0.15 full time workers, and 1 unspecified worker = 0.5 full time workers, which we used as a weighting scheme for determining total numbers of jobs."

A disaggregation version of the OECD data can be found in OECD's [Employment in fisheries, aquaculture and processing Database](#0) if needed. We did not use the dis-aggregated data when preparing this data, as the disaggregated numbers were not available for the FAO data which was used to gapfill.

### Mariculture

-   We used OECD data on people employed in aquaculture sector (marine and inland), total by occupation rate, thousands.

-   Because this data included both marine and inland values, we estimate the proportion of total aquaculture jobs that can be attributed to marine and brackish aquaculture, we used country-specific proportions of marine and brackish aquaculture revenues (compared to total revenues) calculated from FAO aquaculture production value data set.

-   See note in fishing about data disaggregation for fulltime, partime, occassional and status unspecified.

### Fishery Processing

-   Data for the fishery processing sector is from the OECD Sustainable Economies database. We use the variable. People employed in fishery processing sector (marine and inland), total by occupation rate, thousands

-   Due to timing constraints we did not determine a method to subset this data to only marine related fishery processing. This will needed to be added to cleaning script.

### Tourism

### Marine Renewable Energy

-   Data for marine renewable energy was previously only available for two countries, one was obtained through a news release, the other through personal communication. We were not able to use this old data or find an updated data source.

# Wages:

### Oww Database

-   The last year of data available is 2008, however this is still an update from the original livelihoods calculations as the methods state we originally used a version of the database that stopped in 2003.
-   I performed only minimal cleaning of this data- as some of the cleaning relies on determining next steps:
    -   The methods state that we need to: divided by the inflation conversion factor for 2010 so that wage data across years would be comparable (<http://oregonstate.edu/cla/polisci/sahr/sahr>),
    -   then multiplied by the purchasing power parity-adjusted per capita gdp (ppppcgdp, WorldBank).
    -   The adjusted wage data were then multiplied by 12 to get annual wages
    -   I did not complete these steps as I assume it is likely we will be using an inflation conversion factor for a year other than 2010.
    -   An additional data set that is available is the ilo data set, which has fishing sector wages through 2022. I didn't include this data for consistency reasons, since all other sector wage data was available only until 2008, and the interpolation methods may not be the same between data sets. However this data set is stored on MAZU in case it is needed in the future, it can be found at "/home/shares/ohi/git-annex/globalprep/\_raw_data/ILOSTAT/d2023/ILO_earnings_economic.csv" if needed in the future.
