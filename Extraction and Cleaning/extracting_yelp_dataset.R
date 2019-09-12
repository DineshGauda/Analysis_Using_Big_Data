setwd("D:\\MS Data Analytics\\Sem 2\\PDA\\Project\\PDA-Project\\Yelp")

#Download yelp dataset zip file from kaggle
system("kaggle datasets download -d yelp-dataset/yelp-dataset/version/4")

#Extract the zip
zipFileName<- "yelp-dataset.zip"
outDir<-"D:\\MS Data Analytics\\Sem 2\\PDA\\Project\\PDA-Project\\Yelp\\dataset"
unzip(zipFileName,exdir=outDir) 

#delete zip
fileName <- "yelp-dataset.zip"
if (file.exists(fileName)) file.remove(fileName)


