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

	
<!--- Get test information --->
<cfset stMXTest = createobject("component",application.stCOAPI.mxTest.packagepath).getByTitle(url.testset) />
<cfset qTests = querynew("id,componentpath,componentname,componenthint,testmethod,testname,testhint") />
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
		<cfloop from="1" to="#arraylen(stMD.functions)#" index="i">
			<cfif stMD.functions[i].name eq thistest>
				<cfif structkeyexists(stMD.functions[i],"displayname")>
					<cfset testtitle = stMD.functions[i].displayname />
				</cfif>
				<cfif structkeyexists(stMD.functions[i],"hint")>
					<cfset testhint = stMD.functions[i].hint />
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
	
	<cfoutput>
		<div class="testresult #qResults.teststatus#">
			<div class="componentname"><a title="#qTests.componenthint#">#qTests.componentname#</a></div>
			<div class="testname"><a title="#qTests.testhint#">#qTests.testname#</a></div>
			<div class="testtime"><cfif qResults.time lt 500>#qResults.time#ms<cfelseif qResults.time lt 61000>#numberformat(qResults.time/1000,"0.9")#s<cfelse>#round(qResults.time/60000)#:#round((qResults.time-60000)/1000)#min</cfif></div>
			<div class="moredetail"><cfif listcontainsnocase("Failed,Error",qResults.teststatus)><a href="##" onclick="jQ('###qTests.id#_#qTests.testmethod# .detail').toggle();return false;"></cfif>#qResults.teststatus#<cfif listcontainsnocase("Failed,Error",qResults.teststatus)> (more detail)</a></cfif></div>
			<br class="clearer" />
			<div class="detail" id="result#qResults.currentrow#">#qResults.error#<cfdump var="#qResults.debug#"></div>
		</div>
	</cfoutput>

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
						.testresult.Waiting { background-color:##666666; }
						.testresult.Passed { background-color:##00BF0D; }
						.testresult.Failed { background-color:##CC2504; }
						.testresult.Error { background-color:##0000A0; }
					
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
				</style>
				
			</head>
			<body>
				<div id="suiteprogressbar">
					<div id="progress" class="progresstext"></div>
				</div>
	</cfoutput>
	
	<skin:htmlHead library="jqueryjs" />
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
						testname:'#qTests.testname#'
					});
				</cfloop>
				
				jQ(function(){
					var testindex = 0;
					var results = { error:0, passed:0, failed:0 };
					
					function displayTestResult(result) {
						jQ("##"+tests[testindex].id+"_"+tests[testindex].testmethod).html(result);
						
						if (result.match("testresult Error"))
							results.error++;
						else if (result.match("testresult Passed"))
							results.passed++;
						else if (result.match("testresult Failed"))
							results.failed++;
						
						testindex++;
						jQ("##progress").animate({ width:(testindex/#qTests.recordcount#*100).toString()+"%" },250,"linear");
						if (testindex<tests.length) getTestResult(testindex); else jQ("##suiteprogressbar").replaceWith("<div id='suitecompleted'>All tests have been completed ("+(results.error ? " <span class='Error'>errors: <span class='count'>"+results.error+"</span></span> " : "")+(results.failed ? " <span class='Failed'>failures: <span class='count'>"+results.failed+"</span> </span>" : "")+(results.passed ? " <span class='Passed'>passes: <span class='count'>"+results.passed+"</span></span> " : "")+")</div>");
					};
					
					function getTestResult(index) {
						testindex = index;
						jQ.ajax({
							success:displayTestResult,
							url:'#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#&suite='+tests[index].componentpath+'&test='+tests[index].testmethod
						});
					};
					
					if (tests.length) {
						getTestResult(0);
					}
				});
			</script>
		</cfoutput>
	</skin:htmlHead>
	
	<cfoutput query="qTests" group="id">
		<div class="component" id="#qTests.id#">
			<cfoutput>
				<div id="#qTests.id#_#qTests.testmethod#">
					<div class="testresult Waiting">
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