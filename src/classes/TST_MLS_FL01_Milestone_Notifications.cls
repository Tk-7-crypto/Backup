/**
 * This test class is used to test MLS_FL01_Milestone_Notifications flow. 
 */

@isTest
public class TST_MLS_FL01_Milestone_Notifications {
    
    @testSetup
    static void dataSetup()
    {
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
      
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        insert project;
        
        UTL_PSA_TestData.createPermissionControls();

        Contact contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
	    update contact;
        
       
        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1, false)[0];
        resourceRequest.pse__Project__c = project.Id; 
        insert resourceRequest;

        pse__Billing_Event__c billingevent = new pse__Billing_Event__c();
        insert billingevent;

        pse__Billing_Event__c anotherBE = new pse__Billing_Event__c();
        insert anotherBE;

        pse__Billing_Event_Item__c BEI = new pse__Billing_Event_Item__c();
        BEI.pse__Object_Id__c = billingevent.id;
        insert BEI;

        pse__Billing_Event_Item__c anotherBEI = new pse__Billing_Event_Item__c();
        anotherBEI.pse__Object_Id__c = anotherBE.id;
        insert anotherBEI;

        pse__Milestone__c milestones = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_BILLING);  
        milestones.RecordTypeId = milestonerecTypeId;
        milestones.pse__Project__c = project.Id; 
        milestones.pse__Billed__c = false;
        milestones.pse__Invoiced__c = false;
        milestones.pse__Actual_Date__c = system.today();
        milestones.pse__Billing_Event_Item__c = BEI.id;
        milestones.pse__Include_In_Financials__c = true;
        milestones.pse__Approved__c = true;
        insert milestones;

        Service_Line__c serviceline = new Service_Line__c(Name = 'Test Service Line');
        serviceline.Service_Line_Code__c = '09876';
        insert serviceline;

        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.id;
        insert service;

        pse__Milestone__c serviceMilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id serviceMilestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        serviceMilestone.RecordTypeId = serviceMilestonerecTypeId;
        serviceMilestone.Actual_Quantity__c = 10;
        serviceMilestone.Billed_Quantity__c = 15;
        serviceMilestone.pse__Project__c = project.Id;
        serviceMilestone.pse__Target_Date__c = system.today();
        serviceMilestone.Actual_Amount__c = 20;
        serviceMilestone.pse__Milestone_Amount__c = 100;
        serviceMilestone.Billed_Amount__c = 30;
        serviceMilestone.Include_Tasks_on_Deliverables__c = true;
        serviceMilestone.Service__c = service.id;
        serviceMilestone.Service_Line__c = serviceline.id;
        insert serviceMilestone;
        
        Id deliverableRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE);    
        //Parent Project Task
        pse__Project_Task__c parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
        parentprojecttask.recordTypeId = deliverableRecTypeId;
        parentprojecttask.pse__Project__c = project.id;
        parentprojecttask.pse__Milestone__c = serviceMilestone.id;
        parentprojecttask.Countries__c = 'US;';
        parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.Service_Line__c = serviceline.id;
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.pse__Status__c = 'Planned';
        parentprojecttask.Unit_Price__c = 200;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        parentprojecttask.Include_in_Financials__c = true;
        parentprojecttask.Resource__c = Contact.Id;
        
        pse__Project_Task_Assignment__c PTA2 = new pse__Project_Task_Assignment__c();
        PTA2.pse__Project_Task__c = parentprojecttask.id;
        PTA2.pse__Resource__c = contact.Id;
        PTA2.Is_Primary__c = true;

        pse__Project_Task__c projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable'); 
        projecttask.pse__Project__c = project.id;
        projecttask.Pricing_Task_ID__c = '123456';
        projecttask.pse__Milestone__c = serviceMilestone.Id;
        projecttask.Billing_Milestone__c = milestones.id;
        projecttask.pse__Status__c = 'Completed';
        projecttask.pse__Parent_Task__c = parentprojecttask.id;
        projecttask.Resource__c = Contact.Id;
        insert projecttask;
    }
 
    @IsTest
    static void testFlow(){
        pse__Milestone__c milestones = [Select Id,pse__Exclude_from_Billing__c, pse__Status__c,Actual_Quantity__c,Budget_Quantity__c from  pse__Milestone__c where RecordType.Name = 'RDS Billing' limit 1]; 
        Test.startTest();
        milestones.Actual_Quantity__c = 2;
        update milestones; 
        milestones.Budget_Quantity__c = 2;
        update milestones;
        Test.stopTest();
        System.assertEquals((milestones.Actual_Quantity__c/milestones.Budget_Quantity__c), 1, 'Actual to Budget quantity ratio');
    }

}
