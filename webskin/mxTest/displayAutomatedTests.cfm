<cfsetting enablecfoutputonly="true" requesttimeout="2000">
<!--- @@displayname: Automated test run --->

<cfif not application.security.isLoggedIn() and not isdefined("url.updateapp") and not url.updateapp eq application.updateappkey>
	<cfoutput>You do not have permission to access this functionality</cfoutput>
<cfelse>
	
	<cfset url.host = 1 />
	<cfset qTests = getTestInformation(stObj.tests,"#listgetat(stObj.urls,1,'#chr(10)##chr(13)#')#mxunit/runtests.cfm?includeremote=0&format=xml&#stObj.remoteEndpoint#")>
	
	<cfset stResults = structnew() />
	<cfquery dbtype="query" name="qTests">
		select	*,'' as result
		from	qTests
	</cfquery>
	
	<cfset start = now() />
	<cfloop condition="qTests.recordcount neq structcount(stResults) and now() lt dateadd('s',99900,start)">
		<cfloop query="qTests">
			<cfset bReady = true />
			<cfloop list="#qTests.testdependson#" index="dependency">
				<cfif structkeyexists(stResults,hash("#qTests.remote#-#qTests.componentname#-#dependency#"))>
					<cfif stResults[hash("#qTests.remote#-#qTests.componentname#-#dependency#")].status neq "Passed">
						<cfset bReady = false />
						<cfset stResult = structnew() />
						<cfset stResult.index = qTests.currentrow />
						<cfset stResult.status = "Dependency failure" />
						<cfset stResult.message = "This test depends on a test that failed [#dependency#]" />
						<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
						<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
						<cfbreak />
					</cfif>
				<cfelse>
					<cfset bReady = false />
					<cfbreak />
				</cfif>
			</cfloop>
			<cfif bReady>
				<cfhttp url="#application.fapi.fixURL(url=qTests.url,addValues='format=xml')#" />
				<cfif cfhttp.statuscode eq "200 Ok">
					<cfif isxml(cfhttp.filecontent)>
						<cfset xmlTest = xmlParse(cfhttp.filecontent) />
						<cfset stResult = structnew() />
						<cfset stResult.index = qTests.currentrow />
						<cfset stResult.status = xmlTest.testresult.status.xmlText />
						<cfset stResult.message = xmlTest.testresult.details.xmlText />
						<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
						<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
					<cfelse>
						<cfset stResult = structnew() />
						<cfset stResult.index = qTests.currentrow />
						<cfset stResult.status = "Error" />
						<cfset stResult.message = "Result returned from test URL was not valid XML [#application.fapi.fixURL(url=qTests.url,addValues='format=xml')#]" />
						<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
						<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
					</cfif>
				<cfelse>
					<cfset stResult = structnew() />
					<cfset stResult.index = qTests.currentrow />
					<cfset stResult.status = "Error" />
					<cfset stResult.message = "Could not connect to test URL [#application.fapi.fixURL(url=qTests.url,addValues='format=xml')#]" />
					<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
					<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
	
	<cfloop query="qTests">
		<cfif not structkeyexists(stResults,hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#"))>
			<cfset stResult = structnew() />
			<cfset stResult.index = qTests.currentrow />
			<cfset stResult.status = "Error" />
			<cfset stResult.message = "Tests timed out before this test could be completed" />
			<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
			<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
		</cfif>
	</cfloop>
	
	<cfquery dbtype="query" name="qTestPassed">
		select	*
		from	qTests
		where	result='Passed'
	</cfquery>
	
	<cfquery dbtype="query" name="qTests">
		select	*
		from	qTests
		where	result<>'Passed'
	</cfquery>
	
	
	<cfsavecontent variable="resulthtml">
		<cfoutput>
			<h1>#stObj.title#: Test Results for #dateformat(now(),"full")#</h1>
			<p>#qTestPassed.recordcount# test/s passed and #qTests.recordcount# test/s failed. Details about the failed tests are included below.</p>
		</cfoutput>
		<cfoutput query="qTests" group="remote">
			<cfif qTests.remote>
				<h2>Remote Tests</h2>
				<p>These tests were executed on the web server.</p>
			<cfelse>
				<h2>External Tests</h2>
				<p>These tests were executed externally by making HTTP requests to the web server.</p>
			</cfif>
			<cfoutput group="componentname">
				<h3>#qTests.componentname#</h3>
				<cfif len(qTests.componenthint)><p>#qTests.componenthint#</p></cfif>
				<cfoutput>
					<h4>#qTests.testname# (#qTests.result#)</h4>
					<cfif len(qTests.testhint)><p>#qTests.testhint#</p></cfif>
					<cfif find("<",stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")].message)>
						#stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")].message#
					<cfelse>
						<p>#stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")].message#</p>
					</cfif>
				</cfoutput>
			</cfoutput>
		</cfoutput>
	</cfsavecontent>
	
	<cfoutput>
		#resulthtml#
		<h2>Notifications</h2>
		<ul>
	</cfoutput>
	
	<cfloop list="#stObj.notification#" index="thisnot">
		<cftry>
			<cfmail to="#thisnot#" from="#application.config.general.adminemail#" type="html" subject="#stObj.title#: Test Results for #dateformat(now(),'full')#">
				#resulthtml#
			</cfmail>
			<cfoutput><li>Notified #thisnot#</li></cfoutput>
			
			<cfcatch>
				<cfoutput><li>Failed to notify #thisnot# (#cfcatch.message#)</li></cfoutput>
			</cfcatch>
		</cftry>
	</cfloop>
	
	<cfoutput></ul></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />