/*
 * TST_SRV_PSA_AuditLog
 *
 * Providing proofs for the SRV_PSA_AuditLog
 *
 * Revisions    2019-Jun  cld      Initial version
 */
@isTest
private class TST_SRV_PSA_AuditLog 
{
	@testSetup
    static void setupTestData(){
        //Program
        Program__c program = new Program__c(Name = 'Test Program');
        insert program;
        
        Account account = UTL_PSA_TestData.accounts[0];
        account.Name = 'Test Account';
        Project_Log__c projectLog = new Project_Log__c();
        projectLog.Account__c = account.id;
        projectLog.Title__c='Test Title Insert';
        projectLog.Program__c = program.id;
        insert projectLog;
    }
    
    
    @IsTest
    static void testCDCAuditOnProjectLog () 
    {
        //  initialize CDC
        Test.enableChangeDataCapture();

        // SRV_PSA_AuditLog.DO_INSERT_BIG_OBJECT_DATA = false; // cover custom object data save!
        Test.startTest();
        //setupTestData();

        Project_Log__c projectLog = [Select Id, Name from Project_Log__c limit 1];
        Test.getEventBus().deliver();

        // update and trigger cdc event
        projectLog.Reason_For_Deletion__c = 'Support Test Class Coverage';
        update projectLog;
        Test.getEventBus().deliver();

        // delete and trigger cdc event
        delete projectLog;
        Test.getEventBus().deliver();

        Test.stopTest();

        Audit_Log__c[] insertedLogs = [select id, transaction_key__c, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :projectLog.Id and operation__c in ('INSERT') and transaction_key__c != ''];
        system.assertNotEquals(0, insertedLogs.size(), 'Expected to have an INSERT operation with a transaction');
        system.assertEquals('INSERT', insertedLogs[0].Operation__c, 'expected an INSERT operation with a transaction');
        system.assertNotEquals(null, insertedLogs[0].Transaction_Key__c, 'expected an INSERT operation with a transaction');
    }

    // ------------------------------------------------------------
    // ---  version 1 testing
    // ------------------------------------------------------------

    @IsTest
    static void testUpdateOnProjectLog () {
        Test.startTest();
        //setupTestData();
        Project_Log__c projectLog = [Select Id, Name,OwnerId,Date_Added__c,Date_Completed__c,IsDeleted,CurrencyIsoCode,RecordTypeId,Title__c,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate,Account__c,API_Product__c,Assignee_External__c,Assignee_Internal__c,Associated_Project_Phase__c,Category__c,Complexity__c,Countries__c,UserRecordAccessId,RecordVisibilityId,Date_Due__c,Description__c,Detectability_Rank__c,Detectability__c, Group__c,Impact_Rank__c,
                                    Impact__c,Include_in_Reporting__c,Legacy_ID__c, Owner__c, Parent_Project_Log__c,Probability_Rank__c, Probability__c,Program__c, 
                                    Project__c,Projected_Completion_Date__c, Rank__c,Reason_for_Deletion__c, Reason_for_Status_Change__c, Region__c, Resource__c, 
                                    Response_Plan__c, Risk_Priority_Number__c, Risk_Rank__c, Service_Line__c, Service__c, Show_Customer__c, Status__c, Trigger_Description__c, Trigger_Other__c, 
                                    Trigger__c, Walls__c, Wins__c, Wisdoms__c, Impact_Description__c,  Customer_Dependency__c, Date_Discovered__c, Date_Occurred__c, Deliverable__c, Detailed_Description__c, 
                                    If_Yes_Date_Customer_Notified__c, Initiator__c, Project_Metric__c, EDA_Reference_Number__c, Issue_Type__c, Summary__c, Issue_Severity__c, Issue_Tracked_in_EDA_System__c,
                                    Resolution_Plan__c 
                                    from Project_Log__c limit 1];
        Project_Log__c originalLog = projectLog.clone(true, false, false, true);
        projectLog.Title__c='Test Title Updated';
        update projectLog;

        List<Sobject> sobjList = new List<Sobject>();
        Map<Id,SObject> oldMap = new  Map<Id, SObject>();
        oldMap.put(originalLog.id, originalLog);

        sobjList.add(projectLog);
        List<SRV_PSA_AuditLog.AuditLogWrapper> auditlogForUpdateList = SRV_PSA_AuditLog.buildAuditLogWrappersOnInsertUpdate(sobjList, oldMap);

        // cover queue
        SRV_PSA_AuditLog.commitAuditLogChangeEventJob(auditlogForUpdateList);

        Test.stopTest();

        system.assert(auditlogForUpdateList != null && auditlogForUpdateList.size() > 0, 'no update logs built');
        system.assertEquals('UPDATE', auditlogForUpdateList[0].operation);
        //system.assertEquals('title__c', auditlogForUpdateList[0].field);
    }

    @IsTest
    static void testDeleteOnProjectLog () {
        Test.startTest();
        //setupTestData();
        Project_Log__c projectLog = [Select Id, Name from Project_Log__c limit 1];
        projectLog.Reason_for_Deletion__c='Test Title needs to be deleted';
        update projectLog;

        List<SObject> objectList = new List<SObject>{projectLog};
        String operation = 'DELETE';
        List<SRV_PSA_AuditLog.AuditLogWrapper> auditlogForDeleteList = SRV_PSA_AuditLog.buildAuditLogWrappersOnDelete(objectList, operation);

        delete projectLog;
        undelete projectLog;
        Test.stopTest();

        system.assert(auditlogForDeleteList != null && auditlogForDeleteList.size() > 0, 'no delete logs built');
        system.assertEquals('DELETE', auditlogForDeleteList[0].operation);
    }
}
