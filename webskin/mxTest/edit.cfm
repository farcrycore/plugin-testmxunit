<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:processform action="Save Configuration">
	<ft:processformobjects typename="mxTest" />
	<skin:bubble message="Updated tests" />
</ft:processform>

<ft:form>
	<cfoutput><h1>Configure #stObj.title# Tests</h1></cfoutput>
	<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app">
		<ft:object typename="mxTest" stObject="#stObj#" lfields="title,urls,notification,tests" />
	<cfelse>
		<ft:object typename="mxTest" stObject="#stObj#" lfields="notification,tests" />
	</cfif>
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Save Configuration" />
	</ft:farcryButtonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />