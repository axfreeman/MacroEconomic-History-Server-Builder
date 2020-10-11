# Macroeconomic History source data files

10 October 2020

The `DATA` folder contains both the source data files required for the macroeconomic history project  and various transient outputs. It has three subfolders:

- `SOURCE`
- `TESTS`
- `VALIDATIONS`

The `EXPORTS` subfolder of the root folder contains the main outputs from the project, organised into the projects of the Data Laboratory. The `EXPORTS` subfolder is the best place to find the results of the project.

Changes are not tracked in GitHub because the files are too large.

Source files for uploading into the database are stored in the `SOURCE` subfolder. Until 10 October - this may change - they were .csv files because this is more general and caused fewer 'special cases' when it comes to the uploading (ETL) process.

Originals are stored in `SOURCE\ORIGINALS` and will in general contain more data than in the .csv files, because the dataset is a limited selection. There is no special reason for the limitation except to avoid creating a 'thicket' of indicators that make the dataset less user-friendly. In a future version the intention is to deal with this either by the use of a more sophisticated Indicator dimension, or by means of partitions.

`ORIGINALS` contains, as of October 2020, two subfolders. `Archive` contains data from the early stages of the project, which mostly stop in 2017. `NEW IN 2020` contains data to be used in the October 2020 update, in progress at the time of this document

The original files may also contain useful metadata which is not used in the dataset.

Documentation (for example, the accompanying explanations that are supplied by the providers) is NOT located in this folder. It goes in the `DOCUMENTATION` folder.

`TESTS` contains workbooks and other relevant material used to verify that sources have been correctly uploaded. New tests are created as the project is revised. `TESTS` are transient and have no special significance for users, but are archived so that the outcome of each revision can be checked if there is a need to review the history of the revisions. For this reason, the date of creation is generally included in the name.

`VALIDATIONS` contains material used to check the validity of the source data itself, for example, the consistency of capital stock data.





