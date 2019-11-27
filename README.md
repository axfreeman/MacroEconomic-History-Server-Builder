# Macroeconomic History Data Project
[Alan Freeman](https://geopoliticaleconomy.academia.edu/AlanFreeman) 27 November 2019.

>Contact address for the project: **alan.freeman@umanitoba.ca**

## What is the project?

This purpose of this project is to create a user-friendly database of world and country economic, political and social indicators, drawn from a variety of sources, and create a community of users who will add to the data, and work to improve it.

This implements the objectives of the GERG ([Geopolitical Economy Research Group](http://geopoliticaleconomy.ca)) Data group.

The project, originally started in April 2019, has been split into two for user convenience. These are available as two distinct Github repositories:

* The server repository (which contains this file)

* The user repository (which is at [TBA 27/11/2019])

This repository is for folks who want to create a complete clone of the whole project including an SQL server that will supply the data in real time to a connected application like Excel or PowerBI (or any other application that can connect to an SQL server).

Most users won't need this, which is why I separated this code from the user part.

# What are the system requirements (what can you run this code on?)

This code assumes you have installed, probably on a Windows 10 system, the following:

* Microsoft SQL server 2017 or later

* Visual Studio 2019 or later with the SSIS (Integration Services) add-on

It also assumes you know how to use the above software.

## How do you run it?

From Visual studio, open the 'Macrohistory' solution

Modify the parameters so they point at your SQL server and at the directory containing this clone.

In you SQL server, create two databased called 'OLTP' and 'ROLAP'. The data is initially loaded into the OLTP database by two ETL packages called 'Setup OLTP Dimension Tables' and 'Import OLTP data from External sources' (which should be run in this order). Once that's done, your OLTP database contains a standardised version of the data. This is then copied to the ROLAP database in such a way that all the Foreign Keys work properly, which streamlines the data by compacting it and organising it in a star model. As a result, the entire database takes up less than 100MB of space when imported into Excel PowerPivot or PowerBI.

You'll find that you need to run the first task in each of these packages once, to create the initial tables. While you are doing that, the other tasks will be flagged as having errors, because they expect these tables to exist. If you then close the package and re-open it, the error flags should disappear. There's probably a more sophisticated way of doing this but it doesn't take up much time, so that's for a future tweak. Or maybe you can do it and push your improvements back up to the repository.

There is one bug: the UN Population connector has not been parameterised so it will fail, expecting to find the relevant CSV input file in the wrong place. You can either parameterise it properly or edit manually with the new location of this CSV file. Again, if you fix this and push it up to the repository, that would be a nice gesture.

That's it, basically. Let me know if you run into problems.



Oh yes, the name of the folder with the code in it. It got called GERGLE 4.0 at an early stage and since then, the name became redundant. Don't let it worry you.



