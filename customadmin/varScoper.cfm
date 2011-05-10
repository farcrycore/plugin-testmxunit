<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<admin:header />

<cfoutput><h1>Var Scoper</h1></cfoutput>

<ft:form>
	<ft:object typename="varScoper" lFields="locations,types" />
	
	<ft:buttonPanel>
		<ft:button value="Go" />
	</ft:buttonPanel>
</ft:form>

<ft:processform>
	<ft:processformobjects typename="varScoper">
		<cfset oVS = application.fapi.getContentType(typename="varScoper") />
		<cfset qResult = oVS.runVarScoper(argumentCollection=stProperties) />
		<skin:view typename="varScoper" qResult="#qResult#" webskin="adminDisplayResults" />
		<ft:break />
	</ft:processformobjects>
</ft:processform>

<admin:footer />

<cfsetting enablecfoutputonly="false" />