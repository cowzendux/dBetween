#dBetween

SPSS Python Extension function to calculate a between-groups d statistic.

The value of the d statistic is returned by the function.

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html

##Usage
**dBetween(outcome, group)**
* "outcome" is the continuous outcome variable that is being compared between the two groups. This argument is required.
* "group" is a categorical variable that defines the two groups being compared. It can be a string or a numeric variable. If group has more than two levels, then the first two groups (alphabetically) will be used for the comparison.

##Example
**dheight = dBetween("height", "gender")  
print dheight**
* This will calculate the d statistic for the difference between the heights of men and women. 
* The sign of the coefficient will be positive if the first group has a higher mean and will be negative if the second group has a higher mean. If gender was coded 0 = female 1 = male, then a positive d would indicate that females are taller, and a negative d would indicate that men are taller.
