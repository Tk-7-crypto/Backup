@isTest
private class TST_BCH_CRM_OpportunityRenewals_ClonePro{
    public static testMethod void testMailNotification() {
        Integer BATCH_SIZE = 2;
        Account testAcc = UTL_CRM_OpportunityRenewalTestData.setupAccount('Detail Controller Account');
        
        String standardPricebookId =Test.getStandardPricebookId();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        prod.Business_Type__c = 'I&A';
        prod.CanUseRevenueSchedule=true;
        insert prod;
        
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        PE1.IsActive = true;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;   
        
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , BATCH_SIZE);
        Set<Id> renIds = new Set<Id>();
        for(Renewal_Task__c rt : rtList){
            renIds.add(rt.Id);
        }
        //start test
        Test.startTest();
        Global_Variables.RenewalCloneFlag = true;
        //PseSecurity.skipGroupMembersForTesting = true;

        //create an instance of BCH_CRM_OpportunityRenewals_ClonePro
        //call execute method
        String q = 'Select Id,' + 
                                    'Price_Increase__c,' + 
                                    'Cloning_Action__c,' + 
                                    'Cloning_Status__c,' + 
                                    'Cloned_Opportunity__c,' + 
                                    'Cloned_Opportunity__r.name,' + 
                                    'Targeted_Close_Date__c,' + 
                                    'ownerId,' + 
                                    'Owner.Profile.Name,' +
                                    'Opportunity__r.account.name,' + 
                                    'Opportunity__r.name,' + 
                                    'Opportunity__r.C_S_Contract_Value__c, ' + 
                                    'Opportunity__r.Amount, Opportunity__r.Contract_End_Date__c,' + 
                                    'Opportunity__r.Contract_Type__c,' + 
                                    'Opportunity__r.CurrencyIsoCode,' + 
                                    'Opportunity__r.Opportunity_Number__c,' + 
                                    'Opportunity__r.Parent_Opportunity__c, ' + 
                                    'Opportunity__r.Parent_Opportunity__r.name,' + 
                                    '(Select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c From Renewal_Task_Change_Details__r) ' + 
                                    //'Opportunity__c, Opportunity__r.id  from Renewal_Task__c where Id in : '+ renIds + ' and id = ' + renIds[1] +' Cloning_Status__c != \'' + CON_CRM_OpportunityRenewals.CLONED_STATUS_STR + '\' AND Cloning_Action__c != \'\'  AND Cloning_Action__c != \'' + CON_CRM_OpportunityRenewals.NO_RENEW_STR + '\' ';                                                             
                                    'Opportunity__c, Opportunity__r.id, Owner_Country__c  from Renewal_Task__c where Id = \''+ rtList[0].Id +'\' OR Id = \''+ rtList[1].Id +'\' ';
        BCH_CRM_OpportunityRenewals_ClonePro bcOpp = new BCH_CRM_OpportunityRenewals_ClonePro(q);
        try {
            bcOpp.sendMailNotification('test error message');
        } catch (Exception e) {
            //test fails if exception is raised.       
            //System.assertEquals(true, false);
        }
    }
    
    public static testMethod void testBatchOppCloning() {
        Integer BATCH_SIZE = 2;
        //drop all renewal tasks
        //delete [select id from Renewal_Task__c] ;
                        
        //System.assertEquals(BATCH_SIZE, rtList.size());

        Renewal_Dashboard_Settings__c RDSetting = new Renewal_Dashboard_Settings__c();
        RDSetting.Cloning_Batch_Size__c = 5 ;
        RDSetting.Renewal_Year__c = 2017;
        insert RDSetting;
        
        Account testAcc = UTL_CRM_OpportunityRenewalTestData.setupAccount('Detail Controller Account');
        
        String standardPricebookId =Test.getStandardPricebookId();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        prod.Business_Type__c = 'I&A';
        prod.CanUseRevenueSchedule=true;
        insert prod;
        
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        PE1.IsActive = true;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;   
        
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , BATCH_SIZE);
        Set<Id> renIds = new Set<Id>();
        for(Renewal_Task__c rt : rtList){
            renIds.add(rt.Id);
        }
        //start test
        Test.startTest();
        Global_Variables.RenewalCloneFlag = true;
        //PseSecurity.skipGroupMembersForTesting = true;

        //create an instance of BCH_CRM_OpportunityRenewals_ClonePro
        //call execute method
        String q = 'Select Id,' + 
                                    'Price_Increase__c,' + 
                                    'Cloning_Action__c,' + 
                                    'Cloning_Status__c,' + 
                                    'Cloned_Opportunity__c,' + 
                                    'Cloned_Opportunity__r.name,' + 
                                    'Targeted_Close_Date__c,' + 
                                    'ownerId,' + 
                                    'Owner.Profile.Name,' +
                                    'Opportunity__r.account.name,' + 
                                    'Opportunity__r.name,' + 
                                    'Opportunity__r.C_S_Contract_Value__c, ' + 
                                    'Opportunity__r.Amount, Opportunity__r.Contract_End_Date__c,' + 
                                    'Opportunity__r.Contract_Type__c,' + 
                                    'Opportunity__r.CurrencyIsoCode,' + 
                                    'Opportunity__r.Opportunity_Number__c,' + 
                                    'Opportunity__r.Parent_Opportunity__c, ' + 
                                    'Opportunity__r.Parent_Opportunity__r.name,' + 
                                    '(Select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c From Renewal_Task_Change_Details__r) ' + 
                                    //'Opportunity__c, Opportunity__r.id  from Renewal_Task__c where Id in : '+ renIds + ' and id = ' + renIds[1] +' Cloning_Status__c != \'' + CON_CRM_OpportunityRenewals.CLONED_STATUS_STR + '\' AND Cloning_Action__c != \'\'  AND Cloning_Action__c != \'' + CON_CRM_OpportunityRenewals.NO_RENEW_STR + '\' ';                                                             
                                    'Opportunity__c, Opportunity__r.id, Owner_Country__c  from Renewal_Task__c where Id = \''+ rtList[0].Id +'\' OR Id = \''+ rtList[1].Id +'\' ';
        System.debug('query = ' + q);
        BCH_CRM_OpportunityRenewals_ClonePro bcOpp = new BCH_CRM_OpportunityRenewals_ClonePro(q);
        Id pId = Database.executeBatch(bcOpp);
        //stop test
        Test.stopTest();


        List<Renewal_Task__c> artList = [Select Id,
                                    Price_Increase__c,
                                    Cloning_Action__c,
                                    Cloning_Status__c,
                                    Cloned_Opportunity__c,
                                    Cloned_Opportunity__r.name,
                                    Targeted_Close_Date__c,
                                    ownerId,
                                    Owner.Profile.Name,
                                    Opportunity__r.account.name,
                                    Opportunity__r.name,
                                    Opportunity__r.C_S_Contract_Value__c,
                                    Opportunity__r.Amount, Opportunity__r.Contract_End_Date__c,
                                    Opportunity__r.Contract_Type__c,
                                    Opportunity__r.CurrencyIsoCode,
                                    Opportunity__r.Opportunity_Number__c,
                                    Opportunity__r.Parent_Opportunity__c, 
                                    Opportunity__r.Parent_Opportunity__r.name,
                                    (Select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c From Renewal_Task_Change_Details__r)                                                               
                                    Opportunity__c, Opportunity__r.id  from Renewal_Task__c where Id in : renIds];

        System.debug('artList = ' + artList); 
        //asserts go here
        //1. check if the status is not blank -> it has been processed.
        for(Integer i = 0; i < artList.size(); i++)
        {
            System.debug('cloning actionss = ' + artList[i].Cloning_Action__c); 
            System.assert( artList[i].Cloning_Status__c != '');
            if(artList[i].Cloning_Action__c != CON_CRM_OpportunityRenewals.NO_CHANGE_STR && artList[i].Cloning_Action__c != CON_CRM_OpportunityRenewals.NO_RENEW_STR)
                System.assert( artList[i].Cloned_Opportunity__c != null);
        }
        //2. check if status is cloned then
        //asssert if the cloned opportunity is not null.
        //check the no of change detail for this renewal task --> this no. should match with no of opportunity products
            

        
    }


}