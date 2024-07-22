statuses <- df %>% 
  pull(Case_Status) %>% 
  value_counts() %>%
  arrange(-N)

df %>% 
  pull(Facility_Occurred) %>% 
  value_counts() %>%
  arrange(-N)

df %>% 
  filter(year(sitdtrcv) >= 2023) %>%
  pull(Facility_Occurred) %>% 
  value_counts() %>%
  arrange(-N)

length(which(prog_df %>% filter(grepl('Closed Granted',Statuses_Ordered)) %>% pull(Last_Status) != 'Closed Granted'))

dim(prog_df %>% filter(grepl('Closed Granted',Statuses_Ordered)))

prog_df %>% filter(grepl('Closed Granted',Statuses_Ordered)) %>% pull(Last_Status) %>% value_counts() %>% arrange(-N)

test <- prog_df %>% arrange(-Number_Statuses)

prog_df %>% filter(Number_Statuses >= 10) %>% pull(Subject_Primary_DESC) %>% value_counts() %>% arrange(-N)

dim(prog_df %>% 
      select(Case_Number,
             Subject_Primary_DESC,
             Subject_Secondary_DESC,
             Org_Level,
             Facility_Occurred,
             Status_Reasons,
             Statuses_Ordered,
             Number_Statuses,
             Last_Status) %>% 
      unique())

prog_df %>% 
  select(Case_Number,
         Subject_Primary_DESC,
         Subject_Secondary_DESC,
         Org_Level,
         Facility_Occurred,
         Status_Reasons,
         Statuses_Ordered,
         Number_Statuses,
         Last_Status) %>% 
  pull(Case_Number) %>%
  unique() %>%
  length()