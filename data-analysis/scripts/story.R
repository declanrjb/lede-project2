source('functions.R')

df <- read_csv('data/all_complaint-filings_with-locations.csv')

# In early May 2019, an inmate at the Schuykill Correctional Facility in Pennsylvania filed a complaint against prison authorities for alleged "forced medical treatment."
story_df <- df %>% 
  filter(Case_Number == 977328)

story_df <- story_df %>% 
  arrange(sitdtrcv)

fac_counts <- df %>% 
  pull(Facility_Occurred) %>% 
  value_counts %>% 
  arrange(-N)

fac_counts <- df %>% stat_by_cat('Facility_Occurred',
            function(x) {
              x %>%
                pull(Case_Number) %>%
                unique() %>%
                length() %>%
                as.data.frame() %>%
                return()
            })

rej_rates <- df %>% stat_by_cat('Facility_Occurred',
                                function(x) {
                                  x %>%
                                    pull(Case_Number) %>%
                                    unique() %>%
                                    lapply(most_recent_status,df) %>%
                                    unlist() %>%
                                    value_counts() %>%
                                    return()
                                })

# Since the year 2000, inmates have filed more than 130 thousand complaints alleging forced medical treatment, the third most common complaint type after housing appeals and staff misconduct. 
case_types <- df %>% 
  stat_by_cat('Subject_Primary_DESC',
              function(x) {
                x %>%
                  pull(Case_Number) %>%
                  unique() %>%
                  length() %>%
                  as.data.frame() %>%
                  return()
              }) %>%
  rename(Unique_Cases = '.') %>% 
  normalize('Unique_Cases') %>%
  arrange(-Unique_Cases)

case_types$Subject_Primary_DESC <- case_types %>% 
  pull(Subject_Primary_DESC) %>% 
  str_to_title()

case_types %>% write.csv('viz_output/case_types.csv',row.names=FALSE)

# total number of medical cases
df %>%
  filter(Subject_Primary_DESC == 'MEDICAL-EXC. FORCED TREATMENT') %>%
  pull(Case_Number) %>%
  unique() %>%
  length()

# 79% eventually received some kind of decision
df %>%
  filter(Subject_Primary_DESC == 'MEDICAL-EXC. FORCED TREATMENT') %>%
  filter(Case_Status != 'Rejected') %>%
  pull(Case_Number) %>%
  unique() %>%
  length()

df %>%
  filter(Subject_Primary_DESC == 'MEDICAL-EXC. FORCED TREATMENT') %>%
  filter(Case_Status == 'Closed Granted') %>%
  pull(Case_Number) %>%
  unique() %>%
  length()



common_types <- case_types %>%
  arrange(-Unique_Cases) %>%
  pull(Subject_Primary_DESC) %>%
  .[1:10]

# For every hundred such medical complaints, only about seven were ultimately granted.
# Complaints relating to "SEARCHES AND USE OF RESTRAINTS," for example, are granted only about 2% of the time. 
grant_rates <- df %>% 
  stat_by_cat('Subject_Primary_DESC',
                                function(x) {
                                  ((x %>%
                                    filter(Case_Status == 'Closed Granted') %>%
                                    pull(Case_Number) %>%
                                    unique() %>%
                                    length()) /
                                    (x %>% 
                                       pull(Case_Number) %>%
                                       unique() %>%
                                       length())) %>%
                                    as.data.frame() %>%
                                    return()
                                }) %>%
  rename(Grant_Rate = '.')

grant_rates['Granted_Per_Hundred'] <- grant_rates$Grant_Rate * 100
grant_rates %>% 
  arrange(-Grant_Rate) %>%
  .[c(1:5),] %>%
  write.csv('viz_output/top_grant_rates.csv',row.names=FALSE)
grant_rates %>% 
  arrange(Grant_Rate) %>%
  .[c(1:5),] %>%
  write.csv('viz_output/lowest_grant_rates.csv',row.names=FALSE)

# Secondary subjects tied to FSA cases included "FSA ELIGIBILITY" and "FSA - PROGRAMMING / INCENTIVES." 
df %>% filter(Subject_Primary_DESC == 'FSA') %>% pull(Subject_Secondary_DESC) %>% value_counts()

