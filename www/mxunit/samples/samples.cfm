<html>
<head>
    <title>MXUnit Unit Test Samples</title>

    <!-- Include Ext stylesheets here: -->
    <link rel="stylesheet" type="text/css" href="../resources/ext2/resources/css/ext-all.css">
    <link rel="stylesheet" type="text/css" href="../resources/ExtStart.css">
</head>
<body>
<h1 style="height:76;padding-bottom:12">
<img style="font-size:11px;position:absolute;left:0;top:0;" src="../images/no-bugs.gif" border="0"  align="absmiddle">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 MXUnit Unit Test Samples</h1>
<p><h3 style="width:600;padding:12;font-size:11pt">
Note that these samples assume installation of MXUnit <span style="color:darkred">directly under the web root.</span>
The MXUnit Framework and Eclipse Plugin will still work, but the samples will not. You can
change the <code>extends="mxunit.framework.TestCase"</code> to the path of your installation and
the samples will run correctly.
</h3> </p>
<cfdirectory action="list" directory="#getDirectoryFromPath(getCurrentTemplatePath())#" name="samples">
<div style="padding-left:20">
<table style="border:1px ridge black;padding:8;width:450">
<tr>
  <th style="font-weight:bold">Testcase/TestSuite</th>
  <th style="font-weight:bold">Click To Run</th>
</tr>
<tr style="background-color:silver;padding:0">
 <td colspan="2"></td>
</tr>
<cfoutput query="samples">
 <cfset excludes = ".svn,.,MyComponent.cfc,samples.cfm,ScheduledRun.cfm,tests" >
 <cfif not listfind(excludes,name)>
 <cfset isCfc = find(".cfc",name)>
 <cfset u = iif(isCfc, de("#name#?method=runtestremote&output=extjs"),de("#name#")) />
 <tr>
   <td>#name#</td>
   <td><a href="#u#" target="_blank">Run!</a></td>
 </tr>
 </cfif>
</cfoutput>
</table>
<p></p>


<!--- <cfdump var="#samples#" /> --->


 </div>
  <p>&nbsp;</p>




  <div align="center">
  <hr size="1"  style="width:98%" />
   <a href="http://mxunit.org/license.txt" title="Copyleft - GNU 3.0 Public License"><img border="0" src="../images/copyleft.png" align="absmiddle" title="Copyleft - GNU 3.0 Public License"> <cfoutput>#year(now())# MXUnit.org</cfoutput></a>
  </div>
</body>
</html>