#!/bin/bash

#SBATCH --job-name=pabrain
#SBATCH --array=1-10 # 10 models in total
#SBATCH --ntasks=1
#SBATCH --partition=rome
#SBATCH --cpus-per-task=1   # NOTE R limit parallel processes = 124
#SBATCH --time=1-00:00:00
#SBATCH --error=pabrain_log%a
#SBATCH --output=pabrain_log%a
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=s.defina@erasmusmc.nl

# Redirect errors
# LOGFILE=/projects/0/einf1049/scratch/sdefina/pa_brain/log.out
# exec > "$LOGFILE" 2>&1

# Load necessary modules -----------------------------------------------------
module purge
module load 2024
module load R/4.4.2-gfbf-2024a

# Other available r distributions (module spider R)
# R/4.2.1-foss-2022a
# R/4.3.2-gfbf-2023a

# Avoid nested impolicit parallelism (that slows things down) ----------------
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

# Run analyses (in parallel) -------------------------------------------------
Rscript additional_analyses.R

