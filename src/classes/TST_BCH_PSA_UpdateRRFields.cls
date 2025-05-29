/**
 * Test class for BCH_PSA_UpdateRRFields
 */
@IsTest
private class TST_BCH_PSA_UpdateRRFields {
    
    @IsTest
    static void testBatch(){
        Test.startTest();
        Contact contact = UTL_PSA_TestData.resources[0];
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
        
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        project.pse__Project_Manager__c = contact.id;
        project.Service_Line_Lead__c = contact.id;
        insert project;
        
        UTL_PSA_TestData.createPermissionControls();
        //milestones
        pse__Milestone__c milestones = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestones.RecordTypeId = milestonerecTypeId;
        milestones.pse__Project__c = project.Id;
        insert milestones;
        
        //resource request
        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
        resourcerequest.pse__Project__c = project.Id;
        insert resourcerequest;
        
        project.pse__Project_Manager__c = contact.Id;
        project.Service_Line_Lead__c = contact.Id;
        update project;
        Set<Id> projectId = new Set<Id>();
        projectId.add(project.Id);
        Database.executeBatch(new BCH_PSA_UpdateRRFields(projectId));
        Test.stopTest();
        pse__Resource_Request__c rq = [SELECT Id, Project_Manager__c, Service_Line_Lead__c FROM pse__Resource_Request__c WHERE Id = :resourcerequest.Id];
        System.assertEquals(project.pse__Project_Manager__c, rq.Project_Manager__c);
        System.assertEquals(project.Service_Line_Lead__c, rq.Service_Line_Lead__c); 
    }
}
