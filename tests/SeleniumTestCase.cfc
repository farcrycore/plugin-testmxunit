<cfcomponent hint="Selenium tests" extends="FarcryTestCase" output="false" bAbstract="true">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfargument name="host" type="string" required="false" default="localhost" />
		<cfargument name="port" type="numeric" required="false" default="4444" />
		<cfargument name="browser" type="string" required="false" default="*chrome" />
		<cfargument name="baseurl" type="string" required="false" default="http://www.google.com.au/" />
		
		<cfset this.selenium = createobject("java","com.thoughtworks.selenium.DefaultSelenium").init(arguments.host, arguments.port, arguments.browser, arguments.baseurl) />
		<cfset this.selenium.start() />
		<cfset this.thread = CreateObject("java", "java.lang.Thread") />
		
		<cfset super.setUp() />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<cfset this.selenium.stop() />
		
		<cfset super.tearDown() />
	</cffunction>
	
	
	<cffunction name="waitForCondition" returntype="void" output="false" access="public" hint="Sleeps until condition is met, or until timeout">
		<cfargument name="condition" type="string" required="true" hint="Standard loop condition value" />
		<cfargument name="timeout" type="string" required="false" default="30" hint="Number of seconds to wait. Condition is checked every second." />
		
		<cfset var timesofar = 0 />
		<cfset var conditiontrue = evaluate(arguments.condition) />
		
		<cfloop condition="not conditiontrue">
			<cfset timesofar = timesofar + 1 />
			<cfif timesofar gt arguments.timeout>
				<cfthrow message="Timed out waiting for: #arguments.condition#" />
			</cfif>
			<cfset this.thread.sleep(1000) />
			<cfset conditiontrue = evaluate(arguments.condition) />
		</cfloop>
	</cffunction>
	
</cfcomponent>