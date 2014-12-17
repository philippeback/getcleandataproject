Introduction
============

The goal is to prepare a tidy data set that can be used for later analysis.

There is a run_analysis.R script that performs the following transformation:
 
* Merges the training and the test sets to create one data set.
* Extracts only the measurements on the mean and standard deviation for each measurement. 
* Uses descriptive activity names to name the activities in the data set
* Appropriately labels the data set with descriptive variable names. 
* From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

There is a Codebook.md file that describes the experiential design, the raw data set, the transformation process and the resulting tidy data set.

The transformation produces a tidyData.txt.
A premade copy can be loaded back in R using:

```
address <- "https://s3.amazonaws.com/coursera-uploads/user-91622e112d6633a9fa1fbdf4/973758/asst-3/fd00af60895a11e49546d1d292644e53.txt"
address <- sub("^https", "http", address)
data <- read.table(url(address), header = TRUE)
View(data)
```
