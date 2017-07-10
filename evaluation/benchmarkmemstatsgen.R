#
# Creates memory usage summary CSV files from separate, single-version time performance CSV files contained in data/
# Author: Claudio Di Ciccio
# Version: 2017/07/07
#

memdata_v1 <- read.csv2(file='data/v1-benchmark_memory_usage.csv', sep=";", quote="'", header=TRUE, comment.char="#")[c("file","support","alpha","memoryavg")]
memdata_v3 <- read.csv2(file='data/v3-benchmark_memory_usage.csv', sep=";", quote="'", header=TRUE, comment.char="#")[c("file","support","alpha","memoryavg")]
memdata_v4 <- read.csv2(file='data/v4-benchmark_memory_usage.csv', sep=";", quote="'", header=TRUE, comment.char="#")[c("file","support","alpha","memoryavg")]

memdata_v1$memoryavg <- as.numeric(as.character(memdata_v1$memoryavg)) / (1024.0*1024)
memdata_v3$memoryavg <- as.numeric(as.character(memdata_v3$memoryavg)) / (1024.0*1024)
memdata_v4$memoryavg <- as.numeric(as.character(memdata_v4$memoryavg)) / (1024.0*1024)

names(memdata_v1)[names(memdata_v1) == "memoryavg"] = "v1"
names(memdata_v3)[names(memdata_v3) == "memoryavg"] = "v3"
names(memdata_v4)[names(memdata_v4) == "memoryavg"] = "v4"

#memdata_v1$variant <- 'miner' 
#memdata_v3$variant <- 'parallelised over search space' 
#memdata_v4$variant <- 'parallelised over database' 
memdata <- merge(memdata_v1, memdata_v3, by=c("file","support","alpha"), all=TRUE)
memdata <- merge(memdata, memdata_v4, by=c("file","support","alpha"), all=TRUE)
memdata$support <- as.numeric(as.character(memdata$support))

print.benchmark.memdata <- function(memdata,output_csv_file,vacuity) {
  memdata_p <- memdata[which(memdata$alpha == vacuity),c("file","support","v1","v3","v4")]

  memdata_p$v1 <- sprintf("%.3f", round(memdata_p$v1, digits = 3))
  memdata_p$v3 <- sprintf("%.3f", round(memdata_p$v3, digits = 3))
  memdata_p$v4 <- sprintf("%.3f", round(memdata_p$v4, digits = 3))
  
  memdata_p$`v1` <- prettyNum(memdata_p$`v1`, big.mark = ",")
  memdata_p$`v3` <- prettyNum(memdata_p$`v3`, big.mark = ",")
  memdata_p$`v4` <- prettyNum(memdata_p$`v4`, big.mark = ",")
  
  memdata_p <- memdata_p[with(memdata_p, order(file, support)), ]

  write.table(memdata_p, file=output_csv_file, row.names = FALSE, col.names = TRUE, sep=";")
}

print.benchmark.memdata(memdata,'data/benchmark_memory_usage-w-vacuity.csv','0')
print.benchmark.memdata(memdata,'data/benchmark_memory_usage-wo-vacuity.csv','100')
