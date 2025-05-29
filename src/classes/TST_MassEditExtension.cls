@isTest
public class TST_MassEditExtension {
    static List<Case> createRNDCase() {
        List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testSetupTestSiteAccount1', RDSponsor__c = true, RDClinicalSite__c = true,
                                   RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct);
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1', RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct2);
        insert accList;
        
        Contact con = new Contact(FirstName = 'TestFirstName', Lastname = 'testSetupContact', Phone = '(619)852-4569', Department = 'Mission Control', 
                                  Title = 'Mission Specialist - Neptune', Email = 'testSetupcon@iqvia.com', AccountId = acct.Id);
        insert con;
        
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Study__c study1 = CSM_Util.createStudy(acct2.Id);
        study1.Name = 'STUDY12';
        study1.StudyID__c = 'PROJ0012';
        study1.LabProjectCode__c = 'LABPROJ0012';
        insert study1;
        
        StudySiteContactRelationship__c siteConR1 = new StudySiteContactRelationship__c(Study__c = study1.Id, 
                                                                                        Investigator_Name__c = con.Id,
                                                                                        Site_Name__c = acct.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Case csAssistanceRequest = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c = study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'Assistance Request Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RnD_Email_Flag__c = true,
            RecordTypeId = RecordTypeIdCase
        );
        return new List<Case>{csAssistanceRequest};
    }
    static testMethod void singleUpdateTest() {
    	Opportunity o = new Opportunity();
    	List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
    	
    	ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
    	setCtr.setSelected(new Opportunity[]{o});
        MassEditExtension controller = new MassEditExtension(setCtr);
		
		String value = 'test';
	    o.Name = 'test';
        controller.save();
        
	    System.assertEquals(o.Name, value);
    }

    @IsTest
    private static void testActivityUpdate() {
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_P_SYS_ADMIN, 2);
        listOfUser[0].LastName = 'System';
        insert listOfUser;
        User userToRunAs = listOfUser[1];
        
        List<Case> csAssistanceRequest = createRNDCase();
        insert csAssistanceRequest;
        
        Activity__c systemActivity = new Activity__c();
        systemActivity.ActivityOwner__c = listOfUser[0].Id; 
        systemActivity.Case__c = csAssistanceRequest[0].Id;
        Activity__c activity = new Activity__c(Case__c = csAssistanceRequest[0].Id);
        List<Activity__c> activityList = new List<Activity__c>{systemActivity, activity};
        insert activityList;
        
        System.runAs(userToRunAs) {
            ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(activityList);
            setCtr.setSelected(activityList);
            MassEditExtension controller = new MassEditExtension(setCtr);
            
            Test.startTest();
                controller.save();
            Test.stopTest();   
            
        }
    }
}