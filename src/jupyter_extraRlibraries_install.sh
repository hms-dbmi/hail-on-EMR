#!/bin/bash

echo "Installing additional R libraries"
sudo R --no-save << R_SCRIPT

paket <- function(pak){
  new_pak <- pak[!(pak %in% rownames(installed.packages()))]
  if (length(new_pak)) 
    install.packages(new_pak, dependencies = TRUE)
  sapply(pak, library, character.only = TRUE)
}

listOfPackages <- c("devtools","XML","readr","httr","RCurl","data.table","parallel","tidyverse","dplyr","knitr","gplots","tidyr","reshape","shiny","ggplot2","rlist","ggthemes","lubridate","Rcpp","reshape")

paket(listOfPackages)

R_SCRIPT
