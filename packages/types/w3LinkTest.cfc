<cfcomponent displayname="W3C Link Test" hint="Tracks the results of running the W3C link checker" extends="farcry.core.packages.types.types" output="false">
	<cfproperty ftSeq="1" ftFieldSet="Test" ftLabel="Test Case"
				name="mxTestID" type="uuid"
				ftJoin="mxTest" ftRenderType="list" />
	<cfproperty ftSeq="2" ftFieldSet="Test" ftLabel="URL"
				name="url" type="string" ftWatch="mxTestID" />
	<cfproperty ftSeq="3" ftFieldSet="Test" ftWizardStep="Test" ftLabel="Depth"
				name="linkDepth" type="numeric" ftType="integer" ftDefault="3"ftWatch="mxTestID" ftHint="The number of levels to link check. MUST be 1 or more." />
	<cfproperty ftSeq="4" ftFieldSet="test" ftLabel="State"
				name="state" type="string" ftType="list" ftDefault="Waiting"
				ftList="Waiting,Running,Complete" />
				
	<cfproperty ftSeq="7" ftFieldSet="Report" ftLabel="Result File"
				name="resultFile" type="string" ftType="file" ftDestination="/w3LinkTest" />
	
	<cfproperty ftSeq="4" ftFieldSet="W3C Link Test Result" ftLabel="Pass"
				name="numberOK" type="numeric" ftType="integer" />
	<cfproperty ftSeq="5" ftFieldSet="W3C Link Test Result" ftLabel="Redirecting"
				name="numberRedirecting" type="numeric" ftType="integer" />
	<cfproperty ftSeq="6" ftFieldSet="W3C Link Test Result" ftLabel="Failed"
				name="numberBroken" type="numeric" ftType="integer" />
	
	
	
	<cffunction name="ftEditURL" access="public" returntype="string" description="This will return a string of formatted HTML text to enable the editing of the property" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var stTest = structnew() />
		
		<cfif len(arguments.stObject.mxTestID)>
			<cfset stTest = application.fapi.getContentObject(typename="mxTest",objectid=arguments.stObject.mxTestID) />
			<cfset arguments.stMetadata.value = listfirst(stTest.urls,"#chr(10)##chr(13)#") />
		</cfif>
		
		<cfreturn application.formtools.string.oFactory.edit(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="ftEditLinkDepth" access="public" returntype="string" description="This will return a string of formatted HTML text to enable the editing of the property" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var stTest = structnew() />
		
		<cfif len(arguments.stObject.mxTestID)>
			<cfset stTest = application.fapi.getContentObject(typename="mxTest",objectid=arguments.stObject.mxTestID) />
			<cfset arguments.stMetadata.value = stTest.linkDepth />
		</cfif>
		
		<cfreturn application.formtools.integer.oFactory.edit(argumentCollection=arguments) />
	</cffunction>
	
	
	<cffunction name="BeforeSave" access="public" output="false" returntype="struct">
		<cfargument name="stProperties" required="true" type="struct">
		<cfargument name="stFields" required="true" type="struct">
		<cfargument name="stFormPost" required="false" type="struct">		

		<cfset var newLabel = autoSetLabel(stProperties=arguments.stProperties) />
		
		
		<cfif len(trim(newLabel))>
			<cfset arguments.stProperties.label = newLabel />
		</cfif>
		
		
		<cfset stProperties.datetimelastupdated = now() />
		
		<cfset stProperties.resultFile = application.stCOAPI.w3LinkTest.stProps.resultFile.metadata.ftDestination & "/" & arguments.stProperties.objectid & ".txt" />
		<cfif not directoryExists(getDirectoryFromPath(application.path.defaultfilepath & stProperties.resultFile))>
			<cfdirectory action="create" directory="#getDirectoryFromPath(application.path.defaultfilepath & stProperties.resultFile)#" mode="777" />
		</cfif>
		
		<cfreturn stProperties>
	</cffunction>
	
	
	<cffunction name="startTest" access="public" output="false" returntype="void" hint="Starts the link checking process">
		<cfargument name="objectid" type="uuid" required="false" hint="The link test to start" />
		<cfargument name="stObject" type="struct" required="false" hint="The link test to start" />
		
		<cfif structkeyexists(arguments,"objectid")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<cfswitch expression="#application.config.testing.system#">
			<cfcase value="Windows">
				<cfexecute name="c:\windows\system32\cmd.exe"
				    arguments='/c "#expandpath('/farcry/plugins/testMXUnit/packages/w3clinkchecker/kickoff.bat')#" "#expandpath('/farcry/plugins/testMXUnit/packages/w3clinkchecker/bin/checklink')#" #arguments.stObject.url# #int(arguments.stObject.linkDepth)# "#application.path.defaultfilepath##arguments.stObject.resultFile#" "#application.path.defaultfilepath##replace(arguments.stObject.resultFile,".txt",".done")#' 
				    timeout="0">
				</cfexecute>
			</cfcase>
			<cfcase value="Linux">
				<cfexecute name="#expandpath('/farcry/plugins/testMXUnit/packages/w3clinkchecker/kickoff.sh')#"
				    arguments='"#expandpath('/farcry/plugins/testMXUnit/packages/w3clinkchecker/bin/checklink')#" #arguments.stObject.url# #int(arguments.stObject.linkDepth)# "#application.path.defaultfilepath##arguments.stObject.resultFile#" "#application.path.defaultfilepath##rereplace(arguments.stObject.resultFile,".txt$",".done")#"' 
				    timeout="0">
				</cfexecute>
			</cfcase>
		</cfswitch>
		
		<cfset arguments.stObject.state = "Running" />
		<cfset setData(stProperties=arguments.stObject) />
	</cffunction>
	
	<cffunction name="isTestFinished" access="public" output="false" returntype="boolean" hint="Returns true if the output file is older than a minute and not empty">
		<cfargument name="objectid" type="uuid" required="false" hint="The link test to start" />
		<cfargument name="stObject" type="struct" required="false" hint="The link test to start" />
		
		<cfset var stFile = structnew() />
		
		<cfif structkeyexists(arguments,"objectid")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<cfif arguments.stObject.state eq "Complete">
			<cfreturn true />
		<cfelseif fileexists("#application.path.defaultfilepath##rereplace(arguments.stObject.resultFile,'.txt$','.done')#")>
			<cfset stFile = getFileInfo("#application.path.defaultfilepath##arguments.stObject.resultFile#") />
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="parseTestReport" access="public" output="false" returntype="struct" hint="Parses the output of the W3C Link Checker into a ColdFusion array">
		<cfargument name="objectid" type="uuid" required="false" hint="The link test to start" />
		<cfargument name="stObject" type="struct" required="false" hint="The link test to start" />
		
		<cfset var stResult = structnew() />
		
		<cfset var stPage = structnew() />
		<cfset var stLink = structnew() />
		
		<cfset stResult.ok = arraynew(1) />
		<cfset stResult.notok = arraynew(1)>
		
		<cfif structkeyexists(arguments,"objectid")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<cfloop file="#application.path.defaultfilepath##arguments.stObject.resultFile#" index="thisline">
			<cfif refindnocase("^Processing	http",thisline)>
				<cfif structkeyexists(stLink,"url") and not findnocase("www.w3.org",stLink.url) and not refindnocase("(N/A)",stLink.code)>
					<cfset arrayappend(stPage.aLinks,stLink) />
				</cfif>
				<cfif structkeyexists(stPage,"url")>
					<cfif arraylen(stPage.aLinks)>
						<cfset arrayappend(stResult.notok,stPage) />
					<cfelse>
						<cfset arrayappend(stResult.ok,stPage.url) />
					</cfif>
				</cfif>
				<cfset stPage = structnew() />
				<cfset stPage.aLinks = arraynew(1) />
				<cfset stPage.url = mid(thisline,len("Processing	")+1,len(thisline)) />
			<cfelseif refindnocase("^(https?://|mailto:)",thisline)>
				<cfif structkeyexists(stLink,"url") and not findnocase("www.w3.org",stLink.url) and not refindnocase("(N/A)",stLink.code)>
					<cfset arrayappend(stPage.aLinks,stLink) />
				</cfif>
				<cfset stLink = structnew() />
				<cfset stLink.url = thisline />
			<cfelseif left(thisline,3) eq "-> ">
				<cfset stLink.redirect = mid(thisline,4,len(thisline)) />
			<cfelseif findnocase("Code:",thisline)>
				<cfset stLink.code = mid(thisline,9,len(thisline)) />
			<cfelseif findnocase("To Do:",thisline)>
				<cfset stLink.todo = mid(thisline,9,len(thisline)) />
			<cfelseif left(thisline,1) eq "	" and structkeyexists(stLink,"todo")>
				<cfset stLink.todo = stLink.todo & " " & trim(thisline) />
			</cfif>
		</cfloop>
		<cfif structkeyexists(stLink,"url") and not findnocase("www.w3.org",stLink.url) and not refindnocase("(N/A)",stLink.code)>
			<cfset arrayappend(stPage.aLinks,stLink) />
		</cfif>
		<cfif structkeyexists(stPage,"url")>
			<cfif arraylen(stPage.aLinks)>
				<cfset arrayappend(stResult.notok,stPage) />
			<cfelse>
				<cfset arrayappend(stResult.ok,stPage.url) />
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="updateTestFromOutput" access="public" output="false" returntype="struct" hint="Updates the database with the number of broken links and clean pages">
		<cfargument name="objectid" type="uuid" required="false" hint="The link test to start" />
		<cfargument name="stObject" type="struct" required="false" hint="The link test to start" />
		
		<cfset var stReport = structnew() />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfif structkeyexists(arguments,"objectid")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<cfset stReport = parseTestReport(stObject=arguments.stObject) />
		
		<!--- Initialise counts --->
		<cfset arguments.stObject.numberOK = arraylen(stReport.ok) />
		<cfset arguments.stObject.numberRedirecting = 0 />
		<cfset arguments.stObject.numberBroken = 0 />
		
		<!--- Count redirecting / broken --->
		<cfloop from="1" to="#arraylen(stReport.notok)#" index="i">
			<cfloop from="1" to="#arraylen(stReport.notok[i].aLinks)#" index="j">
				<cfif left(stReport.notok[i].aLinks[j].code,1) eq "3">
					<cfset arguments.stObject.numberRedirecting = arguments.stObject.numberRedirecting + 1 />
				<cfelse>
					<cfset arguments.stObject.numberBroken = arguments.stObject.numberBroken + 1 />
				</cfif>
			</cfloop>
		</cfloop>
		
		<!--- Update record --->
		<cfset arguments.stObject.state = "Complete" />
		<cfset setData(stProperties=arguments.stObject) />
		
		<cfreturn arguments.stObject />
	</cffunction>
	
</cfcomponent>