#*****Libraries*****
#Nothing yet.
#****Requires*******
#Nothing yet.
#****Sources********
#Nothing yet.

#On this file we can create general auxiliary/util functions to be used on other files.

#***********START Testing different possiblities to create barplotDT.

#1. Creating a data frame
barPlotDT1<-data.frame(Position=c("PG"), Name=c("Steve"), 
                      Salary=c("9000"), Team=c("UTA"), 
                      vsTeam=c("LAL"), Type=c("Projected"),
                      Points=c("90"), Minutes=c("28"),
                      Points_Salary=c("10"),
                      Points_Min=c("13"))

barPlotDT<-data.frame(Position=c("PG"), Name=c("Mteve"), 
                      Salary=c("9000"), Team=c("UTA"), 
                      vsTeam=c("LAL"), Type=c("Projected"),
                      Points=c("90"), Minutes=c("28"),
                      Points_Salary=c("10"),
                      Points_Min=c("13"))
#Merging 2 data frames
barPlotDT<-rbind(barPlotDT, barPlotDT1)

#Function test, does not work.
barPlotDT<-createBarPlotDT(barPlotDT, players)

createBarPlotDT <- function(barPlotDT, playersDT){
  barPlotDT<-sapply(playersDT$Name, function(x){
   projDF<-data.frame(Position=c(x), Name=c(x), 
                         Salary=c(x), Team=c(x), 
                         vsTeam=c(x), Type=c("Projected"),
                         Points=c(x), Minutes=c(x),
                         Points_Salary=c(x),
                         Points_Min=c(x))
   
    barPlotDT<-rbind(barPlotDT,projDF)
    
    return(barPlotDT)
  })
}

#For loop test
for(i in 1:nrow(playersDT)) {
  row <- playersDT[i,]
  # do stuff with row
  barPlotDT<-cbind(Name=c(row$Salary))
}
#***********END Testing different possiblities to create barplotDT************