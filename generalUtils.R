#*****Libraries*****
#Nothing yet.
#****Requires*******
#Nothing yet.
#****Sources********
#Nothing yet.

#On this file we can create general auxiliary/util functions to be used on other files.

gameRanking<-function(x,y) {
  difference<-abs(x-y)
  total<-(x+y)
  game.Ranking<-(((total-170)/10)+(5-(difference/5)))
  
  
  return(game.Ranking)
  
}