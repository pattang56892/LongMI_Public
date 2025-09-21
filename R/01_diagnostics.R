# =====================================================
# 01_diagnostics.R - Environment Validation
# =====================================================

check_environment <- function() {
  cat("=== ENVIRONMENT DIAGNOSTICS ===\n")
  
  # R Version
  cat("R Version:", R.version.string, "\n")
  
  # JAGS Check
  jags_ok <- tryCatch({
    library(rjags, quietly = TRUE)
    version <- jags.version()
    cat("JAGS Version:", version, "\n")
    TRUE
  }, error = function(e) {
    cat("JAGS: ERROR -", e, "\n")
    FALSE
  })
  
  # Package versions
  required_packages <- c("JointAI", "rjags", "readr", "dplyr", "future")
  packages_ok <- TRUE
  
  for (pkg in required_packages) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      cat(pkg, "version:", as.character(packageVersion(pkg)), "\n")
    } else {
      cat(pkg, ": NOT INSTALLED\n")
      packages_ok <- FALSE
    }
  }
  
  return(list(
    jags_available = jags_ok,
    r_version_ok = as.numeric(R.Version()) >= 4,
    packages_ok = packages_ok
  ))
}

quick_env_check <- function() {
  cat("=== QUICK ENVIRONMENT CHECK ===\n")
  
  # Check R version
  r_version <- as.numeric(paste(R.Version(), R.Version(), sep = "."))
  cat("R Version:", R.version.string, ifelse(r_version >= 4.0, "✓", "⚠"), "\n")
  
  # Check JAGS
  jags_ok <- tryCatch({
    library(rjags, quietly = TRUE)
    cat("JAGS Version:", jags.version(), "✓\n")
    TRUE
  }, error = function(e) {
    cat("JAGS: NOT FOUND ✗\n")
    cat("  → Install from: http://mcmc-jags.sourceforge.net/\n")
    FALSE
  })
  
  # Check critical packages
  critical_packages <- c("readr", "dplyr", "JointAI")
  packages_ok <- TRUE
  
  for (pkg in critical_packages) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      cat(pkg, ": available ✓\n")
    } else {
      cat(pkg, ": missing ✗\n")
      packages_ok <- FALSE
    }
  }
  
  overall_ok <- jags_ok && packages_ok && r_version >= 4.0
  cat("\nOverall status:", ifelse(overall_ok, "READY ✓", "NEEDS SETUP ✗"), "\n")
  
  if (!overall_ok) {
    cat("\nFIX THESE ISSUES FIRST:\n")
    if (!jags_ok) cat("1. Install JAGS system dependency\n")
    if (!packages_ok) cat("2. Install missing R packages\n")
    if (r_version < 4.0) cat("3. Update R to version 4.0+\n")
  }
  
  return(overall_ok)
}
