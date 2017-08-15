setwd("/Users/william/Desktop/Burning_glass")
library(readr)
BGT <- as.data.frame(read_csv("~/Desktop/Burning_glass/BGT_class.csv"))
#View(BGT)

library(DBI)
library(RMySQL)
BG <- dbConnect(MySQL(), user = 'root', password = 'MySQLag1ne', host = 'localhost', dbname = 'BG')

dbWriteTable(conn = BG, name = 'BG_HR', value = BGT)



library(readr)
#class <- read_csv("C:/Users/kjohn/Desktop/BG/BGT_class.csv")
MSA <- BGT[which(BGT$State_Name == 'PA'|BGT$State_Name=='NJ'|BGT$State_Name=='NY'),]
x <- (unique(BGT$County))
x <- sort(x)

# import jon posting data by coutnties
MSA_Counties <- x[c(18,24,61,64,85,86,93,111,113,117,119,123,129,133,138,141,147,149,151,153,166,169,172,178,184)]

MSA_V <- as.vector(MSA_Counties)
MSA1 <- MSA[is.element(MSA$County,MSA_V),]

MSA2 <- MSA1[which(MSA1$Occupation_Code != 0),]
MSA3 <- MSA2[c(3,6,8:14,16,19,22)]

#missing<-MSA1$Occupation_Title[MSA1$Salary==0]
#Tmissing <-table(missing)
#head(sort.int(Tmissing, decreasing=T), 50)

# import unemployement data
library(readr)
#unemployement <- as.data.frame(read_csv("~/Desktop/Burning_glass/unemployment-by-county-us/output.csv"))
unemployement <- as.data.frame(read_excel("~/Desktop/Burning_glass/POP.xlsx",sheet = "Rate"))

statelist<-unique(unemployement$State)
countylist<-unique(unemployement$County)

# import population data by counties
library(readxl)
POP_NY <- as.data.frame(read_excel("~/Desktop/Burning_glass/POP.xlsx",sheet = "NY"))
POP_PEN <- as.data.frame(read_excel("~/Desktop/Burning_glass/POP.xlsx",sheet = "PEN"))
POP_CON <- as.data.frame(read_excel("~/Desktop/Burning_glass/POP.xlsx",sheet = "CON"))
POP_NJ <- as.data.frame(read_excel("~/Desktop/Burning_glass/POP.xlsx",sheet = "NJ"))

# merge & clean all data, then subset it for 2014 & counties we are interested in
a<-rbind(POP_NY,POP_PEN,POP_CON,POP_NJ)
POP_unemployement<-merge(unemployement,a,by="County",all.x=TRUE)
names(POP_unemployement)[7]<-"POP_2014"
POP_unemployement$unemployed<-ceiling(.5/100*POP_unemployement$Rate * POP_unemployement$POP_2014)
POP_unemployement<-POP_unemployement[POP_unemployement$Year==2014,]

unemployement2014<-aggregate(POP_unemployement[ , 8], list(POP_unemployement$`county_state`), mean)
names(unemployement2014)<-c("county_state", "unemployement")
a<-aggregate(POP_unemployement[ , 5], list(POP_unemployement$`county_state`), mean)
names(a)<-c("a","z")
unemployement2014$Rate<-a$z
unemployement2014$unemployement<-ceiling(unemployement2014$unemployement)
unemployement2014$county_state<-toupper(unemployement2014$county_state)

#POP_unemployement$`county, state`<-NULL

MSA3$State_Name<-replace(MSA3$State_Name, which(MSA3$State_Name == "PA"), "PENNSYLVANIA")
MSA3$State_Name<-replace(MSA3$State_Name, which(MSA3$State_Name == "NY"), "NEW YORK")
MSA3$State_Name<-replace(MSA3$State_Name, which(MSA3$State_Name == "NJ"), "NEW JERSEY")
MSA3$State_Name<-toupper(MSA3$State_Name)
MSA3$State_abv<-MSA3$State_Name

MSA3$county_state <- with(MSA3, paste0(MSA3$County, ", ", MSA3$State_Name))

MSA69<-merge(MSA3,unemployement2014,by="county_state",all.x=TRUE)

# save data
save(unemployement2014, file = "unemployement2014.RData")
save(MSA3, file = "MSA3.RData")
save(MSA69, file = "MSA69.RData")

# export to MySQL
library(DBI)
library(RMySQL)
BG <- dbConnect(MySQL(), user = 'root', password = 'MySQLag1ne', host = 'localhost', dbname = 'BG')
dbWriteTable(conn = BG, name = 'BG_job', value = MSA3)

BG <- dbConnect(MySQL(), user = 'root', password = 'MySQLag1ne', host = 'localhost', dbname = 'BG')
dbWriteTable(conn = BG, name = 'BG_needjob', value = unemployement2014)





################################### AGE ###################################
library(readr)
AGE_all <- as.data.frame(read_csv("~/Desktop/Burning_glass/Data USA - Map of Median Age by County.csv"))
View(AGE_all)









  
  
  
  
  
