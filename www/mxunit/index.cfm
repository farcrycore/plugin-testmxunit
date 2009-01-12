<html>
<head>
    <title>MXUnit - Unit Test Framework and Eclipse Plugin for Adobe ColdFusion</title>
    <meta name="keywords" value="coldfusion unit testing test cfmx xunit developer framework quality assurance open source community free" />
    <link rel="stylesheet" type="text/css" href="resources/ExtStart.css">

  <style>
   a {font-weight:normal}
  </style>
</head>
<body>
<table width="100%" cellpadding="0" cellspacing="0" style="border:0">
<tr>
<td nowrap="true">
  <h1 style="height:76;padding-bottom:12">
  <img style="font-size:11px;position:absolute;left:0;top:0;" src="images/no-bugs.gif" border="0" alt="Download to get rid of those pesky bugs." align="absmiddle">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 MXUnit <span style="font-size:11px;position:absolute;left:82;top:40;color:gray;font-family:serif"> Unit Testing framework for ColdFusion developers</span>

  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;


  <a href="doc/api/index.cfm" style="font-size:12pt" title="Local API Documentation">API</a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href=" http://mxunit.org/doc/index.cfm" style="font-size:12pt;" title="Documentation, Tutorials, etc ...">Tutorials and Documentation</a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="http://groups.google.com/group/mxunit/topics" style="font-size:12pt"> Support </a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="http://mxunit.org/blog" style="font-size:12pt"> Blog </a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="generator/index.cfm" style="font-size:12pt" title="Alpha"> Test Stub Generator</a>
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="samples/samples.cfm" style="font-size:12pt;"> Samples </a>
  </h1>
</td>
</tr>
</table><br />
    <div id="content">
     <div align="center">
     <cfoutput>

     </cfoutput>
  <cftry>
   <cfset cfMajorVersion = left(server.coldfusion.productversion,1) />
   <cfset cfProductName =  server.coldfusion.productname />

   <cfif cfProductName is "Railo">
      <cfthrow type="mxunit.exception.RailoVersionException">
   </cfif>
   
   <cfif find("BlueDragon",cfProductName )>
      <cfthrow type="mxunit.exception.BlueDragonVersionException">
   </cfif>

  <cfif cfMajorVersion lt 7>
   <cfthrow type="mxunit.exception.UnsupportedVersionException">
  </cfif>

  <cfscript>
    // @pre path to framework/ComponentUtils is static
    // This is all because we do not know the environment where mxunit it installed.
    // This helps somewhat. The Call to CFCProxy is a nice way to find out
    //  where we are ...
    context  = getDirectoryFromPath(getCurrentTemplatePath());
    proxy = CreateObject("java", "coldfusion.cfc.CFCProxy").init("#context#framework/ComponentUtils.cfc");
    proxy.setAutoFlush(false);
    args = arrayNew(1);
    componentUtils = structNew();
    componentUtils = proxy.invoke("ComponentUtils",args);
    componentUtilsName = getMetaData(componentUtils).name;
    componentRoot = componentUtils.getComponentRoot(componentUtilsName);
    testCase = '
<cfcomponent displayname="MxunitInstallVerificationTest" extends="#componentRoot#.framework.TestCase">

<cffunction name="testThis" >
  <cfset assertEquals("this","this") />
  </cffunction>

  <cffunction name="testThat" >
    <cfset assertEquals("this","that", "This is an intentional failure so you see what it looks like") />
  </cffunction>

  <cffunction name="testSomething" >
  <cfset assertEquals(1,1) />
  </cffunction>


  <cffunction name="testSomethingElse">
    <cfset assertTrue(true) />
  </cffunction>

</cfcomponent>';

  </cfscript>

<cffile action="write" file="#context#MXunitInstallTest.cfc" output="#testCase#" />

<cfscript>
  testSuite = createObject("component","#componentRoot#.framework.TestSuite").TestSuite();
  testSuite.addAll("#componentRoot#.MXunitInstallTest"); //Identical to above
  results = testSuite.run();
</cfscript>
<cfparam name="url.output" default="extjs">

    <div class="myDiv" align="center">
    <div style="font-size:14pt;font-weight:bold;">Congratulations! You have successfully installed MXUnit.</div>
    <cfoutput>
    #results.getResultsOutput(url.output)#
    </cfoutput>
    </div>


   <cfcatch type="mxunit.exception.RailoVersionException">
      <cfoutput>
        <div align="center" style="padding-left:50">
       <h2 align="center">Congratulations, Railo User!</h2>
       You have installed MXUnit. Please check out the <a href="samples/samples.cfm">samples</a>
       to verify MXUnit works as expected.
       </div>
      </cfoutput>
  </cfcatch>
  
  <cfcatch type="mxunit.exception.BlueDragonVersionException">
      <cfoutput>
        <div align="center" style="padding-left:50">
       <h2 align="center">Congratulations, BlueDragon User!</h2>
       You have installed MXUnit. Please check out the <a href="samples/samples.cfm">samples</a>
       to verify MXUnit works as expected.
       </div>
      </cfoutput>
  </cfcatch>


  <cfcatch type="mxunit.exception.UnsupportedVersionException">
    <cfoutput>
      <div align="left" style="padding-left:50">
     <h2 align="center">#cfcatch.type#</h2>
     This installation verification page does not support your verions of ColdFusion
     (<strong>#server.coldfusion.productversion#</strong>).
     The MXUnit framework was likely installed
     with success and can be used with the Eclipse Plug-in, but <em>this page </em>was
     designed for CFMX7 and later.
     </div>
    </cfoutput>
  </cfcatch>


  <cfcatch type="any">
  <div class="myDiv" align="center">
    <span style="font-size:14pt;font-weight:bold;">Ooops! There was a problem with running the installation test</span>
    <br /><br /><div>
    <strong>These are the errors as reported by ColdFusion:</strong>

    <cfoutput>
     <xmp>Type: #cfcatch.Type#
    Message: #cfcatch.message#
    Detail: #cfcatch.detail#
    </cfoutput>
    </xmp>

    <h3>Also, make sure you or ColdFusion has write access to this directory
    in order to run this installation test.</h3>
    </div>

  </div>
  </cfcatch>
 </cftry>

  </div>
  <p>&nbsp;</p>




  <div align="center">
  <hr size="1"  style="width:98%" />
   <a href="http://mxunit.org/license.txt" title="Copyleft - GNU 3.0 Public License"><img border="0" src="images/copyleft.png" align="absmiddle" title="Copyleft - GNU 3.0 Public License"> <cfoutput>#year(now())# MXUnit.org</cfoutput></a>
  </div>
</body>
</html>
