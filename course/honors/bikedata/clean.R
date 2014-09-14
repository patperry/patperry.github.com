#!/usr/bin/Rscript --vanilla

data <- read.csv("raw/bikedata.csv")

data$vehicle <- factor(data$vehicle,
                       levels = 1:7,
                       labels = c("Car", "LGV", "SUV", "Bus", "HGV",
                                  "Taxi", "PTW"))

data$colour <- factor(data$colour,
                      levels = c(1:6, 9),
                      labels = c("Blue", "Red", "Grey", "White", "Black",
                                "Green", "Other"),
                      exclude = 99)

data$street <- factor(data$street,
                      levels = 1:6,
                      labels = c("OneWay1", "OneWay2", "Urban",
                                 "Residential", "Main", "Rural"))

data$datetime <- as.POSIXct(strptime(paste("2006-", data$date, " ",
                                           data$Time, sep=""),
                                     format = "%Y-%d-%b %H:%M", tz = "GMT"))
data$Time <- NULL
data$hour <- NULL
data$date <- NULL

data$helmet <- factor(data$helmet, levels = 0:1, labels = c("N", "Y"))

data$bikelane <- factor(data$Bikelane, levels = 0:1, labels = c("N", "Y"))
data$Bikelane <- NULL

data$city <- factor(data$City,
                    levels = 1:3,
                    labels = c("Salisbury", "Bristol", "Portsmouth"))
data$City <- NULL

write.csv(data, "bikedata.csv", row.names=FALSE)
