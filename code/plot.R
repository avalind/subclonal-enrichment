library(tidyverse)

main <- function(true_overlap, perm_overlap, figname) {
    perms <- read.table(perm_overlap, header=FALSE)$V1
    true_overlap <- read.table(true_overlap, header=FALSE)$V1[1]

    enriched_pval <- as.character(sum(perms>=true_overlap) / length(perms))
    depleted_pval <- as.character(sum(perms<=true_overlap) / length(perms))

    enriched_str = paste0("p-value for enrichment: ", enriched_pval)
    depleted_str = paste0("p-value for depletion: ", depleted_pval)
    subtitle = paste0(enriched_str, ", ", depleted_str)

    pdf(figname)
    hist(perms, breaks=100, main=subtitle)
    abline(v = true_overlap, col="red")
    dev.off()
}

main(snakemake@input[[1]],
    snakemake@input[[2]],
    snakemake@output[[1]])