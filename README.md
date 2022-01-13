# sts_graph_landmark
Easily create Landmark Analysis graphs in Stata

_v. 1.1.2_  

![image](https://user-images.githubusercontent.com/22870774/133729652-f44a595b-cd5b-49a5-95e7-f83561ea4a1c.png)




Description
========


`sts_graph_landmark` has for objective to emulate some of `sts graph, failure()` capabilities to produce landmark analysis plots (namely: graph Kaplan-Meier failure function and display the associated risk table).  

In survival analysis, survival bias (also called immortal-time bias) arises from incorrect analysis of time-dependant events.  
Notoriously, this occurs when grouping statistical units (individuals, patients, ...) at baseline according to events or diagnostics that -albeit are retrospectively known to occur- are posterior to the baseline analysis time and then comparing the two groups (e.g. K-M plots, comparing Hazard ratios and log-rank tests between the two groups).  

Such modelling ignores the time-dependance of the failure event and create scenarios where some statistical units are transitorily immune to failure.  

A landmark analysis is an approach that adequately circumvent this issue by resetting the analysis time after one or more specified timepoints after which only surviving statistical units are included. As such, only statistical units with comparable survivorship status at the landmark time are compared within each landmark epoch.  


Installation
------------

In order to install `sts_graph_landmark` from github the github-package is required:

	net install github, from("https://haghish.github.io/github/")

You can then install the development version of `sts_graph_landmark` with:

	github install CTU-Bern/sts_graph_landmark


Example
------------
  

	# load example dataset (note: this example is nonsensical and only for graphing purposes)
	webuse stan3, clear
	
	# set data as survival data
	stset t1, failure(died) id(id)
	
	# label treatment arms 
	label define posttran_l 0 "prior transplantation" 1 "after transplantation"
	label value posttran posttran_l
	
	# create landmark plot and table 
	sts_graph_landmark, at(200) by(posttran) risktable
	
Help and documentation
----------------------

	# run the following command:
	help sts_graph_landmark


Author
------

**Arnaud Künzi**  
CTU Bern  
arnaud.kuenzi@ctu.unibe.ch  
<https://github.com/CTU-Bern/sts_graph_landmark>  
