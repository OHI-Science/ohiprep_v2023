# process UNWTO arrivals in tourism data
file_path_unwto <- file.path(dir_M, "git-annex", "globalprep", "_raw_data", "UNWTO", paste0("d", version_year), "unwto-inbound-arrivals-data.xlsx")
unwto_arrivals <- readxl::read_xlsx(file_path_unwto, skip = 2) # read in the raw data

unwto_clean <- unwto_arrivals %>% 
  select(country = `Basic data and indicators`, total = `...6`, subdivision_1 = `...7`, subdivision_2 = `...8`, `1995`:`2021`) %>% # select relevant columns
  fill(country, .direction = "down") %>% # add country name to all data associated with that country
  pivot_longer(cols = c("total", "subdivision_1", "subdivision_2"),
               values_to = "metric",
               values_drop_na = TRUE) %>% # make the metrics into one column
  select(-name) %>% # get rid of the name column since it's just the titles of the metrics which are already there
  select(country, metric, everything()) %>% # reorder things
  replace_with_na_all(condition = ~.x == "..") %>% # swap .. with NAs
  pivot_longer(cols = 3:ncol(.), names_to = "year",
               values_to = "tourism_arrivals_ct") %>% # make the years not columns anymore
  pivot_wider(names_from = metric, values_from = tourism_arrivals_ct) %>%
  mutate(overnights = as.numeric(`Overnights visitors (tourists)`), 
         same_day = as.numeric(`Same-day visitors (excursionists)`), 
         total = as.numeric(`Total arrivals`),
         tourism_arrivals_ct = NA) %>% # rename metrics so easier to work with, make numeric, and add a new column to fill with the new calculated values later
  select(country, year, overnights, same_day, total, tourism_arrivals_ct) %>% # select columns needed for analysis (cruise passengers seem to be included in same-day)
  group_by(country, year) %>% # group by county and year
  mutate(
    tourism_arrivals_ct = case_when(
      # !is.na(overnights) & !is.na(same_day) ~ overnights + same_day, # when there are overngihts and same_day values, use the sum of those for tourism-related arrivals
      # !is.na(overnights) & is.na(same_day) ~ overnights, # when there is just overnights, use that value
      # !is.na(same_day) & is.na(overnights) ~ same_day, # when there is just same_day, use that value
      # is.na(same_day) & is.na(overnights) & !is.na(total) ~ total, # when there are neither of those values and a total value is available, use that (last resort because may include non-tourism related arrivals; total is often the sum of overnights and same_day, however)
      !is.na(overnights) ~ overnights,
      is.na(overnights) & !is.na(same_day) & !is.na(total) ~ total - same_day,
      TRUE ~ tourism_arrivals_ct
    )
  ) %>% # v2023: NAs are 601 out of 6021
  mutate(arrivals_method = ifelse(is.na(overnights) & !is.na(same_day) & !is.na(total), "UNWTO - subtraction", NA)) %>%
  mutate(arrivals_gapfilled = ifelse(arrivals_method == "UNWTO - subtraction", "gapfilled", NA)) %>% # prepare a "gapfilled" column to indicate "gapfilled" or NA
  ungroup() %>% # ungroup since not needed anymore
  select(country, year, tourism_arrivals_ct, arrivals_method, arrivals_gapfilled) %>% # select only needed columns
  mutate(country = str_to_title(country), # make countries look nice
         tourism_arrivals_ct = round(as.numeric(tourism_arrivals_ct) * 1000)) # since the units were in thousands

# get UNWTO data to have OHI region names
unwto_clean_names <- name_2_rgn(df_in = unwto_clean,
                                fld_name = 'country',
                                flds_unique = c('year'))
# v2023: no countries removed for not have any match in the lookup tables
# DUPLICATES found. Confirm your script consolidates these as appropriate for your data.
# 
# # A tibble: 11 × 1
# country                     
# <chr>                       
#   1 China                       
# 2 Guadeloupe                  
# 3 Guam                        
# 4 Hong Kong, China            
# 5 Macao, China                
# 6 Martinique                  
# 7 Montenegro                  
# 8 Northern Mariana Islands    
# 9 Puerto Rico                 
# 10 Serbia And Montenegro       
# 11 United States Virgin Islands

# fix duplicates
unwto_dupe_fix <- unwto_clean_names %>%
  group_by(rgn_id, year, arrivals_method, arrivals_gapfilled) %>%
  summarize(sum_fix = ifelse(all(is.na(tourism_arrivals_ct)), NA, sum(tourism_arrivals_ct, na.rm = TRUE))) %>%
  mutate(arrivals_method = ifelse(is.na(arrivals_method) & !is.na(sum_fix), "UNWTO", arrivals_method)) %>%
  rename(tourism_arrivals_ct = sum_fix)

# check out things so far
summary(unwto_dupe_fix) # v2023: 809 NAs in arrivals (before filtering the years down and gapfilling)

# gapfill arrivals
# downfill then upfill missing values
# use 2019 if available to fill 2021, then 2020 if not, to account for COVID-19
# v2023: check rgn_id 114, for example, for if choosing 2019 vs. 2020 worked
unwto_dupe_fix_downup_gf <- unwto_dupe_fix %>%
  group_by(rgn_id) %>%
  arrange(rgn_id, year) %>%
  mutate(tourism_arrivals_ct = ifelse(year == 2021 & is.na(tourism_arrivals_ct), lag(tourism_arrivals_ct, n = 2), tourism_arrivals_ct)) %>%
  fill(tourism_arrivals_ct, .direction = "downup") %>%
  mutate(arrivals_method = ifelse(is.na(arrivals_method) & !is.na(tourism_arrivals_ct), "nearby year", arrivals_method)) %>%
  mutate(arrivals_gapfilled = ifelse(arrivals_method == "nearby year", "gapfilled", arrivals_gapfilled)) %>%
  filter(year >= 2008) %>% # get only the year we need and beyond
  drop_na(tourism_arrivals_ct) # remove any remaining NAs (any remaining have all NAs for that region)

# check out things so far
summary(unwto_dupe_fix) # NAs should be 0 now