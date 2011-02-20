<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="arguments.stParam.bReportPasses" default="false" />

<cfif arguments.stParam.bReportPasses or stObj.numberRedirecting gt 0 or stLocal.stLinkTest.numberBroken gt 0>
	<cfif stObj.state neq "Complete">
		<cfset stObj = updateTestFromOutput(stObject=stObj) />
	</cfif>
	<cfset stLocal.stReport = parseTestReport(stObject=stObj) />
	
	<cfoutput>
		<h2 style="font-family:verdana,arial;">Link Testing Results</h2>
		<p style="font-family:verdana,arial;"><span style="font-weight:bold;color:##00BF0D">#round(stObj.numberOK)#</span> link/s ok, <span style="font-weight:bold;color:##FFA500">#round(stObj.numberRedirecting)#</span> link/s redirecting, and <span style="font-weight:bold;color:##CC2504">#round(stObj.numberBroken)#</span> links/s broken. Details about the broken and redirecting links below.</p>
	</cfoutput>
	
	<cfoutput><h3 style="font-family:verdana,arial;">Problem Pages</h3></cfoutput>
	
	<cfloop from="1" to="#arraylen(stLocal.stReport.pages)#" index="i">
		<cfif arraylen(stLocal.stReport.pages[i].aLinks)>
			<cfoutput>
				<a href="#stLocal.stReport.pages[i].url#" style="font-weight:bold;font-family:verdana,arial;">#stLocal.stReport.pages[i].url#</a><br>
				<table style="width:100%;margin-left:15px;font-family:verdana,arial;">
			</cfoutput>
			<cfloop from="1" to="#arraylen(stLocal.stReport.pages[i].aLinks)#" index="j">
				<cfoutput><tr><td><a href="#stLocal.stReport.pages[i].aLinks[j].url#">#stLocal.stReport.pages[i].aLinks[j].url#</a></td><td><cfif structkeyexists(stLocal.stReport.pages[i].aLinks[j],"redirect")> -&gt; #stLocal.stReport.pages[i].aLinks[j].redirect#</cfif></td><td>#stLocal.stReport.pages[i].aLinks[j].todo#</td></tr></cfoutput>
			</cfloop>
			<cfoutput></table><br></cfoutput>
		</cfif>
	</cfloop>
	
	<cfoutput>
		<h3 style="font-family:verdana,arial;">Pages in Good Order</h3>
		<table style="width:100%;margin-left:15px;font-family:verdana,arial;">
	</cfoutput>
	<cfloop from="1" to="#arraylen(stLocal.stReport.pages)#" index="i">
		<cfif not arraylen(stLocal.stReport.pages[i].aLinks)>
			<cfoutput><tr><td><a href="#stLocal.stReport.pages[i].url#">#stLocal.stReport.pages[i].url#</a></td></tr></cfoutput>
		</cfif>
	</cfloop>
	<cfoutput></table></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />