<cfsetting enablecfoutputonly="true" requesttimeout="1000000" />
<!--- @@displayname: Run tests --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not structkeyexists(url,"tests")>
	<cfset qTests = application.fapi.getContentObjects(typename="mxTest",bAutomated_eq=1) />
	<cfset url.tests = valuelist(qTests.objectid) />
</cfif>

<cfset oTest = application.fapi.getContentType(typename="mxTest") />
<cfloop list="#url.tests#" index="thistest">
	<cfset stTest = oTest.getData(objectid=thistest) />
	<cfif stTest.lastrundate lt dateadd("n",-5,now())>
		<cfset stTest.lastrundate = now() />
		<cfset oTest.setData(stProperties=stTest) />
		<skin:view stObject="#stTest#" webskin="displayAutomatedTests" />
	</cfif>
</cfloop>

<cfsetting enablecfoutputonly="false" />