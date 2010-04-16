<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Configure unit tests --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<ft:processform action="Save Configuration">
	<ft:processformobjects typename="mxTest" />
</ft:processform>


<admin:header />


<!--- Deploy type if it has been requested --->
<cfif structkeyexists(url,"deploy") and url.deploy>
	<cfset createobject("component",application.stCOAPI["mxTest"].packagepath).deployType(btestRun="false") />
	<cflocation url="#cgi.script_name#?#replacenocase(cgi.query_string,'deploy=true','')#" />
</cfif>

<cfset oAltertype = createobject("component","farcry.core.packages.farcry.alterType") />

<cfif oAltertype.isCFCDeployed(typename="mxTest")>
	<ft:form>
		<cfoutput><h1>Configure Automatic Tests</h1></cfoutput>
		<cfset oMXUnit = createobject("component",application.stCOAPI.mxTest.packagepath) />
		<ft:object typename="mxTest" stObject="#oMXUnit.getByTitle()#" lfields="notification,tests" />
		<ft:farcryButtonPanel>
			<ft:farcryButton value="Save Configuration" />
		</ft:farcryButtonPanel>
	</ft:form>
<cfelse>
	<cfoutput>The '<cfif structkeyexists(application.stCOAPI["mxTest"],"displayname")>#application.stCOAPI["mxTest"].displayname#<cfelse>#listlast(application.stCOAPI["mxTest"].name,'.')#</cfif>' content type has not been deployed yet. Click <a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&deploy=true">here</a> to deploy it now.</cfoutput>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />