#!/bin/bash
#SBATCH --job-name=getting_qiime_results
#SBATCH --partition=Bytesflex
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16


cd /export/jippe/jsil/projects/16S/RBRA

mkdir -p /export/jippe/jsil/projects/16S/RBRA/temp
export TMPDIR=/export/jippe/jsil/projects/16S/RBRA/temp


cd /export/jippe/jsil/projects/16S/RBRA/


#~ qiime demux summarize \
#~ --i-data /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_demux.qza \
#~ --o-visualization /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_demux.qzv 

#~ qiime cutadapt trim-paired \
#~ --i-demultiplexed-sequences /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_demux.qza \
#~ --p-front-f GTGYCAGCMGCCGCGGTAA \
#~ --p-front-r CCGYCAATTYMTTTRAGTTT \
#~ --p-discard-untrimmed \
#~ --o-trimmed-sequences /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_trimmed-demux-seqs.qza

#~ qiime demux summarize \
#~ --i-data /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_trimmed-demux-seqs.qza \
#~ --o-visualization /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_trimmed-demux-seqs.qzv 

qiime dada2 denoise-paired \
--i-demultiplexed-seqs /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_trimmed-demux-seqs.qza \
--p-trim-left-f 5 \
--p-trim-left-r 5 \
--p-trunc-len-f 200 \
--p-trunc-len-r 190 \
--o-table /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_table.qza \
--o-representative-sequences /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_representative_sequences.qza \
--o-denoising-stats /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_denoising_stats.qza \
--p-n-threads 16 

qiime metadata tabulate \
--m-input-file /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_denoising_stats.qza \
--o-visualization /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_denoising_stats.qzv

qiime feature-table summarize \
--i-table /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_table.qza \
--m-sample-metadata-file /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330@metadata.txt \
--o-visualization /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_table.qzv

qiime feature-table tabulate-seqs \
--i-data /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_representative_sequences.qza \
--o-visualization /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_representative_sequences.qzv

qiime alignment mafft \
--i-sequences /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_representative_sequences.qza \
--o-alignment /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_aligned-rep-seqs.qza \
--p-n-threads 16 

qiime alignment mask \
--i-alignment /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_aligned-rep-seqs.qza \
--o-masked-alignment /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_masked_aligned-rep-seqs.qza

qiime phylogeny fasttree \
--i-alignment /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_masked_aligned-rep-seqs.qza \
--o-tree /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_unrooted-tree.qza \
--p-n-threads 16

qiime phylogeny midpoint-root \
--i-tree /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_unrooted-tree.qza \
--o-rooted-tree /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_rooted-tree.qza

qiime feature-classifier classify-sklearn \
--i-classifier /export/jippe/jsil/db/Qiime2/qiime2-2022.11/Silva/138/silva-138-99-nb-classifier.qza \
--i-reads /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_representative_sequences.qza \
--o-classification /export/jippe/jsil/projects/16S/NB_classifier_SILVA_138_99_16S_515F-926R_QIIME2-2022.11.qza \
--p-n-jobs 16 \
--p-reads-per-batch 200

qiime metadata tabulate \
--m-input-file /export/jippe/jsil/projects/16S/NB_classifier_SILVA_138_99_16S_515F-926R_QIIME2-2022.11.qza \
--o-visualization /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_taxonomy_NB_classifier_SILVA_132_99_16S_515F-926R_QIIME2-2022.11.qzv

qiime tools export \
--input-path /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_representative_sequences.qza \
--output-path /export/jippe/jsil/projects/16S/RBRA/

qiime tools export \
--input-path /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_table.qza \
--output-path /export/jippe/jsil/projects/16S/RBRA/

qiime tools export \
--input-path /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_rooted-tree.qza \
--output-path /export/jippe/jsil/projects/16S/RBRA/

qiime tools export \
--input-path /export/jippe/jsil/projects/16S/NB_classifier_SILVA_138_99_16S_515F-926R_QIIME2-2022.11.qza \
--output-path /export/jippe/jsil/projects/16S/RBRA/

mv /export/jippe/jsil/projects/16S/RBRA/dna-sequences.fasta /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_dna-sequences.fasta
mv /export/jippe/jsil/projects/16S/RBRA/feature-table.biom /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_feature-table.biom
mv /export/jippe/jsil/projects/16S/RBRA/tree.nwk /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_tree.nwk
mv /export/jippe/jsil/projects/16S/RBRA/taxonomy.tsv /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_taxonomy.tsv

#~ unzip /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_demux.qzv -d /export/jippe/jsil/projects/16S/RBRA/
#~ find /export/jippe/jsil/projects/16S/RBRA/ -type f -name 'forward-seven-number-summaries.csv' -exec sh -c 'for arg do cp -- "$arg" "/export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_forward-seven-number-summaries.csv"; done' _ {} +
#~ find /export/jippe/jsil/projects/16S/RBRA/ -type f -name 'reverse-seven-number-summaries.csv' -exec sh -c 'for arg do cp -- "$arg" "/export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_reverse-seven-number-summaries.csv"; done' _ {} +
#~ unzip /export/jippe/jsil/projects/16S/RBRA/RBRA_16S_515F926R_Q11696_20230330_denoising_stats.qza -d /export/jippe/jsil/projects/16S/RBRA/
#~ find /export/jippe/jsil/projects/16S/RBRA/ -type f -name 'stats.tsv' -exec sh -c 'for arg do cp -- "$arg" "/export/jippe/jsil/projects/16S/RBRA/CHECK_RBRA_16S_515F926R_Q11696_20230330_stats.tsv"; done' _ {} +

#~ source deactivate
