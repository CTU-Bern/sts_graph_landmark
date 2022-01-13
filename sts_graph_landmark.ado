/*******************************************************************************
********************************************************************************	
	Name:		sts_graph_landmark
	Author:		Arnaud Künzi (arnaud.kuenzi@ctu.unibe.ch)
	Version:	1.1.1
	Creation:	2020.09.01
	Last edit:	2022.01.13
	Description:
		
	Comments:
	
		Known bugs: stset options origin(), enter() and probably others 
		cause command 'streset' to fail in the program on a not found 
		temporary variable __00008.

	Changelog:
	
	-1.1.1 ON 2022.01.13
	
		- Fixed bug where execution failed when max follow-up time was not an integer.
		- Fixed graphing bug when an observation time was below from the previous offset of 0.001
		  Offset was changed to epsilon = 1.0x-1b (see bulletpoint 9.6 at
		  https://blog.stata.com/2012/04/02/the-penultimate-guide-to-precision/#section9)
		- Added undocumented keepplotdata option
	
	-1.1.0 ON 2021.08.31
	
		- Added risktableopts(). It is now possible to customize style and position of the elements of the 
			risktable (tbl_title, tbl_labels, tbl_content) as well as the symbol of the key
	
	- 1.0.3 ON 30.11.2020
	
		- fixed issues where custom axis labels such as
		  xlabel(0 "baseline" 30 "1 month" 60 "2 months")
		  caused problems for parsing the risktable numlist.
		  Added private program remove_non_numeric to do so.
	
	- 1.0.2 ON 09.11.2020
	
		- fixed issue where usercmd only worked when r(table) returned one column, so multiple covariates made the code crash. matrix _r now returns all covariates and landmark epochs are suffixed to the column names with a colon like so 'varname:0'

	- 1.0.1 ON 22.10.2020
		- fixed bug where content of local macros in option text() could not be delayed with backslash. (i.e. \`=something' or \`:something')
	
	- 1.0 ON 10.09.2020:
	
		- implemented risktables
		- changed graph command from [if] to split variable (one for each line) 
			to improve clarity
		- removed dependency on ssc colorpalette
		- Option id() is now optional. It rests on the user to ensure that, if not specified, the data is actually single-record survival data.
		- if data has already been stset, the program use the existing st settings.
				if data is not stset, options failure() is required.
		- Option by() is now optional: if missing, a default overall caregory is plotted instead

	- 0.9 ON 2020.09.02: pre-release
	
		from initial feedback
		- fixed ytick() support
		- fixed axis title support

********************************************************************************
*******************************************************************************/





