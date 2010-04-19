<!--- THIS WILL BE INCLUDED AFTER THE FARCRY INIT HAS BEEN RUN BUT ONLY ON APPLICATION INITIALISATION. --->
<cfsetting enablecfoutputonly="yes">

<cftry>
	<cfset application.stPlugins.textMXUnit.seleniumServer = createObject("java", "org.openqa.selenium.server.SeleniumServer").init(application.config.testing.seleniumport) />
	<cfset application.stPlugins.textMXUnit.seleniumServer.start() />
	
	<cfcatch></cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">