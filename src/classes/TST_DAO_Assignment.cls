/**
 * This test class is used to test DAO_Assignment.cls. It is copied over from TST_TGR_Assignment.cls
 * 
 */

@isTest
private class TST_DAO_Assignment {

    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        User testUser = new User(Id = UserInfo.getUserId());
        testUser.SUBREGION__c = 'United States of America';
        testUser.EmployeeNumber = '0808080810';
        testUser.IsActive = true;
        update testUser;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = testUser.id;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        System.debug('agreement->' + agreement);
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        system.debug('resourceRequest->' + resourceRequest);
        insert resourceRequest;   
    }
    
	
    /**
     * This test method used for insert/update Assignment record
     */
    static testmethod void testAssignmentInsertAndUpdate() 
	{
        Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c][0];
        Contact cont = [Select Id From Contact Where LastName = 'TestContact'];
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        pse__Proj__c project = [Select Id From pse__Proj__c where Bid_History__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = [Select Id, SubGroup__c From pse__Resource_Request__c Where SubGroup__c = 'TSL-Japan' limit 1];
        System.debug('resourceRequest51->' + resourceRequest);
        pse__Schedule__c schedule = [Select Id From pse__Schedule__c limit 1];
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, schedule.Id, cont.Id, resourceRequest.Id);
        Test.startTest();
            System.debug('assignement->' + assignement);    
            insert assignement;
            assignement.pse__Status__c = 'Accepted';
            update assignement;
        Test.stopTest();
		
        Integer expected = 1;
        Integer actual = [Select Id From pse__Assignment__c].size();
        system.assertEquals(expected, actual);
    }
    
	
    /**
     * This test method used for insert/update Assignment record
     */
    static testmethod void testAssignmentDelete() 
	{
        Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c][0];
        Contact cont = [Select Id From Contact Where LastName = 'TestContact'];        
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        pse__Proj__c project = [Select Id From pse__Proj__c where Bid_History__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = [Select Id From pse__Resource_Request__c Where SubGroup__c = 'TSL-Japan' limit 1];
        pse__Schedule__c schedule = [Select Id From pse__Schedule__c limit 1];
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, schedule.Id, cont.Id, resourceRequest.Id);
        Test.startTest();
            insert assignement;
            delete assignement;
        Test.stopTest();
		
        Integer expected = 0;
        Integer actual = [Select Id From pse__Assignment__c].size();
        system.assertEquals(expected, actual);
    }
}