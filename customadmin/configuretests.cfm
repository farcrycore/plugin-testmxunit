<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Configure unit tests --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<admin:header />

<!--- Deploy type if it has been requested --->
<cfif structkeyexists(url,"deploy") and url.deploy>
	<cfset createobject("component",application.stCOAPI["mxTest"].packagepath).deployType(btestRun="false") />
	<cflocation url="#cgi.script_name#?#replacenocase(cgi.query_string,'deploy=true','')#" />
</cfif>

<cfset oMXUnit = createobject("component",application.stCOAPI.mxTest.packagepath) />

<cfif oMXUnit.isDeployed()>
	<skin:view stObject="#oMXUnit.getByTitle()#" webskin="edit" />
<cfelse>
	<cfoutput>The '<cfif structkeyexists(application.stCOAPI["mxTest"],"displayname")>#application.stCOAPI["mxTest"].displayname#<cfelse>#listlast(application.stCOAPI["mxTest"].name,'.')#</cfif>' content type has not been deployed yet. Click <a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&deploy=true">here</a> to deploy it now.</cfoutput>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />