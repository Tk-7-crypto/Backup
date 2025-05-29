global class SCH_CRM_OpportunityRenewals_ClonSch implements Schedulable {
    static public String CRON_EXP = '0 0 * * * ?';
    static public String CRON_EXP1 = '0 15 * * * ?';
    static public String CRON_EXP2 = '0 30 * * * ?';
    static public String CRON_EXP3 = '0 45 * * * ?';

    global void execute(SchedulableContext sc) {
         String q = 'Select Id,' +
                                    'Round_Up__c,' + 
                                    'Price_Increase__c,' + 
                                    'Cloning_Action__c,' + 
                                    'Cloning_Status__c,' + 
                                    'Cloned_Opportunity__c,' + 
                                    'Cloned_Opportunity__r.name,' + 
                                    'Targeted_Close_Date__c,' + 
                                    'ownerId,' + 
                                    'Owner.Profile.Name,' +
                                    'Data_Period_Shift__c,' + 
                                    'Opportunity__r.account.name,' + 
                                    'Opportunity__r.name,' + 
                                    'Opportunity__r.C_S_Contract_Value__c, ' + 
                                    'Opportunity__r.Amount, Opportunity__r.Contract_End_Date__c,' + 
                                    'Opportunity__r.Contract_Type__c,' + 
                                    'Opportunity__r.CurrencyIsoCode,' + 
                                    'Opportunity__r.Opportunity_Number__c,' + 
                                    //'Opportunity__r.Prior_Opportunity_ID__c, ' + 
                                    //'Opportunity__r.Prior_Opportunity_ID__r.name,' + 
                                    'Owner_Country__c,' + 
                                    'CAM_Post_Processed__c,' +
                                    //'(Select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c From Renewal_Task_Change_Details__r) ' +                                                              
                                    'Opportunity__c, Opportunity__r.id  from Renewal_Task__c' + 
                                    ' where (Cloning_Status__c != \'' + 
                                    CON_CRM_OpportunityRenewals.CLONED_STATUS_STR + 
                                    '\' AND Cloning_Status__c != \'' + CON_CRM_OpportunityRenewals.ERROR_STATUS_STR + '\'  AND Cloning_Status__c != \'' + CON_CRM_OpportunityRenewals.AW_DETAILS_STATUS_STR +
                                     '\' AND Cloning_Action__c != \'\'  AND Cloning_Action__c != \''+ CON_CRM_OpportunityRenewals.NO_RENEW_STR + '\' )' +
                                     'OR (Cloning_Status__c = \'' + CON_CRM_OpportunityRenewals.CLONED_STATUS_STR + '\' AND Cloned_Opportunity__c != null AND CAM_Post_Processed__c = false)';

          BCH_CRM_OpportunityRenewals_ClonePro bcOpp = new BCH_CRM_OpportunityRenewals_ClonePro(q);
          Renewal_Dashboard_Settings__c  batchSizesetting = Renewal_Dashboard_Settings__c.getInstance(UserInfo.getProfileId());
          Id pId = Database.executeBatch(bcOpp,  batchSizesetting.Cloning_Batch_Size__c!=null ? batchSizesetting.Cloning_Batch_Size__c.intvalue() : 20);
    }

}