<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:processform action="Save Configuration">
	<ft:processformobjects typename="mxTest" />
	<skin:bubble message="Updated tests" />
</ft:processform>

<ft:form>
	<cfoutput><h1>Configure #stObj.title# Tests</h1></cfoutput>
	<cfset oMXUnit = createobject("component",application.stCOAPI.mxTest.packagepath) />
	<ft:object typename="mxTest" stObject="#oMXUnit.getByTitle()#" lfields="notification,tests" />
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Save Configuration" />
	</ft:farcryButtonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />