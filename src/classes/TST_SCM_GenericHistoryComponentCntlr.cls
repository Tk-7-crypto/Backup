@isTest
private class TST_SCM_GenericHistoryComponentCntlr {
    private static User testUser;
    private static Opportunity testOpportunity;
    private static Agreement__c testAgreement;
    private static void setUpData(){
        List<Account> testAccounts = new List<Account>();
        Account testAccount = new Account(Name = 'TestAccountNameForSCM1',CurrencyIsoCode = 'USD',
            Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testAccount);
        insert testAccounts;
        
        
        
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',
            Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description',EmployeeNumber ='08080808');
        listOfUsers.add(testUser);
        insert listOfUsers;
        
        testOpportunity = new Opportunity (Name='Default' ,StageName = '2 - Verify Opportunity',
            CloseDate = System.today() ,Budget_Available__c = 'Yes',CurrencyIsoCode = 'USD');
        insert testOpportunity;  
        
        List<OpportunityFieldHistory> listOpportunityFieldHistory = new List<OpportunityFieldHistory>();
        OpportunityFieldHistory objectHistory = new OpportunityFieldHistory(OpportunityId = testOpportunity.Id, 
            Field = 'Name');
        listOpportunityFieldHistory.add(objectHistory);
        OpportunityFieldHistory objectHistory1 = new OpportunityFieldHistory(OpportunityId = testOpportunity.Id, 
            Field = 'created');
        listOpportunityFieldHistory.add(objectHistory1);
        insert objectHistory;
        
        List<Agreement__c> testAgreements = new List<Agreement__c>();
        testAgreement = new Agreement__c(Name ='testAgree2',Account__c = testAccount.id,
            Active__c = false,Company_Signed_Date__c = Date.today(),Contract_Start_Date__c = Date.today().addDays(2),
            Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc',
            Related_Opportunity__c = testOpportunity.Id); 
        testAgreements.add(testAgreement);
        insert testAgreements;
        
        List<Agreement__History> listAgreementHistory = new List<Agreement__History>();
        Agreement__History agreementHistory = new Agreement__History(ParentId = testAgreement.Id, 
            Field = 'Name');
        listAgreementHistory.add(agreementHistory);
        insert listAgreementHistory;
    }
    
    @isTest
    private static void testGetObjectHistoryShouldReturnBlankListWhenNoObjectPassed(){
        setUpData();
        System.runAs(testUser)
        { 
            SCM_GenericHistoryComponentCntlr controller = new SCM_GenericHistoryComponentCntlr();
            Test.startTest();
                List<SCM_GenericHistoryComponentCntlr.objectHistoryLine> listObjectHistoryLine = 
                    controller.getObjectHistory();
            Test.stopTest();
            
            System.assertEquals(true,listObjectHistoryLine.isEmpty(), 
                'The returned list is not blank when expected');
                        
        } 
    }
    
    @isTest
    private static void testGetObjectHistoryShouldReturnListWhenValidObjectPassed(){
        setUpData();
        System.runAs(testUser)
        { 
            SCM_GenericHistoryComponentCntlr controller = new SCM_GenericHistoryComponentCntlr();
            Test.startTest();
                controller.myObject = testOpportunity;
                List<SCM_GenericHistoryComponentCntlr.objectHistoryLine> listObjectHistoryLine = 
                    controller.getObjectHistory();
            Test.stopTest();
            
            
            System.assertNotEquals(true,listObjectHistoryLine.isEmpty(), 
                'The returned list not blank, when expected ');
                        
        } 
    }
    
    @isTest
    private static void testGetObjectHistoryShouldReturnListWhenOpportunityUpdated(){
        setUpData();
        System.runAs(testUser)
        { 
            SCM_GenericHistoryComponentCntlr controller = new SCM_GenericHistoryComponentCntlr();
            Test.startTest();
                testOpportunity.Budget_Available__c = 'No';
                testOpportunity.Name = 'Test Opp - New';
                update testOpportunity;
                controller.myObject = testOpportunity;
                List<SCM_GenericHistoryComponentCntlr.objectHistoryLine> listObjectHistoryLine = 
                    controller.getObjectHistory();
            Test.stopTest();
            
            
            System.assertNotEquals(true,listObjectHistoryLine.isEmpty(), 
                'The returned list not blank, when expected ');
                        
        } 
    }
    
    @isTest
    private static void testGetObjectHistoryShouldReturnListWhenAgreementUpdated(){
        setUpData();
        System.runAs(testUser)
        { 
            SCM_GenericHistoryComponentCntlr controller = new SCM_GenericHistoryComponentCntlr();
            Test.startTest();
                testAgreement.Active__c = true;
                testAgreement.Name = 'Test Agreement - New';
                testAgreement.Related_Opportunity__c = null;
                update testAgreement;
                controller.myObject = testAgreement;
                List<SCM_GenericHistoryComponentCntlr.objectHistoryLine> listObjectHistoryLine = 
                    controller.getObjectHistory();
            Test.stopTest();
            
            System.assertNotEquals(true,listObjectHistoryLine.isEmpty(), 
                'The returned list not blank, when expected ');
                        
        } 
    }
    
    @isTest
    private static void testReturnFieldLabelShouldReturnFieldLabelWhenAPINamePassed(){
        setUpData();
        System.runAs(testUser)
        { 
            SCM_GenericHistoryComponentCntlr controller = new SCM_GenericHistoryComponentCntlr();
            Test.startTest();
                
                controller.myObject = testOpportunity;
                controller.getObjectHistory();
                String returnValue1 = SCM_GenericHistoryComponentCntlr.returnFieldLabel('Name');
                SCM_GenericHistoryComponentCntlr.myObjectFieldMap = new Map<String, Schema.SObjectField>();
                String returnValue2 = SCM_GenericHistoryComponentCntlr.returnFieldLabel('X4_Delivering_Proposal_Stage_Entry__c');
                SCM_GenericHistoryComponentCntlr.objectHistoryLine objLine= 
                    new SCM_GenericHistoryComponentCntlr.objectHistoryLine();
                objLine.theDate = String.valueOf(Date.today());
                objLine.who  = 'Test';
                objLine.userId = UserInfo.getUserId();
                objLine.action = 'Created';
            Test.stopTest();
            
            System.assertEquals('Name',returnValue1, 'Invalid Label Returned');
            System.assertEquals('4. Delivering Proposal Stage Entry',returnValue2, 'Invalid Label Returned');
                        
        } 
    }
}