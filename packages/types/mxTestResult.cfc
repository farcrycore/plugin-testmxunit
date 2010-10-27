<cfcomponent displayname="Test Result" hint="The results from a automatic test run" extends="farcry.core.packages.types.types" output="false">
	<cfproperty ftSeq="1" ftFieldSet="Test Result" ftLabel="Test Case"
				name="mxTestID" type="uuid"
				ftJoin="mxTest" ftRenderType="list" />
	<cfproperty ftSeq="2" ftFieldSet="Test Result" ftLabel="Pass"
				name="numberPassed" type="numeric" ftType="integer" />
	<cfproperty ftSeq="3" ftFieldSet="Test Result" ftLabel="Dependency failure"
				name="numberDependency" type="numeric" ftType="integer" />
	<cfproperty ftSeq="4" ftFieldSet="Test Result" ftLabel="Failed"
				name="numberFailed" type="numeric" ftType="integer" />
	<cfproperty ftSeq="5" ftFieldSet="Test Result" ftLabel="Error"
				name="numberErrored" type="numeric" ftType="integer" />
	<cfproperty ftSeq="6" ftFieldSet="Test Result" ftLabel="Details"
				name="details" type="longchar" />
	
	<cffunction name="ftEditDetails" access="public" returntype="string" description="This will return a string of formatted HTML text to enable the editing of the property" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		<cfset var wddxDetails = "" />
		
		<cfif len(arguments.stMetadata.value) and isxml(arguments.stMetadata.value)>
			<cfwddx action="wddx2cfml" input="#arguments.stMetadata.value#" output="wddxDetails" />
			<cfsavecontent variable="html"><cfdump var="#wddxDetails#" expand="false" label="Result details" /></cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>
	
</cfcomponent>