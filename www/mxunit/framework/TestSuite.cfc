<cfcomponent displayname="TestSuite" extends="Test" hint="Responsible for creating and running groups of Tests.">

  <cfset cu = createObject("component","ComponentUtils")>
  <cfparam name="this.testSuites" default="#structNew()#" />

  <cfparam name="this.tests" default="#arrayNew(1)#" />
  <!--- Generated content from method --->
  <cfparam name="this.c" default="Error occurred. See stack trace." />


<cffunction name="TestSuite" access="public" returntype="TestSuite" hint="Constructor">
  <!--- redundant? --->
  <cfset this.testSuites = structNew() />
  <cfreturn this />
</cffunction>



 <cffunction name="addTest" access="remote" returntype="void" hint="Adds a single TestCase to the TestSuite.">

  <!---
   Should be of Type "Test". Since All TestCases and TestSuites
   are inherited from Test, we should be able to add them here

   Also, need to
   --->

  <cfargument name="componentName" type="string" required="yes" />
  <cfargument name="method" type="string" required="yes" />
  <cfargument name="componentObject" type="Any" required="no" default="">

  <cfscript>
   try{

     this.tempStruct = structNew();
     this.tempStruct.ComponentObject = arguments.ComponentObject;
     //If the test suite exists get the method array and
     //append the new method name ...
     // update an existing test suite
     if (structKeyExists(this.testSuites, componentName)) {
      this.tempStruct = structFind(this.testSuites, arguments.componentName);
      tempArray = structFind(this.tempStruct, "methods");
      arrayAppend(tempArray,arguments.method);
      //writeoutput(tempArray[1] & "  "  & tempArray[2]);
      structUpdate(this.tempStruct, "methods", tempArray);
      structUpdate(this.testSuites,arguments.componentName, this.tempStruct);
     }
     else{
       //Begin a new test Suite
       structInsert(this.testSuites, arguments.componentName, this.tempStruct);
       //Grab all the methods that begin with the string 'test' ...
       tests = listToArray(arguments.method);
       structInsert(evaluate("this.testSuites." & arguments.componentName), "methods", tests);
     }
    }
    catch (Exception e) {
      writeoutput(e.getMessage());
    }
  </cfscript>
</cffunction>



<!--- Maybe should be named addList --->
<!--- Adds a list of methods belonging to a component into a testSuite object --->
<cffunction name="add" access="remote" returntype="void" hint="Adds a list of TestCases to the TestSuite">
  <cfargument name="componentName" type="Any" required="yes" />
  <cfargument name="methods" type="string" required="yes" />
  <cfargument name="componentObject" type="Any" required="no" default="">
  <cfscript>
   try{
      //If the component already has methods, just update the method array
      if ( structKeyExists(this.testSuites,arguments.componentName) ) {

         tests = structFind(this.testSuites, arguments.componentName);
         for( i = 1; i lte listLen(arguments.methods); i = i + 1 ) {
            arrayAppend(tests.methods, listGetAt(arguments.methods,i));
         }
        return;
       }

     //else convert the list of methods to an array and add it to the test suite
     this.tempStruct = structNew();
     this.tempStruct.ComponentObject = arguments.ComponentObject;
     this.tempStruct.methods = listToArray(arguments.methods);
     this.testSuites[arguments.componentName] = this.tempStruct;
    }
    catch (any e) {
      writeoutput("Error Adding Tests : " & e.getType() & "  " &  e.getMessage() & " " & e.getDetail());
    }
  </cfscript>
</cffunction>



<cffunction name="addAll" access="remote" returntype="any" output="false" hint="Adds all runnable TestCases to the TestSuite">
  <cfargument name="ComponentName" type="any" required="yes" />
  <cfargument name="ComponentObject" type="any" required="false" default="">
  <cfset var a_methods = "">

  <cfif isSimpleValue(arguments.ComponentObject)>
   	<cfset ComponentObject = createObject("component",arguments.ComponentName) />
  </cfif>
	<cfset a_methods = ComponentObject.getRunnableMethods()>
	
  	<cfset add(arguments.ComponentName,ArrayToList(a_methods),ComponentObject)>
  <cfreturn this />
</cffunction>


