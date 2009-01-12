
<!---
Wrapper for HtmlRunner
 --->
 <cfsetting showdebugoutput="false" />
 <cfparam name="url.test" default="" />
 <cfparam name="url.componentPath" default="" />
 <cfparam name="url.output" default="extjs" />
<html>
<head>

 <title>MXUnit HTML Test Runner</title>

</head>
<body>
 <cfscript>
   testIsPresent = cgi.path_info is not "" OR url.test is not "";
   testToRun =  iif(cgi.path_info is "", de(url.test), de(cgi.path_info));
  </cfscript>


  <cfoutput>
  <div style="padding:4;width:100%;overflow:auto">
  <form id="runnerForm" action="index.cfm" method="get">
 &nbsp;&nbsp;<img src="../images/no-bugs.gif" align="left">
 <h2 style="color:navy;font-family:verdana;font-weight:bold;font-size:14px">
 &nbsp;&nbsp;&nbsp;Enter a TestCase,TestSuite, or Directory &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  (<code>componentPath</code> if Directory):
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <br />
 &nbsp;&nbsp;&nbsp;<input type="text" id="test" name="test" value="#testToRun#" size="60" />
 <input type="text" id="componentPath" name="componentPath" value="#url.componentPath#" size="30" />
 <br />
 &nbsp;&nbsp;&nbsp;<input type="submit" value="Run">
 <input type="button" value="Clear" onclick="document.forms[0].test.value='';location.href='./index.cfm'" />

  <input type="button" value="?" onClick="toggleHelp()" />


 <div id="help" style="position:relative;left:100;border:1px ridge silver;visibility:hidden;display:none;width:584;padding:4">
  Usage:
  <p style="font-size:11px;font-weight:normal">
  TestCase example:  <code style="color:darkred">mxunit.tests.framework.AssertTest</code> [<a href="##" onClick="runExample('mxunit.tests.framework.AssertTest','')">Try</a>]<br />
  TestSuite example: <code style="color:darkred">mxunit.tests.framework.fixture.ATestSuite</code> [<a href="##" onClick="runExample('mxunit.tests.framework.fixture.ATestSuite','')">Try</a>]<br />
  Directory example: <code style="color:darkred">C:\CFusionMX7\wwwroot\mxunit\tests\samples\</code> [<a href="##" onClick="runExample('C:\\CFusionMX7\\wwwroot\\mxunit\\tests\\samples\\','mxunit.tests.samples')">Try</a>]<br />

  </p>

 <script>
 function runExample(example,cp){
 document.getElementById('test').value = example;
 document.getElementById('componentPath').value = cp;
 document.getElementById('runnerForm').submit();

 }

 function toggleHelp(){
  var help = document.getElementById('help');
  var hidden = help.style.visibility == 'hidden';
  if(hidden){
   help.style.visibility = 'visible';
   help.style.display = 'block';
  }
  else{
    help.style.visibility = 'hidden';
    help.style.display = 'none';
  }
 }
 </script>
 </div>

 </form>
 </cfoutput>
 </h2>
 </div>
 <cfif testToRun is not "">
 <cfinvoke component="HtmlRunner" method="run" test="#testToRun#" componentPath="#url.componentPath#" output="#url.output#" >
 </cfif>

</body>
</html>

