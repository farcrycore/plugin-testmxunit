<cfcomponent extends="mxunit.framework.TestCase">
	
	<cfset setTestStyle("cfunit")>
	
	<cffunction name="testAssertEquals">
		<cfset assertEquals("my message goes here",1,1)>
	</cffunction>
	
	<cffunction name="testAssertEqualsFailure">
		<cfset assertEquals("my message goes here",1,2)>
	</cffunction>
	
	<cffunction name="testAssertTrue">
		<cfset assertTrue("my message goes here",true)>
	</cffunction>
	
	<cffunction name="testAssertTrueFailure">
		<cfset assertTrue("my message goes here",false)>
	</cffunction>
	
	
</cfcomponent>