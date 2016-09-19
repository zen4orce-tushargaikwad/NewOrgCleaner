public with sharing class ConfigurationCleanUpService {
	
    public List<ApexPage> visualforcePageList {get; set;}
    public List<ApexClass> apexClassList {get; set;}
    public Map<string, List<List<string>>> apexTriggerDetailMap = new Map<string, List<List<string>>>();
    public Map<string, List<List<string>>> workflowDetailMap = new Map<string, List<List<string>>>();
    public Map<string, List<List<String>>> validationRuleDetailMap = new Map<string, List<List<string>>>();
    
    public String triggersJson{get; set;}
    public String apexPageJson{get; set;}
    public String workflowJson{get; set;}
    public String validationRuleJson{get; set;}
    public String apexClassJson{get; set;}
    
    public String ConfigurationList{get; set;}
    public String ConfigName {get; set;}
    public String CurrentConfig {get; set;}
    public List<String> triggerParentList {get;set;}
    public Boolean IsTrigger {get; set;}
    public Boolean IsApexPage {get; set;}
    public Boolean IsWorkflowRule {get; set;}
    public Boolean IsValidationRule {get; set;}
    public Boolean IsApexClass {get; set;}
    
    public List<String> lstDependentClasses {get; set;}
    public List<String> lstDependentPages {get; set;}
    public List<String> lstDependentTriggers {get; set;}
    public List<ApexClass> lstclasses {get; set;}
    		 
    public PageReference Dashboard(){
        return Page.OrgCleanerDashboard;
    }
    
    public void GetConfigDetails(){
    	System.debug('IN - ' + CurrentConfig);
    	if(CurrentConfig == 'Trigger'){
    		IsTrigger = true;
    		getTriggersDetails();
    		triggersJson = ConfigurationCleanUpServiceHandler.generateJsonForTrigger(apexTriggerDetailMap);
    	}
    	else if(CurrentConfig == 'ApexPage'){
    		IsApexPage = true;
    		getVisualforcePages();
    		apexPageJson = ConfigurationCleanUpServiceHandler.generateJsonForApexPage(visualforcePageList);
    	}
    	else if(CurrentConfig == 'WorkflowRule'){
    		IsWorkflowRule = true;
    		getWorkflows();
    		workflowJson = ConfigurationCleanUpServiceHandler.generateJsonForTrigger(workflowDetailMap);
    	}
    	else if(CurrentConfig == 'ValidationRule'){
    		IsValidationRule = true;
    		getValidationRules();
  			validationRuleJson = ConfigurationCleanUpServiceHandler.generateJsonForTrigger(validationRuleDetailMap);
    	}
    	else if(CurrentConfig == 'ApexClass'){
    		IsApexClass = true;
    		getApexClass();
    		apexClassJson = ConfigurationCleanUpServiceHandler.generateJsonForApexClass(apexClassList);
    	}
    }
    public ConfigurationCleanUpService(){
    	System.debug('In Constructor');
    	if(triggersJson == null || triggersJson == ''){
    		//getTriggersDetails();
    		//triggersJson = ConfigurationCleanUpServiceHandler.generateJsonForTrigger(apexTriggerDetailMap);
    	}
    	if(apexPageJson == null || apexPageJson == ''){
    		//getVisualforcePages();
    		//apexPageJson = ConfigurationCleanUpServiceHandler.generateJsonForApexPage(visualforcePageList);
    	}
    	if(workflowJson == null || workflowJson == ''){
    		//getWorkflows();
    		//workflowJson = ConfigurationCleanUpServiceHandler.generateJsonForTrigger(workflowDetailMap);
    	}
        if(validationRuleJson == null || validationRuleJson == ''){
    		//getValidationRules();
    		//validationRuleJson = ConfigurationCleanUpServiceHandler.generateJsonForTrigger(validationRuleDetailMap);
    	}
    	if(apexClassJson == null || apexClassJson == ''){
    		//getApexClass();
    		//apexClassJson = ConfigurationCleanUpServiceHandler.generateJsonForApexClass(apexClassList);
    	}
    }
    public void GetConfigurationDetails(){
    	System.debug('Latest Call - ' + ConfigName);
    	triggersJson = null;
    }
    public void getTriggersDetails(){
    	apexTriggerDetailMap = TriggerService.getTriggers();
    	triggerParentList = new List<String>();
        triggerParentList.addAll(apexTriggerDetailMap.keySet());
    }
    public void getWorkflows(){
    	workflowDetailMap = WorkflowService.getWorkflows();
    }
    public void getApexClass(){
        apexClassList = ConfigurationSelector.getApexClasses();
    }
    
    public void getVisualforcePages(){      
        visualforcePageList = ConfigurationSelector.getVisualforcePages();
    }
    
    public void getValidationRules(){
    	validationRuleDetailMap = ValidationRuleService.getValidationRules();
    	System.debug('validationRuleList - '  + validationRuleDetailMap);
    }
    
    public void CleanConfigurations(){
    	System.debug('ConfigName  123 - '+ConfigName);
    	if(ConfigName == 'Trigger'){
    		List<String> triggersToDelete = new List<String>();
    		for(String details:ConfigurationList.split(',')){
    			triggersToDelete.add(details.split('\\$')[1]);
    		}
        	TriggerService.deleteTrigger(triggersToDelete);
    	}
    	else if(ConfigName == 'ApexPage'){
    		List<String> ApexPageToDelete = new List<String>();
    		for(String details:ConfigurationList.split(',')){
    			ApexPageToDelete.add(details.split('\\$')[0]);
    		}
        	ApexPageService.deleteApexPages(ApexPageToDelete);
    	}
    	else if(ConfigName == 'WorkflowRules'){
    		List<String> WorkflowRuleToDelete = new List<String>();
    		for(String details:ConfigurationList.split(',')){
    			WorkflowRuleToDelete.add(details.split('\\$')[0]+'.'+details.split('\\$')[2]);
    		}
            System.debug('WorkflowRuleToDelete - ' + WorkflowRuleToDelete);
    		WorkflowService.deleteWorkflows(WorkflowRuleToDelete);
    	}
        else if(ConfigName == 'ValidationRules'){
    		List<String> ValidationRuleToDelete = new List<String>();
    		for(String details:ConfigurationList.split(',')){
    			ValidationRuleToDelete.add(details.split('\\$')[0]+'.'+details.split('\\$')[2]);
    		}
            ValidationRuleService.deleteValidationRules(ValidationRuleToDelete);
            System.debug('ValidationRuleToDelete - ' + ValidationRuleToDelete);
        	//ApexPageService.deleteApexPages(ValidationRuleToDelete);
    	}
    	else if(ConfigName == 'ApexClass'){
    		List<String> ApexClassToDelete = new List<String>();
    		for(String details:ConfigurationList.split(',')){
    			ApexClassToDelete.add(details.split('\\$')[1]);
    		}
    		system.debug('ApexClassToDelete - ' + ApexClassToDelete);
    		
    		lstDependentClasses=ConfigurationCleanUpServiceHandler.SearchInClass(ApexClassToDelete);
    		lstDependentPages=ConfigurationCleanUpServiceHandler.SearchInPage(ApexClassToDelete);
 		   	lstDependentTriggers=ConfigurationCleanUpServiceHandler.SearchInTrigger(ApexClassToDelete);
	    	
	    	System.debug('lstDependentClasses='+lstDependentClasses);
    		System.debug('lstDependentPages='+lstDependentPages);
    		System.debug('lstDependentTriggers='+lstDependentTriggers);
    	}
    }
    
}