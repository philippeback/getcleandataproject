# You should create one R script called run_analysis.R that does the following. 
#
#    Merges the training and the test sets to create one data set.

# getting the sets

library(dplyr)
library(tidyr)

# I've downloaded the sets on my machine
# Here I've unzipped the getdata_projectfiles_UCI\ HAR\ Dataset.zip to get the various files

dataLocation <- "./data/UCI HAR Dataset"

print("Reading data")
print("  reading activity labels")
activityLabelsData <- read.table( paste(dataLocation, "activity_labels.txt", sep="/") )
names(activityLabelsData) <- c("activityId", "activity")

print("  reading features data")
featuresData <- read.table( paste(dataLocation, "features.txt", sep="/") )
names(featuresData) <- c("FeatureId", "feature")

print(" There are some remaining no that nice fields but they aren't interesting for the mean and stddev")

print("We need to extract only the measurements on the mean and standard deviation for each measurement.")   
print("  selecting relevant features only")
# set ignore.case to FALSE is you only want the perfectly matching lowercase -mean and -stddev
# the problem statement is unclear about that
selectedFeatureIndexes <- grep("-mean|-std", featuresData$feature, ignore.case=TRUE)
# print(featuresData[selectedFeatureIndexes,])

print("We need to appropriately label the data set with descriptive variable names.")
print("   cleaning up the feature names")

print("     removing parenteses at the end")
featuresData$feature <- gsub("(^.+)\\(\\)(.*)$", "\\1\\2", featuresData$feature, perl=TRUE)

print(" putting in more explicit prefixes")
featuresData$feature <- gsub("^f(.+)$", "freq\\1", featuresData$feature, perl=TRUE)
featuresData$feature <- gsub("^t(.+)$", "time\\1", featuresData$feature, perl=TRUE)

print(" cleaning weird names like BodyBody")
featuresData$feature <- gsub("^(.+)BodyBody(.+)$", "\\1Body\\2", featuresData$feature, perl=TRUE)

print(" replacing dashes with camel case")

# This is still buggy

featuresData$feature <- gsub("^(.+)\\-mean$", "\\1Mean", featuresData$feature, perl=TRUE)
featuresData$feature <- gsub("^(.+)\\-meanFreq$", "\\1MeanFreq", featuresData$feature, perl=TRUE)
featuresData$feature <- gsub("^(.+)\\-mean\\-(.+)$", "\\1Mean\\2", featuresData$feature, perl=TRUE)
featuresData$feature <- gsub("^(.+)\\-std\\-(.+)$", "\\1StdDev\\2", featuresData$feature, perl=TRUE)
featuresData$feature <- gsub("^(.+)\\-std$", "\\1StdDev", featuresData$feature, perl=TRUE)
featuresData$feature <- gsub("^(.+)\\-meanFreq\\-(.+)$", "\\1MeanFreq\\2", featuresData$feature, perl=TRUE)

print("Reading test data")

# in the test/ folder (and do not use Inertial Data)
print("  reading subject test data")
subjectTestData <- read.table( paste(dataLocation, "test", "subject_test.txt", sep="/") )  
print("  reading xTest data")
xTestData <- read.table( paste(dataLocation, "test", "X_test.txt", sep="/") )  
print("  reading yTest data")
yTestData <- read.table( paste(dataLocation, "test", "y_test.txt", sep="/") ) 

print("Reading train data")
print("  reading subject train data")
subjectTrainData <- read.table( paste(dataLocation, "train", "subject_train.txt", sep="/") )  
print("  reading xTrain data")
xTrainData <- read.table( paste(dataLocation, "train", "X_train.txt", sep="/") )  
print("  reading yTrain data")
yTrainData <- read.table( paste(dataLocation, "train", "y_train.txt", sep="/") ) 

print("We need to merge the training and the test sets to create one data set.")
print(" Merging the data sets")
print("  putting subjectTestData and subjectTrainData together")
print("     Putting test data together, and naming columns properly")
names(subjectTestData)<-c("subject")
# we use ActivityId so that it will be easy to merge the activities
names(yTestData)<-c("activityId")
names(xTestData)<-featuresData$feature
print("        we directly pick up the selected features, it is more efficient")
assembledTestData <- cbind(subjectTestData, yTestData, xTestData[,selectedFeatureIndexes])

print("     Putting train data together, and naming columns properly")
names(subjectTrainData)<-c("subject")  
names(yTrainData)<-c("activityId")

names(xTrainData)<-featuresData$feature
print("        we directly pick up the selected features, it is more efficient")
assembledTrainData <- cbind(subjectTrainData, yTrainData, xTrainData[,selectedFeatureIndexes])

print("Binding Test and Train data together")
assembledData <- rbind(assembledTestData, assembledTrainData)

print("We need to use descriptive activity names to name the activities in the data set")
print("Putting activities labels in, matching on the activityId")
mergedData <- merge(assembledData,activityLabelsData)

print("We need to remove the activityId column so that we do not have duplicate info with activity") 

mergedData <- mergedData[ ,-which(names(mergedData) %in% c("activityId"))]

print("We need to create a second, independent tidy data set")
print(" with the average of each variable for each activity and each subject.")

tidyData <- 
  mergedData %>%
  group_by(subject, activity) %>%
  summarise_each(funs(mean))

print("Writing the data out")
write.table(tidyData, "tidyData.txt", row.name=FALSE)

print("read things back to be sure it works")
data <- read.table('tidyData.txt', header = TRUE) #if they used some other way of saving the file than a default write.table, this step will be different
View(data)