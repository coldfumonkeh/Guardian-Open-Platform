<!---
Name: openAPI.cfc
Author: Matt Gifford (aka ColdFuMonkeh - http://www.mattgifford.co.uk)
Date: Tuesday 10th March 2009
Purpose: ColdFusion CFC Wrapper to interact with the Guardian Open Platform API (http://www.guardian.co.uk/open-platform)
Version: 1.1
Blog page: http://www.mattgifford.co.uk/guardianopenplatform/

Revision History:

17th August 2010 - 
	v 1.1 Substantial updates:
		- updated the API to handle JSON return format
		- revised arguments / parameters sent into each public method
		- added Section search method to return list of available sections within the API
		- added parse output option to init constructor method
		
10th March 2009
	v 1.0 Initial release

--->

<cfcomponent name="openAPI" hint="The main CFC for interaction with the Guardian Open Platform API">

	<cffunction name="init" access="public" returntype="any" output="false" hint="I am the constructor method.">
		<cfargument name="apikey" 		required="true" 				type="String" 	hint="I am the multimap API Key." />
		<cfargument name="parseOutput" 	required="false" default="true"	type="Boolean" 	hint="I am a boolean value. If set to true (default), I will return XML parsed, and serialize JSON output." />
			<cfset variables.instance = StructNew() />
			<cfset variables.instance.APIKey 		= arguments.apikey />
			<cfset variables.instance.parseOutput 	= arguments.parseOutput />
			<cfset variables.instance.rootURL 		= 'http://content.guardianapis.com/' />
		<cfreturn this />
	</cffunction>
	
	<!--- GETTERS / ACESSORS --->
	<cffunction name="getAPIKey" access="package" output="false" hint="I return the api key from the variables.instance scope.">
		<cfreturn variables.instance.APIKey />
	</cffunction>
	
	<cffunction name="getParse" access="package" output="false" hint="I return the parseOutput value from the variables.instance scope.">
		<cfreturn variables.instance.parseOutput />
	</cffunction>
	
	<cffunction name="getBaseURL" access="package" output="false" hint="I return the baseURL from the variables.instance scope.">
		<cfreturn variables.instance.rootURL />
	</cffunction>
	
	<!--- PUBLIC METHODS --->
	
	<!--- content search : Perform a paginated search of the content archive --->
	<cffunction name="search" access="public" returntype="any" output="true" hint="Perform a paginated search of the content archive.">
		<cfargument name="q" 				required="false" 	type="string" 	default="" 			hint="A string to search for. If omitted all content is returned." />
		<cfargument name="format" 			required="true" 	type="String" 	default="XML" 		hint="The return format of the requested content. XML or JSON." />
		<cfargument name="fromdate" 		required="false" 	type="string"	default="" 			hint="Returns only content published after and including this date. The date must be formatted YYYY-MM-DD, e.g. 2009-03-10." />
		<cfargument name="todate" 			required="false" 	type="string"	default="" 			hint="Returns only content published before and including this date. The date must be formatted YYYY-MM-DD, e.g. 2009-03-10." />
		<cfargument name="tag" 				required="false" 	type="String" 	default=""			hint="Instruct the API to return only results containing this tag or tags. Comma-separated list of tags if sending more than one." />
		<cfargument name="section" 			required="false" 	type="String" 	default=""			hint="Instruct the API to return only results published in this section. Comma-separated list of sections if sending more than one. Examples include NEWS, POLITICS, UK, WORLD, SOCIETY, MEDIA, ENVIRONMENT, SCIENCE, FOOTBALL, COMMENT, TRAVEL. Use the Section search method to obtain a full list of sections." />
		<cfargument name="showtags" 		required="false" 	type="String" 	default=""			hint="Specify which tags to return for each item in the search result recordset. KEYWORD, CONTRIBUTOR, TONE, TYPE or ALL." />
		<cfargument name="showfields" 		required="false" 	type="String" 	default=""			hint="Specify which fields to return for each item in the search result recordset. This is the content of the item. HEADLINE, BYLINE, BODY, TRAILTEXT, STANDFIRST, STRAP, SHORT-URL, THUMBNAIL, PUBLICATION or ALL." />
		<cfargument name="showrefinements" 	required="false" 	type="String" 	default=""			hint="Specify which refinements to return for each item in the search result recordset. Refinements will help filter the query into more specific and useful results. TONE, CONTRIBUTOR, SERIES, KEYWORD, TYPE, SECTION, BLOG or ALL." />
		<cfargument name="orderby" 			required="false" 	type="String" 	default="newest"	hint="Ask for the results to be ordered. NEWEST, OLDEST or RELEVANCE." />
		<cfargument name="pagesize" 		required="false" 	type="Numeric" 	default="10"		hint="Request a specific number of items returned per page up to a maximum of 50." />
		<cfargument name="page" 			required="false" 	type="Numeric"	default="1" 		hint="Instruct the API to return the result set from  particular page." />
			<cfset var stuParams 	= {} />
			<cfset var callIt 		= '' />
				<cfset stuParams = structCopy(arguments) />
				<cfset structInsert(stuParams, 'apikey', getAPIKey()) />
				<cfset callIt = callAPIMethod('search',stuParams) />
		<cfreturn handleReturnFormat(response=callIt,format=arguments.format) />
	</cffunction>
	
	<!--- tag search : Search for keyword tags within the API --->
	<cffunction name="tags" access="public" returntype="any" output="true" hint="Search for keyword tags within the API.">
		<cfargument name="q" 			required="false" 	type="string" 	default="" 		hint="A string to search for. If omitted all content is returned." />
		<cfargument name="format" 		required="true" 	type="String" 	default="XML" 	hint="The return format of the requested content. XML or JSON." />
		<cfargument name="type" 		required="true" 	type="String" 	default="" 		hint="Instruct the API to return only results from a specific tag type. KEYWORD, CONTRIBUTOR, TONE, SERIES or ALL." />
		<cfargument name="pagesize" 	required="false" 	type="Numeric" 	default="10" 	hint="Request a specific number of items returned per page up to a maximum of 50." />
		<cfargument name="page" 		required="false" 	type="Numeric"	default="1" 	hint="Instruct the API to return the result set from  particular page." />
			<cfset var stuParams 	= {} />
			<cfset var callIt 		= '' />
				<cfset stuParams = structCopy(arguments) />
				<cfset structInsert(stuParams, 'apikey', getAPIKey()) />
				<cfset callIt = callAPIMethod('tags',stuParams) />
		<cfreturn handleReturnFormat(response=callIt,format=arguments.format) />
	</cffunction>
	
	<!--- item : This endpoint provides a representation of an individual item of guardian.co.uk content --->
	<cffunction name="item" access="public" returntype="any" output="true" hint="Provides a representation of an individual item of guardian.co.uk content.">
		<cfargument name="itemID" 			required="true" 	type="string" 						hint="the specific ID number for the item you wish to retrieve.">
		<cfargument name="format" 			required="true" 	type="String" 	default="XML" 		hint="The return format of the requested content. XML or JSON." />
		<cfargument name="showtags" 		required="false" 	type="String" 	default=""			hint="Specify which tags to return for each item in the search result recordset. KEYWORD, CONTRIBUTOR, TONE, TYPE or ALL." />
		<cfargument name="showfields" 		required="false" 	type="String" 	default=""			hint="Specify which fields to return for each item in the search result recordset. This is the content of the item. HEADLINE, BYLINE, BODY, TRAILTEXT, STANDFIRST, STRAP, SHORT-URL, THUMBNAIL, PUBLICATION or ALL." />
		<cfargument name="showfactboxes" 	required="false" 	type="String" 	default=""			hint="Specify which factbox type to return for this content item." />
		<cfargument name="showmedia" 		required="false" 	type="String" 	default=""			hint="Specify which media asset type type to return for this content item. PICTURE, VIDEO, AUDIO, INTERACTIVE or ALL." />
		<cfargument name="showrelated" 		required="false" 	type="Boolean" 	default="false"		hint="Specify if you would like related content returned for this content item. TRUE or FALSE." />
			<cfset var stuParams 	= {} />
			<cfset var callIt			= '' />
				<cfset stuParams = structCopy(arguments) />
				<cfset structDelete(stuParams, 'itemID') />
				<cfset structInsert(stuParams, 'apikey', getAPIKey()) />
			<cfset callIt = callAPIMethod(arguments.itemID ,stuParams) />
		<cfreturn handleReturnFormat(response=callIt,format=arguments.format) />
	</cffunction>
	
	<!--- Sections search : return a list of all sections available within the API. --->
	<cffunction name="sections" access="public" returntype="any" output="true" hint="Search for Section details available within the API.">
		<cfargument name="format" required="true" type="String" default="XML" hint="The return format of the requested content. XML or JSON." />
			<cfset var callIt = '' />
				<cfset callIt = callAPIMethod('sections',arguments) />
		<cfreturn handleReturnFormat(response=callIt,format=arguments.format) />
	</cffunction>
	
	<!--- PRIVATE METHODS --->
		
	<cffunction name="buildParamString" access="private" output="false" returntype="String" hint="I loop through a struct to convert to query params for the URL.">
		<cfargument name="argScope" required="true" type="struct" hint="I am the struct containing the method params." />
			<cfset var strURLParam 	= '' />
				<cfloop collection="#arguments.argScope#" item="key">
					<cfif len(arguments.argScope[key])>
						<cfif listLen(strURLParam)>
							<cfset strURLParam = strURLParam & '&' />
						</cfif>						
						<cfset strURLParam = strURLParam & getCorrectParamName(key) & '=' & lcase(arguments.argScope[key]) />
					</cfif>
				</cfloop>
		<cfreturn strURLParam />
	</cffunction>
	
	<cffunction name="getCorrectParamName" access="private" output="false" hint="I return the correct param name for a key. The API required certain params with hyphenated names, and so we enforce that here for those cases where required.">
		<cfargument name="paramKey" required="true" type="String" hint="I am the param key." />
			<cfset var strCorrect = '' />
				<cfswitch expression="#arguments.paramKey#">
					<cfcase value="apikey">
						<cfset strCorrect = 'api-key' />
					</cfcase>
					<cfcase value="fromdate">
						<cfset strCorrect = 'from-date' />
					</cfcase>
					<cfcase value="todate">
						<cfset strCorrect = 'to-date' />
					</cfcase>
					<cfcase value="showtags">
						<cfset strCorrect = 'show-tags' />
					</cfcase>
					<cfcase value="showfields">
						<cfset strCorrect = 'show-fields' />
					</cfcase>
					<cfcase value="showrefinements">
						<cfset strCorrect = 'show-refinements' />
					</cfcase>
					<cfcase value="orderby">
						<cfset strCorrect = 'order-by' />
					</cfcase>
					<cfcase value="pagesize">
						<cfset strCorrect = 'page-size' />
					</cfcase>
					<cfcase value="showfactboxes">
						<cfset strCorrect = 'show-factboxes' />
					</cfcase>
					<cfcase value="showmedia">
						<cfset strCorrect = 'show-media' />
					</cfcase>
					<cfcase value="showrelated">
						<cfset strCorrect = 'show-related' />
					</cfcase>
					<cfdefaultcase>
						<cfset strCorrect = lcase(arguments.paramKey) />
					</cfdefaultcase>
				</cfswitch>
			<cfreturn strCorrect />
	</cffunction>
	
	<cffunction name="callAPIMethod" access="private" returntype="any" output="true" hint="I make the call to the API to retrieve the data, and reorder the arguments for the URL string.">
		<cfargument name="methodName" 	type="string" required="false" default="" 	hint="I am the name of the method you wish to seach within the API." />
		<cfargument name="methodParams" type="struct" required="false" 				hint="I am the arguments to send to the cfhttp API call." />			
			<cfset var strRemoteCall = getBaseURL() & '#arguments.methodName#?' />
				<cfset strRemoteCall = strRemoteCall & buildParamString(arguments.methodParams) />
			<cfhttp url="#strRemoteCall#" result="callResult" />			
		<cfreturn callResult.filecontent />
	</cffunction>
		
	<cffunction name="handleReturnFormat" access="private" output="false" hint="I handle the return of the response based upon the requested format, and if it will be parsed.">
		<cfargument name="response" required="true" type="Any" 		hint="I am the response data." />
		<cfargument name="format" 	required="true" type="String" 	hint="I am the requested response format." />
			<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfset xmlParse = xmlParse(arguments.response) />
					<cfif getParse()>
						<cfreturn xmlparse(arguments.response) />
					<cfelse>
						<cfreturn arguments.response />
					</cfif>
				</cfcase>
				<cfcase value="json">
					<cfif getParse()>
						<cfreturn deserializeJSON(arguments.response) />
					<cfelse>
						<cfreturn serializeJSON(deserializeJSON(arguments.response)) />
						<cfabort>
					</cfif>
				</cfcase>
			</cfswitch>
	</cffunction>
	
	<!--- --->
	<cffunction name="getJSONRequest" access="private" returnType="string" output="no">
	    <cfscript>
	        var size=GetPageContext().getRequest().getInputStream().available();
	        var emptyByteArray = createObject("java", "java.io.ByteArrayOutputStream").init().toByteArray();
	        var byteClass = createObject("java", "java.lang.Byte").TYPE;
	        var byteArray = createObject("java","java.lang.reflect.Array").newInstance(byteClass, size);
	        GetPageContext().getRequest().getInputStream().readLine(byteArray, 0, size);
	        createObject('java', 'java.lang.System').out.println("{GetJSONRequest} ByteArray.ToString=" &ToString( byteArray     ) );    
	        return ToString( byteArray );
	    </cfscript>
	</cffunction>
	
	<cffunction name="xmlStrip" access="private" returntype="xml" output="true" hint="I help with stripping out tags and tidying up the returned XML.">
		<cfargument name="xmlIn" required="true" type="xml" hint="the XML retrieved from the CFHTTP request." />
			<cfset var originalXML 	= arguments.xmlIn />
			<cfset var xmlOut 		= '' />
				<cfset xmlOut = originalXML.ReplaceAll("(</?)(\w+:)","$1") />
				<cfset xmlOut = xmlOut.ReplaceAll("xmlns(:\w+)?=""[^""]*""","") />
		<cfreturn xmlOut />
	</cffunction>
	
</cfcomponent>