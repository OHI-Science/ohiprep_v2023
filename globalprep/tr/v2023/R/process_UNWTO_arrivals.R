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
  group_by(country, year) %>% # group by county and year
  mutate(
    tourism_arrivals_ct = ifelse(
      metric == "Total arrivals" & is.na(tourism_arrivals_ct) &
        any(!is.na(tourism_arrivals_ct[metric %in% c("Overnights visitors (tourists)", "Same-day visitors (excursionists)")])),
      tourism_arrivals_ct[metric %in% c("Overnights visitors (tourists)", "Same-day visitors (excursionists)")],
      tourism_arrivals_ct # fill total with values from Overnights or Same-day because it is not autofilled: Total originally is either a value on its own or the sum of Overnights and Same-day but must have both
    )
  ) %>% # v2023: NAs go from 11052 to 9111 out of 24084 observations
  ungroup() %>% # ungroup since not needed anymore
  filter(metric == "Total arrivals") %>% # v2023: NAs are 602 out of 6021 observations once going down to only the total metric
  select(-metric) %>% # don't need metric since we are down to one
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
  group_by(rgn_id, year) %>%
  summarize(sum_fix = ifelse(all(is.na(tourism_arrivals_ct)), NA, sum(tourism_arrivals_ct, na.rm = TRUE))) %>%
  mutate(method = ifelse(!is.na(sum_fix), "UNWTO", NA)) %>%
  rename(tourism_arrivals_ct = sum_fix)