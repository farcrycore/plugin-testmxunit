<cfsetting enablecfoutputonly="true" requesttimeout="200000">
<!--- @@displayname: Automated test run --->
<!--- @@viewstack: body --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.isLoggedIn() and not isdefined("url.updateapp") and not url.updateapp eq application.updateappkey>
	<cfoutput>You do not have permission to access this functionality</cfoutput>
<cfelse>
	
	<!--- Kick of link checker if that is part of this test --->
	<cfif stObj.bLinkTests>
		<cfset stLocal.oLinkTest = application.fapi.getContentType(typename="w3LinkTest") />
		<cfset stLocal.stLinkTest = stLocal.oLinkTest.getData(objectid=createuuid()) />
		<cfset stLocal.stLinkTest.mxTestID = stObj.objectid />
		<cfset stLocal.stLinkTest.url = listfirst(stObj.urls,"#chr(10)##chr(13)#") />
		<cfset stLocal.stLinkTest.linkDepth = stObj.linkDepth />
		<cfset stLocal.stLinkTest.resultFile = application.stCOAPI.w3LinkTest.stProps.resultFile.metadata.ftDestination & "/" & stLocal.stLinkTest.objectid & ".txt" />
		<cfset stLocal.oLinkTest.setData(stProperties=stLocal.stLinkTest) />
		<cfset stLocal.oLinkTest.startTest(objectid=stLocal.stLinkTest.objectid) />
	</cfif>
	
	<cfif stObj.bUnitTests>
		<cfset url.host = 1 />
		<cfif len(stObj.remoteEndpoint)>
			<cfset stLocal.remoteURL = "#listgetat(stObj.urls,1,'#chr(10)##chr(13)#')#mxunit/runtests.cfm?includeremote=0&format=xml" />
		<cfelse>
			<cfset stLocal.remoteURL = "" />
		</cfif>
		<cfset stLocal.qTests = getTestInformation(stObj,stLocal.remoteURL)>
		
		<cfset stLocal.stResults = structnew() />
		<cfset stLocal.aResults = arraynew(1) />
		<cfquery dbtype="query" name="stLocal.qTests">
			select	*,'' as result
			from	qTests
		</cfquery>
		
		<cfset stLocal.stTestResult = structnew() />
		<cfset stLocal.stTestResult.objectid = createuuid() />
		<cfset stLocal.stTestResult.typename = "mxTestResult" />
		<cfset stLocal.stTestResult.mxTestID = stObj.objectid />
		<cfset stLocal.stTestResult.numberPassed = 0 />
		<cfset stLocal.stTestResult.numberDependency = 0 />
		<cfset stLocal.stTestResult.numberFailed = 0 />
		<cfset stLocal.stTestResult.numberErrored = 0 />
		<cfset stLocal.stTestResult.details = "" />
		
		<cfset stLocal.start = now() />
		<cfloop condition="stLocal.qTests.recordcount neq structcount(stLocal.stResults) and now() lt dateadd('s',99900,stLocal.start)">
			<cfloop query="stLocal.qTests">
				<cfset stLocal.bReady = true />
				<cfloop list="#stLocal.qTests.testdependson#" index="stLocal.dependency">
					<cfif structkeyexists(stLocal.stResults,hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.dependency#"))>
						<cfif stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.dependency#")].status neq "Passed">
							<cfset bReady = false />
							<cfset stLocal.stResult = structnew() />
							<cfset stLocal.stResult.index = stLocal.qTests.currentrow />
							<cfset stLocal.stResult.name = "#stLocal.qTests.componentname#: #stLocal.qTests.testname#" />
							<cfset stLocal.stResult.status = "Dependency failure" />
							<cfset stLocal.stResult.message = "This test depends on a test that failed [#stLocal.dependency#]" />
							<cfset stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")] = stLocal.stResult />
							<cfset arrayappend(stLocal.aResults,stLocal.stResult) />
							<cfset querysetcell(stLocal.qTests,"result",stLocal.stResult.status,stLocal.qTests.currentrow) />
							<cfset stLocal.stTestResult.numberDependency = stLocal.stTestResult.numberDependency + 1 />
							<cfbreak />
						</cfif>
					<cfelse>
						<cfset stLocal.bReady = false />
						<cfbreak />
					</cfif>
				</cfloop>
				<cfif stLocal.bReady>
					<cfhttp url="#application.fapi.fixURL(url=stLocal.qTests.url,addValues='format=xml')#" />
					<cfif cfhttp.statuscode eq "200 Ok">
						<cfif isxml(cfhttp.filecontent)>
							<cfset stLocal.xmlTest = xmlParse(cfhttp.filecontent) />
							<cfset stLocal.stResult = structnew() />
							<cfset stLocal.stResult.index = stLocal.qTests.currentrow />
							<cfset stLocal.stResult.name = "#stLocal.qTests.componentname#: #stLocal.qTests.testname#" />
							<cfset stLocal.stResult.status = stLocal.xmlTest.testresult.status.xmlText />
							<cfset stLocal.stResult.message = stLocal.xmlTest.testresult.details.xmlText />
							<cfset stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")] = stLocal.stResult />
							<cfset arrayappend(stLocal.aResults,stLocal.stResult) />
							<cfset querysetcell(stLocal.qTests,"result",stLocal.stResult.status,stLocal.qTests.currentrow) />
							<cfswitch expression="#stLocal.stResult.status#">
								<cfcase value="Passed">
									<cfset stLocal.stTestResult.numberPassed = stLocal.stTestResult.numberPassed + 1 />
								</cfcase>
								<cfcase value="Failed">
									<cfset stLocal.stTestResult.numberFailed = stLocal.stTestResult.numberFailed + 1 />
								</cfcase>
								<cfcase value="Error">
									<cfset stLocal.stTestResult.numberErrored = stLocal.stTestResult.numberErrored + 1 />
								</cfcase>
							</cfswitch>
						<cfelse>
							<cfset stLocal.stResult = structnew() />
							<cfset stLocal.stResult.index = stLocal.qTests.currentrow />
							<cfset stLocal.stResult.name = "#stLocal.qTests.componentname#: #stLocal.qTests.testname#" />
							<cfset stLocal.stResult.status = "Error" />
							<cfset stLocal.stResult.message = "Result returned from test URL was not valid XML [#application.fapi.fixURL(url=stLocal.qTests.url,addValues='format=xml')#]" />
							<cfset stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")] = stResult />
							<cfset arrayappend(stLocal.aResults,stLocal.stResult) />
							<cfset querysetcell(stLocal.qTests,"result",stLocal.stResult.status,stLocal.qTests.currentrow) />
							<cfset stLocal.stTestResult.numberErrored = stLocal.stTestResult.numberErrored + 1 />
						</cfif>
					<cfelse>
						<cfset stLocal.stResult = structnew() />
						<cfset stLocal.stResult.index = stLocal.qTests.currentrow />
						<cfset stLocal.stResult.name = "#stLocal.qTests.componentname#: #stLocal.qTests.testname#" />
						<cfset stLocal.stResult.status = "Error" />
						<cfset stLocal.stResult.message = "Could not connect to test URL [#application.fapi.fixURL(url=stLocal.qTests.url,addValues='format=xml')#]" />
						<cfset stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")] = stLocal.stResult />
						<cfset arrayappend(stLocal.aResults,stLocal.stResult) />
						<cfset querysetcell(stLocal.qTests,"result",stLocal.stResult.status,stLocal.qTests.currentrow) />
						<cfset stLocal.stTestResult.numberErrored = stLocal.stTestResult.numberErrored + 1 />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfloop query="stLocal.qTests">
			<cfif not structkeyexists(stResults,hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#"))>
				<cfset stLocal.stResult = structnew() />
				<cfset stLocal.stResult.index = stLocal.qTests.currentrow />
				<cfset stLocal.stResult.name = "#stLocal.qTests.componentname#: #stLocal.qTests.testname#" />
				<cfset stLocal.stResult.status = "Error" />
				<cfset stLocal.stResult.message = "Tests timed out before this test could be completed" />
				<cfset stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")] = stResult />
				<cfset arrayappend(stLocal.aResults,stLocal.stResult) />
				<cfset querysetcell(stLocal.qTests,"result",stLocal.stResult.status,stLocal.qTests.currentrow) />
				<cfset stLocal.stTestResult.numberErrored = stLocal.stTestResult.numberErrored + 1 />
			</cfif>
		</cfloop>
		
		<cfwddx action="cfml2wddx" input="#stLocal.aResults#" output="stLocal.stTestResult.details" />
		<cfset application.fapi.getContentType(typename="mxTestResult").setData(stProperties=stLocal.stTestResult) />
		
		<cfquery dbtype="query" name="stLocal.qTestPassed">
			select	*
			from	qTests
			where	result='Passed'
		</cfquery>
		
		<cfquery dbtype="query" name="stLocal.qTests">
			select	*
			from	qTests
			where	result<>'Passed'
		</cfquery>
		
		<cfif not stObj.bReportPasses and stLocal.qTests.recordcount eq 0>
			<cfset stLocal.unittestresulthtml = "" />
		<cfelse>
			<cfsavecontent variable="stLocal.unittestresulthtml">
				<cfoutput>
					<h1>#stObj.title#: Unit Test Results for #dateformat(now(),"full")#</h1>
					<p>#stLocal.qTestPassed.recordcount# test/s passed and #stLocal.qTests.recordcount# test/s failed. Details about the failed tests are included below.</p>
				</cfoutput>
				<cfoutput query="stLocal.qTests" group="remote">
					<cfif stLocal.qTests.remote>
						<h2>Remote Tests</h2>
						<p>These tests were executed on the web server.</p>
					<cfelse>
						<h2>External Tests</h2>
						<p>These tests were executed externally by making HTTP requests to the web server.</p>
					</cfif>
					<cfoutput group="componentname">
						<h3>#stLocal.qTests.componentname#</h3>
						<cfif len(stLocal.qTests.componenthint)><p>#stLocal.qTests.componenthint#</p></cfif>
						<cfoutput>
							<h4>#stLocal.qTests.testname# (#stLocal.qTests.result#)</h4>
							<cfif len(stLocal.qTests.testhint)><p>#stLocal.qTests.testhint#</p></cfif>
							<cfif find("<",stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")].message)>
								#stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")].message#
							<cfelse>
								<p>#stLocal.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")].message#</p>
							</cfif>
						</cfoutput>
					</cfoutput>
				</cfoutput>
			</cfsavecontent>
			<cfoutput>#stLocal.unittestresulthtml#</cfoutput>
		</cfif>
		
	<cfelse>
		<cfset stLocal.qTests = querynew("empty") />
		<cfset stLocal.unittestresulthtml = "" />
	</cfif>
	
	<!--- If this test include link checking, wait for the process to finish --->
	<cfif stObj.bLinkTests>
		<cfset stLocal.thread = createObject("java", "java.lang.Thread") />
		<cfloop condition="not stLocal.oLinkTest.isTestFinished(stObject=stLocal.stLinkTest)">
			<cfset stLocal.thread.sleep(5000) />
		</cfloop>
		<cfif stLocal.stLinkTest.state neq "Complete">
			<cfset stLocal.stLinkTest = stLocal.oLinkTest.updateTestFromOutput(stObject=stLocal.stLinkTest) />
		</cfif>
		<cfif not stObj.bReportPasses and stLocal.stLinkTest.numberRedirecting eq 0 and stLocal.stLinkTest.numberBroken eq 0>
			<cfset stLocal.linktestresulthtml = "" />
		<cfelse>
			<cfsavecontent variable="stLocal.linktestresulthtml"><skin:view typename="w3LinkTest" objectid="#stLocal.stLinkTest.objectid#" webskin="displayBody" /></cfsavecontent>
			<cfoutput>#stLocal.linktestresulthtml#</cfoutput>
		</cfif> 
	<cfelse>
		<cfset stLocal.linktestresulthtml = "" />
	</cfif>
	
	<cfif len(stLocal.unittestresulthtml) or len(stLocal.linktestresulthtml)>
		<cfoutput>
			<h2>Notifications</h2>
			<ul>
		</cfoutput>
		
		<cfloop list="#stObj.notification#" index="thisnot">
			<cftry>
				<cfmail to="#thisnot#" from="#application.config.general.adminemail#" type="html" subject="#stObj.title#: Test Results for #dateformat(now(),'full')#">
					#stLocal.unittestresulthtml#
					#stLocal.linktestresulthtml#
				</cfmail>
				<cfoutput><li>Notified #thisnot#</li></cfoutput>
				
				<cfcatch>
					<cfoutput><li>Failed to notify #thisnot# (#cfcatch.message#)</li></cfoutput>
				</cfcatch>
			</cftry>
		</cfloop>
		
		<cfoutput></ul></cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />