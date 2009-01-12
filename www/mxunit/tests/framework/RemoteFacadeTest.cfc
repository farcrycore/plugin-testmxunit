<cfcomponent extends="mxunit.framework.TestCase">
	<cfset rf = createObject("component","mxunit.framework.RemoteFacade")>

	<cffunction name="testPing" returntype="void" hint="">
		<cfset var b = rf.ping()>
		<cfset assertTrue(b,"should be true")>
	</cffunction>

	<cffunction name="testGetComponentMethods">
		<cfset var a_methods = rf.getComponentMethods("mxunit.PluginDemoTests.EmptyTest")>
		<cfset assertEquals(0,ArrayLen(a_methods),"should be 0 runnable methods in EmptyTest")>
		<cfset a_methods = rf.getComponentMethods("mxunit.PluginDemoTests.SingleMethodTest")>
		<cfset assertEquals(1,ArrayLen(a_methods),"should be one runnable method in SingleMethodTest")>
		<cfset a_methods = rf.getComponentMethods("mxunit.PluginDemoTests.DoubleMethodTest")>
		<cfset assertEquals(2,ArrayLen(a_methods),"should be 2 runnable methods in DoubleMethodTest")>
	</cffunction>


	<cffunction name="testExecuteTestCase" returntype="void" hint="">
		<cfset var name = "mxunit.PluginDemoTests.DoubleMethodTest">
		<cfset var methods = "">
		<cfset var results = "">

		<cfset results = rf.executeTestCase(name,methods,"")>
		<cfset methods = rf.getComponentMethods(name)>
		<!--- <cfset debug(results)> --->
		<cfset assertTrue(isStruct(results),"results should be struct")>
		<cfset assertEquals(ArrayLen(methods),ArrayLen(StructKeyArray(results[name])),"")>
	</cffunction>
	
	<cffunction name="testExecuteTestCaseWithFailure" returntype="void" hint="">
		<cfset var name = "mxunit.PluginDemoTests.SingleFailureTest">
		<cfset var methods = "">
		<cfset var results = "">

		<cfset results = rf.executeTestCase(name,methods,"")>
		<cfset methods = rf.getComponentMethods(name)>
		<!--- <cfset debug(results)> ---> 
		<cfset assertTrue(isStruct(results),"results should be struct")>
		<cfset assertEquals(ArrayLen(methods),ArrayLen(StructKeyArray(results[name])),"")>
		<cfset assertTrue(StructKeyExists(results[name]["testFail"],"EXCEPTION"))>
		<cfset assertTrue(StructKeyExists(results[name]["testFail"],"TAGCONTEXT"))>
		
		<cfset isArray(results["mxunit.PluginDemoTests.SingleFailureTest"]["testFail"]["TAGCONTEXT"])>
	</cffunction>
	
	<cffunction name="testExecuteTestCaseWithComplexErrorTypeError">
		<cfset var name = "mxunit.PluginDemoTests.ComplexExceptionTypeErrorTest">
		<cfset var method = "willThrowFunkyNonArrayException">
		<cfset var results = "">

		<cfset results = rf.executeTestCase(name,"","")>
		<!--- <cfset debug(results)> --->
		<cfset assertTrue(isSimpleValue(results[name][method]["EXCEPTION"]))>
		<cfset assertTrue( findNoCase("complex",  results[name][method]["EXCEPTION"]),"mxunit should convert the complex exception value into a string and prefix it with 'complexvalue' but didn't: #results[name][method]['EXCEPTION']#" )>
		<cfset assertTrue(StructKeyExists(results[name][method],"TAGCONTEXT"))>		
		<cfset isArray(results[name][method]["TAGCONTEXT"])>
	</cffunction>

	<cffunction name="testStartTestRun">
		<cfset var key = rf.startTestRun()>
		<cfset assertTrue(len(key) GT 0)>
	</cffunction>

	<cffunction name="testGetServerType">
		<cfset var type = rf.getServerType()>
		<cfset debug(type)>
		<cfset assertTrue(  len(type) GT 0  )>
	</cffunction>



</cfcomponent>
