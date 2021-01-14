library(rgee)
library(tmap)
library(sf)

# 1. Initialize
ee_Initialize()

# 2. Get a geometry from over the world
data("World")
World <- World[!(World$name == "Antarctica"),]
world_by_countries <- lapply(seq_along(World$geometry), function(x) World$geometry[x])
ee_world_by_countries <- lapply(world_by_countries,
                                function(x) st_transform(x, 4326) %>% st_centroid() %>%  sf_as_ee())

# 3. Create a query to get NEX-GDDP data
climate_model_data <- ee$ImageCollection("NASA/NEX-GDDP") %>%
  ee$ImageCollection$select("tasmax") %>%
  ee$ImageCollection$filterMetadata("model", "equals", "ACCESS1-0") %>%
  ee$ImageCollection$filterMetadata("scenario", "equals", "rcp85")

# 4. From daily to annual step (2006-2099)
distinctYear <- climate_model_data %>% ee$ImageCollection$distinct("year")
filter <- ee$Filter$equals(leftField = 'year', rightField = 'year')
join <- ee$Join$saveAll('sameYear')
joinCol <- ee$ImageCollection(
  join$apply(distinctYear, climate_model_data, filter)
)
annualMonthlyMeanCol <- joinCol$map(function(img) {
  yearCol <- ee$ImageCollection$fromImages(
    img$get('sameYear')
  )
  yearCol$mean()$set('Year', img$get('year'));
})

# 5. Download annualy data for each country
for (index in 1:176) {
  year_tp_data <- ee_extract(
    x = annualMonthlyMeanCol,
    y = ee_world_by_countries[[index]],
    scale = 2500
  )
  write.csv(year_tp_data, sprintf("%s.csv", as.character(World$name[index])))
}