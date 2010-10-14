<cfcomponent displayname="Basic External Tests" hint="Basic tests for external applications" extends="mxunit.framework.TestCase" output="false">
	
	<cffunction name="setUp" returntype="void" access="public">
		
		<cfset this.baseurl = request.baseurl />
		
		<cfif right(this.baseurl,1) neq "/">
			<cfset this.baseurl = this.baseurl & "/" />
		</cfif>
		
		<cfset super.setUp() />
	</cffunction>
	
	
	<cffunction name="websiteAvailable" access="public" output="false" returntype="void" displayname="Website available" mode="app">
		<cfset var cfhttp = structnew() />
		
		<cfhttp url="#this.baseurl#index.cfm" timeout="30" result="cfhttp" />
		
		<cfset assertEquals(cfhttp.StatusCode,"200 OK","Failed to access #this.baseurl#/index.cfm") />
	</cffunction>
	
	<cffunction name="fuAvailable" access="public" output="false" returntype="void" displayname="Friendly URLs Available" mode="app" dependson="websiteAvailable">
		<cfset var cfhttp = structnew() />
		
		<cfhttp url="#this.baseurl#pingFU" timeout="30" result="cfhttp" />
		
		<cfset assertEquals(cfhttp.StatusCode,"200 OK") />
		<cfset assertTrue(findnocase("PING FU SUCCESS",cfhttp.FileContent)) />
	</cffunction>
	
</cfcomponent>