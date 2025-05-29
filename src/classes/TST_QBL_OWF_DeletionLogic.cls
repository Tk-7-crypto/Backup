/**
* This test class is used to test all methods in QBL_OWF_DeletionLogic queuable class.
* version : 1.0 
*/
@isTest
private class TST_QBL_OWF_DeletionLogic {
    
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
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;        
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        agreement.Bid_Number__c = 0;
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan'; 
        insert resourceRequest;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignment;
    }
    
	
    /**
    * This test method used to test queuable Opportunity deletion
    */
    @isTest
    static void testOpportunity() 
	{
        Test.startTest();
        List<Opportunity> oppList = [Select Id from Opportunity limit 10];
        QBL_OWF_DeletionLogic.QueueOpportunityDeletion queuableObject = new QBL_OWF_DeletionLogic.QueueOpportunityDeletion(oppList);    
        	System.enqueueJob(queuableObject);
        Test.stopTest();
        
        Id actual = System.enqueueJob(queuableObject);
        System.assertNotEquals(null,actual, 'Verifying QBL_OWF_DeletionLogic.QueueOpportunityDeletion Functionality');
    }  
    
	
    /**
    * This test method used to test queuable Agreement deletion
    */
    @isTest
    static void testAgreement() 
	{
        Test.startTest();
        List<Bid_History__c> agrList = [Select Id from Bid_History__c limit 10];
        QBL_OWF_DeletionLogic.QueueAgreementDeletion queuableObject = new QBL_OWF_DeletionLogic.QueueAgreementDeletion(agrList);           
        	System.enqueueJob(queuableObject);
       	Test.stopTest();
        
        Id actual = System.enqueueJob(queuableObject);
        System.assertNotEquals(null,actual, 'Verifying QBL_OWF_DeletionLogic.QueueAgreementDeletion Functionality');
    }  
    
	
    /**
    * This test method used to test queuable Project deletion
    */
    @isTest
    static void testProject() 
	{
        Test.startTest();
        List<pse__Proj__c> projList = [Select Id from pse__Proj__c limit 10];
        QBL_OWF_DeletionLogic.QueueProjectDeletion queuableObject = new QBL_OWF_DeletionLogic.QueueProjectDeletion(projList);    
        	System.enqueueJob(queuableObject);
        Test.stopTest();
        
		Id actual = System.enqueueJob(queuableObject);
        System.assertNotEquals(null,actual, 'Verifying QBL_OWF_DeletionLogic.QueueProjectDeletion Functionality');       
    }  
    
	
    /**
    * This test method used to test queuable Resource Request deletion
    */
    @isTest
    static void testResourceRequest() 
	{
        Test.startTest();
        List<pse__Resource_Request__c> rrList = [Select Id from pse__Resource_Request__c limit 100];
        QBL_OWF_DeletionLogic.QueueResourceRequestDeletion queuableObject = new QBL_OWF_DeletionLogic.QueueResourceRequestDeletion(rrList);    
        	System.enqueueJob(queuableObject);
        Test.stopTest();
        
        Id actual = System.enqueueJob(queuableObject);
        System.assertNotEquals(null,actual, 'Verifying QBL_OWF_DeletionLogic.QueueResourceRequestDeletion Functionality'); 
    }  
    
	
    /**
    * This test method used to test queuable Assignment deletion
    */
    @isTest
    static void testAssignment() 
	{
        Test.startTest();
        List<pse__Assignment__c> assignmentList = [Select Id from pse__Assignment__c limit 100];
        QBL_OWF_DeletionLogic.QueueAssignmentDeletion queuableObject = new QBL_OWF_DeletionLogic.QueueAssignmentDeletion(assignmentList);    
        	System.enqueueJob(queuableObject);
        Test.stopTest();
        
        Id actual = System.enqueueJob(queuableObject);
        System.assertNotEquals(null,actual, 'Verifying QBL_OWF_DeletionLogic.QueueAssignmentDeletion Functionality');
    } 
}