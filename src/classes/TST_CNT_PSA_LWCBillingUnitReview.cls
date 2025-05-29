/*
 * TST_CNT_PSA_LWCBillingUnitReview
 *
 * Providing proofs for the CNT PSA LWC BillingUnit Review page
 *
 *
 */
/*
   sfdx force:apex:test:run -t TST_CNT_PSA_BillingUnitReview-c -r json
 */
@isTest(isParallel=false)
private class TST_CNT_PSA_LWCBillingUnitReview 
{
	@testSetup
    static void dataSetup(){
        UTL_PSA_TestData.createPermissionControls();
        pse__Proj__c parentProject = UTL_PSA_TestData.createParentProject();
    
        pse__Proj__c servicelineproject = UTL_PSA_TestData.createServiceLineProject(parentProject, false);
        servicelineproject.pse__Exclude_From_Billing__c = false;
        insert servicelineproject;
        
        
        pse__Proj__c anotherservicelineproject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'Test Project 2 FF', true);
		
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        UTL_PSA_TestData.createResources(1,false);
        Contact contact = [Select id,FirstName,LastName,Email from Contact limit 1];
        contact.RecordTypeId = contactRT.Id;
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
        
         // Assignment 
        List<pse__Assignment__c> assignments = UTL_PSA_TestData.createAssignments(new List<Contact> {contact, contact, contact},servicelineproject,false);
        assignments[0].pse__Bill_Rate__c = 200;
        assignments[0].Sub_role__c = 'IQVIA Primary GSO';
        assignments[1].pse__Bill_Rate__c = 200;
        assignments[1].Sub_role__c = 'IQVIA GSO LM';
        assignments[2].pse__Bill_Rate__c = 200;
        assignments[2].Sub_role__c = 'IQVIA TAH';
        insert assignments;
    
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
    
        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceLine.Id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        milestone.pse__Exclude_from_Billing__c = false;
        insert milestone;
    
        pse__Milestone__c anothermilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        anothermilestone.RecordTypeId = milestonerecTypeId;
        anothermilestone.pse__Project__c = anotherservicelineproject.Id;
        anothermilestone.Service_Line__c = anotherserviceLine.Id;
        anothermilestone.Service__c = anotherservice.id;
        anothermilestone.Start_Date__c = system.today();
        anothermilestone.End_Date__c =  anothermilestone.Start_Date__c.addDays(30);
        insert anothermilestone;
        
