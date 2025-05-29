@isTest
public class TST_UTL_CSM_SendMail {
    @testSetup
    static void setup(){
        String profileName='System Administrator';
        Id pId =  [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        Integer noOfUser = 10;
        List<User> userList = new List<User>();
        for(Integer index = 0; index < noOfUser; index++) {
            userList.add(new User(
                ProfileId = pId,
                LastName = 'lastName123'+index,
                Email = 'testuser'+index+'3133@iqvia.com',
                Username = 'tes12'+index+'3@imshealth.com',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alia33'+index,
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Q1_Target__c = 1.0,
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description',
                employeenumber= String.valueOf(System.currentTimeMillis()) + index
            ));
        }
        if(userList != null && !userList.isEmpty()) insert userList;
        Account acct = new Account(Name = 'testSetupTestSiteAccount1', RDSponsor__c = true, RDClinicalSite__c = true, RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact con = new Contact(FirstName = 'TestFirstName', Lastname = 'testSetupContact', Phone = '(619)852-4569', Department = 'Mission Control', 
            Title = 'Mission Specialist - Neptune', Email = 'testSetupcon@iqvia.com', AccountId = acct.Id, PreferredLanguage__c = 'en_US');
        insert con;
        
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
        queueUser1.Name = 'Q1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Type__c = 'User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        
        Product2 p2 = new Product2(Name = 'Nexxus MI',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        insert a2;
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c(
            Product__c= p2.Id,SubType1__c = 'Incident-Module', SubType2__c = 'Formularies',
            SubType3__c = '--none--', Active__c = true, Type__c = 'Categorization', Pillar__c = 'Technology Solutions');
            insert cc;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Case cs = new Case();
        cs.ContactId = con.Id;
        cs.AccountId = acct.Id;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = recordTypeIdTechno;
        cs.Priority = 'Priority 4';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Techno Test case';
        cs.Description = 'Test class to check case creation ';
        cs.Status = 'New';
        cs.CurrentQueue__c = queueUser1.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';
        cs.SubType3__c = '--none--';
		insert cs;
        
        cs.Watch_List_User__c = userList[0].Id+','+userList[1].Id;
        update cs;
        
        FeedItem item = new FeedItem();
        item.ParentId = cs.Id;
        item.Body = 'Test Post';
        insert item;
    }
	static testMethod void testsendMailToWatchListUser() {
        List<User> users =[SELECT Id,Name,Email FROM User WHERE User_License_Type__c = 'Salesforce' LIMIT 10];
        Test.startTest();
        Case c = [SELECT Id,ContactId,CaseNumber,LOS__c,Priority,RecordTypeName__c,Subject,ProductName__c,Origin,LastModifiedById FROM Case Limit 1];
        
        EmailTemplate et = [select id from EmailTemplate  where Name like 'CSM_Case_Update_Watchlist_Mail' limit 1];
        
        List<UTL_CSM_SendMail.MessageWrapper> messageList = new List<UTL_CSM_SendMail.MessageWrapper>();
        UTL_CSM_SendMail.MessageWrapper message = new UTL_CSM_SendMail.MessageWrapper();
        message.toEmails = new List<String>{users[0].Id};
        message.content = '<html><body><table border="0" cellpadding="5" width="550" cellspacing="5" height="400" >'+
							+'<tr valign="top" height="400" >'+
                            +'<td tEditID="c1r1" style=" background-color:#FFFFFF; color:#000000; bEditID:r3st1; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r1" locked="0" >'+
                            +'<![CDATA[<font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Case Number <a href="{!Case.Link}">{!Case.CaseNumber}&nbsp;</a> with {!Case.Priority} has been updated</font>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><font face="arial"><br></font></div><div style=""><font face="arial" style="">'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Update Type:</b>&nbsp;UpdateTitle</div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Old and New field value:</b><span style="font-size: 12pt;">&nbsp;</span><span style="font-size: 12pt;">Updatefield</span></div>'+
                            +'</font><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Update made by:</b><span style="font-size: 12pt;">&nbsp;</span>LastChange</div>'+
                            +'</font><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Case Title:</b>&nbsp;{!Case.Subject}</div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Product:&nbsp;</b>{!Case.ProductName__c}</div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Case origin:&nbsp;</b>{!Case.Origin}</div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Case Comment or Post:</b>&nbsp;NewComment</div></font>'+
                            +'<font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Please review the Case and take appropriate action.</b></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Click on the link to access the case: <a href="{!Case.Link}">Click Here</a></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><font color="#de350b">PLEASE DO NOT REPLY TO THIS AUTOMATED EMAIL</font></div></font></div>]]></td>'+
                            +'</tr></table></body></html>';
        message.subject = 'Test Mail';
        message.whatId = c.Id;
    	message.targetObjectId = c.ContactId;
        message.isTargetObjectAsRecipient = false;
        message.whatId= c.Id;
        message.changes = 'Test Mail';
        message.changeValue = '';
        message.caseNumber = c.CaseNumber;
        message.priority = c.Priority;
        message.lastModify = c.LastModifiedById;
        message.title = c.Subject;
        if(c.ProductName__c !=null)
        	message.product = c.ProductName__c;
        else
        	message.product = '';
        message.origin = c.Origin;
        message.templateId = et.Id;
        messageList.add(message);
        
        message = new UTL_CSM_SendMail.MessageWrapper();
        message.targetObjectId = c.Id;
        message.isTargetObjectAsRecipient = false;
        
        messageList.add(message);

        UTL_CSM_SendMail.sendMailToWatchListUser(messageList);
        List<Workflow_Email_Record__c> records = [Select Id from Workflow_Email_Record__c];
        Test.stopTest();
    }
    
    static testMethod void testsetWorkflowParameter(){
        Test.startTest();
        Case c = [SELECT Id,ContactId,CaseNumber,LOS__c,Priority,RecordTypeName__c,Subject,ProductName__c,Origin,LastModifiedById FROM Case Limit 1];
		List<User> userlist = [SELECT Id,EMail FROM User WHERE User_License_Type__c = 'Salesforce' LIMIT 2];   
        Test.stopTest();
        UTL_CSM_SendMail.MessageWrapper message = new UTL_CSM_SendMail.MessageWrapper();
        Workflow_Email_Record__c record = new Workflow_Email_Record__c();
        message.toEmails = new List<String>{userlist[0].Id};
        message.content = '<html><body><table border="0" cellpadding="5" width="550" cellspacing="5" height="400" >'+
							+'<tr valign="top" height="400" >'+
                            +'<td tEditID="c1r1" style=" background-color:#FFFFFF; color:#000000; bEditID:r3st1; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r1" locked="0" >'+
                            +'<![CDATA[<font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Case Number <a href="{!Case.Link}">{!Case.CaseNumber}&nbsp;</a> with {!Case.Priority} has been updated</font>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><font face="arial"><br></font></div><div style=""><font face="arial" style="">'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Update Type:</b>&nbsp;UpdateTitle</div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Old and New field value:</b><span style="font-size: 12pt;">&nbsp;</span><span style="font-size: 12pt;">Updatefield</span></div>'+
                            +'</font><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Update made by:</b><span style="font-size: 12pt;">&nbsp;</span>LastChange</div>'+
                            +'</font><font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Case Title:</b>&nbsp;{!Case.Subject}</div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Product:&nbsp;</b>{!Case.ProductName__c}</div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style=""><b style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Case origin:&nbsp;</b>{!Case.Origin}</div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Case Comment or Post:</b>&nbsp;NewComment</div></font>'+
                            +'<font face="arial" style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Please review the Case and take appropriate action.</b></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Click on the link to access the case: <a href="{!Case.Link}">Click Here</a></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div>'+
                            +'<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><font color="#de350b">PLEASE DO NOT REPLY TO THIS AUTOMATED EMAIL</font></div></font></div>]]></td>'+
                            +'</tr></table></body></html>';
        message.subject = 'Test Mail';
        message.whatId = c.Id;
    	message.targetObjectId = c.ContactId;
        message.isTargetObjectAsRecipient = false;
        message.whatId= c.Id;
        message.changes = 'Test Mail';
        message.changeValue = '';
        message.caseNumber = c.CaseNumber;
        message.priority = c.Priority;
        message.lastModify = c.LastModifiedById;
        message.title = c.Subject;
        if(c.ProductName__c !=null)
        	message.product = c.ProductName__c;
        else
        	message.product = '';
        message.origin = c.Origin;
        message.whatId = c.Id;
        
		UTL_CSM_SendMail.setWorkflowParameter(record, message);
        
        System.assertEquals(record.To_Email_1__c, null);
        System.assertEquals(record.Related_To_Object_Id__c, c.Id);
        System.assertEquals(record.Related_To_Object_Api__c, 'Case');
        System.assertEquals(record.Module_Name__c, 'CSM');
        System.assertEquals(record.Email_Action__c, 'CSM_01_SendEmail');
     }
    
    static testMethod void testIsValidEmailId(){
        System.assertEquals(UTL_CSM_SendMail.isValidEmailId('xyz@abc.com'), true);
        System.assertEquals(UTL_CSM_SendMail.isValidEmailId('xy___33z@abc.com'), true); 
        System.assertEquals(UTL_CSM_SendMail.isValidEmailId('@abc.com'), false); 
        System.assertEquals(UTL_CSM_SendMail.isValidEmailId('abc.com'), false); 
    }
    
    static testMethod void testUpdateEmailMessageMail(){
        Test.startTest();
        List<Case> c = [SELECT Id,ContactId,CaseNumber,LOS__c,Priority,RecordTypeName__c,Subject,ProductName__c,Origin,LastModifiedById,Watch_List_User__c FROM Case Limit 1];
        Test.stopTest();
        UTL_CSM_SendMail.updateEmailMessageMail('Email',c,null);
    }
    static testMethod void testUpdateTaskMail(){
        Test.startTest();
        List<Case> c = [SELECT Id,ContactId,CaseNumber,LOS__c,Priority,RecordTypeName__c,Subject,ProductName__c,Origin,LastModifiedById,Watch_List_User__c FROM Case Limit 1];
        Set<Id> ids = new Set<Id>();
        ids.add(c[0].Id);
        Test.stopTest();
        UTL_CSM_SendMail.updateTaskMail('Call', ids);
    }
    
    static testMethod void testUpdatePostMail(){
        Test.startTest();
        List<Case> cs = [SELECT Id,CaseNumber FROM Case Limit 1];
		List<FeedItem> feeds =[SELECT Id,ParentId,Body,CreatedById from FeedItem LIMIT 1];
        List<Id> caseIds = new List<Id>();
        caseIds.add(cs[0].Id);
        Test.stopTest();
        UTL_CSM_SendMail.updatePostMail(feeds, caseIds);
        
        System.assertEquals(caseIds[0], feeds[0].ParentId,'Success'); 
    }
    static testMethod void testUpdateCaseCommentMail(){
        Test.startTest();
        Case cs = [SELECT Id,CaseNumber FROM Case Limit 1];
        Map<Id,String> posts = new Map<Id,String>();
        posts.put(cs.Id,'Test Case Comment');
        UTL_CSM_SendMail.updateCaseCommentMail(posts);
        Test.stopTest();
    }
}