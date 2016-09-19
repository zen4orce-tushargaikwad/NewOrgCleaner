public with sharing class ApexClassService {
    
    public String apexClassJson{get; set;}
    public string dependentClassesJson{get; set;}
    public string dependentPagesJson{get; set;}
    public string dependentTriggersJson{get; set;}
    Public List<ApexTrigger> triggerList=new List<ApexTrigger>();
    public List<ApexPage> visualforcePageList {get; set;}
    
    public List<String> lstDependentPages;
   	public List<String> lstDependentClasses;
   	public List<String> lstDependentTriggers;
    
    public List<String> selectedClasses;
    public String ConfigurationList{get;set;}
    public string ConfigName{get;set;}
    
    public ApexClassService(){
        List<ApexClass> lstAllAPexClasses=new List<ApexClass>();
        lstAllAPexClasses=ConfigurationSelector.getApexClasses();
        apexClassJson = ApexClassServiceHandler.generateJsonForApexPage(lstAllAPexClasses);
        System.debug('apexClassJson='+apexClassJson);
    }

   	public void dependents(){
   		selectedClasses=new List<String>();
   		for(String s:ConfigurationList.split(','))
   		{
   			selectedClasses.add(s);
   		}
   		lstDependentPages=new List<String>();
   		lstDependentClasses = new List<String>();
   		lstDependentTriggers =  new List<String>();
   		lstDependentPages=ApexClassServiceHandler.SearchInPage(selectedClasses);
   		lstDependentClasses=ApexClassServiceHandler.SearchInClass(selectedClasses);
   		lstDependentTriggers=ApexClassServiceHandler.SearchInTrigger(selectedClasses);
   		dependentClassesJson=ApexClassServiceHandler.generateJson(lstDependentClasses);
   		dependentPagesJson=ApexClassServiceHandler.generateJson(lstDependentPages);
   		dependentTriggersJson=ApexClassServiceHandler.generateJson(lstDependentTriggers);
   	}
    public void deleteclasses()
    {
    	ApexClassServiceHandler.deleteclasses(selectedClasses,lstDependentClasses,lstDependentTriggers,lstDependentPages);
    }
   
}