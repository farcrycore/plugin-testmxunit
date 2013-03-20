<cfsetting enablecfoutputonly="true" />
<!--- @@cacheStatus: -1 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset setLock(stObj=stObj,locked=true) />

<ft:processForm action="Save" url="refresh">
	<ft:processFormObjects typename="#stobj.typename#" />
	<cfset setLock(objectid=stObj.objectid,locked=false) />
</ft:processForm>

<ft:processForm action="Cancel" url="refresh" >
	<cfset setLock(objectid=stObj.objectid,locked=false) />
</ft:processForm>

<ft:form>
	<cfoutput><h1>Configure #stObj.title# Tests</h1></cfoutput>
	<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app">
		<ft:object typename="mxTest" stObject="#stObj#" lfields="title,urls" Legend="Test Case" />
		<ft:object typename="mxTest" stObject="#stObj#" lfields="bUnitTests,tests,remoteEndpoint" Legend="Unit Tests" />
		<ft:object typename="mxTest" stObject="#stObj#" lfields="bLinkTests,linkDepth" Legend="Link Tests" />
	<cfelse>
		<ft:object typename="mxTest" stObject="#stObj#" lfields="tests" Legend="Test Case" />
	</cfif>
	<ft:object typename="mxTest" stObject="#stObj#" lfields="bAutomated,notification,bReportPasses" Legend="Automation" />
	<ft:buttonPanel>
		<ft:button value="Save" />
		<ft:button value="Cancel" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />