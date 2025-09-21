# =====================================================
# 02_package_management.R - Package Installation
# =====================================================

install_all_packages <- function() {
  cat("=== INSTALLING ALL REQUIRED PACKAGES ===\n")
  
  # Package groups in installation order
  package_groups <- list(
    "Core" = c("readr", "dplyr", "tidyr", "ggplot2"),
    "JAGS" = c("rjags", "coda"),
    "Imputation" = c("JointAI", "mice", "VIM", "naniar"),
    "Utility" = c("future", "future.apply", "yaml", "logger", "R6", "testthat", "here", "jsonlite")
  )
  
  for (group_name in names(package_groups)) {
    cat("\nInstalling", group_name, "packages...\n")
    packages <- package_groups[[group_name]]
    
    for (pkg in packages) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        cat("Installing", pkg, "...")
        tryCatch({
          install.packages(pkg, dependencies = TRUE, quiet = TRUE)
          library(pkg, character.only = TRUE, quietly = TRUE)
          cat(" ✓\n")
        }, error = function(e) {
          cat(" ✗\n")
          cat("  Error:", e, "\n")
          if (pkg == "rjags") {
            cat("  → Install JAGS first: http://mcmc-jags.sourceforge.net/\n")
          }
        })
      } else {
        cat(pkg, "already available ✓\n")
      }
    }
  }
  
  cat("\n✓ Package installation complete\n")
}

load_required_packages <- function() {
  required_packages <- c("readr", "dplyr", "JointAI", "future", "yaml")
  
  for (pkg in required_packages) {
    suppressMessages(library(pkg, character.only = TRUE, quietly = TRUE))
  }
  
  cat("✓ Required packages loaded\n")
}
