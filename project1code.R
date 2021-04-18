## Reproducible Research - Course Project 1



## LOADING AND PREPROCESSING THE DATA

## 1. Loading and reading data

if(!file.exists("activity")){
    unzip("activity.zip")
}

data <- read.csv(file = "activity.csv")

## 2. Processing data

data$date <- as.Date(data$date, format = "%Y-%m-%d")



## MEAN OF STEPS PER DAY

library(dplyr)


## 1. Calculating total steps per day

prespd <- group_by(data,date)
spd <- summarise(prespd, total_steps = sum(steps))

## 2. Building histogram of steps per day

hist(spd$total_steps, main = "Histogram of Steps per Day", 
     xlab = "Number of Steps", ylab = "Frequency", col = "blue")

## 3. Calculating mean and median of total steps per day

mean(spd$total_steps, na.rm = TRUE)
median(spd$total_steps, na.rm = TRUE)



## AVERAGE DAILY ACTIVITY PATTERN

## 1. Building line plot of steps by interval

preadp <- group_by(data, interval)
adp <- summarise(preadp, average_steps = mean(steps, na.rm = TRUE))
plot(adp$interval, adp$average_steps, type = "l", col = "blue",
     main = "Average Daily Activity Pattern", xlab = "Interval",
     ylab = "Average Steps", xaxt = "n")
axis(side = 1, at = seq(0, 2400, by = 100), las = 2)

## 2. Getting interval with maximum number of steps

adp[which.max(adp$average_steps),]$interval



## IMPUTING MISSING VALUES

## 1. Calculating total missing values (NA)

sum(!complete.cases(data))

## 2. Filling missing values with rounded mean of that 5-min interval

data$complete_steps <- ifelse(is.na(data$steps), 
                              round(adp$average_steps[match(data$interval,
                                                            adp$interval)],0),
                              data$steps)

## 3. Creating new data set with missing data filled in

all_data <- data.frame(Steps = data$complete_steps, Date = data$date,
                       Interval = data$interval)

head(all_data, n=10)

## 4.1 Making histogram

histcomp0 <- group_by(all_data, Date)
histcomp <- summarise(histcomp0, Total_Steps = sum(Steps))
hist(histcomp$Total_Steps, main = "Histogram of Steps per Day (Complete)", 
     xlab = "Number of Steps", ylab = "Frequency", col = "green")

## 4.2 Calculating mean and median

mean(histcomp$Total_Steps, na.rm = TRUE)
median(histcomp$Total_Steps, na.rm = TRUE)



## DIFFERENCES BETWEEN WEEKDAYS AND WEEKENDS

## 1. Creating a new factor variable with levels: weekday & weekend

Weekday <- weekdays(all_data$Date)
all_data_wk <- cbind(all_data, Weekday)
all_data_wk$Day_Type <- ifelse(all_data_wk$Weekday == "Saturday" | 
                                   all_data_wk$Weekday == "Sunday", "Weekend",
                               "Weekday")

## 2. Building panel plot 

prepanel <- group_by(all_data_wk, Interval, Day_Type)
panel <- summarise(prepanel, Average_Steps = mean(Steps, na.rm = TRUE))

library(ggplot2)
panelplot <- ggplot(panel, aes(x = Interval, y = Average_Steps, 
                               color = Day_Type)) + geom_line() + 
    facet_wrap(.~Day_Type, ncol = 1, nrow = 2) + 
    labs(x = "Interval", y = "Average Steps", title = "Average Steps by Type of Day")
    
