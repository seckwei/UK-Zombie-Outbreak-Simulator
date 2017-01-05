# UK Epidemic/Zombie Outbreak Simulator (HackSheffield March 2016)

##Inspiration

We wanted to create something interesting using all sorts of open data. This project appeals to us because it has funny elements.
What it does

Predict the spread of the virus/disease based on the location, commuting between district, employment rate, population & wage + give you morbid thoughts of the future.
How we built it

- Technologies: Node, MySQL
- Data: Office for National Statistics (ONS) data for 2011, London Datastore

##Challenges we ran into

- Too much data sets that do not exactly match
- Difficult to incorporate/combine data for wanted results. (e.g. getting Local Authorities' boundary coordinates)
- Severely lack of APIs which resulted us in downloading datasets and converting them into database tables.

##Accomplishments that we're proud of

- We went through 5 hours of thorough planning, weren't tempted to tap away on our keyboards until we were done planning.
- Although we did not manage to properly crunch the data we have, we still managed to get some sensible information.
- We went through hell digging for datasets in open data websites (e.g. ONS, Data.gov.uk, etc).

##What we learned

- MySQL does not have Common Table Expressions i.e. stick to the tech you know best
- Don't have to aim for perfection

##What's nice to have for UK Epidemic Simulator

- Including other types of data to predict the spread (e.g. topography, health status of location, etc)
- Feature to find a safe location to start a base
- Map routes to various desired resources
- Weather forecast
- Other survival features (e.g. (poisonous plants / berry identifier)
