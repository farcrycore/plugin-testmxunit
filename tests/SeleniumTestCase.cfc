<cfcomponent hint="Selenium tests" extends="FarcryTestCase" output="false" bAbstract="true">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfargument name="host" type="string" required="false" default="localhost" />
		<cfargument name="port" type="numeric" required="false" default="4444" />
		<cfargument name="browser" type="string" required="false" default="" />
		<cfargument name="baseurl" type="string" required="false" default="" />
		
		<cfif not len(arguments.baseurl)>
			<cfif isdefined("request.baseurl")>
				<cfset arguments.baseurl = request.baseurl />
			<cfelse>
				<cfset arguments.baseurl = "http://#cgi.http_host#/" />
			</cfif>
		</cfif>
		<cfset this.baseurl = arguments.baseurl />
		
		<cfif not len(arguments.browser)>
			<cfif isdefined("application.config.testing.browser") and len(application.config.testing.browser)>
				<cfset arguments.browser = application.config.testing.browser />
			<cfelse>
				<cfset arguments.browser = "*chrome" />
			</cfif>
		</cfif>
		
		<cfset super.setUp() />
		
		<cfset this.selenium = createobject("java","com.thoughtworks.selenium.DefaultSelenium").init(arguments.host, arguments.port, arguments.browser, arguments.baseurl) />
		<cfset this.selenium.start() />
		<!--- <cffile action="append" file="/home/blair/www/logs/remotetestappliance/selenium.log" output="Selenium settings: #arguments.toString()#" /> --->
		
		<cfset this.thread = CreateObject("java", "java.lang.Thread") />
	</cffunction>
	
	<cffunction name="tearDown" returntype="void" access="public">
		<cfset this.selenium.stop() />
		
		<cfset super.tearDown() />
	</cffunction>
	
	
	<cffunction name="waitFor" returntype="void" output="false" access="public" hint="Waits for the specified time">
		<cfargument name="timeout" type="numeric" required="true" hint="Number of seconds to wait." />
		
		<cfset this.thread.sleep(arguments.timeout * 1000) />
	</cffunction>
	
	<cffunction name="waitForCondition" returntype="void" output="false" access="public" hint="Sleeps until condition is met, or until timeout">
		<cfargument name="condition" type="string" required="true" hint="Standard loop condition value" />
		<cfargument name="timeout" type="string" required="false" default="30" hint="Number of seconds to wait. Condition is checked every second." />
		<cfargument name="message" type="string" required="false" default="Timed out waiting for: #arguments.condition#" hint="Error message" />
		
		<cfset var timesofar = 0 />
		<cfset var conditiontrue = evaluate(arguments.condition) />
		
		<cfloop condition="not conditiontrue">
			<cfset timesofar = timesofar + 1 />
			<cfif timesofar gt arguments.timeout>
				<cfset fail(arguments.message) />
			</cfif>
			<cfset waitFor(1) />
			<cfset conditiontrue = evaluate(arguments.condition) />
		</cfloop>
	</cffunction>
	
</cfcomponent>