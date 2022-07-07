library(tidyverse) 
library(microbiome)
library(ANCOMBC)

#TODO: Deal with duplicate names from different branches
get_taxa_diffabund=function(ds, des, trank=NA, grp=NA, coef=1){
  if (is.na(grp)) {
    grp=des
  }
  
  library(ANCOMBC)
  if((is.na(trank)) | (trank == "ASV")){
    dds=ds
  } else{
    dds=aggregate_taxa(ds, trank)
  }
  o=ancombc(dds, formula = des,
            p_adj_method = "fdr",
            group=grp, zero_cut = 0.95,
            lib_cut = 1000)
  oo=tibble(pvalue=o$res$p_val[[coef]], taxon=rownames(o$res$p_val), 
            qvalue=o$res$q_val[[coef]], stat=o$res$W[[coef]], 
            beta=o$res$beta[[coef]], se=o$res$se[[coef]])
  return(oo)
}

diffabund=function(ds, des, grp=NA, coef=1)
{
  rs=c("Phylum", "Class", "Order", "Family", "Genus", "Species", "ASV")
  res=lapply(rs, function(r) get_taxa_diffabund(ds, des, trank = r, grp=grp, coef = coef) %>% mutate(taxon_rank=r))
  res=bind_rows(res)
  res=res %>% dplyr::arrange(qvalue)
  
  return(res)
}


ds=readRDS("unfiltered_dataset.rds")
rds=readRDS("filtered_dataset.rds")
sam=readRDS("revised_samplesheet.rds") %>% as.data.frame()
rownames(sam)=sam$ID
sample_data(ds)=sam
sample_data(rds)=sam

args = commandArgs(trailingOnly=TRUE)
res=diffabund(rds, args[1], args[1])
res %>% write_csv(str_c("differential_abundance/", args[1], ".diffabundance.csv"))