<cffunction name="run" returntype="WEB-INF.cftags.component" access="remote" output="true" hint="Primary method for running TestSuites and individual tests.">
  <cfargument name="results" hint="The TestResult collecting parameter." required="no" type="TestResult" default="#createObject("component","TestResult").TestResult()#" />
	<cfargument name="testMethod" hint="A single test method to run." type="string" required="no" default="">
	<cfset var methods = ArrayNew(1)>
	<cfset var o = "">
	<cfset var start = "">
	<cfset var end = "">
	<cfset var i = "">
	<cfset var j = "">
	<cfset var methodName = "">

   <cfset var components = structKeyArray(this.suites()) />
   <!---  //Returns a structure corresponding to the key/componentName --->
   <cfset var temp = this.suites() />

   <cfloop from="1" to="#arrayLen(components)#" index="i">
    <cfset this.suites = structFind(temp, components[i] ) />

	<cfif len(arguments.testMethod)>
		<cfset methods[1] = arguments.testMethod>
	<cfelse>
		 <cfset methods = structFind(this.suites, "methods") />
	</cfif>


    <cfset componentObject = structFind(this.suites,"ComponentObject")>
    <cfif isSimpleValue(componentObject)>
      <cfset o = createObject("component", components[i]).TestCase(componentObject) />
    <cfelse>
      <cfset o = componentObject.TestCase(componentObject)>
    </cfif>



    <cfloop from="1" to="#arrayLen(methods)#" index="j">
		<cfset   methodName = methods[j] />
      	<cfset this.c = "">
     <cfset  start = getTickCount() />

     <cftry>
		<cfset  results.startTest(methodName,components[i]) />
       <!---  //Get start time    //Execute the test --->

		 <cfinvoke component="#o#" method="setUp">

      <cfsavecontent variable="this.c">
		   <cfinvoke component="#o#" method="#methodName#">
      </cfsavecontent>

       <cfset  results.addSuccess('Passed') />
       <cfset  results.addContent(this.c) /> <!--- //Add the trace message from the TestCase instance --->

	 <cfcatch type="mxunit.exception.AssertionFailedError">
        <cfset results.addFailure(cfcatch) />
        <cfset results.addContent(this.c) /><!--- Bill::10.04.07 Not sure if this will work... --->
        <cflog file="mxunit" type="error" application="false" text="#cfcatch.message#::#cfcatch.detail#">
      </cfcatch>
      <cfcatch type="any">
		<cfset o.debug(cfcatch)>
        <cfset results.addError(cfcatch) />
        <cfset results.addContent(this.c) />
        <cflog file="mxunit" type="error" application="false" text="#cfcatch.message#::#cfcatch.detail#" />
      </cfcatch>

      </cftry>

	<cftry>
		<cfinvoke component="#o#" method="tearDown">
	<cfcatch type="any">
		<cfset results.addError(cfcatch)>
	</cfcatch>
	</cftry>

	<cfset  results.addTrace( o.getTrace() ) />
	<!--- //add the deubg array to the test result item --->
	<cfset  results.setDebug( o.getDebug()) />
	<!--- // make sure the debug buffer is reset for the next text method  --->
	<cfset  o.clearDebug()  />
	<!---  //reset the trace message.Bill 6.10.07 --->
	<cfset  o.traceMessage="" />
	<cfset  end = getTickCount() />
	<cfset  results.addProcessingTime(end-start) />

    <cfset results.endTest(methodName) />

    </cfloop> <!--- end j loop --->


    </cfloop><!--- end i loop --->
   <cfset results.closeResults() /><!--- Get correct time run for suite --->
  <cfreturn results />
</cffunction>

<cffunction name="runTestRemote" access="remote" output="true">
  <cfargument name="output" type="string" required="false" default="extjs" hint="Output format: html,xml,junitxml,extjs "><!--- html,xml,junitxml,extjs --->
  <cfargument name="debug" type="boolean" required="false" default="false" hint="Flag to indicate whether or not to dump the test results to the screen.">
  <cfscript>
   var result = this.run();
   switch(arguments.output){
    case 'html':
      writeoutput(result.getHtmlresults());
    break;

    case 'xml':
      writeoutput(result.getXmlresults());
    break;

    case 'junitxml':
    writeoutput(result.getJUnitXmlresults());
    break;

    case 'extjs':
    writeoutput('<body>#result.getEXTresults("TestSuite Runner")#<div id="testresultsgrid" class="bodypad"></div></body>');
    break;

    default:
     writeoutput(result.getHtmlresults());
    break;
   }

  </cfscript>
  <cfif arguments.debug>
	<p>&nbsp;</p>
    <cfdump var="#result.getResults()#" label="Raw Results Dump">
  </cfif>

</cffunction>


<cffunction name="suites" access="public" returntype="struct">
 <cfreturn this.testSuites />

</cffunction>

<cffunction name="stringValue" access="remote" returntype="string">
  <cfreturn this.suites().toString() />

</cffunction>

<cffunction name="dump">
 <cfargument name="o">
  <cfdump var="#o#">
</cffunction>

</cfcomponent>







