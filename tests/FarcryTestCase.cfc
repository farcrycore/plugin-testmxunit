<cfcomponent hint="SSFS utility functions" extends="mxunit.framework.TestCase" output="false" bAbstract="true">
	
	<cffunction name="setUp" returntype="void" access="public">
	
		<cfset this.aPinObjects = arraynew(1) />
		<cfset this.aPinUsers = arraynew(1) />
		<cfset this.aPinScopes = arraynew(1) />
		<cfset this.aPinCategories = arraynew(1) />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		
		<!--- Revert data --->
		<cfset revertObjects() />
		
		<!--- Remove dirty users --->
		<cfset revertUsers() />
		
		<!--- Remove dirty scope variables --->
		<cfset revertScopes() />
		
		<!--- Remove dirty categories --->
		<cfset revertCategories() />
	</cffunction>
	
	
	<cffunction name="createTemporaryObject" access="package" returntype="struct" output="false" hint="Creates an object and adds it to the pinned list">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		
		<cfset var o = createobject("component",application.stCOAPI[arguments.typename].packagepath) />
		<cfset var stObj = duplicate(arguments) />
		<cfset var lCategories = "" />
		<cfset var oCategory = createobject("component","farcry.core.packages.farcry.category") />
		
		<cfparam name="stObj.objectid" default="#createuuid()#" />
		
		<cfif structkeyexists(arguments,"categories")>
			<cfset lCategories = arguments.categories />
			<cfset structdelete(arguments,"categories") />
		</cfif>
		
		<cfset pinObjects(typename=arguments.typename,objectid=stObj.objectid) />
		<cfset o.setData(stProperties=stObj) />
		<cfset oCategory.assignCategories(stObj.objectid,lCategories) />
		
		<cfreturn stObj />
	</cffunction>
	
	<cffunction name="createTemporaryCategory" access="package" returntype="struct" output="false" hint="Creates the specified category and adds it the the pinned list">
		<cfargument name="alias" type="string" required="true" hint="" />
		<cfargument name="parentid" type="uuid" required="false" default="#application.catid.root#" hint="The parent of the new category" />
		<cfargument name="categoryid" type="string" required="false" hint="" />
		<cfargument name="categorylabel" type="string" required="false" hint="" />
		
		<cfset var oCategory = createobject("component","farcry.core.packages.farcry.category") />
		
		<cfparam name="arguments.categoryid" default="#createuuid()#" />
		<cfparam name="argumetns.categorylabel" default="#arguments.alias#" />
		
		<cfset pinCategories(arguments.categoryid) />
		<cfset oCategory.addCategory(arguments.categoryid,arguments.categorylabel,arguments.parentid) />
		<cfset oCategory.setAlias(arguments.categoryid,arguments.alias) />
		
		<cfreturn duplicate(arguments) />
	</cffunction>
	
	
	<cffunction name="getCategory" access="package" returntype="struct" output="false" hint="Returns the specified category">
		<cfargument name="category" type="string" required="true" hint="The category id or alias" />
		
		<cfset var qCategory = structnew() />
		<cfset var stCat = structnew() />
		<cfset var oTree = createobject("component","farcry.core.packages.farcry.tree") />
		
		<cfif isvalid("uuid",arguments.category)>
			<cfquery datasource="#application.dsn#" name="qCategory">
				select		*
				from		#application.dbowner#categories
				where		categoryid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#" />
			</cfquery>
		<cfelse><!--- Retrieve the category by alias --->
			<cfquery datasource="#application.dsn#" name="qCategory">
				select		*
				from		#application.dbowner#categories
				where		alias=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#" />
			</cfquery>
		</cfif>
		
		<cfif qCategory.recordcount>
			<cfset stCat.categoryid = qCategory.categoryid />
			<cfset stCat.alias = qCategory.alias />
			<cfset stCat.categoryLabel = qCategory.categoryLabel />
			<cfset stCat.parentid = oTree.getParentID(qCategory.categoryid) />
		</cfif>
		
		<cfreturn stCat />
	</cffunction>
	
	<cffunction name="getCategoryReferences" access="package" returntype="string" output="false" hint="Returns a list of references to the category">
		<cfargument name="categoryid" type="uuid" required="true" hint="The categoryid" />
		
		<cfset var qRefs = querynew("empty") />
		
		<cfquery datasource="#application.dsn#" name="qRefs">
			select	objectid
			from	#application.dbowner#refCategories
			where	categoryid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryid#" />
		</cfquery>
		
		<cfreturn valuelist(qRefs.objectid) />
	</cffunction>
	
	<cffunction name="pinCategories" access="package" returntype="void" output="false" hint="Adds categories to the dirty list, to be reverted on tearDown">
		<cfargument name="category" type="string" required="true" hint="A list of objectids or aliases" />
		
		<cfset var thiscategory = "" />
		<cfset var stPin = structnew() />
		
		<cfloop list="#arguments.category#" index="thiscategory">
			<cfset stPin = structnew() />
			<cfset stPin.category = thiscategory />
			
			<!--- Add category information --->
			<cfset stPin.stPre = getCategory(thiscategory) />
			
			<!--- Add reference information --->
			<cfif not structisempty(stPin.stPre)>
				<cfset stPin.lPreRefs = getCategoryReferences(stPin.stPre.categoryid) />
			</cfif>
			
			<!--- Add to pinned list --->
			<cfset arrayappend(this.aPinCategories,stPin) />
		</cfloop>
	</cffunction>
	
	<cffunction name="revertCategory" access="package" returntype="void" output="false" hint="Reverts a specific category and its references">
		<cfargument name="stPin" type="struct" required="true" hint="The previous category values" />
		
		<cfset var stCurrent = getCategory(stPin.category) />
		<cfset var lReferences = "" />
		<cfset var thisreference = "" />
		<cfset var oCategory = createobject("component","farcry.core.packages.farcry.category") />
		
		<cfif not structisempty(stCurrent)>
			<cfset lReferences = getCategoryReferences(stCurrent.categoryid) />
		</cfif>
		
		<cfif structisempty(arguments.stPin.stPre) and not structisempty(stCurrent)><!--- CASE 1: Delete the category --->
			
			<cfset oCategory.deleteCategory(stCurrent.categoryid,application.dsn) />
			
		<cfelseif not structisempty(arguments.stPin.stPre) and structisempty(stCurrent)><!--- CASE 2: Re-add this category --->
			
			<cfset oCategory.addCategory(arguments.stPin.stPre.categoryid,arguments.stPin.stPre.categorylabel,arguments.stPin.stPre.parentid) />
			<cfset oCategory.setAlias(arguments.stPin.stPre.categoryid,arguments.stPin.stPre.alias) />
					
			<cfloop list="#arguments.stPin.lReferences#" index="thisreference">
				<cfquery datasource="#application.dsn#">
					insert 
					into 	#application.dbowner#refCategories
							(categoryid,objectid)
					values	(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stPin.stPre.categoryid#" />,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisreference#" />
							)
				</cfquery>
			</cfloop>
			
		<cfelse><!--- CASE 3: Revert this category --->
			
			<!--- Update category --->
			<cfquery datasource="#application.dsn#">
				update	#application.dbowner#categories
				set		alias=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stPin.alias#" />,
						categorylabel=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stPin.categorylabel#" />
				where	categoryid=categoryid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stPin.categoryid#" />
			</cfquery>
			
			<!--- Check parent --->
			<cfif arguments.stPin.stPre.parentid neq stCurrent.parentid>
				<cfset oCategory.moveCategory(arguments.stPin.stPre.categoryid,arguments.stPin.stPre.parentid) />
			</cfif>
			
			<!--- Update references --->
			<cfloop list="#arguments.stPin.lReferences#" index="thisreference">
				<cfif not listcontains(lReferences,thisreference)><!--- Re-add reference --->
					<cfquery datasource="#application.dsn#">
						insert 
						into 	#application.dbowner#refCategories
								(categoryid,objectid)
						values	(
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stPin.stPre.categoryid#" />,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisreference#" />
								)
					</cfquery>
				</cfif>
			</cfloop>
			<cfloop list="#lReferences#" index="thisreference">
				<cfif not listcontains(arguments.stPin.lReferences,thisreference)><!--- Delete reference --->
					<cfquery datasource="#application.dsn#">
						delete 
						from 	#application.dbowner#refCategories
						where 	categoryid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stPin.stPre.categoryid#" />
								AND objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisreference#" />
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="revertCategories" access="package" returntype="void" output="false" hint="Reverts all pinned categories and their references">
		<cfset var i = 0 />
		<cfset var stPin = structnew() />
		<cfset var qCategory = querynew("empty") />
		
		<cfloop from="1" to="#arraylen(this.aPinCategories)#" index="i">
			<cfset revertCategory(this.aPinCategories[i]) />
		</cfloop>
	</cffunction>
	
	
	<cffunction name="getObjects" access="package" returntype="query" output="false" hint="Returns a query containing information about objects that meet the specified filter">
		<cfargument name="typename" type="string" required="true" hint="The type of object to get" />
		<cfargument name="timeframe" type="numeric" required="false" hint="How old the objects are" />
		
		<cfset var qObjects = querynew("empty") />
		<cfset var thisproperty = "" />
		
		<cfquery datasource="#application.dsn#" name="qObjects" result="stResult">
		select		*
		from		#application.dbowner##arguments.typename#
		where		1=1
					<cfif structkeyexists(arguments,"timeframe")>
						AND datetimecreated><cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd('s',0-arguments.timeframe,now())#" />
					</cfif>
					<cfloop collection="#arguments#" item="thisproperty">
						<cfif not refindnocase("(^|,)(typename|timeframe|exceptobjectids)($|,)",thisproperty)>
							AND #thisproperty#=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments[thisproperty]#" />
						</cfif>
					</cfloop>
					<cfif structkeyexists(arguments,"exceptobjectids") and len(arguments.exceptobjectids)>
						AND objectid not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.exceptobjectids#" />)
					</cfif>
	</cfquery>
	
	<cfreturn qObjects />
