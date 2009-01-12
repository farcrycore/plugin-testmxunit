<cfcomponent displayname="MyComponent" >  
  <cffunction name="add" access="public" returntype="numeric">  
    <cfargument name="num1" type="numeric" />  
    <cfargument name="num2" type="numeric" />  
    <cfreturn num1+num2>  
    </cffunction>  
</cfcomponent>