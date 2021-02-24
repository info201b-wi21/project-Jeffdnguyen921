
library(readr)
SSDB_Raw_Data_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/SSDB_Raw_Data.csv?token=ASMBDXHD5IM7WB37PKUT2FTAH24JC")
View(SSDB_Raw_Data_df)
Unemployment_df <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/Unemployment.csv?token=ASMBDXGZ36J2NRSGNKLLWDLAH24MU")
View(Unemployment_df) 
us_cities <- read_csv("https://raw.githubusercontent.com/info201b-wi21/project-Jeffdnguyen921/main/data/uscities.csv?token=ASMBDXGJXITVXINJCIPTACLAH7BCI")

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

Unemployment_df <- rename(Unemployment_df, county_fips = fips_txt)

