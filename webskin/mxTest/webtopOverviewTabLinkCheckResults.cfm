<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Link Check Results --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset stLocal.qResults = application.fapi.getContentObjects(typename="w3LinkTest",lProperties="objectid,datetimecreated,numberOK,numberRedirecting,numberBroken,resultFile",mxTestID_eq=stObj.objectid,orderBy="datetimecreated desc",maxRows=7) />
<cfquery dbtype="query" name="stLocal.qResults">
	select * from stLocal.qResults order by datetimecreated asc
</cfquery>

<skin:loadJS id="jquery" />
<skin:htmlHead><cfoutput>
	<script type="text/javascript">
		function showDetails(d){
			$j('.result-detail').hide();
			$j('##details-'+d.replace(/[^\w]+/g,'-')).show();
		};
	</script>
</cfoutput></skin:htmlHead>

<cfoutput><h2>Test Results</h2></cfoutput>
<cfchart format="png" chartwidth="500" chartheight="400" yaxistitle="Number" xaxistitle="Date" showlegend="true" seriesplacement="stacked" url="javascript:showDetails('$ITEMLABEL$')">
	<cfloop list="numberOK:##00BF0D:Clear Pages,numberRedirecting:##FFA500:Redirecting Links,numberBroken:##CC2504:Broken Links" index="stLocal.thischart">
		<cfchartseries type="bar" serieslabel="#listlast(stLocal.thischart,':')#" seriescolor="#listgetat(stLocal.thischart,2,':')#">
			<cfloop query="stLocal.qResults"><cfchartdata item="#dateformat(stLocal.qResults.datetimecreated[stLocal.qResults.currentrow], 'd mmm')#" value="#stLocal.qResults[listfirst(stLocal.thischart,':')][stLocal.qResults.currentrow]#" /></cfloop>
		</cfchartseries>
	</cfloop>
</cfchart>

<cfloop query="stLocal.qResults">
	<cfoutput>
		<div id="details-#dateformat(stLocal.qResults.datetimecreated, 'd-mmm')#" class="result-detail" style="display:none;">
			<skin:view typename="w3LinkTest" objectid="#stLocal.qResults.objectid#" webskin="displayBody" />
		</div>
	</cfoutput>
</cfloop>

<cfsetting enablecfoutputonly="false" />