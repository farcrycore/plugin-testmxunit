<cfsetting enablecfoutputonly="true" requesttimeout="10000" />
<!--- @@displayname: Run tests --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not structkeyexists(url,"tests")>
	<cfset qTests = application.fapi.getContentObjects(typename="mxTest",notification_neq="") />
	<cfset url.tests = valuelist(qTests.objectid) />
</cfif>

<cfloop list="#url.tests#" index="thistest">
	<skin:view objectid="#thistest#" typename="mxTest" webskin="displayBodyAutomatedTests" />
</cfloop>

<cfsetting enablecfoutputonly="false" />