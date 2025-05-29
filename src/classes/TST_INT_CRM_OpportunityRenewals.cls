/*
* Name              : TST_INT_CRM_OpportunityRenewals
* Created By        : Suman Sharma
* Created Date      : 5 Jan, 2017
* Revision          : 
* Description       : Test Class for INT_CRM_OpportunityRenewals apex class
*/
@isTest
private class TST_INT_CRM_OpportunityRenewals {
    testmethod static void testBatchOppCloning() {
        Integer BATCH_SIZE = 2;
        
        Account acc = UTL_CRM_OpportunityRenewalTestData.setupAccount('TestAccount');
        
        String standardPricebookId =Test.getStandardPricebookId();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        prod.Business_Type__c = 'I&A';
        prod.IsActive = true;
        prod.CanUseRevenueSchedule=true;
        prod.ProductCode = '1234';
        prod.Pillar__c = 'Technology Solutions; Information Offering'; 
        insert prod;
        
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        PE1.IsActive = true;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1; 
        
        Address__c TestAddress = New Address__c(Name='Test Address',Account__c = acc.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
        SAP_Reference__c = '495001',MDM_Validation_Status__c = 'Validated',RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId());
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert TestAddress;
        
        List<Renewal_Task__c> renTaskList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(acc, BATCH_SIZE);
        Set<Id> renIds = new Set<Id>();
        List<BNF2__c> TestBnfList = new List<BNF2__c>();
        for(Renewal_Task__c renTask : renTaskList){
            renIds.add(renTask.Id);
            BNF2__c TestBnf = new BNF2__c(Opportunity__c = renTask.Opportunity__c);
            TestBnf.BNF_Status__c = 'Accepted';
            TestBnf.Sales_Org_Code__c = 'ES51';
            TestBnf.IMS_Sales_Org__c = 'IMS Spain [ES51]';
            TestBnf.Ship_To__c = TestAddress.Id;
            TestBnf.Bill_To__c = TestAddress.Id;
            //TestBnf.RecordTypeId = [Select Name, Id From RecordType where isActive = true and Name = 'SAP SD Integrated' Limit 1][0].id;
            //TestBnf.Revenue_Analyst__c = ratest.Id;
            TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
            TestBnf.Contract_End_Date__c = Date.today().addYears(2);
            TestBnfList.add(TestBnf);
        }
        
        insert TestBnfList;
        System.assertEquals(BATCH_SIZE, renTaskList.size());
        
        Renewal_Dashboard_Settings__c RDSetting = new Renewal_Dashboard_Settings__c();
        RDSetting.Cloning_Batch_Size__c = 5 ;
        RDSetting.Renewal_Year__c = 2017;
        insert RDSetting; 
        
       
        
        //start test
        Test.startTest();       
      
        
        EXT_CRM_OpportunityRenewals_NoChange controller = new EXT_CRM_OpportunityRenewals_NoChange();
        controller.CreateOpportunityHierarchyAndItsClone(renTaskList);
        //stop test
        Test.stopTest();
        
        
        List<Renewal_Task__c> artList = [Select Id,
                                         Price_Increase__c,
                                         Cloning_Action__c,
                                         Cloning_Status__c,
                                         Cloned_Opportunity__c,
                                         Cloned_Opportunity__r.name,
                                         Cloned_Opportunity__r.CloseDate,
                                         Cloned_Opportunity__r.StageName,
                                         Cloned_Opportunity__r.Amount,
                                         Targeted_Close_Date__c,
                                         ownerId,
                                         Owner_Country__c,
                                         Data_Period_Shift__c,
                                         CAM_Post_Processed__c,
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
        
        
        for(Integer i = 0; i < artList.size(); i++)
        {
            System.assert( artList[i].Cloning_Status__c != '');
            if(artList[i].Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR){
                System.assert( artList[i].Cloned_Opportunity__c != null);
                System.assert( artList[i].Cloned_Opportunity__r.name != null);
                //check the name of cloned opportuntiy
                System.assert( artList[i].Cloned_Opportunity__r.name.contains('Renewal'));
                //check the close date of cloned opportunity
                System.assert( artList[i].Cloned_Opportunity__r.CloseDate != null);
                System.assert( artList[i].Cloned_Opportunity__r.CloseDate.isSameDay(artList[i].Targeted_Close_Date__c));
                System.assert( artList[i].Cloned_Opportunity__r.StageName == CON_CRM.FINALIZING_DEAL_STAGE);
            }
            
            //Decimal calPrice = artList[i].Opportunity__r.Amount * (100 + artList[i].Price_Increase__c/100);
            //System.debug('calPrice = ' + calPrice + ' Opportuntiy__r.Amount =' + artList[i].Opportunity__r.Amount);
            
        } 
    }
}