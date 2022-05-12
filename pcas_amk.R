#2022-03-22

# PCAs 
# principal component analysis
# a way to reduce the deminsionality of the data 

#PCAs can be used in image compression
#Igean values and Vectors can be multplied back together 
#

#PCA1 is set up because it has the most variation in your data 
# The combined variance 
#PC1 and PC2 should explain 50% 
# the biplot shows the PC1 and PC2 variation combined 

# A PCA is only as valuable as teh first handful of components can explain 


library(tidyverse)
library(palmerpenguins)


head(penguins)
#PCAs do not like NAs

pen_drop_na = penguins %>%
  drop_na()
#getting rid of NAs is a big deal 

pen_num = pen_drop_na %>%
  select(ends_with("_mm"), body_mass_g)

#geopgraphers and oceanographers like PCAs


head(pen_num)


#Run PCA
dim(pen_num)
pen_pca = prcomp(pen_num, center = TRUE, scale. = TRUE)
#center- to center data over 0
summary(pen_pca)
#proportion of varience is the Igean vector 
# were geting lots of info from the PC1
# a biplot would give us 0.88 percent of the variance 
class(pen_pca)
#special snowflake data type 
str(pen_pca) #fancy versions of lists 
#x is wehre the principle components are contained 
str(summary(pen_pca))
summary(pen_pca)$importance
proportion_of_variance <- summary(pen_pca)$importance[2,]

# calculate proportion of variance 
pen_pca$sdev^2 / sum(pen_pca$sdev^2)
#since its a vector, we have 4 outputs 



pen_pca$rotation
#these are the loadings and they are the Igan values for your PC
#PC1 mainly has positive values across the variables exceot bill_depth is negtive
#most of the action happening in PC2 is bill_length and bill_depth

plot(pen_pca)


# Scree plot
pca_scree = data.frame(pc=c(1:4), 
                       var=proportion_of_variance)

ggplot(aes(x=pc, y=var), data = pca_scree)+
  geom_col()+
  geom_point()+
  geom_line()



# create a bi plot

# creating the df we want for the biplot 
str(pen_pca)
head(pen_pca$x)
# each one of these rows correspond to a penguin that was in the OG data set
pen_pca_meta = cbind(pen_drop_na, pen_pca$x)
head(pen_pca_meta)

ggplot()+
  geom_point(aes(x=PC1, y=PC2, color=species), data = pen_pca_meta)

install.packages("devtools")
library(devtools)
install_github("vqv/ggbiplot")
library(ggbiplot)

ggbiplot(pen_pca, groups=pen_pca_meta$species, ellipse=T) 
  
ggbiplot(pen_pca, groups=pen_pca_meta$species, ellipse=T, alpha = 0) + 
 geom_point(aes(color=pen_pca_meta$species, shape=pen_pca_meta$sex)) +
  theme_bw() +
  xlim(-3,3)+
  coord_fixed(ratio=1)

# can graph the PC3 and 4 the data is orthagonal and not repeated 
# so variation accounted for in 1 and 2 is not used again in 3 and 4