cap program drop sts_graph_landmark
program define sts_graph_landmark

	version 16
	
	syntax [varlist(default=none)] [if] [in], [at(numlist >0) FAILure(varname) TItle(string) id(varname) by(varname) end(numlist max=1) YLABel(passthru) XLABel(passthru) LCOLors(string) RISKtable EVents risktableopts(string) SCale(real 0.8) FRFrom(string) usercmd(string) stsetopts(string) stslistopts(string) SHOWcmd KEEPplotdata *]

	************* PARSING PARAMETERS AND SETTING DEFAULT VALUES *************
	if ("`by'"		== ""){
		tempvar by
		cap lab define ovlab 1 "Overall"
		gen `by':ovlab = 1
		local by_lvls 
		local nlevels 1
	}
	
	if ("`id'"		== ""){
		* create default id variable for stsplit. Makes the assumption st data is single-record
		tempvar id		
		gen `id' = _n
		local defaultid defaultid
	}
	
	
	
	
	*store levels of 'by' and 'at'
	qui levelsof `by', local(by_lvls)
	local nlevels `r(r)'
	
	
	local nat `:word count `at''
	
	*Default option values
	
												local varname:	word 1 of `varlist'
	if ("`failure'" != "" & "`varname'" == "")	local varname	`failure'_days
	else{
		if ("`failure'" == "")					local failure 	"`_dta[st_bd]'"
		if ("`varname'" == "")					local varname 	"`_dta[st_bt]'"
	}
	if ("`by'"		!= "")						local byby		by(`by')
												local idid		id(`id')
	if ("`end'"		== ""){
		
		qui summ `varname'
												local end	`r(max)'
	}	
												local atend		"0 `at' `end'"
	if ("`frframe'" == "")						local frfrom	default
	
	*Default graphic options
	local graphobs connect(J) sort
	if !regexm(\`"`options'"', "ytitle\(")		local options2	`"`options2' ytitle("Failure rate (%)")"'
	if !regexm(\`"`options'"', "ytick\(")		local options2	`"`options2' ytick(#10)"'
	if !regexm("`ylabel'","angle")				local ylabel	`"`ylabel' ylabel(, angle(0))"'
	if ("`xlabel'"	== "")						local xlabel	`"xlabel(`atend')"'
	if ("`title'"	== ""){
		if ("`failure'" != "" ){				//default title
												local options2	`"`options2' title("K-M curves for `:variable label `failure''")"'
		}
		else if ("`_dta[st_bd]'" != ""){		//default title if data is already stset
												local options2	`"`options2' title("K-M curves for `:variable label `_dta[st_bd]''")"'
		}
	}											//user-defined title
	else										local options2	`"`options2' title("`title'")"'
	if !regexm(\`"`options'"', "graphregion\("){
												local options2	`"`options2' graphregion(color(white) lc(white) lw(thick) margin(5 5 5 5))"'
	}
	if (`"`risktableopts'"' != ""){
												local risktable "risktable"	
												noi: di as text "{hi:risktableopts()} set -> option {hi:risktable} is implied."
	}
	if ("`legend'"	== ""){
		if ("`risktable'" == ""){
			forvalues j = 1/`nlevels'{
				local legendopts `"`legendopts' `j' "`:label (`by') `:word `j' of `by_lvls'''""'
			}
				local legendopts order(`legendopts')
		}
		else	local legendopts "off"
		
												local options2	`"`options2' legend(`legendopts')"'
	}
	
	*parse xlabel ticks
	if "`risktable'" != "" {
		gettoken discard keep: xlabel, parse("(")
		gettoken keep discard: keep, match(parns)
		
		*remove quoted labels. it outputs r(numlist)
		remove_non_numeric `"`keep'"'
		
		numlist `"`r(numlist)'"', sort
		local risktabletimes `"0 `r(numlist)'"'
		local risktabletimes: list uniq risktabletimes
	}

	*define K-M lines colors
	if ("`lcolors'"	== ""){
		*Palette taken from the ssc colorpalette Set1
		local default_palette `""55 126 184" "228 26 28" "77 175 74" "152 78 163" "255 127 0" "255 255 51" "166 86 40" "247 129 191" "153 153 153""'
												local lcolors `"`default_palette'"'
	}
	
	*parse xlabel formatting options for the risktable
	while (`"`risktableopts'"' != ""){
		gettoken crisktableopts risktableopts: risktableopts, bind match(parns)
		gettoken cname copt: crisktableopts, parse("(") bind match(parns)
		gettoken copt discard: copt, parse(",") match(parns)
		
		if (regexm(`"`copt'"',",")){
		    gettoken cpos copt: copt, parse(",")
		
			local copt: subinstr local copt "," "", count(local comma_replaced)
			if ("`comma_replaced'" == "0"){
				local cpos 
			} 
		}
		else if real(`"`copt'"') != . {
			local cpos `copt'
			local copt
		}

		
		if inlist("`cname'","tbl_title","tbl_labels","tbl_content"){
		    
			*define justification if not defined in `cname'_opts
			if (regexm(`"`copt'"',"labjustification\(left\)|labjustification\(right\)")){
				local `cname'_just `=regexs(0)'
				
				*remove the labjustification() parameter from the current option string as we have now parsed it.
				local copt `=regexr(`"`copt'"',"labjustification\(left\)|labjustification\(right\)","")'
				
				*define the symbol in the key
				if ("`cname'" == "tbl_labels" ){
					if (regexm(`"`copt'"',`"(symbol\()([^)]+)(\))"')){
						local match `"`=regexs(2)'"'
						local match: list clean match
						
						*if it is a number, then it's the position in the following symbol list
						if real(`"`match'"') != . {
							local symbolnum = round(real("`match'"))
							local symbol: word `symbolnum' of █ {&bull} ⬤ ⚫ //add here more symbols separated by space.
						}
						else{
							*else we just take the content of `match' as the symbol.
							local symbol `"`match'"'
						}
						*remove the symbol() parameter from the current option string as we have now parsed it.
						local copt `"`=regexr(`"`copt'"',`"symbol\([^)]+\)"',"")'"'
					}
					else{
						local symbol `"█"'
					}
				}
			}
			else{
				local `cname'_just labjustification(right)
			}
			*store options and positions
			local `cname'_opts `copt'
			local `cname'_pos `cpos'
			
		} 
		
		
		
		local copt
		local cpos
		local cname
	}
	
	if (`"`risktableopts'"' == ""){
		local symbol `"█"'
	}

	if ("`tbl_title_pos'" == ""){
		local tbl_title_pos = -20
	} 
	if ("`tbl_labels_pos'" == "") {
		local tbl_labels_pos = -20
	}
	if ("`tbl_labels_just'" == "") {
		local tbl_labels_just labjustification(right)
	}
	
	************* GETTING A FRAME WITH RISK VALUES SPLIT AT LANDMARK TIME ******	
	
	*Get data
	marksample touse
	
	tempname frworking
	frame copy `frfrom' `frworking'
	
	frame `frworking' {
		qui{
			
			keep if `touse'
			
			*if data is not already st
			cap st_is 2
			if _rc == 119 {
				if "`failure'" != ""{
					* set the data as survival					
					stset `varname', `idid' failure(`failure') `stsetopts'
				}
				else{
					noi di as error _newline "Data not declared as survival-time." _newline "Run {cmd:stset} first or provide options {opt failure()}, {opt id()} (and {it:varname} if needed) to {cmd:sts_graph_landmark}. (see {stata help sts_graph_landmark})"
					error 119
				}
			}
			else{
				//if data already stset
				
				noi di as text _newline(1) "Current st settings:"
				noi st_show
				
				//has been stset with option id: 
				if ("`_dta[st_id]'" != ""){
					//in case no id() option provided to sts_graph_landmark
					if ("`defaultid'" == "defaultid"){
						if("`stsetopts'" != ""){
							noi di as text _newline(1) "Adding stsetops() to current st settings"
							streset, `stsetopts'
						}
						else{
							noi di as text _newline(1) "Using existing st settings."
						
						}
						*but still need to substitute internal variable with existing st settings:
						drop `id'		//drop the ad-hoc id tempvar to avoid confusion
						local id		"`_dta[st_id]'"	//and use the stset id instead
						local idid		"id(`_dta[st_id]')"
					}
					else{
						//in case user provided an override to stset id()
						if ("`_dta[st_id]'" != "`id'"){
							noi di as text _newline(1) "Override st id():"
							streset, id(`id') `stsetopts'
							noi st_show
						} 
					}
				}
				else{
					//if data already stset with option id:
					*stsplit later require data to be id() set
					if ("`defaultid'" == "defaultid") noi di as error _newline "Warning: data not {cmd:stset} with {opt id()} option." _newline " Data is reset as: .{cmd:streset, id(_n)} (->assumption that survival data is single-record. )" _newline "If data is multiple-record, please re-run either {cmd:stset} or {cmd:sts_graph_landmark} with the correct {opt id()} variable." _newline as text
					else noi di as text _newline "Data not {cmd:stset} with {opt id()} option." _newline " Data is reset as: .{cmd:streset, id(`id')} as specified in option {opt id()}" _newline as text
						noi di "`id'"
						streset, id(`id') `stsetopts'
						noi di as text _newline(1) "st settings used:"
						noi st_show
				}

			}
			
			*save label of failure variable
			local fail_labvar: variable label `failure'
			
			*if risktable, get at-risk populations:
			if ("`risktable'" == "risktable"){
				local nxlabel: word count  `risktabletimes'
				forval j = 1/`nlevels' {
					local clevel : word `j' of `by_lvls'
					forval i = 1/`nxlabel' {
						local k  : word `i'			of `risktabletimes'
						local k2 : word `=`i'+1'	of `risktabletimes'
						
						if `i' < `nxlabel'{
							if (`k' == 0)	local equal "="
							else			macro drop equal

							count if _t>=`k' & `by' == `clevel' & _t0 <`equal' `k'
							local atrisk `r(N)'
							
							count if (_d & ~missing(_d) & _t >= `k' & _t < `k2' & `by'== `clevel' )
							local events `r(N)'
		
							/* add the at risk text */
							local axislab`j' `"`axislab`j'' `k' "`atrisk'""'
							if `"`showev'"' != "" {
								/* add the events text */
								local k2 = (`k' + `k2')/2.2
								local axislab`j' `"`axislab`j'' `k2' "(`events')""'
							}
						}
						else{	//last period is different (at the `end' timepoint)
							quietly count if _t >= `k' & `by' == `clevel' & _t0 < `k'
							local atrisk `r(N)'
							local axislab`j' `"`axislab`j'' `k' "`atrisk'""'
							*noi di `"`axislab`j''"'
						}
					}
				}
			}
			
			*Landmark analyses for `nat' periods	
			stsplit indicator, at(`atend') trim nopreserve 
			
			*drop previous results of usedefined function
			cap mat drop _r*
			
			preserve
			foreach i of numlist 0 `at' {   
				tempfile lmfig_`i'                     
				keep if indicator == `i'
				replace `failure' = 0 if `failure' != 1
				
				/*previously:
					stset, clear
					stset `varname', `idid' failure(`failure') `stsetopts'
				This is unneeded since we can simple re-apply stset like this:*/
				
				pause
				streset
				
				
				
				*run user command:
				if (`"`usercmd'"' != "" & ) {
					
					noi di _newline(2) as text "{hline 80}" _newline "Landmark time `i'"
					noi `usercmd'
					mat _r_`i' = r(table)
					

					add_fix `:colnames _r_`i'', prefix(`"""') suffix(`":`i'""')
					
					mat colnames _r_`i' = `r(newlist)'
				}
					
					
				*save sts list
				sts list, `byby' failure saving("`lmfig_`i''", replace) `stslistopts'
				restore, preserve
			}
			
			*store results from user command in same matrix
			if (`"`usercmd'"' != "") {
				local _r `:all matrices  "_r_*"'
				local _r "`:list sort local _r'"
				local _r `"`:subinstr local _r " " ", ", all'"'
				mat _r = `_r'
				noi di _newline(2) as text "{hline 80}" _newline `"Available results from usercmd: "`usercmd'""'
				noi mat list _r
			}
			
			restore, not
			
			*coalesce data
			use "`lmfig_0'", replace
			
			local epsilon = 1.0x-1b
			
			foreach i of numlist 0 `at' {
				
				foreach level of local by_lvls {
					insobs 1, after(_N)
					replace failure = 0 in l
					replace time = cond(`i' == 0, 0, `i' + `epsilon') in l
					replace `by' = `level' in l
				}
				
				if `i'> 0 append using "`lmfig_`i''"
				
			}
			replace failure=failure*100
			lab var failure "`fail_labvar'"
			
			*separate KM curves per landmark-period and bygroups
			forvalues i = 1/`=`nat'+1' {	//for each `at' (landmark timepoints)
			
				local lb = `:word `i' 		of `atend'' + `epsilon'
				local ub = `:word `=`i'+1'	of `atend'' + `epsilon'
				if (`i'==1) local dis_cond  time <= `ub' & !missing(`ub')
				else		local dis_cond  inrange(time,`lb', `ub')
				
				forvalues j = 1/`nlevels' { //for each `level' (by groups)
					local clevel : word `j' of `by_lvls'
					gen failure`i'`j' = failure if  `dis_cond' & ( (time == `lb' & missing(`by')) | `by' == `clevel')
					replace failure`i'`j' = failure`i'`j'[_n-1] if  failure`i'`j' == 0 & missing(failure`i'`j'[_n+1])
					
				}
			}

	*************   GRAPHING RESULTS AND BUILDING RISKTABLE   ******************
			
			*Build graphing command
			forvalues i = 1/`=`nat'+1' {	//for each `at' (landmark timepoints)

				forvalues j = 1/`nlevels' { //for each `level' (by groups)
					
					if (`j' > 1 | `nlevels' == 1)	local twowaycmd `" || "'

					local lmgraph `lmgraph' `twowaycmd' line failure`i'`j' time, `graphobs' lcolor("`:word `j' of `lcolors''") 
				}
				if (`i' > 1) local lmgraph `lmgraph' xline(`:word `i' of `atend'', lp(shortdash) lc(black)) //add  landmark delimitation vertical line 
			}
			
			
			*Add the risktable to the graph
			if("`risktable'" == "risktable"){
				
				local axisname 1
				forvalues j = 0/`nlevels' {
					local caxis `=`j'+10'
					local axisname `"`axisname' `caxis'"'
					local maxaxes `caxis'
					
					*Remove all axis titles
					local rtopts `rtopts' xtitle("", axis(`caxis'))
					
					*Add risktable scheme to axis
					local rtopts `rtopts' xscale(style(scheme sts_risktable) axis(`caxis'))
						
					if `j'>0 {
						*Add tbl_content: risktables content (numbers) as axis labels
						local rtopts `rtopts' xlabel(`axislab`j'', custom axis(`caxis') `tbl_content_opts' /*labsize(vsmall)*/)
						
						*Add tbl_labels: risktable labels (bygroup names)
						local cbyname : label (`by') `:word `j' of `by_lvls'' 20
						
						if (regexm("`tbl_labels_just'","left")){
							local labeltxt1 `symbol'
							local labeltxt2 `symbol' `cbyname'
						}
						else{
							local labeltxt1 `symbol'
							local labeltxt2 `cbyname' `symbol'
						}
						
						local tbl_label_ico xlabel(`tbl_labels_pos' `"`labeltxt1' "' , axis(`caxis') labcolor("`:word `j' of `lcolors''") `tbl_labels_just' `tbl_labels_opts' add custom)
						
						local tbl_label xlabel(`tbl_labels_pos' `"`labeltxt2' "', axis(`caxis')	add custom norescale `tbl_labels_just' `tbl_labels_opts' labstyle(sts_risktitle))
						
							local rtopts `rtopts' `tbl_label' `tbl_label_ico'
						
					}
					else{
						*Add tbl_title: risktable title (the table name (not an xtitle))
						local rtopts `rtopts' xlabel(`tbl_title_pos' `"Number at risk"', custom norescale labstyle(sts_risktitle) axis(`caxis') `tbl_title_just' `tbl_title_opts') 
					}
				} 
				local rtopts xaxis(`axisname') maxaxes(`maxaxes') `rtopts' xoverhang scale(`scale')
			}
			
			
			
			local lmgraph `"`lmgraph' `rtopts' `xlabel' `ylabel' `options' `options2'"' //add graph options

		}
		
		if "`showcmd'" != "" {
			di as text _newline(2) `"`lmgraph'"'
		} 
		
	************************     DISPLAY GRAPH     *****************************		
		*Execute query
		twoway `lmgraph'
		
		
	}
	

	*drop working frame
	frame change default
	*frame drop frworking
	
	if("`keepplotdata'" != ""){
		frame copy `frworking' sts_graph_data, replace
		di "Plotting data available in frame sts_graph_data"
		
	}
	
end



cap program drop add_fix
program define add_fix, rclass
syntax namelist [, PREFix(string)  SUFfix(string)]
	foreach word of local namelist {
		local newlist "`newlist' `prefix'`word'`suffix'"
	}

	return local newlist = `"`newlist'"'
end


cap program drop remove_non_numeric
program define remove_non_numeric, rclass
*remove any non numeric element (not any character, any element) of list provided and returns a proper numlist
	foreach word in `*' {
		if  regexm("`word'","[^0-9]") == 0 local numlist "`numlist' `word'"
	}

	return local numlist = `"`numlist'"'
end
