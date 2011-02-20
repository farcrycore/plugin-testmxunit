<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="arguments.stParam.bReportPasses" default="false" />
<cfwddx action="wddx2cfml" input="#stObj.details#" output="stLocal.details" />

<cfquery dbtype="query" name="stLocal.qTestPassed">
	select	*
	from	stLocal.details.qTests
	where	result='Passed'
</cfquery>

<cfquery dbtype="query" name="stLocal.qTests">
	select	*
	from	stLocal.details.qTests
	where	result<>'Passed'
</cfquery>

<cfif arguments.stParam.bReportPasses or stLocal.qTests.recordcount>
	<cfoutput>
		<h2 style="font-family:verdana,arial;">Unit Test Results</h1>
		<p style="font-family:verdana,arial;"><span style="font-weight:bold;color:##00BF0D">#stLocal.qTestPassed.recordcount#</span> test/s passed and <span style="font-weight:bold;color:##CC2504">#stLocal.qTests.recordcount#</span> test/s failed. Details about the failed tests are included below.</p>
	</cfoutput>
	<cfoutput query="stLocal.qTests" group="remote">
		<cfif stLocal.qTests.remote>
			<h3 style="font-family:verdana,arial;">Remote Tests</h3>
			<p style="font-family:verdana,arial;">These tests were executed on the web server.</p>
		<cfelse>
			<h3 style="font-family:verdana,arial;">External Tests</h3>
			<p style="font-family:verdana,arial;">These tests were executed externally by making HTTP requests to the web server.</p>
		</cfif>
		<cfoutput group="componentname">
			<h4 style="font-family:verdana,arial;">#stLocal.qTests.componentname#</h4>
			<cfif len(stLocal.qTests.componenthint)><p>#stLocal.qTests.componenthint#</p></cfif>
			<cfoutput>
				<h5 style="font-family:verdana,arial;">#stLocal.qTests.testname# (#stLocal.qTests.result#)</h5>
				<cfif len(stLocal.qTests.testhint)><p>#stLocal.qTests.testhint#</p></cfif>
				<cfif find("<",stLocal.details.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")].message)>
					#stLocal.details.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")].message#
				<cfelse>
					<p style="font-family:verdana,arial;">#stLocal.details.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")].message#</p>
				</cfif>
			</cfoutput>
		</cfoutput>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />