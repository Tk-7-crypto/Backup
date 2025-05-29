/*
* Providing proofs for CNT_PSA_ChecklistTaskMassUpdate
*/
@isTest(isParallel=false)
private class TST_CNT_PSA_ChecklistTaskMassUpdate {
    
    @testSetup
    static void dataSetup() 
    {
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        pse__Proj__c parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentProject.recordTypeId = rdsrecTypeId;
        parentProject.Name = 'Test Parent Project';
        parentproject.Program__c = program.id;
        insert parentProject;
        
        pse__Proj__c servicelineproject = UTL_PSA_TestData.createProjects(2, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        servicelineproject.recordTypeId = recTypeId;
        servicelineproject.pse__Parent_Project__c = parentProject.id;
        servicelineproject.Name = 'Test ServiceLine Project';
        insert servicelineproject;
        
        pse__Proj__c anotherservicelineproject = UTL_PSA_TestData.createProjects(2, false)[1];
        anotherservicelineproject.recordTypeId = recTypeId;
        anotherservicelineproject.pse__Parent_Project__c = parentProject.id;
        anotherservicelineproject.Name = 'Test Another ServiceLine Project';
        insert anotherservicelineproject;
        
        UTL_PSA_TestData.createPermissionControls();
        
        
        Service_Line__c serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'code',
            Name = 'code'
        );
        insert serviceLine;
        
        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'code'
        );
        insert service;
        
        Service_Line__c anotherserviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'pv',
            Name = 'pv'
        );
        insert anotherserviceLine;
        
        Service__c anotherservice = new Service__c(
            Active__c = true,
            Service_Line__c = anotherserviceLine.id,
            Service_Code__c = 'pv'
            
        );
        insert anotherservice;
        
        UTL_PSA_TestData.key = 'MS1';
        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = parentProject.Id;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceLine.Id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
		Test.startTest();
        insert milestone;
        
        
        Id taskrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_PROJECT_TASK);
        
        UTL_PSA_TestData.key = 'RDST1';
        pse__Project_Task__c task1 = UTL_PSA_TestData.createProjectTaskTestSubject();
        task1.pse__Milestone__c= milestone.Id;
        task1.RecordTypeId = taskrecTypeId;
        task1.Parent_Project__c = parentProject.Id;
        task1.pse__Project__c = parentProject.Id;
        task1.Service_Line__c = anotherserviceLine.Id;
        task1.Service__c = anotherservice.id;
        insert task1;
        Test.stopTest();
        
    }
    
    //This method used to update Checklist Tasks.
    @IsTest
    static void testUpdateChecklistTasks() {
        Contact resourceRecord = [SELECT Id, Name from Contact LIMIT 1];
        pse__Project_Task__c task = [SELECT Id,RecordType.Name, pse__Status__c,pse__Start_Date_Time__c, pse__End_Date_Time__c, pse__Description__c FROM pse__Project_Task__c WHERE RecordType.Name='RDS Project Task' LIMIT 1];
        Test.startTest();
        String startDateString = '2021-09-05';
        String endDateString = '2021-10-05';
        String statusString = 'In Progress';
        String descriptionString = 'test description';
        String resourceString = String.valueOf(resourceRecord.Id);
        String tasksUpdatedResponse = CNT_PSA_ChecklistTaskMassUpdate.updateChecklistTasks(new List<pse__Project_Task__c> {task}, startDateString, endDateString, statusString, descriptionString, resourceString);
        Test.stopTest();
        String expected = 'success';
        String actual = tasksUpdatedResponse;
        System.assertEquals(expected, actual, 'Tested');
    }
    
    /*
* Test method for getting  checklist tasks
*/
    @IsTest
    static void testGetProjectTasks() {
        pse__Proj__c rdsProject = [SELECT Id, Name from pse__Proj__c WHERE Name = 'Test Parent Project' LIMIT 1];
        pse__Project_Task__c task1 = [SELECT Id, Name from pse__Project_Task__c LIMIT 50];
        String blankServiceLineProj;
        Test.startTest();
        List<String> fieldList = new List<String> {'Id', 'Name'};
        List<pse__Project_Task__c> taskList = CNT_PSA_ChecklistTaskMassUpdate.getProjectTasks(String.valueOf(rdsProject.Id),blankServiceLineProj,fieldList);
        Test.stopTest();
        String expected = String.valueOf(task1.Id);
        String actual = String.valueOf(taskList[0].Id);
        System.assertEquals(expected, actual,'Tested');
    }
    
    /**
* This method used to update Checklist Tasks.
*/
    @IsTest
    static void testIsUserHavingEditablePermissionSet() {
        Boolean res;
        Test.startTest();
        System.runAs(new User (Id = UserInfo.getUserId())) {
            List<PermissionSet> rdsPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Admin'];
            List<PermissionSetAssignment>  permissionSetAssigmentList = [SELECT Id 
                                                                         FROM PermissionSetAssignment 
                                                                         WHERE AssigneeId =: UserInfo.getUserId() 
                                                                         AND PermissionSetId =: rdsPermissionSet[0].Id ];
            res = CNT_PSA_ChecklistTaskMassUpdate.isUserHavingEditablePermissionSet();
            if(permissionSetAssigmentList.size() > 0){
                System.assertEquals(true, res,'Tested'); 
            }else{
                System.assertEquals(false, res,'Tested'); 
            }
        }
        Test.stopTest();
    }
    
    //Test method for searchContactsBySearchKey
    @IsTest
    static void testFindContactsBySearchKey() {
        Contact resourceRecord = [SELECT Id, Name from Contact LIMIT 1];
        Test.startTest();
        List<UTL_LookupSearchResult> resourceList = CNT_PSA_ChecklistTaskMassUpdate.findContactsBySearchKey(resourceRecord.Name);
        Test.stopTest();
        System.assertEquals(false, resourceList.size()>0,'Tested');
    }
}
