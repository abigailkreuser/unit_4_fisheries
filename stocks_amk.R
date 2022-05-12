# 2022-03-17
# happy st pattys day 
# 2&3 mash up


# stock collapse 

#back ground info for reading 
# stock isn't a species, byt its a species fished in a particular way managed by an agency and has a lot
# of huan components 
# stocks can overlap 

#this is a complicated dataset and its really big 


library(tidyverse)
load("data/RAMLDB v4.495/R Data/DBdata[asmt][v4.495].RData")
head(area)

#timeseries_values_views table is what we will probably be using 



# particularly ugly data
# logistic regression 
#famous fishery paper 
# when a catch is 10% or less than the histroical maximum catch 
# the stock is considered to collapse 
# there are caveats like where does management play a role

glimpse(timeseries_values_views)
#stockid is helpful for linking tables 
#TBbest best estimate of total biomass 
#TCbest - total catch best estimate - we will be working with today 
# eg in 1960 it was 33000 metric tons 


glimpse(stock)
#tsn taxon key 
# we want this stock info added to the views 

fish = timeseries_values_views %>%
  left_join(stock, by = c("stockid", "stocklong"))
# joins by two variables but these will always match up


dim(timeseries_values_views)
dim(fish) # has more columns but the exact same number of rows 
glimpse(taxonomy)
# there can be one cod species, but there are many cod stocks, so tsn changes but not the actual species 
# this table also has fishery type


#adding taxonomy 
fish = timeseries_values_views %>%
  left_join(stock, by = c("stockid", "stocklong")) %>%
  left_join(taxonomy, by= "tsn", "scientificname") 

fish <- fish %>%  
  select(stockid, year, TCbest, tsn, commonname, region, FisheryType, taxGroup, scientificname.x)

fish <- fish %>%
  filter(stockid != "ACADREDGOMB")

glimpse(fish)

glimpse(fish)#if you don't join by both it makes a scientificname.y and scientificname.x


dim(timeseries_values_views)
dim(fish)

ggplot() +
  geom_line(aes(x=year, y=TCbest, color=stockid), data=fish) +
  theme(legend.position = "none")
ggsave('figures/total_catch_all_stocks.png', device="png", height=4, width=7, units="in")

#checking the units of each 
table(timeseries_units_views$TCbest)
unique(timeseries_units_views$TCbest)


fish %>% group_by(stockid, commonname, region) %>% 
  summarize(TCbest_max = max(TCbest, na.rm=T)) %>%
  arrange(desc(TCbest_max))

#fun story time about acadian redfish 

fish <- fish %>%
  filter(stockid != "ACADREDGOMGB")# idk whats going on here but there is an issue removing stock things 



#FUCKIN I cannot remove acadian red fish 


# Cod collapse

cod = fish %>% 
  filter(scientificname.x == "Gadus morhua") %>%
  distinct(region)

cod = fish %>% 
  filter(scientificname.x == "Gadus morhua",
         region == "Canada East Coast", 
         !is.na(TCbest)) %>%
  group_by(year) %>%
  summarise(total_catch = sum(TCbest)) 
glimpse(cod)

ggplot(aes(x=year, y=total_catch, color = stockid), data=cod) + 
  geom_line() +
  labs(x= "Year", y= "Total Catch (Metric Tons)", 
       title = "Cod Total Catch in East Canadian Coast")


## collapse data frame 
cummax() #cummulative maximum

collapse <- fish %>%
  filter(!is.na(TCbest)) %>%
  group_by(stockid, tsn, scientificname.x, commonname, FisheryType, region, taxGroup) %>%
  mutate(historical_max_catch = cummax(TCbest),
         collapse = TCbest < 0.1 * historical_max_catch) %>%
  summarize(ever_collapsed = any(collapse)) %>%
  ungroup() #holds on to the grouping done above even though tthere should only be one left per group
#okay okay okay there is something going on with the = vs the <- you cannot use that within the mutate. 


glimpse(collapse)

ggplot()+
  geom_bar(aes(x=FisheryType), data = collapse) +
  facet_wrap(~ever_collapsed) + 
  coord_flip()




## Logisitic regression 
# a glm when your y needs to be constrained between 0 and 1 
# T/F a  binary 
# dont have to meet as many logistic regressions 
# functions showing the relationship between the logistic and linear model 


# building logistic regression 
model_data = collapse %>%
  mutate(FisheryType = as.factor(FisheryType)) %>%
  filter(!is.na(FisheryType))
head(model_data)

# run the model 
model_l = glm(ever_collapsed ~ FisheryType, family="binomial", data=model_data) #binomial is the logistic regression family
summary(model_l)
#binomial- 1s and 0s, T/F
#poisson - is good for count distribution 



model_data %>% distinct(FisheryType) %>% arrange(FisheryType)
# made the intercept be flat fish, through using arrange as alphabetical 


#flat fish is trapped in the intercept value 
# the glm probability of the other listed organisms it in relation to the intercept 
# forage fish are statistically significantly likely to collapse in comparison to the intercept 
# rockfish are the most likely to collapse relative to our flat fish 
#tuna and marlin are negative, are less likely to collapse than flat fish
# you wouldnt report the table this way you would visualize it. 

#looking at the estimate in the GLM to the if the relationship to the other fishery type
# is positive or negative 



#create and visualize logisitic regression predictions 
FisheryType = model_data %>% distinct(FisheryType)

model_l_predict <- predict(model_l, newdata=FisheryType, se.fit = TRUE, type="response")
#type = response and not link- link is in the scale of the X and is called log odds?
# we want to know if the fishery is going to collapse or not so we want it in the scale of the y


collapse_predictions <- cbind(FisheryType, model_l_predict)

ggplot(data = collapse_predictions, aes(x=FisheryType, y=fit, fill=FisheryType))+
  geom_bar(stat="identity", show.legend=FALSE) + 
  geom_errorbar(aes(ymin= fit-se.fit, ymax = fit + se.fit), width = 0.2)+
  coord_flip()+
  ylab("Probability of stock collapse")+
  theme_bw()
