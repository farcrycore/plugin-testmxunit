<cfcomponent displayname="Testing" extends="farcry.core.packages.forms.forms" output="false" key="testing" hint="Define how testing works in this application">
	<cfproperty ftSeq="1" ftFieldset="Testing" name="mode" type="string" ftLabel="Mode" ftType="list" ftList="self:Self testing,app:Test appliance" ftDefault="self" />

	<cfproperty ftSeq="11" ftFieldSet="Selenium" name="browser" type="string" ftLabel="Browser" ftDefault="*chrome" ftHint="Other options are " />
	
</cfcomponent>