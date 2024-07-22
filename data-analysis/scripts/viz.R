source('functions.R')

df <- read_csv('data/all_complaint-filings_with-locations.csv')

test_cases <- df %>% 
  filter(year(sitdtrcv) == 2019) %>%
  pull(Case_Number)

temp_df <- df %>%
  filter(Case_Number %in% test_cases)

temp_df['Time_Elapsed'] <- (temp_df$sdtstat - temp_df$sitdtrcv)

temp_df <- temp_df %>%
  select(Case_Number,
         Case_Status,
         Subject_Primary_DESC,
         Subject_Secondary_DESC,
         Facility_Occurred,
         sdtstat,
         sitdtrcv,
         Status_Reasons,
         Time_Elapsed)

temp_df <- temp_df %>% arrange(sitdtrcv) %>% arrange(Case_Number)

temp_df['Occurrence'] <- NA
temp_df['So_Far'] <- NA
for (i in 1:length(temp_df$Case_Number)) {
  message(i/length(temp_df$Case_Number))
  so_far <- temp_df[c(1:i-1),]
  other_occurrences <- which((so_far %>% pull(Case_Number)) == temp_df[i,]$Case_Number)
  temp_df[i,]$Occurrence <- length(other_occurrences) + 1
  temp_df[i,]$So_Far <- so_far %>%
    filter(Case_Number == temp_df[i,]$Case_Number) %>%
    arrange(sitdtrcv) %>%
    pull(Time_Elapsed) %>%
    sum()
}

unique_cases <- temp_df$Case_Number %>% unique()
case_indices <- as.data.frame(matrix(ncol=3,nrow=length(unique_cases)))
colnames(case_indices) <- c('Case_Number','totOccurrences','lastStatus')
case_indices$Case_Number <- unique_cases

case_indices$totOccurrences <- case_indices$Case_Number %>% lapply(function(x) {return(length(which(temp_df$Case_Number == x)))}) %>% unlist()

for (i in 1:length(case_indices$Case_Number)) {
  message(i/length(case_indices$Case_Number))
  case_indices[i,]$lastStatus <- temp_df %>%
    filter(Case_Number == case_indices[i,]$Case_Number) %>%
    arrange(sdtstat) %>%
    pull(Case_Status) %>%
    last()
}

temp_df <- left_join(temp_df,case_indices,by='Case_Number')

temp_df <- temp_df %>% arrange(lastStatus) %>% arrange(totOccurrences)

unique_cases <- temp_df$Case_Number %>% unique()
case_indices <- as.data.frame(matrix(ncol=2,nrow=length(unique_cases)))
colnames(case_indices) <- c('Case_Number','posIndex')
case_indices$Case_Number <- unique_cases
case_indices$posIndex <- 1:length(unique_cases)

temp_df <- left_join(temp_df,case_indices,by='Case_Number')

temp_df <- temp_df %>% rename(totStages = totOccurrences)

# analysis

# Of the 41,617 unique cases to reach a final resolution in the year 2019, 41% were initially rejected and sent back to inmates without resolution.
temp_df %>% 
  filter(Occurrence == 1) %>% 
  filter(Case_Status == 'Rejected') %>% 
  pull(Case_Number) %>%
  unique() %>%
  length()

# The most common reason for rejection was improper level — an attempt by the inmate to file a complaint directly with the BOP Regional Director without first filing with their own warden. 
# 2,292 complaints were rejected after reviewers determined that they did not qualify as 'sensitive.' 
temp_df %>% 
  filter(Occurrence == 1) %>% 
  filter(Case_Status == 'Rejected') %>% 
  pull(Status_Reasons) %>%
  str_split(',') %>%
  unlist() %>%
  str_squish() %>%
  value_counts() %>%
  arrange(-N)

# An additional 27% of complaints were reviewed as valid filings but denied without relief. 
# Only 1.8% of complaints were granted on their first attempt.
temp_df %>%
  filter(Occurrence == 1) %>%
  pull(Case_Status) %>%
  value_counts() %>%
  arrange(-N)

# For every five cases rejected without a decision, only two were refiled.
temp_df %>% filter(Case_Number %in% (temp_df %>% 
                                       filter(Occurrence == 1) %>% 
                                       filter(Case_Status == 'Rejected') %>% 
                                       pull(Case_Number))) %>%
  filter(Occurrence == 2) %>%
  pull(Case_Number) %>%
  unique() %>%
  length()

refile_nums <- temp_df %>% filter(Case_Number %in% (temp_df %>% 
                                                      filter(Occurrence == 1) %>% 
                                                      filter(Case_Status == 'Rejected') %>% 
                                                      pull(Case_Number))) %>%
  filter(Occurrence == 2) %>%
  pull(Case_Number) %>%
  unique()

target_rows <- 1:79454

target_rows <- target_rows[(target_rows %in% which(temp_df$Case_Number %in% refile_nums)) & (target_rows %in% which(temp_df$Occurrence == 2))]

temp_df['Refile'] <- NA

temp_df[target_rows,]$Refile <- TRUE

export_df <- temp_df %>%
  select(Case_Number,
         Case_Status,
         Status_Reasons,
         Time_Elapsed,
         Occurrence,
         So_Far,
         lastStatus,
         posIndex,
         Refile)


# write to viz
write.csv(export_df,'../project2/data/viz-data.csv',row.names=FALSE)

# Those that did choose to appeal - sometimes several times - could expect to wait an average of two to three months for a final decision.
appealed_df <- temp_df %>%
  filter(totStages > 1)

unique_cases <- unique(appealed_df$Case_Number)

case_resolve_times <- as.data.frame(matrix(ncol=2,nrow=length(unique_cases)))
colnames(case_resolve_times) <- c('Case','Resolve_Time')
case_resolve_times$Case <- unique_cases
for (i in 1:length(case_resolve_times$Case)) {
  message(i/length(case_resolve_times$Case))
  case_resolve_times[i,]$Resolve_Time <- temp_df %>%
    filter(Case_Number == case_resolve_times[i,]$Case) %>%
    pull(Time_Elapsed) %>%
    sum()
}

#By the end of the appeal process, only 3% of cases were granted remediation.
temp_df %>% filter(Case_Status == 'Closed Granted') %>% pull(Case_Number) %>% unique() %>% length()
temp_df %>% pull(Case_Number) %>% unique() %>% length()




