@isTest
private class TST_DAO_LiveChatTranscript {
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
        
        Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        /* Added End */
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
}