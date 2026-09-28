#!/bin/bash

#SBATCH --job-name=00_pabrain
#SBATCH --array=1-4 # 2 measures x 2 hemis
#SBATCH --ntasks=1
#SBATCH --partition=rome
#SBATCH --cpus-per-task=64
#SBATCH --time=1-00:00:00
#SBATCH --error=logs/ss_build%a
#SBATCH --output=logs/ss_build%a
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=s.defina@erasmusmc.nl

# Redirect errors
# LOGFILE=/projects/0/einf1049/scratch/sdefina/pa_brain/log.out
# exec > "$LOGFILE" 2>&1

# Load necessary modules -----------------------------------------------------
module purge
module load 2025
module load NLopt/2.10.0-GCCcore-14.2.0 
module load R/4.5.1-gfbf-2025a

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
Rscript 00_build_ss.R

