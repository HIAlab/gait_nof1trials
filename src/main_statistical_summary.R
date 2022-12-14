#### Statistics summary and ANOVA of the data ####
rm(list=ls())

# load libraries and functions
library(ez)
source("./src/data_loader.R")

# load data
downsample_step <- 5
kw <- 'LFRF_all_strides'

# select list of features / gait paarameters
features_list <- c(
  "stride_lengths",
  "stride_times"
)

# read data from file
loc_df <- load_gait_parameters(folder_path, kw)

# summary statistics of the participants
sub_characteristics <- c("age", "height(cm)", "weight(kg)", "leg_length(cm)")
sub_df <- unique(loc_df[, append(sub_characteristics, "sub")])

for (sub_char in sub_characteristics) {
  print_subject_summary(sub_df, sub_char)
}

# summary statistics of the data
loc_df <- loc_df[loc_df$foot == "left", ]
loc_df <- downsample_rows(loc_df[loc_df$foot == "left", ], downsample_step)
print(paste("Downsample by", downsample_step))
print("Summary of data from all subjects after downsampling:")

# two-way repeated measures ANOVAA
results_2_way_anova <- data.frame()
for (var_name in features_list) {
  print_data_summary(loc_df, var_name)
  
  dat_df <- select(loc_df, "var" = var_name, sub, condition, fatigue)
  
  res.aov <- ezANOVA(
    data = dat_df,
    dv = .(var),
    wid = .(sub),
    within = .(condition, fatigue),
    detailed = T,
    type = 2
  )
  
  anova_res <- data.frame(res.aov)
  anova_res$variable <- var_name
  results_2_way_anova <- dplyr::bind_rows(results_2_way_anova, anova_res)
}
print("ANOVA Summary:")
print(results_2_way_anova)