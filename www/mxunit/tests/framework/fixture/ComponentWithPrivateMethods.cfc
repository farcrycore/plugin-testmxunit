<cfcomponent extends="ParentWithPrivateMethods">
	
	
	<cffunction name="aPrivateMethod" access="private" returntype="string">
		<cfargument name="arg1" type="string" required="true">
		<cfargument name="arg2" type="string" required="true">
		<cfargument name="sep" type="string" required="false" default="_">
		<cfreturn arg1 & sep & arg2>
	</cffunction>

	<cffunction name="aNoArgPrivateMethod" access="private" returntype="string">
		<cfreturn "boo">
	</cffunction>

	<cffunction name="aPrivateMethodNoRT" access="private">
		<cfset var purpose = "no return type specified">
		<cfreturn purpose>
	</cffunction>

	<cffunction name="aPrivateMethodReturnArray" access="private">
		<cfreturn ArrayNew(1)>
	</cffunction>

	<cffunction name="aPrivateMethodReturnArray2" returntype="array" access="private">
		<cfreturn ArrayNew(1)>
	</cffunction>

	<!--- this will run as constructor code --->
	<cfset this.x = 1>
	<cffunction name="aPrivateVoid" access="private" returntype="void">
		<cfset this.x = 5>
	</cffunction>



</cfcomponent>