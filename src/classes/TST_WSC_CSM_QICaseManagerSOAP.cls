@isTest
private class TST_WSC_CSM_QICaseManagerSOAP {
    
    testmethod static void WSC_CSM_QICaseManagerSOAPCaseManager() {
        Product2 product = new Product2(Name = 'AggregateSpend360', ProductCode = 'AggregateSpend360', isActive = true);
        insert product;
        Account account = new Account(
            Name = 'TestAcc',
            Accountcountry__c='IN',
            RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Contact con = new Contact( 
            AccountId = account.Id,
            Firstname='Mallikarjua', 
            Lastname='Reddy', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='malli@trailhead.com');
        insert con;
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
        Asset asset = new Asset(Name = 'AggregateSpend360', AccountId = account.Id, Product2Id = product.id);
        insert asset;
        CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Incident-Modules', SubType2__c='Missing Data',SubType3__c='--none--', Pillar__c = 'Technology Solutions');
        insert categorization;
        WSC_CSM_QICaseManagerSOAP.attachment_element att = new WSC_CSM_QICaseManagerSOAP.attachment_element();
        att.filename ='TestTech.txt'; 
        att.data = String.valueOf(EncodingUtil.urlEncode('Unit Test Tech Attachment Body','UTF-8'));
        WSC_CSM_QICaseManagerSOAP.attachments_element atts = new WSC_CSM_QICaseManagerSOAP.attachments_element();
        atts.attachment = new List<WSC_CSM_QICaseManagerSOAP.attachment_element>{att};
        String caseNumber = WSC_CSM_QICaseManagerSOAP.createCase(con.Email, 'Subject Test WS from Test Case', 'description test ws WS from Test Case', 'AggregateSpend360','Incident-Modules','Missing Data', 'Priority 1','Q1','Internal');
        WSC_CSM_QICaseManagerSOAP.MessageResponse mr = WSC_CSM_QICaseManagerSOAP.createCasewithAccountId(con.Email, 'Subject Test WS from Test Case', 'description test ws WS from Test Case', 'AggregateSpend360','Incident-Modules','Missing Data', 'High','Q1','Internal',account.Id,Con.Id);
        WSC_CSM_QICaseManagerSOAP.MessageResponse updaRes = WSC_CSM_QICaseManagerSOAP.updateCase(caseNumber, 'AggregateSpend360','Incident-Modules','Missing Data', 'Abandoned','Closed Automatically');
        WSC_CSM_QICaseManagerSOAP.CaseInfo caseInfo= WSC_CSM_QICaseManagerSOAP.getCaseById(caseNumber);
        WSC_CSM_QICaseManagerSOAP.getCaseListByQueueName('Q1');
        WSC_CSM_QICaseManagerSOAP.CaseInfo caseUpdate= WSC_CSM_QICaseManagerSOAP.closeCase(caseNumber, 'Test Resolution',account.Id);
        Test.startTest();
        WSC_CSM_QICaseManagerSOAP.MessageResponse updaResSmart = WSC_CSM_QICaseManagerSOAP.updateCaseSmartIT(caseNumber,null,null, 'AggregateSpend360','Incident-Modules','Missing Data', '--none--', 'Abandoned',null,'Closed Automatically','Closed Automatically','Other','Other Service',null);
        WSC_CSM_QICaseManagerSOAP.createCaseSmartIT(con.Email, null,null,'malli@trailhead.com','Yes','Subject Test WS from Test Case', 'description test ws WS from Test Case','New',null, 'AggregateSpend360','Incident-Modules','Missing Data', '--none--','Priority 1','Q1','Internal','Closed Automatically','Closed Automatically','Other','Other Service',null,atts);
        WSC_CSM_QICaseManagerSOAP.createCaseComment(caseNumber,'Test External Case Comment',true);
        Test.stopTest();
    }
}
