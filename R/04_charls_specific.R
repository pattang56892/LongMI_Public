# =====================================================
# 04_charls_specific.R - CHARLS Configuration
# =====================================================

create_charls_config <- function() {
  
  charls_config <- list(
    
    # Binary variables (0/1 coding in CHARLS)
    binary_vars = c(
      "nation", "marry", "smoken", "drinkl", "pension", "ins",
      "fall_down", "hip", "pain", "disability", "teeth", "cm"
    ),
    
    # Ordinal variables (ordered categories)
    ordinal_vars = c(
      "srh", "satlife", "disability_status", "eyesight_distance", 
      "eyesight_close", "hear", "edu"
    ),
    
    # Continuous variables
    continuous_vars = c(
      "sleep", "total_cognition", "cesd10", "hhcperc", "age", "cm_num"
    ),
    
    # Required variables (should always be present)
    required_vars = c("ID", "wave", "gender"),
    
    # Exclude from imputation
    exclude_vars = c("num", "adyear", "admonth", "chronic_num", "mul_chronic")
  )
  
  return(charls_config)
}

prepare_charls_data <- function(data) {
  
  cat("Preparing CHARLS data...\n")
  
  # Get CHARLS configuration
  charls_config <- create_charls_config()
  
  # Remove excluded variables
  exclude_vars <- intersect(charls_config, names(data))
  if (length(exclude_vars) > 0) {
    data <- data[, !names(data) %in% exclude_vars]
    cat("✓ Removed excluded variables:", paste(exclude_vars, collapse = ", "), "\n")
  }
  
  # Apply data types for binary variables
  for (var in intersect(charls_config, names(data))) {
    data[[var]] <- factor(data[[var]])
  }
  
  # Apply data types for ordinal variables
  for (var in intersect(charls_config, names(data))) {
    data[[var]] <- ordered(data[[var]])
  }
  
  # Scale hhcperc if needed (convert percentage to proportion)
  if ("hhcperc" %in% names(data)) {
    max_val <- max(data, na.rm = TRUE)
    if (max_val > 1) {
      data <- data / 100
      cat("✓ Scaled hhcperc to proportion\n")
    }
  }
  
  cat("✓ CHARLS data preparation complete\n")
  return(data)
}

apply_charls_variable_types <- function(pipeline) {
  
  if (is.null(pipeline)) {
    stop("No data loaded in pipeline")
  }
  
  charls_config <- create_charls_config()
  
  # Set variable types in pipeline
  pipeline <- list(
    binary_vars = intersect(charls_config, names(pipeline)),
    ordinal_vars = intersect(charls_config, names(pipeline)),
    continuous_vars = intersect(charls_config, names(pipeline))
  )
  
  # Apply data preparation
  pipeline <- prepare_charls_data(pipeline)
  
  cat("✓ CHARLS variable types applied to pipeline\n")
  
  return(pipeline)
}
