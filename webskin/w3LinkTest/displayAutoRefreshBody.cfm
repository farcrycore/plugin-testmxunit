<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif isTestFinished(stObject=stObj)>
	<skin:view stObject="#stObj#" webskin="displayBody" bReportPasses="true" />
<cfelse>
	<cfoutput><h2>Test is still running</h2></cfoutput>
	<skin:onReady><cfoutput>
		setTimeout(function(){
			window.location.href=window.location.href;
		},2000);
	</cfoutput></skin:onReady>
</cfif>
	
		
<cfsetting enablecfoutputonly="false" />