## Simple R script to install specified packages
# these are from cran
install.packages( c("plyr", "ggplot2"), dependencies = TRUE, repos="http://cran.rstudio.com/")
# this is for bioconductor
source("http://bioconductor.org/biocLite.R")
biocLite("phyloseq")
q()