# unset PYTHONPATH
# rm -rf ~/.virtualenvs/r-reticulate
# module load Python/3.11.11  # module matching your venv
# python -m venv ~/.virtualenvs/r-reticulate
# source ~/.virtualenvs/r-reticulate/bin/activate
# python -m pip install --upgrade pip
# pip install numpy matplotlib nilearn plotly kaleido
# python -c "import numpy, matplotlib, nilearn, plotly, kaleido; print('all good')"


library(reticulate)

Sys.setenv(RETICULATE_PYTHON = path.expand("~/.virtualenvs/r-reticulate/bin/python"))
reticulate::use_virtualenv(path.expand("~/.virtualenvs/r-reticulate"), required = TRUE)

reticulate::py_config() 


library(verywise, lib.loc = '/gpfs/home6/sdefina/R/x86_64-pc-linux-gnu-library/4.5')

proj_dir <- "/projects/0/einf1049/scratch/sdefina/PA-brain-project"

outp_dir <- file.path(proj_dir, "results")

frees_home <- "/home/genr/software/freesurfer/6.0.0/"

# vw_summarize_outp_dir(outp_dir)

measures <- c("area", "thickness")
expos <- c('pa_overall', 'pa_light', 'pa_mvpa', 'pa_self', 'tot_steps')
modls <- c('intadj', 'icvadj') # 'main') # 

analysis_grid <- expand.grid(measure = measures, 
                             expo = expos, 
                             modeltype = modls, stringsAsFactors = FALSE)

plot_results <- function(measure, expo, modeltype) {
  
  cli::cli_rule(left = paste(measure, "~", expo), right = modeltype) 
  
  expo_name <- switch(expo,
                      pa_overall = 'Overall physical activity', 
                      pa_light = 'Light physical activity', 
                      pa_mvpa = 'Moderate-vigorous physical activity', 
                      pa_self = 'Self-reported physical activity', 
                      tot_steps = 'Total steps')
  
  meas_name <- switch(measure,
                      thickness = 'Cortical thickness',
                      area = 'Cortical surface area (white surface)')
  
  plot_vw_map(
    res_dir   = file.path(outp_dir, paste0(expo, '_', modeltype)),
    term      = expo,
    measure   = measure,
    hemi      = 'both',
    surface   = 'pial',
    threshold = 'cws',
    title = paste(meas_name, '~', expo_name), 
    to_file   = file.path(proj_dir, 'plots', paste(measure, expo, modeltype, 'png', sep = '.')),
    fs_home   = frees_home
  )
}

purrr::pwalk(analysis_grid, plot_results)
