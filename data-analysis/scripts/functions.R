library(tidyverse)

value_counts <- function(vec) {
  unique_vals <- unique(vec)
  
  result <- as.data.frame(matrix(ncol=3,nrow=length(unique_vals)))
  colnames(result) <- c("Val","N",'Norm')
  
  result$Val <- unique_vals
  
  result$N <- result$Val %>%
    lapply(function(x) {return(length(which(vec == x)))}) %>%
    unlist()
  
  result$Norm <- result$Val %>%
    lapply(function(x) {return(length(which(vec == x))/length(vec))}) %>%
    unlist()
  
  return(result)
}

get_statuses <- function(casenmbr,df) {
  status_vec <- df %>% 
    filter(Case_Number == casenmbr) %>%
    arrange(sdtstat) %>%
    pull(Case_Status)
  return(status_vec)
}

most_recent_status <- function(casenmbr,df) {
  statuses <- get_statuses(casenmbr,df)
  return(statuses[-1])
}

first_filed <- function(casenmbr,df) {
  result <- df %>% 
    filter(Case_Number == casenmbr) %>%
    arrange(sitdtrcv) %>%
    pull(sitdtrcv) %>%
    first()
  return(result)
}

last_resolved <- function(casenmbr,df) {
  result <- df %>% 
    filter(Case_Number == casenmbr) %>%
    arrange(sdtstat) %>%
    pull(sdtstat) %>%
    last()
  return(result)
}

stat_by_cat_single <- function(cat_val,df,cat_col,func) {
  temp_df <- df[which(df[[{{cat_col}}]] == cat_val),]
  transformed_df <- temp_df %>% func()
  transformed_df[{{cat_col}}] <- cat_val
  return(transformed_df)
}

stat_by_cat <- function(df,cat_col,func) {
  cat_vals <- unique(df[[{{cat_col}}]])
  stat_results <- cat_vals %>% lapply(stat_by_cat_single,df,cat_col,func)
  result <- do.call(rbind,stat_results)
  return(result)
}

normalize <- function(df,target_col) {
  new_name <- paste('NORM_',target_col,sep='')
  df[[{{new_name}}]] <- df[[{{target_col}}]] %>% 
    lapply(function(x) {
      return(x / sum(df[[{{target_col}}]]))
    }) %>%
    unlist()
  return(df)
}