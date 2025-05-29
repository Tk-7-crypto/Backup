@isTest
private class TST_CNT_CSM_Email_Opt_Out {

        
        /**
* This method used to set up testdata
*/ 
        @testSetup
        static void dataSetup() {
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            
            String profilId2 = [select id from Profile where Name='System Administrator'].Id;
            User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
            accOwner.EmployeeNumber = '070707071';
            insert accOwner;
            
            System.runAs (accOwner) {
                Account account1 = UTL_TestData.createAccount();
                account1.ownerId=accOwner.Id;
                insert account1;
                List<Contact> listOfContact = UTL_TestData.createContacts(account1.Id,1);
                insert listOfContact;
                List<Case> listCase= new List<Case>();
                Case newCase = UTL_TestData.createCase();
                newCase.RecordTypeId = new SLT_RecordType().getRecordType('DATACase')[0].Id;
                newCase.contactId = listOfContact[0].id;
                listCase.add(newCase);
                insert listCase;
            } 
            
        }

    @IsTest
    static void testupdateContact() {
        Id accountId = [Select Id,Name from Account where name = 'TestAccount' limit 1].Id;
        Id ContactId = [select Id, name from contact where accountId =: accountId limit 1].Id;
        Id caseId = [select Id from Case where ContactId =:ContactId limit 1].Id;
        
        Test.startTest();
             CNT_CSM_Email_Opt_Out.updateContact(ContactId, caseId);
        Test.stopTest();
        
        Contact newContact = [select Id,Opt_Out_From__c from Contact where Id =: ContactId limit 1];
        System.assertEquals('Self Registration', newContact.Opt_Out_From__c, 'contact will not receive email');
    }
}