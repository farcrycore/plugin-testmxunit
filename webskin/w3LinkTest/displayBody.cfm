<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput><h1><a href="#stObj.url#">#stObj.url#</a> - #timeformat(stObj.datetimecreated,'hh:mmtt')#, #dateformat(stObj.datetimecreated,"d mmmm")#</h1></cfoutput>
<cfif isTestFinished(stObject=stObj)>
	<cfif stObj.state neq "Complete">
		<cfset stObj = updateTestFromOutput(stObject=stObj) />
	</cfif>
	
	<cfset stLocal.stReport = parseTestReport(stObject=stObj) />
	
	<cfoutput><h3>Problem Pages</h3></cfoutput>
	
	<cfloop from="1" to="#arraylen(stLocal.stReport.notok)#" index="i">
		<cfoutput>
			<a href="#stLocal.stReport.notok[i].url#" style="font-weight:bold;">#stLocal.stReport.notok[i].url#</a><br>
			<table style="width:100%;margin-left:15px;">
		</cfoutput>
		<cfloop from="1" to="#arraylen(stLocal.stReport.notok[i].aLinks)#" index="j">
			<cfoutput><tr><td><a href="#stLocal.stReport.notok[i].aLinks[j].url#">#stLocal.stReport.notok[i].aLinks[j].url#</a></td><td><cfif structkeyexists(stLocal.stReport.notok[i].aLinks[j],"redirect")> -&gt; #stLocal.stReport.notok[i].aLinks[j].redirect#</cfif></td><td>#stLocal.stReport.notok[i].aLinks[j].todo#</td></tr></cfoutput>
		</cfloop>
		<cfoutput></table><br></cfoutput>
	</cfloop>
	
	<cfoutput>
		<h3>OK Pages</h3>
		<table style="width:100%;margin-left:15px;">
	</cfoutput>
	<cfloop from="1" to="#arraylen(stLocal.stReport.ok)#" index="i">
		<cfoutput><tr><td><a href="#stLocal.stReport.ok[i]#">#stLocal.stReport.ok[i]#</a></td></tr></cfoutput>
	</cfloop>
	<cfoutput></table></cfoutput>
<cfelse>
	<skin:onReady><cfoutput>
		setTimeout(function(){
			window.location.href=window.location.href;
		},2000);
	</cfoutput></skin:onReady>
	<cfoutput>This test is still running</cfoutput>
</cfif>
	
		
<cfsetting enablecfoutputonly="false" />