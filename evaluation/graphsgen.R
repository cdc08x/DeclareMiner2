#
# Creates the time performance graphs from CSV files contained in data/
# Author: Claudio Di Ciccio
# Version: 2017/07/07
#

library(ggplot2)
library(scales)
library(grid)

serious_theme <- theme_bw() + # less fancy colors
  #increase size of gridlines
  theme(panel.grid.major = element_line(size = .5, color = "lightgrey"),
        #increase size of axis lines
        axis.line = element_line(size=.7, color = "black"),
        #Adjust legend position to maximize space, use a vector of proportion
        #across the plot and up the plot where you want the legend. 
        #You can also use "left", "right", "top", "bottom", for legends on the side of the plot
        #  legend.position = c(.2,.9),
        #box around the legend
        legend.background = element_rect(colour = "black", size=.3),
        #increase the font size
        text = element_text(size=24)) 
## http://www.noamross.net/blog/2013/11/20/formatting-plots-for-pubs.html

data_v1 <- read.csv2(file='data/v1-synlog_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")
data_v3 <- read.csv2(file='data/v3-synlog_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")
data_v4 <- read.csv2(file='data/v4-synlog_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")

apriori_v1 <- read.csv2(file='data/v1-syn_apriori_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")
apriori_v3 <- read.csv2(file='data/v3-syn_apriori_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")
apriori_v4 <- read.csv2(file='data/v4-syn_apriori_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")

apriori <- rbind(apriori_v1, apriori_v3, apriori_v4)

# v1 miner ("no par.")
# v3 miner+ ("par. src.sp.")
# v4 ms miner+ ("par. db.")

data_v1$time <- data_v1$time * 1.0 / 1000
data_v3$time <- data_v3$time * 1.0 / 1000
data_v4$time <- data_v4$time * 1.0 / 1000
apriori$time <- apriori$time * 1.0 / 1000

default_alphabet <- '16'
default_logsize <- '1600'
default_tracelen <- '16'
default_support <- '80'
no_vacuity <- '100'
with_vacuity <- '0'

computypes <- c("apriori", "no par.", "par. db.", "par. src.sp.")
customshapetypes <- data.frame( types = computypes, shapes = c(8,2,5,1)) # two-crosses, triangle, circle, diamond
customlinetypes <- data.frame( types = computypes, lines = c("twodash","dotted","dashed","solid"))
compatypes <- c("vs par.db", "vs par.src.sp")
compashapetypes <- data.frame( types = compatypes, shapes = c(2,1)) # triangle, circle
compalinetypes <- data.frame( types = compatypes, lines = c("dashed","solid"))

#
#
################################################################
# W.r.t. trace length. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-tracelen-alpha100.pdf")

data_v1_p <- data_v1[which(data_v1$alphabet == default_alphabet & data_v1$logsize == default_logsize & data_v1$support == default_support & data_v1$alpha == no_vacuity),]
data_v3_p <- data_v3[which(data_v3$alphabet == default_alphabet & data_v3$logsize == default_logsize & data_v3$support == default_support & data_v3$alpha == no_vacuity),]
data_v4_p <- data_v4[which(data_v4$alphabet == default_alphabet & data_v4$logsize == default_logsize & data_v4$support == default_support & data_v4$alpha == no_vacuity),]
apriori_p <- apriori[which(apriori$alphabet == default_alphabet & apriori$logsize == default_logsize & apriori$support == default_support & apriori$alpha == no_vacuity),]

apriori_p_avg <- aggregate(apriori_p[c("time")], by=apriori_p[c("minlen")], FUN=mean)
data_v1_p_avg <- aggregate(data_v1_p[c("time")], by=data_v1_p[c("minlen")], FUN=mean)
data_v3_p_avg <- aggregate(data_v3_p[c("time")], by=data_v3_p[c("minlen")], FUN=mean)
data_v4_p_avg <- aggregate(data_v4_p[c("time")], by=data_v4_p[c("minlen")], FUN=mean)

tracelen_novac_plot <- ggplot(data = NULL, aes(x = minlen, y = time)) +
  geom_point(data = apriori_p_avg, alpha=0.5, size=5, aes(shape="apriori")) +  
  geom_line(data = apriori_p_avg, aes(linetype="apriori")) +
  geom_point(data = data_v1_p, alpha=0.25, size=7, aes(shape="no par.")) +
  geom_point(data = data_v1_p_avg, alpha=0.5, size=5, shape=17, show.legend=FALSE) + # black triangle  
  geom_line(data = data_v1_p_avg, aes(linetype="no par.")) +
  geom_point(data = data_v3_p, alpha=0.25, size=7, aes(shape="par. src.sp.")) +
  geom_point(data = data_v3_p_avg, alpha=0.5, size=5, shape=19, show.legend=FALSE) + # black disc
  geom_line(data = data_v3_p_avg, aes(linetype="par. src.sp.")) +
  geom_point(data = data_v4_p, alpha=0.25, size=7, aes(shape="par. db.")) +
  geom_point(data = data_v4_p_avg, alpha=0.5, size=5, shape=18, show.legend=FALSE) + # black diamond
  geom_line(data = data_v4_p_avg, aes(linetype="par. db."))

x_minor_ticks=sort(unique(data_v1_p$minlen))
x_ticks=x_minor_ticks[seq(1, length(x_minor_ticks), 2)]
tracelen_novac_plot <- tracelen_novac_plot +
#  ylim(0,50) +
#  scale_y_log10() +
#  annotation_logticks(sides = "l") +
#  coord_trans(y = "log10") +
  scale_y_continuous(labels = comma, breaks=c(1.000, 2.500, 5.000, 7.500)) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time v. trace length", x = "Events per trace", y = "Computation time [sec]", shape = "Algorithm", linetype = "Algorithm")) +
  serious_theme + theme(legend.position=c(.2,.85), plot.title=element_blank()) +
  scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
  scale_linetype_manual(breaks = customlinetypes$types, values=customlinetypes$lines)

plot (tracelen_novac_plot)

dev.off()

#
#
################################################################
# Time saving with parallelism, w.r.t. trace length. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-tracelen-alpha100-savings.pdf")

# Merge data_v1_p_avg and data_v3_p_avg by their "minlen" column and subtract the respective "time" content
data_v1_v3_p_avg <- within(merge(data_v1_p_avg,data_v3_p_avg,by="minlen"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("minlen","time")]

# Merge data_v1_p_avg and data_v4_p_avg by their "minlen" column and subtract the respective "time" content
data_v1_v4_p_avg <- within(merge(data_v1_p_avg,data_v4_p_avg,by="minlen"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("minlen","time")]

sav_tracelen_novac_plot <- ggplot(data = NULL, aes(x = minlen, y = time)) +
  geom_point(data = data_v1_v3_p_avg, alpha=0.5, size=5, aes(shape="vs par.src.sp")) + # disc
  geom_line(data = data_v1_v3_p_avg, aes(linetype="vs par.src.sp")) +
  geom_point(data = data_v1_v4_p_avg, alpha=0.5, size=5, aes(shape="vs par.db")) + # diamond
  geom_line(data = data_v1_v4_p_avg, aes(linetype="vs par.db"))


sav_tracelen_novac_plot <- sav_tracelen_novac_plot +
  ylim(-30,75) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time saved with parallelism v. trace length", x = "Events per trace", y = "Relative difference in comp. time [%]", shape = "Comparison", linetype = "Comparison")) +
  serious_theme + theme(legend.position=c(.75,.15), plot.title=element_blank()) +
  scale_shape_manual(breaks = compashapetypes$types, values=compashapetypes$shapes) +
  scale_linetype_manual(breaks = compalinetypes$types, values=compalinetypes$lines)

plot (sav_tracelen_novac_plot)

dev.off()

#
#
################################################################
# Time w.r.t. trace length + savings. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-tracelen-alpha100-savings-tile.pdf", height = 14, width = 8)

grid.newpage()
grid.draw(rbind(
  ggplotGrob(tracelen_novac_plot +
               theme(axis.text.x = element_blank(), axis.title.x = element_blank())
  ), 
  ggplotGrob(sav_tracelen_novac_plot),
  size="first"))

dev.off()

#
#
################################################################
# W.r.t. trace length. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-tracelen-alpha0.pdf")

data_v1_p <- data_v1[which(data_v1$alphabet == default_alphabet & data_v1$logsize == default_logsize & data_v1$support == default_support & data_v1$alpha == with_vacuity),]
data_v3_p <- data_v3[which(data_v3$alphabet == default_alphabet & data_v3$logsize == default_logsize & data_v3$support == default_support & data_v3$alpha == with_vacuity),]
data_v4_p <- data_v4[which(data_v4$alphabet == default_alphabet & data_v4$logsize == default_logsize & data_v4$support == default_support & data_v4$alpha == with_vacuity),]
apriori_p <- apriori[which(apriori$alphabet == default_alphabet & apriori$logsize == default_logsize & apriori$support == default_support & apriori$alpha == with_vacuity),]

apriori_p_avg <- aggregate(apriori_p[c("time")], by=apriori_p[c("minlen")], FUN=mean)
data_v1_p_avg <- aggregate(data_v1_p[c("time")], by=data_v1_p[c("minlen")], FUN=mean)
data_v3_p_avg <- aggregate(data_v3_p[c("time")], by=data_v3_p[c("minlen")], FUN=mean)
data_v4_p_avg <- aggregate(data_v4_p[c("time")], by=data_v4_p[c("minlen")], FUN=mean)

tracelen_vac_plot <- ggplot(data = NULL, aes(x = minlen, y = time)) +
  geom_point(data = apriori_p_avg, alpha=0.5, size=5, aes(shape="apriori")) +  
  geom_line(data = apriori_p_avg, aes(linetype="apriori")) +
  geom_point(data = data_v1_p, alpha=0.25, size=7, aes(shape="no par.")) +
  geom_point(data = data_v1_p_avg, alpha=0.5, size=5, shape=17, show.legend=FALSE) + # black triangle  
  geom_line(data = data_v1_p_avg, aes(linetype="no par.")) +
  geom_point(data = data_v3_p, alpha=0.25, size=7, aes(shape="par. src.sp.")) +
  geom_point(data = data_v3_p_avg, alpha=0.5, size=5, shape=19, show.legend=FALSE) + # black disc
  geom_line(data = data_v3_p_avg, aes(linetype="par. src.sp.")) +
  geom_point(data = data_v4_p, alpha=0.25, size=7, aes(shape="par. db.")) +
  geom_point(data = data_v4_p_avg, alpha=0.5, size=5, shape=18, show.legend=FALSE) + # black diamond
  geom_line(data = data_v4_p_avg, aes(linetype="par. db."))
  

x_minor_ticks=sort(unique(data_v1_p$minlen))
x_ticks=x_minor_ticks[seq(1, length(x_minor_ticks), 2)]
tracelen_vac_plot <- tracelen_vac_plot +
  #  ylim(0,80000) +
  # scale_y_log10(labels = comma) +
  # annotation_logticks(sides = "l") +
  # coord_trans(y = "log10") +
  scale_y_continuous(labels = comma, breaks=c(1.000,2.500,5.000,7.500,10.000)) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time v. trace length", x = "Events per trace", y = "Computation time [sec]", shape = "Algorithm", linetype = "Algorithm")) +
  serious_theme + theme(legend.position=c(.2,.85), plot.title=element_blank()) +
  scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
  scale_linetype_manual(breaks = customlinetypes$types, values=customlinetypes$lines)

plot (tracelen_vac_plot)

dev.off()

#
#
################################################################
# Time saving with parallelism, w.r.t. trace length. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-tracelen-alpha0-savings.pdf")

# Merge data_v1_p_avg and data_v3_p_avg by their "minlen" column and subtract the respective "time" content
data_v1_v3_p_avg <- within(merge(data_v1_p_avg,data_v3_p_avg,by="minlen"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("minlen","time")]

# Merge data_v1_p_avg and data_v4_p_avg by their "minlen" column and subtract the respective "time" content
data_v1_v4_p_avg <- within(merge(data_v1_p_avg,data_v4_p_avg,by="minlen"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("minlen","time")]

sav_tracelen_vac_plot <- ggplot(data = NULL, aes(x = minlen, y = time)) +
  geom_point(data = data_v1_v3_p_avg, alpha=0.5, size=5, aes(shape="vs par.src.sp")) + # disc
  geom_line(data = data_v1_v3_p_avg, aes(linetype="vs par.src.sp")) +
  geom_point(data = data_v1_v4_p_avg, alpha=0.5, size=5, aes(shape="vs par.db")) + # diamond
  geom_line(data = data_v1_v4_p_avg, aes(linetype="vs par.db"))

sav_tracelen_vac_plot <- sav_tracelen_vac_plot +
  ylim(-30,75) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time saved with parallelism v. trace length", x = "Events per trace", y = "Relative difference in comp. time [%]", shape = "Comparison", linetype = "Comparison")) +
  serious_theme + theme(legend.position=c(.75,.15), plot.title=element_blank()) +
  scale_shape_manual(breaks = compashapetypes$types, values=compashapetypes$shapes) +
  scale_linetype_manual(breaks = compalinetypes$types, values=compalinetypes$lines)

plot (sav_tracelen_vac_plot)

dev.off()

#
#
################################################################
# Time w.r.t. trace length + savings. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-tracelen-alpha0-savings-tile.pdf", height = 14, width = 8)

grid.newpage()
grid.draw(rbind(
  ggplotGrob(tracelen_vac_plot +
               theme(axis.text.x = element_blank(), axis.title.x = element_blank())
  ), 
  ggplotGrob(sav_tracelen_vac_plot),
  size="first"))

dev.off()

#
#
################################################################
# W.r.t. log size. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-logsize-alpha100.pdf")

data_v1_p <- data_v1[which(data_v1$alphabet == default_alphabet & data_v1$minlen == default_tracelen & data_v1$support == default_support & data_v1$alpha == no_vacuity),]
data_v3_p <- data_v3[which(data_v3$alphabet == default_alphabet & data_v3$minlen == default_tracelen & data_v3$support == default_support & data_v3$alpha == no_vacuity),]
data_v4_p <- data_v4[which(data_v4$alphabet == default_alphabet & data_v4$minlen == default_tracelen & data_v4$support == default_support & data_v4$alpha == no_vacuity),]
apriori_p <- apriori[which(apriori$alphabet == default_alphabet & apriori$minlen == default_tracelen & apriori$support == default_support & apriori$alpha == no_vacuity),]

apriori_p_avg <- aggregate(apriori_p[c("time")], by=apriori_p[c("logsize")], FUN=mean)
data_v1_p_avg <- aggregate(data_v1_p[c("time")], by=data_v1_p[c("logsize")], FUN=mean)
data_v3_p_avg <- aggregate(data_v3_p[c("time")], by=data_v3_p[c("logsize")], FUN=mean)
data_v4_p_avg <- aggregate(data_v4_p[c("time")], by=data_v4_p[c("logsize")], FUN=mean)

logsize_novac_plot <- ggplot(data = NULL, aes(x = logsize, y = time)) +
  geom_point(data = apriori_p_avg, alpha=0.5, size=5, aes(shape="apriori")) +  
  geom_line(data = apriori_p_avg, aes(linetype="apriori")) +
  geom_point(data = data_v1_p, alpha=0.25, size=7, aes(shape="no par.")) +
  geom_point(data = data_v1_p_avg, alpha=0.5, size=5, shape=17, show.legend=FALSE) + # black triangle  
  geom_line(data = data_v1_p_avg, aes(linetype="no par.")) +
  geom_point(data = data_v3_p, alpha=0.25, size=7, aes(shape="par. src.sp.")) +
  geom_point(data = data_v3_p_avg, alpha=0.5, size=5, shape=19, show.legend=FALSE) + # black disc
  geom_line(data = data_v3_p_avg, aes(linetype="par. src.sp.")) +
  geom_point(data = data_v4_p, alpha=0.25, size=7, aes(shape="par. db.")) +
  geom_point(data = data_v4_p_avg, alpha=0.5, size=5, shape=18, show.legend=FALSE) + # black diamond
  geom_line(data = data_v4_p_avg, aes(linetype="par. db."))
  
x_minor_ticks=sort(unique(data_v1_p$logsize))
x_ticks=x_minor_ticks[seq(1, length(x_minor_ticks), 2)]
logsize_novac_plot <- logsize_novac_plot +
  #  ylim(0,80000) +
  #scale_y_log10(labels = comma) +
  #annotation_logticks(sides = "l") +
  scale_y_continuous(labels = comma) +
  # coord_trans(y = "log10") +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time v. log size", x = "Traces in log", y = "Computation time [sec]", shape = "Algorithm", linetype = "Algorithm")) +
  serious_theme + theme(legend.position=c(.2,.85), plot.title=element_blank(), axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
  scale_linetype_manual(breaks = customlinetypes$types, values=customlinetypes$lines)

plot (logsize_novac_plot)

dev.off()

#
#
################################################################
# Time saving with parallelism, w.r.t. log size. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-logsize-alpha100-savings.pdf")

# Merge data_v1_p_avg and data_v3_p_avg by their "logsize" column and subtract the respective "time" content
data_v1_v3_p_avg <- within(merge(data_v1_p_avg,data_v3_p_avg,by="logsize"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("logsize","time")]

# Merge data_v1_p_avg and data_v4_p_avg by their "logsize" column and subtract the respective "time" content
data_v1_v4_p_avg <- within(merge(data_v1_p_avg,data_v4_p_avg,by="logsize"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("logsize","time")]

sav_logsize_novac_plot <- ggplot(data = NULL, aes(x = logsize, y = time)) +
  geom_point(data = data_v1_v3_p_avg, alpha=0.5, size=5, aes(shape="vs par.src.sp")) + # disc
  geom_line(data = data_v1_v3_p_avg, aes(linetype="vs par.src.sp")) +
  geom_point(data = data_v1_v4_p_avg, alpha=0.5, size=5, aes(shape="vs par.db")) + # diamond
  geom_line(data = data_v1_v4_p_avg, aes(linetype="vs par.db"))

sav_logsize_novac_plot <- sav_logsize_novac_plot +
  ylim(-30,75) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time saved with parallelism v. log size", x = "Traces in log", y = "Relative difference in comp. time [%]", shape = "Comparison", linetype = "Comparison")) +
  serious_theme + theme(legend.position=c(.25,.85), plot.title=element_blank(), axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_shape_manual(breaks = compashapetypes$types, values=compashapetypes$shapes) +
  scale_linetype_manual(breaks = compalinetypes$types, values=compalinetypes$lines)

plot (sav_logsize_novac_plot)

dev.off()

#
#
################################################################
# Time w.r.t. log size + savings. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-logsize-alpha100-savings-tile.pdf", height = 14, width = 8)

grid.newpage()
grid.draw(rbind(
  ggplotGrob(logsize_novac_plot +
               theme(axis.text.x = element_blank(), axis.title.x = element_blank())
  ), 
  ggplotGrob(sav_logsize_novac_plot),
  size="first"))

dev.off()

#
#
################################################################
# W.r.t. log size. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-logsize-alpha0.pdf")

data_v1_p <- data_v1[which(data_v1$alphabet == default_alphabet & data_v1$minlen == default_tracelen & data_v1$support == default_support & data_v1$alpha == with_vacuity),]
data_v3_p <- data_v3[which(data_v3$alphabet == default_alphabet & data_v3$minlen == default_tracelen & data_v3$support == default_support & data_v3$alpha == with_vacuity),]
data_v4_p <- data_v4[which(data_v4$alphabet == default_alphabet & data_v4$minlen == default_tracelen & data_v4$support == default_support & data_v4$alpha == with_vacuity),]
apriori_p <- apriori[which(apriori$alphabet == default_alphabet & apriori$minlen == default_tracelen & apriori$support == default_support & apriori$alpha == with_vacuity),]

# Outlier removal
# data_v4_p <- data_v4_p[data_v4_p$time > 10000,]

apriori_p_avg <- aggregate(apriori_p[c("time")], by=apriori_p[c("logsize")], FUN=mean)
data_v1_p_avg <- aggregate(data_v1_p[c("time")], by=data_v1_p[c("logsize")], FUN=mean)
data_v3_p_avg <- aggregate(data_v3_p[c("time")], by=data_v3_p[c("logsize")], FUN=mean)
data_v4_p_avg <- aggregate(data_v4_p[c("time")], by=data_v4_p[c("logsize")], FUN=mean)

logsize_vac_plot <- ggplot(data = NULL, aes(x = logsize, y = time)) +
  geom_point(data = apriori_p_avg, alpha=0.5, size=5, aes(shape="apriori")) +  
  geom_line(data = apriori_p_avg, aes(linetype="apriori")) +
  geom_point(data = data_v1_p, alpha=0.25, size=7, aes(shape="no par.")) +
  geom_point(data = data_v1_p_avg, alpha=0.5, size=5, shape=17, show.legend=FALSE) + # black triangle  
  geom_line(data = data_v1_p_avg, aes(linetype="no par.")) +
  geom_point(data = data_v3_p, alpha=0.25, size=7, aes(shape="par. src.sp.")) +
  geom_point(data = data_v3_p_avg, alpha=0.5, size=5, shape=19, show.legend=FALSE) + # black disc
  geom_line(data = data_v3_p_avg, aes(linetype="par. src.sp.")) +
  geom_point(data = data_v4_p, alpha=0.25, size=7, aes(shape="par. db.")) +
  geom_point(data = data_v4_p_avg, alpha=0.5, size=5, shape=18, show.legend=FALSE) + # black diamond
  geom_line(data = data_v4_p_avg, aes(linetype="par. db."))
  
x_minor_ticks=sort(unique(data_v1_p$logsize))
x_ticks=x_minor_ticks[seq(1, length(x_minor_ticks), 2)]

logsize_vac_plot <- logsize_vac_plot +
  #  ylim(0,80000) +
  # scale_y_log10(labels = comma) +
  # annotation_logticks(sides = "l") +
  # coord_trans(y = "log10") +
  scale_y_continuous(labels = comma, breaks=c(1.000,2.500,5.000,7.500,10.000)) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time v. log size", x = "Traces in log", y = "Computation time [sec]", shape = "Algorithm", linetype = "Algorithm")) +
  serious_theme + theme(legend.position=c(.2,.85), plot.title=element_blank(), axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
  scale_linetype_manual(breaks = customlinetypes$types, values=customlinetypes$lines)

plot (logsize_vac_plot)

dev.off()

#
#
################################################################
# Time saving with parallelism, w.r.t. log size. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-logsize-alpha0-savings.pdf")

# Merge data_v1_p_avg and data_v3_p_avg by their "logsize" column and subtract the respective "time" content
data_v1_v3_p_avg <- within(merge(data_v1_p_avg,data_v3_p_avg,by="logsize"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("logsize","time")]

# Merge data_v1_p_avg and data_v4_p_avg by their "logsize" column and subtract the respective "time" content
data_v1_v4_p_avg <- within(merge(data_v1_p_avg,data_v4_p_avg,by="logsize"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("logsize","time")]

sav_logsize_vac_plot <- ggplot(data = NULL, aes(x = logsize, y = time)) +
  geom_point(data = data_v1_v3_p_avg, alpha=0.5, size=5, aes(shape="vs par.src.sp")) + # disc
  geom_line(data = data_v1_v3_p_avg, aes(linetype="vs par.src.sp")) +
  geom_point(data = data_v1_v4_p_avg, alpha=0.5, size=5, aes(shape="vs par.db")) + # diamond
  geom_line(data = data_v1_v4_p_avg, aes(linetype="vs par.db"))

sav_logsize_vac_plot <- sav_logsize_vac_plot +
  ylim(-30,75) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time saved with parallelism v. log size", x = "Traces in log", y = "Relative difference in comp. time [%]", shape = "Comparison", linetype = "Comparison")) +
  serious_theme + theme(legend.position=c(.2,.85), plot.title=element_blank(), axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_shape_manual(breaks = compashapetypes$types, values=compashapetypes$shapes) +
  scale_linetype_manual(breaks = compalinetypes$types, values=compalinetypes$lines)

plot (sav_logsize_vac_plot)

dev.off()

#
#
################################################################
# Time w.r.t. log size + savings. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-logsize-alpha0-savings-tile.pdf", height = 14, width = 8)

grid.newpage()
grid.draw(rbind(
  ggplotGrob(logsize_vac_plot +
               theme(axis.text.x = element_blank(), axis.title.x = element_blank())
    ), 
  ggplotGrob(sav_logsize_vac_plot),
  size="first"))

dev.off()

#
#
################################################################
# W.r.t. alphabet size. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-alphabet-alpha100.pdf")

data_v1_p <- data_v1[which(data_v1$logsize == default_logsize & data_v1$minlen == default_tracelen & data_v1$support == default_support & data_v1$alpha == no_vacuity),]
data_v3_p <- data_v3[which(data_v3$logsize == default_logsize & data_v3$minlen == default_tracelen & data_v3$support == default_support & data_v3$alpha == no_vacuity),]
data_v4_p <- data_v4[which(data_v4$logsize == default_logsize & data_v4$minlen == default_tracelen & data_v4$support == default_support & data_v4$alpha == no_vacuity),]
apriori_p <- apriori[which(apriori$logsize == default_logsize & apriori$minlen == default_tracelen & apriori$support == default_support & apriori$alpha == no_vacuity),]

# Outliers removal
data_v1_p <- rbind(data_v1_p[(data_v1_p$alphabet == 56 & data_v1_p$time < 25),], data_v1_p[data_v1_p$alphabet != 56,])

apriori_p_avg <- aggregate(apriori_p[c("time")], by=apriori_p[c("alphabet")], FUN=mean)
data_v1_p_avg <- aggregate(data_v1_p[c("time")], by=data_v1_p[c("alphabet")], FUN=mean)
data_v3_p_avg <- aggregate(data_v3_p[c("time")], by=data_v3_p[c("alphabet")], FUN=mean)
data_v4_p_avg <- aggregate(data_v4_p[c("time")], by=data_v4_p[c("alphabet")], FUN=mean)

alphabet_novac_plot <- ggplot(data = NULL, aes(x = alphabet, y = time)) +
  geom_point(data = apriori_p_avg, alpha=0.5, size=5, aes(shape="apriori")) +  
  geom_line(data = apriori_p_avg, aes(linetype="apriori")) +
  geom_point(data = data_v1_p, alpha=0.25, size=7, aes(shape="no par.")) +
  geom_point(data = data_v1_p_avg, alpha=0.5, size=5, shape=17, show.legend=FALSE) + # black triangle  
  geom_line(data = data_v1_p_avg, aes(linetype="no par.")) +
  geom_point(data = data_v3_p, alpha=0.25, size=7, aes(shape="par. src.sp.")) +
  geom_point(data = data_v3_p_avg, alpha=0.5, size=5, shape=19, show.legend=FALSE) + # black disc
  geom_line(data = data_v3_p_avg, aes(linetype="par. src.sp.")) +
  geom_point(data = data_v4_p, alpha=0.25, size=7, aes(shape="par. db.")) +
  geom_point(data = data_v4_p_avg, alpha=0.5, size=5, shape=18, show.legend=FALSE) + # black diamond
  geom_line(data = data_v4_p_avg, aes(linetype="par. db."))
  
x_minor_ticks=sort(unique(data_v1_p$alphabet))
x_ticks=x_minor_ticks[seq(1, length(x_minor_ticks), 2)]

alphabet_novac_plot <- alphabet_novac_plot +
  #  ylim(0,80000) +
  #scale_y_log10(labels = comma) +
  #annotation_logticks(sides = "l") +
  scale_y_continuous(labels = comma, breaks = c(5.000,10.000,25.000,50.000,100.000)) +
  # coord_trans(y = "log10") +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time v. alphabet size", x = "Alphabet size", y = "Computation time [sec]", shape = "Algorithm", linetype = "Algorithm")) +
  serious_theme + theme(legend.position=c(.25,.85), plot.title=element_blank()) +
  scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
  scale_linetype_manual(breaks = customlinetypes$types, values=customlinetypes$lines)

plot (alphabet_novac_plot)

dev.off()

#
#
################################################################
# Time saving with parallelism, w.r.t. alphabet size. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-alphabet-alpha100-savings.pdf")

# Merge data_v1_p_avg and data_v3_p_avg by their "alphabet" column and subtract the respective "time" content. Scale it as a percentage.
data_v1_v3_p_avg <- within(merge(data_v1_p_avg,data_v3_p_avg,by="alphabet"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("alphabet","time")]

# Merge data_v1_p_avg and data_v4_p_avg by their "alphabet" column and subtract the respective "time" content. Scale it as a percentage.
data_v1_v4_p_avg <- within(merge(data_v1_p_avg,data_v4_p_avg,by="alphabet"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("alphabet","time")]

sav_alphabet_novac_plot <- ggplot(data = NULL, aes(x = alphabet, y = time)) +
  geom_point(data = data_v1_v3_p_avg, alpha=0.5, size=5, aes(shape="vs par.src.sp")) + # disc
  geom_line(data = data_v1_v3_p_avg, aes(linetype="vs par.src.sp")) +
  geom_point(data = data_v1_v4_p_avg, alpha=0.5, size=5, aes(shape="vs par.db")) + # diamond
  geom_line(data = data_v1_v4_p_avg, aes(linetype="vs par.db"))


sav_alphabet_novac_plot <- sav_alphabet_novac_plot +
  ylim(-30,75) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time saved with parallelism v. alphabet size", x = "Alphabet size", y = "Relative difference in comp. time [%]", shape = "Comparison", linetype = "Comparison")) +
  serious_theme + theme(legend.position=c(.2,.85), plot.title=element_blank()) +
  scale_shape_manual(breaks = compashapetypes$types, values=compashapetypes$shapes) +
  scale_linetype_manual(breaks = compalinetypes$types, values=compalinetypes$lines)

plot (sav_alphabet_novac_plot)

dev.off()

#
#
################################################################
# Time w.r.t. alphabet size + savings. No vacuity detection
################################################################
#
#

pdf("graphs/time-v-alphabet-alpha100-savings-tile.pdf", height = 14, width = 8)

grid.newpage()
grid.draw(rbind(
  ggplotGrob(alphabet_novac_plot +
               theme(axis.text.x = element_blank(), axis.title.x = element_blank())
  ), 
  ggplotGrob(sav_alphabet_novac_plot),
  size="first"))

dev.off()

#
#
################################################################
# W.r.t. alphabet size. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-alphabet-alpha0.pdf")

data_v1_p <- data_v1[which(data_v1$logsize == default_logsize & data_v1$minlen == default_tracelen & data_v1$support == default_support & data_v1$alpha == with_vacuity),]
data_v3_p <- data_v3[which(data_v3$logsize == default_logsize & data_v3$minlen == default_tracelen & data_v3$support == default_support & data_v3$alpha == with_vacuity),]
data_v4_p <- data_v4[which(data_v4$logsize == default_logsize & data_v4$minlen == default_tracelen & data_v4$support == default_support & data_v4$alpha == with_vacuity),]
apriori_p <- apriori[which(apriori$logsize == default_logsize & apriori$minlen == default_tracelen & apriori$support == default_support & apriori$alpha == with_vacuity),]

# Outliers removal
data_v1_p <- data_v1_p[data_v1_p$time < 10,]

apriori_p_avg <- aggregate(apriori_p[c("time")], by=apriori_p[c("alphabet")], FUN=mean)
data_v1_p_avg <- aggregate(data_v1_p[c("time")], by=data_v1_p[c("alphabet")], FUN=mean)
data_v3_p_avg <- aggregate(data_v3_p[c("time")], by=data_v3_p[c("alphabet")], FUN=mean)
data_v4_p_avg <- aggregate(data_v4_p[c("time")], by=data_v4_p[c("alphabet")], FUN=mean)

alphabet_vac_plot <- ggplot(data = NULL, aes(x = alphabet, y = time)) +
  geom_point(data = apriori_p_avg, alpha=0.5, size=5, aes(shape="apriori")) +  
  geom_line(data = apriori_p_avg, aes(linetype="apriori")) +
  geom_point(data = data_v1_p, alpha=0.25, size=7, aes(shape="no par.")) +
  geom_point(data = data_v1_p_avg, alpha=0.5, size=5, shape=17, show.legend=FALSE) + # black triangle  
  geom_line(data = data_v1_p_avg, aes(linetype="no par.")) +
  geom_point(data = data_v3_p, alpha=0.25, size=7, aes(shape="par. src.sp.")) +
  geom_point(data = data_v3_p_avg, alpha=0.5, size=5, shape=19, show.legend=FALSE) + # black disc
  geom_line(data = data_v3_p_avg, aes(linetype="par. src.sp.")) +
  geom_point(data = data_v4_p, alpha=0.25, size=7, aes(shape="par. db.")) +
  geom_point(data = data_v4_p_avg, alpha=0.5, size=5, shape=18, show.legend=FALSE) + # black diamond
  geom_line(data = data_v4_p_avg, aes(linetype="par. db."))
  
x_minor_ticks=sort(unique(data_v1_p$alphabet))
x_ticks=x_minor_ticks[seq(1, length(x_minor_ticks), 2)]

alphabet_vac_plot <- alphabet_vac_plot +
  #  ylim(0,80000) +
  # scale_y_log10(labels = comma) +
  # annotation_logticks(sides = "l") +
  # coord_trans(y = "log10") +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time v. alphabet size", x = "Alphabet size", y = "Computation time [sec]", shape = "Algorithm", linetype = "Algorithm")) +
  serious_theme + theme(legend.position=c(.2,.8), plot.title=element_blank()) +
  scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
  scale_linetype_manual(breaks = customlinetypes$types, values=customlinetypes$lines)

plot (alphabet_vac_plot)

dev.off()

#
#
################################################################
# Time saving with parallelism, w.r.t. alphabet size. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-alphabet-alpha0-savings.pdf")

# Merge data_v1_p_avg and data_v3_p_avg by their "alphabet" column and subtract the respective "time" content
data_v1_v3_p_avg <- within(merge(data_v1_p_avg,data_v3_p_avg,by="alphabet"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("alphabet","time")]

# Merge data_v1_p_avg and data_v4_p_avg by their "alphabet" column and subtract the respective "time" content
data_v1_v4_p_avg <- within(merge(data_v1_p_avg,data_v4_p_avg,by="alphabet"), {
  time <- ( (time.x - time.y) / time.x )  * 100
})[,c("alphabet","time")]

sav_alphabet_vac_plot <- ggplot(data = NULL, aes(x = alphabet, y = time)) +
  geom_point(data = data_v1_v3_p_avg, alpha=0.5, size=5, aes(shape="vs par.src.sp")) + # disc
  geom_line(data = data_v1_v3_p_avg, aes(linetype="vs par.src.sp")) +
  geom_point(data = data_v1_v4_p_avg, alpha=0.5, size=5, aes(shape="vs par.db")) + # diamond
  geom_line(data = data_v1_v4_p_avg, aes(linetype="vs par.db"))


sav_alphabet_vac_plot <- sav_alphabet_vac_plot +
  ylim(-30,75) +
  scale_x_continuous(breaks = x_ticks, minor_breaks=x_minor_ticks, labels = comma) +
  labs(list(title = "Time saved with parallelism v. alphabet size", x = "Alphabet size", y = "Relative difference in comp. time [%]", shape = "Comparison", linetype = "Comparison")) +
  serious_theme + theme(legend.position=c(.2,.85), plot.title=element_blank()) +
  scale_shape_manual(breaks = compashapetypes$types, values=compashapetypes$shapes) +
  scale_linetype_manual(breaks = compalinetypes$types, values=compalinetypes$lines)

plot (sav_alphabet_vac_plot)

dev.off()

#
#
################################################################
# Time w.r.t. alphabet size + savings. With vacuity detection
################################################################
#
#

pdf("graphs/time-v-alphabet-alpha0-savings-tile.pdf", height = 14, width = 8)

grid.newpage()
grid.draw(rbind(
  ggplotGrob(alphabet_vac_plot +
               theme(axis.text.x = element_blank(), axis.title.x = element_blank())
  ), 
  ggplotGrob(sav_alphabet_vac_plot),
  size="first"))

dev.off()

#
#
################################################################
# Time saving with and without vacuity detection enabled.
################################################################
#
#

pdf("graphs/saved-timing-vac-v-novac.pdf", width = 16, height = 9)

data_v1_p <- data_v1[which(data_v1$alphabet == default_alphabet & data_v1$logsize == default_logsize & data_v1$minlen == default_tracelen),]
data_v3_p <- data_v3[which(data_v3$alphabet == default_alphabet & data_v3$logsize == default_logsize & data_v3$minlen == default_tracelen),]
data_v4_p <- data_v4[which(data_v4$alphabet == default_alphabet & data_v4$logsize == default_logsize & data_v4$minlen == default_tracelen),]

data_v1_p_avg <- aggregate(data_v1_p[c("time")], by=data_v1_p[c("support","alpha")], FUN=mean)
data_v3_p_avg <- aggregate(data_v3_p[c("time")], by=data_v3_p[c("support","alpha")], FUN=mean)
data_v4_p_avg <- aggregate(data_v4_p[c("time")], by=data_v4_p[c("support","alpha")], FUN=mean)

data_v1_p_avg[,c("variant")]="no par."
data_v3_p_avg[,c("variant")]="par. src.sp."
data_v4_p_avg[,c("variant")]="par. db."

data_v_p_avg <- rbind(data_v1_p_avg, data_v3_p_avg, data_v4_p_avg, make.row.names = TRUE)
data_v_p_avg$saved <- NA
data_v_p_avg$diffvacnovac <- data_v_p_avg$time

# Calculate the time saved by including the vacuity check
savings <- within(
  merge(
    data_v_p_avg[which(data_v_p_avg$alpha==100),],
    data_v_p_avg[which(data_v_p_avg$alpha==0),],
    by=c("support","variant")), {
      saved <- ( (time.x - time.y) / time.x ) * 100 * (-1)
      diffvacnovac <- time.x - time.y
      time <- time.x
      alpha <- alpha.x
    }
)[,c("variant","support","time","diffvacnovac","saved","alpha")]
# Update the "saved" time in the appropriate tuples of data_v_p_avg
data_v_p_avg <- rbind(data_v_p_avg[which(data_v_p_avg$alpha==0),],savings)

data_v_p_avg$alpha <- factor(data_v_p_avg$alpha, levels=c(100,0), labels=c("disabled","enabled"))

data_v_p_avg

plot(
  ggplot(data = data_v_p_avg, 
         aes(x = support, y = diffvacnovac) ) + 
    geom_bar(aes(x = support, y = diffvacnovac, fill = alpha), 
             position="stack", stat = "identity", alpha = 0.75) +
    geom_text(data = data_v_p_avg[which(data_v_p_avg$alpha=="disabled"),], 
              aes(x = support, y = time - diffvacnovac, label = paste0(sprintf("%.02f",saved),"%")), 
              size=6, na.rm = TRUE, angle = 90, hjust = -0.1) +
    facet_grid(~ variant) +
    serious_theme +
    scale_fill_manual(values=c("#BBBBBB","#000000")) +
    labs(fill = "Vacuity detection", x = "support [%]", y = "time [sec]")
)

dev.off()