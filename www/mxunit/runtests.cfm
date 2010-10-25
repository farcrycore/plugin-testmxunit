<cfsetting enablecfoutputonly="true" requesttimeout="100" /> 
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License:
	
--->
<!--- @@displayname: --->
<!--- @@description: displayPageStandard --->
<!--- @@author: Rob Rohan on 2008-12-31 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.testset" default="" />
<cfparam name="url.suite" default="" />
<cfparam name="url.test" default="" />
<cfparam name="url.host" default="1" />
<cfparam name="url.includeremote" default="1" />
<cfparam name="url.format" default="html" /><!--- html | xml --->

<!--- Get test information --->
<cfset oMX = application.fapi.getContentType(typename="mxTest") />

<cfset qAllTests = application.fapi.getContentObjects(typename="mxTest",lProperties="objectid,title",orderby="title asc") />
<cfif not len(url.testset)>
	<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app">
		<cfset url.testset = qAllTests.objectid[1] />
	<cfelse>
		<cfset url.testset = "Default #application.applicationname#" />
	</cfif>
</cfif>
<cfif isvalid("uuid",url.testset)>
	<cfset stMXTest = oMX.getData(url.testset) />
<cfelseif len(url.testset)>
	<cfset stMXTest = oMX.getByTitle(url.testset) />
</cfif>
<cfif not len(stMXTest.urls)>
	<cfset stMXTest.urls = "http://#cgi.http_host#/" />
</cfif>
<cfset baseurl = listgetat(stMXTest.urls,url.host,"#chr(10)##chr(13)#") />
<cfset request.baseurl = baseurl />

<cfif url.includeremote and len(stMXTest.remoteEndpoint)>
	<cfset remoteURL = "#baseurl#mxunit/runtests.cfm?format=xml&testformat=html" />
<cfelse>
	<cfset remoteURL = "" />
