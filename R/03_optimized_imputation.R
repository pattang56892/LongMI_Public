# =====================================================
# 03_optimized_imputation.R - Complete Pipeline Class
# =====================================================

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
      
      # Remove num column
      if ("num" %in% names(self$data)) {
        self$data$num <- NULL
        cat("✓ Removed 'num' column\n")
      }
      
      cat("✓ Longitudinal data structure prepared\n")
    },
    
    # Classify variables
    classify_variables = function() {
      self$variable_types <- list(
        binary_vars = c("nation", "marry", "smoken", "drinkl", "pension", "ins",
                       "fall_down", "hip", "pain", "disability", "teeth", "cm"),
        ordinal_vars = c("srh", "satlife", "disability_status", "eyesight_distance",
                        "eyesight_close", "hear", "edu"),
        continuous_vars = c("sleep", "total_cognition", "cesd10", "hhcperc", "age", "cm_num")
      )
      
      # Apply data types
      for (var in intersect(self$variable_types$binary_vars, names(self$data))) {
        self$data[[var]] <- factor(self$data[[var]])
      }
      
      for (var in intersect(self$variable_types$ordinal_vars, names(self$data))) {
        self$data[[var]] <- ordered(self$data[[var]])
      }
      
      cat("✓ Variables classified and types applied\n")
      return(invisible(self))
    },
    
    # Analyze missing data patterns
    analyze_missing_data = function() {
      if (is.null(self$data)) {
        stop("No data loaded")
      }
      
      cat("Analyzing missing data patterns...\n")
      
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
    
    # FIT IMPUTATION MODEL - THIS WAS MISSING
    fit_imputation_model = function(target_var = NULL, n_chains = 2, n_adapt = 500, n_iter = 1000) {
      
      if (is.null(self$data)) {
        stop("No data loaded")
      }
      
      # Clean data - fix list column issue
      for(i in 1:ncol(self$data)) {
        if(is.list(self$data[[i]]) && !is.data.frame(self$data[[i]])) {
          self$data[[i]] <- as.character(self$data[[i]])
        }
      }
      
      # Select target variable if not specified
      if (is.null(target_var)) {
        vars_with_missing <- names(which(colSums(is.na(self$data)) > 0))
        target_var <- intersect(c("disability_status", "srh", "sleep"), vars_with_missing)[1]
        if (is.na(target_var)) {
          target_var <- vars_with_missing[1]
        }
      }
      
      cat("Fitting imputation model for:", target_var, "\n")
      
      # Simple formula to avoid complexity
      formula_str <- paste(target_var, "~ age + wave + (1|ID)")
      cat("Formula:", formula_str, "\n")
      
      tryCatch({
        set.seed(123)
        
        if (target_var %in% c("srh", "satlife", "disability_status", "edu")) {
          # Ordinal model
          model <- JointAI::clmm_imp(
            as.formula(formula_str),
            data = self$data,
            n.chains = n_chains,
            n.adapt = n_adapt,
            n.iter = n_iter,
            progress.bar = "text"
          )
        } else if (target_var %in% c("nation", "marry", "smoken", "drinkl")) {
          # Binary model
          model <- JointAI::glmm_imp(
            as.formula(formula_str),
            family = binomial(),
            data = self$data,
            n.chains = n_chains,
            n.adapt = n_adapt,
            n.iter = n_iter,
            progress.bar = "text"
          )
        } else {
          # Continuous model
          model <- JointAI::lmm_imp(
            as.formula(formula_str),
            data = self$data,
            n.chains = n_chains,
            n.adapt = n_adapt,
            n.iter = n_iter,
            progress.bar = "text"
          )
        }
        
        self$models <- list()
        self$models[[target_var]] <- model
        cat("✓ Model fitted successfully\n")
        
      }, error = function(e) {
        cat("✗ Error fitting model:", e$message, "\n")
        self$models <- NULL
      })
      
      return(invisible(self))
    },
    
    # GENERATE IMPUTATIONS - THIS WAS MISSING
    generate_imputations = function(m = 5) {
      if (is.null(self$models) || length(self$models) == 0) {
        stop("No fitted models available. Run fit_imputation_model() first.")
      }
      
      cat("Generating", m, "imputed datasets...\n")
      
      model <- self$models[[1]]
      
      tryCatch({
        imputed_list <- JointAI::complete(model, m = m)
        
        self$results <- list(
          imputed_datasets = imputed_list,
          n_imputations = m,
          generation_time = Sys.time()
        )
        
        cat("✓", m, "imputed datasets generated successfully\n")
        
      }, error = function(e) {
        cat("✗ Error generating imputations:", e$message, "\n")
        self$results <- NULL
      })
      
      return(invisible(self))
    },
    
    # SAVE RESULTS - THIS WAS MISSING
    save_results = function(output_dir = "outputs") {
      if (is.null(self$results)) {
        stop("No results to save. Run generate_imputations() first.")
      }
      
      # Create directories
      dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
      dir.create(file.path(output_dir, "imputed_data"), showWarnings = FALSE)
      dir.create(file.path(output_dir, "models"), showWarnings = FALSE)
      
      # Save imputed datasets
      for (i in seq_along(self$results$imputed_datasets)) {
        filename <- file.path(output_dir, "imputed_data", paste0("imputed_dataset_", i, ".csv"))
        readr::write_csv(self$results$imputed_datasets[[i]], filename)
      }
      
      # Save models
      saveRDS(self$models, file.path(output_dir, "models", "imputation_models.rds"))
      
      cat("✓ Results saved to:", output_dir, "\n")
      return(invisible(self))
    },
    
    # Print summary
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
        total_missing <- self$missing_analysis$total_missing
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

cat("Complete ImputationPipeline class loaded with all methods\n")