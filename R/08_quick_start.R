# =====================================================
# 08_quick_start.R - Quick Start Functions
# =====================================================

run_quick_setup <- function(data_path = NULL) {
  
  cat("=== QUICK SETUP FOR CHARLS IMPUTATION ===\n")
  
  # Load all functions
  tryCatch({
    source("R/01_diagnostics.R")
    source("R/02_package_management.R") 
    source("R/03_optimized_imputation.R")
    source("R/04_charls_specific.R")
    cat("✓ All functions loaded\n")
  }, error = function(e) {
    cat("✗ Error loading functions:", e, "\n")
    cat("Make sure you're in the project root directory\n")
    return(invisible(NULL))
  })
  
  # Check environment
  cat("\nChecking environment...\n")
  env_ok <- quick_env_check()
  
  if (!env_ok) {
    cat("\nEnvironment issues detected. Installing packages...\n")
    install_all_packages()
    
    # Re-check after installation
    env_ok <- quick_env_check()
    if (!env_ok) {
      cat("✗ Environment setup incomplete. Please fix issues manually.\n")
      return(invisible(NULL))
    }
  }
  
  # Test with data if provided
  if (!is.null(data_path) && file.exists(data_path)) {
    
    cat("\nTesting with real CHARLS data...\n")
    
    tryCatch({
      
      # Load required packages
      load_required_packages()
      
      # Create and test pipeline
      pipeline <- ImputationPipeline()
      pipeline(data_path)
      pipeline <- apply_charls_variable_types(pipeline)
      pipeline()
      pipeline()
      
      cat("✓ Successfully loaded and processed CHARLS data\n")
      cat("✓ Pipeline ready for imputation analysis\n")
      
      # Save processed data
      saveRDS(pipeline, "temp/test_pipeline.rds")
      cat("✓ Test pipeline saved to temp/test_pipeline.rds\n")
      
      return(pipeline)
      
    }, error = function(e) {
      cat("✗ Error with real data:", e$message, "\n")  # FIXED: e$message is a string
      cat("Environment setup completed, but data processing failed\n")
      cat("Check your data file path and format\n")
      return(invisible(NULL))
    })
    
  } else {
    
    cat("\nTesting pipeline class without data...\n")
    
    tryCatch({
      test_pipeline <- quick_test_pipeline()
      cat("✓ Pipeline class working correctly\n")
      return(test_pipeline)
    }, error = function(e) {
      cat("✗ Pipeline test failed:", e, "\n")
      return(invisible(NULL))
    })
  }
  
  cat("\n=== SETUP COMPLETE ===\n")
  cat("Next steps:\n")
  cat("1. Load your CHARLS data: pipeline <- ImputationPipeline()\n")
  cat("2. Load data: pipeline('data/raw/charlscm4.csv')\n")
  cat("3. Apply CHARLS config: pipeline <- apply_charls_variable_types(pipeline)\n")
  cat("4. Analyze missing data: pipeline()\n")
  cat("5. View summary: pipeline()\n")
}

# Convenience function for immediate testing
test_charls_setup <- function() {
  data_path <- "data/raw/charlscm4.csv"
  
  if (file.exists(data_path)) {
    run_quick_setup(data_path)
  } else {
    cat("CHARLS data not found at:", data_path, "\n")
    cat("Please ensure charlscm4.csv is in the data/raw/ directory\n")
    cat("Or run: run_quick_setup('path/to/your/charlscm4.csv')\n")
  }
}

# Display instructions
cat("CHARLS Imputation Quick Start Functions Loaded\n")
cat("===============================================\n")
cat("Main commands:\n")
cat("• run_quick_setup('data/raw/charlscm4.csv') - Complete setup with your data\n")
cat("• test_charls_setup() - Quick test if data is in standard location\n") 
cat("• quick_env_check() - Check environment only\n")
cat("\nRun one of these commands to get started!\n")
