/*
* Name              : TST_OppRen_NoChange_Ext
* Created By        : Suman Sharma
* Created Date      : 5 Jan, 2017
* Revision          : 
* Description       : Test Class for OpportunityRenewals_Interface apex class
*/
@isTest
private class TST_EXT_CRM_OpportunityRenewals_NoChange {
    /////************  Test Method   *************/////////////
    
    /*private static testmethod void testEXT_CRM_OpportunityRenewals_NoChange()
     {
        //test start here
        test.StartTest();
            
            List<Opportunity> listOriginalOpportunities = new List<Opportunity>();
            EXT_CRM_OpportunityRenewals_NoChange controller = new EXT_CRM_OpportunityRenewals_NoChange();
            List<Renewal_Task__c> listOfRenewal_Task = Database.query(controller.GenerateSelectQueryWithAllFields('Renewal_Task__c')+'Limit 2');
            system.debug('listOfRenewal_Task###1'+listOfRenewal_Task);
            for(Renewal_Task__c renewaltsak :listOfRenewal_Task)
            {
                system.debug('renewaltsak.Targeted_Close_Date__c1###'+renewaltsak.Targeted_Close_Date__c);
                renewaltsak.Targeted_Close_Date__c = renewaltsak.Targeted_Close_Date__c.addMonths(13);
                system.debug('renewaltsak.Targeted_Close_Date__c###'+renewaltsak.Targeted_Close_Date__c);
            }
            system.debug('listOfRenewal_Task###'+listOfRenewal_Task);
             
            
            //JsonGenerator.GenerateRenewalTaskJson();
            //controller.CloneOpportunities_For_Renewal_With_NoChange(listOfRenewal_Task);
            
        //test stop here
        test.StopTest();
     }//*/
    
    public static testMethod void testBatchOppCloning() {
        Renewal_Dashboard_Settings__c testRenDashSetting = new Renewal_Dashboard_Settings__c();
        testRenDashSetting.Renewal_Year__c = 2019;
        insert testRenDashSetting;
        Integer BATCH_SIZE = 2;
        //drop all renewal tasks
        //delete [select id from Renewal_Task__c] ;
        Account testAcc = UTL_CRM_OpportunityRenewalTestData.setupAccount('Detail Controller Account');
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , BATCH_SIZE);
        Set<Id> renIds = new Set<Id>();
        for(Renewal_Task__c renTask : rtList){
            renIds.add(renTask.Id);
        }
        System.assertEquals(BATCH_SIZE, rtList.size());

        //start test
        Test.startTest();
        //create an instance of BatchCloneOpportunities
        //call execute method
        
        EXT_CRM_OpportunityRenewals_NoChange controller = new EXT_CRM_OpportunityRenewals_NoChange();
        controller.CloneOpportunities_For_Renewal_With_NoChange(rtList);
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

        //asserts go here
        System.debug('artList = ' + artList);
        //1. check if the status is not blank -> it has been processed.
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
                System.assert( artList[i].Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_5);
            }
            /*
            //check opportunity stage name of closed opportunity
            if(artList[i].Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR)
                System.assert( artList[i].Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_5);
            //5 Negotiate Contract Ts & Cs
            if(artList[i].Cloning_Action__c == CON_CRM_OpportunityRenewals.NO_CHANGE_STR)
                System.assert( artList[i].Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_5);
            */
            //check the price increase
            Decimal calPrice = artList[i].Opportunity__r.Amount * (100 + artList[i].Price_Increase__c/100);
            System.debug('calPrice = ' + calPrice + ' Opportuntiy__r.Amount =' + artList[i].Opportunity__r.Amount);
            //System.assert(calPrice == artList[i].Cloned_Opportunity__r.Amount);
            //List<OpportunityLineItem> olList = artList[i].Cloned_Opportunity__c.OpportunityLineItem; 
            //System.assert(olList.size() == 5);
        }
        //2. check if status is cloned then
        //asssert if the cloned opportunity is not null.
        //check the no of change detail for this renewal task --> this no. should match with no of opportunity products  
    }
}