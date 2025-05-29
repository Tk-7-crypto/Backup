/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Project_Task_Assignment
 */


@isTest
private class TST_SLT_Project_Task_Assignment {

    
    @IsTest
    static void testGetSObject () {
        //setupTestData();
        Test.startTest();
        SLT_Project_Task_Assignment sltProjectTaskAssignment = new SLT_Project_Task_Assignment();
        sltProjectTaskAssignment.getSObjectType();
        Test.stopTest();


    }


    @IsTest
    static void testTaskAssignmentByTask () {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project_Task__c'};
        List<pse__Project_Task_Assignment__c> idToTask = new SLT_Project_Task_Assignment().getTaskAssignmentsByTask(new Set<Id> {projecttask.id}, fieldSet );
        Test.stopTest();
        
        }

    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Project_Task__c projecttask;
    static pse__Project_Task_Assignment__c PTA;
    static Contact contact;
    static Contact anothercontact;
    
    static void setupTestData () {
      
        

        
        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
      
        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        insert project;
        System.debug('&&& inserted sub project');

      
        UTL_PSA_TestData.createPermissionControls(); 

         //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
	    update contact;
        
        anothercontact = UTL_PSA_TestData.resources[1];
        System.debug('&&& contact');
        
        //Project Task
        projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable Task'); 
        projecttask.pse__Project__c = project.id;
        insert projecttask;
        System.debug('&&& inserted project task');
         

        //project task assignment
        PTA = new pse__Project_Task_Assignment__c();
        PTA.pse__Project_Task__c = projecttask.id;
        PTA.pse__Resource__c = contact.Id;
        PTA.Is_Primary__c = true;
        //insert PTA;
        System.debug('&&& inserted project task assignment');
        
       
       

    }

    }