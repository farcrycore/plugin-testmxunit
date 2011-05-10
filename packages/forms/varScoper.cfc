<cfcomponent extends="farcry.core.packages.forms.forms" output="false">
	<cfproperty name="locations" type="string" ftLabel="Locations"
				ftType="list" ftListData="getLocations" />
	<cfproperty name="types" type="string" ftLabel="Types"
				ftType="list" ftList="coapi:COAPI Components,webskins:Webskins,other:Other" ftSelectMultiple="true" />
				
				
	<cffunction name="getLocations" access="public" output="false" returntype="string">
		<cfset var result = ":-- select location --" />
		<cfset var name = "" />
		<cfset var loc = "" />
		<cfset var oManifest = "" />
		
		<cfloop list="core,#application.plugins#,project" index="loc">
			<cfswitch expression="#loc#">
				<cfcase value="core">
					<cfset result = listappend(result,"core:Core") />
				</cfcase>
				<cfcase value="project">
					<cfset result = listappend(result,"project,Project") />
				</cfcase>
				<cfdefaultcase>
					<cfif fileexists(expandpath("/farcry/plugins/#loc#") & "/install/manifest.cfc")>
						<cfset oManifest = createobject("component","farcry.plugins.#loc#.install.manifest") />
						<cfif structkeyexists(oManifest,"name")>
							<cfset result = listappend(result,"#loc#:#oManifest.name#") />
						<cfelse>
							<cfset result = listappend(result,"#loc#:#loc#") />
						</cfif>
					<cfelse>
						<cfset result = listappend(result,"#loc#:#loc#") />
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="runVarScoper" access="public" output="false" returntype="query">
		<cfargument name="locations" type="string" required="true" />
		<cfargument name="types" type="string" required="true" />
		
		<cfset var packagepath = "" />
		<cfset var coapitypes = "types,rules,forms,schema" />
		<cfset var thistype = "" />
		<cfset var qResults = querynew("filename,function,variable,context,linenumber","varchar,varchar,varchar,varchar,integer") />
		
		<cfset var customTags = arraynew(1) />
		
		<cfset arrayappend(customTags,"admin:loopwebtop,item") />
		<cfset arrayappend(customTags,"admin:loopwebtop,class") />
		<cfset arrayappend(customTags,"ca:displayFilter,r_stFilter") />
		<cfset arrayappend(customTags,"extjs:bubbleOutput,index") />
		<cfset arrayappend(customTags,"extjs:bubbleOutput,bubble") />
		<cfset arrayappend(customTags,"ft:button,r_stButton") />
		<cfset arrayappend(customTags,"ft:farcryButton,r_stButton") />
		<cfset arrayappend(customTags,"ft:object,r_stFields") />
		<cfset arrayappend(customTags,"ft:object,r_stPrefix") />
		<cfset arrayappend(customTags,"ft:objectadmin,r_oTypeAdmin") />
		<cfset arrayappend(customTags,"ft:processformobjects,r_stProperties") />
		<cfset arrayappend(customTags,"ft:processformobjects,r_stObject") />
		<cfset arrayappend(customTags,"ft:validateFormObjects,r_stProperties") />
		<cfset arrayappend(customTags,"ft:validateFormObjects,r_stObject") />
		<cfset arrayappend(customTags,"misc:diff,diff") />
		<cfset arrayappend(customTags,"misc:map,result") />
		<cfset arrayappend(customTags,"misc:map,index") />
		<cfset arrayappend(customTags,"misc:map,sendback") />
		<cfset arrayappend(customTags,"misc:map,value") />
		<cfset arrayappend(customTags,"misc:sort,result") />
		<cfset arrayappend(customTags,"misc:sort,value1") />
		<cfset arrayappend(customTags,"misc:sort,value2") />
		<cfset arrayappend(customTags,"misc:sort,sendback") />
		<cfset arrayappend(customTags,"sec:checkPermission,result") />
		<cfset arrayappend(customTags,"sec:checkRole,result") />
		<cfset arrayappend(customTags,"skin:buildLink,r_url") />
		<cfset arrayappend(customTags,"skin:cache,cacheRead") />
		<cfset arrayappend(customTags,"skin:multiPageNav,r_qlinks") />
		<cfset arrayappend(customTags,"skin:multiPageToc,r_qlinks") />
		<cfset arrayappend(customTags,"skin:pagination,r_stObject") />
		<cfset arrayappend(customTags,"skin:relatedcontent,r_html") />
		<cfset arrayappend(customTags,"skin:relatedLinks,r_qlinks") />
		<cfset arrayappend(customTags,"skin:secondaryNav,r_navQuery") />
		<cfset arrayappend(customTags,"skin:view,r_html") />
		<cfset arrayappend(customTags,"skin:view,r_objectid") />
		<cfset arrayappend(customTags,"wiz:object,r_stWizard") />
		<cfset arrayappend(customTags,"wiz:object,r_stFields") />
		<cfset arrayappend(customTags,"wiz:processwizard,r_stWizard") />
		<cfset arrayappend(customTags,"wiz:processwizardobjects,r_stProperties") />
		<cfset arrayappend(customTags,"wiz:wizard,r_stWizard") />
		
		<!--- Var check coapi components --->
		<cfif listcontains(arguments.types,"coapi")>
			<cfswitch expression="#arguments.locations#">
				<cfcase value="core">
					<cfloop list="#coapitypes#" index="thistype">
						<cfif directoryexists(expandpath("/farcry/core/packages/#thistype#"))>
							<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/core/packages/#thistype#"),true,"","",customTags)) />
						</cfif>
					</cfloop>
				</cfcase>
				<cfcase value="project">
					<cfloop list="#coapitypes#" index="thistype">
						<cfif directoryexists(expandpath("/farcry/projects/#application.projectDirectoryName#/packages/#thistype#"))>
							<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/projects/#application.projectDirectoryName#/packages/#thistype#"),true,"","",customTags)) />
						</cfif>
					</cfloop>
				</cfcase>
				<cfdefaultcase>
					<cfloop list="#coapitypes#" index="thistype">
						<cfif directoryexists(expandpath("/farcry/plugins/#arguments.locations#/packages/#thistype#"))>
							<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/plugins/#arguments.locations#/packages/#thistype#"),true,"","",customTags)) />
						</cfif>
					</cfloop>
				</cfdefaultcase>
			</cfswitch>
		</cfif>
		
		<!--- Var check other components --->
		<cfif listcontains(arguments.types,"other")>
			<cfswitch expression="#arguments.locations#">
				<cfcase value="core">
					<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/core"),true,coapitypes,"",customTags)) />
				</cfcase>
				<cfcase value="project">
					<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/projects/#application.projectDirectoryName#"),true,coapitypes,"",customTags)) />
				</cfcase>
				<cfdefaultcase>
					<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/plugins/#arguments.locations#"),true,coapitypes,"",customTags)) />
				</cfdefaultcase>
			</cfswitch>
		</cfif>
		
		<!--- Var check webskins --->
		<cfif listcontains(arguments.types,"webskins")>
			<cfswitch expression="#arguments.locations#">
				<cfcase value="core">
					<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/core/webskin"),true,"","",customTags,true)) />
				</cfcase>
				<cfcase value="project">
					<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/projects/#application.projectDirectoryName#/webskin"),true,"","",customTags,true)) />
				</cfcase>
				<cfdefaultcase>
					<cfset addResultsToQuery(qResults,processDirectory(expandpath("/farcry/plugins/#arguments.locations#/webskin"),true,"","",customTags,true)) />
				</cfdefaultcase>
			</cfswitch>
		</cfif>
		
		<cfquery dbtype="query" name="qResults">
			select		*, lower(filename) as lowerFilename, lower(function) as lowerFunction
			from		qResults
			order by	lowerFilename, lowerFunction, variable, linenumber
		</cfquery>
		
		<cfreturn qResults />
	</cffunction>
	
	<cffunction name="addResultsToQuery" access="private" output="false" returntype="void" hint="Adds the specified results to the query">
		<cfargument name="q" type="query" required="true" />
		<cfargument name="st" type="struct" required="true" />
		
		<cfset var filename = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfloop collection="#arguments.st#" item="filename">
			<cfloop from="1" to="#arraylen(arguments.st[filename])#" index="i">
				<cfloop from="1" to="#arraylen(arguments.st[filename][i].unscopedarray)#" index="j">
					<cfset queryaddrow(arguments.q) />
					<cfset querysetcell(arguments.q,"filename",filename) />
					<cfset querysetcell(arguments.q,"function",arguments.st[filename][i].functionname) />
					<cfset querysetcell(arguments.q,"variable",arguments.st[filename][i].unscopedarray[j].variablename) />
					<cfset querysetcell(arguments.q,"context",arguments.st[filename][i].unscopedarray[j].variablecontext) />
					<cfset querysetcell(arguments.q,"linenumber",arguments.st[filename][i].unscopedarray[j].linenumber) />
				</cfloop>
			</cfloop>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="processDirectory" hint="used to traverse a directory structure" access="private" output="false" returntype="struct">
		<cfargument name="startingDirectory" type="string" required="true">
		<cfargument name="recursive" type="boolean" required="false" default="false">
		<cfargument name="directoryExcludeList" type="string" required="false" default="">
		<cfargument name="fileExcludeList" type="string" required="false" default="">
		<cfargument name="customTags" type="array" required="false" default="#arraynew(1)#">
		<cfargument name="bWebskins" type="boolean" required="false" default="false" />
		
		<cfset var fileQuery = "" />
		<cfset var scoperFileName = "" />
		<cfset var pathsep = "/" />
		<cfset var fileParseText = "" />
		<cfset var stResults = structnew() />
		<cfset var varScoper = "" />
		
		<cfdirectory directory="#arguments.startingDirectory#" name="fileQuery" />
		<cfloop query="fileQuery">
			
			<!--- check to see if we want to exclude the diretory or file (from properties file) --->
			<cfif NOT listFindNoCase(arguments.directoryExcludeList, listLast(replace(arguments.startingDirectory, "\", "/", "ALL"), pathsep)) AND NOT listFindNoCase(arguments.fileExcludeList, "#name#")>
				<cfset scoperFileName = "#arguments.startingDirectory##pathsep##name#" />
				
				<cfif listFind("cfc,cfm",right(fileQuery.name,3)) NEQ 0 and type IS "file">
					<cffile action="read" file="#scoperFileName#" variable="fileParseText" />
					<cfif arguments.bWebskins>
						<cfset stResults[scoperFileName] = processWebskin(fileParseText,arguments.customTags) />
					<cfelse>
						<cfset varscoper = createobject("component","farcry.plugins.testMXUnit.packages.custom.varScoper").init(fileParseText=fileParseText, showDuplicates=1, showLineNumbers=1, parseCfscript=1, customTags=arguments.customTags) />
						<cfset varscoper.runVarscoper() />
						<cfset stResults[scoperFileName] = varscoper.getResultsArray() />
					</cfif>
				<cfelseif type IS "Dir" and arguments.recursive >
					<cfset structappend(stResults,processDirectory(startingDirectory=scoperFileName, recursive=true, directoryExcludeList=arguments.directoryExcludeList, fileExcludeList=arguments.fileExcludeList, customTags=arguments.customTags, bWebskins=arguments.bWebskins)) />
				</cfif>
			</cfif>		
			
		</cfloop>
		
		<cfreturn stResults />
	</cffunction>
	
	<cffunction name="processWebskin" access="public" output="false" returntype="array">
		<cfargument name="webskinText" type="string" required="true" />
		<cfargument name="customTags" type="array" required="false" default="#arraynew(1)#" />
		
		<cfset var aResults = arraynew(1) />
		<cfset var newResults = arraynew(1) />
		<cfset var varScoper = createobject("component","farcry.plugins.testMXUnit.packages.custom.varScoper") />
		<cfset var webskinLines = varScoper.countNumberOfLines(arguments.webskinText) />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var st = "" />
		
		<cfif not structkeyexists(this,"fourqVars")>
			<cfset this.fourqVars = structnew() />
			<cffile action="read" file="#expandpath('/farcry/core/packages/fourq/fourq.cfc')#" variable="this.fourqVars.full" />
			<cfset st = refindnocase("<cffunction.*?</cffunction>",this.fourqVars.full,1,true) />
			<cfloop condition="st.pos[1]">
				<cfif find('name="runView"',mid(this.fourqVars.full,st.pos[1],st.len[1]))>
					<cfset st = refindnocase("<cffunction.*?</cffunction>",this.fourqVars.full,st.pos[1]+st.len[1],true) />
				<cfelse>
					<cfset this.fourqVars.full = left(this.fourqVars.full,st.pos[1]-1) &+ mid(this.fourqVars.full,st.pos[1]+st.len[1],len(this.fourqVars.full)) />
					<cfset st = refindnocase("<cffunction.*?</cffunction>",this.fourqVars.full,st.pos[1],true) />
				</cfif>
			</cfloop>
			<cfset this.fourqVars.include = refind('<cfinclude template="##arguments\.WebskinPath##">',this.fourqVars.full,1,true) />
			<cfset this.fourqVars.left = left(this.fourqVars.full,this.fourqVars.include.pos[1]-1) />
			<cfset this.fourqVars.right = mid(this.fourqVars.full,this.fourqVars.include.pos[1]+this.fourqVars.include.len[1],len(this.fourqVars.full)) />
			<cfset this.fourqVars.leftLines = varScoper.countNumberOfLines(this.fourqVars.left) />
		</cfif>
		
		<cfset varScoper.init(fileParseText=this.fourqVars.left & arguments.webskinText & this.fourqVars.right, showDuplicates=1, showLineNumbers=1, parseCfscript=1, customTags=arguments.customTags) />
		<cfset varScoper.runVarscoper() />
		<cfset aResults = varScoper.getResultsArray() />
		
		<cfloop from="1" to="#arraylen(aResults)#" index="i">
			<cfif aResults[i].functionname eq "runView" or (aResults[i].linenumber gt this.fourqVars.leftLines and aResults[i].linenumber lt this.fourqVars.leftLines + webskinLines)>
				<cfloop from="1" to="#arraylen(aResults[i].unscopedarray)#" index="j">
					<cfset aResults[i].unscopedarray[j].linenumber = aResults[i].unscopedarray[j].linenumber - this.fourqVars.leftLines />
				</cfloop>
				<cfset arrayAppend(newResults,aResults[i]) />
			</cfif>
		</cfloop>
		
		<cfreturn newResults />
	</cffunction>
	
</cfcomponent>