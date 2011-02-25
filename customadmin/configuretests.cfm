<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Configure unit tests --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<admin:header />

<!--- Deploy type if it has been requested --->
<cfif structkeyexists(url,"deploy") and url.deploy>
	<cfset createobject("component",application.stCOAPI["mxTest"].packagepath).deployType(btestRun="false") />
	<cflocation url="#cgi.script_name#?#replacenocase(cgi.query_string,'deploy=true','')#" />
</cfif>

<cfset oMXUnit = createobject("component",application.stCOAPI.mxTest.packagepath) />

<cfif oMXUnit.isDeployed()>
	<cfif isdefined("application.config.testing.mode") and application.config.testing.mode eq "app">
		<ft:processform action="Run Test">
			<cfsetting requesttimeout="100000" />
			<cfset oTest = application.fapi.getContentType(typename="mxTest") />
			<cfset stTest = oTest.getData(objectid=form.selectedObjectID) />
			<cfset stTest.lastrundate = now() />
			<cfset oTest.setData(stProperties=stTest) />
			<skin:view stObject="#stTest#" webskin="displayTestRun" r_html="reportHTML" alternateHTML="" />
			<cfif len(reportHTML)>
				<cfoutput>
					<h2>#stTest.title# Notifications</h2>
					<ul>
				</cfoutput>
				
				<cfloop list="#stTest.notification#" index="thisnot">
					<cftry>
						<cfmail to="#thisnot#" from="#application.config.general.adminemail#" type="html" subject="#stTest.title#: Test Results for #dateformat(stTest.lastrundate,'full')#">#reportHTML#</cfmail>
						<cfoutput><li>Notified #thisnot#</li></cfoutput>
						
						<cfcatch>
							<cfoutput><li>Failed to notify #thisnot# (#cfcatch.message#)</li></cfoutput>
						</cfcatch>
					</cftry>
				</cfloop>
				
				<cfoutput></ul></cfoutput>
			<cfelse>
				<cfoutput><h2>#stTest.title# report was empty</h2></cfoutput>
			</cfif>
		</ft:processform>
		
		<cfset stFilterMetaData = structnew() />
		
		<cfset stFilterMetaData.title.ftValidation = "" />
		<cfset stFilterMetaData.urls.ftValidation = "" />
		<cfset stFilterMetaData.urls.ftDefault = "" />
		<cfset stFilterMetaData.urls.ftDefaultType = "" />
		
		<ft:objectadmin 
			typename="mxTest"
			title="Configure Tests"
			columnList="title,urls,bAutomated,notification" 
			lCustomColumns="Nightly Test Results:cellLastAutomatedTestRun"
			sortableColumns="title"
			lFilterFields="title,urls"
			stFilterMetaData="#stFilterMetaData#"
			sqlorderby="title asc"
			lCustomActions="Run Test"
			plugin="textMXUnit"
			module="customlists/configuretests.cfm" />

	<cfelse>
		<skin:view stObject="#oMXUnit.getByTitle()#" webskin="edit" />
	</cfif>
<cfelse>
	<cfoutput>The '<cfif structkeyexists(application.stCOAPI["mxTest"],"displayname")>#application.stCOAPI["mxTest"].displayname#<cfelse>#listlast(application.stCOAPI["mxTest"].name,'.')#</cfif>' content type has not been deployed yet. Click <a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&deploy=true">here</a> to deploy it now.</cfoutput>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />