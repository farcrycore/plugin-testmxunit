<cfsetting enablecfoutputonly="true" /> 
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License:
	
--->
<!--- @@displayname: --->
<!--- @@description: displayPageStandard --->
<!--- @@author: Rob Rohan on 2008-12-31 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.testset" default="Automatic" />
<cfparam name="url.suite" default="" />
<cfparam name="url.test" default="" />
<cfparam name="url.format" default="html" />
	
<!--- Get test information --->
<cfset stMXTest = createobject("component",application.stCOAPI.mxTest.packagepath).getByTitle(url.testset) />
<cfset qTests = querynew("id,componentpath,componentname,componenthint,testmethod,testname,testhint,testdependson") />
<cfset stTests = structnew() />
<cfloop list="#stMXTest.tests#" index="testpath">
	<cfset oTest = createobject("component",testpath) />
	<cfset stMD = getMetadata(oTest) />
	
	<cfif structkeyexists(stMD,"displayname")>
		<cfset componentname = stMD.displayname />
	<cfelse>
		<cfset componentname = listlast(stMD.fullname,".") />
	</cfif>
	
	<cfif structkeyexists(stMD,"hint")>
		<cfset componenthint = stMD.hint />
	<cfelse>
		<cfset componenthint = "" />
	</cfif>
	
	<cfset stTests[testpath] = createobject("component",testpath) />
	
	<cfloop list="#arraytolist(oTest.getRunnableMethods())#" index="thistest">
		<cfset testtitle = thistest />
		<cfset testhint = "" />
		<cfset testdependson = "" />
		<cfloop from="1" to="#arraylen(stMD.functions)#" index="i">
			<cfif stMD.functions[i].name eq thistest>
				<cfif structkeyexists(stMD.functions[i],"displayname")>
					<cfset testtitle = stMD.functions[i].displayname />
				</cfif>
				<cfif structkeyexists(stMD.functions[i],"hint")>
					<cfset testhint = stMD.functions[i].hint />
				</cfif>
				<cfif structkeyexists(stMD.functions[i],"dependson")>
					<cfset testdependson = stMD.functions[i].dependson />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfset queryaddrow(qTests) />
		<cfset querysetcell(qTests,"id",replace(testpath,".","","ALL")) />
		<cfset querysetcell(qTests,"componentpath",testpath) />
		<cfset querysetcell(qTests,"componentname",componentname) />
		<cfset querysetcell(qTests,"componenthint",componenthint) />
		<cfset querysetcell(qTests,"testmethod",thistest) />
		<cfset querysetcell(qTests,"testname",testtitle) />
		<cfset querysetcell(qTests,"testhint",testhint) />
		<cfset querysetcell(qTests,"testdependson",testdependson) />
	</cfloop>
</cfloop>


