library(data.table)
library(ggplot2)
library(ggthemes)
library(readstata13)
library(stringi)

#data_path <- 'F:/STATA/Aggregate/PCS_occ/dta/change/change7015_all.dta'
data_path <- 'F:/STATA/Aggregate/PCS_occ/dta/change/change7015_US.dta'
df <- as.data.table(read.dta13(data_path))

sdf <- df
sdf <- melt(sdf,id='year',variable.name='skill',value.name='share')
sdf[skill %in% c('change_high'), Skill := 'High Pay']
sdf[skill %in% c('change_mid'), Skill := 'Mid Pay']
sdf[skill %in% c('change_low'), Skill := 'Low Pay']
sdf <- sdf[,.(share=sum(share)),by=.(year,Skill)]
sdf <- dcast(sdf,Skill ~ year,value.var='share')

sdf <- melt(sdf,id='Skill')

sdf$Skill <- factor(sdf$Skill, levels = c("Low Pay","Mid Pay","High Pay"))
sdf$variable <- factor(sdf$variable, levels = c(1980,1990,2000,2015))
sdf <- sdf[order(sdf$Skill, sdf$variable)]



sdf[, Skill := factor(Skill, levels=c('Low Pay','Mid Pay','High Pay'))]


skill_labels <- c('Low-Paying','Mid-Paying',' High-Paying')
year <- c(1980,1990,2000,2015)


occ_change_plot <- ggplot(sdf,aes(Skill, value, fill=Skill, alpha=variable))+
  geom_bar(stat='identity',position='dodge')+
  theme_stata()+
  labs(title=paste('Changes in Occupational Employment Shares,1970-2016'),x='',y='',subtitle=paste('(Changes in Shares in Pct Points) per Decade'))+
  scale_fill_manual(values=c('#d7191c','#fdae61','#2c7bb6'),labels=skill_labels)+
  theme(axis.ticks.x = element_blank(), plot.background = element_rect(fill='white'),
        axis.text.y=element_text(angle=0),legend.title=element_blank(),
        legend.background = element_rect(colour='white'))+
  guides(fill=guide_legend(order=1),alpha=guide_legend(order=99))
occ_change_plot
ggsave(filename="change_7015_US.pdf", path = 'F:/STATA/Aggregate/PCS_occ/fig', width=7,height=5.25)


# plot_skill_group_levels_changes(df,subgroup='overall',subgroup_title='Working Age Adults',
#                                intervals=c('1970-1980','1980-1990','1990-2000','2000-2016'))