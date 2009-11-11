<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
	
--->
<!--- @@displayname: --->
<!--- @@Description: --->
<!--- @@Developer: Blair (blair@daemon.com.au) --->
<cfcomponent extends="farcry.core.packages.types.types" displayname="MX Unit Tests" hint="Set of unit tests. I expect this will only be used for configuring the nightly tests.">
	<cfproperty ftSeq="1" ftFieldset="Test" ftWizardstep="Test" ftLabel="Title"
				name="title" type="string" hint="The name of the test set. A set called 'Automatic' should be created automatically" />
	<cfproperty ftSeq="2" ftFieldset="Test" ftWizardsetp="Test" ftLabel="Email notification"
				name="notification" type="longchar" hint="The email addresses to send the unit test results"
				ftType="string" />
	<cfproperty ftSeq="3" ftFieldset="Test" ftWizardstep="Test" ftLabel="Tests"
				name="tests" type="longchar" hint="The tests that are part of the set" />
	
	<cffunction name="ftEditTests" returntype="string" output="false" access="public" hint="UI for selecting the tests in this set">
		<cfset var location = "" />
		<cfset var qTests = querynew("name,location,path,hint","varchar,varchar,varchar,varchar") />
		<cfset var qTheseTests = querynew("name,location,path,hint","varchar,varchar,varchar,varchar") />
		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfloop list="core,#application.plugins#,project" index="location">
			<cfset qTheseTests = getTests(location) />
			
			<cfquery dbtype="query" name="qTests">
				select		name,location,path,hint
				from		qTests
				where		name not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(qTheseTests.name)#" />)
				
				UNION
				
				select		name,location,path,hint
				from		qTheseTests
				
				order by	location asc,name asc
			</cfquery>
		</cfloop>
		
		<skin:htmlHead library="jqueryjs" />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<script type="text/javascript">
					function selectLocations(location,select) {
						jQ('input.location'+location).each(function(i){
							this[0].checked = select;
						});
					};
				</script>
			</cfoutput>
			<cfoutput query="qTests" group="location">
				<label class="testlocation" style="font-weight:bold;text-align:left;"><input type="checkbox" name="selectall" id="all#qTests.location#" onclick="selectLocations('#qTests.location#',this.checked);" /> #ucase(qTests.location)#</label><br class="clearer" />
				<div id="tests#qTests.location#">
					<cfoutput>
						<label class="testcomponent" style="margin-left:10px;text-align:left;"><input type="checkbox" name="#arguments.fieldname#" class="location#qTests.location#" value="#qTests.path#"<cfif listcontains(arguments.stMetadata.value,qTests.path)> checked="true"</cfif> /> #qTests.name[qTests.currentrow]#</label>
						<cfif len(qTests.hint)>
							<span class="hint">#qTests.hint#</span>
						</cfif><br class="clearer" />
					</cfoutput>
				</div><br class="clearer" />
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="getTests" returntype="query" output="false" access="public" hint="Returns all the tests for the specified location">
		<cfargument name="location" type="string" required="true" hint="The location to search (core | pluginname | project)" />
		
		<cfset var qFiles = querynew("empty") />
		<cfset var qTests = querynew("name,location,path,hint","varchar,varchar,varchar,varchar") />
		<cfset var stMD = structnew() />
		<cfset var packagepath = "" />
		
		<cfswitch expression="#location#">
			<cfcase value="core">
				<cfdirectory action="list" directory="#application.path.core#/tests" filter="*.cfc" name="qFiles" />
				<cfset packagepath = "farcry.core.tests." />
			</cfcase>
			
			<cfcase value="project">
				<cfdirectory action="list" directory="#application.path.project#/tests" filter="*.cfc" name="qFiles" />
				<cfset packagepath = "farcry.projects.#application.projectdirectoryname#.tests." />
			</cfcase>
			
			<cfdefaultcase><!--- plugin --->
				<cfdirectory action="list" directory="#application.path.plugins#/#arguments.location#/tests" filter="*.cfc" name="qFiles" />
				<cfset packagepath = "farcry.plugins.#arguments.location#.tests." />
			</cfdefaultcase>
		</cfswitch>
		
		<cfloop query="qFiles">
			<cfset stMD = getMetadata(createobject("component","#packagepath##listfirst(qFiles.name,'.')#")) />
			
			<cfif not structkeyexists(stMD,"bAbstract") or not stMD.bAbstract>
				<cfset queryaddrow(qTests) />
				<cfif structkeyexists(stMD,"displayname")>
					<cfset querysetcell(qTests,"name",stMD.displayname) />
				<cfelse>
					<cfset querysetcell(qTests,"name",listlast(stMD.fullname,".")) />
				</cfif>
				<cfset querysetcell(qTests,"location",arguments.location) />
				<cfset querysetcell(qTests,"path","#packagepath##listfirst(qFiles.name,'.')#") />
				<cfif structkeyexists(stMD,"hint")>
					<cfset querysetcell(qTests,"hint",stMD.hint) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn qTests />
	</cffunction>
	
	<cffunction name="getByTitle" returntype="struct" output="false" access="public" hint="Returns the automatic object">
		<cfargument name="title" type="string" required="false" default="Automatic" hint="The name of the test set to retrieve. By default the Automatic set is retrieved." />
		
		<cfset var qResult = querynew("empty") />
		<cfset var stObj = structnew() />
		
		<cfquery datasource="#application.dsn#" name="qResult">
			select	objectid
			from	#application.dbowner#mxTest
			where	title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#" />
		</cfquery>
		
		<cfif qResult.recordcount>
			<cfreturn getData(objectid=qResult.objectid) />
		<cfelse>
			<cfset stObj = getData(objectid=createuuid()) />
			<cfset stObj.title = "Automatic" />
			<cfset stObj.notification = application.config.general.adminemail />
			<cfset setData(stProperties=stObj) />
			
			<cfreturn stObj />
		</cfif>
	</cffunction>
	
</cfcomponent>
