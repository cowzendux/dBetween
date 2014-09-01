* Calculate between-groups d statistic
* Analyses by Jamie DeCoster

* Usage: dBetween(Outcome, Group Variable)
* Outcome is the continuous outcome variable that is being compared
between the two groups
* Group Variable is a categorical variable that defines the two groups being
compared. If Group Variable has more than two levels, then the first two
groups (alphabetically) will be used for the comparison.
* The program will obtain the means of the two groups and calculate the
d statistic, calculated as:
(mean of first group - mean of second group)/pooled sd
* The two means, the pooled sd, and the d statistic will be printed
to the output window. The d statistic will also be returned by the function.

* EXAMPLE: dBetween("height", "gender")
This will calculate the d statistic for the difference between the heights of
men and women. The sign of the coefficient will be positive if the first
group has a higher mean and will be negative if the second group has
a higher mean. If gender was coded 0 = female 1 = male, then a positive
d would indicate that females are taller, and a negative d would indicate
that men are taller.

*******
* Version History
*******
* 2013-04-04 Created

set printback=off.
begin program python.
import spss, spssaux, math

def getVariableIndex(variable):
   	for t in range(spss.GetVariableCount()):
      if (variable.upper() == spss.GetVariableName(t).upper()):
         return(t)

def descriptive(variable, stat):
# Valid values for stat are MEAN STDDEV MINIMUM MAXIMUM
# SEMEAN VARIANCE SKEWNESS SESKEW RANGE
# MODE KURTOSIS SEKURT MEDIAN SUM VALID MISSING
# VALID returns the number of cases with valid values, and MISSING returns
# the number of cases with missing values

 if (stat.upper() == "VALID"):
   cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
	  handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
		visible=False)
	  result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
   return (result[0])
 elif (stat.upper() == "MISSING"):
   cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
	  handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
		visible=False)
	  result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
   return (result[1])
 else:
  	cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /STATISTICS="+stat+"\n\
  /ORDER=ANALYSIS."
	  handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
		visible=False)
	  result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
   if (float(result[0]) <> 0):
    return (result[2])

def getLevels(variable):
    submitstring = """use all.
execute.
SET Tnumbers=values.
OMS SELECT TABLES
/IF COMMANDs=['Frequencies'] SUBTYPES=['Frequencies']
/DESTINATION FORMAT=OXML XMLWORKSPACE='freq_table'.
    FREQUENCIES VARIABLES=%s.
    OMSEND.
SET Tnumbers=Labels.""" %(variable)
    spss.Submit(submitstring)
 
    handle='freq_table'
    context="/outputTree"
#get rows that are totals by looking for varName attribute
#use the group element to skip split file category text attributes
    xpath="//group/category[@varName]/@text"
    values=spss.EvaluateXPath(handle,context,xpath)

# If the original variable was numeric, convert the list to numbers

    varnum=getVariableIndex(variable)
    values2 = []
    if (spss.GetVariableType(varnum) == 0):
      for t in range(len(values)):
         values2.append(int(float(values[t])))
    else:
      for t in range(len(values)):
         values2.append("'" + values[t] + "'")
    spss.DeleteXPathHandle(handle)
    return values2

def dBetween(outcome, group):
    glevels = getLevels(group)
    meanlist = []
    sdlist = []
    nlist = []
    namelist = []
    w = 0
    for level in glevels[:2]:
        submitstring = """USE ALL.
COMPUTE filter_$=(%s=%s).
FILTER BY filter_$.
EXECUTE.""" %(group, level)
        spss.Submit(submitstring)

        namelist.append(group + " = " + str(level))
        m = float(descriptive(outcome, "MEAN"))
        meanlist.append(m)
        s = float(descriptive(outcome, "STDDEV"))
        sdlist.append(s)
        n = int(descriptive(outcome, "VALID"))
        nlist.append(n)
        w = w + ((n-1)*(s**2))

    sp = math.sqrt(w/(nlist[0]+nlist[1]))
    d = (meanlist[0] - meanlist[1]) / sp

# Writing to SPSS output 

    print "*********"
    print group + "\t" + str(glevels[0]) + "\t" + str(glevels[1])
    print "n" + "\t" + str(nlist[0]) + "\t" + str(nlist[1])
    print "mean" + "\t" + str(meanlist[0]) + "\t" + str(meanlist[1])
    print "sd" + "\t" + str(sdlist[0]) + "\t" + str(sdlist[1])
    print
    print "d = " + str(round(d, 4))
    print "*********"

    spss.Submit("USE ALL.")
    return(d)

end program python.
set printback=on.
