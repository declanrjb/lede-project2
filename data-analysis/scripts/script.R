source('functions.R')

#semantra
# use machine learning to search for concepts
# follow a specific case
# keep it granular

df <- read_csv('data/all_complaint-filings_with-locations.csv')

prog_df <- df %>%
  filter(year(sitdtrcv) %in% 2015:2019)

prog_df <- prog_df %>% 
  select(Case_Number,
         Subject_Primary_DESC,
         sdtstat,
         sitdtrcv,
         Case_Status
  )

prog_df['Statuses_Ordered'] <- NA
prog_df['First_Filed'] <- NA
prog_df['Last_Resolved'] <- NA

for (i in 1:length(prog_df$Case_Number)) {
  message(i/length(prog_df$Case_Number))
  prog_df[i,]$Statuses_Ordered <- prog_df[i,]$Case_Number %>% get_statuses(prog_df) %>% paste(collapse=', ')
  prog_df[i,]$First_Filed <- prog_df[i,]$Case_Number %>% first_filed(prog_df)
  prog_df[i,]$Last_Resolved <- prog_df[i,]$Case_Number %>% last_resolved(prog_df)
}

write.csv(prog_df,'data/prog_df.csv',row.names=FALSE)

prog_df <- read_csv('data/prog_df.csv')

prog_df <- prog_df %>% unique()

# closed granted but not final status 1.5% of cases

prog_df <- prog_df %>% 
      select(Case_Number,
             Subject_Primary_DESC,
             First_Filed,
             Last_Resolved,
             #Subject_Secondary_DESC,
             #Org_Level,
             #Facility_Occurred,
             #Status_Reasons,
             Statuses_Ordered
             ) %>% 
      unique()

prog_df['Number_Statuses'] <- prog_df$Statuses_Ordered %>% str_split(',') %>% lapply(length) %>% unlist()

prog_df['Last_Status'] <- prog_df$Statuses_Ordered %>% str_split_i(',',-1) %>% str_squish()

prog_df['Case_Appearances'] <- unlist(lapply(prog_df$Case_Number,function(x) {return(length(which(prog_df$Case_Number == x)))}))


prog_df %>% 
  pull(Statuses_Ordered) %>% 
  str_split_i(', ',1) %>% 
  str_squish() %>% 
  value_counts() %>% 
  arrange(-N)

# most of the non-uniques appear to be changes to secondary description between filings, about 3% of the data above