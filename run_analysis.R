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
names(activityLabelsData) <- c("ActivityId", "Activity")

print("  reading features data")
featuresData <- read.table( paste(dataLocation, "features.txt", sep="/") )
names(featuresData) <- c("FeatureId", "Feature")

print(" There are some remaining no that nice fields but they aren't interesting for the mean and stddev")

print("We need to extract only the measurements on the mean and standard deviation for each measurement.")   
print("  selecting relevant features only")
# set ignore.case to FALSE is you only want the perfectly matching lowercase -mean and -stddev
# the problem statement is unclear about that
selectedFeatureIndexes <- grep("-mean|-std", featuresData$Feature, ignore.case=TRUE)
# print(featuresData[selectedFeatureIndexes,])

print("We need to appropriately label the data set with descriptive variable names.")
print("   cleaning up the feature names")

print("     removing parenteses at the end")
featuresData$Feature <- gsub("(^.+)\\(\\)(.*)$", "\\1\\2", featuresData$Feature, perl=TRUE)

print(" putting in more explicit prefixes")
featuresData$Feature <- gsub("^f(.+)$", "Freq\\1", featuresData$Feature, perl=TRUE)
featuresData$Feature <- gsub("^t(.+)$", "Time\\1", featuresData$Feature, perl=TRUE)

print(" cleaning weird names like BodyBody")
featuresData$Feature <- gsub("^(.+)BodyBody(.+)$", "\\1Body\\2", featuresData$Feature, perl=TRUE)

print(" replacing dashes with camel case")

# This is still buggy

featuresData$Feature <- gsub("^(.+)\\-mean$", "\\1Mean", featuresData$Feature, perl=TRUE)
featuresData$Feature <- gsub("^(.+)\\-meanFreq$", "\\1MeanFreq", featuresData$Feature, perl=TRUE)
featuresData$Feature <- gsub("^(.+)\\-mean\\-(.+)$", "\\1Mean\\2", featuresData$Feature, perl=TRUE)
featuresData$Feature <- gsub("^(.+)\\-std\\-(.+)$", "\\1StdDev\\2", featuresData$Feature, perl=TRUE)
featuresData$Feature <- gsub("^(.+)\\-std$", "\\1StdDev", featuresData$Feature, perl=TRUE)
featuresData$Feature <- gsub("^(.+)\\-meanFreq\\-(.+)$", "\\1MeanFreq\\2", featuresData$Feature, perl=TRUE)

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
names(subjectTestData)<-c("Subject")
# we use ActivityId so that it will be easy to merge the activities
names(yTestData)<-c("ActivityId")
names(xTestData)<-featuresData$Feature
print("        we directly pick up the selected features, it is more efficient")
assembledTestData <- cbind(subjectTestData, yTestData, xTestData[,selectedFeatureIndexes])

print("     Putting train data together, and naming columns properly")
names(subjectTrainData)<-c("Subject")  
names(yTrainData)<-c("ActivityId")

names(xTrainData)<-featuresData$Feature
print("        we directly pick up the selected features, it is more efficient")
assembledTrainData <- cbind(subjectTrainData, yTrainData, xTrainData[,selectedFeatureIndexes])

print("Binding Test and Train data together")
assembledData <- rbind(assembledTestData, assembledTrainData)

print("We need to use descriptive activity names to name the activities in the data set")
print("Putting activities labels in, matching on the ActivityId")
mergedData <- merge(assembledData,activityLabelsData)

print("We need to remove the ActivityId column so that we do not have duplicate info with Activity") 

mergedData <- mergedData[ ,-which(names(mergedData) %in% c("ActivityId"))]

print("We need to create a second, independent tidy data set")
print(" with the average of each variable for each activity and each subject.")

tidyData <- 
  mergedData %>%
  group_by(Subject, Activity) %>%
  summarise_each(funs(mean))

print("Writing the data out")
write.table(tidyData, "tidyData.txt", row.name=FALSE)
#read things back to be sure it works
#data <- read.table(file_path, header = TRUE) #if they used some other way of saving the file than a default write.table, this step will be different
#View(data)