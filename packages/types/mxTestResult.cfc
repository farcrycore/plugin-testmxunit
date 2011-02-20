<cfcomponent displayname="Test Result" hint="The results from a automatic test run" extends="farcry.core.packages.types.types" output="false">
	<cfproperty ftSeq="1" ftFieldSet="Test Result" ftLabel="Test Case"
				name="mxTestID" type="uuid"
				ftJoin="mxTest" ftRenderType="list" />
	<cfproperty ftSeq="2" ftFieldSet="Test Result" ftLabel="Pass"
				name="numberPassed" type="numeric" ftType="integer" />
	<cfproperty ftSeq="3" ftFieldSet="Test Result" ftLabel="Dependency failure"
				name="numberDependency" type="numeric" ftType="integer" />
	<cfproperty ftSeq="4" ftFieldSet="Test Result" ftLabel="Failed"
				name="numberFailed" type="numeric" ftType="integer" />
	<cfproperty ftSeq="5" ftFieldSet="Test Result" ftLabel="Error"
				name="numberErrored" type="numeric" ftType="integer" />
	<cfproperty ftSeq="6" ftFieldSet="Test Result" ftLabel="Details"
				name="details" type="longchar" />
	
	<cffunction name="ftEditDetails" access="public" returntype="string" description="This will return a string of formatted HTML text to enable the editing of the property" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		<cfset var wddxDetails = "" />
		
		<cfif len(arguments.stMetadata.value) and isxml(arguments.stMetadata.value)>
			<cfwddx action="wddx2cfml" input="#arguments.stMetadata.value#" output="wddxDetails" />
			<cfsavecontent variable="html"><cfdump var="#wddxDetails#" expand="false" label="Result details" /></cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="getTestResult" access="public" returntype="struct" description="Runs tests and returns a new Test Result object" output="false">
		<cfargument name="mxTestID" type="uuid" required="false" />
		<cfargument name="stTest" type="struct" required="false" />
		
		<cfset var remoteURL = "" />
		<cfset var qTests = "" />
		<cfset var stResults = structnew() />
		<cfset var aResults = arraynew(1) />
		<cfset var stTestResult = getData(createuuid()) />
		<cfset var start = now() />
		<cfset var bReady = true />
		<cfset var dependency = true />
		<cfset var xmlTest = "" />
		<cfset var stDetails = structnew() />
		<cfset var oTest = application.fapi.getContentType(typename="mxTest") />
		
		<cfif not structkeyexists(arguments,"stTest")>
			<cfset arguments.stTest = application.fapi.getContentObject(typename="mxTest",objectid=arguments.mxTestID) />
		</cfif>
		
		<cfset url.host = 1 />
		<cfif len(arguments.stTest.remoteEndpoint)>
			<cfset remoteURL = "#listgetat(arguments.stTest.urls,1,'#chr(10)##chr(13)#')#mxunit/runtests.cfm?includeremote=0&format=xml" />
		<cfelse>
			<cfset remoteURL = "" />
		</cfif>
		<cfset qTests = oTest.getTestInformation(arguments.stTest,remoteURL)>
		
		<cfquery dbtype="query" name="qTests">
			select	*,'' as result
			from	qTests
		</cfquery>
		
		<cfset stTestResult.mxTestID = arguments.stTest.objectid />
		<cfset stTestResult.numberPassed = 0 />
		<cfset stTestResult.numberDependency = 0 />
		<cfset stTestResult.numberFailed = 0 />
		<cfset stTestResult.numberErrored = 0 />
		<cfset stTestResult.details = "" />
		
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
							<cfset stResult.name = "#qTests.componentname#: #qTests.testname#" />
							<cfset stResult.status = "Dependency failure" />
							<cfset stResult.message = "This test depends on a test that failed [#dependency#]" />
							<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
							<cfset arrayappend(aResults,stResult) />
							<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
							<cfset stTestResult.numberDependency = stTestResult.numberDependency + 1 />
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
							<cfset stResult.name = "#qTests.componentname#: #qTests.testname#" />
							<cfset stResult.status = xmlTest.testresult.status.xmlText />
							<cfset stResult.message = xmlTest.testresult.details.xmlText />
							<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
							<cfset arrayappend(aResults,stResult) />
							<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
							<cfswitch expression="#stResult.status#">
								<cfcase value="Passed">
									<cfset stTestResult.numberPassed = stTestResult.numberPassed + 1 />
								</cfcase>
								<cfcase value="Failed">
									<cfset stTestResult.numberFailed = stTestResult.numberFailed + 1 />
								</cfcase>
								<cfcase value="Error">
									<cfset stTestResult.numberErrored = stTestResult.numberErrored + 1 />
								</cfcase>
							</cfswitch>
						<cfelse>
							<cfset stResult = structnew() />
							<cfset stResult.index = qTests.currentrow />
							<cfset stResult.name = "#qTests.componentname#: #qTests.testname#" />
							<cfset stResult.status = "Error" />
							<cfset stResult.message = "Result returned from test URL was not valid XML [#application.fapi.fixURL(url=qTests.url,addValues='format=xml')#]" />
							<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
							<cfset arrayappend(aResults,stResult) />
							<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
							<cfset stTestResult.numberErrored = stTestResult.numberErrored + 1 />
						</cfif>
					<cfelse>
						<cfset stResult = structnew() />
						<cfset stResult.index = qTests.currentrow />
						<cfset stResult.name = "#qTests.componentname#: #qTests.testname#" />
						<cfset stResult.status = "Error" />
						<cfset stResult.message = "Could not connect to test URL [#application.fapi.fixURL(url=qTests.url,addValues='format=xml')#]" />
						<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
						<cfset arrayappend(aResults,stResult) />
						<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
						<cfset stTestResult.numberErrored = stTestResult.numberErrored + 1 />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfloop query="qTests">
			<cfif not structkeyexists(stResults,hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#"))>
				<cfset stResult = structnew() />
				<cfset stResult.index = qTests.currentrow />
				<cfset stResult.name = "#qTests.componentname#: #qTests.testname#" />
				<cfset stResult.status = "Error" />
				<cfset stResult.message = "Tests timed out before this test could be completed" />
				<cfset stResults[hash("#qTests.remote#-#qTests.componentname#-#qTests.testmethod#")] = stResult />
				<cfset arrayappend(aResults,stResult) />
				<cfset querysetcell(qTests,"result",stResult.status,qTests.currentrow) />
				<cfset stTestResult.numberErrored = stTestResult.numberErrored + 1 />
			</cfif>
		</cfloop>
		
		<cfset stDetails.stResults = stResults />
		<cfset stDetails.aResults = aResults />
		<cfset stDetails.qTests = qTests />
		<cfwddx action="cfml2wddx" input="#stDetails#" output="stTestResult.details" />
		<cfset setData(stProperties=stTestResult) />
		
		<cfreturn stTestResult />
	</cffunction>
	
	<cffunction name="minArg" access="public" returntype="numeric" output="false">
		<cfset var i = 0 />
		<cfset var mina = "" />
		
		<cfloop from="1" to="#arraylen(arguments)#" index="i">
			<cfif not isnumeric(mina) or mina gt arguments[i]>
				<cfset mina = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfreturn mina />
	</cffunction>
	
	<cffunction name="maxArg" access="public" returntype="numeric" output="false">
		<cfset var i = 0 />
		<cfset var maxa = "" />
		
		<cfloop from="1" to="#arraylen(arguments)#" index="i">
			<cfif not isnumeric(maxa) or maxa lt arguments[i]>
				<cfset maxa = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfreturn maxa />
	</cffunction>
	
	<cffunction name="getTestChart" access="public" returntype="string" description="Returns the chart image path (after downloading it from Google if necessary)" output="false">
		<cfargument name="objectid" type="uuid" required="false" />
		<cfargument name="stObject" type="struct" required="false" />
		
		<cfset var filename = "" />
		<cfset var minr = 0 />
		<cfset var maxr = 0 />
		
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = getData(arguments.objectid) />
		</cfif>
		
		<cfset minr = minArg(arguments.stObject.numberPassed,arguments.stObject.numberDependency,arguments.stObject.numberFailed,arguments.stObject.numberErrored) />
		<cfset maxr = maxArg(arguments.stObject.numberPassed,arguments.stObject.numberDependency,arguments.stObject.numberFailed,arguments.stObject.numberErrored) />
		
		<cfreturn "http://chart.apis.google.com/chart?chs=360x285&cht=p&chco=00BF0D|FFA500|CC2504|0000A0&chd=t:#arguments.stObject.numberPassed#,#arguments.stObject.numberDependency#,#arguments.stObject.numberFailed#,#arguments.stObject.numberErrored#&chds=#minr#,#maxr#&chdl=Passed|Dependency+Failure|Failed|Error&chdlp=b&chma=|5&chtt=Unit+Tests&chts=3A3A3A,17.5" />
	</cffunction>
	
</cfcomponent>