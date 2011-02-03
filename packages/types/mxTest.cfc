<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
	
--->
<!--- @@displayname: --->
<!--- @@Description: --->
<!--- @@Developer: Blair (blair@daemon.com.au) --->
<cfcomponent extends="farcry.core.packages.types.types" displayname="MX Unit Tests" hint="Set of unit tests. I expect this will only be used for configuring the nightly tests.">
	<cfproperty ftSeq="1" ftFieldset="Test" ftWizardstep="Test" ftLabel="Title"
				name="title" type="string" hint="The name of the test set. A set called 'Automatic' should be created automatically"
				ftValidation="required" />
	<cfproperty ftSeq="2" ftFieldset="Test" ftWizardstep="Test" ftLabel="URLs"
				name="urls" type="longchar" ftHint="One URL on each line, listing the base URLs that this test suite can be run against. The first URL will be used for automated tests."
				ftDefault="'http://##cgi.http_host##/'" ftDefaultType="evaluate"
				ftValidation="required" />
	
	<cfproperty ftSeq="11" ftFieldSet="Unit Tests" ftWizardStep="Test" ftLabel="Unit Tests"
				name="bUnitTests" type="boolean" default="1" ftDefault="1" hint="Set to true to run unit tests" />
	<cfproperty ftSeq="12" ftFieldset="Unit Tests" ftWizardstep="Test" ftLabel="Tests"
				name="tests" type="longchar" hint="The tests that are part of the set" />
	<cfproperty ftSeq="13" ftFieldset="Unit Tests" ftWizardstep="Test" ftLabel="Test Suite Endpoint"
				name="remoteEndpoint" type="string" hint="URL for running remote tests on the target server"
				ftHint="There is a link in the top left of the 'Run Tests' page. Copy the query string (the part of the URL after '?') into this field." />
	
	<cfproperty ftSeq="21" ftFeildSet="Broken Link Checking" ftWizardStep="Test" ftLabel="Link Checking"
				name="bLinkTests" type="boolean" default="0" ftDefault="0" hint="Set to true to run link checker" />
	<cfproperty ftSeq="22" ftFieldSet="Broken Link Checking" ftWizardStep="Test" ftLabel="Depth"
				name="linkDepth" type="numeric" ftType="integer" ftDefault="3" ftHint="The number of levels to link check. MUST be 1 or more.">
	
	<cfproperty ftSeq="31" ftFieldset="Automation" ftWizardstep="Test" ftLabel="Run as part of nightly tests"
				name="bAutomated" type="boolean"
				ftHint="If you have automated nightly tests set up, use this flag to indicate whether this test case should be included." />
	<cfproperty ftSeq="32" ftFieldset="Automation" ftWizardstep="Test" ftLabel="Email notification"
				name="notification" type="longchar" hint="The email addresses to send the unit test results"
				ftType="string" ftHint="This is used during automated test runs, not when using the 'Run Tests' option to the right." />
	<cfproperty ftSeq="13" ftFieldset="Automation" ftWizardstep="Test" ftLabel="Report passes"
				name="bReportPasses" type="boolean" default="0" ftDefault="0" 
				ftType="boolean" ftHint="Set to true to report on passed tests" />
	
	<cfproperty name="lastrundate" type="datetime" hint="The last time this test was executed. Used to ensure that it won't accidentally get hit twice." />
	
	<cffunction name="ftEditTests" returntype="string" output="false" access="public" hint="UI for selecting the tests in this set">
		<cfset var location = "" />
		<cfset var qTests = querynew("name,location,path,hint","varchar,varchar,varchar,varchar") />
		<cfset var qTheseTests = querynew("name,location,path,hint","varchar,varchar,varchar,varchar") />
		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app">
			<cfset qTests = getTests("app") />
		<cfelse>
			<cfset qTests = getTests() />
		</cfif>
		
		<skin:loadJS id="jquery" />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<script type="text/javascript">
					function selectTests(selected,location,id) {
						id = id || '';
						$j('input[class^=location'+location+id+']').each(function(i){
							this.checked = selected;
						});
						
						if (id==''){
							// location and test case info work the same way: set to all or none
							$j('a[class^=location'+location+'][class$=info]').each(function(i){
								var cur = $j(this).html().split("/");
								if (selected) cur[0] = parseInt(cur[1]); else cur[0] = 0;
								$j(this).html(''+cur[0]+'/'+cur[1]);
							});
						}
						else {
							// testcase
							var curtc = $j('a.location'+location+id+'info').html().split("/");
							if (selected) curtc[0] = parseInt(curtc[1]); else curtc[0] = 0;
							$j('a.location'+location+id+'info').html(''+curtc[0]+'/'+curtc[1]);
							
							// location
							var $alltc = $j('input[name=#arguments.fieldname#][class^=location'+location+']');
							var $selectedtc = $j('input:checked[name=#arguments.fieldname#][class^=location'+location+']:checked');
							$j('a.location'+location+'info').html(''+$selectedtc.length+'/'+$alltc.length);
						}
						
					};
					function setSelectedLocations(location,total,selected){
						$j('a.location'+location+'info').html(''+selected+'/'+total);
						if (total==selected) $j('##all'+location)[0].checked = true;
					};
					function setSelectedTestCases(location,id,total,selected){
						$j('a.location'+location+id+'info').html(''+selected+'/'+total);
						if (total==selected) $j('input.'+id)[0].checked = true;
					};
					function updateSelectedInfo(selected,location,id){
						// location
						var cur = $j('a.location'+location+'info').html().split("/");
						if (selected) cur[0] = parseInt(cur[0]) + 1; else cur[0] = parseInt(cur[0]) - 1;
						$j('a.location'+location+'info').html(''+cur[0]+'/'+cur[1]);
						
						// testcase
						var cur = $j('a.location'+location+id+'info').html().split("/");
						if (selected) cur[0] = parseInt(cur[0]) + 1; else cur[0] = parseInt(cur[0]) - 1;
						$j('a.location'+location+id+'info').html(''+cur[0]+'/'+cur[1]);
					};
				</script>
				<div class="multiField">
			</cfoutput>
			<cfoutput query="qTests" group="location">
				<cfset locationtotal = 0 />
				<cfset locationselected = 0 />
				
				<label class="testlocation" style="font-weight:bold;text-align:left;">
					<input type="checkbox" name="selectlocation" id="all#qTests.location#" onclick="selectTests(this.checked,'#qTests.location#');" />
					#qTests.locationlabel# 
					<a href="##" class="location#qTests.location#info" onclick="$j('##location#qTests.location#').toggle();return false">0/0</a>
				</label>
				
				<div id="location#qTests.location#" class="group" style="display:none;"><br class="clearer" />
					<cfoutput group="componentpath">
						<cfset testcasetotal = 0 />
						<cfset testcaseselected = 0 />
						
						<label class="testcomponent" style="margin-left:1.5em;text-align:left;">
							<input type="checkbox" name="selecttestcase" class="location#qTests.location# #qTests.id#" value="#qTests.componentpath#" onclick="selectTests(this.checked,'#qTests.location#','#qTests.id#');" />
							#qTests.componentname[qTests.currentrow]#
							<a href="##" title="#qTests.componenthint#" class="location#qTests.location##qTests.id#info" onclick="$j('##location#qTests.location##qTests.id#').toggle();return false">0/0</a>
						</label>
						
						<div id="location#qTests.location##qTests.id#" class="group" style="display:none;"><br class="clearer" />
							<cfoutput>
								<cfif listcontains(arguments.stMetadata.value,"#qTests.componentpath#.#qTests.testmethod#")>
									<cfset testcasetotal = testcasetotal + 1 />
									<cfset testcaseselected = testcaseselected + 1 />
									<cfset locationtotal = locationtotal + 1 />
									<cfset locationselected = locationselected + 1 />
								<cfelse>
									<cfset testcasetotal = testcasetotal + 1 />
									<cfset locationtotal = locationtotal + 1 />
								</cfif>
								
								<label class="test" style="margin-left:3em;text-align:left;">
									<input type="checkbox" name="#arguments.fieldname#" class="location#qTests.location##qTests.id#" value="#qTests.componentpath#.#qTests.testmethod#"<cfif listcontains(arguments.stMetadata.value,"#qTests.componentpath#.#qTests.testmethod#")> checked="true"</cfif> onclick="updateSelectedInfo(this.checked,'#qTests.location#','#qTests.id#');" />
									#qTests.testname[qTests.currentrow]#
								</label>
								
								<cfif len(qTests.testhint)>
									<span class="hint">#qTests.testhint#</span>
								</cfif><br class="clearer" />
							</cfoutput>
							
							<script type="text/javascript">setSelectedTestCases('#qTests.location#','#qTests.id#',#testcasetotal#,#testcaseselected#);</script>
						</div><br class="clearer" />
					</cfoutput>
					
					<script type="text/javascript">setSelectedLocations('#qTests.location#',#locationtotal#,#locationselected#);</script>
				</div><br class="clearer" />
			</cfoutput>
			<cfoutput></div></cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="getTests" returntype="query" output="false" access="public" hint="Returns all the tests for the specified location">
		<cfargument name="mode" type="string" required="false" default="any" hint="Filters results to specific a speicfic testing mode. 'self' indicates a test that can only be run in Self Testing mode, 'app' indicates a test that can only be run in Test Appliance mode, and the default 'any' indicates a test that can be run in any mode." />
		
		<cfset var location = "" />
		<cfset var qTests = querynew("id,location,locationlabel,componentpath,componentname,componenthint,testmethod,testname,testhint,testmode") />
		<cfset var oTest = "" />
		<cfset var stMD = structnew() />
		<cfset var thisMD = structnew() />
		<cfset var componentname = "" />
		<cfset var componenthint = "" />
		<cfset var componentmode = "" />
		<cfset var testtitle = "" />
		<cfset var testhint = "" />
		<cfset var testmode = "" />
		<cfset var testssofar = "" />
		<cfset var testfound = false />
		<cfset var i = 0 />
		
		<cfloop list="core,#application.plugins#,project" index="location">
			<cfset qTestCases = getTestCases(location) />
			
			<cfloop query="qTestCases">
				<cftry>
					<cfset oTest = createobject("component",qTestCases.path) />
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
					
					<cfif structkeyexists(stMD,"mode")>
						<cfset componentmode = stMD.mode />
					<cfelse>
						<cfset componentmode = "any" />
					</cfif>
					
					<cfloop list="#arraytolist(oTest.getRunnableMethods())#" index="thistest">
						<cfset testtitle = thistest />
						<cfset testhint = "" />
						<cfset testfound = false />
						<cfset thisMD = stMD />
						<cfloop condition="not testfound and not findnocase('component',thisMD.name)">
							<cfset i = 1 />
							<cfloop condition="not testfound and i lte arraylen(thisMD.functions)">
								<cfif thisMD.functions[i].name eq thistest>
									<cfif structkeyexists(thisMD.functions[i],"displayname")>
										<cfset testtitle = thisMD.functions[i].displayname />
									</cfif>
									<cfif structkeyexists(thisMD.functions[i],"hint")>
										<cfset testhint = thisMD.functions[i].hint />
									</cfif>
									<cfif structkeyexists(thisMD.functions[i],"mode")>
										<cfset testmode = thisMD.functions[i].mode />
									<cfelse>
										<cfset testmode = componentmode />
									</cfif>
									<cfset testfound = true />
								</cfif>
								<cfset i = i + 1 />
							</cfloop>
							<cfset thisMD = thisMD.extends />
						</cfloop>
						
						<cfset queryaddrow(qTests) />
						<cfset querysetcell(qTests,"id",replace(qTestCases.path,".","","ALL")) />
						<cfset querysetcell(qTests,"location",location) />
						<cfset querysetcell(qTests,"locationlabel",qTestCases.locationlabel) />
						<cfset querysetcell(qTests,"componentpath",qTestCases.path) />
						<cfset querysetcell(qTests,"componentname",componentname) />
						<cfset querysetcell(qTests,"componenthint",componenthint) />
						<cfset querysetcell(qTests,"testmethod",thistest) />
						<cfset querysetcell(qTests,"testname",testtitle) />
						<cfset querysetcell(qTests,"testhint",testhint) />
						<cfset querysetcell(qTests,"testmode",testmode) />
					</cfloop>
					
					<cfcatch>
						<cflog file="testing" text="Error loading #qTestCases.path#">
					</cfcatch>
				</cftry>
			</cfloop>
		</cfloop>
		
		<cfif arguments.mode neq "any">
			<cfquery dbtype="query" name="qTests">
				select		*
				from		qTests
				where		testmode='any' or testmode=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mode#" />
			</cfquery>
		</cfif>
		
		<cfreturn qTests />
	</cffunction>
	
	<cffunction name="getTestCases" returntype="query" output="false" access="public" hint="Returns all the tests for the specified location">
		<cfargument name="location" type="string" required="true" hint="The location to search (core | pluginname | project)" />
		
		<cfset var qFiles = querynew("empty") />
		<cfset var qTests = querynew("location,locationlabel,path","varchar,varchar,varchar") />
		<cfset var stMD = structnew() />
		<cfset var packagepath = "" />
		<cfset var locationlabel = "" />
		<cfset var oManifest = "" />
		
		<cfswitch expression="#location#">
			<cfcase value="core">
				<cfdirectory action="list" directory="#application.path.core#/tests" filter="*.cfc" name="qFiles" />
				<cfset packagepath = "farcry.core.tests." />
				<cfset locationlabel = "Core" />
			</cfcase>
			
			<cfcase value="project">
				<cfdirectory action="list" directory="#application.path.project#/tests" filter="*.cfc" name="qFiles" />
				<cfset packagepath = "farcry.projects.#application.projectdirectoryname#.tests." />
				<cfset locationlabel = "Project" />
			</cfcase>
			
			<cfdefaultcase><!--- plugin --->
				<cfdirectory action="list" directory="#application.path.plugins#/#arguments.location#/tests" filter="*.cfc" name="qFiles" />
				<cfset packagepath = "farcry.plugins.#arguments.location#.tests." />
				<cfif fileexists(expandpath("/farcry/plugins/#arguments.location#/install/manifest.cfc"))>
					<cfset oManifest = createobject("component","farcry.plugins.#arguments.location#.install.manifest") />
					<cfif structkeyexists(oManifest,"name")>
						<cfset locationlabel = oManifest.name />
					<cfelse>
						<cfset locationlabel = arguments.location />
					</cfif>
				<cfelse>
					<cfset locationlabel = arguments.location />
				</cfif>
			</cfdefaultcase>
		</cfswitch>
		
		<cfloop query="qFiles">
			<cfset stMD = getMetadata(createobject("component","#packagepath##listfirst(qFiles.name,'.')#")) />
			
			<cfif not structkeyexists(stMD,"bAbstract") or not stMD.bAbstract>
				<cfset queryaddrow(qTests) />
				<cfset querysetcell(qTests,"location",arguments.location) />
				<cfset querysetcell(qTests,"locationlabel",locationlabel) />
				<cfset querysetcell(qTests,"path","#packagepath##listfirst(qFiles.name,'.')#") />
			</cfif>
		</cfloop>
		
		<cfreturn qTests />
	</cffunction>
	
	<cffunction name="getTestComponents" returntype="struct" output="false" access="public" hint="Returns the components required to run the tests">
		<cfargument name="testcase" type="struct" required="true" hint="MX Unit Tests object" />
		
		<cfset var stTests = structnew() />
		<cfset var componentpath = "" />
		
		<cfloop list="#arguments.testcase.tests#" index="testpath">
			<cfset componentpath = listdeleteat(testpath,listlen(testpath,"."),".") />
			<cfif not structkeyexists(stTests,componentpath)>
				<cfset stTests[componentpath] = createobject("component",componentpath) />
			</cfif>
		</cfloop>
		
		<cfreturn stTests />
	</cffunction>
	
	<cffunction name="getTestInformation" returntype="query" output="false" access="public" hint="Returns information about the specified tests">
		<cfargument name="testcase" type="struct" required="true" hint="MX Unit Tests object" />
		<cfargument name="remoteURL" type="string" required="false" default="" hint="If the endpoint is included, the remote tests are also returned">
		
		<cfset var qTests = querynew("remote,id,componentpath,componentname,componenthint,testmethod,testname,testhint,testdependson,url","bit,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
		<cfset var qRemote = getRemoteTestInformation(arguments.remoteURL & "&includeremote=0&#arguments.testcase.remoteEndpoint#") />
		<cfset var testpath = "" />
		<cfset var componentpath = "" />
		<cfset var oTest = "" />
		<cfset var stMD = "" />
		<cfset var thisMD = "" />
		<cfset var componentname = "" />
		<cfset var componenthint = "" />
		<cfset var thistest = "" />
		<cfset var testtitle = "" />
		<cfset var testdependson = "" />
		<cfset var testhint = "" />
		<cfset var stTests = structnew() />
		<cfset var testfound = false />>
		
		<cfloop list="#arguments.testcase.tests#" index="testpath">
			<cfset componentpath = listdeleteat(testpath,listlen(testpath,"."),".") />
			<cfif not structkeyexists(stTests,componentpath)>
				<cfset stTests[componentpath] = createobject("component",componentpath) />
			</cfif>
			<cfset stMD = getMetadata(stTests[componentpath]) />
			
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
			
			
			<cfloop list="#arraytolist(stTests[componentpath].getRunnableMethods())#" index="thistest">
				<cfif listlast(testpath,".") eq thistest>
					<cfset testtitle = thistest />
					<cfset testhint = "" />
					<cfset testdependson = "" />
					<cfset testfound = false />
					<cfset thisMD = stMD />
					<cfloop condition="not testfound and not findnocase('component',thisMD.name)">
						<cfset i = 1 />
						<cfloop condition="not testfound and i lte arraylen(thisMD.functions)">
							<cfif thisMD.functions[i].name eq thistest>
								<cfif structkeyexists(thisMD.functions[i],"displayname")>
									<cfset testtitle = thisMD.functions[i].displayname />
								</cfif>
								<cfif structkeyexists(thisMD.functions[i],"hint")>
									<cfset testhint = thisMD.functions[i].hint />
								</cfif>
								<cfif structkeyexists(thisMD.functions[i],"dependson")>
									<cfset testdependson = thisMD.functions[i].dependson />
								</cfif>
							</cfif>
							<cfset i = i + 1 />
						</cfloop>
						<cfset thisMD = thisMD.extends />
					</cfloop>
					
					<cfset queryaddrow(qTests) />
					<cfset querysetcell(qTests,"remote",false) />
					<cfset querysetcell(qTests,"id",replace(testpath,".","","ALL")) />
					<cfset querysetcell(qTests,"componentpath",componentpath) />
					<cfset querysetcell(qTests,"componentname",componentname) />
					<cfset querysetcell(qTests,"componenthint",componenthint) />
					<cfset querysetcell(qTests,"testmethod",thistest) />
					<cfset querysetcell(qTests,"testname",testtitle) />
					<cfset querysetcell(qTests,"testhint",testhint) />
					<cfset querysetcell(qTests,"testdependson",testdependson) />
					<cfset querysetcell(qTests,"url","http://#cgi.http_host#/mxunit/runtests.cfm?testset=#arguments.testcase.objectid#&suite=#componentpath#&test=#thistest#&host=#url.host#&ajaxmode=1&remote=0") />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfquery dbtype="query" name="qTests">
			select * from qTests
			union
			select * from qRemote
		</cfquery>
		
		<cfreturn qTests />
	</cffunction>
	
	<cffunction name="getRemoteTestInformation" returntype="query" output="false" access="public" hint="Returns information about the specified remote tests">
		<cfargument name="remoteURL" type="string" required="true" hint="The URL to retrieve test information from" />
		
		<cfset var cfhttp = structnew() />
		<cfset var qTests = querynew("remote,id,componentpath,componentname,componenthint,testmethod,testname,testhint,testdependson,url","bit,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
		<cfset var xmlResult = structnew() />
		<cfset var thiscomponent = "" />
		<cfset var thistest = "" />
		
		<cfhttp url="#arguments.remoteURL#" />
		
		<cfif cfhttp.StatusCode eq "200 Ok">
			<cfset xmlResult = xmlParse(cfhttp.filecontent) />
			<cfif structkeyexists(xmlResult.testsuite,"component")>
				<cfloop from="1" to="#arraylen(xmlResult.testsuite.component)#" index="thiscomponent">
					<cfloop from="1" to="#arraylen(xmlResult.testsuite.component[thiscomponent].test)#" index="thistest">
						<cfset queryaddrow(qTests) />
						<cfset querysetcell(qTests,"remote",true) />
						<cfset querysetcell(qTests,"id",xmlResult.testsuite.component[thiscomponent].test[thistest].xmlAttributes.id) />
						<cfset querysetcell(qTests,"componentpath",xmlResult.testsuite.component[thiscomponent].xmlAttributes.id) />
						<cfset querysetcell(qTests,"componentname",xmlResult.testsuite.component[thiscomponent].name.xmlText) />
						<cfset querysetcell(qTests,"componenthint",xmlResult.testsuite.component[thiscomponent].hint.xmlText) />
						<cfset querysetcell(qTests,"testmethod",listlast(xmlResult.testsuite.component[thiscomponent].test[thistest].xmlAttributes.id,"_")) />
						<cfset querysetcell(qTests,"testname",xmlResult.testsuite.component[thiscomponent].test[thistest].name.xmlText) />
						<cfset querysetcell(qTests,"testhint",xmlResult.testsuite.component[thiscomponent].test[thistest].hint.xmlText) />
						<cfset querysetcell(qTests,"testdependson",xmlResult.testsuite.component[thiscomponent].test[thistest].xmlAttributes.dependson) />
						<cfset querysetcell(qTests,"url",application.fapi.fixURL(url=xmlResult.testsuite.component[thiscomponent].test[thistest].url.xmlText,addValues="remote=1")) />
					</cfloop>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn qTests />
	</cffunction>
	
	<cffunction name="getByTitle" returntype="struct" output="false" access="public" hint="Returns the automatic object">
		<cfargument name="title" type="string" required="false" default="Default #application.applicationname#" hint="The name of the test set to retrieve. By default the Automatic set is retrieved." />
		
		<cfset var qResult = querynew("empty") />
		<cfset var stObj = structnew() />
		
		<cfquery datasource="#application.dsn#" name="qResult">
			select	objectid
			from	#application.dbowner#mxTest
			where	title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#" />
		</cfquery>
		
		<cfif qResult.recordcount>
			<cfreturn getData(objectid=qResult.objectid) />
		<cfelse>
			<cfset stObj = getData(objectid=createuuid()) />
			<cfset stObj.title = arguments.title />
			<cfset stObj.notification = application.config.general.adminemail />
			<cfset setData(stProperties=stObj) />
			
			<cfreturn stObj />
		</cfif>
	</cffunction>
	
</cfcomponent>
