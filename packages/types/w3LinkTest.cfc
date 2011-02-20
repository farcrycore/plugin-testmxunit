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
		<cfset var st = structnew() />
		
		<cfset stResult.pages = arraynew(1) />
		<cfset stResult.totals = structnew() />
		<cfset stResult.totals.all = 0 />
		<cfset stResult.totals.redirecting = 0 />
		<cfset stResult.totals.broken = 0 />
		
		<cfif structkeyexists(arguments,"objectid")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<cfloop file="#application.path.defaultfilepath##arguments.stObject.resultFile#" index="thisline">
			<cfif refindnocase("^Processing	http",thisline)>
				<cfif structkeyexists(stLink,"url") and not findnocase("www.w3.org",stLink.url) and not refindnocase("(N/A)",stLink.code)>
					<cfset arrayappend(stPage.aLinks,stLink) />
					<cfif not structkeyexists(stLink,"redirect")>
						<cfset stResult.totals.broken = stResult.totals.broken + 1 />
					</cfif>
				</cfif>
				<cfif structkeyexists(stPage,"url")>
					<cfset arrayappend(stResult.pages,stPage) />
				</cfif>
				<cfset stPage = structnew() />
				<cfset stPage.aLinks = arraynew(1) />
				<cfset stPage.url = mid(thisline,len("Processing	")+1,len(thisline)) />
			<cfelseif refind("^Found \d+ anchor",thisline)>
				<cfset st = refind("^Found (\d+) anchor",thisline,1,true) />
				<cfset stPage.totalanchors = mid(thisline,st.pos[2],st.len[2]) />
				<cfset stResult.totals.all = stResult.totals.all + stPage.totalanchors />
			<cfelseif refindnocase("^(https?://|mailto:)",thisline)>
				<cfif structkeyexists(stLink,"url") and not findnocase("www.w3.org",stLink.url) and not refindnocase("(N/A)",stLink.code)>
					<cfset arrayappend(stPage.aLinks,stLink) />
					<cfif not structkeyexists(stLink,"redirect")>
						<cfset stResult.totals.broken = stResult.totals.broken + 1 />
					</cfif>
				</cfif>
				<cfset stLink = structnew() />
				<cfset stLink.url = thisline />
			<cfelseif left(thisline,3) eq "-> ">
				<cfset stLink.redirect = mid(thisline,4,len(thisline)) />
				<cfset stResult.totals.redirecting = stResult.totals.redirecting + 1 />
			<cfelseif findnocase("Code:",thisline)>
				<cfset stLink.code = mid(thisline,9,len(thisline)) />
			<cfelseif findnocase("To Do:",thisline)>
				<cfset stLink.todo = mid(thisline,9,len(thisline)) />
			<cfelseif left(thisline,1) eq "	" and refind("\s+",thisline) and structkeyexists(stLink,"todo")>
				<cfset stLink.todo = stLink.todo & " " & trim(thisline) />
			</cfif>
		</cfloop>
		<cfif structkeyexists(stLink,"url") and not findnocase("www.w3.org",stLink.url) and not refindnocase("(N/A)",stLink.code)>
			<cfset arrayappend(stPage.aLinks,stLink) />
			<cfif not structkeyexists(stLink,"redirect")>
				<cfset stResult.totals.broken = stResult.totals.broken + 1 />
			</cfif>
		</cfif>
		<cfif structkeyexists(stPage,"url")>
			<cfset arrayappend(stResult.pages,stPage) />
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
		<cfset arguments.stObject.numberRedirecting = stReport.totals.redirecting />
		<cfset arguments.stObject.numberBroken = stReport.totals.broken />
		<cfset arguments.stObject.numberOK = stReport.totals.all - stReport.totals.redirecting - stReport.totals.broken />
		
		<!--- Update record --->
		<cfset arguments.stObject.state = "Complete" />
		<cfset setData(stProperties=arguments.stObject) />
		
		<cfreturn arguments.stObject />
	</cffunction>
	
	
	<cffunction name="minArg" access="public" returntype="numeric" output="false">
		<cfset var i = 0 />
		<cfset var mina = "" />
		
		<cfloop from="1" to="#arraylen(arguments)#" index="i">
			<cfif not isnumeric(mina) or mina gt arguments[i]>
				<cfset mina = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfreturn mina />
	</cffunction>
	
	<cffunction name="maxArg" access="public" returntype="numeric" output="false">
		<cfset var i = 0 />
		<cfset var maxa = "" />
		
		<cfloop from="1" to="#arraylen(arguments)#" index="i">
			<cfif not isnumeric(maxa) or maxa lt arguments[i]>
				<cfset maxa = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfreturn maxa />
	</cffunction>
	
	<cffunction name="getTestChart" access="public" returntype="string" description="Returns the chart image path (after downloading it from Google if necessary)" output="false">
		<cfargument name="objectid" type="uuid" required="false" />
		<cfargument name="stObject" type="struct" required="false" />
		
		<cfset var filename = "" />
		<cfset var minr = 0 />
		<cfset var maxr = 0 />
		
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = getData(arguments.objectid) />
		</cfif>
		
		<cfset minr = minArg(arguments.stObject.numberOK,arguments.stObject.numberRedirecting,arguments.stObject.numberBroken) />
		<cfset maxr = maxArg(arguments.stObject.numberOK,arguments.stObject.numberRedirecting,arguments.stObject.numberBroken) />
		
		<cfreturn "http://chart.apis.google.com/chart?chs=360x285&cht=p&chco=00BF0D|FFA500|CC2504&chd=t:#arguments.stObject.numberOK#,#arguments.stObject.numberRedirecting#,#arguments.stObject.numberBroken#&chds=#minr#,#maxr#&chdl=OK|Redirecting|Broken&chdlp=b&chma=|5&chtt=Link+Tests&chts=3A3A3A,17.5" />
	</cffunction>
	
</cfcomponent>