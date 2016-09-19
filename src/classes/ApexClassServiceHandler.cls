public with sharing class ApexClassServiceHandler {
    
    public Map<String, Map<String, List<String>>> classwiseMap = new Map<String, Map<String, List<String>>>();
    public Map<String, List<String>> SummaryMap = new Map<String, List<String>>();
    public Map<String, List<String>> typeWiseMap;
    public MetadataAPI mapi = new MetadataAPI();
    Public List<ApexClass> lstAllAPexClasses=new List<ApexClass>();
    
    Public static List<String> SearchInClass(List<String> searchKeywords)
    {
        List<String> lstDependentCLasses = new List<String>();
        String keywordsToSearch;
        set<String> ClassSummary = new set<String>();
        List<String> lstclasses=new List<String>();
        for(String s:searchKeywords)
        {
        	keywordsToSearch=keywordsToSearch+s+' '+'OR ';
        }
        String preFinalString=keywordsToSearch.removeStart('null');
        String FinalString=preFinalString.removeEndIgnoreCase('OR ');
        //SOSL Dynamic Query
        String SearchQuery = 'FIND {'+FinalString+'}RETURNING ApexClass(Name)';
        List<Search.SearchResult> ClassSearchResult=ConfigurationSelector.selectclasses(SearchQuery);
        //Retriving Keyword Used in Class
        for (Search.SearchResult searchResult : ClassSearchResult) { 
        ApexClass Classes = (ApexClass) searchResult.getSObject(); 
        ClassSummary.add(Classes.Name);
        }
        ClassSummary.removeAll(searchKeywords);
        lstclasses.addAll(ClassSummary);
        return lstclasses; 
    }
    
    Public static List<String> SearchInTrigger(List<String> searchKeywords)
    {
        String keywordsToSearch;
        List<String> TriggerSummary = new list<String>();
        for(String s:searchKeywords)
        {
        	keywordsToSearch=keywordsToSearch+s+' '+'OR ';
        }
        String preFinalString=keywordsToSearch.removeStart('null');
        String FinalString=preFinalString.removeEndIgnoreCase('OR ');
        String SearchQuery = 'FIND {'+FinalString+'}RETURNING ApexTrigger(name)';
        List<Search.SearchResult> TriggersearchResults=ConfigurationSelector.selectTriggers(SearchQuery);
        //Retriving Keyword Used in Triggers
        for (Search.SearchResult TriggersResults : TriggersearchResults) { 
        ApexTrigger Triggers = (ApexTrigger) TriggersResults.getSObject();
            TriggerSummary.add(Triggers.Name);
        }
        return TriggerSummary;  
    }
    
    Public static List<String> SearchInPage(List<String> searchKeywords)
    {        
        //Retriving Keyword Used in Pages
        List<String> PageNames = new List<String>();
        PageNames=ConfigurationSelector.selectApexPages(searchKeywords);
        return PageNames;
    }

    
    public static string generateJsonForApexPage(List<ApexClass> lstAllApexClasses){
    	JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('data');
        gen.writeStartArray();
        Integer count = 1;	
        
        for(ApexClass apexClassObj: lstAllAPexClasses){
         	gen.writeStartObject();
        	gen.writeStringField('id', String.valueOf(count));
        	gen.writeStringField('configID', apexClassObj.ID);
        	gen.writeStringField('name', apexClassObj.Name);
        	gen.writeStringField('enbl', '0');
        	gen.writeStringField('level', '0');
        	gen.writeStringField('parent', '');
        	gen.writeStringField('isLeaf', 'false');
        	gen.writeStringField('expanded', 'false');
        	gen.writeStringField('loaded', 'false');
        	gen.writeEndObject();
			count++;
        }
         gen.writeEndArray();
        gen.writeEndObject();
        System.debug('gen.getAsString()='+gen.getAsString());
        return gen.getAsString();
    }
    
    
    public static string generateJson(List<String> lstComponents){
    	JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('data');
        gen.writeStartArray();
        Integer count = 1;	
        
        for(String apexClassObj: lstComponents){
         	gen.writeStartObject();
        	gen.writeStringField('id', String.valueOf(count));
        	gen.writeStringField('configID', '');
        	gen.writeStringField('name', apexClassObj);
        	gen.writeStringField('enbl', '0');
        	gen.writeStringField('level', '0');
        	gen.writeStringField('parent', '');
        	gen.writeStringField('isLeaf', 'false');
        	gen.writeStringField('expanded', 'false');
        	gen.writeStringField('loaded', 'false');
        	gen.writeEndObject();
			count++;
        }
         gen.writeEndArray();
        gen.writeEndObject();
        System.debug('gen.getAsString()='+gen.getAsString());
        return gen.getAsString();
    }
    
    
    
    public static void deleteclasses(List<String> lstClassesToDelete,List<String> lstDependentClasses,List<String> lstDependentTriggers ,List<String> lstDependentPages)
    {
    	lstDependentClasses=SearchInClass(lstClassesToDelete);
    	lstDependentPages=SearchInPage(lstClassesToDelete);
    	lstDependentTriggers=SearchInTrigger(lstClassesToDelete);	
    	String sessionId=UserInfo.getSessionId();
    	Integer count = System.purgeOldAsyncJobs(Date.today()+1);
    	Database.executeBatch(new CommentDependentClassBatch(lstClassesToDelete,lstDependentClasses,sessionId),10);
    	Database.executeBatch(new CommentDependentTriggersBatch(lstClassesToDelete,lstDependentTriggers,sessionId),10);
    	Database.executeBatch(new CommentDependentPagesBatch(lstClassesToDelete,lstDependentPages,sessionId),10);
    }
}