<cfif len(url.suite) and len(url.test)>

	<cfset testSuite = createObject("component","mxunit.framework.TestSuite").TestSuite() />
	
	<cfset testSuite.add(url.suite,url.test,stTests[url.suite]) />
	
	<cfset results = testSuite.run(testMethod=url.test) />
	<cfset qResults = results.getResultsOutput('query') /><!--- html | extjs | xml | junitxml | query | array --->
	
	<cfquery dbtype="query" name="qTests">
		select		*
		from		qTests
		where		componentpath='#url.suite#' and testmethod='#url.test#'
	</cfquery>
	
	<cfswitch expression="#url.format#">
		<cfcase value="html">
			<cfoutput>
				<div class="testresult #qResults.teststatus#">
					<div class="componentname"><a title="#qTests.componenthint#">#qTests.componentname#</a></div>
					<div class="testname"><a title="#qTests.testhint#">#qTests.testname#</a></div>
					<div class="testtime"><cfif qResults.time lt 500>#qResults.time#ms<cfelseif qResults.time lt 61000>#numberformat(qResults.time/1000,"0.9")#s<cfelse>#round(qResults.time/60000)#:#round((qResults.time-60000)/1000)#min</cfif></div>
					<div class="moredetail"><cfif listcontainsnocase("Failed,Error",qResults.teststatus)><a href="##" onclick="$j('###qTests.id#_#qTests.testmethod# .detail').toggle();return false;"></cfif>#qResults.teststatus#<cfif listcontainsnocase("Failed,Error",qResults.teststatus)> (more detail)</a></cfif></div>
					<br class="clearer" />
					<div class="detail" id="result#qResults.currentrow#">#qResults.error#<cfdump var="#qResults.debug#"></div>
				</div>
			</cfoutput>
		</cfcase>
		<cfcase value="xml">
			<cfsavecontent variable="xmlout">
				<cfoutput>
					<?xml version="1.0" encoding="utf-8" ?>
					<testresult id="#qTests.id#_#qTests.testmethod#">
						<status>#qResults.teststatus#</status>
						<time>#qResults.time#</time>
						<details><![CDATA[<cfif listcontainsnocase("Failed,Error",qResults.teststatus)>#qResults.error#</cfif>]]></details>
					</testresult>
				</cfoutput>
			</cfsavecontent>
			
			<cfcontent type="text/xml" reset="true" variable="#tobinary(tobase64(trim(xmlout)))#" />
		</cfcase>
	</cfswitch>

<cfelse>
	
	<cfquery dbtype="query" name="qTests">
		select		*
		from		qTests
		order by	componentname asc, testname asc
	</cfquery>
	
	<cfoutput>
		<html>
			<head>
				<title>#stMXTest.title# Results</title>
				<style type="text/css">
					.component { margin-bottom: 15px; }
					
					.testresult { margin:5px; padding:5px; font-family:helvetica,arial; color:##FFFFFF; }
						.testresult.Waiting { background-console.log("<a href='##' onclick='$j(\"##"+test[index].id+"_"+test[index].testmethod+" .detail\").toggle();return false;'>Dependency failure</a>");color:##666666; }
						.testresult.Passed { background-color:##00BF0D; }
						.testresult.Failed { background-color:##CC2504; }
						.testresult.Error { background-color:##0000A0; }
						.testresult.Unrunnable { background-color:##FFA500; }
					
					.componentname { float:left; font-weight:bold; width: 20%; }
					.testname { float:left; width:55%; }
					.testtime { float:left; width: 10%; }
					.moredetail { float:left; width:15%; text-align:right; }
						.moredetail a { color:##FFFFFF; text-decoration:none; }
						.moredetail a:hover { text-decoration:underline; }
					
					.detail { float:none; display:none; background-color:##FFFFFF; margin-top:5px; padding:5px; color:##000; }
					
					.clearer { float:none; clear:both; }
					
					##suiteprogressbar { margin:15px 5px; border:1px ##CCCCCC solid; }
						##progress { height:20px; width:0px; margin:0px; color:##FFFFFF; background:yellow url(#application.url.webroot#/mxunit/images/progress.png); overflow:hidden; white-space:nowrap; }
					
					##suitecompleted { margin:15px 5px; border:1px ##CCCCCC solid; padding:0; text-align:center; font-family:helvetica,arial; font-weight:bold; }
						##suitecompleted .Error { color:##0000A0; }
						##suitecompleted .Failed { color:##CC2504; }
						##suitecompleted .Passed { color:##00BF0D; }
						##suitecompleted .Unrunnable { color:##FFA500; }
				</style>
				
			</head>
			<body>
				<div id="suiteprogressbar">
					<div id="progress" class="progresstext"></div>
				</div>
	</cfoutput>
	
	<skin:loadJS id="jquery" />
	<skin:htmlHead>
		<cfoutput>
			<script type="text/javascript">
				var tests = [ ];
				<cfloop query="qTests">
					tests.push({
						id:'#qTests.id#',
						componentpath:'#qTests.componentpath#',
						componentname:'#qTests.componentname#',
						testmethod:'#qTests.testmethod#',
						testname:'#qTests.testname#',
						testdependson:'#qTests.testdependson#',
						result:0 // -3:unrunnable,-2:error,-1:failure,0:waiting,1:success
					});
				</cfloop>
				
					var testindex = 0;
					var results = { error:0, passed:0, failed:0, dependencyfailures:0 };
					
					function isTestReady(index,killwaiting){
						if (tests[index].result!==0) return 0; // don't run a test twice
						if (tests[index].testdependson=="")	return 1; // if there aren't dependencies, run now
						
						var dependencies = tests[index].testdependson.split(",");
						for (var i=0;i<dependencies.length;i++){
							var testfound = false;
							for (var j=0;j<tests.length;j++){
								if (tests[j].componentpath==tests[index].componentpath && tests[j].testmethod==dependencies[i]){
									if (tests[j].result==0) { // dependency hasn't been run: not ready
										if (killwaiting) {
											tests[index].result = -3;
											$j("##"+tests[index].id+"_"+tests[index].testmethod+" .testresult").removeClass("Waiting").addClass("Unrunnable");
											$j("##"+tests[index].id+"_"+tests[index].testmethod+" .moredetail").html("<a href='##' onclick='$j(\"##"+tests[index].id+"_"+tests[index].testmethod+" .detail\").toggle();return false;'>Dependency failure</a>");
											$j("##"+tests[index].id+"_"+tests[index].testmethod+" .detail").html("Circular dependencies");
											results.dependencyfailures++;
										}
										return -3;
									}
									if (tests[j].result<0) { // dependency failed: update this test and return not ready
										tests[index].result = -3;
										$j("##"+tests[index].id+"_"+tests[index].testmethod+" .testresult").removeClass("Waiting").addClass("Unrunnable");
										$j("##"+tests[index].id+"_"+tests[index].testmethod+" .moredetail").html("<a href='##' onclick='$j(\"##"+tests[index].id+"_"+tests[index].testmethod+" .detail\").toggle();return false;'>Dependency failure</a>");
										$j("##"+tests[index].id+"_"+tests[index].testmethod+" .detail").html("This test depends on ["+tests[j].testname+"], which failed.");
										results.dependencyfailures++;
										return -2;
									}
									testfound = true;
								}
							}
							if (!testfound) { // dependency doesn't exist: update this test and return not ready
								tests[index].result = -3;
								$j("##"+tests[index].id+"_"+tests[index].testmethod+" .testresult").removeClass("Waiting").addClass("Unrunnable");
								$j("##"+tests[index].id+"_"+tests[index].testmethod+" .moredetail").html("<a href='##' onclick='$j(\"##"+tests[index].id+"_"+tests[index].testmethod+" .detail\").toggle();return false;'>Dependency failure</a>");
								$j("##"+tests[index].id+"_"+tests[index].testmethod+" .detail").html("This test depends on ["+tests[j].testname+"], which is not defined.");
								results.dependencyfailures++;
								return -1;
							}
						}
						
						return 1; // can only get here after finding, and finding successfull, all of the dependencies
					};
					
					function getNextTest() {
						for (var d=0;d<5;d++) { // handle recursive dependecies
							for (var i=0;i<tests.length;i++){
								testready = isTestReady(i,d==4);
								if (tests[i].result==0 && testready>0) return i;
							}
						}
						return -1; // no tests left
					};
					
					function displayTestResult(result) {
						$j("##"+tests[testindex].id+"_"+tests[testindex].testmethod).html(result);
						
						if (result.match("testresult Error")) {
							results.error++;
							tests[testindex].result = -2;
						}
						else if (result.match("testresult Passed")) {
							results.passed++;
							tests[testindex].result = 1;
						}
						else if (result.match("testresult Failed")) {
							results.failed++;
							tests[testindex].result = -1;
						}
						
						testindex = getNextTest();
						per = (results.error+results.passed+results.failed+results.dependencyfailures)/#qTests.recordcount#*100;
						$j("##progress").animate({ width:per.toString()+"%" },100,"linear");
						if (testindex>-1) getTestResult(testindex); else $j("##suiteprogressbar").replaceWith("<div id='suitecompleted'>All tests have been completed ("+(results.error ? " <span class='Error'>errors: <span class='count'>"+results.error+"</span></span> " : "")+(results.failed ? " <span class='Failed'>failures: <span class='count'>"+results.failed+"</span> </span>" : "")+(results.passed ? " <span class='Passed'>passes: <span class='count'>"+results.passed+"</span></span> " : "")+(results.dependencyfailures ? " <span class='Unrunnable'>dependency failures: <span class='count'>"+results.dependencyfailures+"</span></span> " : "")+")</div>");
					};
					
					function getTestResult(index) {
						testindex = index;
						$j.ajax({
							success:displayTestResult,
							url:'#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#&suite='+tests[index].componentpath+'&test='+tests[index].testmethod
						});
					};
					
				$j(function(){
					getTestResult(getNextTest());
				});
			</script>
		</cfoutput>
	</skin:htmlHead>
	
	<cfoutput query="qTests" group="id">
		<div class="component" id="#qTests.id#">
			<cfoutput>
				<div id="#qTests.id#_#qTests.testmethod#">
					<div class="testresult Waiting">
						<input type="hidden" name="dependson" value="#qTests.testdependson#" />
						<div class="componentname"><a title="#qTests.componenthint#">#qTests.componentname#</a></div>
						<div class="testname"><a title="#qTests.testhint#">#qTests.testname#</a></div>
						<div class="testtime">&nbsp;</div>
						<div class="moredetail">Queued</div>
						<br class="clearer" />
						<div class="detail"></div>
					</div>
				</div>
			</cfoutput>
		</div>
	</cfoutput>
	
	<cfoutput>
			</body>
		</html>
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false" />
