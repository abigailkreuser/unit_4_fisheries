# joins and pivots 
# 2022-03-15 

#mutating join - mashing two tables together 
# there is normally some key that links the two togetherr 
# left, right, full


#filtering joins- remove some rows in one table based on what is in table 2
#semi and anti


#its not that simple of a concept
#there can be really unexpected behavior 


library(tidyverse)

data1=data.frame(ID =c(1,2),
                 X1 = c("a1", "a2"))
data2=data.frame(ID = c(2,3),
                 X2=c("b1", "b2"))
data1
data2
# left table is the first table because you read left to right 

left_join(data1, data2)
#shows you its joining by ID, because that is the only column name shared by the two tables

left_join(data1, data2, by="ID")
#if needing to combine cols with diff names look it up 
# by =c("ID1" == "ID2")
# when specify it doesnt give you the little note


#tidyverse way so you can also link commands, like group and summarize
data12 =data1 %>%
  left_join(data2, by="ID")
data12

#doesnt use right joins, ,because that just uses the second table same concept
#could just switch the order of the tables, and use left join



#inner join - keeps data that actually has matches 

inner_table = data1 %>%
  inner_join(data2, by = "ID")

#limited use, could left join and then filter out the NAs

#full join
#uses all the data from the tables 
# and throws in NAs where that data is not available
full_table = full_join(data1, data2, by ="ID")


#semi join- returns data1 that has matching values in data2, but not data2 data
#erin would use data1 %in% data2
semi_table = semi_join(data1, data2, by="ID")


#anti join- can tell you where the meta data doesn't exist 
# will show you every ID that doesnt exist in table 2 from table 1
# couls use !%in%
# %in% could when using a single column, but if you need to use a join for multiple columns 
# the anti join is helpful. 
# like species names and genus names needing both to id animals

anti_table = data1 %>%
  anti_join(data2, by = "ID")



# reasons why joins are so tricky 
# repeat observations in the second table
# use dim() to check if number of rows is the same or different 
# could double count obs when there is multiple in the "right table" 

#distinct() on common name will keep the first instance of column name 
# exercise 1.1 
# but if I do care, read the paper, choose the wieight and create another col in table 2
# use for analysis T/F


### Pivots

survey = data.frame(quadrat_id = c(101, 102, 103, 104),
                    barnacle_n = c(2, 11, 8, 27),
                    chiton_n = c(1, 0, 0, 2),
                    mussel_n = c(0, 1, 1, 4))

survey

#ggplot and dplyr can play nicer if you pivot your data 
#erin flips between long and wide all the time 

long = survey %>%
  pivot_longer(cols = c("barnacle_n", "chiton_n", "mussel_n"),
               names_to="beastie", 
               values_to="counts")
long

wide = long %>%
  pivot_wider(names_from=beastie, values_from=counts)

wide



# with ggplot- it likes the long format 
# modeling like the wide format 