</cffunction>

	<cffunction name="pinObjects" access="package" returntype="void" output="false" hint="Adds an object to the dirty list, to be removed on tearDown">
		<cfset var stPin = structnew() />
		<cfset var qObjects = getObjects(argumentCollection=arguments) />
		<cfset var o = createobject("component",application.stCOAPI[arguments.typename].packagepath) />
		
		<!--- Filter --->
		<cfset stPin.filter = duplicate(arguments) />
		
		<!--- Pre-test data --->
		<cfset stPin.aPre = arraynew(1) />
		<cfset stPin.lPre = "" />
		<cfloop query="qObjects">
			<cfset stPin.lPre = listappend(stPin.lPre,qObjects.objectid) />
			<cfset arrayappend(stPin.aPre,o.getData(objectid=qObjects.objectid)) />
		</cfloop>
		
		<cfset arrayappend(this.aPinObjects,stPin) />
	</cffunction>
	
	<cffunction name="revertObjects" access="package" returntype="void" output="false" hint="Reverts all pinned data">
		<cfset var qObjects = querynew("empty") />
		<cfset var o = "" />
		<cfset var thiscolumn = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<!--- Remove dirty objects --->
		<cfloop from="1" to="#arraylen(this.aPinObjects)#" index="i">
			<cfset o = createobject("component",application.stCOAPI[this.aPinObjects[i].filter.typename].packagepath) />
			
			<!--- Resave all objects in the old dataset --->
			<cfloop from="1" to="#arraylen(this.aPinObjects[i].aPre)#" index="j">
				<cfset o.setData(stProperties=this.aPinObjects[i].aPre[j]) />
			</cfloop>
			
			<!--- Remove objects that weren't in the old dataset and are in the new one --->
			<cfset this.aPinObjects[i].filter.exceptobjectids = this.aPinObjects[i].lPre />
			<cfset qObjects = getObjects(argumentCollection=this.aPinObjects[i].filter) />
			<cfloop query="qObjects">
				<cfset o.deleteData(objectid=qObjects.objectid) />
			</cfloop>
		</cfloop>
	</cffunction>
	
	
	<cffunction name="getUsers" access="package" returntype="query" output="false" hint="Returns an array of all specified users">
		<cfargument name="userlogins" type="string" required="true" hint="The user's login" />
		
		<cfset var qResult = querynew("empty") />
		
		<cfquery datasource="#application.dsn#" name="qResult">
			select		*
			from		dmUser
			where		userlogin in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.userlogins#">)
			order by	userid
		</cfquery>
		
		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="getUserGroups" access="package" returntype="query" output="false" hint="Returns an array of all specified users">
		<cfargument name="userlogins" type="string" required="true" hint="The user's login" />
		
		<cfset var qResult = querynew("empty") />
		
		<cfquery datasource="#application.dsn#" name="qResult">
			select		*
			from		dmUserToGroup
			where		userID in (
							select		userid
							from		dmUser
							where		userlogin in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.userlogins#">)
						)
			order by	userid
		</cfquery>
		
		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="pinUsers" access="package" returntype="void" output="false" hint="Adds a user to the dirty list, to be removed on tearDown">
		<cfargument name="userlogins" type="string" required="true" hint="The user's login" />
		
		<cfset stPin = structnew() />
		
		<cfset stPin.lUserLogins = arguments.userlogins />
		<cfset stPin.qPreUsers = getUsers(arguments.userlogins) />
		<cfset stPin.qPreUserGroups = getUserGroups(arguments.userlogins) />
		<cfset stPin.lUserIDs = valuelist(stPin.qPreUsers.userid) />
		
		<cfset arrayappend(this.aPinUsers,stPin) />
	</cffunction>
	
	<cffunction name="revertUsers" access="package" returntype="void" output="false" hint="Reverts all pinned users">
		<cfset var i = 0 />
		<cfset var stPin = structnew() />
		
		<cfloop from="1" to="#arraylen(this.aPinUsers)#" index="i"><cflog file="testing" text="Reverting user: #this.aPinUsers[i].lUserLogins#" />
			<cfset stPin = this.aPinUsers[i] />
			
			<!--- Remove new users --->
			<cfquery datasource="#application.dsn#">
				delete
				from	dmUser
				where	userLogin in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stPin.lUserLogins#" />)
						<cfif len(stPin.lUserIDs)>
							and userid not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stPin.lUserIDs#" />)
						</cfif>
			</cfquery>
			
			<!--- Update users --->
			<cfloop query="stPin.qPreUsers">
				<cfquery datasource="#application.dsn#">
					update	dmUser
					set		userPassword=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stPin.qPreUsers.userPassword#" />,
							userStatus=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stPin.qPreUsers.userStatus#" />
					where	userLogin=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stPin.qPreUsers.userLogin#" />
				</cfquery>
			</cfloop>
			
			<!--- Remove groups for users --->
			<cfquery datasource="#application.dsn#">
				delete
				from	dmuser
				where	userLogin in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stPin.lUserLogins#" />)
			</cfquery>
			
			<!--- Resave groups for users --->
			<cfloop query="stPin.qPreUserGroups">
				<cfquery datasource="#application.dsn#">
					insert into dmUserToGroup (
								userID,
								groupID
							)
					values (
								<cfqueryparam cfsqltype="cf_sql_integer" value="#stPin.qPreUserGroups.userID#" />,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#stPin.qPreUserGroups.groupID#" />
							)
				</cfquery>
			</cfloop>
		</cfloop>
	</cffunction>
	
	
	<cffunction name="pinScope" access="package" returntype="void" output="false" hint="Pins the specified scope variables">
		<cfargument name="variable" type="string" required="true" hint="The variable to pin" />
		
		<cfset var curval = "" />
		<cfset var stPin = structnew() />
		
		<cfset stPin.variable = arguments.variable />
		
		<cftry>
			<cfset curval = evaluate(arguments.variable) />
			<cfset stPin.value = duplicate(curval) />
			
			<cfcatch>
				<!--- The variable doesn't exist --->
			</cfcatch>
		</cftry>
		
		<cfset arrayappend(this.aPinScopes,stPin) />
	</cffunction>
	
	<cffunction name="revertScopes" access="package" returntype="void" output="false" hint="Reverts the pinned scopes">
		<cfset var i = 0 />
		<cfset var val = "" />
		
		<cfloop from="1" to="#arraylen(this.aPinScopes)#" index="i">
			<!--- If the variable didn't exist and does now, remove it --->
			<cfif not structkeyexists(this.aPinScopes[i],"value")>
				<cftry>
					<cfset val = evaluate(this.aPinScopes[i].variable) />
					<cfset structdelete(listdeleteat(this.aPinScopes[i].variable,listlen(this.aPinScopes[i].variable,"."),"."),listlast(this.aPinScopes[i].variable,".")) />
					
					<cfcatch>
						<!--- This variable doesn't exist --->
					</cfcatch>
				</cftry>
			</cfif>
			
			<!--- If the variable does exist, update it --->
			<cfif structkeyexists(this.aPinScopes[i],"value")>
				<cfset "#this.aPinScopes[i].variable#" = this.aPinScopes[i].value />
			</cfif>
		</cfloop>
	</cffunction>
	
	
	<cffunction name="assertContentTypeExists" access="package" returntype="boolean" hint="Returns true if the specified key exists">
		<cfargument name="typename" type="string" required="true" hint="The typename to attempt to instantiate" />
		<cfargument name="message" type="string" required="false" default="" hint="The message to record on failure" />
		
		<cfset var o = "" />
		
		<cfif structkeyexists(application.stCOAPI,arguments.typename)>
			<cfset o = createobject("component",application.stCOAPI[arguments.typename].packagepath) />
		<cfelse>
			<cfinvoke method="fail" message="#arguments.message#" />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="assertObjectExists" access="package" returntype="boolean" hint="Tests that the specified object exists">
		<cfargument name="typename" type="string" required="true" hint="The type of the object to check for" />
		<cfargument name="timeframe" type="numeric" required="false" hint="Restricts the timeframe to check for logs" />
		<cfargument name="message" type="string" required="false" default="" hint="The message to record on failure" />
		
		<cfset var qObjects = querynew("empty") />
		
		<cfquery datasource="#application.dsn#" name="qObjects">
			select		objectid
			from		#application.dbowner##arguments.typename#
			where		1=1
						<cfif structkeyexists(arguments,"timeframe")>
							AND datetimecreated><cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd('s',0-arguments.timeframe,now())#" />
						</cfif>
						<cfloop collection="#arguments#" item="thisproperty">
							<cfif not listcontainsnocase("typename,timeframe,message",thisproperty)>
								AND #thisproperty#=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments[thisproperty]#" />
							</cfif>
						</cfloop>
		</cfquery>
		
		<cfif not qObjects.recordcount>
			<cfinvoke method="fail" message="#arguments.message#" />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="assertNotObjectExists" access="package" returntype="boolean" hint="Tests that the specified object does not exist">
		<cfargument name="typename" type="string" required="true" hint="The type of the object to check for" />
		<cfargument name="timeframe" type="numeric" required="false" hint="Restricts the timeframe to check for logs" />
		<cfargument name="message" type="string" required="false" default="" hint="The message to record on failure" />
		
		<cfset var qObjects = querynew("empty") />
		
		<cfquery datasource="#application.dsn#" name="qObjects">
			select		objectid
			from		#application.dbowner##arguments.typename#
			where		1=1
						<cfif structkeyexists(arguments,"timeframe")>
							AND datetimecreated><cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd('s',0-arguments.timeframe,now())#" />
						</cfif>
						<cfloop collection="#arguments#" item="thisproperty">
							<cfif not listcontainsnocase("typename,timeframe,message",thisproperty)>
								AND #thisproperty#=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments[thisproperty]#" />
							</cfif>
						</cfloop>
		</cfquery>
		
		<cfif qObjects.recordcount>
			<cfinvoke method="fail" message="#arguments.message# #createobject('component',application.stCOAPI[arguments.typename].packagepath).getData(objectid=qObjects.objectid[1]).toString()#" />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	
	<cffunction name="assertUser" access="package" returntype="boolean" hint="Tests that the specified user exists">
		<cfargument name="userlogin" type="string" required="true" hint="The type of the object to check for" />
		<cfargument name="userdirectory" type="string" required="true" hint="Restricts the user to a specific user directory" />
		<cfargument name="userstatus" type="string" required="false" hint="Restricts the user to a specific status" />
		<cfargument name="message" type="string" required="false" default="" hint="The message to record on failure" />
		
		<cfset var qObjects = querynew("empty") />
		
		<cfquery datasource="#application.dsn#" name="qObjects">
			select		userLogin
			from		#application.dbowner#dmUser
			where		userlogin=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userlogin#" />
						<cfif structkeyexists(arguments,"userstatus")>
							AND userstatus=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userstatus#" />
						</cfif>
		</cfquery>
		
		<cfif not qObjects.recordcount>
			<cfinvoke method="fail" message="#arguments.message#" />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="assertUserGroup" access="package" returntype="boolean" hint="Tests that a user is assigned to a group">
		<cfargument name="userlogin" type="string" required="true" hint="The type of the object to check for" />
		<cfargument name="userdirectory" type="string" required="true" hint="Restricts the user to a specific user directory" />
		<cfargument name="group" type="string" required="true" hint="The group to check" />
		<cfargument name="message" type="string" required="false" default="" hint="The message to record on failure" />
		
		<cfset var qObjects = querynew("empty") />
		
		<cfquery datasource="#application.dsn#" name="qObjects">
			select		u.userid
			from		#application.dbowner#dmUser u
						inner join
						#application.dbowner#dmUserToGroup ug
						on u.userid=ug.userid
						inner join
						#application.dbowner#dmGroup g
						on ug.groupid=g.groupid
			where		u.userlogin=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userlogin#" />
						and (
							<cfif isnumeric(arguments.group)>
								g.groupid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#" />
							<cfelse>
								1=0
							</cfif>
							OR
							g.groupName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#" />
						)
		</cfquery>
		
		<cfif not qObjects.recordcount>
			<cfinvoke method="fail" message="#arguments.message#" />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	
	<cffunction name="assertVariable" access="package" returntype="boolean" hint="Tests that a specified variable has been declared and has the specified value">
		<cfargument name="variable" type="string" required="true" hint="The variable to check" />
		<cfargument name="value" type="string" required="false" hint="The value to check for" />
		<cfargument name="message" type="string" required="false" default="" hint="The message to record on failure" />
		
		<cfset var curval = evaluate(arguments.variable) />
		
		<cfif structkeyexists(arguments,"value") and curval neq arguments.value>
			<cfinvoke method="fail" message="#arguments.message#" />
		</cfif>
		
		<cfreturn true />
	</cffunction>

</cfcomponent>