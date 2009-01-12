<cfcomponent extends="mxunit.framework.TestCase">
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- ////////////////////////////////////////////////////////////////// --->
	
	<cffunction name="passTest" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
		<cfset assertEquals(true,true) />
	</cffunction>
	
	<cffunction name="failTest" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
		<cfset assertEquals("yes", "no") />
	</cffunction>
	
</cfcomponent>