/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Pricing_Task
 */


@isTest
private class TST_SLT_Pricing_Task {

    
    //Test get list of field names from field set by field set name
    @IsTest
    static void testgetFieldListByFieldSetName () {
        setupTestData();
        Test.startTest();
        
        List<String> fieldSetName = new SLT_Project_Task().getFieldListByFieldSetName('PSA_RDS_Deliverable_AR');
        
        Test.stopTest();
        Integer expected = 0;
        Integer actual = fieldSetName.size();
        System.assertNotEquals(expected, actual);


    }

    

    /**
     * This method used to get a Pricing Task by Project.
     */    
    @IsTest
    static void testselectByProject() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'Project__c'};
        List<Pricing_Task__c> idToProject = new SLT_Pricing_Task().selectByProject(new Set<Id> {pricingtask.id}, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToProject.size();
        System.assertEquals(expected, actual);
    }



    /**
     * This method used to get pricing tasks associated with a given project and service code
     */    
    @IsTest
    static void selectTasksByProjectAndServiceCode() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'Project__c', 'Service_Code__c','Role__c','Primary_Service__c','Primary_Service_Code__c','Budget_Hours__c','Task_Id__c'};
        Map<String, List<Pricing_Task__c>> pricingTaskId = new SLT_Pricing_Task().selectTasksByProjectAndServiceCode(new Set<Id> {pricingtask.Project__c}, fieldSet );
         System.debug('$$$ Got the pricing task map'+pricingTaskId);
        Test.stopTest();
        
        /*System.assertEquals(expected, actual);
        System.debug('**** ' + actual);*/
    }


    

    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static Pricing_Task__c pricingtask;
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

        //Pricing Task
        pricingtask = new Pricing_Task__c(Name = 'TestPricingTask');
        pricingtask.Project__c = project.id;
        //pricingtask.Service_Code__c = 'SAE1';
        insert pricingtask;
        
        //Project Task
        projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS_Template_Task'); 
        projecttask.pse__Project__c = project.id;
        projecttask.Pricing_Task_ID__c = '123456';
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