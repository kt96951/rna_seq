# 1. Force a clean data frame with no NAs
res_df <- as.data.frame(res)
res_df <- res_df[!is.na(res_df$padj), ]
res_df$gene_name <- gsub("gene-", "", rownames(res_df))

# 2. Safety: Handle p-values that are exactly 0 (which become Infinity)
# This replaces 0 with the smallest possible number R can handle
res_df$padj[res_df$padj == 0] <- .Machine$double.xmin

# 3. Add the simplified binary significance
res_df$significant <- ifelse(
  res_df$padj < 0.05 & abs(res_df$log2FoldChange) > 1,
  "Significant", "Not Significant"
)

# 4. Create the plot
p <- ggplot(res_df, aes(x = log2FoldChange, 
                        y = -log10(padj), 
                        text = gene_name,
                        color = significant)) + # Use the column we just made
  geom_point(alpha = 0.5, size = 1.2) +
  scale_color_manual(values = c("Significant" = "red2", "Not Significant" = "grey70")) +
  theme_minimal() +
  labs(title = "Volcano Plot: OCA2 mutant vs wild type", 
       x = "Log2 Fold Change",
       y = "-Log10 Adjusted P-value",
       color = "Status")

# 5. Save the file
# Using ggsave is often more reliable than the png()/dev.off() sandwich
ggsave("DGE_Volcano_Simple.png", p, width=7, height=7, dpi=300)

library(plotly)
ggplotly(p, tooltip = "text")
