require(QDECR)

dir_subj <- '/projects/0/einf1049/data/abcd/rel4.0/bids/derivatives/freesurfer/6.0.0/untar'

pheno <- readRDS('pabrain_abcd_imp_June2024.rds')

analysis_id <- as.integer(Sys.getenv('SLURM_ARRAY_TASK_ID', unset = 1))
n_cores <- as.integer(Sys.getenv('SLURM_CPUS_PER_TASK', unset = 1))

# Parameter space =================================================================
hemis <- c('lh','rh')
outcs <- c('thickness', 'area')
expos <- c('light_pa', 'mvpa')
model <- c('adjint','adjicv')

param_grid <- expand.grid('hemi'=hemis, 'outc'=outcs, 'mode'=model, 'expo'=expos)

# Only keep parameter combinations that need to be run:
# - mvpa_adjint - thickness
# - light_pa_adjint - area, thickness
# - light_pa_adjicv - area, thickness
# [note: not necessary but to avoid possible future ordering issues]
param_grid <- param_grid[param_grid$expo == 'light_pa' | (
    param_grid$expo == 'mvpa' & param_grid$mode == 'adjint' & param_grid$outc == 'thickness'), ]

# Parameter selection --------------------------------------------------------------
params <- param_grid[analysis_id, ]

proj_name <- paste(params$expo, params$mode, sep='_')

base_covs <- '+ age + sex + ethn + site + parent_edu' # fixed

outc_name <- paste0('qdecr_', params$outc)
expo_name <- if (params$expo == 'light_pa') 'pa_light' else 'pa_mvpa'

adj_covs <- if (params$mode == 'adjint') '+ int' else '+ icv'

formula_spec <- as.formula(paste(outc_name, '~', expo_name, base_covs, adj_covs))

dir_out <- file.path('results', params$expo)


# Analysis --------------------------------------------------------------------------
cat('\n=========================================================\n')
cat(paste(analysis_id, ':', proj_name, params$outc, params$hemi, '(', n_cores, 'cores )'))
cat('\n=========================================================\n')
vw <- QDECR::qdecr_fastlm(formula = formula_spec, 
			  data = pheno, 
			  id = "id",
			  hemi = as.character(params$hemi),
			  dir_subj = dir_subj,
			  dir_tmp = file.path(dir_out, 'tmp'), 
			  dir_out = dir_out, 
			  project = proj_name,
			  n_cores = n_cores, 
			  clobber = TRUE)
