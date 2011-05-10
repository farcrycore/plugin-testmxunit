<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Var Scoper Results --->

<cfset stLocal.q = arguments.stParam.qResult />

<cfoutput query="stLocal.q" group="filename">
	<div style="font-size:130%;font-weight:bold;">#stLocal.q.filename#</div>
	<cfoutput group="function">
		<div style="font-size:117%;font-weight:bold;margin-left:20px;">#stLocal.q.function#</div>
		<ul style="padding-left:20px;margin-left:20px;margin-bottom:20px;">
		<cfoutput group="variable">
			<li style="list-style:disc outside none;"><span style="font-weight:bold;">#stLocal.q.variable#</span>
			<cfoutput><br><span style="font-family:courier;">#stLocal.q.linenumber#: #htmleditformat(stLocal.q.context)#</span></cfoutput>
			</li>
		</cfoutput>
		</ul>
	</cfoutput>
</cfoutput>

<cfsetting enablecfoutputonly="false" />