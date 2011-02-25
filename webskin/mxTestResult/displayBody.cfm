<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="arguments.stParam.bReportPasses" default="false" />
<cfwddx action="wddx2cfml" input="#stObj.details#" output="stLocal.details" />

<cfif isstruct(stLocal.details) and structkeyexists(stLocal.details,"aResults")>
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
			<h2 style="font-family:verdana,arial;">Unit Test Results</h2>
			<p style="font-family:verdana,arial;"><span style="font-weight:bold;color:##00BF0D">#stLocal.qTestPassed.recordcount#</span> test/s passed and <span style="font-weight:bold;color:##CC2504">#stLocal.qTests.recordcount#</span> test/s failed.<cfif stLocal.qTests.recordcount> Details about the failed tests are included below.</cfif></p>
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
				<table style="width:100%;margin-left:15px;font-family:verdana,arial;">
					<tr style="font-weight:bold;"><th>Test</th><th>Result</th><th>Message</th></tr>
					<cfoutput><tr><td>#stLocal.qTests.testname#</td><td>#stLocal.qTests.result#</td><td>#stLocal.details.stResults[hash("#stLocal.qTests.remote#-#stLocal.qTests.componentname#-#stLocal.qTests.testmethod#")].message#</td></tr></cfoutput>
				</table>
			</cfoutput>
		</cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />