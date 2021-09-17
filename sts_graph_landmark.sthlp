{smcl}
{* *! version 1.1.0  31Aug2021}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{right:also see:  {help sts graph}, {help stset}, {help stsplit}}
{hline}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "sts_graph_landmark##syntax"}{...}
{viewerjumpto "Description" "sts_graph_landmark##description"}{...}
{viewerjumpto "Options" "sts_graph_landmark##options"}{...}
{viewerjumpto "Remarks" "sts_graph_landmark##remarks"}{...}
{viewerjumpto "Examples" "sts_graph_landmark##examples"}{...}
{title:Title}

{phang}
{bf:sts_graph_landmark} {hline 2} Display Kaplan-Meier curves and Risk tables for landmark analyses


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:sts_graph_landmark}
[{varname}]
{ifin}
{cmd:,} at(numlist) [failure(varname) id(idvar) by(varlist) {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt varname}*}not needed if data is {cmd:stset} or if varname is named {it:failvar}_days{p_end}
{synopt:{opt at(numlist)}}for landmark analysis: landmark times{p_end}
{synopt:{opt fai:lure(failvar)}*}failure event (takes values [0,1]){p_end}
{synopt:{opt id(idvar)}*}multiple-record ID variable{p_end}
{synopt:{opt by(varlist)}}estimate separate functions for each group formed by varlist{p_end}
{synopt:{opt end(double)}}trim/exclude from the graph events occuring after the {it:end} upper range of the analysis time{p_end}
{synopt:{opt stsetopts(string)}}optional settings for the internal stset command. See {help stset}{p_end}
{synopt:{opt stslistopts(string)}}optional settings for the internal sts list command. See {help sts list}{p_end}

{synopt:{it:*required if data is not {cmd:stset}.}}{p_end}

