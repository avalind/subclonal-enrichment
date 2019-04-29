library(tidyverse)
library(readxl)

main <- function(filename) {
    writer <- function(df) {
        outname_clonal = paste0("scratch/", unique(df$`Tumor ID`), "_clonal.bed")
        outname_subclonal = paste0("scratch/", unique(df$`Tumor ID`), "_subclonal.bed")

        # First, collect all clonal abberations for this patient
        clonal <- df %>% filter(`Sample ID`=="ALL")
        write_tsv(clonal %>% select(Chr, Start, End), path=outname_clonal, col_names=FALSE)

        # then, collect all subclonal abberations.
        subclonal <- df %>% filter(`Sample ID`!="ALL")
        write_tsv(subclonal %>% select(Chr, Start, End) %>% distinct(), path=outname_subclonal, col_names=FALSE)
        return(df)
    }
    
    dataset <- read_excel(filename, skip=2)
    dataset <- na.omit(dataset)
    return(dataset %>% filter(str_detect(Method, "SNP")) %>% group_by(`Tumor ID`) %>% do(writer(.)))
}

main(snakemake@input[[1]])
