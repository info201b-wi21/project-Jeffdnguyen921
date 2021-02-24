
SSDB_Raw_Data_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Raw_Data_Compiled.csv?token=ASLKMK4FWIIAM7YWLDYYV6DAH4CY2")

Unemployment_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/Unemployment.Compiled.csv?token=ASLKMK2CIMZKQEZ2I2AZ65DAH4KC2")

us_cities <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/uscities.csv?token=ASLKMK4UTUNAYL7DBRIZLG3AH4J3E")

features <- colnames(us_cities)

# joining county_fips in school_schooting database using a complete USA  
# location dataset so that SSDB and Unemployment both have county fips.

us_city_state_city <- us_cities %>%
  unite("location", city, state_id, sep = ", ") %>%
  select(location, county_fips)

SSDB_df_state_city <- SSDB_Raw_Data_df %>%
  unite("location", City, State, sep = ", ")

SSDB_df <- inner_join(SSDB_df_state_city, us_city_state_city, by = "location")

# rename so unemployment_df and SSDB both have 'county_fips' column

Unemployment_df <- Unemployment_df%>%
  rename(county_fips = fips_txt)

# Select columns that are necessary to do analysis 

Unemployment_df <- Unemployment_df%>%
select(county_fips, area_name, Unemployment_rate_2000, Unemployment_rate_2001, 
       Unemployment_rate_2002, Unemployment_rate_2003, Unemployment_rate_2004, 
       Unemployment_rate_2005, Unemployment_rate_2006, Unemployment_rate_2007, 
       Unemployment_rate_2008, Unemployment_rate_2009, Unemployment_rate_2010, 
       Unemployment_rate_2011, Unemployment_rate_2012, Unemployment_rate_2013, 
       Unemployment_rate_2014, Unemployment_rate_2015, Unemployment_rate_2016, 
       Unemployment_rate_2017, Unemployment_rate_2018, Unemployment_rate_2019)





