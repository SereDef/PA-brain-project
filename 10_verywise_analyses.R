
library(verywise, lib.loc = '/gpfs/home6/sdefina/R/x86_64-pc-linux-gnu-library/4.5')

# Arguments --------------------------------------------------------
n_cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"), unset = 1)

proj_dir <- "/projects/0/einf1049/scratch/sdefina/PA-brain-project"

data_dir <-  file.path(proj_dir, "data")
outp_dir <- file.path(proj_dir, "results")

frees_home <- "/home/genr/software/freesurfer/6.0.0/"

fs_template <- "fsaverage"
chunk_size <- 1000  # based on 96 cores
error_cutoff <- 20 # default

# TMP I reuse ss from Annet's project 
ss_file <- file.path(data_dir, "ss")

df_file <- file.path(data_dir, "pabrain_abcd_imp_June2024.rds")

# ------------------------------------------------------------------------------
hemis <- c("lh", "rh")
outcs <- c("area", "thickness")
expos <- c('pa_overall', 'pa_light', 'pa_mvpa', 'pa_self', 'tot_steps')
modls <- c('main','intadj', 'icvadj')

job_grid <- expand.grid(hemi = hemis, 
                        measure = outcs,
                        expo = expos, 
                        modeltype = modls, stringsAsFactors = FALSE)

task_n <- Sys.getenv("SLURM_ARRAY_TASK_ID", unset = 1)

params <- job_grid[task_n, ]

attach(params)

base_covs <- '+ age + sex + ethn + parent_edu' # fixed
random_term <- '+ (1 | site)'

fixed_terms <- switch(modeltype,
                      main = base_covs,
                      intadj = paste(base_covs, '+ int'),
                      icvadj = paste(base_covs, '+ icv'))

model_formula <- as.formula(
  paste0("vw_", measure, " ~ ", expo, fixed_terms, random_term))

# Directories
model_outp_dir <- file.path(outp_dir, paste(expo, modeltype, sep='_'))

# I create it already so I can put the log there 
dir.create(model_outp_dir, recursive = TRUE, showWarnings = FALSE)

# Main analysis -----------------------------------------------------------
message(
  "============================================================\n",
  "--- (", task_n, ") ", hemi, " ", measure, " ~ ",  expo, " - ", modeltype, " ---",
  "\n============================================================\n")

options(default.nproc.blas = NULL)
bigparallelr::set_blas_ncores(1)

options(bigstatsr.check.parallel.blas = FALSE)

start.time <- Sys.time()

out <- verywise::run_vw_lmm(formula = model_formula,
                            pheno = df_file,
                            subj_dir = ss_file,
                            outp_dir = model_outp_dir,
                            hemi = hemi,
                            fs_template = fs_template,
                            apply_cortical_mask = TRUE,
                            folder_id = 'id',
                            tolerate_surf_not_found = error_cutoff,
                            # weights = 'weights',
                            lmm_control = lme4::lmerControl(),
                            REML = TRUE,
                            seed = 3108,
                            n_cores = n_cores,
                            chunk_size = chunk_size,
                            FS_HOME = frees_home,
                            save_ss = FALSE,
                            verbose = TRUE)

end.time <- Sys.time()

elapsed <- difftime(end.time, start.time, units = "mins") 

cat("\nStart time: ", format(start.time), 
    "\nEnd time:   ", format(end.time),
    "\nElapsed:    ", elapsed, "min\n")
