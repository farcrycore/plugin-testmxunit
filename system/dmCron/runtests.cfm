<cfsetting enablecfoutputonly="true" requesttimeout="10000" />
<!--- @@displayname: Run tests --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not structkeyexists(url,"tests")>
	<cfset qTests = application.fapi.getContentObjects(typename="mxTest",bAutomated_eq=1) />
	<cfset url.tests = valuelist(qTests.objectid) />
</cfif>

<cfloop list="#url.tests#" index="thistest">
	<skin:view objectid="#thistest#" typename="mxTest" webskin="displayAutomatedTests" />
</cfloop>

<cfsetting enablecfoutputonly="false" />