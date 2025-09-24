# CHARLS Multiple Imputation for Longitudinal Data

Enhanced version of the original imputation analysis with improved structure, error handling, and production-ready features.

## Quick Start (Working Version with Critical Fixes)

**Prerequisites:** R 4.5.1+ and JAGS 4.3.1+ already installed

```r
# 1. Start R (use full path if needed in VS Code)
R.exe
# or: "C:\Program Files\R\R-4.5.1\bin\R.exe"

# 2. Load required packages FIRST (critical order)
library(dplyr)
library(tidyr)
library(rlang)
library(JointAI)

# 3. Load pipeline class
source("R/03_optimized_imputation.R")

# 4. Create and setup pipeline
pipeline <- ImputationPipeline$new()
pipeline$load_data('data/raw/charlscm4.csv')
pipeline$classify_variables()
pipeline$analyze_missing_data()
pipeline$print_summary()

# 5. CRITICAL FIX #1: Convert tibble to data.frame
pipeline$data <- as.data.frame(pipeline$data)

# 6. CRITICAL FIX #2: Clean list columns that break JointAI
for(col_name in names(pipeline$data)) {
  col <- pipeline$data[[col_name]]
  if(is.list(col) && !is.factor(col)) {
    pipeline$data[[col_name]] <- as.character(unlist(col))
    if(col_name %in% c("age", "wave", "sleep", "total_cognition", "cesd10", "hhcperc", "cm_num")) {
      pipeline$data[[col_name]] <- as.numeric(pipeline$data[[col_name]])
    }
  }
}

# 7. Re-apply variable classification after cleaning
pipeline$classify_variables()

# 8. Run imputation (now it works)
pipeline$fit_imputation_model()
pipeline$generate_imputations(m = 5)
pipeline$save_results()
```

### Expected Output
- Environment check: All green checkmarks
- Data loaded: ~9,427 rows, 35 columns
- Missing data: ~3,709 values across 25 variables
- Model fitting: "Parallel sampling with 0 workers started" (success indicator)
- Results: 5 imputed datasets saved to outputs/

## Legacy Quick Start (May Not Work)

The original quick start method below may fail with "type 'list'" errors:

```r
source("R/08_quick_start.R")
run_quick_setup("data/raw/charlscm4.csv")
```

## Project Structure

- R/ - Core analysis functions
- data/ - Input and output data
- config/ - Configuration files  
- outputs/ - Analysis results
- tests/ - Testing framework
- docs/ - Documentation
- scripts/ - Utility scripts
- logs/ - Log files

## Requirements

- R 4.5.1+
- JAGS 4.3.1+ system dependency (http://mcmc-jags.sourceforge.net/)
- Required R packages: dplyr, tidyr, rlang, JointAI, R6, readr

## Critical Bug Fixes

**Without the fixes in steps 5-7, you will encounter:**
- Error: "default method not implemented for type 'list'"
- JointAI cannot process tibble or list column formats from readr

**The fixes address:**
- Tibble format incompatibility with JointAI
- List columns that break Bayesian MCMC sampling
- Ordered factor issues in longitudinal models

## Original Code

The original analysis is preserved in docs/original_imputation.Rmd. This project provides an optimized, production-ready version with the same statistical methodology.

## Features

- Automated environment setup and package management
- Robust error handling and validation
- Memory optimization for large datasets
- Comprehensive logging and diagnostics
- CHARLS-specific variable type handling
- Production-ready configuration management
- **Fixed JointAI compatibility issues**

## Troubleshooting

1. **"type 'list'" error**: Use the complete quick start with critical fixes above
2. **"ImputationPipeline not found"**: Load all packages before sourcing R files
3. **JAGS not found**: Install JAGS system dependency first
4. **Package errors**: Run install_all_packages() in R
5. **R.exe not recognized**: Restart VS Code or use full path to R.exe
6. **Data loading issues**: Check file path and CSV format
7. **Memory issues**: Reduce dataset size or increase system memory

## Support

For issues specific to CHARLS data or the original methodology, refer to the original Imputation.Rmd file and CHARLS documentation. The critical fixes above resolve the main compatibility issues with modern R/JointAI versions.