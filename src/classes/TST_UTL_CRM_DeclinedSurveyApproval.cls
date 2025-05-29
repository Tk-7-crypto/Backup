@istest
public class TST_UTL_CRM_DeclinedSurveyApproval {
    @TestSetup
    public static void setup(){
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        insert testUser1;
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        
        List<Contact> contactList = new List<Contact>();
        Contact testContact = UTL_TestData.createContact(newAccount.id);
        testContact.pse__Salesforce_User__c = testUser1.Id;
        contactList.add(testContact); 
        Contact testContact1 = UTL_TestData.createContact(newAccount.id);
        testContact1.FirstName = 'TestDeclined';
        testContact1.LastName = 'SurveyApprover';
        testContact1.Email = 'test.declined@approver.com';
        testContact1.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        contactList.add(testContact1); 
        insert contactList;
        List<Opportunity> opportunityRecordList = new List<Opportunity>();
        Opportunity opportunityRecord = UTL_TestData.createOpportunity(newAccount.id);
        opportunityRecord.StageName = 'In-Hand';
        opportunityRecord.Survey_Recipient__c = testContact1.Id;
        opportunityRecord.CloseDate = Date.today();
        opportunityRecord.Upcoming_Survey_Send_Date__c = Date.today();
        opportunityRecord.Next_Survey_Send_Date__c = Date.today();
        opportunityRecord.US_government_fully_or_partially_funded__c = 'No';
        opportunityRecord.Proposal_Due_Date__c = System.today() + 1; 
        opportunityRecord.Is_there_a_regulatory_purpose__c = 'No';
        opportunityRecordList.add(opportunityRecord);
        
        Opportunity opportunityRecord2 = UTL_TestData.createOpportunity(newAccount.id);
        opportunityRecord2.StageName = 'In-Hand';
        opportunityRecord2.CloseDate = Date.today();
        opportunityRecord2.Upcoming_Survey_Send_Date__c = Date.today();
        opportunityRecord2.Next_Survey_Send_Date__c = Date.today();
        opportunityRecord2.Survey_Recipient__c = testContact1.Id;
        opportunityRecord2.US_government_fully_or_partially_funded__c = 'No';
        opportunityRecord2.Proposal_Due_Date__c = System.today() + 1; 
        opportunityRecord2.Is_there_a_regulatory_purpose__c = 'No';
        opportunityRecordList.add(opportunityRecord2);
        
        Opportunity opportunityRecord3 = new Opportunity(Name = 'Test Opportunity', Path_Probability__c = 'Verbal',  Line_of_Business__c = 'Clinical', Is_this_IQVIA_Biotech__c = 'No', StageName = 'In-Hand', CloseDate = Date.today(), AccountId = newAccount.id, Previous_survey_sent_date__c = Date.today().addMonths(-6), Research_Study_Classification__c = 'Not a research study', Contract_End_Date__c = Date.today().addMonths(19),
            Survey_Recipient__c = testContact1.Id, US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today(),CurrencyIsoCode = 'USD');
        opportunityRecordList.add(opportunityRecord3);
        
        insert opportunityRecordList;
        
        Product2 product = new Product2(Name = 'Product X',ProductCode = 'Pro-X',isActive = true, Offering_Type__c ='Commercial Tech',Material_Type__c='ZREP',Offering_Segment__c='Commercial Solutions');
        product.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert product;
        Product2 product1 = new Product2(Name = 'Test Product', Global_Product_Code__c = '123',Material_Type__c = 'ZREP');
        insert product1;
        PricebookEntry priceBookEntry = UTL_TestData.createPricebookEntry(product.Id);
        priceBookEntry.UnitPrice = 20000;
        insert priceBookEntry;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry priceBookEntry1 = new PricebookEntry(Product2Id = product1.Id, UnitPrice = 54,
            IsActive = true, Pricebook2Id = pricebookId,CurrencyIsoCode = 'USD');
        insert priceBookEntry1;
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem opportunityProduct = UTL_TestData.createOpportunityLineItem(opportunityRecord.id, priceBookEntry.id);
        opportunityProduct.TotalPrice = 20000;
        oliList.add(opportunityProduct);
        OpportunityLineItem opportunityProduct2 = UTL_TestData.createOpportunityLineItem(opportunityRecord2.id, priceBookEntry.id);
        opportunityProduct2.TotalPrice = 20000;
        oliList.add(opportunityProduct2);
        OpportunityLineItem opportunityProduct3 = new OpportunityLineItem(OpportunityId = opportunityRecord3.Id, Sale_Type__c = 'New',Delivery_Country__c = 'USA',
            Revenue_Type__c = 'Subscription', UnitPrice = 40000, Quantity = 1, priceBookEntryId = priceBookEntry.Id, Therapy_area__c = 'Oncology');
        oliList.add(opportunityProduct3);
        insert oliList;
        
        List<Client_Sat_Survey__c> csatList = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c clientSatSurvey = UTL_TestData.createClientSatSurveyRecord('testsurvey', 'No', testContact.Id, opportunityRecord.Id);
        clientSatSurvey.Don_t_Send_Survey_Reason__c = CON_Qualtrics.DECLINED;
        clientSatSurvey.Decline_Survey_Reason__c = 'This revenue is too low';
        clientSatSurvey.Survey_Send_Date__c = System.today();
        clientSatSurvey.Declined_SurveyApprover_1__c = testContact1.id;
        clientSatSurvey.OwnerId = testUser1.id;
        csatList.add(clientSatSurvey);
        
        Client_Sat_Survey__c clientSatSurvey2 = UTL_TestData.createClientSatSurveyRecord('testsurvey', 'No', testContact.Id, opportunityRecord2.Id);
        clientSatSurvey2.Don_t_Send_Survey_Reason__c = CON_Qualtrics.DELAYED;
        clientSatSurvey2.Delay_Survey_Reason__c = 'Project on hold';
        clientSatSurvey2.Survey_Send_Date__c = System.today();
        clientSatSurvey2.Declined_SurveyApprover_1__c = testContact1.id;
        clientSatSurvey2.OwnerId = testUser1.id;
        csatList.add(clientSatSurvey2);
        
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opportunityRecord3.id);
        proxyProject.Record_Type_Name__c = 'Engagement';
        proxyProject.Delivery_PIC_Name__c = 'Test Shikha';
        insert proxyProject;
        Client_Sat_Survey__c clientSatSurvey3 = UTL_TestData.createClientSatSurveyRecord('testSurvey', 'No', String.valueOf(testContact1.id), String.valueOf(opportunityRecord3.id));
        clientSatSurvey3.Don_t_Send_Survey_Reason__c = CON_Qualtrics.DECLINED;
        clientSatSurvey3.Decline_Survey_Reason__c = 'Client refuses to do surveys';
        clientSatSurvey3.Survey_Send_Date__c = System.today();        
        clientSatSurvey3.Declined_SurveyApprover_1__c = testContact1.id;
        clientSatSurvey3.OwnerId = testUser1.id;
        csatList.add(clientSatSurvey3);
        insert csatList;
 
    }
    
    @istest
    public static void testSendDeclineMail(){
        Client_Sat_Survey__c clientSatSurvey = [Select id, Send_Survey__c, Opportunity__c, Declined_SurveyApprover_1__c from Client_Sat_Survey__c where Don_t_Send_Survey_Reason__c =: CON_Qualtrics.DECLINED AND Decline_Survey_Reason__c =: 'This revenue is too low' limit 1];
        Contact declinedSurveyApprover = [Select id, Email, Name from Contact where FirstName = 'TestDeclined'];
                
        EmailTemplate et = [Select id, name, Body, HtmlValue from EmailTemplate where name = 'CS Process Denial Approval Notification'];
        Messaging.SingleEmailMessage newMail  = Messaging.renderStoredEmailTemplate(et.Id, clientSatSurvey.Declined_SurveyApprover_1__c, clientSatSurvey.id);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{newMail});
        
        String reply = '<div dir="ltr">Accept</div><br><div class="gmail_attr"></div><blockquote class="gmail_quote">';
        String newHtmlBody = newMail.getHtmlBody().replace('<html>','<div>').replace('</html>','</div>');
       
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.htmlBody = reply + newHtmlBody + '</blockquote></div>';
        email.plainTextBody = email.htmlBody.StriphtmlTags();
        email.fromAddress = declinedSurveyApprover.Email;
        email.fromName = declinedSurveyApprover.name;
        email.subject = newMail.getSubject();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = declinedSurveyApprover.Email;
      
        Test.startTest();
            UTL_CRM_DeclinedSurveyApproval obj= new UTL_CRM_DeclinedSurveyApproval();
            obj.handleInboundEmail(email, env );
        Test.stopTest();
    }
    
    @istest
    public static void testSendDeclineMailZREP(){
        Client_Sat_Survey__c clientSatSurvey = [Select id, Send_Survey__c, Opportunity__c, Declined_SurveyApprover_1__c from Client_Sat_Survey__c where Don_t_Send_Survey_Reason__c =: CON_Qualtrics.DECLINED AND Decline_Survey_Reason__c =: 'Client refuses to do surveys' limit 1];
        Contact declinedSurveyApprover = [Select id, Email, Name from Contact where FirstName = 'TestDeclined'];
                
        EmailTemplate et = [Select id, name, Body, HtmlValue from EmailTemplate where name = 'CS Process Denial Approval Notification'];
        Messaging.SingleEmailMessage newMail  = Messaging.renderStoredEmailTemplate(et.Id, clientSatSurvey.Declined_SurveyApprover_1__c, clientSatSurvey.id);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{newMail});
        
        String reply = '<div dir="ltr">Accept</div><br><div class="gmail_attr"></div><blockquote class="gmail_quote">';
        String newHtmlBody = newMail.getHtmlBody().replace('<html>','<div>').replace('</html>','</div>');
       
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.htmlBody = reply + newHtmlBody + '</blockquote></div>';
        email.plainTextBody = email.htmlBody.StriphtmlTags();
        email.fromAddress = declinedSurveyApprover.Email;
        email.fromName = declinedSurveyApprover.name;
        email.subject = newMail.getSubject();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = declinedSurveyApprover.Email;
      
        Test.startTest();
            UTL_CRM_DeclinedSurveyApproval obj= new UTL_CRM_DeclinedSurveyApproval();
            obj.handleInboundEmail(email, env );
        Test.stopTest();
    }
    
    @istest
    public static void testSendDeclineMailReject(){
        Client_Sat_Survey__c clientSatSurvey = [Select id, Send_Survey__c, Opportunity__c, Declined_SurveyApprover_1__c from Client_Sat_Survey__c where Don_t_Send_Survey_Reason__c =: CON_Qualtrics.DECLINED limit 1];
        Contact declinedSurveyApprover = [Select id, Email, Name from Contact where FirstName = 'TestDeclined'];
                
        EmailTemplate et = [Select id, name, Body, HtmlValue from EmailTemplate where name = 'CS Process Denial Approval Notification'];
        Messaging.SingleEmailMessage newMail  = Messaging.renderStoredEmailTemplate(et.Id, clientSatSurvey.Declined_SurveyApprover_1__c, clientSatSurvey.id);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{newMail});
        
        String reply = '<div dir="ltr">No</div><br><div class="gmail_attr"></div><blockquote class="gmail_quote">';
        String newHtmlBody = newMail.getHtmlBody().replace('<html>','<div>').replace('</html>','</div>');
       
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.htmlBody = reply + newHtmlBody + '</blockquote></div>';
        email.plainTextBody = email.htmlBody.StriphtmlTags();
        email.fromAddress = declinedSurveyApprover.Email;
        email.fromName = declinedSurveyApprover.name;
        email.subject = newMail.getSubject();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = declinedSurveyApprover.Email;
      
        Test.startTest();
            UTL_CRM_DeclinedSurveyApproval obj= new UTL_CRM_DeclinedSurveyApproval();
            obj.handleInboundEmail(email, env );
        Test.stopTest();
    }
    
    @istest
    public static void testSendDelayMail(){
        Client_Sat_Survey__c clientSatSurvey = [Select id, Send_Survey__c, Opportunity__c, Declined_SurveyApprover_1__c from Client_Sat_Survey__c where Don_t_Send_Survey_Reason__c =: CON_Qualtrics.DELAYED limit 1];
        
        Contact declinedSurveyApprover = [Select id, Email, Name from Contact where FirstName = 'TestDeclined'];
                
        EmailTemplate et = [Select id, name, Body, HtmlValue from EmailTemplate where name = 'CS Process Denial Approval Notification'];
        Messaging.SingleEmailMessage newMail  = Messaging.renderStoredEmailTemplate(et.Id, clientSatSurvey.Declined_SurveyApprover_1__c, clientSatSurvey.id);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{newMail});
        
        String reply = '<div dir="ltr">Accept</div><br><div class="gmail_attr"></div><blockquote class="gmail_quote">';
        String newHtmlBody = newMail.getHtmlBody().replace('<html>','<div>').replace('</html>','</div>');
       
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.htmlBody = reply + newHtmlBody + '</blockquote></div>';
        email.plainTextBody = email.htmlBody.StriphtmlTags();
        email.fromAddress = declinedSurveyApprover.Email;
        email.fromName = declinedSurveyApprover.name;
        email.subject = newMail.getSubject();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = declinedSurveyApprover.Email;
      
        Test.startTest();
            UTL_CRM_DeclinedSurveyApproval obj= new UTL_CRM_DeclinedSurveyApproval();
            obj.handleInboundEmail(email, env );
        Test.stopTest();
    }
    
    @IsTest
    public static void testReassignRequest() {
        User testUser = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser.Email = 'test.reassignuser@metacube.com';
        insert testUser;
        System.runAs(testUser){
            Group gp = new Group(Name = CON_Qualtrics.DECLINE_SURVEY_REASSIGN_GROUP_LABEL);
            insert gp;
            GroupMember gpm = new GroupMember();
            gpm.GroupId = gp.Id;
            gpm.UserOrGroupId = UserInfo.getUserId();
            Database.insert(gpm);
        }
        Client_Sat_Survey__c clientSatSurvey = [Select id, Need_Escalation__c, Send_Survey__c, Opportunity__c, Declined_SurveyApprover_1__c from Client_Sat_Survey__c where Send_Survey__c = 'No' limit 1][0];
        clientSatSurvey.Need_Escalation__c = true;
        update clientSatSurvey;
        EmailTemplate et = [Select id, name, Body, HtmlValue from EmailTemplate where name = 'CS Process Denial Approval Notification'];
        Messaging.SingleEmailMessage newMail  = Messaging.renderStoredEmailTemplate(et.Id, testUser.id, clientSatSurvey.id);
        newMail.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{newMail});
        
        String reply = '<div dir="ltr">Accept</div><br><div class="gmail_attr"></div><blockquote class="gmail_quote">';
        String newHtmlBody = newMail.getHtmlBody().replace('<html>','<div>').replace('</html>','</div>');
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.htmlBody = reply + newHtmlBody + '</blockquote></div>';
        email.plainTextBody = email.htmlBody.StriphtmlTags();
        email.fromAddress = testUser.Email;
        email.fromName = testUser.name;
        email.subject = newMail.getSubject();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = testUser.Email;
        
        Test.startTest();
        UTL_CRM_DeclinedSurveyApproval obj= new UTL_CRM_DeclinedSurveyApproval();
        obj.handleInboundEmail(email, env );
        Test.stopTest();
    }
    
}