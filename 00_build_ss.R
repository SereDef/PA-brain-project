library(verywise, lib.loc = '/gpfs/home6/sdefina/R/x86_64-pc-linux-gnu-library/4.5')

subj_dir <- '/projects/0/einf1049/data/abcd/rel4.0/bids/derivatives/freesurfer/6.0.0/untar'

data_dir <- "/projects/0/einf1049/scratch/sdefina/PA-brain-project/data"

ssubj_dir <- file.path(data_dir, "ss")

df_file <- file.path(data_dir, "pabrain_abcd_imp_June2024.rds")
df <- readRDS(df_file)
pheno <- mice::complete(df, 1)
folder_ids <- pheno[, 'id'] 

n_cores <- as.integer(Sys.getenv('SLURM_CPUS_PER_TASK', unset = 1))
task_n <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", unset = 1))

# Parameter space =================================================================
hemis <- c('lh','rh')
outcs <- c('thickness', 'area')

job_grid <- expand.grid(hemi = hemis, 
                        measure = outcs, stringsAsFactors = FALSE)

params <- job_grid[task_n, ]

attach(params)

ss <- build_supersubject(
  subj_dir = subj_dir,
  folder_ids = folder_ids,
  supsubj_dir = ssubj_dir,
  measure = measure,
  hemi = hemi,
  fs_template = "fsaverage",
  n_cores = n_cores,
  error_cutoff = 20,
  save_rds = TRUE,
  verbose = TRUE
)  
