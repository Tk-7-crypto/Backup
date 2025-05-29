@isTest
private class TST_SLT_Task {

    static Apttus__APTS_Agreement__c getAgreementData(Id OpportuntiyId){

        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;

        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.Apttus__Related_Opportunity__c = OpportuntiyId;
        return testAgreement;
    }

    static Opportunity setOpportunityData(Id accountId){

        Indication_List__c indicationList = new Indication_List__c(Therapy_Area__c = CON_CPQ.ONCOLOGY);
        insert indicationList;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = 'Data Sciences';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c='MVP123';
        testOpportunity.Potential_Regions__c = 'Asia Pacific';
        insert testOpportunity;    
        return testOpportunity;
    }

    static Account setAccountData(){

        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    static Task setTaskData(String whatId){

        Task taskObj = UTL_TestData.createTask('test', whatId, CON_CPQ.OPEN, CON_CPQ.NORMAL);
        taskObj.OwnerId = UserInfo.getUserId();
        taskObj.Status = 'Not Started';
        taskObj.RecordTypeId = SObjectType.Task.getRecordTypeInfosByName().get(CON_CPQ.CPQ_TASK).getRecordTypeId();
        insert taskObj;
        return taskObj;
    }
    
    @isTest
	static void testSelectTaskById(){
        
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c agreement = getAgreementData(testOpportunity.Id);
        insert agreement;
        Task taskObj = setTaskData(agreement.Id);

        Test.startTest();
        	List<Task> taskList = new SLT_Task().selectById(new Set<Id>{taskObj.Id});
        Test.stopTest();

        system.assertEquals(1, taskList.size(),'Should Return Task');
	}
	
    @isTest
	static void testSelectNonCompletedTaskByWhatIdAndOwnerId(){
        
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c agreement = getAgreementData(testOpportunity.Id);
        agreement.OwnerId = UserInfo.getUserId();
        insert agreement;
        Task taskObj = setTaskData(agreement.Id);
		Set<String> taskFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.STATUS};
        Set<Id> taskRecordTypeIds = new Set<Id>{SObjectType.Task.getRecordTypeInfosByName().get(CON_CPQ.CPQ_TASK).getRecordTypeId()};
            
        Test.startTest();
        	List<Task> taskList = new SLT_Task().selectNonCompletedTaskByWhatIdAndOwnerId(taskFieldSet, agreement.Id, UserInfo.getUserId(), taskRecordTypeIds);
        Test.stopTest();

        system.assertEquals(1, taskList.size(),'Should Return Task');
	}
    
    @isTest
    static void testSelectTaskNonCompletedTasForAgreements(){

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c agreement = getAgreementData(testOpportunity.Id);
        agreement.OwnerId = UserInfo.getUserId();
        insert agreement;
        Task taskObj = setTaskData(agreement.Id);
        Set<String> taskFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.STATUS};
        Set<Id> taskRecordTypeIds = new Set<Id>{SObjectType.Task.getRecordTypeInfosByName().get(CON_CPQ.CPQ_TASK).getRecordTypeId()};
        Set<Id> whatIds = new Set<Id>{agreement.Id};

        Test.startTest();
            List<Task> taskList = new SLT_Task().selectTaskNonCompletedTasForAgreements(taskFieldSet, whatIds, taskRecordTypeIds);
        Test.stopTest();

        system.assertEquals(1, taskList.size(),'Should Return Task');
    }

    @isTest
    static void testGetTasksShouldReturnTasksList(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        TST_CLM_TestDataFactory.createTask(objAgreement.Id,true);
        Set<String> fieldsForTasks = new Set<String>{'Id','Subject'};
        String conditionFortasks= 'WhatId = \''+ objAgreement.Id +'\'';

        Test.startTest();
            List<Task> taskList = new SLT_Task().getTasks(fieldsForTasks, conditionFortasks, 1, 'CreatedDate');
        Test.stopTest();

        system.assertEquals(1, taskList.size(),'Should Return Task');
    }
    
    @isTest
    static void testGetTasksByCampaignName(){
        Campaign campaign = new Campaign(Name = 'test' , Status = 'Planned');
        insert campaign;
        Task task = new Task();
        task.RecordTypeId = CON_CRM.MQL_TASK_RECORD_TYPE_ID;
        task.Disposition__c = CON_CRM.TASK_Disposition_Accept;
        task.Campaign_Name2__c = campaign.Id;
        Insert task;
        
        Test.startTest();
        List<AggregateResult> taskList = new SLT_Task().getTasksByCampaign(new Set<String>{campaign.Id}, CON_CRM.TASK_Disposition_Accept, CON_CRM.MQL_TASK_RECORD_TYPE_ID);
        Test.stopTest();
    }

    @isTest
    private static void testSelectTaskByWhatIds(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        insert agreement;
		
        Task task = UTL_TestData.createTask('Task Test', agreement.Id, 'open','normal');   
        insert task;
        
        Test.startTest();
        	List<Task> taskList = new SLT_Task().SelectTaskByWhatIds(new Set<String>{'Id'}, new Set<Id>{agreement.Id}, 'WhatId IN: whatIds');
        Test.stopTest();
        
        System.assertEquals(1, taskList.size(), 'Task List is  empty when not expected');
    }
}