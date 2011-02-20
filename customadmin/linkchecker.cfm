<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header />

<cfparam name="url.viewreport" default="new" />

<cfset qReports = application.fapi.getContentObjects(typename="w3LinkTest",lProperties="objectid,url,datetimecreated",orderBy="datetimecreated desc",maxRows=10) />

<cfoutput>
	<table style="width:100%;border:0 none;">
		<tr style="border:0 none;">
			<td style="border:0 none;padding:10px;" width="70%" valign="top">
</cfoutput>
<cfif isvalid("uuid",url.viewreport)>
	<skin:view typename="w3LinkTest" objectid="#url.viewreport#" webskin="displayAutoRefreshBody" />
<cfelse>
	<ft:processForm action="Run Check">
		<ft:processFormObjects typename="w3LinkTest" />
		<cfif len(lSavedObjectIDs)>
			<cfset application.fapi.getContentType(typename="w3LinkTest").startTest(objectid=lSavedObjectIDs) />
			<cflocation url="#application.fapi.fixURL(addValues='viewreport=#lSavedObjectIDs#')#" addtoken="false" />
		</cfif>
	</ft:processForm>
	
	<ft:form>
		<cfoutput><h1>New Link Check Test</h1></cfoutput>
		<ft:object typename="w3LinkTest" key="liverun" lFields="mxTestID,url,linkDepth" />
		<ft:buttonPanel>
			<ft:button value="Run Check" />
		</ft:buttonPanel>
	</ft:form>
</cfif>
<cfoutput>
			</td>
			<td style="border:0 none;padding:10px;" width="30%" valign="top">
				<a href="#application.fapi.fixURL(addValues='viewreport=new')#">&lt;new test&gt;</a><br>
				<cfloop query="qReports">
					<a href="#application.fapi.fixURL(addValues='viewreport=#qReports.objectid#')#">#timeformat(qReports.datetimecreated,'hh:mmtt')# #dateformat(qReports.datetimecreated,"dd/mm")# - #qReports.url#</a><br>
				</cfloop>
			</td>
		</tr>
	</table>
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="true" />