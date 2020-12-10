# Macroeconomic History data files

9 December 2020

The `DATA` folder contains both the source data files required for the macroeconomic history project  and various transient outputs. It has three subfolders:

- `SOURCE`
- `TESTS`
- `VALIDATIONS`
- `Exports`

Changes are not tracked in GitHub because the files are too large. They are (hopefully) tracked on the local machine, but I've not had the occasion to verify this.

The `EXPORTS` subfolder contains the main outputs from the project, organised into the projects of the Data Laboratory. It is the best place to find the results of the project

Source files for uploading into the database are stored in the `SOURCE` subfolder. Until 10 October - this may change - they were .csv files because this is more general and caused fewer 'special cases' when it comes to the uploading (ETL) process.

Originals are stored in `SOURCE\ORIGINALS` and will in general contain more data than in the .csv files, because the dataset is a limited selection. There is no special reason for the limitation except to avoid creating a 'thicket' of indicators that make the dataset less user-friendly. In a future version the intention is to deal with this either by the use of a more sophisticated Indicator dimension, or by means of partitions.

`ORIGINALS` contains, as of October 2020, two subfolders. `Archive` contains data from the early stages of the project, which mostly stop in 2017. `NEW IN 2020` contains data to be used in the October 2020 update, in progress at the time of this document

The original files may also contain useful metadata which is not used in the dataset.

`DOCUMENTATION` includes both the accompanying explanations that are supplied by the providers and notes on how it is presented and uploaded

`TESTS` contains workbooks and other relevant material used to verify that sources have been correctly uploaded. New tests are created as the project is revised. `TESTS` are transient and have no special significance for users, but I try to archive them because github does not track large file changes. Hopefully this system will eventually allow each revision to be checked if the need arises. For this reason, I try to include the date of creation in the name.

`VALIDATIONS` contains two types of material: that to check the validity of the source data itself, for example, the consistency of capital stock data; and validations of the calculations, especially since the creation of an add-in to calculate Theil T, Gini and weighted quartiles.





