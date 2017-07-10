#
# Creates performance summary CSV files from separate, single-version time performance CSV files contained in data/
# Author: Claudio Di Ciccio
# Version: 2017/07/07
#

timedata_v1 <- read.csv2(file='data/v1-benchmark_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")[c("file","support","alpha","time")]
timedata_v3 <- read.csv2(file='data/v3-benchmark_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")[c("file","support","alpha","time")]
timedata_v4 <- read.csv2(file='data/v4-benchmark_performance.csv', sep=";", quote="'", header=TRUE, comment.char="#")[c("file","support","alpha","time")]

timedata_v1_avg <- aggregate(timedata_v1[c("time")], by=timedata_v1[c("file","support","alpha")], FUN=mean)
timedata_v3_avg <- aggregate(timedata_v3[c("time")], by=timedata_v3[c("file","support","alpha")], FUN=mean)
timedata_v4_avg <- aggregate(timedata_v4[c("time")], by=timedata_v4[c("file","support","alpha")], FUN=mean)

timedata_v4_avg

timedata_v1_avg$time <- as.numeric(as.character(timedata_v1_avg$time)) / (1000.0)
timedata_v3_avg$time <- as.numeric(as.character(timedata_v3_avg$time)) / (1000.0)
timedata_v4_avg$time <- as.numeric(as.character(timedata_v4_avg$time)) / (1000.0)

names(timedata_v1_avg)[names(timedata_v1_avg) == "time"] = "v1"
names(timedata_v3_avg)[names(timedata_v3_avg) == "time"] = "v3"
names(timedata_v4_avg)[names(timedata_v4_avg) == "time"] = "v4"

#timedata_v1_avg$variant <- 'miner'  
#timedata_v3_avg$variant <- 'parallelised over search space' 
#timedata_v4_avg$variant <- 'parallelised over database' 
timedata <- merge(timedata_v1_avg, timedata_v3_avg, by=c("file","support","alpha"), all=TRUE)
timedata <- merge(timedata, timedata_v4_avg, by=c("file","support","alpha"), all=TRUE)
timedata$support <- as.numeric(as.character(timedata$support))

print.benchmark.timedata <- function(timedata,output_csv_file,vacuity) {
  timedata_p <- timedata[which(timedata$alpha == vacuity),c("file","support","v1","v3","v4")]

  timedata_p$v1 <- sprintf("%.3f", round(timedata_p$v1, digits = 3))
  timedata_p$v3 <- sprintf("%.3f", round(timedata_p$v3, digits = 3))
  timedata_p$v4 <- sprintf("%.3f", round(timedata_p$v4, digits = 3))
  
  timedata_p$`v1` <- prettyNum(timedata_p$`v1`, big.mark = ",")
  timedata_p$`v3` <- prettyNum(timedata_p$`v3`, big.mark = ",")
  timedata_p$`v4` <- prettyNum(timedata_p$`v4`, big.mark = ",")
  
  timedata_p <- timedata_p[with(timedata_p, order(file, support)), ]

  write.table(timedata_p, file=output_csv_file, row.names = FALSE, col.names = TRUE, sep=";")
}

print.benchmark.timedata(timedata,'data/benchmark_performance-w-vacuity.csv','0')

print.benchmark.timedata(timedata,'data/benchmark_performance-wo-vacuity.csv','100')
