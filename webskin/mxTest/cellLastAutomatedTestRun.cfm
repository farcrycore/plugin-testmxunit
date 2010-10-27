<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Last test run --->

<cfset stLocal.qLatest = application.fapi.getContentObjects(typename="mxTestResult",lProperties="datetimecreated,numberPassed,numberDependency,numberFailed,numberErrored",mxTestID_eq=stObj.objectid,orderby="datetimecreated desc",maxrows=1) />

<cfif stLocal.qLatest.recordcount>
	<cfoutput>#dateformat(stLocal.qLatest.datetimecreated,"d mmm")# ( <cfif stLocal.qLatest.numberPassed><span style="color:##00BF0D;font-weight:bold;" title="Passed">#stLocal.qLatest.numberPassed#</span></cfif> <cfif stLocal.qLatest.numberDependency><span style="color:##FFA500;font-weight:bold;" title="Dependency failure">#stLocal.qLatest.numberDependency#</span></cfif> <cfif stLocal.qLatest.numberFailed><span style="color:##CC2504;font-weight:bold;" title="Failed">#stLocal.qLatest.numberFailed#</span></cfif> <cfif stLocal.qLatest.numberErrored><span style="color:##0000A0;font-weight:bold;" title="Error">#stLocal.qLatest.numberErrored#</span></cfif> )</cfoutput>
<cfelse>
	<cfoutput>N/A</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="true" />