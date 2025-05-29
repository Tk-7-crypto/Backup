global class BCH_OWF_FilterReversal implements Database.Batchable<sObject> {
    Id filterDelete;
    List<pse__Filter__c> filterToDelete = new List<pse__Filter__c>();
    String query;
    Set<String> contactsToUpdate;
    
    global BCH_OWF_FilterReversal(String filterId, Set<String> contactsToUpdate){
        this.filterDelete = filterId;
        this.contactsToUpdate = contactsToUpdate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        query='select id from pse__Filter__c WHERE Id =:filterDelete Order by CreatedDate desc';
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<pse__Filter__c> input) {
        try{
            List<Contact> srContacts = [SELECT id, name, Match_Percentage__c FROM Contact WHERE name IN :contactsToUpdate];
            List<Contact> updateContacts = new List<Contact>();
            for(Contact c : srContacts){
                c.Match_Percentage__c = null;
                updateContacts.add(c);
            }
        	update updateContacts;
        }catch(System.QueryException e){
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, string.valueof(e));
            ApexPages.addMessage(myMsg);
        }
        
        
        for(pse__Filter__c f : input){
            if(f.Id == filterDelete){
                filterToDelete.add(f);
            }
        }
        try{
        	delete filterToDelete; 
        } catch(System.DMLException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,string.valueof(e));
            ApexPages.addMessage(myMsg);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
       
	}
    

}