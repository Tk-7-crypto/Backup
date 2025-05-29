/**
* This test class is used to test all methods in Bid History trigger helper.
* version : 1.0
*/
@IsTest
public class TST_DAO_Bid_History {
    
    /**
    * This method is used to setup data for all methods.
    */
    @TestSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        pse__Permission_Control__c permissionControlGroup1 = UTL_OWF_TestData.createPermissionControl(cont, null, null, null);
        insert permissionControlGroup1;
    }
    
	
    /**
    * This test method used for insert and update opportunity record
    */ 
    static testMethod void testAgreementInsert() 
	{   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        Test.startTest();
            insert opp;
            Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
            insert agreement;
        	agreement.Bid_History_Status_Category__c  = 'Amended';
        update agreement;
        Test.stopTest();
		
		Integer expected = 1;
        Integer actual = [Select Id From Bid_History__c].size();
        system.assertEquals(expected, actual);
    }
    
	
    /**
    * This test method used to test Agreement Delete
    */ 
    static testMethod void testAgreementDelete() 
	{   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        insert agreement;
        Test.startTest();
            delete agreement;
        Test.stopTest();
        
        List<Bid_History__c> agrList = [Select Id from Bid_History__c];
        System.assertEquals(0, agrList.size());
    }

}