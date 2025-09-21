# =====================================================
# 03_optimized_imputation.R - Main Pipeline Class (FIXED)
# =====================================================

# Ensure R6 is available
if (!requireNamespace("R6", quietly = TRUE)) {
  install.packages("R6")
}
library(R6)

ImputationPipeline <- R6::R6Class("ImputationPipeline",
  public = list(
    # Properties
    data = NULL,
    config = NULL,
    variable_types = NULL,
    missing_analysis = NULL,
    models = NULL,
    results = NULL,
    
    # Initialize
    initialize = function(config = NULL) {
      self$config <- config %||% self$get_default_config()
      cat("ImputationPipeline initialized\n")
    },
    
    # Load data with validation
    load_data = function(file_path) {
      cat("Loading data from:", file_path, "\n")
      
      if (!file.exists(file_path)) {
        stop("Data file not found: ", file_path)
      }
      
      tryCatch({
        self$data <- readr::read_csv(file_path, show_col_types = FALSE)
        self$prepare_longitudinal_data()
        cat("✓ Data loaded:", nrow(self$data), "rows,", ncol(self$data), "columns\n")
      }, error = function(e) {
        stop("Error loading data: ", e$message)
      })
      
      return(invisible(self))
    },
    
    # Prepare longitudinal data structure
    prepare_longitudinal_data = function() {
      if ("ID" %in% names(self$data)) {
        self$data$ID <- factor(self$data$ID)
      }
      
      if ("wave" %in% names(self$data)) {
        self$data$wave <- as.numeric(self$data$wave)
      }
      
      # Remove num column as in original code
      if ("num" %in% names(self$data)) {
        self$data$num <- NULL
        cat("✓ Removed 'num' column\n")
      }
      
      cat("✓ Longitudinal data structure prepared\n")
    },
    
    # Analyze missing data patterns
    analyze_missing_data = function() {
      if (is.null(self$data)) {
        stop("No data loaded")
      }
      
      cat("Analyzing missing data patterns...\n")
      
      # Basic missing data summary
      missing_summary <- self$data %>%
        dplyr::summarise_all(~sum(is.na(.))) %>%
        tidyr::gather(variable, n_missing) %>%
        dplyr::mutate(pct_missing = n_missing / nrow(self$data) * 100) %>%
        dplyr::filter(n_missing > 0) %>%
        dplyr::arrange(desc(n_missing))
      
      self$missing_analysis <- list(
        summary = missing_summary,
        total_missing = sum(is.na(self$data)),
        complete_cases = sum(complete.cases(self$data))
      )
      
      cat("✓ Missing data analysis complete\n")
      cat("  Total missing values:", self$missing_analysis$total_missing, "\n")
      cat("  Complete cases:", self$missing_analysis$complete_cases, "\n")
      
      return(invisible(self))
    },
    
    # Print comprehensive summary
    print_summary = function() {
      cat("\n", paste(rep("=", 50), collapse = ""), "\n")
      cat("CHARLS LONGITUDINAL IMPUTATION PIPELINE SUMMARY\n")
      cat(paste(rep("=", 50), collapse = ""), "\n")
      
      if (!is.null(self$data)) {
        cat("Data:", nrow(self$data), "observations,", ncol(self$data), "variables\n")
        
        if ("ID" %in% names(self$data)) {
          n_subjects <- length(unique(self$data$ID))
          cat("Longitudinal structure:", n_subjects, "subjects\n")
        }
        
        if ("wave" %in% names(self$data)) {
          waves <- sort(unique(self$data$wave))
          cat("Time waves:", paste(waves, collapse = ", "), "\n")
        }
      }
      
      if (!is.null(self$variable_types)) {
        cat("\nVariable classification:\n")
        for (var_type in names(self$variable_types)) {
          cat("  ", var_type, ":", length(self$variable_types[[var_type]]), "variables\n")
        }
      }
      
      if (!is.null(self$missing_analysis)) {
        total_missing <- sum(self$missing_analysis$summary$n_missing)
        cat("\nMissing data:", total_missing, "values across", 
            nrow(self$missing_analysis$summary), "variables\n")
      }
      
      if (!is.null(self$models)) {
        cat("\nFitted models:", length(self$models), "\n")
      }
      
      if (!is.null(self$results)) {
        cat("\nImputation results:", self$results$n_imputations, "datasets generated\n")
      }
      
      cat(paste(rep("=", 50), collapse = ""), "\n\n")
    },
    
    # Default configuration
    get_default_config = function() {
      list(
        mcmc = list(
          base_chains = 2,
          base_adapt = 300,
          base_iter = 2000,
          thin = 1
        ),
        parallel = list(
          enabled = TRUE,
          workers = max(1, parallel::detectCores() - 1)
        ),
        output = list(
          save_models = TRUE,
          save_diagnostics = TRUE,
          default_imputations = 5
        )
      )
    }
  )
)

# Test function
quick_test_pipeline <- function() {
  cat("Testing ImputationPipeline class...\n")
  
  pipeline <- ImputationPipeline$new()
  cat("✓ Pipeline created successfully\n")
  
  return(pipeline)
}