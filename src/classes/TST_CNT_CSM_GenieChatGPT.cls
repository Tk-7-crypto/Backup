@isTest
private class TST_CNT_CSM_GenieChatGPT {
    
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        acc.Website='http://www.iqvia.com';
        insert acc;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestGenieChatGPTContact');
        insert cnt;
        Account account = UTL_TestData.createAccount();
        account.Website='http://www.iqvia.com';
        insert account;
        Contact contact = UTL_TestData.createContact(account.Id);
        insert contact;
        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Case c = New Case(Subject = 'TestGenieChatGPTCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,Current_Queue__c = 'Q1');
        insert c;
        CSM_ExternalClient_info__c ec = new CSM_ExternalClient_info__c(Name = 'AskGenie', Client_Url__c = 'http://test-internal-global-ticketgenie.iqvia.com/ticketgenie',Account_Id__c='PUT');
        insert ec;
        CSM_Ticket_Genie__c tg = new CSM_Ticket_Genie__c(Case__c = c.Id, IsAdvanced__c = false, IsNativeLanguage__c = false,SuggestedResolution__c = '{Summary: \'this is Summary\', Resolution: [Check if the Insight Module is active for the user\'s profile.,Provide documentation about the Insight Module and its configuration.,Check if the user has the necessary permissions to view Insights.], References: [https://docs.ims.io/OCE_Personal/WebUSG/Content/OCE/Welcome%20to%20OCE%20Sales.htm,https://docs.ims.io/OCE_Personal/MobileUSG/Content/_OCE/_Welcome/Welcome.htm]}'); 
        insert tg;
    }
    
    private class CNT_CSM_GenieChatGPTMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"Summary":"This is a test summary","Resolution":["Check if the Insight Module is active for the user\'s profile. ","Provide documentation about the Insight Module and its configuration.","Check if the user has the necessary permissions to view Insights.","Verify if there are any filters applied that may be hiding the Insights.","If the issue persists, troubleshoot further by checking the user\'s access to the related objects and fields.","If the issue still persists, escalate to the relevant team for further investigation."],"References":["https://docs.ims.io/OCE_Personal/WebUSG/Content/OCE/Welcome%20to%20OCE%20Sales.htm","https://docs.ims.io/OCE_Personal/MobileUSG/Content/_OCE/_Welcome/Welcome.htm","https://docs.ims.io/OCE_Personal/iPhoneUSG/Content/_iPhone/0_Welcome/11_Welcome_R18.htm"]}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    static void testGetGenieResolution(){
        Case cs = Database.query('Select Id,CaseNumber,RecordTypeName__c,ProductName__c,Account_Name_Article__c from Case LIMIT 1');
        Test.setMock(HttpCalloutMock.class, new CNT_CSM_GenieChatGPTMock());
        Test.startTest();
        CNT_CSM_GenieChatGPT.getGenieResolution(cs, false, false);
        Test.StopTest();
        Id cId = cs.Id;
        CSM_Ticket_Genie__c ticketGenie = Database.query('Select Id,Case__c,SuggestedResolution__c,FeedBackScore__c,Comments__c from CSM_Ticket_Genie__c where Case__c = : cId LIMIT 1');
        CNT_CSM_GenieChatGPT.saveFeedBackdata(ticketGenie);
        CNT_CSM_GenieChatGPT.getTicketGeniedata(cs.Id);
    }

}