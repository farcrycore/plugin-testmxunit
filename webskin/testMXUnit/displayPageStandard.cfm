<cfsetting enablecfoutputonly="true" /> 
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License:
	
--->
<!--- @@displayname: --->
<!--- @@description: displayPageStandard --->
<!--- @@author: Rob Rohan on 2008-12-31 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.method" default="" />

<cfset testSuite = createObject(
	"component", 
	"mxunit.framework.TestSuite"
).TestSuite() />

<cfscript>
	////////////////////////////////////////////////////////////////////////////
	// Example of adding single tests for your application
	testSuite.addAll("farcry.plugins.testMXUnit.tests.ExampleTest");
	
	results = testSuite.run(testMethod=url.method);
</cfscript>

<!--- Other output formats. The XML one might be pretty useful. The extjs one
	doesn't work likely due to mappings. I've left it broken though so we don't
	break compatibility with mxunit. --->
<!--- ['html', 'extjs', 'xml', 'junitxml', 'query', 'array'] --->
<cfoutput>#results.getResultsOutput('html')#</cfoutput>

<!--- If you have a lot of tests, you can also run a directory of tests at one
	time using the following: --->
<!--- <cfinvoke 
	component="mxunit.runner.DirectoryTestSuite"   
	method="run"
	directory="#expandPath('../../../plugins/apiYouTubePublic/tests')#"
	componentPath="farcry.plugins.apiYouTubePublic.tests"
	recurse="false"
	excludes="GatewayBaseTest,YouTubeTest"
	returnvariable="results" 
/>
<cfoutput>#results.getResultsOutput('extjs')#</cfoutput> --->

<cfsetting enablecfoutputonly="false" />