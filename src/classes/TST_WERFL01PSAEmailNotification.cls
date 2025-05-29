/*
* Test class for FLOW- WERFL01PSAEmailNotification
*/
@IsTest
public class TST_WERFL01PSAEmailNotification {
    
    @testSetup
    static void setupTestData(){
        
        UTL_PSA_TestData.createPermissionControls();
        
        //program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        testResource.Email = 'test@email.com';
        insert testResource;
        
        //group
        pse__Grp__c groups = new pse__Grp__c(Name = 'RADDS');
        insert groups;
        
        //rds project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        parentproject.Program__c = program.id;
        parentproject.pse__Group__c = groups.id;
        parentproject.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Project_Code__c ='12345';
        parentproject.pse__End_Date__c = System.today().addDays(-30);
        parentproject.pse__Start_Date__c = System.today().addDays(-60);
        parentproject.pse__Project_Manager__c = testResource.id;
        parentproject.Name = 'test project';
        insert parentproject;
                
        //service line [PVS]
        Service_Line__c pvsServiceLine = new Service_Line__c(
        Name = CON_PSA.PV_SOLN_SRVC_NAME,
        Active__c=true,
        Service_Line_Code__c = 'PVSU'
        );
        insert pvsServiceLine;
        
        //service line project
        pse__Proj__c pvsProject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'PV Solutions Project', false);
        pvsProject.Service_Line__c = pvsServiceLine.Id;
        pvsProject.pse__Parent_Project__c = parentproject.id;
        pvsProject.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        pvsProject.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
        pvsProject.pse__Project_Manager__c = testResource.id;
        pvsProject.Service_Line_Lead__c = testResource.id;
        insert pvsProject;
        
        //project task [rds] 1
        pse__Project_Task__c projectTask1 = new pse__Project_Task__c (
            RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_PROJECT_TASK),
            pse__Status__c = CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS,
            Name = 'Test Complete Project Files Review',
            pse__End_Date_Time__c = Date.today().addDays(3),
            pse__Project__c = pvsProject.Id,
            Trigger_Email_Notification__c = TRUE
        );
        insert projectTask1;
        
        //project task [rds] 2
        pse__Project_Task__c projectTask2 = new pse__Project_Task__c (
            RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_PROJECT_TASK),
            pse__Status__c = CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS,
            Name = 'Test Complete Project Files Review',
            pse__End_Date_Time__c = Date.today().addDays(14),
            pse__Project__c = pvsProject.Id,
            Trigger_Email_Notification__c = TRUE
        );
        insert projectTask2;
        
        //rds settings
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Project_EndDate_Failed_Batch_Email_Ids__c = 'test@iqvia.com';
        rdsSettings.Project_Task_Email_to_SLL_Recipient__c = 'test@iqvia.com';
        rdsSettings.Project_Task_SLL_Failed_Batch_Email_Ids__c = 'test@iqvia.com';
        insert rdsSettings;
    }
   
    @isTest
    static void testExecuteBatch_BCH_PSA_ProjEndDateEmailToProjMngr(){
        test.startTest();
        BCH_PSA_ProjEndDateEmailToProjMngr batchObj = new BCH_PSA_ProjEndDateEmailToProjMngr();
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertNotEquals(2, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
    
    
    //45 days cumulative email
    @isTest
    static void testExecuteBatchFortyFiveDays_BCH_PSA_Send_Monthly_LR_Metric_Mails(){
        test.startTest();
        BCH_PSA_ProjectTaskMailToServiceLineLead batchObj = new BCH_PSA_ProjectTaskMailToServiceLineLead();
        batchObj.batchMode = 'NEXT45DAYS';
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertNotEquals(2, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
    
    //14 days cumulative email
    @isTest
    static void testExecuteBatchForteenDays_BCH_PSA_Send_Monthly_LR_Metric_Mails(){
        test.startTest();
        BCH_PSA_ProjectTaskMailToServiceLineLead batchObj = new BCH_PSA_ProjectTaskMailToServiceLineLead();
        batchObj.batchMode = '14DAYSPRIOR';
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertNotEquals(2, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
    
    //3 days cumulative email
    @isTest
    static void testExecuteBatchThreeDays_BCH_PSA_Send_Monthly_LR_Metric_Mails(){
        test.startTest();
        BCH_PSA_ProjectTaskMailToServiceLineLead batchObj = new BCH_PSA_ProjectTaskMailToServiceLineLead();
        batchObj.batchMode = '3DAYSPRIOR';
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertNotEquals(2, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }   
}
