@isTest
private class TST_CNT_CSM_SNOWChatGPT {
    
    @testSetup
    static void dataSetup() {
        Group g = new Group(Name='IQVIAGenAI');
        insert g;
        System.runAs(new User(Id = UserInfo.getUserId())){
         
        GroupMember gm = new  GroupMember(GroupId = g.Id,UserOrGroupId = UserInfo.getUserId());
        insert gm;
        }
        Account acc = CSM_Util.createAccount();
        insert acc;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestSNOWContact');
        insert cnt;
        Knowledge__kav k = new Knowledge__kav();
        k.Title = 'Title:Draft Close Resolution';
        k.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Information').getRecordTypeId();
        k.UrlName ='Draft-Case-Resolution';
        k.Content__c ='Question Answer Draft Close Resolution Add Draft Close Resolution Run Draft Close Resolution validate Draft Close Resolution';
        k.Pillar__c ='Information Offering';
        k.ReviewDate__c = System.today();
        insert k;
        Knowledge__kav kr  = [select KnowledgeArticleId from Knowledge__kav];
        String articleId = kr.KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);
        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
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
        Case c = New Case(Subject = 'TestSNOWChatGPTCase', Description = 'SNOWChatGPT What is IQVIA? IMPORTANT - PLEASE READ: this is related to IQVA rules',RecordTypeId=recordType, ContactId = cnt.Id, AccountId = acc.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,Current_Queue__c = 'Q1',Device__c='laptop',Resolution__c ='Resolution added for case',Technical_Resolution_Internal_Use_only__c='Technical Resolution Internal Use only added');
        insert c;
        FeedItem fi = new FeedItem(ParentId = c.Id, Body ='Test Contat',Type = 'TextPost' , Visibility ='AllUsers');
        insert fi;
        List<CaseComment> newComment = new List<CaseComment>();
        newComment.add(new CaseComment(ParentId = c.Id,CommentBody = 'Test Comment Case',IsPublished = false)); 
        newComment.add(new CaseComment(ParentId = c.Id,CommentBody = 'Test Comment Case CommentBoby',IsPublished = true)); 
        insert newComment;
        CSM_ExternalClient_info__c ecc = new CSM_ExternalClient_info__c(Name = 'InternalSnowGenAI', Client_Url__c = 'http://test.com', UserName__c = 'User', Password__c='Pwd');
        insert ecc;
        CSM_Case_Details_Global_Setting__c gd1 = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIACopilot Case Summary',Component_Id__c = 'Case Summary',Setting_Type__c = 'Case Summary',Other_Details__c = 'Case Summary');
        CSM_Case_Details_Global_Setting__c gd2 = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIACopilot Case Close Note',Component_Id__c = 'Case Close Note',Setting_Type__c = 'Case Close Note',Other_Details__c = 'Case Close Note');
        CSM_Case_Details_Global_Setting__c gd3 = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIACopilot Case Activity Audit',Component_Id__c = 'Case Activity Audit',Setting_Type__c = 'Case Activity Audit',Other_Details__c = 'Case Activity Audit');
        CSM_Case_Details_Global_Setting__c gd4 = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIACopilotEmailGenerator',Component_Id__c = 'Draft Email',Setting_Type__c = 'Draft Email',Other_Details__c = 'Draft Email',Origin__c = g.Id);
        CSM_Case_Details_Global_Setting__c gd5 = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIACopilotDraftKBInfo',Component_Id__c = 'Draft Article Information',Setting_Type__c = 'Draft Article Information',Other_Details__c = 'Draft Article Information',Origin__c = g.Id);
        CSM_Case_Details_Global_Setting__c gd6 = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIACopilotDraftKBQuestion',Component_Id__c = 'Draft Article Question-Answer',Setting_Type__c = 'Draft Article Question-Answer',Other_Details__c = 'Draft Article Question-Answer',Origin__c = g.Id);
        CSM_Case_Details_Global_Setting__c gd7 = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIACopilotCaseResolution',Component_Id__c = 'Draft Close Resolution',Setting_Type__c = 'Draft Close Resolution',Other_Details__c = 'Draft Close Resolution',Origin__c = g.Id);
        