        Id deliverableRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE);
        //Parent Project Task
        pse__Project_Task__c parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
        parentprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
        parentprojecttask.pse__Project__c = servicelineproject.id;
        parentprojecttask.pse__Milestone__c = milestone.id;
        //parentprojecttask.Target__c = target.id;
        parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.Service_Line__c = serviceline.id;
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.pse__Status__c = 'Planned';
        parentprojecttask.Unit_Price__c = 200;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        parentprojecttask.Include_in_Financials__c = true;
        test.startTest();
        
        pse__Project_Task_Assignment__c PTA2 = new pse__Project_Task_Assignment__c();
        PTA2.pse__Project_Task__c = parentprojecttask.id;
        PTA2.pse__Resource__c = contact.Id;
        PTA2.Is_Primary__c = true;
        
        pse__Project_Task__c deliverable = new pse__Project_Task__c(
            RecordTypeId=deliverableRecTypeId,
            Quantity__c = 100,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            Service_Line__c= serviceLine.id,
            pse__Milestone__c = milestone.id,
            pse__Project__c = servicelineproject.id,
            Billable__c=true,
            pse__Parent_Task__c = parentprojecttask.Id,
            resource__c = contact.Id
            );
        insert deliverable;
        
        pse__Milestone__c billingMilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id billingMilestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_BILLING);
        billingMilestone.RecordTypeId = billingMilestonerecTypeId;
        billingMilestone.pse__Project__c = servicelineproject.Id;
        billingMilestone.Service__c = service.id;
        billingMilestone.Service_Line__c = serviceLine.Id;
        billingMilestone.Start_Date__c = system.today();
        billingMilestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        billingMilestone.pse__Exclude_from_Billing__c = false;
        insert billingMilestone;

    }

    @isTest static void testGetServiceLines() {
        //setupTestData();
        pse__Proj__c anotherservicelineproject = [Select Id, Name from pse__Proj__c where Name ='Test Project 2 FF' limit 1];
        pse__Proj__c parentProject = [Select Id, Name, pse__Parent_Project__c from pse__Proj__c where  pse__Parent_Project__c = NULL limit 1];
        test.startTest();
        List<CNT_PSA_LWCBillingUnitReview.ServiceLineWrapper> actionResult = CNT_PSA_LWCBillingUnitReview.getServiceLineList(anotherservicelineproject.Id,parentProject.Id);
        system.assertNotEquals(null, actionResult);
        system.assertNotEquals(null, actionResult[0].serviceLineUrl);
        system.assertEquals('Test Project 2 FF', actionResult[0].value);
        test.stopTest();
    }

    @isTest static void testGetServiceLinesParentProject() {
        //setupTestData();
        pse__Proj__c parentProject = [Select Id, Name, pse__Parent_Project__c from pse__Proj__c where  pse__Parent_Project__c = NULL limit 1];
        test.startTest();
        List<CNT_PSA_LWCBillingUnitReview.ServiceLineWrapper> actionResult = CNT_PSA_LWCBillingUnitReview.getServiceLineList(parentProject.Id,parentProject.Id);
        List<String> serviceLineNames = new List<String>();
        for( CNT_PSA_LWCBillingUnitReview.ServiceLineWrapper wrapper : actionResult){
            serviceLineNames.add(wrapper.value);
        }
        system.assertNotEquals(null, actionResult);
        system.assert(serviceLineNames.contains('Test Project 1 FF'),'Expected project Test Project 1 FF not found.');
        system.assert(serviceLineNames.contains('Test Project 2 FF'),'Expected another project Test Project 2 FF not found.');
        test.stopTest();
    }


    @isTest static void testGetAllMilestonesNoFilters() {
        //setupTestData();
        pse__Proj__c anotherservicelineproject = [Select Id, Name from pse__Proj__c where Name ='Test Project 2 FF' limit 1];
        pse__Proj__c parentProject = [Select Id, Name, pse__Parent_Project__c from pse__Proj__c where  pse__Parent_Project__c = NULL limit 1];
        pse__Milestone__c anothermilestone = [Select Id, Name, pse__Project__c from pse__Milestone__c where pse__Project__c =: anotherservicelineproject.Id];
        test.startTest();
        List<CNT_PSA_LWCBillingUnitReview.MilestoneWrapper> actionResult = CNT_PSA_LWCBillingUnitReview.getAllMilestonesNoFilters(anotherservicelineproject.Id,parentProject.Id);
        system.assertNotEquals(null, actionResult);
        system.assertEquals(anothermilestone.id, actionResult[0].id);
        test.stopTest();
    }


    @isTest static void testGetAllMilestonesByParentProject() {
        //setupTestData();
        pse__Proj__c parentProject = [Select Id, Name, pse__Parent_Project__c from pse__Proj__c where  pse__Parent_Project__c = NULL limit 1];
        test.startTest();
        List<CNT_PSA_LWCBillingUnitReview.MilestoneWrapper> actionResult = CNT_PSA_LWCBillingUnitReview.getAllMilestonesNoFilters(parentProject.Id,parentProject.Id);
        system.assertNotEquals(null, actionResult);
        system.assertEquals(3, actionResult.size());
        test.stopTest();
    }

    @isTest static void testGetAllMilestones() {
        //setupTestData();
        pse__Proj__c parentProject = [Select Id, Name, pse__Parent_Project__c from pse__Proj__c where  pse__Parent_Project__c = NULL limit 1];
        pse__Milestone__c anothermilestone = [Select Id, Name, pse__Project__c, Start_Date__c, End_Date__c from pse__Milestone__c limit 1];
        test.startTest();
        List<String> servicelinestring = new List<String> {'pv','code'};
        List<CNT_PSA_LWCBillingUnitReview.MilestoneWrapper> actionResult = CNT_PSA_LWCBillingUnitReview.getAllMilestones(parentProject.Id,servicelinestring,anothermilestone.Start_Date__c,anothermilestone.End_Date__c);
        system.assertNotEquals(null, actionResult);
        system.assertEquals(3, actionResult.size());
        test.stopTest();
    }
    
    @isTest static void testcreateBillingMilestone() {
        test.startTest();
        pse__Proj__c servicelineproject = [Select Id, Name from pse__Proj__c where pse__Exclude_From_Billing__c = false limit 1];
        pse__Milestone__c milestone = [Select Id,Name, pse__Project__r.Name, Service_Line__c, Service_Line__r.Name, Service__c, Service__r.Name, Rate__c, Budget_Quantity__c, Actual_Quantity__c, Service__r.Service_Code__c, Billed_Quantity__c, pse__Project__r.Id, pse__Project__r.pse__Parent_Project__r.Project_Code__c from pse__Milestone__c limit 1];
        
        CNT_PSA_LWCBillingUnitReview.MilestoneWrapper mw = new CNT_PSA_LWCBillingUnitReview.MilestoneWrapper(milestone);
        system.assertNotEquals(null, mw.serviceLineUrl);
        system.assertNotEquals(null,mw.serviceUrl);
        system.assertNotEquals(null,mw.remainingQuantity);
        mw.serviceLineProjectId = servicelineproject.id;
        
        pse__Milestone__c actionResult = CNT_PSA_LWCBillingUnitReview.createBillingMilestone(new CNT_PSA_LWCBillingUnitReview.MilestoneWrapper(milestone));
        test.stopTest();
    }
    
    

    @isTest static void testApproveForBilling() {
        //setupTestData();
        test.startTest();
       
        pse__Proj__c servicelineproject = [Select Id, Name from pse__Proj__c where pse__Exclude_From_Billing__c = false limit 1];
        pse__Milestone__c milestone = [Select Id,Name, pse__Project__r.Name, Service_Line__c, Service_Line__r.Name, Service__c, Service__r.Name, Rate__c, Budget_Quantity__c, Actual_Quantity__c, Service__r.Service_Code__c, Billed_Quantity__c, pse__Project__r.Id, pse__Project__r.pse__Parent_Project__r.Project_Code__c from pse__Milestone__c where RecordType.name = 'RDS Billing' limit 1 ];
        //pse__Project_Task__c deliverable = [Select Id,Name,pse__Project__c, pse__Project__r.Name, Billing_Hold__c,Not_Billed_Reason__c,Service__r.Name, pse__Actual_End_Date_Time__c, Quantity__c, Target__r.Name, Drug__r.Name, Service__r.Service_Code__c, Resource__r.name, Total_Billable_Amount__c, Eligible_for_Billing__c, Tracking_Number__c from pse__Project_Task__c where pse__Milestone__c =: milestone.Id ];
        //deliverable.Billing_Hold__c=false;
        //deliverable.Exclude_from_Billing__c=false;
        //update deliverable;
        
        CNT_PSA_LWCBillingUnitReview.MilestoneWrapper mw = new CNT_PSA_LWCBillingUnitReview.MilestoneWrapper(milestone);
        system.assertNotEquals(null, mw.serviceLineUrl);
        system.assertNotEquals(null,mw.serviceUrl);
        system.assertNotEquals(null,mw.remainingQuantity);
        mw.serviceLineProjectId = servicelineproject.id;
        
        //CNT_PSA_LWCBillingUnitReview.DeliverableWrapper dw = new CNT_PSA_LWCBillingUnitReview.DeliverableWrapper(deliverable);
        //mw.deliverables = new List<CNT_PSA_LWCBillingUnitReview.DeliverableWrapper> {dw};
        //mw.eligibleDeliverables = mw.deliverables;
        CNT_PSA_LWCBillingUnitReview.MilestoneWrapper[]  mwArray = new CNT_PSA_LWCBillingUnitReview.MilestoneWrapper[] {};
        mwArray.add(mw);
        String actionResult = CNT_PSA_LWCBillingUnitReview.approveForBilling(mwArray);
        test.stopTest();
        system.assertNotEquals(null, actionResult);
        system.assertEquals('Success', actionResult);
    }
	

    @isTest static void testMakeHold() {
        //setupTestData();
        pse__Project_Task__c deliverable = [Select Id,Billing_Hold__c,Exclude_from_Billing__c from pse__Project_Task__c limit 1];
        test.startTest();
    
        // make sure it raises error on invalid input to make hold
        Boolean raisedError = false;
        try {
            List<Map<String,String> > invalidList = null;
            String invalidReason = null;
            CNT_PSA_LWCBillingUnitReview.makeHold(invalidList, invalidReason);
        } catch (Exception e) {
            raisedError = true;
        }
        system.assertEquals(true, raisedError, 'Error expected, but call succeeded!');
        deliverable.Billing_Hold__c=false;
        update deliverable;
        Map<String,String> idmap = new Map<String,String>();
        idmap.put('Id',deliverable.id);
        List<Map<String,String> > updateselectedrecords = new List<Map<String,String> >();
        updateselectedrecords.add(idmap);
        String actionResult = CNT_PSA_LWCBillingUnitReview.makeHold(updateSelectedRecords, 'No Bill Reason');
        test.stopTest();
        system.assertNotEquals(null, actionResult);
        system.assertEquals('Success', actionResult);
    }


    @isTest static void testRemoveHold() {
        //setupTestData();
        pse__Project_Task__c deliverable = [Select Id,Billing_Hold__c,Exclude_from_Billing__c from pse__Project_Task__c limit 1];
        test.startTest();
        // make sure it raises error on invalid input to make hold
        Boolean raisedError = false;
        try {
            List<Map<String,String> > invalidList = null;
            CNT_PSA_LWCBillingUnitReview.removeHold(invalidList);
        } catch (Exception e) {
            raisedError = true;
        }
        system.assertEquals(true, raisedError, 'Error expected, but call succeeded!');
    
        Map<String,String> idmap = new Map<String,String>();
        idmap.put('Id',deliverable.id);
        List<Map<String,String> > updateselectedrecords = new List<Map<String,String> >();
        updateselectedrecords.add(idmap);
        String actionResult = CNT_PSA_LWCBillingUnitReview.removeHold(updateSelectedRecords);
        test.stopTest();
        system.assertNotEquals(null, actionResult);
        system.assertEquals('Success', actionResult);
    }

    @isTest static void testExcludeDeliverable() {
        //setupTestData();
        pse__Project_Task__c deliverable = [Select Id,Billing_Hold__c,Exclude_from_Billing__c from pse__Project_Task__c limit 1];
        test.startTest();
        // make sure it raises error on invalid input to make hold
        Boolean raisedError = false;
        try {
            List<Map<String,String> > invalidList = null;
            String invalidReason = null;
            CNT_PSA_LWCBillingUnitReview.excludeDeliverable(invalidList, invalidReason);
        } catch (Exception e) {
            raisedError = true;
        }
        system.assertEquals(true, raisedError, 'Error expected, but call succeeded!');
        Map<String,String> idmap = new Map<String,String>();
        idmap.put('Id',deliverable.id);
        List<Map<String,String> > updateselectedrecords = new List<Map<String,String> >();
        updateselectedrecords.add(idmap);
        String actionResult = CNT_PSA_LWCBillingUnitReview.excludeDeliverable(updateSelectedRecords, 'No Bill Reason');
        test.stopTest();
        system.assertNotEquals(null, actionResult);
        system.assertEquals('Success', actionResult);
    }


    /*
    static pse__Proj__c parentProject;
    static pse__Proj__c servicelineproject;
    static pse__Proj__c anotherservicelineproject;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static Service_Line__c anotherserviceLine;
    static Contact contact;
    static pse__Milestone__c milestone;
    static pse__Milestone__c anothermilestone;
    static pse__Project_Task__c deliverable;
    static pse__Project_Task__c anotherdeliverable;
    static pse__Resource_Request__c resourcerequest;
    
    static void setupTestData () {
    
        // parent project
        parentProject = UTL_PSA_TestData.createParentProject();
    
        // Service line project
        servicelineproject = UTL_PSA_TestData.createServiceLineProject(parentProject, false);
        servicelineproject.pse__Exclude_From_Billing__c = false;
        insert servicelineproject;
    
        //resource request
        //resourcerequest = UTL_PSA_TestData.createResourceRequests(1, servicelineproject)[0];
    
        // Another Service line project
        anotherservicelineproject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'Test Project 2 FF', true);
    
    
        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
    
        UTL_PSA_TestData.createPermissionControls();
    
    
        // service line
        serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'code',
            Name = 'code'
            );
        insert serviceLine;
    
        // service
        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'code'
            );
        insert service;
    
        // service line
        anotherserviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'pv',
            Name = 'pv'
            );
        insert anotherserviceLine;
    
        // service
        Service__c anotherservice = new Service__c(
            Active__c = true,
            Service_Line__c = anotherserviceLine.id,
            Service_Code__c = 'pv'
    
            );
        insert anotherservice;
    
        //milestones
        milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
    
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceLine.Id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        milestone.pse__Exclude_from_Billing__c = false;
        insert milestone;
    
        //anothermilestone
        anothermilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        anothermilestone.RecordTypeId = milestonerecTypeId;
        anothermilestone.pse__Project__c = anotherservicelineproject.Id;
        anothermilestone.Service_Line__c = anotherserviceLine.Id;
        anothermilestone.Service__c = anotherservice.id;
        anothermilestone.Start_Date__c = system.today();
        anothermilestone.End_Date__c =  anothermilestone.Start_Date__c.addDays(30);
        insert anothermilestone;
    
    
        //Deliverable for milestone
        Id deliverableRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE);
        deliverable = new pse__Project_Task__c(
            Quantity__c = 100,
            pse__End_Date_Time__c = date.Today().addDays(30),
            End_Date_Planned__c = date.Today().addDays(30),
            //Resource__c = contact.Id,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            pse__Milestone__c = milestone.Id,
            pse__Project__c = servicelineproject.Id,
            Billable__c=true,
            Type__c='Deliverable',
            RecordTypeId=deliverableRecTypeId
            );
        insert deliverable;
    
    }
	*/
}
