<cfsetting enablecfoutputonly="true" />
<!--- @@cacheStatus: -1 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset setLock(stObj=stObj,locked=true) />
			
<cfif structkeyexists(url,"iframe")>
	<cfset onExitProcess = structNew() />
	<cfset onExitProcess.Type = "HTML" />
	<cfsavecontent variable="onExitProcess.content">
		<cfoutput>
			<script type="text/javascript">
				<!--- parent.location.reload(); --->
				parent.location = parent.location;
				parent.closeDialog();		
			</script>
		</cfoutput>
	</cfsavecontent>
</cfif>

<ft:processForm action="Save" Exit="true">
	<ft:processFormObjects typename="#stobj.typename#" />
	<cfset setLock(objectid=stObj.objectid,locked=false) />
</ft:processForm>

<ft:processForm action="Cancel" Exit="true" >
	<cfset setLock(objectid=stObj.objectid,locked=false) />
</ft:processForm>

<ft:form>
	<cfoutput><h1>Configure #stObj.title# Tests</h1></cfoutput>
	<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app">
		<ft:object typename="mxTest" stObject="#stObj#" lfields="title,urls,tests,remoteEndpoint" Legend="Test Case" />
	<cfelse>
		<ft:object typename="mxTest" stObject="#stObj#" lfields="tests" Legend="Test Case" />
	</cfif>
	<ft:object typename="mxTest" stObject="#stObj#" lfields="bAutomated,notification" Legend="Automation" />
	<ft:buttonPanel>
		<ft:button value="Save" />
		<ft:button value="Cancel" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />