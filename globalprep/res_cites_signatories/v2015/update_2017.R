#### 2017 update for new ohi-global framework

library(dplyr)

data <- data.frame()

for (year in 2012:2015){ # year = 2012
  data_new <- read.csv(sprintf("globalprep/res_cites_signatories/v2015/data/rgn_cites_eez%s.csv", year))
  
  data_new <- data_new %>%
    mutate(year = year) %>%
    select(rgn_id, year, resilience_score)
  
  data <- rbind(data, data_new)
  
}

summary(data)
write.csv(data, "globalprep/res_cites_signatories/v2015/data/rgn_cites_eez_updated.csv", row.names=FALSE)