</cfif>
<cfset qTests = oMX.getTestInformation(stMXTest,remoteURL) />
<cfset stTests = oMX.getTestComponents(stMXTest) />

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
					<div class="componentname">
						<cfif url.remote>
							<a title="Test on server" class="ui-icon ui-icon-circlesmall-close" style="float:left;"></a>
						<cfelse>
							<a title="External test" class="ui-icon ui-icon-extlink" style="float:left;"></a>
						</cfif>
						<a title="#qTests.componenthint#">#qTests.componentname#</a>
					</div>
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
					<testresult id="#qTests.id#_#qTests.testmethod#" remote="#url.remote#">
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
		order by	remote asc, componentname asc, testname asc
	</cfquery>
	
	<cfswitch expression="#url.format#">
		<cfcase value="html">
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
								
							##defaultbaseurl { font-family:helvetica,arial; }
						</style>
						
					</head>
					<body>
						<table width="100%">
							<tr>
								<td width="20px">
									<a href="#application.url.webroot#/mxunit/runtests.cfm?testset=#urlencodedformat(stMXTest.title)#&host=#url.host#" class="ui-state-default ui-icon ui-icon-link">Link</a>
								</td>
								<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app" and listlen(stMXTest.urls,"#chr(10)##(chr(13))#")>
									<td width="200px">
										<select id="testset" style="width:100%;" onchange="window.location.href=this.value;">
											<cfloop query="qAllTests">
												<option value="#application.url.webroot#/mxunit/runtests.cfm?testset=#qAllTests.objectid#&host=#url.host#"<cfif url.testset eq qAllTests.objectid> selected</cfif>>#qAllTests.title#</option>
											</cfloop>
										</select>
									</td>
								</cfif>
								<td width="200px">
									<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app" and listlen(stMXTest.urls,"#chr(10)##(chr(13))#") gt 1>
										<select id="baseurl" style="width:100%;" onchange="window.location.href=this.value;">
											<cfloop from="1" to="#listlen(stMXTest.urls,'#chr(10)##(chr(13))#')#" index="thisbaseurl">
												<option value="#application.url.webroot#/mxunit/runtests.cfm?testset=#url.testset#&host=#thisbaseurl#"<cfif thisbaseurl eq url.host> selected</cfif>>#listgetat(stMXTest.urls,thisbaseurl,'#chr(10)##(chr(13))#')#</option>
											</cfloop>
										</select>
									<cfelse>
										<a id="defaultbaseurl" title="#baseurl#">#baseurl#</a>
										<input type="hidden" id="baseurl" value="#baseurl#" />
									</cfif>
								</td>
								<td width="45px">
									<a href="##" id="action-restart" class="ui-state-default ui-icon ui-icon-seek-first" style="float:left;">&nbsp;</a>
									<span style="float:left;">&nbsp;</span>
									<a href="##" id="action-play-pause" class="ui-state-default ui-icon ui-icon-play" style="float:left;">&nbsp;</a>
								</td>
								<td>
									<div id="suiteprogressbar">
										<div id="progress" class="progresstext"></div>
									</div>
								</td>
							</tr>
						</table>
			</cfoutput>
			
			<skin:loadJS id="jquery" />
			<skin:loadJS id="jquery-ui" />
			<skin:loadCSS id="jquery-ui" />
			<skin:htmlHead>
				<cfoutput>
					<script type="text/javascript">
						var tests = [ ];
						<cfloop query="qTests">
							tests.push({
								id:'#qTests.id#',
								remote:#qTests.remote#,
								componentpath:'#qTests.componentpath#',
								componentname:'#qTests.componentname#',
								testmethod:'#qTests.testmethod#',
								testname:'#qTests.testname#',
								testdependson:'#qTests.testdependson#',
								url:'#jsstringformat(qTests.url)#',
								result:0 // -3:unrunnable,-2:error,-1:failure,0:waiting,1:success
							});
						</cfloop>
						
							var testindex = 0;
							var results = { error:0, passed:0, failed:0, dependencyfailures:0 };
							var bRunning = 0;
							var baseurl = "";
							
							function isTestReady(index,killwaiting){
								if (tests[index].result!==0) return 0; // don't run a test twice
								if (tests[index].testdependson=="")	return 1; // if there aren't dependencies, run now
								
								var dependencies = tests[index].testdependson.split(",");
								for (var i=0;i<dependencies.length;i++){
									var testfound = false;
									for (var j=0;j<tests.length;j++){
										if (tests[j].remote==tests[index].remote && tests[j].componentpath==tests[index].componentpath && tests[j].testmethod==dependencies[i]){
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
										//tests[index].result = -3;
										//$j("##"+tests[index].id+"_"+tests[index].testmethod+" .testresult").removeClass("Waiting").addClass("Unrunnable");
										//$j("##"+tests[index].id+"_"+tests[index].testmethod+" .moredetail").html("<a href='##' onclick='$j(\"##"+tests[index].id+"_"+tests[index].testmethod+" .detail\").toggle();return false;'>Dependency failure</a>");
										//$j("##"+tests[index].id+"_"+tests[index].testmethod+" .detail").html("This test depends on ["+tests[j].testname+"], which is not defined.");
										//results.dependencyfailures++;
										//return -1;
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
								if (testindex>-1) 
									getTestResult(testindex); 
								else {
									$j("##suiteprogressbar").replaceWith("<div id='suitecompleted'>All tests have been completed ("+(results.error ? " <span class='Error'>errors: <span class='count'>"+results.error+"</span></span> " : "")+(results.failed ? " <span class='Failed'>failures: <span class='count'>"+results.failed+"</span> </span>" : "")+(results.passed ? " <span class='Passed'>passes: <span class='count'>"+results.passed+"</span></span> " : "")+(results.dependencyfailures ? " <span class='Unrunnable'>dependency failures: <span class='count'>"+results.dependencyfailures+"</span></span> " : "")+")</div>");
									finishTests();
								}
							};
							
							function getTestResult(index) {
								testindex = index;
								if (bRunning){
									$j.ajax({
										success:displayTestResult,
										url:tests[index].url
									});
								}
							};
							
							function playTests(){
								bRunning = 1;
								$j("##action-play-pause").removeClass("ui-icon-play").addClass("ui-icon-pause");
								$j("##baseurl,##testset").attr("disabled",true);
								baseurl = $j("##baseurl").val();
								getTestResult(getNextTest());
							};
							function pauseTests(){
								bRunning = 0;
								$j("##action-play-pause").removeClass("ui-icon-pause").addClass("ui-icon-play");
								$j("##baseurl,##testset").attr("disabled",false);
							};
							function finishTests(){
								bRunning = 0;
								$j("##action-play-pause")
									.removeClass("ui-icon-pause").addClass("ui-icon-play")
									.removeClass("ui-state-default").addClass('ui-state-disabled');
								$j("##baseurl,##testset").attr("disabled",false);
							};
							function resetTests(){
								testindex = 0;
								results = { error:0, passed:0, failed:0, dependencyfailures:0 };
								for (var i=0;i<tests.length;i++)
									tests[i].result = 0;
								
								$("div.testresult").removeClass("Error").removeClass("Passed").removeClass("Failed").removeClass("Unrunnable").addClass("Waiting")
									.find("div.testtime").html("&nbsp;").end()
									.find("div.moredetail").html("Queued").end()
									.find("div.detail").html("").hide().end();
								
								$j("##action-play-pause").removeClass("ui-state-disabled").addClass('ui-state-default');
								
								$("##suitecompleted").replaceWith('<div id="suiteprogressbar"><div id="progress" class="progresstext"></div></div>');
							};
							
						$j(function(){
							
							$j("##action-play-pause").bind("click",function(){
								if (bRunning) pauseTests();	else playTests();
								return false;
							}).hover(function(){
								$(this).removeClass("ui-state-default").addClass("ui-state-hover");
							},function(){
								$(this).removeClass("ui-state-hover").addClass("ui-state-default");
							});
							
							$j.fn.log = function() { console.log(this); return this; };
							
							$j("##action-restart").bind("click",function(){
								if (bRunning) pauseTests();
								resetTests();
								return false;
							}).hover(function(){
								$(this).removeClass("ui-state-default").addClass("ui-state-hover");
							},function(){
								$(this).removeClass("ui-state-hover").addClass("ui-state-default");
							});
							
						});
					</script>
				</cfoutput>
			</skin:htmlHead>
			
			<cfoutput query="qTests" group="id">
				<div class="component" id="#rereplace(qTests.componentname,'[^\w]*','','all')#">
					<cfoutput>
						<div id="#rereplace(qTests.id,'[^\w]*','','all')#_#qTests.testmethod#">
							<div class="testresult Waiting">
								<input type="hidden" name="dependson" value="#qTests.testdependson#" />
								<div class="componentname">
									<cfif qTests.remote>
										<a title="Test on server" class="ui-icon ui-icon-circlesmall-close" style="float:left;"></a>
									<cfelse>
										<a title="External test" class="ui-icon ui-icon-extlink" style="float:left;"></a>
									</cfif>
									<a title="#qTests.componenthint#">#qTests.componentname#</a>
								</div>
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

		</cfcase>
		<cfcase value="xml">
			<cfparam name="url.testformat" default="#url.format#" />
			<cfsavecontent variable="xmlout">
				<cfoutput>
					<?xml version="1.0" encoding="utf-8" ?>
					<testsuite>
				</cfoutput>
				
				<cfoutput query="qTests" group="componentpath">
					<component id="#rereplace(qTests.componentname,'[^\w]*','','all')#">
						<name><![CDATA[#qTests.componentname#]]></name>
						<hint><![CDATA[#qTests.componenthint#]]></hint>
						
						<cfoutput>
							<test id="#qTests.id#_#qTests.testmethod#" dependson="#qTests.testdependson#">
								<name><![CDATA[#qTests.testname#]]></name>
								<hint><![CDATA[#qTests.testhint#]]></hint>
								<url>#xmlformat('#qTests.url#&format=#url.testformat#')#</url>
							</test>
						</cfoutput>
					</component>
				</cfoutput>
				
				<cfoutput>
					</testsuite>
				</cfoutput>
			</cfsavecontent>
			
			<cfcontent type="text/xml" reset="true" variable="#tobinary(tobase64(trim(xmlout)))#" />
		</cfcase>
	</cfswitch>

</cfif>

<cfsetting enablecfoutputonly="false" />
