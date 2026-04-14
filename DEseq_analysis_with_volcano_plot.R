#load libraries 

library(data.table)
library(BiocManager)
library(DESeq2)
library(apeglm)
library(ggplot2)
library(ggrepel)
library(EnhancedVolcano)



dir = "/scratch/kt96951/workdir/rna_seq/"
sampleData = paste0(dir, "Cornsnake.csv")
sampleData = fread(sampleData)
rownames(sampleData) = sampleData$ENA_RUN
sampleData$individual = as.factor(sampleData$individual)
sampleData$Paris_classification = as.factor(sampleData$Paris_classification)

# Use relevel() to set adjacent normal samples as reference
sampleData$Paris_classification = relevel(sampleData$Paris_classification, ref = "Wild type")

files = list.files(paste0(dir, "star_results"), "*ReadsPerGene.out.tab$", full.names = T)

#star count data
countData = data.frame(fread(files[1]))[c(1,4)]

# Loop and read the 4th column remaining files
for(i in 2:length(files)) {
  countData = cbind(countData, data.frame(fread(files[i]))[4])
}

# Skip first 4 lines, count data starts on the 5th line
countData = countData[c(5:nrow(countData)),]
colnames(countData) = c("GeneID", gsub(paste0(dir,"star/"), "", files))
colnames(countData) = gsub("_ReadsPerGene.out.tab", "", colnames(countData))
rownames(countData) = countData$GeneID

countData = countData[,c(2:ncol(countData))]

#build a DEseq data set 
dds = DESeqDataSetFromMatrix(countData = countData,
                             colData = sampleData, design = ~ Individual + Paris_classification)
#running DEseq
dds = DESeq(dds)
res <- results(dds, name = "Paris_classification_Mutant_vs_Wild.type", alpha = 0.05)

#PCA plot
rld = rlog(dds)
vsd = vst(dds)

#rlog
pcaData = plotPCA(rld, intgroup=c("Individual","Paris_classification"), 
                  returnData=TRUE)
percentVar = round(100 * attr(pcaData, "percentVar"))
png("DGE_PCA-rlog.STAR.png", width=7, height=7, units = "in", res = 300)
ggplot(pcaData, aes(PC1, PC2, colour = Paris_classification)) + 
  geom_point(size = 2) + theme_bw() + 
  scale_color_manual(values = c("blue", "red")) +
  geom_text_repel(aes(label = Individual), nudge_x = -1, nudge_y = 0.2, size = 3) +
  ggtitle("Principal Component Analysis (PCA)", subtitle = "rlog transformation") +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance"))
dev.off()

#vst
pcaData = plotPCA(vsd, intgroup=c("Individual","Paris_classification"), 
                  returnData=TRUE)
percentVar = round(100 * attr(pcaData, "percentVar"))

png("DGE_PCA-vst.STAR.png", width=7, height=7, units = "in", res = 300)
ggplot(pcaData, aes(PC1, PC2, colour = Paris_classification)) + 
  geom_point(size = 2) + theme_bw() + 
  scale_color_manual(values = c("blue", "red")) +
  geom_text_repel(aes(label = individual), nudge_x = -1, nudge_y = 0.2, size = 3) +
  ggtitle("Principal Component Analysis (PCA)", subtitle = "vst transformation") +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance"))
dev.off()

#volcano plot 
pCutoff = 0.05
FCcutoff = 1.0
rownames(res) <- gsub("gene-", "", rownames(res))
p = EnhancedVolcano(data.frame(res), lab = rownames(res), x = 'log2FoldChange', y = 'padj',ylim = c(0, 15),
                    xlab = bquote(~Log[2]~ 'fold change'), ylab = bquote(~-Log[10]~adjusted~italic(P)),
                    pCutoff = pCutoff, FCcutoff = FCcutoff, pointSize = 0, labSize = 4.0,col = c('grey30', 'forestgreen', 'royalblue', 'red2'),colAlpha = 1.0 ,shape = 19,
                    title = "Volcano plot", subtitle = "SSA/P vs. Normal",
                    caption = paste0('log2 FC cutoff: ', FCcutoff, '; p-value cutoff: ', pCutoff, '\nTotal = ', nrow(res), ' variables'),
                    drawConnectors = TRUE,
                    widthConnectors = 0.5,
                    colConnectors = 'grey50',
                    arrowheads = FALSE,
                    max.overlaps = 15,
                    directionConnectors = 'both',
                    legendLabels=c('NS','Log2 FC','Adjusted p-value', 'Adjusted p-value & Log2 FC'),
                    legendPosition = 'bottom', legendLabSize = 14, legendIconSize = 5.0)

png("DGE_VolcanoPlots.STAR.png", width=7, height=7, units = "in", res = 300)
print(p)
dev.off()

