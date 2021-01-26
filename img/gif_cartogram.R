library(sf)
library(magick)
library(cartogram)

x <- st_read("data/sen_slope.json")
weight <- "sen_slope"
value <- x[[weight]]
plot(x[weight])

mixmax_scale <- function(x){(x-min(x))/(max(x)-min(x))}
compare_map <- x[weight]
compare_map$sen_slope <- mixmax_scale(x$sen_slope)
compare_map$area <- mixmax_scale(st_area(x))
compare_map_antar <- compare_map[-7,]

areas <- lapply(1:20, function(x) {
  area_sf <- cartogram::cartogram_cont(compare_map_antar, "sen_slope", x)
  st_area(area_sf)
  }
)

areas_df <- data.frame(areas)
colnames(areas_df) <- sprintf("area_%02d", 1:20)
areas_df$sen_slope <- compare_map_antar$sen_slope

for (index in 1:20) {
  png(
    filename = sprintf("/home/csaybar/Documents/Github/cartogram/img/gif/img_%02d.png", index),
    width = 662*2,
    height = 463*2 
  )
  st_sf(areas_df[c(index, 21)], geometry = compare_map_antar$geometry) %>% plot(breaks = "jenks")
  dev.off()
}

img_cartogram <- list.files("/home/csaybar/Documents/Github/cartogram/img/gif/", full.names = TRUE)
img_cartogram_gif <- magick::image_read(img_cartogram) 

image_write_gif(
  image = img_cartogram_gif, 
  path = "/home/csaybar/Documents/Github/cartogram/img/cartogram.gif",
  delay = 1
)