setwd("D:\\MS Data Analytics\\Sem 2\\PDA\\Project\\PDA-Project\\Yelp")
library(stringr)        #This package is used for string manipulation functions
library(dplyr)          #This package is used for data manipulation tasks
#################################### yelp_business #############################
data_business = read.csv("yelp_business.csv", stringsAsFactors = FALSE, na.strings=c("","NA"))

#remove double quotes from string
data_business$name = noquote(data_business$name)
data_business$name = gsub('"', '', data_business$name)
data_business$address = noquote(data_business$address)
data_business$address = gsub('"', '', data_business$address)

#replace empty address with NA
data_business$address[data_business$address==""] = NA
#remove comma
data_business$address = gsub(',', '', data_business$address)

#check NA values
sapply(data_business, function(x) sum(is.na(x)))

#remove column as there many NA rows and its was not required also
data_business$neighborhood  = NULL

#removed columns that are not required
data_business$postal_code  = NULL

#remove rows with NA values ... very few of them
data_business = na.omit(data_business)

dim(data_business)
str(data_business)
names(data_business)

#created clean csv file
write.csv(data_business, "business.csv", row.names = FALSE)
############################ yelp_review ##################################
library(lubridate) # to get year from date

data_review = read.csv("yelp_review.csv", stringsAsFactors = FALSE, na.strings=c("","NA"))
dim(data_review)
str(data_review)
names(data_review)
head(data_review)

#convert character to date
data_review$date = as.Date(data_review$date)
#Get year form date
data_review$year <- year(data_review$date)

#check NA values
sapply(data_review, function(x) sum(is.na(x)))
#No rows with NA

#Too much data in this file so we filter it 
#select only Restaurant business
restaurants <- data_business[grepl('Restaurant',data_business$categories),]
data_review = data_review[data_review$business_id %in% restaurants$business_id, ]
#Select reviews of 2016 only
data_review = data_review[data_review$year == 2016, ]

#removing special characters and double quotes and newline
data_review$text = str_replace_all(data_review$text, "[[:punct:]]", " ")
data_review$text = str_replace_all(data_review$text, "\\n", "    ")
data_review$text = noquote(data_review$text)
data_review$text = gsub('"', '', data_review$text)

head(data_review$text)
dim(data_review)
data_review$year=NULL

data_review$business_name <- data_business$name[match(data_review$business_id, data_business$business_id)]
str(data_review)

write.csv(data_review, "review.csv", row.names = FALSE)

#################################### yelp_user #############################
data_user = read.csv("yelp_user.csv", stringsAsFactors = FALSE, na.strings=c("","NA"))
dim(data_user)
str(data_user)
names(data_user)

#check NA values
sapply(data_user, function(x) sum(is.na(x)))

#removing rows with NA values
data_user = na.omit(data_user)

data_user$yelping_since = as.Date(data_user$yelping_since)
data_user$year <- year(data_user$yelping_since)
#Select user reviews of 2016 only
data_user = data_user[data_user$year == 2016, ]

data_user$year = NULL

#removing special characters and double quotes
data_user$elite = str_replace_all(data_user$elite, "[[:punct:]]", " ")
data_user$elite = noquote(data_user$elite)
data_user$elite = gsub('"', '', data_user$elite)

#removing special characters and double quotes
data_user$name = str_replace_all(data_user$name, "[[:punct:]]", " ")
data_user$name = noquote(data_user$name)
data_user$name = gsub('"', '', data_user$name)


write.csv(data_user, "user.csv", row.names = FALSE)
#################################### yelp_tip #############################
library(lubridate) # to get year from date

data_tip = read.csv("yelp_tip.csv", stringsAsFactors = FALSE, na.strings=c("","NA"))
dim(data_tip)
str(data_tip)
names(data_tip)
head(data_tip)

#convert character to date
data_tip$date = as.Date(data_tip$date)
#Get year form date
data_tip$year <- year(data_tip$date)

#check NA values
sapply(data_tip, function(x) sum(is.na(x)))
#No rows with NA

#Select user tips of 2016 only
data_tip = data_tip[data_tip$year == 2016, ]

#remove rows with NA values ... very two rows
data_business = na.omit(data_business)

#removing special characters and double quotes and newline
data_tip$text = str_replace_all(data_tip$text, "[[:punct:]]", " ")
data_tip$text = str_replace_all(data_tip$text, "\\n", "    ")
data_tip$text = noquote(data_tip$text)
data_tip$text = gsub('"', '', data_tip$text)

head(data_tip$text)
dim(data_tip)

#removing year column
data_tip$year=NULL

#adding a new column business name by joining tow df based on bussiness_id
data_tip$business_name <- data_business$name[match(data_tip$business_id, data_business$business_id)]
str(data_tip)

write.csv(data_tip, "tip.csv", row.names = FALSE)