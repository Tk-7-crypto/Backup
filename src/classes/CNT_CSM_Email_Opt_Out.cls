public without sharing class CNT_CSM_Email_Opt_Out {

    @AuraEnabled
    public static void updateContact(String expid, String caseid) {
        try{
            UTL_ExecutionControl.stopTriggerExecution = true;
            UTL_ExecutionControl.stopTriggerExecution = true;
            Contact newContact = [SELECT Id, Opt_Out_From__c FROM Contact WHERE Id =: expid LIMIT 1];
            Case newCase = [SELECT Id FROM case WHERE Id =: caseid limit 1];
            newContact.Opt_Out_From__c = CON_CSM.S_SELF_rEGISTRATION;
            update newContact;
            update newCase;
            
        }Catch(Exception e){
            throw new AuraHandledException(e.getMessage());    
        }
        
    }

}