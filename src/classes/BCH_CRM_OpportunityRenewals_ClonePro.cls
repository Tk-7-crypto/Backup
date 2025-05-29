global class BCH_CRM_OpportunityRenewals_ClonePro implements Database.Batchable<sObject>, Database.AllowsCallOuts {
    global final String query;
    
    final static String NO_RENEW_STR = CON_CRM_OpportunityRenewals.NO_RENEW_STR;

    global BCH_CRM_OpportunityRenewals_ClonePro( String q ) {
        query = q;
    }
 
    global Database.QueryLocator start( Database.BatchableContext bc ) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        //we will get a list of renwal tasks here.
        //iterate the list and create appropriate instance of NoCange or ChageDetail class here
        Global_Variables.RenewalCloneFlag = true;
        //PseSecurity.isRunningInBatchContext = true;
        //PseSecurity.forceCalloutOperationsToQueue =true;
        
        
        //  Call Cameleon functions that would normally occur via @future triggers
        //  but have been excluded since @future code cannot be called from batch Apex      
        List<Renewal_Task__c> RT_Array = new List<Renewal_Task__c> ();
        for(sObject s : scope) {
            Renewal_Task__c rt = (Renewal_Task__c) s;
            if(rt.Cloned_Opportunity__c != null && 
                rt.Cloning_Status__c == CON_CRM_OpportunityRenewals.CLONED_STATUS_STR &&
                rt.CAM_Post_Processed__c == false)
            {
                RT_Array.add(rt);
            }                
        }
        Set<Id> OppId_Set = new Set<Id>();
        for (Renewal_Task__c RT:RT_Array)
        {
            OppId_Set.add(RT.Cloned_Opportunity__c);
            RT.CAM_Post_Processed__c = true;
        } 
        try
        {
            // commented below line by sandeep as CAM_Wrapper class is deleted Date 3 August 2012 for Task assigned by Sam
            //CAM_Wrapper.CAM_Callout_Non_Future(OppId_Set);
            //CAM_WrapperOpp.CAM_Callout1_Non_Future(OppId_Set);
        }
        catch (Exception e)
        {
            sendMailNotification(e.getMessage()); 
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String[] toAddresses = new String[] {'sduncan@uk.imshealth.com'};           
            mail.setToAddresses(toAddresses);
        //  mail.setOrgWideEmailAddressId('0D270000000PAzY');
            mail.setSubject('Batch cloning error');
            mail.setHtmlBody('<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Batch opportunity cloning failed ***<br><br>The automated cloning process failed:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Error Mesage:</td><td>'+E.getMessage()+'</td></tr></table></p></td></tr></table>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//*/
        }
        update RT_Array;          
        
        List<Renewal_Task__c> rtList = new List<Renewal_Task__c> ();
        System.debug('Before rtList' + rtList);
        for(sObject s : scope) {
            Renewal_Task__c rt = (Renewal_Task__c) s;
            if(rt.Cloning_Action__c != NO_RENEW_STR && 
                rt.Cloning_Status__c != CON_CRM_OpportunityRenewals.CLONED_STATUS_STR &&
                rt.Cloned_Opportunity__c == null)
            {
                rtList.add(rt);
            }                
        }
        System.debug('After rtList' + rtList);
        EXT_CRM_OpportunityRenewals_NoChange oppCloner = new EXT_CRM_OpportunityRenewals_NoChange();
        oppCloner.CloneOpportunities_For_Renewal_With_NoChange(rtList);
    }

    global void finish(Database.BatchableContext bc) {
    }
    
        public void sendMailNotification(String errMsg) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
        String[] toAddresses = new String[] {'sduncan@uk.imshealth.com'};           
        mail.setToAddresses(toAddresses);
        mail.setOrgWideEmailAddressId('0D270000000PAzY');
        mail.setSubject('Batch cloning error');
        mail.setHtmlBody('<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Batch opportunity cloning failed ***<br><br>The automated cloning process failed:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Error Mesage:</td><td>'+ errMsg +'</td></tr></table></p></td></tr></table>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
 

}