<cfsetting enablecfoutputonly="true" requesttimeout="200000">
<!--- @@displayname: Automated test run --->
<!--- @@fuAlias: testrun --->
<!--- @@viewstack: body --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.isLoggedIn() and not isdefined("url.updateapp") and not url.updateapp eq application.updateappkey>

	<cfoutput>You do not have permission to access this functionality</cfoutput>
	
<cfelse>
	
	<cfif structkeyexists(url,"date")>
		<cfset arguments.stParam.date = url.date />
	</cfif>
	<cfif structkeyexists(arguments.stParam,"date")>
		<cfset stLocal.results = getTestResults(stObject=stObj,date=arguments.stParam.date) />
	<cfelse>
		<cfset stLocal.results = getTestResults(stObject=stObj) />
	</cfif>
	
	<cfset stLocal.html = structnew() />
	<cfset stLocal.html.unitchart = "" />
	<cfset stLocal.html.unitdetails = "" />
	<cfset stLocal.html.linkchart = "" />
	<cfset stLocal.html.linkdetails = "" />
	
	<cfif stObj.bUnitTests and structkeyexists(stLocal.results,"mxTestResultID")>
		<cfsavecontent variable="stLocal.html.unitdetails"><skin:view typename="mxTestResult" objectid="#stLocal.results.mxTestResultID#" webskin="displayBody" bReportPasses="#stObj.bReportPasses#" alternateHTML="" /></cfsavecontent>
		<cfsavecontent variable="stLocal.html.unitchart"><skin:view typename="mxTestResult" objectid="#stLocal.results.mxTestResultID#" webskin="displayChart" bReportPasses="#stObj.bReportPasses#" alternateHTML="" /></cfsavecontent>
	</cfif>
	
	<cfif stObj.bLinkTests and structkeyexists(stLocal.results,"w3LinkTestID")>
		<cfsavecontent variable="stLocal.html.linkdetails"><skin:view typename="w3LinkTest" objectid="#stLocal.results.w3LinkTestID#" webskin="displayBody" bReportPasses="#stObj.bReportPasses#" alternateHTML="" /></cfsavecontent>
		<cfsavecontent variable="stLocal.html.linkchart"><skin:view typename="w3LinkTest" objectid="#stLocal.results.w3LinkTestID#" webskin="displayChart" bReportPasses="#stObj.bReportPasses#" alternateHTML="" /></cfsavecontent>
	</cfif>
	
	<cfif stObj.bReportPasses or len(stLocal.html.unitdetails) or len(stLocal.html.unitdetails) >
		<cfoutput>
			<h1 style="font-family:verdana,arial;">#stObj.title#: Test Results for #dateformat(now(),"full")#</h1>
			<h2 style="font-family:verdana,arial;">Overview</h2>
			<table style="font-family:verdana,arial;">
				<tr>
					<cfif stObj.bUnitTests><td>#stLocal.html.unitchart#</td></cfif>
					<cfif stObj.bLinkTests><td>#stLocal.html.linkchart#</td></cfif>
				</tr>
			</table>
			
			#stLocal.html.unitdetails#
			
			#stLocal.html.linkdetails#
		</cfoutput>
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false" />