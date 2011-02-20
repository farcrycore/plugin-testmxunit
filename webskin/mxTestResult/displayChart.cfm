<cfsetting enablecfoutputonly="true" />

<cfparam name="arguments.stParam.style" default="" />

<cfoutput><img src="#getTestChart(stObject=stObj)#" alt="Unit Test Chart" width="360px" height="285px" style="#arguments.stParam.style#"></cfoutput>

<cfsetting enablecfoutputonly="false" />