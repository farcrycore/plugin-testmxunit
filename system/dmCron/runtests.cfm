<cfsetting enablecfoutputonly="true" requesttimeout="1000000" />
<!--- @@displayname: Run tests --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not structkeyexists(url,"tests")>
	<cfset qTests = application.fapi.getContentObjects(typename="mxTest",bAutomated_eq=1) />
	<cfset url.tests = valuelist(qTests.objectid) />
</cfif>

<cfset oTest = application.fapi.getContentType(typename="mxTest") />
<cfloop list="#url.tests#" index="thistest">
	<cfset stTest = oTest.getData(objectid=thistest) />
	<cfif stTest.lastrundate lt createdate(year(now()),month(now()),day(now()))>
		<cfset stTest.lastrundate = now() />
		<cfset oTest.setData(stProperties=stTest) />
		<skin:view stObject="#stTest#" webskin="displayTestRun" r_html="reportHTML" alternateHTML="" />
		<cfif len(reportHTML)>
			<cfoutput>
				<h2>#stTest.title# Notifications</h2>
				<ul>
			</cfoutput>
			
			<cfloop list="#stTest.notification#" index="thisnot">
				<cftry>
					<cfmail to="#thisnot#" from="#application.config.general.adminemail#" type="html" subject="#stTest.title#: Test Results for #dateformat(stTest.lastrundate,'full')#">#reportHTML#</cfmail>
					<cfoutput><li>Notified #thisnot#</li></cfoutput>
					
					<cfcatch>
						<cfoutput><li>Failed to notify #thisnot# (#cfcatch.message#)</li></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			
			<cfoutput></ul></cfoutput>
		<cfelse>
			<cfoutput><h2>#stTest.title# - No results</h2></cfoutput>
		</cfif>
	</cfif>
</cfloop>

<cfsetting enablecfoutputonly="false" />