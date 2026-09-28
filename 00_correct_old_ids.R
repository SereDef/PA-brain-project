
proj_dir <- "/projects/0/einf1049/scratch/sdefina/PA-brain-project/data"

df_file <- file.path(proj_dir, "pabrain_abcd_imp_June2024.rds")

df <- readRDS(df_file)

# TMP I reuse ss from Annet's project 
# ss_file <- "/projects/0/einf1049/scratch/sdefina/att_brain_2026/ss_abcd"
# folds <- read.csv(file.path(ss_file, 'lh.area.ss.rownames.csv'))
#                   
# ses_new <- unique(stringr::str_split_i(folds[,1], "_ses-", 2))
# ses <- unique(stringr::str_split_i(df$data$id, "_ses-", 2))

long <- mice::complete(df, action = "long", include = TRUE)

long$id <- gsub("NDARINV", "", long$id)
long$id <- gsub("2YearFollowUpYArm1", "02A", long$id)

# back to mids
df_new <- mice::as.mids(long)  

saveRDS(df_new, file.path(proj_dir, "pabrain_abcd_imp_July2026.rds"))




