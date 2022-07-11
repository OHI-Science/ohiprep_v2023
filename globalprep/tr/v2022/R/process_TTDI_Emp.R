



ttdi_emp <- ttdi_raw %>%
  filter(Title %in% c("T&T industry Share of Employment, % of total employment",
                      "T&T industry Employment, 1,000 jobs"),
         Attribute == "Value",
         Edition == "2019") %>% 
  select(Title, Albania:Zambia) %>% 
  # currently Zambia is the last country column - this may need to change in the future if countries are added (e.g. Zimbabwe)
  pivot_longer(cols = Albania:Zambia, names_to = "country",
               values_to = "value") %>% 
  mutate(value = as.numeric(value)) %>% 
  pivot_wider(names_from = Title, values_from = value) %>% 
  rename("jobs_pct" = "T&T industry Share of Employment, % of total employment",
         "jobs_ct" = "T&T industry Employment, 1,000 jobs") %>% 
  mutate(jobs_ct = round(jobs_ct * 1000))