{syntab:Graph options}
{synopt:{opt ti:tle(string)}}Title of the graph{p_end}
{synopt:{cmdab:lcol:ors(}{it:{help colorstyle}list}{cmd:)}}list of colors and opacities for the K-M curves{p_end}
{synopt:{opt xtit:le(string[,subopts])}}{p_end}
{synopt:{opt ytit:le(string[,subopts])}}See {manhelpi axis_title_options G-3}{p_end}
{synopt:{opt xlab:el(string[,subopts])}}{p_end}
{synopt:{opt ylab:el(string[,subopts])}}See {manhelpi axis_label_options G-3}{p_end}
{synopt:{opt legend(subopts)}}See {help legend_options G-3}{p_end}
{p2col:{it:...}}{p_end}
{p2col:{it:{help scatter##twoway_options:twoway_options}}}titles, legends,
       axes, added lines and text, by, regions, name, aspect ratio, etc.{p_end}
{p2col:{it:showcmd}}outputs the graph command for debugging purposes{p_end}

{syntab:Risk table options}
{synopt:{opt risk:table}}Display a risk table below the graph.{p_end}
{synopt:{opt ev:ents}}Display the failure event count alongside the number at risk.{p_end}
{synopt:{opt risktableopts(string)}}Options for formatting the risk table below the graph.{p_end}

{syntab:Estimation options}
{synopt:{opt usercmd(string)}}let the user run a command that will be run at each landmark period

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sts_graph_landmark} has for objective to emulate some of {cmd:sts graph, failure} {it:(see {help sts graph})} capabilities to produce landmark analysis plots (namely: graph Kaplan-Meier failure function and display the associated risk table).
{p_end}

{pstd}
In survival analysis, survival bias (also called immortal-time bias) arises from incorrect analysis of time-dependant events. {break}
 Notoriously, this occurs when grouping statistical units (individuals, patients, ...) at baseline according to events or diagnostics that -albeit are retrospectively known to occur- are posterior to the baseline analysis time and then comparing the two groups  (e.g. K-M plots, comparing Hazard ratios and log-rank tests between the two groups). {break}
 Such modelling ignores the time-dependance of the failure event and create scenarios where some statistical units are transitorily immune to failure. 
{p_end}

{pstd}
A landmark analysis is an approach that adequately circumvent this issue by resetting the analysis time after one or more specified timepoints after which only surviving statistical units are included. {break}
As such, only statistical units with comparable survivorship status at the landmark time are compared within each landmark epoch. {break}
The choice of the landmark time(s) is often a matter of clinical consideration and in the context of immortal-time bias is chosen to coincide with the value 
equivalent in analysis-time at which knowledge acquisition of the group membership occurs.
{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt varname} If the data is {cmd:stset} or if the time-to-failure variable is suffixed with '_days', leave {it:varname} empty. 
Else, if the time-to-failure variable is not called {it:failvar}_days (see {cmd:failure}) you have to specify here its name. 
In other words, for a failure variable called {it:failvar}, if the time-to-failure variable is NOT named {it:failvar}_days, you HAVE to specify its name here.

{phang}
{opt at(numlist)} Timepoints at which a landmark is placed. Multiple timepoints are supported, you can input a numlist with such as {it:30 100 360}.

{phang}
{opt failure(failvar)} variable coding the failures (1 = failed, 0 = not failed). The time-to-failure variable is assumed to be whatever is {cmd:stset}. 
If no time-to-failure variable has been stset, it is presumed to be named by default {it:failvar}_days.

{phang}
{opt id(varname)} If the survival data has multiple-records per unit (patient, person, individual, household), the unit identifier has to be specified. 
If the survival data is single-record (one line per id/unit) this option is optional. 
It rests on the user to ensure {opt id()} is specified if the data analyzed is multiple-record survival data.

{phang}
{opt end(double)} trim/exclude from the graph events occuring after the value set by {it:end}. 
This option has no bearing on the estimation of the survival/failure characteristics and is purely graphical. see {opt stsetopts(string)} to parametrize the survival-time data.

{phang}
{opt stsetopts(string)} Rarely used. 
passtrough options to the internal {cmd:stset} command. 
This is notably of interest for (but not limited to) multiple-records survival data to set {opt id()}, {opt future},  {opt past},  {opt enter()}, {opt exit()}
 and other intricates failure/survival profiles. 
See {help stset} for more details

{phang}
{opt stslist(string)} Rarely used. passtrough options to the internal {cmd:sts list} command. Options of interest are {opt adjust()}, {opt strata()},  {opt enter}. See {help sts list} for more details.


{dlgtab:Risktable} 

{phang}
{opt risktable} Display a risk table below the graph. It reports the numbers at risk {it:just before entering} the period on the time axis. The at-risk population comprise of units whom follow-up time covers the time period of interest (units censored due to incomplete follow-up time or previous failure are excluded).

{phang}
{opt ev:ents} Display the failure event count alongside the number at risk.

{phang}
{marker risktableopts}
{opt risktableopts(string)} The risktableopts option is needed especially when xlabel ticks are very close to each others and the table's content is overlapping with the labels or itself. 
Through this option, it is possible to change text size via {cmd:labsize(}{help textsizestyle}{cmd:)} or by changing text indentation and/or justification.
 Three distinct regions {it:tbl_reg} are exposed for formatting: {it:tbl_title}, {it:tbl_labels} and {it:tbl_content}.


	{it:tbl_title}
	-------------------------------------------
	{it:...}		|	{it:...		...}
	{it:tbl_labels}	|	{it:tbl_content	...}
	{it:...}		|	{it:...		...}
 
{phang} 
 The formatting of the options is:
 
 {bf: risktableopts(tbl_reg(# , {help axis_label_options}))}

 {phang}'#' denotes the position on the x axis and is specific to the scale used. 
 For a scale in days from 0 to 365 days, a position of #=-20 will draw the title at -20 relative to the left of the graph. the default value is -20.

 {phang}tbl_reg denotes one of {{it:tbl_title}, {it:tbl_labels}, {it:tbl_content}}. it is possible to define more than one tbl_reg like so:
 
 {bf: risktableopts(tbl_title(-20 , labsize(huge)) tbl_label(-15, labsize(vtiny)))}

 {phang}table_reg {cmd:tbl_labels()} has one extra suboption: {cmd:symbol(}{it:symbol}{cmd:})}{p_end}
 
 {phang}{it:symbol} can be either an integer from 1/4:{p_end}
 {p2colset 9 12 27 2}{...}
  {p2col:1}█{p_end}
  {p2col:2}•{p_end}
  {p2col:3}⬤{p_end}
  {p2col:4}⚫{p_end}
{p2colreset}
{phang} or a string literal. (e.g. {cmd:symbol("*")} will use the symbol * in the label key (see {help legend_options##description:{it:legend_options}} for more info on the terminology) {p_end}

{dlgtab:Estimation}

{phang}
{opt usercmd(cmdstring)} let the user define a {it:cmdstring} that will be run once at each landmark period defined in {cmd:at()}. 
The results are exposed via the matrix {cmd:_r}. This matrix is also available through the graphing {opt text()} interface. 
However, be aware that when you invoke {cmd:sts_graph_landmark}, the matrix {cmd:_r} does not exist yet.
Given that Stata will try to resolve the content of any local macro inside of {opt text()} at runtime, you have to delay macro expansion so that its content is only interpreted after cmdstring is run 
(see the technical note in {manpage P 305:[P] macro}).
 
 This is done like so: 
 
 text("HR: {error:\}{result:`=_r[1,1]'}")
 
 This will substitute {result:the local macro expression} to the first element of the matrix {cmd:_r}.
 Take note of the {error:mandatory} backslash before the backtick. 
 Read {mansection U 18.3 Macros:[U] macro} and {mansection U 18.3.8 MacroExpressions:[U] Macros expressions} to know more about Stata's macro system.

{marker remarks}{...}
{title:Fixing table alignement}

{phang}
If some elements on the table are overlapping or misaligned, try first changing the {opt scale()} option, or changing the graph aspect ratio by specifying {opt xsize()} and {opt ysize()}. See {manhelpi graph_display G-2} 
If you wish to retain different font sizes for the graph or/and {it:tbl_reg} regions, refer to the above {help sts_graph_landmark##risktableopts:risktableopts(string)} option

{pstd}

{marker remarks}{...}
{title:Remarks}

{phang}
The command takes care of {cmd:stset}, {cmd:stsplit} and graph the data. The original dataset is not modified. If data has been previously {cmd:stset}, the program uses existing st settings.

{pstd}

{marker examples}{...}
{title:Examples}

{phang}minimal example with a landmark time of 100 days. Note that the previous {cmd:stset} command would have made the {cmd:by()} superfluous had the variable {it:posstran} been named {it:died_days} instead:

{phang}{stata webuse stan3, clear}{p_end}
{phang}{stata stset t1, failure(died) id(id)}{p_end}
{phang}{stata sts_graph_landmark, at(100) by(posttran)}{p_end}

{phang}minimal example with a landmark time of 100 days (without any previous {cmd:stset)):

{phang}{stata stset, clear}{p_end}
{phang}{stata sts_graph_landmark t1, id(id)	failure(died) by(posttran) at(100) }{p_end}

{phang}with risk table:

{phang}{stata sts_graph_landmark t1, id(id)	failure(died) by(posttran) at(100) risktable}{p_end}

{phang}with several landmark times:

{phang}{stata sts_graph_landmark t1, id(id)	failure(died) by(posttran) at(200 500) }{p_end}

{phang}with user-defined command:

{phang}{stata sts_graph_landmark t1, id(id)	failure(died) by(posttran) at(200 500) usercmd(stcox surgery, nolog) }{p_end}

{phang}with user-defined command and plotting HR on graph:

{phang}{cmd:. sts_graph_landmark t1, id(id)	failure(died) by(posttran) at(500) usercmd(stcox surgery, nolog) ///} {p_end}
{phang}{cmd: text(10 300	\`"HR = `:di %5.2f `=_r[1,1]''"' \`"p =  `:di %5.2f `=_r[4,1]''"') ///} {p_end}
{phang}{cmd: text(10 1000	\`"HR = `:di %5.2f `=_r[1,2]''"' \`"p =  `:di %5.2f `=_r[4,2]''"')}
{p_end}

{title:Author}

{pstd}
Arnaud Künzi, CTU Bern, Switzerland ({browse "mailto:arnaud.kuenzi@ctu.unibe.ch":arnaud.kuenzi@ctu.unibe.ch})

{pstd}

{title:Citations and recommanded readings}

{pstd}
Morgan, C.J. Landmark analysis: A primer. 
{it:J. Nucl. Cardiol.} {bf:26}, 391–393 (2019). 
https://doi.org/10.1007/s12350-019-01624-z

{pstd}
Gleiss, Andreas, Rainer Oberbauer, and Georg Heinze. An unjustified benefit: immortal time bias in the analysis of time‐dependent events. 
{it:Transplant International} {bf:31}, no. 2 (2018): 125-130.  
https://doi.org/10.1111/tri.13081

{pstd}
