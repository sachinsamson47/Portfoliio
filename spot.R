spotify <-  read.csv('C:\\Users\\Sachin\\Desktop\\spotify_songs.csv', na.strings = c(""," ",NA))
library(dplyr)
library(ggplot2)
install.packages("corrplot")
library(corrplot)
install.packages("plotly")
library(plotly)



list <-  colnames(spotify)
for (i in 1:length(list)){
  dat <-  spotify[list[i]]
  print(paste("Number of missing values in column",list[i]," is : " ,sum(is.na(dat))))
}

spotify <-  na.omit(spotify)


str(spotify)


spotify$track_id <- tolower(trimws(as.character(spotify$track_id)))
spotify$track_id <-  as.factor(spotify$track_id)

spotify$track_name <- tolower(trimws(as.character(spotify$track_name)))

spotify$track_artist <- tolower(trimws(as.character(spotify$track_artist)))

spotify$track_album_id <- tolower(trimws(as.character(spotify$track_album_id)))

spotify$track_album_name <- tolower(trimws(as.character(spotify$track_album_name)))

spotify$playlist_name <- tolower(trimws(as.character(spotify$playlist_name)))

spotify$playlist_id <- tolower(trimws(as.character(spotify$playlist_id)))

spotify$playlist_genre <- tolower(trimws(as.character(spotify$playlist_genre)))

spotify$playlist_subgenre <- tolower(trimws(as.character(spotify$playlist_subgenre)))

# Converting "Album Release Date" into year format

library(lubridate)
spotify$track_album_release_date_yr <- as.Date(spotify$track_album_release_date, format = "%m/%d/%Y")
spotify$track_album_release_date_yr <- format(as.Date(spotify$track_album_release_date_yr, "%y"),"%Y")
spotify$track_album_release_date_yr <- as.numeric(spotify$track_album_release_date_yr)


func_duplicate <-  function(x){if(sum(duplicated(x))>0)
{x<- x %>% distinct()}else{print("No duplicate observations found in the dataset")}
}

func_duplicate(spotify)


spotify$release_era<-ifelse( spotify$track_album_release_date_yr < 1970 , "1960's",
                             ifelse( spotify$track_album_release_date_yr < 1980, "1970's",
                                     ifelse( spotify$track_album_release_date_yr < 1990, "1980's",
                                             ifelse( spotify$track_album_release_date_yr < 2000,"1990's",
                                                     ifelse( spotify$track_album_release_date_yr < 2010 , "2000's","2010's")))))


spotify$popularity_class <- ifelse( spotify$track_popularity < 24 , "low",
                                    ifelse( spotify$track_popularity >= 24 &spotify$track_popularity< 62, "medium","high"))

spotify$popularity_class <-  as.factor(spotify$popularity_class)



spotify$podcast_music_cls <-  ifelse( spotify$speechiness >=0.66, "podcast", "music" )

knitr::kable( head(spotify,3), align = "lccrr", caption = "A sample data") 


summary(spotify$track_popularity)

par(mfrow=c(1,2))



dat <-  spotify %>% select (playlist_genre , track_popularity , track_id,track_album_id) %>% 
  group_by (playlist_genre) %>% summarise(avg_rating = mean(track_popularity),
                                          track_count = length(unique(track_id)),
                                          album_count = length(unique(track_album_id)))
n <-  length(unique(spotify$playlist_genre))

color_list <- hcl.colors(n, palette = "viridis", alpha = NULL, rev = FALSE, fixup = TRUE)

p1 <- ggplot(dat, aes(x=reorder(dat$playlist_genre,-dat$avg_rating), y=dat$avg_rating),label=dat$avg_rating) +
  
  geom_segment( aes(x=reorder(dat$playlist_genre,dat$avg_rating), xend=dat$playlist_genre, y=0,    
                    yend=dat$avg_rating),color=color_list[1:n]) +
  
  geom_point( size=5, color=color_list[1:n], fill=alpha(color_list[1:n], 0.3), alpha=0.7, shape=21, stroke=2) +
  
  theme_light() +ylab("Average Popularity Score") + xlab("Playlist Genre")+
  
  coord_flip() +
  
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.border = element_blank(),
    axis.ticks.y = element_blank()) 




n <-  length(unique(spotify$playlist_genre))

color_list <- hcl.colors(n, palette = "viridis", alpha = NULL, rev = FALSE, fixup = TRUE)

p2 <- ggplot(dat, aes(x=reorder(dat$playlist_genre,-dat$track_count), y=dat$track_count),label=dat$track_count) +
  geom_segment( aes(x=reorder(dat$playlist_genre,dat$track_count), xend=dat$playlist_genre, y=0,     
                    yend=dat$track_count),color=color_list[1:n]) +
  geom_point( size=5, color=color_list[1:n], fill=alpha(color_list[1:n], 0.3), alpha=0.7, shape=21, stroke=2) +
  theme_light() +ylab("Total number of tracks") + xlab("Playlist Genre")+
  coord_flip() +
  theme( 
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.border = element_blank(),
    axis.ticks.y = element_blank()) 

p1

p2

# Correlation matrix
nums <- unlist(lapply(spotify, is.numeric)) 
corrplot(cor(spotify[,c("danceability","valence","speechiness","track_popularity","duration_ms","instrumentalness")]), order = "hclust")


dat <-  spotify %>% select (podcast_music_cls , track_popularity , track_id) %>% 
  group_by (podcast_music_cls) %>% summarise(avg_rating = mean(track_popularity),
                                             track_count = length(unique(track_id)))
dat




