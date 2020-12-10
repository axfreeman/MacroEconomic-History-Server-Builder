# Macroeconomic History Data Preparation Notes

10 October 2020

These are rough notes on the various data sources and how to prepare them for upload

They relate mainly to new data uploaded in October 2020 and after

### WDI

This is the priority because it is the most current and begins with early dates

The current dataset is pivoted with all series (447,000 rows) 

There is a ‘maximum limit’ on the number of cells that can be downloaded. 

The selection pane is usable and a logged-in user can save it. So data is downloaded in recognizable chunks. 

- Chunk 1: The national accounts data, aggregates only (without GDP per capita and GNI per capita)
- Chunk 2: Balance of Payments (all data)
- Chunk 3: Demographics and Income Distribution (selection)

Meta: ask for scaling to be applied. Ask for NA to be .., because it makes the prep easier

#### Prep

1. Amalgamate the chunks using cut and paste to create WDI2020.xlsx
2. Create a cleaned sheet with both chunks in it
3. Change the first four column names to be Country Name, Country Code, Indicator Name, Indicator Code
4. Remove the scale code
5. Remove the junk from the year headings
6. Export as CSV

