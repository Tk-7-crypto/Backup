/**
 * This test class is used to test all methods in Suggeted Resources service class
 * version : 1.0
 */
@IsTest
public class TST_SLT_Suggested_Resources {
    
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup()
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        insert agreement;
    }
	
    
    /**
     * This test method used to cover basic methods
     */ 
    @isTest
    static void testServiceSuggestedResources() 
	{   
        List<Schema.SObjectField> resourceRequestList = new SLT_Suggested_Resources().getSObjectFieldList();
        Schema.SObjectType resourceRequest = new SLT_Suggested_Resources(true).getSObjectType();
		
		Integer expected = 0;
		System.assertEquals(expected, resourceRequestList.size());
    }    
    
	
    /**
     * This test method used to get Suggested Resources By Resource Request ID
     */ 
    @isTest
    static void testGetSuggestedResourcesByResourceRequestID() 
	{   
        pse__Resource_Request__c resReq = [Select Id From pse__Resource_Request__c limit 1];
        Set<ID> resReqIdSet = new Set<Id>{resReq.Id};
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','Resource_Request__c'};
        Test.startTest();
            List<Suggested_Resources__c> suggestedResources = new SLT_Suggested_Resources().getSuggestedResourcesByResourceRequestID(resReqIdSet, resourceRequestFieldSet);
        Test.stopTest();
    
        Integer expected = 0;
        Integer actual = suggestedResources.size();
        system.assertEquals(expected, actual);
    }
    

}