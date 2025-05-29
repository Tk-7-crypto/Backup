@isTest
private class TST_DAOH_LiveChatTranscript {
    static testMethod void doTestLead() {
        //create a test Lead
        Lead testLead = new Lead(OwnerId= UserInfo.getUserId(), FirstName = 'Mallikarjuna', LastName = 'Reddy', Email = 'test@test.com', Country = 'USA', LeadSource = 'Corporate Website, Live Chat', Company = 'IQVIA');
        insert testLead;
        //create a Live Chat Visitor
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        //create a Live Chat Transcript
        LiveChatTranscript trans = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,Email__c = 'test@test.com',FirstName__c = 'Mallikarjuna',LastName__c = 'Reddy', Body = 'Some chat.  Blah Blah');
        insert trans;
        trans.Status = 'Completed';
        update trans;
    }
    
    static testMethod void doTestContact() {
        
        Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE', AccountCountry__c = 'BR');
        insert acct;
        
        Contact Con = new Contact(Firstname='Mallikarjuna', Lastname='Reddy',Phone='(619)852-4569', Department='Mission Control', Title='Mission Specialist - Neptune', Email='test@test.com');
        insert Con;
        
        //create a Live Chat Visitor
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        //update visitor;
        
        
        //create a Live Chat Transcript
        LiveChatTranscript trans = new LiveChatTranscript(LiveChatVisitorId = visitor.Id, Email__c = 'test@test.com',FirstName__c = 'Mallikarjuna',LastName__c = 'Reddy',Body = 'Some chat.  Blah Blah');
        insert trans;
        trans.Status = 'Completed';
        update trans;
        
    }
    
    
    static testMethod void doTestNoContactAndLead() {
        
        //create a Live Chat Visitor
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        //create a Live Chat Transcript
        LiveChatTranscript trans = new LiveChatTranscript(LiveChatVisitorId = visitor.Id, Email__c = 'test@test.com',FirstName__c = 'Mallikarjuna',LastName__c = 'Reddy',Body = 'Some chat.  Blah Blah');
        insert trans;
        trans.Status = 'Completed';
        update trans;
    }
    
    @isTest
    static void testLiveChatAutomatedProcess(){
        User autoUser = [select Id,Name from user where Name ='Automated Process' Limit 1];
        LiveChatDeployment ldep = [select Id,DeveloperName from LiveChatDeployment where DeveloperName ='MRKT_CA_LIVE_CHAT_DEP' Limit 1 ];
        
        Test.startTest();
            System.runAs(autoUser){
                try{
                    Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE', AccountCountry__c = 'BR');
                    insert acct;
                    
                    /* Added End */
                    Contact Con = new Contact(Firstname='Mallikarjuna', Lastname='Reddy',Phone='(619)852-4569', Department='Mission Control', Title='Mission Specialist - Neptune', Email='test@test.com',PreferredLanguage__c = 'en_US');
                    insert Con;
                    
                    //create a Live Chat Visitor
                    LiveChatVisitor visitor = new LiveChatVisitor();
                    insert visitor;
                    //update visitor;
                    
                    //create a Live Chat Transcript
                    Id RecordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
                    Case newCaseForAFU = new Case(
                        Origin = 'Chat',                
                        Subject = 'Test Subject Auto' + 1,
                        Description = 'Test Desc Auto' + 1,
                        Status = 'New',
                        RecordTypeId = RecordTypeIdTechno,
                        OwnerId = UserInfo.getUserId()
                    );
                    insert newCaseForAFU;
                    LiveChatTranscript trans = new LiveChatTranscript(CaseId = newCaseForAFU.Id, Status = CON_CSM.S_COMPLETED, LiveChatDeploymentId = ldep.Id, LiveChatVisitorId = visitor.Id, Email__c = 'test@test.com',FirstName__c = 'Mallikarjuna',LastName__c = 'Reddy',Body = 'Some chat.  Blah Blah');
                    insert trans;
                    
                    
                    
                }
                catch(Exception ex){
                    
                }
            }
        Test.stopTest();
    }
}