<cfsetting enablecfoutputonly="true" />

<cfparam name="arguments.stParam.style" default="" />

<cfoutput><img src="http://#cgi.http_host##getTestChart(stObject=stObj)#" alt="Link Test Chart" width="360px" height="285px" style="#arguments.stParam.style#"></cfoutput>

<cfsetting enablecfoutputonly="false" />