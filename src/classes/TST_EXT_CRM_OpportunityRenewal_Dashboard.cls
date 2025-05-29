@isTest
private class TST_EXT_CRM_OpportunityRenewal_Dashboard {
    static testmethod void testJsonGenratorConstructor(){
        //test start here
        test.StartTest();
        	EXT_CRM_OpportunityRenewal_Dashboard controller = new EXT_CRM_OpportunityRenewal_Dashboard();
        test.StopTest();
    }
    static testmethod void testJsonParser(){
        Account acc = UTL_CRM_OpportunityRenewalTestData.setupAccount('TestAccount');
        
        String standardPricebookId =Test.getStandardPricebookId();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        prod.Business_Type__c = 'I&A';
        prod.CanUseRevenueSchedule=true;
        insert prod;
        
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        PE1.IsActive = true;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;   
        List<Renewal_Task__c> renTaskList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(acc, 3);
        Map<String, Renewal_Task__c> rtIdMap = new Map<String, Renewal_Task__c>();
        for(Renewal_Task__c task : renTaskList){
            rtIdMap.put('' + task.id , task );
        }   
        
        List<OpportunityLineItem> oliList = [Select Id,PriceBookEntry.ProductCode, OpportunityId,CurrencyIsoCode  from OpportunityLineItem Limit 1];
        
        list<Renewal_Task_Change_Detail__c> dtList=new list<Renewal_Task_Change_Detail__c>();
        
        for(integer index=0;index < renTaskList.size();index++)
        {
            Renewal_Task_Change_Detail__c rtdcForRetained = new Renewal_Task_Change_Detail__c(Opportunity_Line_Item_Id__c = oliList[0].Id,
                                                                                             Renewal_Task__c = renTaskList[index].Id,
                                                                                             Type__c='Renewed',
                                                                                             TotalPrice__c = 1000.00,
                                                                                             currencyisocode=oliList[0].currencyisocode,
                                                                                             Year_on_Year_Change__c = 0.0,
                                                                                             ProductCode__c = prod.ProductCode);
            
            dtList.add(rtdcForRetained);
            
        }
        
        //List<Renewal_Task_Change_Detail__c> dtList = [select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c from Renewal_Task_Change_Detail__c where Renewal_Task__c = : renTaskList[0].id];
        system.debug(' dtList :'+dtList);
         system.debug(' dtList :'+renTaskList);
        
        string json = '{ outerRec :  [{'+
            'id : "'+ renTaskList[0].id +'",'+ 'cloning_action : 3,'+
            'closeDate : "' + Date.today() + '",'+  'price_inc : "5",'+
            'innerRecords : ['+  '{id : "'+ dtList[0].Opportunity_Line_Item_Id__c +'"},'+
            '{id : "'+ dtList[1].Opportunity_Line_Item_Id__c +'", comment : "abc"}]}, {'+  'id : "'+ renTaskList[1].id +'",'+
            'cloning_action : 2,'+ 'dataPeriodShift : "2",'+
            'closeDate : "'+ Date.today() +'",'+
            'price_inc : "5",'+
            'innerRecords : []'+
            '},{id : "'+ renTaskList[2].id +'",cloning_action : 1, noRenewComment: "abc", innerRecords : [] }]}';        
        //test start here
        test.StartTest();
            EXT_CRM_OpportunityRenewal_Dashboard controller = new EXT_CRM_OpportunityRenewal_Dashboard();
            controller.rtIdMap = rtIdMap;
            
            controller.jsonForCloning = json;
            controller.firstJsonToParse = true;
            //controller.CloneRenewalTaskHeirarchy();
            controller.cloneRenwalTasks();
            controller.processCloning();
            List<renewal_Task__c> rtList1 = [select id, cloning_status__c from renewal_Task__c where id in :rtIdMap.keyset()];
            for(Renewal_Task__c rt1: rtList1 ) {
                System.assert(rt1.Cloning_Status__c != '' );
            }
        //test start here
        test.StopTest();
        /*Account acc = UTL_CRM_OpportunityRenewalTestData.setupAccount('TestAccount');
        List<Renewal_Task__c> renTaskList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(acc, 3);
        Map<String, Renewal_Task__c> rtIdMap = new Map<String, Renewal_Task__c>();
        for(Renewal_Task__c task : renTaskList){
        rtIdMap.put('' + task.id , task );
        }    
        
        List<Renewal_Task_Change_Detail__c> dtList = [select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c from Renewal_Task_Change_Detail__c where Renewal_Task__c = : renTaskList[0].id];
        
        string json = '{ outerRec :  [{'+
        'id : "'+ renTaskList[0].id +'",'+ 'cloning_action : 3,'+
        'closeDate : "' + Date.today() + '",'+  'price_inc : "5",'+
        'innerRecords : ['+  '{id : "'+ dtList[0].Opportunity_Line_Item_Id__c +'"},'+
        '{id : "'+ dtList[1].Opportunity_Line_Item_Id__c +'", comment : "abc"}]}, {'+  'id : "'+ renTaskList[1].id +'",'+
        'cloning_action : 2,'+ 'dataPeriodShift : "2",'+
        'closeDate : "'+ Date.today() +'",'+
        'price_inc : "5",'+
        'innerRecords : []'+
        '},{id : "'+ renTaskList[2].id +'",cloning_action : 1, noRenewComment: "abc", innerRecords : [] }]}';        
        //test start here
        test.StartTest();
        EXT_CRM_OpportunityRenewal_Dashboard controller = new EXT_CRM_OpportunityRenewal_Dashboard();
        controller.rtIdMap = rtIdMap;
        
        controller.jsonForCloning = json;
        controller.firstJsonToParse = true;
        //controller.CloneRenewalTaskHeirarchy();
        controller.cloneRenwalTasks();
        controller.processCloning();
        List<renewal_Task__c> rtList1 = [select id, cloning_status__c from renewal_Task__c where id in :rtIdMap.keyset()];
        for(Renewal_Task__c rt1: rtList1 ) {
        System.assert(rt1.Cloning_Status__c != '' );
        }
        
        //test start here
        test.StopTest();*/
    }
    static testmethod void testReassignWithNoTask(){
        test.StartTest();
            EXT_CRM_OpportunityRenewal_Dashboard controller = new EXT_CRM_OpportunityRenewal_Dashboard();
            controller.reassignRecIdList = '';
            //test start here
        test.StopTest();
    }
    static testmethod void testNoUserReassignedToTask(){
        Account acc = UTL_CRM_OpportunityRenewalTestData.setupAccount('TestAccount');
        
        String standardPricebookId =Test.getStandardPricebookId();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        prod.Business_Type__c = 'I&A';
        prod.CanUseRevenueSchedule=true;
        insert prod;
        
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        PE1.IsActive = true;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;   
        
        List<Renewal_Task__c> renTaskList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(acc, 1);
        test.StartTest();
            EXT_CRM_OpportunityRenewal_Dashboard controller = new EXT_CRM_OpportunityRenewal_Dashboard();
            controller.reassignRecIdList = '\'' + renTaskList[0].id +'\'';
            controller.reassignUserId = '';
        //test start here
        test.StopTest();
    }
    static testmethod void testReassign(){
        Account acc = UTL_CRM_OpportunityRenewalTestData.setupAccount('TestAccount');
        
        String standardPricebookId =Test.getStandardPricebookId();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        prod.Business_Type__c = 'I&A';
        prod.CanUseRevenueSchedule=true;
        insert prod;
        
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        PE1.IsActive = true;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;   
        
        List<Renewal_Task__c> renTaskList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(acc, 1);
        
        test.StartTest();
            EXT_CRM_OpportunityRenewal_Dashboard controller = new EXT_CRM_OpportunityRenewal_Dashboard();
            controller.reassignRecIdList = '\'' + renTaskList[0].id +'\'';
            controller.reassignUserId = [select Id from User limit 1].Id;
            controller.reassign();
        //test start here
        test.StopTest();
    }
}