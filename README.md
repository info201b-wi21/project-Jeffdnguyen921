# INFO 201 Course Project

This repo will contain the code and data for a course project
for the _Technical Foundations of Informatics_ course at the UW iSchool.

# Project Domain: School Shootings and Income #
Jeffrey Nguyen,
Luka Marceta,
Quang Nguyen,
Liza Moore

--------
## Section 1 ##
### Problem Domain ###
Our proposal seeks to investigate the relationship between income and school shootings. Our group has defined a school shooting as “any time a gun goes off in an academic setting”. The database we have selected is the only comprehensive list of all school shootings in America. The definition of a school shooting is abstract and the Center for Homeland Defense and Security acknowledges the limitations of their list, disclosing the ambiguity of a school shooting requires a compassionate mindset to take in myriad variables. Casting a “wide net” to catch as many incidents as possible. The phenomena recorded in each incident are diverse, including “Bullying,” “Illegal Activity,” “Indiscriminate/Targeted”. Moreover, each incident has a reliability score that is found by assessing the credibility of the source

The other data set we gathered as a proxy to the wealth of each school is a comprehensive list of the proportion of students who live below the poverty line in each public school district. The data set is from the federal census bureau. A 2017 mapping survey was carried out and is consistent with the population and income estimates from the American Community Survey, a survey that gathers information on ancestry, educational attainment, and income.

Although our group’s intention is to merely summarize and consolidate wealth and school shooting incidents, we are interested in whether there are any differences in motivation, weapon, or legal ramifications.

**Income inequality and mass shootings in the United States
https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-019-7490-x**

**Income Inequality, Household Income, and Mass Shooting in the United States
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6199901/**

------------
## Section 2 ##
### Data Sets ###
#### [K-12 School Shooting comprehensive list](https://www.chds.us/ssdb/data-map/) ####
- How data was collected
  1. Preliminary research and merging multiple data sources
    - From "US Secret Service, FBI, and Department of Education; media or advocacy groups including The Washington Post, CNN, Gun Violence Archive, Everytown for Gun Safety, Education Weekly, and Mother Jones; and websites or blogs including Columbines Angels, Wikipedia, schoolshootingdatabase.com, and schoolshootingtracker.com."
  2. Detailed research
    - Assessment of situation and detailed information from teachers to students shot and going into depth on the exact circumstances and motivations that might have prompted the event.
  3. Score reliability of data
    - Relaibility on information ranging from (1-5) weakest to strongest:
      1. Blogs
      2. Single newspaper articles or online news
      3. Multiple News Sources
      4. Hundreds of News Sources or Statement/Interview from law enforcement
      5. Court Records or Police Reports
- Analysis Questions Answered
  - Using number of children living in poverty would be a perfect proxy variable for median income. Most school districts are funded via property tax which is linked to household income. This helps answer all the questions.

#### [% of Students Living in Proverty by School District in 2017-2018 School Year](https://www.census.gov/data/datasets/2017/demo/saipe/2017-school-districts.html) ####
- How data was collected
  - Some data are collected from respondents directly, through survey's given to families in their respective districts.
  - Additional data is from state, federal, and local governments
- Analysis Questioned answered
  - Helps address the class issue in poverty and provides information that helps answer all the low income class questions.

#### [School Shooting Data from Washington Post](https://github.com/washingtonpost/data-school-shootings/blob/master/school-shootings-data.csv) ####
- How data was collected
  - Reporters identified every act of gunfire at a primary or secondary school during school hours since Columbine High School on April 20, 1999.
    - Using NEXIS, news articles, open-source databases, law enforcement reports, information from school websites, and calls to schools and police departments.
    - Cases were only counted for those that happened immediately before, during, or just after classes
  - Data on enrollment and demographics were compiled by the US Department of Education.
- Analysis Questioned answered
  - Similar to the other school shooting dataset, it helps answer all the questions given that involve school shooting data.

#### [Median household income and Unemployment for US, States, and Counties](https://www.ers.usda.gov/data-products/county-level-data-sets/download-data/) ####
- How data was collected
  - Data was collected by the US Department of Agricultures Economic Research Service.
    - Data was collected using Department of Labor and other US Department data and putting all the data gathered by the agencies in a nuanced list for use.
- Analysis Questioned answered
  - This helps give a holistic view of classes by area and helps answer all the class question regardless of higher or lower class.

--------
## Section 3 ##
### Analysis Questions ###
*Liza:*
  - Do high income areas have higher or lower rates of shootings?
    - This question brings forth the differences in rates relative to the background of students in a given area.
  - Of high income areas, are there more shootings at elementary, middle or high schools?
    - This question helps look into where the concentration of shootings are and where our focus might be in the future.

*Luka:*
  - Are automatic weapons more prevalent in shootings in higher income areas?
    - This question help understanding the widespread automatic weapons issue relative to income.
  - Is law enforcement more likely to apprehend the shooter in higher income areas?
    - This question helps answer the impact that law enforcement might have on higher income areas that have more funding for police departments.

*Quang:*
  - Does income dictate the result of a school shooting? (casualties / shooter livelihood)
    - This question helps understanding of inequalities that different classes face when experiencing the same situation.
  - Does income affect the number of casualties in a mass shooting?
    - This question also addresses how an individual class might dictate the outcome of a school shooting.

*Jeffrey:*
  - How does the deaths during a shootings in low income areas differ to the rate of shootings in high income areas?
    - This is a comparison question that address deaths as a form to look into how class involves the survival of students.
  - How does mass shootings in low income areas differ in comparison to high income areas?
    - This question looks at mass shootings in an attempt to understand the prevalence between classes.
