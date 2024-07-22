# lede-project2
This story for the Lede Progam at Columbia University is based on BOP inmate complaint data made available to the public thanks to the tireless work of Jeremy Singer-Vine and the Data Liberation Project. (Disclosure: I am an unpaid volunteer for the DLP.)

Data analysis was performed with R and RStudio. Page design made use of Coolors, Flourish, and GitHub Pages.

The raw inmate complaints dataset (thoroughly documented here by DLP volunteers) contains 37 variables of case information across 1.78 million rows. Each row represents a single filing with its associated start and end dates, but not necessarily a single incident. BOP case numbers track continuing complaints across rows, and each case number can appear in one or more rows. In principle, each real-world incident is assigned its own dedicated case number regardless of how many times an inmate ultimately files a complaint about it, although this is difficult to verify without more information about the incidents themselves.

This story began with volunteer work I undertook for the DLP tidying the original raw dataset for easier use by researchers and journalists, as well as geocoding the complaints to the real-world locations of their subject facilities. That work is ongoing. (@declanrjb/dlp-inmate-complaints) However, the analysis presented here is my own and should not be taken to represent the findings of the DLP or its other volunteers. This repository contains the complete supporting code for my analysis, with each calculation marked with its associated conclusions found in the linked article.  

For processed data, see viz/data. For raw data, see data-analysis/data. For analysis code, see data-analysis/scripts.
