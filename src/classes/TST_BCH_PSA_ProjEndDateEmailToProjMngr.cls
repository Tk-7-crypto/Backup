/*
* Test class for BCH_PSA_ProjEndDateEmailToProjMngr
*/
@IsTest
public class TST_BCH_PSA_ProjEndDateEmailToProjMngr {
    @testSetup
    static void setupTestData(){
        
        UTL_PSA_TestData.createPermissionControls();
        
        //contact
        Contact contact = UTL_PSA_TestData.createResources(1, false)[0];
        RecordType contactRecordType = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        contact.RecordTypeId = contactRecordType.Id;
        contact.Email = 'test@metacube.com';
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        insert contact;
        
        //program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //group
        pse__Grp__c groups = new pse__Grp__c(Name = 'RADDS');
        insert groups;
        
        //rds project 1
        pse__Proj__c project1 = UTL_PSA_TestData.createProjects(1, false)[0];
        project1.Program__c = program.id;
        project1.pse__Group__c = groups.id;
        project1.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        project1.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        project1.Project_Code__c ='12345';
        project1.pse__End_Date__c = System.today().addDays(-30);
        project1.pse__Start_Date__c = System.today().addDays(-60);
        project1.pse__Project_Manager__c = contact.id;
        project1.Name = 'test project';
        insert project1;
        
        //rds settings
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Project_EndDate_Failed_Batch_Email_Ids__c = 'test@iqvia.com';
        insert rdsSettings;
    }
   
    @isTest
    static void testExecuteBatch(){
        test.startTest();
        BCH_PSA_ProjEndDateEmailToProjMngr batchObj = new BCH_PSA_ProjEndDateEmailToProjMngr();
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertEquals(1, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
}
