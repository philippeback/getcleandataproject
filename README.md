Introduction
============
The code book contains a general description of the raw data set, the processing done and the resulting tidy data set. 
This README focusses on how the analysis script works and zooms in on some of the processing details.

Goal
----
The goal is to prepare tidy data that can be used for later analysis.

Deliverables
------------

There is one R script called run_analysis.R that does the following:
 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Please note that the list above does not mandates a particular order in the steps, only that it _does the following_.
This is mentioned because following the order blindly leads to lots of complications in column selection where one would have to shift column index ids and so on, making it a source of hard to spot problems.

There is this README.md which focuses on the details of how all works together.

There is a Codebook.md file that explains the resulting data set.

Experimental design
===================

The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

(http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) 

Original source of the data
---------------------------

Here are the data for the project: 

(https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 

Raw data files
--------------
The original files are provided in a zip file, which when unzipped has the following layout:

```
.
├── activity_labels.txt
├── features_info.txt
├── features.txt
├── README.txt
├── test
│   ├── Inertial Signals
│   │   ├── body_acc_x_test.txt
│   │   ├── body_acc_y_test.txt
│   │   ├── body_acc_z_test.txt
│   │   ├── body_gyro_x_test.txt
│   │   ├── body_gyro_y_test.txt
│   │   ├── body_gyro_z_test.txt
│   │   ├── total_acc_x_test.txt
│   │   ├── total_acc_y_test.txt
│   │   └── total_acc_z_test.txt
│   ├── subject_test.txt
│   ├── X_test.txt
│   └── y_test.txt
└── train
    ├── Inertial Signals
    │   ├── body_acc_x_train.txt
    │   ├── body_acc_y_train.txt
    │   ├── body_acc_z_train.txt
    │   ├── body_gyro_x_train.txt
    │   ├── body_gyro_y_train.txt
    │   ├── body_gyro_z_train.txt
    │   ├── total_acc_x_train.txt
    │   ├── total_acc_y_train.txt
    │   └── total_acc_z_train.txt
    ├── subject_train.txt
    ├── X_train.txt
    └── y_train.txt

```

README.txt contains the description of the various files and features_info.txt, the description of the fields.

Description of the run_analysis script
======================================

The script achieves the requirements through a set of stages detailed below.

Required R packages
-------------------
The script makes use of the dplyr and tidyr packages.

Make sure these are available.

One can install them with:

```
install.packages(c("dplyr", "tidyr"))
```

The key concerns to be taken care of are:

Raw data file structure loading
------------------------------------

The original data has several separated files that need to be put back together meaningfully.

* activity names are provided in a separate file (activity_labels.txt)
* column titles are provided in a separate file (features.txt)
* actities themselves are provided in a separate file (y_test.txt, y_train.txt)
* train and test data are segregated an need to be put together (there are in test/ and train/ folders)
  * suject data is a separate file (subject_test.txt, subject_train.txt)
  * actual measurements are in a separate file (X_test.txt, subject_train.txt)
* data which is not revelant to our objective (Inertial Signals subfolders inside test and train data). These can be disregarded. 



The useful datasets are loaded in data tables, each named after the file.


Original data fields names processing
-------------------------------------

The original data fields names are somewhat unsuited for easy use in R, due to:

* dashes in the names (one or more)
* names ending with parentheses (opening and closing)
* names with somewhat wrong names (like _BodyBody_ in the name, which should be _Body_)
* f and t prefixes on the names are not that readable and are replaced by time and freq to denote time and frequential aspects more clearly.
* duplicate names because they forgot to add the x, y, z (these shouldn't be in the tidy data, so they aren't processed)

So, the script cleans the names. This is performed with a couple of ```gsub``` and regex expressions on the ```FeatureData$Features``` data table.

As an example of the raw data field names see below:

```
35 tBodyAcc-arCoeff()-Z,2
36 tBodyAcc-arCoeff()-Z,3
37 tBodyAcc-arCoeff()-Z,4
38 tBodyAcc-correlation()-X,Y
39 tBodyAcc-correlation()-X,Z
40 tBodyAcc-correlation()-Y,Z
41 tGravityAcc-mean()-X
42 tGravityAcc-mean()-Y
43 tGravityAcc-mean()-Z
44 tGravityAcc-std()-X
45 tGravityAcc-std()-Y
46 tGravityAcc-std()-Z
47 tGravityAcc-mad()-X
...
373 fBodyAccJerk-meanFreq()-X
...
516 fBodyBodyAccJerkMag-mean()
517 fBodyBodyAccJerkMag-std()
518 fBodyBodyAccJerkMag-mad()
...
555 angle(tBodyAccMean,gravity)
556 angle(tBodyAccJerkMean),gravityMean)
```

Filtering of unneeded data fields
---------------------------------

As only mean and std fields are needed, we need to keep only the fields that are related to that. 

To do it, it is best to select the features we need from the original names, before processing the field names and build a vector of indexes that have be used.
That way, we can easily alter the selection if the selection rule is changed.

The rules on the selection is based on keeping the mean and stddev fields but this is open to intepretation.

What we do here is that we keep the indexes of the matching elements:

``` 

selectedFeatureIndexes <- grep("-mean|-std", featuresData$Feature, ignore.case=TRUE) 

```

The selectedFeatureIndexes vector is very useful for the subsetting X_train and X_test data.


Subbsetting X_train and X_test data
-----------------------------------

When assembling the data set, the script gets rid of the undeeded columns.

It does so by subsetting X_train and X_test with selectedFeatureIndexes.


Assembling the data set
-----------------------

To assemble the data set, the content of the files is assembled as follows:

```

Subject		selected features titles		ActivityId	
--------------+-------------------------------------+--------------
subject_test	subsetted columns of X_test		y_train

subject_train	subsetted columns of X_train		y_train

```

The key assembly part is:

```
assembledTestData <- cbind(subjectTestData, yTestData, xTestData[,selectedFeatureIndexes])
assembledTrainData <- cbind(subjectTrainData, yTrainData, xTrainData[,selectedFeatureIndexes])
```

Also have a look on how the columns get their title with a couple of names().
Naming the data table columns makes it easy to have properly titled data tables for manipulation and merging.

At this point, the script will have to put in the correct activity names in place and not numerical ActivityId's.

Merging activity names
----------------------

The data set is augmented with the activity names.

The activity ids and names are provided in the activity_labels.txt.

```
activityLabelsData <- read.table( paste(dataLocation, "activity_labels.txt", sep="/") )
```

To ease the merging of names, the naming of the fields aligns the ids in the activityLabelsData with the ones in the assembled data set.

```
names(activityLabelsData) <- c("ActivityId", "Activity")
```

That way, the names can be merged easily on the ActivityId. The is no need to provide .by clauses.

```
mergedData <- merge(assembledData,activityLabelsData)
```

Removal of unnecessary ActivityId column
----------------------------------------

The ActivityId column is not needed anymore as it was solely useful for joining. As it represents the same data as Activity, we can get rid of it.

```
mergedData <- mergedData[ ,-which(names(mergedData) %in% c("ActivityId"))]
```

At this point, the data set is assembled in ```mergedData``` and it is possible to proceed to the last step.

Creation of a second, independent tidy data set
-----------------------------------------------

This second data set, with the average of each variable for each activity and each subject is produced.

To do so, we use the tidyr facilities on mergedData, with grouping and summarization.

As there are quite a number of columns, it would be quite long and inflexible to add them all by hand.
As all the columns that are not grouped by are what we want the mean out of, we can use the summarize_each function, coupled with the funs function, which applies the mean to all columns at once.

This way, we can change the selected columns at the beginning of the script and have all the rest fall in place nicely.

```
tidyData <- 
  mergedData %>%
  group_by(Subject, Activity) %>%
  summarise_each(funs(mean))
```

Now, the names are still having some duplication and tidyness can be improved further to meets the principles of tidy data as (http://vita.had.co.nz/papers/tidy-data.pdf).

But the principles says: Each variable you measure should be in one column, Each different observation of that variable should be in a different row.

The tidy data set produced here meets the requirements as each column contains a different observation of a specific variable.

Writing the tidy data set out
-----------------------------

The tidy data is written out to disk following the requirements. It is named ```tidyData.txt```

```
write.table(tidyData, "tidyData.txt", row.name=FALSE)
```

Following up what's happening in the script
===========================================

When one runs the script, progress is printed out with print statements, in order to understand what's going on.

Here is an example:

```
> source('~/workspace/DataScience/GettingData/CourseProject/R/run_analysis.R')

Reading data
  reading activity labels
  reading features data
 There are some remaining no that nice fields but they aren't interesting for the mean and stddev
We need to extract only the measurements on the mean and standard deviation for each measurement.
  selecting relevant features only
We need to appropriately label the data set with descriptive variable names.
   cleaning up the feature names
     removing parenteses at the end
 putting in more explicit prefixes
 cleaning weird names like BodyBody
 replacing dashes with camel case
Reading test data
  reading subject test data
  reading xTest data
  reading yTest data
Reading train data
  reading subject train data
  reading xTrain data
  reading yTrain data
We need to merge the training and the test sets to create one data set.
 Merging the data sets
  putting subjectTestData and subjectTrainData together
     Putting test data together, and naming columns properly
        we directly pick up the selected features, it is more efficient
     Putting train data together, and naming columns properly
        we directly pick up the selected features, it is more efficient
Binding Test and Train data together
We need to use descriptive activity names to name the activities in the data set
Putting activities labels in, matching on the ActivityId
We need to remove the ActivityId column so that we do not have duplicate info with Activity
We need to create a second, independent tidy data set
 with the average of each variable for each activity and each subject.
Writing the data out
```




