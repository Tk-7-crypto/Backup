/*
* Test class for BCH_PSA_Send_Monthly_LR_Metric_Mails
*/
@IsTest
public class TST_BCH_PSA_ProjectTaskMailToSLLead {
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
        
        //rds project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        parentproject.Program__c = program.id;
        parentproject.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Project_Code__c ='12345';
        insert parentproject;
        
        //service line [PVS]
        //Service_Line__c pvsServiceLine = new Service_Line__c (
        //    Active__c = true,
        //    Service_Line_Code__c = 'SL1',
        //   Name = CON_PSA.PV_SOLN_SRVC_NAME
        //);
        Service_Line__c pvsServiceLine = UTL_PSA_TestData.createServiceLine(1, false)[0];
        pvsServiceLine.Name = CON_PSA.PV_SOLN_SRVC_NAME;
        pvsServiceLine.Active__c = true;
        insert pvsServiceLine;
        
        //service line project
        pse__Proj__c pvsProject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'PV Solutions Project', false);
        pvsProject.Service_Line__c = pvsServiceLine.Id;
        pvsProject.pse__Parent_Project__c = parentproject.id;
        pvsProject.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        pvsProject.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
        pvsProject.pse__Project_Manager__c = contact.id;
        pvsProject.Service_Line_Lead__c = contact.id;
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
        rdsSettings.Project_Task_Email_to_SLL_Recipient__c = 'test@iqvia.com';
        rdsSettings.Project_Task_SLL_Failed_Batch_Email_Ids__c = 'test@iqvia.com';
        insert rdsSettings;
    }
    
    //45 days cumulative email
    @isTest
    static void testExecuteBatchFortyFiveDaysCumulative(){
        test.startTest();
        BCH_PSA_ProjectTaskMailToServiceLineLead batchObj = new BCH_PSA_ProjectTaskMailToServiceLineLead();
        batchObj.batchMode = 'NEXT45DAYS';
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertEquals(1, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
    
    //14 days cumulative email
    @isTest
    static void testExecuteBatchForteenDaysPrior(){
        test.startTest();
        BCH_PSA_ProjectTaskMailToServiceLineLead batchObj = new BCH_PSA_ProjectTaskMailToServiceLineLead();
        batchObj.batchMode = '14DAYSPRIOR';
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertEquals(1, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
    
    
    //3 days cumulative email
    @isTest
    static void testExecuteBatchThreeDaysPrior(){
        test.startTest();
        BCH_PSA_ProjectTaskMailToServiceLineLead batchObj = new BCH_PSA_ProjectTaskMailToServiceLineLead();
        batchObj.batchMode = '3DAYSPRIOR';
        Database.executeBatch(batchObj, 200);
        test.stopTest();
        
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertEquals(1, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
}
