# Libraries
library(tidyverse) # for data manipulation
library(vcd)  # for dealing with categorical data
accidents <- read.csv('road-accidents-2010.csv', header=TRUE,as.is=TRUE, na.strings="-1")
# use the function as.Dates to convert string to dates
accidents$mydate <- as.Date(accidents$Date, format="%d/%m/%Y")
accidents$Fatality <- accidents$Accident_Severity == 1
 sum(! (accidents$Weather_Conditions %in% 1:6))
sum(! (accidents$Weather_Conditions %in% 1:6))/nrow(accidents)
# Cheking number of missing values
accidents %>%
  summarise_all(~(sum(is.na(.))))

accidents=na.omit(accidents)
# dim(accidents)
accidents <- subset(accidents, accidents$Weather_Conditions %in% 1:6,)
help(subset)
dim(accidents)

newframe=accidents %>% group_by(mydate)%>% summarise(N=n(), meanW=mean(Weather_Conditions), p.fatal=mean(Fatality))
names(newframe)[1]="Date"
#extracting the day of the week, 0=Sunday
newframe$Day=format(newframe$Date, "%w")

# PLOT 1
plot1=ggplot(data=newframe, aes(x=Day, y=N))
plot1+geom_boxplot()
plot1+geom_jitter(aes(size=p.fatal, color=meanW), position=position_jitter(w=.3, h=.0))
plot1+geom_boxplot()+geom_jitter(aes(size=p.fatal, color=meanW), position=position_jitter(w=.3, h=.0))+ggtitle("Number of accidents by day of the week")+
  xlab("Day of the week. 0 is Sunday") +
  ylab("Number of accidents in a day")

#  PLOT 2
# Fatality rates by weather severity
plot2 <- ggplot(data=newframe, aes(x=meanW, y=p.fatal))
plot2 <-plot2 +
  geom_point(aes(size=Day, color=N))+
  geom_smooth(color="black")+
  ggtitle("Proporton of fatalities by mean weather condition")+
  xlab("Mean Weather Severity") +
  ylab("Proportion of accidents with at least one fatality")
plot2
# PLOT 3
##number of accidents by day
plot3<- ggplot(data=newframe, aes(x=Date, y=N))+
    ggtitle("Number of accidents with injury in 2010")+
    xlab("Date")+ylab("Number of accidents")+
    geom_point()+
    geom_smooth()
plot3

## by month
# Extract the month
newframe$month <- as.numeric(format(newframe$Date, "%m"))
#calculations to compute confidence intervals, N is number of accidents each day

newframe2=newframe %>% group_by(month)%>% summarise(Mu=mean(N), s=sd(N), se=s/sqrt(n()),lcp= Mu-
qt(0.975,n()-1)*se,ucp= Mu+
qt(0.975,n()-1)*se)

# PLOT 4
ggplot(newframe2,aes(x=month, y=Mu))+geom_line()+geom_ribbon(aes(ymin=lcp,ymax=ucp), fill="grey70", alpha=0.7)+geom_line(aes(y=Mu))+scale_x_continuous(breaks=c(1:12))
# or
plot4 <- ggplot(data=newframe2, aes(x=month, y=Mu))+
    ggtitle("Number of accidents by month")+
    xlab("Month")+ylab("Mean number of accidents by month with 95% ci")+
    geom_point()+
    geom_errorbar(aes(ymin=lcp, ymax=ucp), width=0.2)+
    geom_line(aes(group=1))+
    scale_x_continuous(breaks=c(1:12))

## 
# let's try to extract the hour of the day an accidents happens
accidents$DateTime <- as.POSIXlt(paste(accidents$Date," ",accidents$Time), format="%d/%m/%Y %H:%M", tz="GMT")
accidents$DateTime[1:10]
accidents$Hour <- as.numeric(format(accidents$DateTime, "%H"))

# PLOT 5
ggplot(data=accidents, aes(x=Hour))+
  ggtitle("Histogram of accidents with injury by hour of the day")+
  ylab("Number of accidents")+xlab("Hour of the day")+
  geom_histogram( binwidth=1, alpha=0.2)

ggplot(data=accidents, aes(x=Hour,after_stat(density)))+
  ggtitle("Histogram of accidents with injury by hour of the day")+
  ylab("Relative Freq. of accidents")+xlab("Hour of the day")+
  geom_histogram( binwidth=1, alpha=0.2)+geom_density()

# the warning is because there are four missing values, probably due to the conversion process from dates to Hour
sum(is.na(accidents$Hour))

# contingency table
newframe4=table(accidents$Hour, accidents$Fatality)
newframe4
# it is better to use command xtabs(), altough the output is the same. It's used to obtain a contingency table in Frequency Form from 
# a table in Case Form.

#contingency table
newframe5=xtabs(~Hour+Fatality,data=accidents)
addmargins(newframe5)
# showing proportions instead of frequencies
prop.table(newframe5,1)
chisq.test(newframe5)
# warning: proportions are close to 0 or 1 and our sample size doesn't meet requirements for the test to work well
# obtaining the p-value by simulation
chi1=chisq.test(newframe5, simulate.p.value=TRUE)
# residuals
chi1$residuals
#expected values
chi1$expected
# the original table
chi1$obs

#function mosaic(), package vcd
mosaic(newframe5, shade=TRUE)

# preliminary plot
plot(prop.table(newframe5,1)[,2], type="l", xlab="", ylab="")

# Let's create a new variable, grouping variable Hour
accidents <- accidents%>% mutate(Hour_n=cut(Hour, breaks=c(0,6,12,18,23),include.lowest = TRUE,right=TRUE,
                                            labels=c("G1","G2","G3","G4")))
newframe8=xtabs(~Hour_n+Fatality,data=accidents)
prop.table(newframe8,1)
mosaic(newframe8, shade=TRUE)

#Variables Fatality and Hour
newframe6=accidents[,c(34,36)]

newframe7=newframe6 %>% group_by(Hour) %>% summarise(n=sum(Fatality), N=n(), p=n/N, cil=p-1.96*sqrt((p*(1-p)/N)), ciu=p+1.96*sqrt((p*(1-p)/N)) )

################### PLOT 6
plot6 <- ggplot(data=newframe7, aes(x=Hour, y=p))+
  ggtitle("Probability of a fatality by hour of the day")+
  xlab("Hour of the day")+ylab("Probability of a fatality and 95% ci")+
  geom_point()+
  geom_line()+
  geom_errorbar(aes(ymin=cil, ymax=ciu), width=0.2)

plot6


# Exercise: Construct the contingency table Month X Fatality, Day of the week x Fatality and test the hypothesis of independence. Does # the day of # the week or the month of the # year make any difference in the distribution of fatality accidents? Interpret the output of the test, # # the residuals and plot a mosaic for each test. 
