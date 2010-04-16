<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<!--- Deploy type if it has been requested --->
<cfif structkeyexists(url,"deploy") and url.deploy>
	<cfset createobject("component",application.stCOAPI["mxTest"].packagepath).deployType(btestRun="false") />
	<cflocation url="#cgi.script_name#?#replacenocase(cgi.query_string,'deploy=true','')#" />
</cfif>

<cfset oAltertype = createobject("component","farcry.core.packages.farcry.alterType") />

<cfif oAltertype.isCFCDeployed(typename="mxTest")>
	<cfinclude template="/farcry/plugins/testMXUnit/www/mxunit/runtests.cfm" />
<cfelse>
	<admin:header />
	<cfoutput>The '<cfif structkeyexists(application.stCOAPI["mxTest"],"displayname")>#application.stCOAPI["mxTest"].displayname#<cfelse>#listlast(application.stCOAPI["mxTest"].name,'.')#</cfif>' content type has not been deployed yet. Click <a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&deploy=true">here</a> to deploy it now.</cfoutput>
	<admin:footer />
</cfif>