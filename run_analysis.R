library(dplyr)

# Download the data
if(!file.exists("./data/dataset.zip")){
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(url, destfile = "./data/dataset.zip")
}

unzip(zipfile = "./data/dataset.zip", exdir = "./data")

# Read training data
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
sub_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# Read test data
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
sub_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Read variable names and activity labels
var_names <- read.table("./data/UCI HAR Dataset/features.txt")
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

# Assign column names
colnames(x_train) <- var_names[,2]
colnames(x_test) <- var_names[,2]
colnames(y_train) <- "activityId"
colnames(y_test) <- "activityId"
colnames(sub_train) <- "subjectId"
colnames(sub_test) <- "subjectId"
colnames(activity_labels) <- c("activityId", "activityType")

# Merge the data sets
merge_train <- cbind(y_train, sub_train, x_train)
merge_test <- cbind(y_test, sub_test, x_test)
data_set <- rbind(merge_train, merge_test)

#Extract only the measurments on the mean and standard deviation
column_names <- colnames(data_set)
mean_sd <- (grepl("activityId", column_names) |
                grepl("subjectId", column_names) |
                    grepl("mean..", column_names) |
                    grepl("std..", column_names))
subset_mean_sd <- data_set[, mean_sd == TRUE]

# Use descriptive activity names, appropriately label the data set variables
data_set_named <- merge(subset_mean_sd, activity_labels, by="activityId", all.x=TRUE)

# Create a second, independent tidy data set with the average of each variable for each activity and each subject
tidy_set <- aggregate(. ~subjectId + activityId, data_set_named, mean)
tidy_set <- tidy_set[order(tidy_set$subjectId, tidy_set$activityId),]

write.table(tidy_set, "./data/tidyset.txt", row.name=FALSE)
