if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

#Unzip dataset to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#1. Merge the training and the test sets to create one data set.

#read training tables
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#read test tables:
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#feature vector:
features <- read.table('./data/UCI HAR Dataset/features.txt')

#activity labels:
activityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

#column names
colnames(x_train) <- features[,2] 
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"
colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"
colnames(activityLabels) <- c('activityId','activityType')

#merge data
merge_train <- cbind(y_train, subject_train, x_train)
merge_test <- cbind(y_test, subject_test, x_test)
OneDataset <- rbind(merge_train, merge_test)

#Extract only the measurements on the mean and standard deviation for each measurement.
colNames <- colnames(OneDataset)

mean_and_std <- (grepl("activityId" , colNames) | 
                   grepl("subjectId" , colNames) | 
                   grepl("mean.." , colNames) | 
                   grepl("std.." , colNames) 
)

subsetData <- OneDataset[ , mean_and_std == TRUE]

ActivityNamesDataset <- merge(subsetData, activityLabels, by='activityId', all.x=TRUE)

#Create a second, independent tidy data set with the average of each variable for each activity and each subject.

tidySet <- aggregate(. ~subjectId + activityId, ActivityNamesDataset, mean)
tidySet <- tidySet[order(tidySet$subjectId, tidySet$activityId),]

write.table(tidySet, "tidySet.txt", row.name=FALSE)