        List<CSM_Case_Details_Global_Setting__c> listSet = new List<CSM_Case_Details_Global_Setting__c>{gd1,gd2,gd3,gd4,gd5,gd6,gd7};
        insert listSet;
        CNT_CSM_SNOWChatGPT.getSummaryDetails(c.Id);
        CNT_CSM_SNOWChatGPT.getCopilotCustomSettings(null);
        Activity__c act1 = new Activity__c(ActivityOwner__c=UserInfo.getUserId(), Type__c = 'Call - Inbound', Case__c=c.Id,Status__c='Done' );
        insert act1;
    }
    
    @isTest
    private static void testCallSNOWGenAIPost(){
        Case c =[Select Id from Case Limit 1];
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"result":{"sys_id":"13242435","u_content":"Case Summary","u_order":"3","u_role":"Assistant"}}'));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.callSNOWGenAIChatGPT('What is IQVIA?', null);
        Test.stopTest();
    }
    
    @isTest
    private static void testAskCallSNOWGenAIPost(){
        Case c =[Select Id from Case Limit 1];
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"result":{"sys_id":"13242435","u_content":"Case Summary","u_order":"3","u_role":"Assistant"}}'));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.askCaseAssistance(c.Id, 'Case Summary','English','en_US',null);
        Test.stopTest();
    }
    
    @isTest
    private static void testDraftSNOWGenAIPost(){
        Case c =[Select Id from Case Limit 1];
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"result":{"sys_id":"13242435","u_content":"Draft Email","u_order":"3","u_role":"Assistant"}}'));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.askCaseAssistance(c.Id,'Draft Email','English','en_US',null);
        Test.stopTest();
    }
    
    @isTest
    private static void testDraftQuestionSNOWGenAIPost(){
        Case c =[Select Id from Case Limit 1];
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"result":{"sys_id":"13242435","u_content":"Draft Article Question-Answer","u_order":"3","u_role":"Assistant"}}'));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.askCaseAssistance(c.Id,'Draft Article Question-Answer','English','en_US',null);
        Test.stopTest();
    }
    
    @isTest
    private static void testDraftInformationSNOWGenAIPost(){
        Case c =[Select Id from Case Limit 1];
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"result":{"sys_id":"13242435","u_content":"Draft Article Information","u_order":"3","u_role":"Assistant"}}'));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.askCaseAssistance(c.Id,'Draft Article Information','English','en_US',null);
        Test.stopTest();
    }
    
    @isTest
    private static void testDraftCaseResSNOWGenAIPost(){
        Case c =[Select Id from Case Limit 1];
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"result":{"sys_id":"13242435","u_content":"Draft Close Resolution","u_order":"3","u_role":"Assistant"}}'));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.askCaseAssistance(c.Id,'Draft Close Resolution','English','en_US',null);
        Test.stopTest();
    }

    @isTest
    private static void testCloseCallSNOWGenAIPost(){
        Case c =[Select Id from Case Limit 1];
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"result":{"sys_id":"13242435","u_content":"Case Close Note","u_order":"3","u_role":"Assistant"}}'));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.askCaseAssistance(c.Id,'Case Close Note','English','en_US',null);
        Test.stopTest();
    }
    
    @isTest
    private static void testCallSNOWGenAIGET(){
        Case c =[Select Id from Case Limit 1];
        WSC_CSM_SNOWGenAICallOut.GenAIGetResponse resp = new WSC_CSM_SNOWGenAICallOut.GenAIGetResponse();
        List<WSC_CSM_SNOWGenAICallOut.GenAIResult> result = new List<WSC_CSM_SNOWGenAICallOut.GenAIResult>();
        WSC_CSM_SNOWGenAICallOut.GenAIResult res = new WSC_CSM_SNOWGenAICallOut.GenAIResult();
        res.sys_id = '1143543';
        res.u_content = 'Case Summary';
        res.u_order = '3';
        res.u_role ='Assistant';
        result.add(res);
        resp.result = result;
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut(JSON.serialize(resp)));
        Test.startTest();
        CNT_CSM_SNOWChatGPT.callGetSNOWGenAIChatGPT('1143543');
        IQVIACopilot_ChatGPT__c gptEmail = new IQVIACopilot_ChatGPT__c(Content__c ='Draft Email', Order__c =3,Case__c=c.Id, Role__c='Assistant',sys_Id__c='1144543',Type__c='Draft Email');
        insert gptEmail;
        EmailMessage em2 = new EmailMessage(FromAddress = 'replytocsm@iqvia.com', ToAddress = 'caseContact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body',HtmlBody = '<html><head><title></title></head><body>Test dummy body</body></html>',Status='5',IsPrivateDraft=true, ParentId = c.Id, Incoming = false);
        insert em2;
        CNT_CSM_SNOWChatGPT.saveEmailasDraft(c.Id, gptEmail.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetCaseAssistance(){
        Case c =[Select Id from Case Limit 1];
        WSC_CSM_SNOWGenAICallOut.GenAIGetResponse resp = new WSC_CSM_SNOWGenAICallOut.GenAIGetResponse();
        List<WSC_CSM_SNOWGenAICallOut.GenAIResult> result = new List<WSC_CSM_SNOWGenAICallOut.GenAIResult>();
        WSC_CSM_SNOWGenAICallOut.GenAIResult res = new WSC_CSM_SNOWGenAICallOut.GenAIResult();
        res.sys_id = '1143543';
        res.u_content = 'Case Summary';
        res.u_order = '3';
        res.u_role ='Assistant';
        result.add(res);
        resp.result = result;
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut(JSON.serialize(resp)));
        Test.startTest();
        List<IQVIACopilot_ChatGPT__c> listG = CNT_CSM_SNOWChatGPT.getCaseAssistance(c.Id, '1143543','Case Summary');
        IQVIACopilot_ChatGPT__c gpt = new IQVIACopilot_ChatGPT__c(Content__c ='Case Summary', Order__c =3,Case__c=c.Id, Role__c='Assistant',sys_Id__c='1143543',Type__c='Case Summary');
        insert gpt;
        IQVIACopilot_ChatGPT__c gptEmail = new IQVIACopilot_ChatGPT__c(Content__c ='Draft Email', Order__c =3,Case__c=c.Id, Role__c='Assistant',sys_Id__c='1144543',Type__c='Draft Email');
        insert gptEmail;
        IQVIACopilot_ChatGPT__c gptKbI = new IQVIACopilot_ChatGPT__c(Content__c ='Title:Draft Article Information <p>::BEG_RES::</p> Resolution: Step 1 step 2', Order__c =3,Case__c=c.Id, Role__c='Assistant',sys_Id__c='1144543',Type__c='Draft Article Information');
        insert gptKbI;
        IQVIACopilot_ChatGPT__c gptKbQ = new IQVIACopilot_ChatGPT__c(Content__c ='Title:Draft Article Question-Answer <p>::BEG_QUST::</p> Question: What is the issue? <p>::BEG_ANS::</p> Answer:This is the answer', Order__c =3,Case__c=c.Id, Role__c='Assistant',sys_Id__c='1144543',Type__c='Draft Article Question-Answer');
        insert gptKbQ;
        EmailMessage em1 = new EmailMessage(FromAddress = 'replytocsm@iqvia.com', ToAddress = 'caseContact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body',HtmlBody = '<html><head><title></title></head><body>Test dummy body</body></html>', ParentId = c.Id, Incoming = True);
        insert em1;
        CNT_CSM_SNOWChatGPT.saveEmailasDraft(c.Id, gptEmail.Id);
        CNT_CSM_SNOWChatGPT.saveKBDraft(c.Id, gptKbI.Id,'en_US');
        CNT_CSM_SNOWChatGPT.saveKBDraft(c.Id, gptKbQ.Id,'en_US');
        CNT_CSM_SNOWChatGPT.saveCaseResolution(c.Id, gptKbQ.Id);
        Test.stopTest();
    }

}