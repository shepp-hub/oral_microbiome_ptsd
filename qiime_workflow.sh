qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path pe-33-manifest.txt \
--output-path paired-end-demux.qza \
--input-format PairedEndFastqManifestPhred33V2

# Denoise and summarise
qiime dada2 denoise-paired \
--i-demultiplexed-seqs paired-end-demux.qza \
--p-trim-left-f 19 \
--p-trunc-len-f 278 \
--p-trunc-len-r 225 \
--p-trim-left-r 5 \
--p-n-threads 0 \
--o-table table-dada2.qza \
--o-representative-sequences rep-seqs-dada2.qza \
--o-denoising-stats stats-dada2.qza

mv rep-seqs-dada2.qza rep-seqs.qza
mv table-dada2.qza table.qza

qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats-dada2.qzv

qiime feature-table summarize \
--i-table table.qza \
--o-visualization table.qzv \
--m-sample-metadata-file sample-metadata.tsv

qiime feature-table tabulate-seqs \
--i-data rep-seqs.qza \
--o-visualization rep-seqs.qzv

# Phylogenetic treee construction
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

# Create HOMD classifier
wget 'http://www.homd.org/ftp/16S_rRNA_refseq/HOMD_16S_rRNA_RefSeq/current/HOMD_16S_rRNA_RefSeq_V15.22.qiime.taxonomy'
wget 'http://www.homd.org/ftp/16S_rRNA_refseq/HOMD_16S_rRNA_RefSeq/current/HOMD_16S_rRNA_RefSeq_V15.22.fasta'

qiime tools import   --type 'FeatureData[Sequence]' --input-path HOMD_16S_rRNA_RefSeq_V15.22.fasta --output-path HOMD_16S_rRNA_RefSeq_V15.22.qza
qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path HOMD_16S_rRNA_RefSeq_V15.22.qiime.taxonomy --output-path HOMD_16S_rRNA_RefSeq_V15.22.taxonomy.qza
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads HOMD_16S_rRNA_RefSeq_V15.22.qza --i-reference-taxonomy HOMD_16S_rRNA_RefSeq_V15.22.taxonomy.qza --o-classifier HOMD_16S_rRNA_RefSeq_V15.22.classifier.qza
qiime feature-classifier classify-sklearn --i-classifier HOMD_16S_rRNA_RefSeq_V15.22.classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy.qza --p-n-jobs -1 --p-confidence 0.85
qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv


# Diversity analyses
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 13172 \
  --m-metadata-file sample-metadata.tsv \
  --output-dir core-metrics-results

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/evenness-group-significance.qzv

# Taxonomic classification
qiime feature-classifier classify-sklearn \
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

# Export count and taxonomy data
qiime composition add-pseudocount \
--i-table table.qza \
--o-composition-table comp-table.qza

qiime tools export --input-path comp-table.qza --output-path ./

qiime tools export --input-path taxonomy.qza --output-path ./

# biom, version 2.1.5
biom convert -i feature-table.biom -o feature-table.tsv --to-tsv

