<cfcomponent extends="mxunit.framework.TestCase">


	<cffunction name="setUp" returntype="void" access="public" hint="put things here that you want to run before each test">
		<cfset variables.blender = createObject("component","mxunit.framework.ComponentBlender")>
		<cfset variables.mycfc = createObject("component","mxunit.tests.framework.fixture.NewCFComponent")>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public" hint="put things here that you want to run after each test">

	</cffunction>

	<cffunction name="foo" access="private">
		<cfreturn "foo">
	</cffunction>

	<cffunction name="testCauseAFailure" returntype="void" hint="tests error path">
		<cfset var actual = "" />
		<cftry>
			<!--- do something here to cause an error --->
			<cfset actual = blender.foo()>
			<cfset fail("Error path test... should not have gotten here")>
		<cfcatch type="mxunit.exception.AssertionFailedError">
			<cfrethrow>
		</cfcatch>
		<cfcatch type="any"></cfcatch>
		</cftry>
	</cffunction>


	<cffunction name="testMixin" returntype="void" access="public">
		<cfset var actual = "" />
		 <cfset blender._mixin("foo",foo)>
		<cfset actual = blender.foo()>
		<cfset assertEquals("foo",actual,"")>
	</cffunction>

	<cffunction name="testMixinPrivate" returntype="void" access="public">
		<cfset var actual = "" />
		 <cfset blender._mixinAll(blender,mycfc)>

		 <cfset debug( getMetadata(mycfc) )>

		 <cfset actual = blender.doSomethingPrivate()>
		<cfset assertEquals("poo",actual,"")>
	</cffunction>

	<!---
	for now, removing this test. it looks like it's impossible to simply use mixins
	to convert a package-level method to public. weird, though, that you can do it
	with private but not public
	<cffunction name="testMixinPackage" returntype="void" access="public">
	<cfset var actual = "" />
	<cfset var result = "" />
	<cfset var result2 = "" />
		 <cfset blender._mixinAll(blender,mycfc)>

		 <cfset debug( getMetadata(mycfc) )>

		  <cfset actual = blender.doSomethingPackage()>
		<cfset assertEquals("goo",actual,"")>
	</cffunction> --->


	<cffunction name="testMixinAll" returntype="void" hint="">
		<cfset blender._mixinAll(this,mycfc)>
		<cfset result = this.doSomething()>
		<cfset result2 = this.doSomethingElse()>
		<cfset assertEquals(mycfc.doSomething(),result,"")>
		<cfset assertEquals(mycfc.doSomethingElse(),result2,"")>
	</cffunction>

	<cffunction name="testIsComponentVariableDefined">
		<cfset assertTrue( blender._isComponentVariableDefined("_Mixin") )>
		<cfset assertFalse( blender._isComponentVariableDefined("_Mixin$$$") )>

		<cfset blender._MixinAll(blender,this)>
		<cfset assertTrue(blender._isComponentVariableDefined("setUp"))>

	</cffunction>

	<cffunction name="testIsComponentVariableDefinedCallingFromMyself">
		<cfset var result = "" />
		<!--- mix blender into me --->
		<cfset blender._MixinAll(this,blender)>
		<cfset result =  this._isComponentVariableDefined("_MixIn")>
		<cfset assertTrue(result,"")>
	</cffunction>
	
	<cffunction name="testMixinPropertyDefaultScopes">
		
		<cftry>			
		<!--- this should not work b/c internalVar is private --->
		<cfset tmp = mycfc.internalVar>
		<cfset fail("Error path test... should not have gotten here")>
		<cfcatch type="mxunit.exception.AssertionFailedError">
			<cfrethrow>
		</cfcatch>
		<cfcatch type="any"></cfcatch>
		</cftry>
		
		<!--- now, mix in the property and assure it's properly overwritten' --->
		<cfset blender._mixinAll(mycfc,blender)>
		<cfset mycfc._mixinProperty(propertyName="internalVar",property="goo")>
		<cfset assertEquals("goo",mycfc.internalVar)>
	</cffunction>
	
	<cffunction name="testMixinPropertyInstanceScope">
		<cfset blender._mixinAll(mycfc,blender)>
		<cfset mycfc._mixinProperty(propertyName="internalVar",property="goo",scope="instance")>
		<cfset assertEquals("goo",mycfc.getInstance().internalVar)>
	</cffunction>

</cfcomponent>