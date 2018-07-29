#!/bin/bash

echo "Installing additional R libraries"
sudo R --no-save << R_SCRIPT
		install.packages("devtools", repos="https://cran.r-project.org")
		install.packages("XML", repos="https://cran.r-project.org")
		install.packages("readr", repos="https://cran.r-project.org")
		install.packages("httr", repos="https://cran.r-project.org")
		install.packages("RCurl", repos="https://cran.r-project.org")
		install.packages("data.table", repos="https://cran.r-project.org")
		install.packages("parallel", repos="https://cran.r-project.org")
		install.packages("tidyverse", repos="https://cran.r-project.org")
		install.packages("dplyr", repos="https://cran.r-project.org")
		install.packages("knitr", repos="https://cran.r-project.org")
		install.packages("gplots", repos="https://cran.r-project.org")
		install.packages("tidyr", repos="https://cran.r-project.org")
		install.packages("reshape", repos="https://cran.r-project.org")
		install.packages("shiny", repos="https://cran.r-project.org")
		install.packages("ggplot2", repos="https://cran.r-project.org")
		install.packages("rlist", repos="https://cran.r-project.org")
		install.packages("ggthemes", repos="https://cran.r-project.org")
		install.packages("lubridate", repos="https://cran.r-project.org")
		install.packages("Rcpp", repos="https://cran.r-project.org")
		install.packages("reshape", repos="https://cran.r-project.org")
R_SCRIPT