# Accepted cases are exceedingly rare, and appear to mark only filings that were actively under consideration at the moment the BOP exported data from its internal system.
# Of the 1.78 million case tickets filed since 2000, nearly seven hundred thousand were rejected
df %>% 
  pull(Case_Status) %>%
  value_counts() %>%
  arrange(-N)

all_rej_reasons <- rej_reasons <- df %>%
  filter(Case_Status == 'Rejected') %>%
  pull(Status_Reasons) %>%
  str_split(',') %>%
  unlist() %>%
  str_squish() %>%
  unique()

rej_reasons <- df %>%
  filter(Case_Status == 'Rejected') %>%
  pull(Status_Reasons) %>%
  str_split(',') %>%
  unlist() %>%
  str_squish() %>%
  value_counts() %>%
  arrange(-N)

status_reason_codes <- read_csv('data/status_reason_codes.csv')

rej_reasons <- left_join(rej_reasons,status_reason_codes,by=c('Val' = 'STATUS_CODE'))

# Nearly 28,000 complaints were rejected from consideration with the reason: "YOU DID NOT SIGN YOUR REQUEST OR APPEAL." 
sig_cases <- df %>% filter(grepl('SIG',Status_Reasons)) %>% pull(Case_Number) %>% unique()

sig_rejected <- df %>%
  filter(Case_Number %in% sig_cases) %>%
  pull(Case_Number) %>%
  value_counts()

# of those rejected for lacking a signature, 20% are never refiled
dim(sig_rejected %>% filter(N > 1))[1] / dim(sig_rejected)[1]

rej_reason_codes <- read_csv('hand_analysis/rej_reasons_cleaned.csv')

# A hand categorization of these codes and their associated narrative descriptions shows that more than 20% of rejected cases reference paperwork mistakes made by inmates, the second most common reason for rejection behind "OTHER."
rej_reason_cats <- rej_reason_codes %>% stat_by_cat('Category',function(x) {
  x %>%
    pull(N) %>%
    sum() %>%
    as.data.frame() %>%
    rename(Tot_Cases = '.') %>%
    return()
}) %>%
  normalize('Tot_Cases') %>%
  arrange(-Tot_Cases)

rej_reason_codes$Norm <- rej_reason_codes$Norm * 100
rej_reason_codes %>% write.csv('hand_analysis/rej_reasons_flourish.csv',row.names=FALSE)

df['Reason_Types'] <- df$Status_Reasons
for (i in 1:length(rej_reason_codes$Val)) {
  message(i)
  df$Reason_Types <- gsub(rej_reason_codes[i,]$Val,rej_reason_codes[i,]$Category,df$Reason_Types)
}

df['Reason_Types'] <- df %>%
  pull(Reason_Types) %>%
  str_split(',') %>%
  lapply(str_squish) %>%
  lapply(unique) %>%
  lapply(function(x) {return(paste(x,collapse=', '))}) %>%
  unlist()

rej_forms <- df %>% filter(Case_Status == 'Rejected') %>% filter(grepl('Forms',Reason_Types))
form_rej_cases <- rej_forms %>% pull(Case_Number) %>% unique()
form_case_reps <- df %>%
  filter(Case_Number %in% form_rej_cases) %>%
  pull(Case_Number) %>%
  value_counts()

#Of the hundreds of thousands of complaints rejected for paperwork mistakes, nearly 30% were never refiled.
form_case_reps %>%
  pull(N) %>%
  value_counts() %>%
  arrange(Val)

form_refiled <- form_case_reps %>% filter(N > 1) %>% pull(Val)
form_refiled_df <- df %>%
  filter(Case_Number %in% form_refiled)

form_refiled_fates <- form_refiled %>%
  lapply(get_statuses,form_refiled_df)

form_refiled_fate_vec <- form_refiled_fates %>% 
  lapply(function(x) {return(paste(x,collapse=', '))}) %>% 
  unlist()

# For those that did choose to refile, only five in every hundred were ultimately granted. 
length(which(grepl('Closed Granted',form_refiled_fate_vec))) / length(form_refiled_fate_vec)

df %>% filter(Case_Status %in% c('Accepted','Rejected')) %>% pull(Case_Number) %>% unique() %>% length()

  