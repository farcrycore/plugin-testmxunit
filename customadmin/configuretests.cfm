<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Configure unit tests --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset oMXUnit = createobject("component",application.stCOAPI.mxTest.packagepath) />

<ft:processform action="Save Configuration">
	<ft:processformobjects typename="mxTest" />
</ft:processform>


<admin:header />

<ft:form>
	<cfoutput><h1>Configure Automatic Tests</h1></cfoutput>
	<ft:object typename="mxTest" stObject="#oMXUnit.getByTitle()#" lfields="notification,tests" />
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Save Configuration" />
	</ft:farcryButtonPanel>
</ft:form>

<admin:footer />

<cfsetting enablecfoutputonly="false" />