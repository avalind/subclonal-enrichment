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

# Ugly duplication!
split_by_type <- function(filename) {
    writer <- function(df) {
        outname_gain_clonal = paste0("per_type/", unique(df$`Tumor ID`), "_gain_clonal.bed")
        outname_gain_subclonal = paste0("per_type/", unique(df$`Tumor ID`), "_gain_subclonal.bed")

        outname_loss_clonal = paste0("per_type/", unique(df$`Tumor ID`), "_loss_clonal.bed")
        outname_loss_subclonal = paste0("per_type/", unique(df$`Tumor ID`), "_loss_subclonal.bed")

        # First, collect all clonal gains for this patient 
        clonal_gain <- df %>% filter(`Sample ID`=="ALL") %>% 
            filter(str_detect(string=str_to_lower(Type), pattern="gain"))
        write_tsv(clonal_gain %>% select(Chr, Start, End), path=outname_gain_clonal, col_names=FALSE)

        # then do the same for clonal losses.
        clonal_loss <- df %>% filter(`Sample ID`=="ALL") %>% 
            filter(str_detect(string=str_to_lower(Type), pattern="loss"))
        write_tsv(clonal_loss %>% select(Chr, Start, End), path=outname_loss_clonal, col_names=FALSE)

        # then, collect all subclonal gains
        subclonal_gain <- df %>% filter(`Sample ID`!="ALL") %>% 
            filter(str_detect(string=str_to_lower(Type), pattern="gain"))
        write_tsv(subclonal_gain %>% select(Chr, Start, End) %>% distinct(), path=outname_gain_subclonal, col_names=FALSE)
        
        # and finally collect subclonal losses.
        subclonal_loss <- df %>% filter(`Sample ID`!="ALL") %>% 
            filter(str_detect(string=str_to_lower(Type), pattern="loss"))
        write_tsv(subclonal_loss %>% select(Chr, Start, End) %>% distinct(), path=outname_loss_subclonal, col_names=FALSE)
        
        return(df)
    }
    
    dataset <- read_excel(filename, skip=2)
    dataset <- na.omit(dataset)
    return(dataset %>% filter(str_detect(Method, "SNP")) %>% group_by(`Tumor ID`) %>% do(writer(.)))
}


#split_by_type(snakemake@input[[1]])
