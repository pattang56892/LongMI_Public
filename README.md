# CHARLS Multiple Imputation for Longitudinal Data

Enhanced version of the original imputation analysis with improved structure, error handling, and production-ready features.

## Quick Start

1. **Setup Environment**:
   `
   source("R/08_quick_start.R")
   run_quick_setup("data/raw/charlscm4.csv")
   `

2. **Run Analysis**:
   `
   pipeline <- ImputationPipeline()
   pipeline("data/raw/charlscm4.csv")
   pipeline <- apply_charls_variable_types(pipeline)
   pipeline()
   pipeline()
   `

## Project Structure

- R/ - Core analysis functions
- data/ - Input and output data
- config/ - Configuration files  
- outputs/ - Analysis results
- 	ests/ - Testing framework
- docs/ - Documentation
- scripts/ - Utility scripts
- logs/ - Log files

## Requirements

- R 4.0+
- JAGS system dependency (http://mcmc-jags.sourceforge.net/)
- Required R packages (auto-installed)

## Original Code

The original analysis is preserved in docs/original_imputation.Rmd. This project provides an optimized, production-ready version with the same statistical methodology.

## Features

- Automated environment setup and package management
- Robust error handling and validation
- Memory optimization for large datasets
- Comprehensive logging and diagnostics
- CHARLS-specific variable type handling
- Production-ready configuration management

## Troubleshooting

1. **JAGS not found**: Install JAGS system dependency first
2. **Package errors**: Run install_all_packages() in R
3. **Data loading issues**: Check file path and CSV format
4. **Memory issues**: Reduce dataset size or increase system memory

## Support

For issues specific to CHARLS data or the original methodology, refer to the original Imputation.Rmd file and CHARLS documentation.
