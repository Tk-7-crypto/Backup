@isTest
private class TST_DAOH_Case {
  
    /**
    * This method is used to setup data for all methods.
    */  
    @testSetup
    static void dataSetup() {

        List<User> listOfUser = UTL_TestData.createUser('Service User', 2);
        listOfUser[0].IsActive = true;
        listOfUser.add(UTL_TestData.createUser('System Administrator', 1)[0]);
        Insert listOfUser;
        CSM_ExternalClient_info__c eci = new CSM_ExternalClient_info__c(Name='Mir3',Client_Url__c = 'http://www.mir3.com/ws', Password__c='pwd', UserName__c='User', client_secret__c ='15-15',Client_Certificate__c='CSM Digital Engagement');
        insert eci;
        List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testSetupTestSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE', AccountCountry__c = 'BR');
        acct.C_SAT_Survey_Option__c = 'TS Option B;TS Option C;TS Option D;DATA Option B;DATA Option C;DATA Option D;R&D Option B;R&D Option C;R&D Option D;TS Option E';
        accList.add(acct);
        
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acct1.C_SAT_Survey_Option__c = 'TS Option B;TS Option C;TS Option D;DATA Option B;DATA Option C;DATA Option D;R&D Option B;R&D Option C;R&D Option D;TS Option E';
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acct2.C_SAT_Survey_Option__c = 'TS Option B;TS Option C;TS Option D;DATA Option B;DATA Option C;DATA Option D;R&D Option B;R&D Option C;R&D Option D;TS Option E';
        accList.add(acct2);
        insert accList;
        Study__c study= new Study__c(Name = 'testSetupCaseTestStudy', Sponsor__c = acct2.Id,Protocol__c ='testSetupCaseTestStudy');
        insert study;
        /* Added End */
        CSM_Date_Format_By_Language__c fbl = new CSM_Date_Format_By_Language__c(Name ='testDateFormat', April__c ='Apr', August__c ='Aug', Date_Format__c = 'MMMM dd yyyy', December__c='Dec', February__c = 'Feb', January__c='Jan', July__c='Jul', June__c='Jun', Language_Code__c='en_US', March__c='Mar', May__c='May', November__c='Nov', October__c='Oct', September__c='Sep');
        insert fbl;
        Contact con = new Contact( FirstName = 'TestFirstName', Lastname='testSetupContact', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        insert con;
        
        // cc list test data start
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.C_SAT_Survey_Option__c = 'TS Option B;TS Option C;TS Option D;DATA Option B;DATA Option C;DATA Option D;R&D Option B;R&D Option C;R&D Option D;TS Option E';
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.AccountCountry__c = 'US';
        accCase.CustomerSegment__c = 'GOVERNMENT';
        accCase.Sub_Industry__c = 'STATE';
        insert accCase;
        
        Contact conCase = new Contact();
        conCase.AccountId = accCase.Id;
        conCase.FirstName = 'Saurabh';
        conCase.LastName = 'Sharma';
        conCase.Salutation = 'Eng';
        conCase.Email = 'noreply@dummy.com';
        conCase.PreferredLanguage__c = 'en_US';
        conCase.Portal_Case_Type__c = 'Information Offering; Technology Solutions';
        conCase.Contact_User_Type__c = 'Rep User';
        conCase.EmployeeNumber__c = '44504';
        insert conCase;
        FeedItem feed = new FeedItem (parentid = accCase.id,type = 'CreateRecordEvent', Body = 'Hello');
        insert feed;
        
        CSM_Case_Details_Global_Setting__c gd = new CSM_Case_Details_Global_Setting__c();
        gd.Name = 'Tech_RCA_Document';
        gd.Setting_Type__c = 'OS07. Internal Root Cause Analysis Form.docx';
        gd.Other_Details__c = 'https://quintiles.sharepoint.com/:w:/r/sites/MAP/Shared%20Documents/Templates/Standard/OS07.%20Internal%20Root%20Cause%20Analysis%20Form.docx';
        insert gd;
        CSM_Case_Details_Global_Setting__c custsettObj1 = new CSM_Case_Details_Global_Setting__c();
        custsettObj1.Name = 'Email Template Default New';
        custsettObj1.Setting_Type__c = 'Email Template';
        custsettObj1.Country__c = 'Default';
        custsettObj1.Component_Id__c = '00X6A000000hM1F';
        custsettObj1.Other_Details__c = 'New';
        custsettObj1.RecordTypeId__c = '0126A000000hC35QAE';
        insert custsettObj1;
        
        CSM_Case_Details_Global_Setting__c custSet = new CSM_Case_Details_Global_Setting__c();
        custSet.Name = 'CAS_ET_CSM_Data_OriginatorNotification';
        custSet.Setting_Type__c = 'Email Template';
        custSet.Country__c = 'Default';
        custSet.Origin__c = 'Customer Portal';
        custSet.Component_Id__c = '00X6A000000hM1F';
        custSet.Other_Details__c = 'Resolved with Customer';
        custset.RecordTypeId__c = '0126A000000hC35QAE';
        insert custSet;
        CSM_Case_Details_Global_Setting__c ct001 = new CSM_Case_Details_Global_Setting__c();
        ct001.Name = 'CAS_ET_CSM_tionEmailTECH';
        ct001.Setting_Type__c = 'Email Template';
        ct001.Country__c = 'Default';
        ct001.Origin__c = 'Customer Portal';
        ct001.Component_Id__c = '00X6A000000hM1F';
        ct001.Other_Details__c = 'Closed';
        ct001.RecordTypeId__c = '0126A000000hC35QAE';
        insert ct001;
        
        CSM_Case_Details_Global_Setting__c custSet555 = new CSM_Case_Details_Global_Setting__c(Name = 'ET TECH EN CSH OOO Queue Message',Setting_Type__c = 'Email Template',Component_Id__c = '00X6A000000hM1F');
        insert custSet555;
        CSM_Case_Details_Global_Setting__c custSet554 = new CSM_Case_Details_Global_Setting__c(Name = 'ET TECH EN PRM OOO Queue Message',Setting_Type__c = 'Email Template',Component_Id__c = '00X6A000000hM1F');
        insert custSet554;
        
        CSM_Case_Details_Global_Setting__c custsettObj2 = new CSM_Case_Details_Global_Setting__c();
        custsettObj2.Name = 'Org Wide No-Reply';
        custsettObj2.Setting_Type__c = 'Org Wide';
        custsettObj2.Component_Id__c = '0D26A000000L1W5';
        custsettObj2.Other_Details__c = 'Customer Portal';
        custsettObj2.Origin__c = 'Customer Portal';
        custsettObj2.RecordTypeId__c = '0126A000000hC35QAE';
        insert custsettObj2;
        
        CSM_Case_Details_Global_Setting__c custsettObj3 = new CSM_Case_Details_Global_Setting__c();
        custsettObj3.Name = 'Email Template register PEP';
        custsettObj3.Setting_Type__c = 'Email Template';
        custsettObj3.Country__c = 'Default PEP';
        custsettObj3.Component_Id__c = '0D26A000000L1W5';
        custsettObj3.Other_Details__c = 'New';
        custsettObj3.Origin__c = 'Partner Portal';
        custsettObj3.RecordTypeId__c = '0126A000000hC35QAE';
        insert custsettObj3;
        
        CSM_Case_Details_Global_Setting__c custsettObj4 = new CSM_Case_Details_Global_Setting__c();
        custsettObj4.Name = 'ET_TECH_EN_Case Closed  PEP';
        custsettObj4.Setting_Type__c = 'Email Template';
        custsettObj4.Country__c = 'PEP';
        custsettObj4.Component_Id__c = '0D26A000000L1W5';
        custsettObj4.Other_Details__c = 'Closed';
        custsettObj4.Origin__c = 'Partner Portal';
        custsettObj4.RecordTypeId__c = '0126A000000hC35QAE';
        insert custsettObj4;
        
        CSM_Case_Details_Global_Setting__c custsettObj5 = new CSM_Case_Details_Global_Setting__c();
        custsettObj5.Name = 'Email Template Update PEP';
        custsettObj5.Setting_Type__c = 'Email Template';
        custsettObj5.Country__c = 'PEP';
        custsettObj5.Component_Id__c = '0D26A000000L1W5';
        custsettObj5.Other_Details__c = 'CaseComment';
        custsettObj5.Origin__c = 'Partner Portal';
        custsettObj5.RecordTypeId__c = '0126A000000hC35QAE';
        insert custsettObj5;
        CSM_Case_Details_Global_Setting__c setting = new CSM_Case_Details_Global_Setting__c(Name='LTMS_Special_Char',Setting_Type__c='class:class,â€™:,Â:,~/:\n');
		insert setting;
        CSM_Case_Details_Global_Setting__c ca1 = new CSM_Case_Details_Global_Setting__c();
        ca1.Name = 'Email Template New OrgIN';
        ca1.Setting_Type__c = 'Email Template';
        ca1.Country__c = 'IN';
        ca1.Component_Id__c = '00X6A000001DnmrUAC';
        ca1.Other_Details__c = 'DATACase';
        ca1.RecordTypeId__c = '0126A000000hC35QAE';
        insert ca1;
        
        CSM_Case_Details_Global_Setting__c ca11 = new CSM_Case_Details_Global_Setting__c();
        ca11.Name = 'Email Template Default New Org';
        ca11.Setting_Type__c = 'Email Template';
        ca11.Country__c = 'Default';
        ca11.Component_Id__c = '00X6A000001DnmrUAC';
        ca11.Other_Details__c = 'DATACase';
        ca11.RecordTypeId__c = '0126A000000hC35QAE';
        insert ca11;
        
        CSM_Case_Details_Global_Setting__c ca2 = new CSM_Case_Details_Global_Setting__c();
        ca2.Name = 'Org Wide No-Reply Org';
        ca2.Setting_Type__c = 'Org Wide';
        ca2.Component_Id__c = '0D26A000000L1W5';
        ca2.Other_Details__c = 'Default';
        ca2.Origin__c = 'Customer Portal';
        ca2.RecordTypeId__c = '0126A000000hC35QAE';
        insert ca2;
        
        CSM_Case_Details_Global_Setting__c csmSettingData1 = new CSM_Case_Details_Global_Setting__c();
        csmSettingData1.Name = 'ET DATA EN Case Creation';
        csmSettingData1.Component_Id__c = '00X6A000000V1If';
        csmSettingData1.Country__c = 'Default';
        csmSettingData1.Origin__c = 'Customer Portal';
        csmSettingData1.Other_Details__c = 'New';
        csmSettingData1.RecordTypeId__c = '0126A000000hC33QAE';
        csmSettingData1.Setting_Type__c = 'Email Template';
        insert csmSettingData1;
        
        CSM_Case_Details_Global_Setting__c csmSettingData2 = new CSM_Case_Details_Global_Setting__c();
        csmSettingData2.Name = 'ET DATA EN Case Resolution';
        csmSettingData2.Component_Id__c = '00X6A000000V1If';
        csmSettingData2.Country__c = 'Default';
        csmSettingData2.Origin__c = 'Customer Portal';
        csmSettingData2.Other_Details__c = 'Resolved';
        csmSettingData2.RecordTypeId__c = '0126A000000hC33QAE';
        insert csmSettingData2;
        /*EmailTemplate validET = new EmailTemplate();
        validET.isActive = true;
        validET.Name = 'CSM_TECH_EmailTemp_Test1';
        validET.DeveloperName = 'CSM_TECH_EmailTemp_Test1';
        validET.TemplateType = 'text';
        validET.FolderId = UserInfo.getUserId();
        validET.Subject = 'CSM_TECH_EmailTemp_Test1';
        insert validET;*/
        List<EmailTemplate> emList = Database.query('select Id,Name from EmailTemplate where name  in (\'ET TECH EN Case AFU No Response\',\'ET TECH EN Case AFU Message\')');
        CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c afu = new CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c();
        afu.Name = 'EN';
        if(emList != null){
            afu.AFU_No_Response_TemplateID__c = emList[0].Id;
            afu.AFU_Follow_Up_TemplateID__c = emList[0].Id;
        }else{
            afu.AFU_No_Response_TemplateID__c = '00X2g000000IHieEAG';
            afu.AFU_Follow_Up_TemplateID__c = '00X2g000000IHieEAG';
        }
        insert afu;
        BusinessHours bHours1 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        CSM_AFU_DEFAULT_EMAIL__c afuDef = new CSM_AFU_DEFAULT_EMAIL__c();
        afuDef.Name = 'replytocsm';
        afuDef.Default_AFU_Email__c = 'replytocsm@iqvia.csm';
        insert afuDef;
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='Q1';
        queues1.Tier__c ='Tier 1';
        queues1.QueueName__c ='Q1';
        queues1.Business_Hours__c = bHours1.Id;
        queues1.Out_Of_Office_Notification__c = true;
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='Q1';
        queues1.Business_Hours__c = bHours1.Id;
        queues1.Out_Of_Office_Notification__c = true;
        queueUser1.Tier__c ='Tier 1';
        queueUser1.QueueName__c ='Q1';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        Queue_User_Relationship__c q12 = new Queue_User_Relationship__c(Name ='Q2 T2',Tier__c ='Tier 2', QueueName__c ='Q1',
        Business_Hours__c = bHours1.Id,Out_Of_Office_Notification__c = true,Type__c ='Queue',User__c = UserInfo.getUserId());
        insert q12;
        CSM_ExternalClient_info__c interCl = new CSM_ExternalClient_info__c();
        interCl.Name = 'Internal';
        interCl.UserName__c = 'test';
        interCl.Password__c = 'test';
        interCl.Client_Url__c = 'http://test.iqvia.com';
		interCl.Q2_POST_URL__c = 'http://test.iqvia.com';
        interCl.Q2_GET_URL1__c = 'http://test.iqvia.com';
        interCl.Q2_GET_URL2__c = 'test.iqvia.com';
        interCl.Infosario_Group_Id__c = '5539';
        interCl.Email_CC__c = 'http://test.iqvia.com';
        insert interCl;
        
        G_Inquiry_Settings__c gInquirySettings = new G_Inquiry_Settings__c();
        gInquirySettings.GInquiry_Case_Owner_Email__c = 'john2@iqvia.com';
        gInquirySettings.GInquiry_Case_Owner_Name__c = 'GInquiry User';
        gInquirySettings.Ginquiry_Current_Queue__c = queueUser1.Id;
        gInquirySettings.GInquiry_Initial_Queue__c = queueUser1.Id;
        gInquirySettings.GInquiry_Case_Owner__c = queueUser1.User__c;
        Insert gInquirySettings;
        
        List<CaseOLASettings__c> pList = new List<CaseOLASettings__c>();
        CaseOLASettings__c pp1 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 1',Priority__c = 'Priority 1',Target_Time__c = 120);
        pList.add(pp1);
        CaseOLASettings__c pp2 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 2',Priority__c = 'Priority 2',Target_Time__c = 240);
        pList.add(pp2);
        CaseOLASettings__c p3 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 3',Priority__c = 'Priority 3',Target_Time__c = 360);
        pList.add(p3);
        CaseOLASettings__c p4 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 4',Priority__c = 'Priority 4',Target_Time__c = 480);
        pList.add(p4);
        CaseOLASettings__c ol = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' OLA',Priority__c = 'Priority 4',Target_Time__c = 1440);
        pList.add(ol);
        insert pList;
        
        OneKey_Config__c oneKey = new OneKey_Config__c(OneKey_Request_1__c = '{"fields": [{"name": "individual.individualEid","values":[',
                                                       OneKey_Request_2__c = '],"codBase": [{0}"]}', Exact_Search_Method__c = '],"method": "EXACT"},',
                                                       Phonetic_Search_Method__c = '],"method": "PHONETIC"},', OneKey_Request_3__c = '{"name": "individual.firstNameLastName","values":[');
        insert oneKey;
        CSM_case_Trigger_Handler__c am = new CSM_case_Trigger_Handler__c(CSM_Activity_Open_Validation__c = true,CSM_Sender_Email_Id__c ='replytocsm@iqvia.com');
        insert am;
        List<Case> caseList = new List<Case>();
        
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Product2 p1 = new Product2(Name = 'DDD',Pillar__c = 'Information Offering',SpecificToCSM__c = True);
        insert p1;
        Product2 p2 = new Product2(Name = 'Nexxus MI',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
       Product_Group_Relationship__c pg = new Product_Group_Relationship__c(Name='ProdG',Product__c =p2.Id,Collaboration_Group_Id__c = accCase.id);
        insert pg;
        Asset a1 = new Asset(Name = 'DDD', AccountId = accObjId, Product2Id = p1.id, Status ='Installed');
        insert a1;
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = accObjId, Product2Id = p2.id, Status ='Installed');
        insert a2;
        List<Asset> asList = new List<Asset>();
        Asset a3 = new Asset(Name = 'DDD', AccountId = acct.Id, Product2Id = p1.id, Status ='Installed');
        asList.add(a3);
        Asset a4 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        asList.add(a4);
        insert asList;
        
        List<CSM_QI_Case_Categorization__c> ccList = new List<CSM_QI_Case_Categorization__c>();
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c(
        Product__c= p2.Id,SubType1__c = 'Incident-Module', SubType2__c = 'Formularies',
        SubType3__c = '--none--', Active__c = true, Type__c = 'Categorization', Pillar__c = 'Technology Solutions');
        ccList.add(cc);
        CSM_QI_Case_Categorization__c ccData = new CSM_QI_Case_Categorization__c(
        Product__c= p1.Id, SubType1__c = 'DATA MGT/PRODUCTION',SubType2__c = 'DATA ISSUES',SubType3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)',
        Active__c = true,Type__c = 'Categorization', Pillar__c = 'Information Offering');
        ccList.add(ccData);
        insert ccList;
        
        Entitlement entRd = new Entitlement(Name='R&D Testing', AccountId=acct.Id,Type = 'R&D',
                                           BusinessHoursId = bHours1.Id, StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        Entitlement entTech = new Entitlement(Name='TECHNO Testing', AccountId=accObjId,Type = 'TECHNO',
                                           BusinessHoursId = bHours1.Id, StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        Entitlement entData = new Entitlement(Name='Data Testing', AccountId=accObjId,Type = 'DATA',
                                           BusinessHoursId = bHours1.Id, StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        insert entTech;
        insert entData;
        insert entRd;
        CSM_Queue_Dispatch_Case_Permissions__c dP = new CSM_Queue_Dispatch_Case_Permissions__c(IsActive__c = true,Source_Queue__c = q12.Id, Destination_Queue__c=queues1.Id,Type__c ='Allow',RecordType_Name__c='TechnologyCase');
        insert dP;
        CSM_Email_To_Case_Custom_Settings__c e2cCase1 = new CSM_Email_To_Case_Custom_Settings__c(Queue_User_Relationship__c = queues1.Id,Keyword_Assignment__c = 'Test',Type__c = 'Mir3 SMS Notification');
        insert e2cCase1;
		CSM_Email_To_Case_Custom_Settings__c e2cCase2 = new CSM_Email_To_Case_Custom_Settings__c(Queue_User_Relationship__c = q12.Id,Keyword_Assignment__c = 'Test',Type__c = 'Mir3 SMS Notification');
        insert e2cCase2;
		CSM_Email_To_Case_Custom_Settings__c e2cCase3 = new CSM_Email_To_Case_Custom_Settings__c(Queue_User_Relationship__c = queues1.Id,Keyword_Assignment__c = 'Test',Type__c = 'Prevent Creation');
        insert e2cCase3;
        Case cs = new Case();
        cs.Force_CSAT_Email_Survey__c = true;
        cs.ContactId = conObjId;
        cs.AccountId = accObjId;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = recordTypeIdTechno;
        cs.Priority = 'Priority 4';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.OOO_FLag__c = true;
        cs.Subject = 'Techno Test case';
        cs.Description = 'Test class to check case creation ';
        cs.Status = 'New';
        cs.CurrentQueue__c = queueUser1.Id;
        cs.AssetId = a2.Id;
        cs.Case_CategorizationId__c = cc.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        cs.External_System_Type__c = CON_CSM.S_BISM;
        cs.ServiceNowSystemType__c = CON_CSM.S_BISM;
        cs.EntitlementId = entTech.Id;
        cs.Set_Internal_Follow_Up_from_Priority__c = true;
        caseList.add(cs);
        
        Case csData = new Case();
        csData.Force_CSAT_Email_Survey__c = true;
        csData.AccountId = accObjId;
        csData.AssignCaseToCurrentUser__c = false;
        csData.RecordTypeId = RecordTypeIdData;
        csData.OwnerId = UserInfo.getUserId();
        csData.AssetId = a1.Id;
        csData.LOS__c = 'DATA';
        csData.SubType1__c = 'DATA MGT/PRODUCTION';
        csData.SubType2__c = 'DATA ISSUES';
        csData.SubType3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)';
        csData.Priority = 'High';
        csData.Origin = 'Agent Initiated';
        csData.Subject = 'Data Test case';
        csData.Description = 'No information available';
        csData.Status = 'In Progress';
        csData.CurrentQueue__c = queueUser1.Id;
        csData.InitialQueueData__c = queueUser1.Id;
        csData.First_response_email_time__c = null;
        csData.First_response_sent__c = FALSE;
        csData.EntitlementId = entData.Id;
        caseList.add(csData);
        
        Case cs2 = new Case();
        cs2.Force_CSAT_Email_Survey__c = true;
        cs2.ContactId = conObjId;
        cs2.AccountId = accObjId;
        cs2.AssignCaseToCurrentUser__c = false;
        cs2.OwnerId = UserInfo.getUserId();
        cs2.RecordTypeId = recordTypeIdTechno;
        cs2.Priority = 'Priority 3';
        cs2.Origin = 'Partner Portal';
        cs2.CaseSource__c = 'Customer';
        cs2.Mail_CC_List__c = 'nodata@info.com';
        cs2.Subject = 'Techno case';
        cs2.Description = 'Test class to check case creation';
        cs2.Status = 'New';
        cs2.AssetId = a2.Id;
        cs2.Case_CategorizationId__c = cc.Id;
        cs2.ProductName__c= 'Nexxus MI';
        cs2.SubType1__c = 'Incident-Module';
        cs2.SubType2__c = 'Formularies';  
        cs2.SubType3__c = '--none--';
        cs2.CurrentQueue__c = queueUser1.Id;
        cs2.External_System_Type__c = CON_CSM.S_ROCHE_SN;
        cs2.EntitlementId = entTech.Id;
        cs2.Set_Internal_Follow_Up_from_Priority__c = true;
        caseList.add(cs2);
        
        Case csTech1 = new Case();
        csTech1.Force_CSAT_Email_Survey__c = true;
        csTech1.ContactId = conObjId;
        csTech1.AccountId = accObjId;
        csTech1.AssignCaseToCurrentUser__c = false;
        csTech1.OwnerId = UserInfo.getUserId();
        csTech1.RecordTypeId = recordTypeIdTechno;
        csTech1.Priority = 'Priority 2';
        csTech1.Origin = 'Partner Portal';
        csTech1.Mail_CC_List__c = 'nodata@info.com';
        csTech1.Subject = 'Techno Test case for csh';
        csTech1.Description = 'Test class to check case creation ';
        csTech1.Status = 'New';
        csTech1.CurrentQueue__c = queueUser1.Id;
        csTech1.AssetId = a2.Id;
        csTech1.Case_CategorizationId__c = cc.Id;
        csTech1.ProductName__c= 'Nexxus MI';
        csTech1.SubType1__c = 'Incident-Module';
        csTech1.SubType2__c = 'Formularies';  
        csTech1.SubType3__c = '--none--';
        csTech1.Case_Type__c = 'Problem';
        csTech1.EntitlementId = entTech.Id;
        csTech1.Set_Internal_Follow_Up_from_Priority__c = true;
        caseList.add(csTech1);
        
        // cc list test data end
        Study__c study1= CSM_Util.createStudy(acct2.Id);
        study1.Name ='STUDY12';
        study1.StudyID__c ='PROJ0012';
        study1.LabProjectCode__c ='LABPROJ0012';
        study1.Protocol__c ='STUDY12';
        insert study1;
        
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        StudySiteContactRelationship__c siteConR1=new StudySiteContactRelationship__c(Study__c = study1.Id,Investigator_Name__c = con.Id,Site_Name__c = acct.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        Case cs1 = new Case(
            Force_CSAT_Email_Survey__c = true,
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'Child Activity Plan Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            EntitlementId = entRd.Id,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1,Count_of_AFU__c = 1
        );
        caseList.add(cs1);
        
        Case csActivityPlan = new Case(
            Force_CSAT_Email_Survey__c = true,
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'Parent Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = entRD.Id,
            RnD_Email_Flag__c = true,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        
        caseList.add(csActivityPlan);
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Case csAssistanceRequest = new Case(
            Force_CSAT_Email_Survey__c = true,
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Owner__c = 'LTMS',
            Subject = 'Assistance Request Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = entRd.Id,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RnD_Email_Flag__c = true,
            RecordTypeId = RecordTypeIdCase
        );
        caseList.add(csAssistanceRequest);
        
        Id RecordTypeIdTC = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId(); 
        for(integer i = 0;i<1;i++){           
            Case newCaseForAFU = new Case(
                Force_CSAT_Email_Survey__c = true,
                AccountId = accCase.Id,
                ContactId = con.Id,         
                CurrentQueue__c=queues1.Id,
                Origin = 'Web',                
                Subject = 'Test Subject' + 1,
                Description = 'Test Desc' + 1,
                InitialQueue__c = 'Q1',
                Status = 'New',
                Priority = 'Priority 4',
                RecordTypeId = RecordTypeIdTC,
                OwnerId = UserInfo.getUserId()
            );            
            caseList.add(newCaseForAFU);
        }  
        Test.startTest();
        insert caseList;
        Test.stopTest();
        DAOH_Case.getCSMProfile('profileId');
        
    }

    @isTest
    static void testAutomatedProcess(){
        User autoUser = [select Id,Name from user where Name ='Automated Process' Limit 1 ];
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
                    LiveChatTranscript trans = new LiveChatTranscript(CaseId = newCaseForAFU.Id,LiveChatDeploymentId = ldep.Id, LiveChatVisitorId = visitor.Id, Email__c = 'test@test.com',FirstName__c = 'Mallikarjuna',LastName__c = 'Reddy',Body = 'Some chat.  Blah Blah');
                    insert trans;
                    
                    newCaseForAFU.Status = 'New';
                    update newCaseForAFU;
                    
                }
                catch(Exception ex){
                    
                }
            }
        Test.stopTest();
    }
    
    
    /** Milestone Test start*/
    static testMethod void TestCompleteMilestoneCase(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Id accId = acc.Id;
        Study__c study = [SELECT Id, Name FROM Study__c WHERE Name = 'testSetupCaseTestStudy' LIMIT 1];
        StudySiteContactRelationship__c siteConR = [Select Id,Study__c,Investigator_Name__c, Site_Name__c From StudySiteContactRelationship__c where Site_Name__r.Name = 'testSetupTestSiteAccount1' LIMIT 1];
        List<Case> cases = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase','ActivityPlan')];
        List<Id> caseIds = new List<Id>();
        
        if (cases.isEmpty()==false){
            for (Case cL : cases){
                caseIds.add(cl.Id);
            }
            DAOH_Case.completeMilestone(caseIds, CON_CSM.S_FIRST_RESPONSE_T, System.now());            
            for (Case cL : cases){
                caseIds.add(cl.Id);
                cL.Force_CSAT_Email_Survey__c = true;
                cL.Status = 'Closed';
                cL.SlaStartDate = Date.today().addMonths(-2);
            }
            Test.startTest();
            update cases;
            Test.stopTest();
        }
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforCase() {
        CNT_CSM_FieldHistoryTracking.saveFields('Case','AccessionNumber__c,Account_Name_Article__c,AccountCountry__c,ACN__c,ActionDescription__c,Activity__c,AdditionalAction__c,AdditionalActionsCompleted__c,AdditionalThirdPartyCase2__c,AdditionalThirdPartyCase__c,AgeGrouping__c,AlignmentName__c,Approach__c,AreyouquestioningcomparingProjected__c,AssetName__c,AssignCaseToCurrentUser__c,ATCLevel__c,AttachMarketDefinitionToTicket__c,Auditsquestioningcomparing__c,AutoClosed__c,BusinessHours__c,BusinessHoursId,BusinessUntilDueDate__c,Case_CategorizationId__c,CaseCreator__c,CaseRequestBy__c,CaseSource__c,CaseSubType1__c,CaseSubType2__c,CaseSubType3__c,CFM10CFM7__c,Channel__c,Channelsquestioningcomparing__c,ChildCaseDescription__c,ClientInq__c,ClientObjectiveBusinessNeed__c,ClientRefMaterial__c,ClosedBy__c,ClosedByGroup__c,CloseNotes__c,CMFProd__c,Comments,ComplexityLevel__c,ConfigurationItem__c,ConsumerHealthData__c,ContactBusinessTerritory__c,ContactEmail,ContactFax,ContactMobile,ContactPhone,COREClassification__c,CORESubClassification__c,CoreTicket__c,CreatedByGroup__c,CreatedDate__c,CRMSolutionSupportPriority__c,CrossauditDIsales__c,CrossDatabase__c,CurrencyIsoCode,InitialQueue__c,CurrentQueue1__c,CurrentQueue__c,Customer_Requested_Date__c,CustomerQualityAlert__c,CustomerRequiredDate__c,CustomerUrgency__c,CycleFrom__c,CycleTo__c,DataDeliveryEndDate__c,DataDeliveryFrequency__c,DataMeasurement__c,DataSourceSPP__c,DataTimePeriodInQuestion__c,DataTypeIMSOne__c,DataWeekMonthOfReport__c,DateCorrected__c,DateofAction__c,DateResolved__c,DEA__c,Describetheissuedifferenceindetail__c,DidthisRequireCorrectiveAction__c,DueDate__c,EmailCC__c,EntitlementId,EnvironmentType__c,ExternalContacts__c,ExternalTeamStatusNE__c,FillinthenameoftheClientCompanyt__c,FirstCallResolution__c,FlexibleFields__c,FollowUpDateLevel__c,ForeignCallerId__c,FoundBy__c,From_EmailToCase__c,GlobalCaseType__c,HCRS_DaaS_Manual_Match_ID__c,HCRSWebID__c,HelpDeskWarmTransfer__c,HospitalsIncluded__c,HOTFix__c,IfOtherChannelPleasespecify__c,IfOtherMetricsPleaseSpecify__c,IfOtherPEPTPleaseSpecify__c,IfyeshowmanylookupsrequiredCorrec__c,Impact__c,ImplementationCenterRequester__c,Imputation__c,IMSDr__c,IMSPrescriberNumber__c,InitialQueue__c,InternalOrExternalDI__c,IsClosedOnCreate,IsStopped,Issue__c,IssueCausedBy__c,IssuedDifferencepreresearchconducted__c,IsThisASpecialHandlingClient__c,ItemNumber__c,JIRANotes__c,LastModifiedDate__c,LevelOfService__c,LookBackPeriod__c,LOS__c,ManagerEvaluation__c,MarketNameOnWeb__c,Metric__c,Metricsquestioningcomparing__c,MilestoneStatus,MIVersion__c,MonoComboTherapy__c,MonthofRework__c,NDC_Number__c,NextMilestoneFlag__c,NextMilestonePriorValue__c,NextMilestoneStatus__c,NextNotificationDate__c,NoContactKnown__c,NovartisCaseType__c,Numberaffected__c,NumberofDatabasesReworked__c,NumberOfNotifications__c,OpsHourEstimated__c,OpsRunbookIMSOne__c,OpsStackRank__c,ParentId,PEPTOnOff__c,Phone_Number__c,PhoneVerification__c,Plan__c,Plan_Name__c,PlanEndDate__c,PlannedFixDate__c,PlanStartDate__c,PrimaryOrSecondaryFactory__c,PriorityDefinitionDate__c,ProductId,ProductMarketorOther__c,ProductMarketOrOtherName__c,ProductName__c,ProductOutletToResearch__c,ProductPackSize__c,ProjectCategoryNS__c,PRSNumber__c,PSACode__c,QualityIssue__c,QuintilesIMSRefMaterial__c,Reason,RecordTypeId,RecordTypeName__c,Release__c,ReOpenDate__c,ReOpened__c,ReOpener__c,ReportCustomisation__c,ReportLocations__c,ReportsTo__c,RequireAction__c,RequiredCallbackCompleted__c,RequiredReprocess__c,ResolutionCode__c,ResolutionsharedwithCustomer__c,ResolutionSubType__c,ResolvedBy__c,ResolvedWithinSLP__c,Retail__c,RootCause__c,RootCauseCommentsinternal__c,RootCauseToClients__c,RunDateOfReport__c,ScheduledDate__c,SendAutomaticAcknowledgmentEmail__c,SendResolutionEmail__c,ServiceNow_Group__c,Site__c,SlaExitDate,SlaStartDate,SLPTurnaroundTime__c,SolvedBY__c,SOTC__c,SourceId,SpecialtyGrouping__c,StatusAtFirstSubmission__c,StatusDefinitionDate__c,StopStartDate,SubcaseClasification__c,SubType1__c,SubType2__c,SubType3__c,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,Supplier__c,SupplierCustom__c,SupplierName__c,SupportTier__c,Survey_Link__c,SwitchAddGracePeriod__c,Tag__c,Target_Date__c,Template__c,Territory__c,TerritoryIDNE__c,ThirdPartyCase__c,TimeIntervalsquestioningcomparing__c,Timeline__c,TimingofReportChanges__c,TotalTimeinhours__c,Type,TypeCustom__c,UrgentForCustomer__c,USC3__c,USC5__c,USC_Code__c,UserTrainedDate__c,What_limitsdoesyourdatainclude__c,WhatChannelIsConcerned__c,WhatLimitsDoesYourDataInclude__c,WhatMetricsIsConcerned__c,WhatTimePeriodareyouquestioning__c,WhySLPWasMissed__c,WhySLPwasMissedDescription__c,Workaround__c,XponentPrescribingDynamics__c,ZipOutlet__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        cnt2.PreferredLanguage__c = 'en_US';
        insert cnt2;
        Study__c study= CSM_Util.createStudy(acct2.Id);
        study.Name ='STUDY1';
        study.StudyID__c ='PROJ001';
        study.LabProjectCode__c ='LABPROJ001';
        insert study;
        Study__c study2= CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = new Product2(Name = 'CaseTestProduct1Audit', ProductCode='TSTP-0011',Family='None',IsActive=true);
        product.Pillar__c = 'Information Offering; Technology Solutions';
        insert product;
        Asset aset=CSM_Util.createAsset('CaseTestProduct1Audit',product.Id,acc.Id,cnt.Id,study.Id);
        insert aset;
        ServiceNow_Group__c service=new ServiceNow_Group__c();
        service.Group_ID__c='GRP123';
        service.Name = 'Service GRP123';
        service.Order__c = 1;
        insert service;
        
        ServiceNow_Group__c service2=new ServiceNow_Group__c();
        service2.Group_ID__c='GRP123';
        service2.Name = 'Service GRP123';
        service2.Order__c = 1;
        insert service2;
        
        CSM_ExternalClient_info__c interCl = new CSM_ExternalClient_info__c();
        interCl.Name = 'Internal';
        interCl.UserName__c = 'test';
        interCl.Password__c = 'test';
        interCl.Client_Url__c = 'http://test.iqvia.com';
		interCl.Q2_POST_URL__c = 'http://test.iqvia.com';
        interCl.Q2_GET_URL1__c = 'http://test.iqvia.com';
        interCl.Q2_GET_URL2__c = 'test.iqvia.com';
        interCl.Infosario_Group_Id__c = service2.Id;
        interCl.Email_CC__c = 'http://test.iqvia.com';
        insert interCl;
        
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        BusinessHours bHours2 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='EU Business Hours' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R&D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        Entitlement ent2 = new Entitlement(Name='Testing2', AccountId=acc.Id,Type = 'R&D',
                                           BusinessHoursId = bHours2.Id,
                                           StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        queues.Tier__c ='Tier 1';
		queues.Business_Hours__c = bHours.Id;
        queues.Out_Of_Office_Notification__c = true;
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        queueUser.Tier__c ='Tier 1';
        queueUser.Business_Hours__c = bHours.Id;
        queueUser.Out_Of_Office_Notification__c = true;
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='prodops';
        queues2.QueueName__c ='prodops';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        queues2.Tier__c ='Tier 1';
        queues2.Business_Hours__c = bHours.Id;
        queues2.Out_Of_Office_Notification__c = true;
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='prodops';
        queueUser2.QueueName__c ='prodops';
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        queueUser2.Tier__c ='Tier 1';
        queueUser2.TECH_QueueUser__c = queues2.Id;
        queueUser2.Business_Hours__c = bHours.Id;
        queueUser2.Out_Of_Office_Notification__c = true;
        insert queueUser2;
        
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        insert siteConR;
        siteConR.SiteNumber__c = 'SITE01';
        siteConR.Lab_Site_Number__c = 'LABSITE01';
        update siteConR;
        StudySiteContactRelationship__c siteConR2=new StudySiteContactRelationship__c(Study__c = study2.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR2.SiteNumber__c = 'SSCN121121';
        insert siteConR2;
        List<Case> csList = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase','ActivityPlan')];

        
        if(csList != null && csList.size() > 0){
            Case cse = csList[0];
            Case cseParent = csList[1];
            Test.startTest();
            cse.CurrentQueue__c = queues2.Id;
            cse.InitialQueue__c  =  'Q2';
            cse.Study__c  =  study2.Id;
            cse.Site_Related_to_the_Study__c = siteConR2.Id;
            cse.AssetId =  aset.Id;
            cse.ServiceNow_Group__c =  service2.Id;
            cse.LOS__c = CON_CSM.S_Q2_INV_SITE;
            cse.ServiceNowSystemType__c = 'Internal';
            cse.EntitlementId  =  ent2.Id;
            cse.BusinessHoursId  =  bHours2.Id;
            update cse;
            cse.Study__c  =  study.Id;
            cse.Site_Related_to_the_Study__c = siteConR.Id;
            cse.CurrentQueue__c = queues2.Id;
            cse.InitialQueue__c  =  'Q2';
            cse.Status = 'In Progress';
            cse.Description = 'Test Case for Trigger';
            cse.SubType2__c = 'tbd';
            cse.EntitlementId  =  ent2.Id;
            cse.BusinessHoursId  =  bHours2.Id;
            update cse;
            Test.stopTest();    
        }
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforCase2() {
        CNT_CSM_FieldHistoryTracking.saveFields('Case','AccessionNumber__c,Account_Name_Article__c,AccountCountry__c,ACN__c,ActionDescription__c,Activity__c,AdditionalAction__c,AdditionalActionsCompleted__c,AdditionalThirdPartyCase2__c,AdditionalThirdPartyCase__c,AgeGrouping__c,AlignmentName__c,Approach__c,AreyouquestioningcomparingProjected__c,AssetName__c,AssignCaseToCurrentUser__c,ATCLevel__c,AttachMarketDefinitionToTicket__c,Auditsquestioningcomparing__c,AutoClosed__c,BusinessHours__c,BusinessHoursId,BusinessUntilDueDate__c,Case_CategorizationId__c,CaseCreator__c,CaseRequestBy__c,CaseSource__c,CaseSubType1__c,CaseSubType2__c,CaseSubType3__c,CFM10CFM7__c,Channel__c,Channelsquestioningcomparing__c,ChildCaseDescription__c,ClientInq__c,ClientObjectiveBusinessNeed__c,ClientRefMaterial__c,ClosedBy__c,ClosedByGroup__c,CloseNotes__c,CMFProd__c,Comments,ComplexityLevel__c,ConfigurationItem__c,ConsumerHealthData__c,ContactBusinessTerritory__c,ContactEmail,ContactFax,ContactMobile,ContactPhone,COREClassification__c,CORESubClassification__c,CoreTicket__c,CreatedByGroup__c,CreatedDate__c,CRMSolutionSupportPriority__c,CrossauditDIsales__c,CrossDatabase__c,CurrencyIsoCode,InitialQueue__c,CurrentQueue1__c,CurrentQueue__c,Customer_Requested_Date__c,CustomerQualityAlert__c,CustomerRequiredDate__c,CustomerUrgency__c,CycleFrom__c,CycleTo__c,DataDeliveryEndDate__c,DataDeliveryFrequency__c,DataMeasurement__c,DataSourceSPP__c,DataTimePeriodInQuestion__c,DataTypeIMSOne__c,DataWeekMonthOfReport__c,DateCorrected__c,DateofAction__c,DateResolved__c,DEA__c,Describetheissuedifferenceindetail__c,DidthisRequireCorrectiveAction__c,DueDate__c,EmailCC__c,EntitlementId,EnvironmentType__c,ExternalContacts__c,ExternalTeamStatusNE__c,FillinthenameoftheClientCompanyt__c,FirstCallResolution__c,FlexibleFields__c,FollowUpDateLevel__c,ForeignCallerId__c,FoundBy__c,From_EmailToCase__c,GlobalCaseType__c,HCRS_DaaS_Manual_Match_ID__c,HCRSWebID__c,HelpDeskWarmTransfer__c,HospitalsIncluded__c,HOTFix__c,IfOtherChannelPleasespecify__c,IfOtherMetricsPleaseSpecify__c,IfOtherPEPTPleaseSpecify__c,IfyeshowmanylookupsrequiredCorrec__c,Impact__c,ImplementationCenterRequester__c,Imputation__c,IMSDr__c,IMSPrescriberNumber__c,InitialQueue__c,InternalOrExternalDI__c,IsClosedOnCreate,IsStopped,Issue__c,IssueCausedBy__c,IssuedDifferencepreresearchconducted__c,IsThisASpecialHandlingClient__c,ItemNumber__c,JIRANotes__c,LastModifiedDate__c,LevelOfService__c,LookBackPeriod__c,LOS__c,ManagerEvaluation__c,MarketNameOnWeb__c,Metric__c,Metricsquestioningcomparing__c,MilestoneStatus,MIVersion__c,MonoComboTherapy__c,MonthofRework__c,NDC_Number__c,NextMilestoneFlag__c,NextMilestonePriorValue__c,NextMilestoneStatus__c,NextNotificationDate__c,NoContactKnown__c,NovartisCaseType__c,Numberaffected__c,NumberofDatabasesReworked__c,NumberOfNotifications__c,OpsHourEstimated__c,OpsRunbookIMSOne__c,OpsStackRank__c,ParentId,PEPTOnOff__c,Phone_Number__c,PhoneVerification__c,Plan__c,Plan_Name__c,PlanEndDate__c,PlannedFixDate__c,PlanStartDate__c,PrimaryOrSecondaryFactory__c,PriorityDefinitionDate__c,ProductId,ProductMarketorOther__c,ProductMarketOrOtherName__c,ProductName__c,ProductOutletToResearch__c,ProductPackSize__c,ProjectCategoryNS__c,PRSNumber__c,PSACode__c,QualityIssue__c,QuintilesIMSRefMaterial__c,Reason,RecordTypeId,RecordTypeName__c,Release__c,ReOpenDate__c,ReOpened__c,ReOpener__c,ReportCustomisation__c,ReportLocations__c,ReportsTo__c,RequireAction__c,RequiredCallbackCompleted__c,RequiredReprocess__c,ResolutionCode__c,ResolutionsharedwithCustomer__c,ResolutionSubType__c,ResolvedBy__c,ResolvedWithinSLP__c,Retail__c,RootCause__c,RootCauseCommentsinternal__c,RootCauseToClients__c,RunDateOfReport__c,ScheduledDate__c,SendAutomaticAcknowledgmentEmail__c,SendResolutionEmail__c,ServiceNow_Group__c,Site__c,SlaExitDate,SlaStartDate,SLPTurnaroundTime__c,SolvedBY__c,SOTC__c,SourceId,SpecialtyGrouping__c,StatusAtFirstSubmission__c,StatusDefinitionDate__c,StopStartDate,SubcaseClasification__c,SubType1__c,SubType2__c,SubType3__c,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,Supplier__c,SupplierCustom__c,SupplierName__c,SupportTier__c,Survey_Link__c,SwitchAddGracePeriod__c,Tag__c,Target_Date__c,Template__c,Territory__c,TerritoryIDNE__c,ThirdPartyCase__c,TimeIntervalsquestioningcomparing__c,Timeline__c,TimingofReportChanges__c,TotalTimeinhours__c,Type,TypeCustom__c,UrgentForCustomer__c,USC3__c,USC5__c,USC_Code__c,UserTrainedDate__c,What_limitsdoesyourdatainclude__c,WhatChannelIsConcerned__c,WhatLimitsDoesYourDataInclude__c,WhatMetricsIsConcerned__c,WhatTimePeriodareyouquestioning__c,WhySLPWasMissed__c,WhySLPwasMissedDescription__c,Workaround__c,XponentPrescribingDynamics__c,ZipOutlet__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        cnt2.PreferredLanguage__c = 'en_US';
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acct2.Id);
        study.Name = 'STUDY1';
        study.StudyID__c = 'PROJ001';
        study.LabProjectCode__c = 'LABPROJ001';
        insert study;
        Study__c study2 = CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = new Product2(Name = 'CaseTestProduct2Audit', ProductCode='TSTP-0012',Family='None',IsActive=true);
        product.Pillar__c = 'Information Offering; Technology Solutions';
        insert product;
        Asset aset = CSM_Util.createAsset('CaseTestProduct2Audit',product.Id, acc.Id, cnt.Id, study.Id);
        insert aset;
        ServiceNow_Group__c service = new ServiceNow_Group__c();
        service.Group_ID__c = 'GRP123';
        service.Name = 'Service GRP123';
        service.Order__c = 1;
        insert service;
        
        ServiceNow_Group__c service2 = new ServiceNow_Group__c();
        service2.Group_ID__c = 'GRP123';
        service2.Name = 'Service GRP123';
        service2.Order__c = 1;
        insert service2;
        
        BusinessHours bHours = [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours WHERE IsActive = true and name = 'Default' LIMIT 1];
        BusinessHours bHours2 = [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours WHERE IsActive = true and name = 'EU Business Hours' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name = 'Testing', AccountId = acc.Id, Type = 'R&D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate = Date.valueof(System.now().addDays(-2)), 
                                          EndDate = Date.valueof(System.now().addYears(2)));
        
        Entitlement ent2 = new Entitlement(Name='Testing2', AccountId=acc.Id,Type = 'R&D',
                                           BusinessHoursId = bHours2.Id,
                                           StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId();
        queues.Tier__c ='Tier 1';
        queues.Business_Hours__c = bHours.Id;
        queues.Out_Of_Office_Notification__c = true;
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        queueUser.Tier__c ='Tier 1';
        queueUser.Business_Hours__c = bHours.Id;
        queueUser.Out_Of_Office_Notification__c = true;
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='prodops';
        queues2.QueueName__c ='prodops';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        queues2.Tier__c ='Tier 1';
        queues2.Business_Hours__c = bHours.Id;
        queues2.Out_Of_Office_Notification__c = true;
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='prodops';
        queueUser2.QueueName__c ='prodops';
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        queueUser2.Tier__c ='Tier 1';
        queueUser2.TECH_QueueUser__c = queues2.Id;
        queueUser2.Business_Hours__c = bHours.Id;
        queueUser2.Out_Of_Office_Notification__c = true;
        insert queueUser2;
        
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        insert siteConR;
        siteConR.SiteNumber__c = 'SITE01';
        siteConR.Lab_Site_Number__c = 'LABSITE01';
        update siteConR;
        StudySiteContactRelationship__c siteConR2=new StudySiteContactRelationship__c(Study__c = study2.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR2.SiteNumber__c = 'SSCN121121';
        insert siteConR2;
        List<Case> csList = [select Id,AccountId,ContactId,ParentId,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase','ActivityPlan')];

        
        if(csList != null && csList.size() > 0){
            Case cse = csList[0];
            Case cseParent = csList[1];
            Test.startTest();
            cse.AccountId = null;
            cse.ContactId = null;
            cse.EntitlementId  =  ent2.Id;
            cse.ParentId  =  cseParent.Id;
            update cse;
            cse.AccountId = acc.Id;
            cse.ContactId = cnt.Id;
            cse.EntitlementId  =  null;
            update cse;
            Test.stopTest();    
        }
    }
    
    @IsTest
    static void testDataPortalUsersAssignment() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Account account = [SELECT Id,AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1].Id;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'DDD' LIMIT 1];
        Product2 product1 = [SELECT Id, Name FROM Product2 WHERE Name = 'Nexxus MI' LIMIT 1];
        Asset asset = [SELECT Id, Name FROM Asset WHERE AccountId = :account.Id AND Name = 'DDD' LIMIT 1];
        Asset asset1 = [SELECT Id, Name FROM Asset WHERE AccountId = :account.Id AND Name = 'Nexxus MI' LIMIT 1];
        System.runAs (usr) {
            String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
            
            BusinessHours bHours = [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours WHERE IsActive = true and name = 'Default' LIMIT 1];
            CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
            cc.Product__c= product1.Id;
            cc.SubType1__c = 'Incident-Module';
            cc.SubType2__c = 'Formula';  
            cc.SubType3__c = '--none--';
            cc.Type__c = 'Categorization';
            cc.Active__c = true;
            cc.Pillar__c = 'Technology Solutions';
            insert cc;
            
            Group g1 = new Group(Name='Tech CSM T2', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (UserOrGroupId = usr.Id,GroupId = g1.Id);
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User', Tier__c ='Tier 1',
                Enable_Round_Robin__c = true, Business_Hours__c = bHours.Id,
        Out_Of_Office_Notification__c = true,
                Group_Id__c = grpUser.groupId);           
            insert qur;
            
            GroupMember portalUser = new GroupMember ( UserOrGroupId = usr.Id,GroupId = g1.Id);
            insert portalUser;
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(
                Name = portalUser.group.Name,
                User__c = portalUser.UserOrGroupId,
                Type__c = 'Queue', Tier__c ='Tier 1', Business_Hours__c = bHours.Id,
        Out_Of_Office_Notification__c = true,
                Enable_Round_Robin__c = true,
                Group_Id__c = portalUser.groupId);
            insert qurPortal;
            
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = account.Id;
            dT.All_Current_Users__c = true;
            dT.AccountCountry__c = account.AccountCountry__c;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = account.Id;
            dd.All_Current_Users__c = true;
            dd.AccountCountry__c = account.AccountCountry__c;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            
            CSM_QI_Data_Portal_Queue_User_details__c dataPortal = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataPortal.Case_Subtype_3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)';
            dataPortal.Queue_User_Relationship__c =qurPortal.Id;
            dataPortal.CaseRecordType__c = 'DATACase';
            dataPortal.Type__c ='Queue Assignment';
            dataPortal.Order__c = 100;
            insert dataPortal;
            
            CSM_QI_Data_Portal_Queue_User_details__c dataTechno = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataTechno.Queue_User_Relationship__c = qurPortal.Id;
            dataTechno.Account__c = account.Id;
            dataTechno.All_Current_Users__c = true;
            dataTechno.AccountCountry__c = account.AccountCountry__c;
            dataTechno.CaseRecordType__c = 'TechnologyCase';
            dataTechno.Type__c ='Queue Assignment';
            dataTechno.Order__c = 1;
            insert dataTechno;
            
            ServiceNow_Group__c service = new ServiceNow_Group__c();
            service.Group_ID__c='EA-IQVIA';
            service.Name = 'EA-IQVIA';
            service.SystemType__c = 'IQVIA';
			service.Order__c = 1;
            insert service;
            
            CMDB__c cm = new CMDB__c();
            cm.Admin_Group_Name__c ='Admin';
            cm.Category__c = '1';
            cm.Name__c = '1';
            insert cm;
            
            CSM_QI_Data_Portal_Queue_User_details__c dataIVPTechno = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataIVPTechno.Queue_User_Relationship__c = qurPortal.Id;
            dataIVPTechno.Account__c = account.Id;
            dataIVPTechno.All_Current_Users__c = false;
            dataIVPTechno.AccountCountry__c = account.AccountCountry__c;
            dataIVPTechno.CaseRecordType__c = 'TechnologyCase';
            dataIVPTechno.Type__c ='Product Level Restriction';
            dataIVPTechno.Product__c ='Nexxus MI';
            dataIVPTechno.ProductId__c = product1.Id;
            dataIVPTechno.ServiceNow_Group__c = service.Id;
            dataIVPTechno.ServiceNow_Type__c = 'Incident';
            dataIVPTechno.ClientContact__c = conObjId;
            dataIVPTechno.CMDB__c = cm.Id;
            dataIVPTechno.Order__c = 2;
            insert dataIVPTechno;
            
            Test.startTest();
            User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = conObjId, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            insert user;
            
            CSM_QI_Case_Categorization__share ccSh = new CSM_QI_Case_Categorization__share();
            ccSh.ParentId = cc.Id;
            ccSh.UserOrGroupId = user.Id;
            ccSh.AccessLevel = 'Read';
            ccSh.RowCause='manual';
            Database.insert(ccSh,false);
            Queue_User_Relationship__share qurSh = new Queue_User_Relationship__share();
            qurSh.ParentId = qur.Id;
            qurSh.UserOrGroupId = user.Id;
            qurSh.AccessLevel = 'Read';
            qurSh.RowCause='manual';
            Database.insert(qurSh,false);
            Queue_User_Relationship__share qurPortalSh = new Queue_User_Relationship__share();
            qurPortalSh.ParentId = qurPortalSh.Id;
            qurPortalSh.UserOrGroupId = user.Id;
            qurPortalSh.AccessLevel = 'Read';
            qurPortalSh.RowCause='manual';
            Database.insert(qurPortalSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dTSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dTSh.ParentId = dT.Id;
            dTSh.UserOrGroupId = user.Id;
            dTSh.AccessLevel = 'Read';
            dTSh.RowCause='manual';
            Database.insert(dTSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share ddSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            ddSh.ParentId = dd.Id;
            ddSh.UserOrGroupId = user.Id;
            ddSh.AccessLevel = 'Read';
            ddSh.RowCause='manual';
            Database.insert(ddSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dataPortalSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dataPortalSh.ParentId = dataPortal.Id;
            dataPortalSh.UserOrGroupId = user.Id;
            dataPortalSh.AccessLevel = 'Read';
            dataPortalSh.RowCause='manual';
            Database.insert(dataPortalSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dataTechnoSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dataTechnoSh.ParentId = dataTechno.Id;
            dataTechnoSh.UserOrGroupId = user.Id;
            dataTechnoSh.AccessLevel = 'Read';
            dataTechnoSh.RowCause='manual';
            Database.insert(dataTechnoSh,false);
            ServiceNow_Group__Share serviceSh = new ServiceNow_Group__Share();
            serviceSh.ParentId = service.Id;
            serviceSh.UserOrGroupId = user.Id;
            serviceSh.AccessLevel = 'Read';
            serviceSh.RowCause='manual';
            Database.insert(serviceSh,false);
            CMDB__Share cmSh = new CMDB__Share();
            cmSh.ParentId = cm.Id;
            cmSh.UserOrGroupId = user.Id;
            cmSh.AccessLevel = 'Read';
            cmSh.RowCause='manual';
            Database.insert(cmSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dataIVPTechnoSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dataIVPTechnoSh.ParentId = dataIVPTechno.Id;
            dataIVPTechnoSh.UserOrGroupId = user.Id;
            dataIVPTechnoSh.AccessLevel = 'Read';
            dataIVPTechnoSh.RowCause='manual';
            Database.insert(dataIVPTechnoSh,false);
            system.runAs(user){
                User u = [Select Id,UserType from User where id = :user.Id limit 1];
                Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
                Id RecordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
                List<Case> csList = new List<Case>();
                /*Account accountCommunity = UTL_TestData.createAccount();
                accountCommunity.ownerId=user.Id;
                accountCommunity.AccountCountry__c = 'FR';
                accountCommunity.Name = 'France Test Account';
                insert accountCommunity;
                Contact contactCommunity = new Contact( 
                    Firstname='Brian', 
                    Lastname='Lara', 
                    Phone='(619)852-4570', 
                    Department='Mission Control', 
                    Title='Mission Specialist - Mercury', 
                    Email='lara.brian@acme.com',
                    Portal_Case_Type__c = 'Information Offering; Technology Solutions',
                    Contact_User_Type__C = 'Ho User',PreferredLanguage__c = 'en_US',
                    AccountId = accountCommunity.Id);
                insert contactCommunity;*/

                Case c = new Case(
                    AccountId = account.Id,
                    ContactId = conObjId,
                    AssetId = asset.Id,
                    Origin = 'Customer Portal',
                    Status = 'New',
                    AssignCaseToCurrentUser__c = false,
                    SubType3__c='LOOK-UP, PRESCRIBER (1-20 COUNT)',
                    OwnerId = qurPortal.Group_Id__c,
                    RecordTypeId = RecordTypeIdCase
                    //CurrentQueue__c = qurPortal.Id
                );
                csList.add(c);
                
                Case c1 = new Case(
                    AccountId = account.Id,
                    ContactId = conObjId,
                    AssetId = asset1.Id,
                    Origin = 'Customer Portal',
                    Status = 'New',
                    Subject = 'TestCaseMacro',
                    Priority = 'Priority 4',
                    AssignCaseToCurrentUser__c = false,
                    OwnerId = qurPortal.Group_Id__c,
                    Owner__c = qurPortal.Group_Id__c,
                    RecordTypeId = RecordTypeIdTechno
                    //CurrentQueue__c = qurPortal.Id
                );
                csList.add(c1);
                insert csList;
            }
            /*Case c2 = [select id,ProductName__c,SubType1__c,SubType2__c,SubType3__c From Case where Subject = 'TestCaseMacro'];
              QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
              req.setQuickActionName('Case.Macros_Only');
              c2.ProductName__c= 'Nexxus MI';
              c2.SubType1__c = 'Incident-Module';
              c2.SubType2__c = 'Formula';  
              c2.SubType3__c = '--none--';
              req.record = c2;
              QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);*/
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testDataPortalUserCaseCreate() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Account account = [SELECT Id,AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1].Id;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'DDD' LIMIT 1];
        Product2 product1 = [SELECT Id, Name FROM Product2 WHERE Name = 'Nexxus MI' LIMIT 1];
        Asset asset = [SELECT Id, Name FROM Asset WHERE AccountId = :account.Id AND Name = 'DDD' LIMIT 1];
        Asset asset1 = [SELECT Id, Name FROM Asset WHERE AccountId = :account.Id AND Name = 'Nexxus MI' LIMIT 1];
        System.runAs (usr) {
            String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
            
            
            CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
            cc.Product__c= product1.Id;
            cc.SubType1__c = 'Incident-Module';
            cc.SubType2__c = 'Formula';  
            cc.SubType3__c = '--none--';
            cc.Type__c = 'Categorization';
            cc.Active__c = true;
            cc.Pillar__c = 'Technology Solutions';
            insert cc;
            
            Group g1 = new Group(Name='Tech CSM T2', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (UserOrGroupId = usr.Id,GroupId = g1.Id);
            insert grpUser;
            BusinessHours bHours1 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User', Tier__c ='Tier 1',Business_Hours__c = bHours1.Id,
                Out_Of_Office_Notification__c = true,
                Enable_Round_Robin__c = true,
                Group_Id__c = grpUser.groupId);           
            insert qur;
            
            GroupMember portalUser = new GroupMember ( UserOrGroupId = usr.Id,GroupId = g1.Id);
            insert portalUser;
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(
                Name = portalUser.group.Name,
                User__c = portalUser.UserOrGroupId,
                Type__c = 'Queue', Tier__c ='Tier 1',Business_Hours__c = bHours1.Id,
                Out_Of_Office_Notification__c = true,
                Enable_Round_Robin__c = true,
                Group_Id__c = portalUser.groupId);
            insert qurPortal;
            
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = account.Id;
            dT.All_Current_Users__c = true;
            dT.AccountCountry__c = account.AccountCountry__c;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = account.Id;
            dd.All_Current_Users__c = true;
            dd.AccountCountry__c = account.AccountCountry__c;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            
            CSM_QI_Data_Portal_Queue_User_details__c dataPortal = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataPortal.Case_Subtype_3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)';
            dataPortal.Queue_User_Relationship__c =qurPortal.Id;
            dataPortal.CaseRecordType__c = 'DATACase';
            dataPortal.Type__c ='Queue Assignment';
            dataPortal.Order__c = 100;
            insert dataPortal;
            
            CSM_QI_Data_Portal_Queue_User_details__c dataTechno = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataTechno.Queue_User_Relationship__c = qurPortal.Id;
            dataTechno.Account__c = account.Id;
            dataTechno.All_Current_Users__c = true;
            dataTechno.AccountCountry__c = account.AccountCountry__c;
            dataTechno.CaseRecordType__c = 'TechnologyCase';
            dataTechno.Type__c ='Queue Assignment';
            dataTechno.Order__c = 1;
            insert dataTechno;
            
            ServiceNow_Group__c service = new ServiceNow_Group__c();
            service.Group_ID__c='EA-IQVIA';
            service.Name = 'EA-IQVIA';
            service.SystemType__c = 'IQVIA';
			service.Order__c = 1;
            insert service;
            
            CMDB__c cm = new CMDB__c();
            cm.Admin_Group_Name__c ='Admin';
            cm.Category__c = '1';
            cm.Name__c = '1';
            insert cm;
            
            CSM_QI_Data_Portal_Queue_User_details__c dataIVPTechno = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataIVPTechno.Queue_User_Relationship__c = qurPortal.Id;
            dataIVPTechno.Account__c = account.Id;
            dataIVPTechno.All_Current_Users__c = false;
            dataIVPTechno.AccountCountry__c = account.AccountCountry__c;
            dataIVPTechno.CaseRecordType__c = 'TechnologyCase';
            dataIVPTechno.Type__c ='Product Level Restriction';
            dataIVPTechno.Product__c ='Nexxus MI';
            dataIVPTechno.ProductId__c = product1.Id;
            dataIVPTechno.ServiceNow_Group__c = service.Id;
            dataIVPTechno.ServiceNow_Type__c = 'Incident';
            dataIVPTechno.ClientContact__c = conObjId;
            dataIVPTechno.CMDB__c = cm.Id;
            dataIVPTechno.Order__c = 2;
            insert dataIVPTechno;
            
            Test.startTest();
            User user = New User(Alias = 'c1om', Email = 'john1231@acme.com',IsActive =true , ContactId = conObjId, ProfileId = profilId,Username =' john11@acme.com', LastName= 'test132LastName', CommunityNickname ='test11munityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            insert user;
            
            CSM_QI_Case_Categorization__share ccSh = new CSM_QI_Case_Categorization__share();
            ccSh.ParentId = cc.Id;
            ccSh.UserOrGroupId = user.Id;
            ccSh.AccessLevel = 'Read';
            ccSh.RowCause='manual';
            Database.insert(ccSh,false);
            Queue_User_Relationship__share qurSh = new Queue_User_Relationship__share();
            qurSh.ParentId = qur.Id;
            qurSh.UserOrGroupId = user.Id;
            qurSh.AccessLevel = 'Read';
            qurSh.RowCause='manual';
            Database.insert(qurSh,false);
            Queue_User_Relationship__share qurPortalSh = new Queue_User_Relationship__share();
            qurPortalSh.ParentId = qurPortalSh.Id;
            qurPortalSh.UserOrGroupId = user.Id;
            qurPortalSh.AccessLevel = 'Read';
            qurPortalSh.RowCause='manual';
            Database.insert(qurPortalSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dTSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dTSh.ParentId = dT.Id;
            dTSh.UserOrGroupId = user.Id;
            dTSh.AccessLevel = 'Read';
            dTSh.RowCause='manual';
            Database.insert(dTSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share ddSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            ddSh.ParentId = dd.Id;
            ddSh.UserOrGroupId = user.Id;
            ddSh.AccessLevel = 'Read';
            ddSh.RowCause='manual';
            Database.insert(ddSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dataPortalSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dataPortalSh.ParentId = dataPortal.Id;
            dataPortalSh.UserOrGroupId = user.Id;
            dataPortalSh.AccessLevel = 'Read';
            dataPortalSh.RowCause='manual';
            Database.insert(dataPortalSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dataTechnoSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dataTechnoSh.ParentId = dataTechno.Id;
            dataTechnoSh.UserOrGroupId = user.Id;
            dataTechnoSh.AccessLevel = 'Read';
            dataTechnoSh.RowCause='manual';
            Database.insert(dataTechnoSh,false);
            ServiceNow_Group__Share serviceSh = new ServiceNow_Group__Share();
            serviceSh.ParentId = service.Id;
            serviceSh.UserOrGroupId = user.Id;
            serviceSh.AccessLevel = 'Read';
            serviceSh.RowCause='manual';
            Database.insert(serviceSh,false);
            CMDB__Share cmSh = new CMDB__Share();
            cmSh.ParentId = cm.Id;
            cmSh.UserOrGroupId = user.Id;
            cmSh.AccessLevel = 'Read';
            cmSh.RowCause='manual';
            Database.insert(cmSh,false);
            CSM_QI_Data_Portal_Queue_User_details__Share dataIVPTechnoSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dataIVPTechnoSh.ParentId = dataIVPTechno.Id;
            dataIVPTechnoSh.UserOrGroupId = user.Id;
            dataIVPTechnoSh.AccessLevel = 'Read';
            dataIVPTechnoSh.RowCause='manual';
            Database.insert(dataIVPTechnoSh,false);
            system.runAs(user){
                User u = [Select Id,UserType from User where id = :user.Id limit 1];
                Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
                Case c = new Case(
                    AccountId = account.Id,
                    ContactId = conObjId,
                    AssetId = asset.Id,
                    Origin = 'Customer Portal',
                    Status = 'New',
                    AssignCaseToCurrentUser__c = false,
                    SubType3__c='LOOK-UP, PRESCRIBER (1-20 COUNT)',
                    OwnerId = qurPortal.Group_Id__c,
                    RecordTypeId = RecordTypeIdCase
                    //CurrentQueue__c = qurPortal.Id
                );
                insert c;
            }
            
            Test.stopTest();
        }
    }
    public testmethod static void TestChildCaseCreateFromChildCase() {
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Id caseId;
        Case parent =  [SELECT Id,CaseNumber,Origin From Case where Subject = 'Parent Case' Limit 1];
        List<Case> csList = [select Id,CurrentQueue__c,RecordTypeName__c,ParentId,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where Subject != 'Parent Case' and RecordTypeName__c in ('RandDCase','ActivityPlan')];
        List<Case> csUp = new List<Case>();
        if(csList != null && csList.size() > 0){
            for(Case cs : csList){
                if(cs.RecordTypeName__c == 'RandDCase' && cs.ParentId == null){
                    cs.ParentId = parent.Id;  
                    caseId = cs.Id;
                    csUp.add(cs);
                }
            }
            
            for(Case cs : csList){
                if(cs.RecordTypeName__c == 'ActivityPlan' && cs.ParentId == null){
                    cs.ParentId = caseId;
                    csUp.add(cs);
                }
            }
        }
    
        Test.startTest();
        try{
            update csUp;
        }catch(System.DmlException ex){
            
        }
        Test.stopTest();
        
    }
    
    public testmethod static void TestChildCaseCreate() {
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Account acct1 = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount2' LIMIT 1];
        Account acct2 = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1];  
        Study__c study = [SELECT Id FROM Study__c WHERE Name = 'STUDY12' AND Sponsor__c =: acct2.Id];
        Contact con = [SELECT Id, Name, PreferredLanguage__c FROM Contact WHERE AccountId =: acct.Id][0];
        User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='group name', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'Queue', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            Queue_User_Relationship__c qur1 = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = grpUser.group.Id);
            
            insert qur1;
            
            
            Entitlement ent = new Entitlement(Name='Testing', AccountId=acct2.Id,Type = 'R_D',
                                              BusinessHoursId = busId.Id,
                                              StartDate=Date.valueof(System.now().addDays(-2)), 
                                              EndDate=Date.valueof(System.now().addYears(2)));
            insert ent;
            
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Study__c =study.Id,
                AssignCaseToCurrentUser__c = false,
                Sponsor__c = acct2.Id,   
                Origin = 'Email',
                Status = 'New',
                RandD_Location__c = 'Dalian',
                OwnerId = u.Id,
                RecordTypeId = RecordTypeIdCase
            );
            try{
                insert c;  
            }catch (DmlException e) {
                System.debug('Failed to Insert :'+e);
            }
            Test.startTest();
            /* Commented */
            Case c1 = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Study__c =study.Id,
                Sponsor__c = acct2.Id,
                Origin = 'Email',
                AssignCaseToCurrentUser__c = false,
                Status = 'New',
                RandD_Location__c = 'Dalian',
                OwnerId = u.Id,
                CurrentQueue__c = qur.Id,
                ParentId = c.Id,
                RecordTypeId = RecordTypeIdCase
            );
            insert c1;
            Test.stopTest();
        }
    }
    
    static testMethod void testCaseUpdation(){
        List<Case> updatecaselist = [SELECT Id, Status, Case_Type__c, Origin FROM Case];
        Integer index = 0;
        for(Case cse : updatecaselist){
            if(index < updatecaselist.size()-1 && cse.Case_Type__c != 'Problem'){
                cse.Status = 'Resolved with Customer';
                index++;
            }
        }
        
        Test.startTest();
            update updatecaselist;
        Test.stopTest();
    }

    @isTest
    static void testRestrictClosedCaseModificationAsSystemAdmin(){
        User adminUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        List<Case> caseList = [SELECT Id, Priority, Case_Type__c, Origin,RecordTypeName__c FROM Case];
        for(Case caseRecord : caseList){
            if(caseRecord.Case_Type__c != 'Problem'){
                caseRecord.Force_CSAT_Email_Survey__c = true;
                caseRecord.Status = 'Closed';
            }
        }
        update caseList;
        
        Test.startTest();
        System.runAs(adminUser){
            DAOH_Case.isCaseUpdated = FALSE;
            for(Case caseRecord : caselist){
                if(CON_CSM.S_TECHNOLOGY_R_T == caseRecord.RecordTypeName__c){
                    caseRecord.Priority = 'Priority 3';
                }else{
                    caseRecord.Priority = 'Medium';
                }
                caseRecord.Origin = 'Customer Portal';
            }
            update caseList;
        }
        Test.stopTest();
    }
    
    @isTest
    static void testRestrictClosedCaseModificationAsServiceUser(){
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        Account accountRecord = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        Asset assetRecord = [SELECT Id FROM Asset WHERE Name = 'DDD' AND AccountId = :accountRecord.Id LIMIT 1];
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queueUserRelation = new Queue_User_Relationship__c(Name = 'Q1', Tier__c ='Tier 1', Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,User__c = serviceUser.Id, Type__c = 'User');
        insert queueUserRelation;
        Id dataRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Case caseRecord = CSM_TestDataFactory.createClosedCase(accountRecord.Id, dataRecordTypeId, null, TRUE, 'Customer Portal', 'Techno case', 'Test class to check case creation',
                                                                   serviceUser.Id, 'Closed', 'Dummy Text', 'CLIENT - DATA QUERY NOT VALID', assetRecord.Id, FALSE, queueUserRelation.Id);
        insert caseRecord;
        Test.setCreatedDate(caseRecord.Id, DateTime.newInstance(2012,12,12));
        
        Test.startTest();
            System.runAs(serviceUser){
                  DAOH_Case.isCaseUpdated = FALSE;
                caseRecord.Priority = 'High';
                caseRecord.Origin = 'Chat';                
                try{
                    UPDATE caseRecord;
                }
                catch(Exception ex){
                    Boolean expectedExceptionThrown = ex.getMessage().contains('You can\'t update/modify the case fields') ? true : false;
                    System.assertEquals(expectedExceptionThrown, true);
                }
            }
        Test.stopTest();
    }
    
    static testMethod void web2caseCreation(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        accOwner.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert accOwner;
        
        System.runAs (accOwner) {
        List<Asset> assets = new List<Asset>();
           Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            
            Product2 product = UTL_TestData.createProduct();
            product.Name = 'DDD';
            product.SpecificToCSM__c = True;
            insert product;
            BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
                    
            Asset asset = new Asset(Name = 'DDD', AccountId = account.Id, Product2Id = product.id);
            insert asset;
            
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='john@acme.com',
            Portal_Case_Type__c = 'Information Offering',
            PreferredLanguage__c = 'en_US',
            AccountId = account.Id);
        insert contact;
        Group g1 = new Group(Name='group name', type='Queue', DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = accOwner.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            
            GroupMember portalUser = new GroupMember (
                UserOrGroupId = UserInfo.getUserId(),
                GroupId = g1.Id);
            
            insert portalUser;
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(
                Name = portalUser.group.Name,
                User__c = portalUser.UserOrGroupId,
                Type__c = 'User', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = portalUser.groupId);
            insert qurPortal;
            
        CSM_Case_Details_Global_Setting__c custsettObj1 = new CSM_Case_Details_Global_Setting__c();
        custsettObj1.Name = 'ONEKEY WEB - ORGANIZATIONS';
        custsettObj1.Component_Id__c = asset.Id;
        custsettObj1.Other_Details__c = 'ORGANIZATIONS-Asset';
        insert custsettObj1;
        CSM_Case_Details_Global_Setting__c custsettObj3 = new CSM_Case_Details_Global_Setting__c();
        custsettObj3.Name = 'Data US ORGANIZATIONAL DB MGT';
        custsettObj3.Setting_Type__c = g1.Id;
        //custsettObj3.Component_Id__c = 'a0Km0000003kOzBEAU';
        custsettObj3.Other_Details__c = 'ORGANIZATIONS-Queue';
        insert custsettObj3;    
        
        Test.startTest();
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            
            Case c = new Case(
                AccountId = account.Id,
                Subject = 'Test Subject',
                Description = 'Test Subject',
                Origin = 'Web',
                AssignCaseToCurrentUser__c = false,
                SuppliedEmail = 'john@acme.com',
                HCRSWebID__c = 'ORGANIZATIONS',
                Status = 'New',
                RecordTypeId = RecordTypeIdCase
            );
            insert c;
        
        Test.stopTest();
        }
    }

    static testMethod void web2caseCreationProf(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        accOwner.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert accOwner;
        System.runAs (accOwner) {
        List<Asset> assets = new List<Asset>();
           Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            account.AccountCountry__c = 'IN';
            insert account;
            
            Product2 product = UTL_TestData.createProduct();
            product.Name = 'DDD';
            product.SpecificToCSM__c = True;
            insert product;
            BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
                    
            Asset asset = new Asset(Name = 'DDD', AccountId = account.Id, Product2Id = product.id);
            insert asset;
            
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='john@acme.com',
            Portal_Case_Type__c = 'Information Offering',
            PreferredLanguage__c = 'en_US',
            AccountId = account.Id);
        insert contact;
        Group g1 = new Group(Name='group name', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = accOwner.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            
            GroupMember portalUser = new GroupMember (
                UserOrGroupId = UserInfo.getUserId(),
                GroupId = g1.Id);
            
            insert portalUser;
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(
                Name = portalUser.group.Name,
                User__c = portalUser.UserOrGroupId,
                Type__c = 'User', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = portalUser.groupId);
            insert qurPortal;
            CSM_Case_Details_Global_Setting__c custsettObj1 = new CSM_Case_Details_Global_Setting__c();
            custsettObj1.Name = 'ONEKEY WEB - PROFESSIONALS';
            custsettObj1.Component_Id__c = asset.Id;
            custsettObj1.Other_Details__c = 'PROFESSIONALS-Asset';
            insert custsettObj1;
            CSM_Case_Details_Global_Setting__c custsettObj3 = new CSM_Case_Details_Global_Setting__c();
            custsettObj3.Name = 'Data US ORGANIZATIONAL DB MGT';
            custsettObj3.Setting_Type__c = g1.Id;
            //custsettObj3.Component_Id__c = 'a0Km0000003kOzBEAU';
            custsettObj3.Other_Details__c = 'PROFESSIONALS-Queue';
            insert custsettObj3;    
            
            
        Test.startTest();
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            
            Case c = new Case(
                AccountId = account.Id,
                Subject = 'Test Subject',
                Description = 'Test Subject',
                Origin = 'Web',
                AssignCaseToCurrentUser__c = false,
                SuppliedEmail = 'john@acme.com',
                HCRSWebID__c = 'PROFESSIONALS~PRO001',
                Status = 'New',
                RecordTypeId = RecordTypeIdCase
            );
            insert c;
        Case clonedCase = c.clone(false, false, false, false);
        Test.stopTest();
        }
    }
    @isTest
    static void testPopulateChildCaseWithAsset(){
        Account accountRecord = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        Contact contactRecord = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Study__c studyRecord = [SELECT Id FROM Study__c WHERE Name = 'STUDY12'];
        Asset assetRecord = [SELECT Id FROM Asset WHERE Name = 'DDD' AND AccountId = :accountRecord.Id LIMIT 1];
        Asset assetRecord2 = [SELECT Id FROM Asset WHERE Name = 'Nexxus MI' AND AccountId = :accountRecord.Id LIMIT 1];
        Id dataRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Queue_User_Relationship__c queues1 = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' AND Type__c = 'Queue'];
        Queue_User_Relationship__c queueUser1 = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' AND Type__c = 'User'];
        
        List<Case> listCase = new List<Case>();
        Case parentCaseRecord = CSM_TestDataFactory.createCase(accountRecord.Id, contactRecord.Id, dataRecordTypeId, assetRecord.Id, 'Email', null, null, null, queueUser1.Id);
        listCase.Add(parentCaseRecord);
        
        Case parentCaseRecord2 = CSM_TestDataFactory.createCase(accountRecord.Id, contactRecord.Id, dataRecordTypeId, assetRecord.Id, 'Chat', null, null, null, queueUser1.Id);
        listCase.Add(parentCaseRecord2);
        insert listCase;
        
        Case childCaseRecord = CSM_TestDataFactory.createCase(accountRecord.Id, contactRecord.Id, dataRecordTypeId, null, 'Customer Portal', parentCaseRecord.Id, 'Provide asset to child record', null, queueUser1.Id);
        
        Test.startTest();
        try{
            insert childCaseRecord;
            childCaseRecord = [Select Id, AssetId FROM Case WHERE Id =: ChildCaseRecord.Id];
            system.assertEquals(childCaseRecord.AssetId, parentCaseRecord.AssetId);
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();
    }
   @isTest
   static void testSetCalendarEvent(){
       Id techRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
       User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
       Account accountRecord = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
       BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
       Queue_User_Relationship__c queueUserRelation = new Queue_User_Relationship__c(Name = 'Q1', User__c = serviceUser.Id, Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Type__c = 'User', Tier__c ='Tier 1');
       INSERT queueUserRelation;
       
       Case CaseRecord = new Case(
                AccountId = accountRecord.Id,
                Subject = 'Test Subject',
                Description = 'Test Subject',
                Origin = 'Agent Initiated',
                NoContactKnown__c = true,
                Status = 'Awaiting',
                SubStatus__c = 'Schedule',
                ScheduledDatetime__c = System.now(),
                OwnerId = serviceUser.Id,
                AssignCaseToCurrentUser__c = false,
                CurrentQueue__c = queueUserRelation.id,
                RecordTypeId = techRecordTypeId
            );
       INSERT CaseRecord;
       ID caseID = CaseRecord.id;
       Case caseDetails =[Select CaseNumber,Owner.eMail, SubStatus__c,ScheduledDatetime__c,Subject ,Description,Account_Name_Article__c from case where ID = :caseID ];
       List<Case> caseList =new List<Case>();
       caseList.add(caseDetails);
      
       System.runAs (serviceUser) {  
          
       Test.startTest();
       try{
           DAOH_Case.SetCalendarEvent(caseList,null); 
       }
       catch(Exception ex){
           ex.getMessage();
       }
       Test.stopTest();
   }      
 }
  
   @isTest
   static void testGenerateEvent(){       
       Id techRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
       List<Case> listCase = new List<Case>();
       listCase= [Select Subject ,ScheduledDatetime__c,Description from Case where RecordTypeName__c = 'TechnologyCase' LImit 1];
       if(listCase.size()>0){
       listCase[0].ScheduledDatetime__c = system.now();
       listCase[0].Description = 'Description';
       listCase[0].Subject ='Sub';
       Test.startTest();
       update listCase;
       listCase = [Select Subject, Description , ScheduledDatetime__c from case where  RecordTypeName__c = 'TechnologyCase'];
       EXT_CSM_CalendarEvent.ext_GenerateEvent('Akansha.gupta@metacube.com', 'summary', listCase[0].Description, listCase[0].ScheduledDatetime__c, listCase[0].ScheduledDatetime__c, listCase[0].Subject, 0);
       Test.stopTest();
       }
   }
    
    @isTest
    static void testSetFirstEscalationTimeField(){
        Id techRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        List<Case> caseList = [SELECT Id, CaseNumber, Subject, IsEscalated FROM Case WHERE RecordTypeId = :techRecordTypeId];
        for(Case caseRecord : caseList){
            caseRecord.IsEscalated = true;
        }
        
        Test.startTest();
        try{
            update caseList;
            Case caseRecord = [SELECT Id, IsEscalated FROM Case WHERE RecordTypeId = :techRecordTypeId LIMIT 1];
            System.assertEquals(true, caseRecord.IsEscalated);
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();
    }

    @isTest
    static void testTickStoppedCheckboxToPauseEntitlement(){
        List<Case> caseList = [SELECT Id, caseNumber FROM Case WHERE status = 'New'];
        for(Case caseRecord : caseList){
            caseRecord.Status = 'Waiting for';
            caseRecord.SubStatus__c = 'Customer';
        }
        
        Test.startTest();
        try{
            update caseList;
            Case caseRecord = [SELECT Id, IsStopped FROM CASE WHERE status = 'Waiting for' and substatus__c = 'Customer' LIMIT 1];
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendAutomatedFollowUp(){
        
        CSM_AFU_EMAIL_TEMPLATE__c emailTemplates = new CSM_AFU_EMAIL_TEMPLATE__c();
        emailTemplates.AFU_No_Response_TemplateID__c = '00X6A000000IrlC';
        emailTemplates.AFU_Follow_Up_TemplateID__c = '00X6A000000IrlB';
        insert emailTemplates;
        
        CSM_ReplyTo_Email__c setting = new CSM_ReplyTo_Email__c();
        setting.Name = 'ReplyToEmail';
        setting.Reply_To_Email_Address__c = 'noreply@dummyemail.com';
        insert setting;
        
        List<Case> testCasesList = new List<Case>();
        List<Case> listOfCase = [SELECT Id, Status,From_emailtocase__c, recordTypeID,AFU_Email_Flag__c,AFU_TECH__c,Count_of_AFU__c,ContactEmail,ContactId
            FROM Case LIMIT 4];
        Integer count = 1;
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id RecordTypeId2 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        for(Case objCase : listOfCase){                       
            if(count == 1){               
                objCase.AFU_TECH__c = true;
                objCase.RecordTypeId = RecordTypeId1;
                objCase.Status = 'In Progress';
                objCase.Count_of_AFU__c = 4;
                objCase.AFU_Email_Flag__c = true;
            }
            else if(count == 2){
                objCase.AFU_TECH__c = false;
                objCase.RecordTypeId = RecordTypeId1;
                objCase.Status = 'In Progress';
                
            }
            else if(count == 3){
                objCase.AFU_TECH__c = false;
                objCase.RecordTypeId = RecordTypeId2;
                objCase.Status = 'In Progress';
            }
            else if(count == 4){
                objCase.AFU_TECH__c = true;
                objCase.RecordTypeId = RecordTypeId2;
                objCase.Status = 'In Progress';
            }
            count = count + 1;
            testCasesList.add(objCase);
        }
        
        Test.startTest();
        try{
            DAOH_Case.sendAutomatedFollowUp(testCasesList);
            testCasesList[0].AFU_TECH__c = TRUE;
            testCasesList[0].Status = 'Closed';
            testCasesList[0].Force_CSAT_Email_Survey__c = true;
            update testCasesList;
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();        
    }
    @isTest
    static void testSetFieldForData(){
        List<Case> listCase = new List<Case>();
        listCase= [Select Subject ,CaseNumber,SubType1__c from Case where RecordTypeName__c = 'DATACase' LImit 1];
        if(listCase.size()>0){ 
            listCase[0].Subject = 'SERVICE';
        }
        Test.startTest();
        try{
            DAOH_Case.setFieldForData(listCase);
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckFCRWhenCaseIsCreatedAsClosed() {
        Account myAcc = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        Contact cont = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: myAcc.Id][0];
        User u = [Select id from User where Id =: UserInfo.getUserId()];
        Queue_User_Relationship__c queues = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' AND Name = 'Q1'];
    
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Case c = new Case(
            Force_CSAT_Email_Survey__c = true,
            AccountId = myAcc.Id
            , ContactId = cont.Id
            , Origin = 'Chat'
            , Status = 'Closed'
            , CurrentQueue__c = queues.Id
            , AssignCaseToCurrentUser__c = false
            , InitialQueue__c = 'Q1'
            , OwnerId = u.Id,   
            Priority = 'Priority 4',
            RecordTypeId = RecordTypeIdCase
        );
        
        Test.startTest();
            insert c;
            c = [SELECT FirstCallResolution__c FROM
                Case WHERE AccountId =: myAcc.Id LIMIT 1];
        
            //System.assertEquals(true, c.FirstCallResolution__c);
            c.IsEscalated = true;
            update c;
        Test.stopTest();
    }
    
    @isTest
    static void testCheckSpecialHandlingClient() {
        
        Account myAcc = new Account(Name = 'TestAct', phone = '1001231234', RDCategorization__c = 'Site', IsThisASpecialHandlingClient__c = true,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert myAcc;
        Account secAcc = new Account(Name = 'SecAct', phone = '1001231234', RDCategorization__c = 'Site', IsThisASpecialHandlingClient__c = false,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert secAcc;
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone = '4567890999', accountid = myAcc.id,PreferredLanguage__c = 'en_US');
        insert cont;
        Contact contSec = new Contact(FirstName = 'TestSed', LastName = 'LastNameSec', phone = '4567890999', accountid = secAcc.id,PreferredLanguage__c = 'en_US');
        insert contSec;
        User u = [Select id from User where Id =: UserInfo.getUserId()];
        
        Queue_User_Relationship__c queues = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' AND Name = 'Q1'];
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Test.startTest();
        Case c = new Case(
            AccountId = myAcc.Id
            , ContactId = cont.Id
            , Origin = 'Chat'
            , Status = 'New'
            , AssignCaseToCurrentUser__c = false
            , InitialQueue__c = 'Q1'
            , OwnerId = u.Id
            , RecordTypeId = RecordTypeIdCase
        );
        insert c;
        Case resultPostive = [select IsThisASpecialHandlingClient__c from case where AccountId =: myAcc.Id Limit 1];
        System.assertEquals(true, resultPostive.IsThisASpecialHandlingClient__c);
        c.AccountId = secAcc.Id;
        c.ContactId = contSec.Id;
        update c;
        Case resultNegative = [select IsThisASpecialHandlingClient__c from case where AccountId =: secAcc.Id Limit 1];
        System.assertEquals(false, resultNegative.IsThisASpecialHandlingClient__c);
        Test.stopTest();
        
    }
    
    @isTest
    static void testReOpenedClosedCase() {
        Account myAcc = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        Contact cont = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: myAcc.Id][0];
        User u = [Select id from User where Id =: UserInfo.getUserId()];
        Queue_User_Relationship__c queues = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' AND Name = 'Q1'];
    
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Test.startTest();
        Case c = new Case(Force_CSAT_Email_Survey__c = true,
            AccountId = myAcc.Id
            , ContactId = cont.Id
            , Origin = 'Chat'
            , Status = 'Closed'
            , CurrentQueue__c = queues.Id
            , AssignCaseToCurrentUser__c = false
            , InitialQueue__c = 'Q1'
            , OwnerId = u.Id
            , RecordTypeId = RecordTypeIdCase
        );
        insert c;   
    
        List < Case > caseList = [SELECT Id, Priority, Origin, Status FROM Case where id =: c.id limit 1];
        for (Case caseRecord: caseList) {
            caseRecord.Status = 'Acknowledged';
        }
       
        update caseList;
        Case updateCase = [select ReOpened__c, ReOpenDate__c, ReOpener__c from
            case where Id =: caseList[0].Id];
        System.assertEquals(true, updateCase.ReOpened__c);
        System.assertEquals(UserInfo.getName(), updateCase.ReOpener__c);
        System.assertEquals(Date.today(), updateCase.ReOpenDate__c);
        Test.stopTest();
    }
     @isTest
    static void testUnCheckFCRWhenCaseIsReopened() {
        Case c = [SELECT Id, AccountId, RecordTypeName__c, ClosedDate, FirstCallResolution__c, ReOpened__c, IsEscalated, Status FROM Case WHERE RecordTypeName__c = 'TechnologyCase' LIMIT 1];

        Test.startTest();
        c.FirstCallResolution__c = true;
        c.ReOpened__c = true;
        c.status = 'New';
        update c;
    
        c = [SELECT FirstCallResolution__c FROM Case WHERE Id =: c.Id Limit 1];
        System.assertEquals(false, c.FirstCallResolution__c);
        Test.stopTest();
    }
    @isTest
    static void testsetAssetBlankForData() {
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        System.runAs (serviceUser) {  
        List<Case> caseList = [SELECT Id, CaseNumber, Subject,AccountID,CurrentQueue__c, IsEscalated FROM Case WHERE RecordTypeId = :RecordTypeIdCase];  
        Test.startTest();
        try{
            if(caseList.size()>0){
            Case c = new Case(
            AccountId = caseList[0].AccountID
            ,Origin = 'Chat'
            , Status = 'New'
            , CurrentQueue__c = caseList[0].CurrentQueue__c
            , AssignCaseToCurrentUser__c = false
            , InitialQueue__c = caseList[0].CurrentQueue__c
            , OwnerId = serviceUser.Id
            ,ParentId = caseList[0].id
            , RecordTypeId = RecordTypeIdCase
        );
           
        insert c;
               case caseData =[Select AccountId ,AssetId from Case where id =:c.id];
               if(caseList[0].AccountId != caseData.AccountId){
                   System.assertEquals(NUll, caseData.AssetId);
               }
               else{
                   System.assertEquals(caseList[0].AssetId, caseData.AssetId);
                   }
                   
            } 
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();
        }
    }
    
    @IsTest
    static void testCheckFCRWhenCaseIsClosedWithInOneHour() {
        Account myAcc = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        Contact cont = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: myAcc.Id][0];
    
        Queue_User_Relationship__c queues = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' AND Name = 'Q1'];
        Queue_User_Relationship__c queueUser = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'User' AND Name = 'Q1'];
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        
        Case caseRecord = CSM_TestDataFactory.createClosedCase(myAcc.Id, RecordTypeIdCase, cont.Id, FALSE, 'Agent Initiated', 'Techno case', 'Test class to check case creation',
                                                                   UserInfo.getUserId(), 'Closed', 'Dummy Text', 'CLIENT - DATA QUERY NOT VALID', null, FALSE, queueUser.Id);
        caseRecord.Force_CSAT_Email_Survey__c = true;
        insert caseRecord;
        
        Test.startTest();
            caseRecord.Subject = 'Closed Update';
            caseRecord.FirstCallResolution__c = false;
            update caseRecord;
        
            Case updatedCase = [select FirstCallResolution__c from case where Id =: caseRecord.Id];
            //System.assertEquals(true, updatedCase.FirstCallResolution__c);
        Test.stopTest();
    }
    
    static testMethod void TestcompleteRDCaseMilestone(){
        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestAct', phone='1001231234', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(myAcc);
        Account busAcc = new Account(Name = 'TestForMS', phone='4567890999', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(busAcc);
        insert acts;
        
        Account acct2 = new Account(Name = 'TestAcc2',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;
        Study__c study= new Study__c(Name = 'CaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999',
                                   accountid = busAcc.id,PreferredLanguage__c = 'en_US');
        insert(cont);
        Id contactId = cont.Id;
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cont.Id,Site_Name__c = acts[1].Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        insert siteConR;
        Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=busAcc.Id, BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id);
        insert entl;
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        system.runAs(u) {
            Group g1 = new Group(Name='group name', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            Queue_User_Relationship__c qu = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'Queue', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = grpUser.groupId);
            
            insert qu;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,TECH_QueueUser__c = qu.Id,
                Type__c = 'User', Tier__c ='Tier 1',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
            String entlId;
            if (entl != null)
                entlId = entl.Id;
            List<Case> cases = new List<Case>{};
                if (entlId != null){
                    Case c = new Case(Subject = 'Test Case with Entitlement ',
                                      Study__c=study.Id,
                                      Sponsor__c = acct2.Id,
                                      Site_Related_to_the_Study__c = siteConR.Id,
                                      Origin = 'Email',
                                      Status = 'New',
                                      InitialQueue__c = 'Q1',
                                      AssignCaseToCurrentUser__c = false,
                                      RandD_Location__c = 'Dalian',
                                      EntitlementId = entlId, 
                                      ContactId = contactId,
                                      RecordTypeId = RecordTypeIdCase,
                                      CurrentQueue__c = qur.Id);
                    cases.add(c);
                }
            Test.startTest();
            insert cases;
            List<Id> caseIds = new List<Id>();
            if (cases.isEmpty()==false){
                //insert cases;            
                for (Case cL : cases){
                    //caseIds.add(cL.Id);
                    cL.Status = 'Waiting for';
                    cL.SubStatus__c = 'QC';
                    
                }
                
                // update cases;
                DAOH_Case.completeMilestone(caseIds,'Critical Alert' , System.now());
            Test.stopTest();
            }
        }

    }

    @isTest
    static void testUpdateAssignToCurrentQueueOnQuickAction(){       
        Id techRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        List<Case> caseList = [SELECT Id, CaseNumber,AssignCaseToCurrentUser__c, Subject, IsEscalated,AssetId, Asset.Name, AssetName__c, ProductName__c, SubType1__c, SubType2__c, SubType3__c,RecordType.Name from case  WHERE RecordTypeId = :techRecordTypeId limit 1];
        QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
        req.setQuickActionName('Case.Macros_Only');
        for(Case caseRecord : caseList){
            caseRecord.AssignCaseToCurrentUser__c = true;
            req.record = caseRecord;

        }
        update caseList;
        Test.startTest();
        try{
            QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAddDescriptionAsCaseComment(){
        CSM_ExternalClient_info__c externalClientInfo = new CSM_ExternalClient_info__c();
        externalClientInfo.Name = CON_CSM.S_ROCHE_SN;
        externalClientInfo.Profile_Id__c = 'test';
        insert externalClientInfo;
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id queueUserId = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' AND Type__c = 'User' LIMIT 1].Id;
        Case cs = new Case();
        cs.ContactId = conObjId;
        cs.AccountId = accObjId;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = recordTypeIdTechno;
        cs.Priority = 'Priority 4';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Techno Test case';
        cs.Description = 'Test class to check case creation ';
        cs.Status = 'New';
        cs.External_System_Type__c = CON_CSM.S_ROCHE_SN;
        cs.ServiceNowSystemType__c = CON_CSM.S_ROCHE_SN;
        cs.CurrentQueue__c = queueUserId;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        Test.startTest();
            insert cs;
			cs.Priority = 'Priority 2';
            update cs;
        Test.stopTest();
    }
    
    @isTest
    static void testCustomEmailAddressesValidation(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Id queueUserId = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' AND Type__c = 'User' LIMIT 1].Id;
        
        Case caseRecord = [select Id,Origin,AFU_Email_Addresses__c,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        Test.startTest();
        //insert caseRecord;
        //System.assertEquals('testmail@mailer.com; noreply@mailer.com', caseRecord.AFU_Email_Addresses__c);
        
        //Case caseRecordNew = [SELECT Id, Status FROM Case WHERE recordTypeId =: recordTypeIdRnD AND Origin = 'Web' LIMIT 1];
        caseRecord.AFU_Email_Addresses__c = 'test@n.c;; nomail';
        try{
            update caseRecord;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Invalid Email Address Format In AFU Email Addresses.') ? true : false;
            //System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmail(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueRecord.Name = 'RnD - Global Investigator Services';
        queueRecord.QueueName__c ='RnD - Global Investigator Services';
        queueRecord.Type__c ='Queue';
        queueRecord.Tier__c ='Tier 1';
        queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueRecord;
        Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUserRecord.Name ='RnD - Global Investigator Services';
        queueUserRecord.QueueName__c = 'RnD - Global Investigator Services';
        queueUserRecord.Type__c ='User';
        queueUserRecord.TECH_QueueUser__c = queueRecord.Id;
        queueUserRecord.User__c = UserInfo.getUserId();
        queueUserRecord.Tier__c ='Tier 1';
        queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueUserRecord;
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.CurrentQueue__c = queueUserRecord.Id;
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'Infosario - QCC';
        caseRecord.SubType1__c = 'Infosario CSS';
        caseRecord.SubType2__c = 'Account Management';
        caseRecord.SubType3__c = 'Add User';
        caseRecord.Status = 'Waiting for';
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 1;
        
        Test.startTest();
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmail1(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueRecord.Name = 'RnD - Global Investigator Services';
        queueRecord.QueueName__c ='RnD - Global Investigator Services';
        queueRecord.Type__c ='Queue';
        queueRecord.Tier__c ='Tier 1';
        queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueRecord;
        Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUserRecord.Name ='RnD - Global Investigator Services';
        queueUserRecord.QueueName__c = 'RnD - Global Investigator Services';
        queueUserRecord.Type__c ='User';
        queueUserRecord.Tier__c ='Tier 1';
        queueUserRecord.TECH_QueueUser__c = queueRecord.Id;
        queueUserRecord.User__c = UserInfo.getUserId();
        queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueUserRecord;
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.CurrentQueue__c = queueUserRecord.Id;
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'Infosario - QCC';
        caseRecord.SubType1__c = 'Infosario CSS';
        caseRecord.SubType2__c = 'Account Management';
        caseRecord.SubType3__c = 'Add User';
        caseRecord.Status = 'Waiting for';
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        
        Test.startTest();
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 1;
        update caseRecord;
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmailQ2(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'Q� Lab Investigator Services';
        caseRecord.Status = 'Waiting for';
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 1;
        
        Test.startTest();
        update caseRecord;
        caseRecord.LOS__c = 'Q� Lab Investigator Services';
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.SubStatus__c = 'Automated FU';
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.AFU_Email_Addresses__c = null;
        caseRecord.Count_of_AFU__c = 1;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        //System.assertEquals('Waiting for', caseRecord.Status);
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmailResolved(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueRecord.Name = 'RnD - Global Investigator Services';
        queueRecord.QueueName__c ='RnD - Global Investigator Services';
        queueRecord.Type__c ='Queue';
        queueRecord.Tier__c ='Tier 1';
        queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueRecord;
        Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUserRecord.Name ='RnD - Global Investigator Services';
        queueUserRecord.QueueName__c = 'RnD - Global Investigator Services';
        queueUserRecord.Type__c ='User';
        queueUserRecord.Tier__c ='Tier 1';
        queueUserRecord.TECH_QueueUser__c = queueRecord.Id;
        queueUserRecord.User__c = UserInfo.getUserId();
        queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueUserRecord;
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.CurrentQueue__c = queueUserRecord.Id;
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'Infosario - QCC';
        caseRecord.SubType1__c = 'Infosario CSS';
        caseRecord.SubType2__c = 'Account Management';
        caseRecord.SubType3__c = 'Add User';
        caseRecord.Status = 'Resolved';
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 1;
        
        Test.startTest();
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.AFU_Email_Addresses__c = null;
        caseRecord.Count_of_AFU__c = 1;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        //System.assertEquals('Resolved', caseRecord.Status);
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmailResolvedQ2(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'Q� Lab Investigator Services';
        caseRecord.Status = 'Resolved';
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 1;
        
        Test.startTest();
        caseRecord.LOS__c = 'Q� Lab Investigator Services';
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.SubStatus__c = 'Automated FU';
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.AFU_Email_Addresses__c = null;
        caseRecord.Count_of_AFU__c = 1;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 3;
        update caseRecord;
        //System.assertEquals('Resolved', caseRecord.Status);
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmailEDCWaiting(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'EDC Support';
        caseRecord.Status = 'Waiting for';
        caseRecord.Count_of_AFU__c = 1;
        caseRecord.SubStatus__c = 'Automated FU';
        
        Test.startTest();
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        //System.assertEquals('Waiting for', caseRecord.Status);
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmailCSSWaiting(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.Status = 'Waiting for';
        caseRecord.Count_of_AFU__c = 1;
        caseRecord.SubStatus__c = 'Automated FU';
        
        Test.startTest();
        caseRecord.LOS__c = 'CD-CSS';
        caseRecord.Count_of_AFU__c = 1;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.LOS__c = 'CD-CSS';
        caseRecord.AFU_Email_Addresses__c = null;
        caseRecord.Count_of_AFU__c = 1;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        //System.assertEquals('Waiting for', caseRecord.Status);
        Test.stopTest();
    }
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmailEDC_CSSResolved(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'EDC Support';
        caseRecord.Status = 'Resolved';
        caseRecord.Count_of_AFU__c = 1;
        caseRecord.SubStatus__c = 'Automated FU';
        
        Test.startTest();
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        //System.assertEquals('Resolved', caseRecord.Status);
        Test.stopTest();
    }
    
    
    @isTest
    static void testSendRandDAutomatedFollowUpEmailCSSResolved(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        
        Case caseRecord = [select Id,CurrentQueue__c,InitialQueue__c,Study__c,Site_Related_to_the_Study__c,AssetId,ServiceNow_Group__c,EntitlementId,BusinessHoursId,Status, SubStatus__c,Description,CaseSubType2__c from Case where RecordTypeName__c in ('RandDCase') LIMIT 1];
        
        caseRecord.Origin = 'Web';
        caseRecord.RnD_Email_Flag__c = true;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.Status = 'Resolved';
        caseRecord.SubStatus__c = 'Automated FU';
        
        Test.startTest();
        caseRecord.LOS__c = 'CD-CSS';
        caseRecord.Count_of_AFU__c = 1;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.Count_of_AFU__c = 2;
        update caseRecord;
        caseRecord.SubStatus__c = 'Automated FU';
        caseRecord.LOS__c = 'CD-CSS';
        caseRecord.Count_of_AFU__c = 3;
        update caseRecord;
        //System.assertEquals('Resolved', caseRecord.Status);
        Test.stopTest();
    }
    
    @isTest
    static void testIfCaseIsInApprovalProcess() {
        case newCase1 = UTL_TestData.createCase();
        newCase1.OneKey_FirstName__c = 'ALAIN';
        newCase1.OneKey_LastName__c = 'BISMUTH';
        //newCase1.Type = 'Erasure';
        
        Test.startTest();
            insert newCase1;
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        newCase1 = [Select Id,Status from Case where oneKeyId__c = 'WFRD00890450' limit 1];
        //System.assertEquals('Request for Approval', newCase1.status, 'Case is not assigned to approver');
    }
    
    @isTest
    static void testWhenCaseStausIsupdated() {
        case newCase1 = UTL_TestData.createCase();
        newCase1.OneKey_FirstName__c = 'ALAIN';
        newCase1.OneKey_LastName__c = 'BISMUTH';
        //newCase1.Type = 'Erasure';
        insert newCase1;
        newCase1.status = 'Closed';
        newCase1.Force_CSAT_Email_Survey__c = true;
        Test.startTest();
            update newCase1;
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        newCase1 = [Select Id,Status,OneKeyID__c from Case where Id =: newCase1.Id limit 1];
        //System.assertEquals('Deleted', newCase1.OneKeyID__c, 'One Key Id is not updated ');
    }
    
    @isTest
    static void testcheckCaseTypeForDataCase() {
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = '';
        newCase1.RecordTypeId = sltRecordType.getRecordType(CON_CSM.S_DATACASE)[0].Id;
        
        Test.startTest();
            insert newCase1;
        Test.stopTest();
        
        List<Case> result = [Select Id from case];
        //System.assertEquals(False, result.isEmpty(),'Result is fetched');
        //System.assertEquals(true, result.Size() > 1,'Result is fetched');
    }
    
    @isTest
    static void testcheckCaseTypeForDataCaseForError() {
        Test.startTest();
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = 'Data MX Client Services';
        newCase1.Case_Type__c = '';
        newCase1.RecordTypeId = sltRecordType.getRecordType(CON_CSM.S_DATACASE)[0].Id;
        System.runAs(serviceUser) {
            try{
                insert newCase1;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains(Label.Case_type_is_mandatory_for_this_Initial_queue) ? true : false;
                //System.assertEquals(expectedExceptionThrown, true);
            }
        }    
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateLOSForRnDPillarShouldPopulateLOS() {
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        Case newCase = UTL_TestData.createCase();
        newCase.InitialQueue__c = 'RnD - Global Account Management';
        newCase.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        Test.startTest();
            insert newCase;
        Test.stopTest();
        
        newCase = [SELECT Id, LOS__c FROM Case WHERE Id =: newCase.Id limit 1];
        ////System.assertEquals('Account Management', newCase.LOS__c, 'LOS is populated');
    }
    
    @isTest
    static void testsetRecordtypetoIQVIALiveChat() {
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.Tier__c ='Tier 1';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUser1.Name = 'Q1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Type__c = 'User';
        queueUser1.Tier__c ='Tier 1';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        Case newCase = UTL_TestData.createCase();
        newCase.InitialQueue__c = 'RnD - Global Account Management';
        newCase.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        Id accountRecordId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id contactRecordId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Case caseRecord = new Case();
        caseRecord.AccountId = accountRecordId;
        caseRecord.Origin = 'Chat';
        caseRecord.ContactId = contactRecordId;
        caseRecord.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('IQVIALiveChat').getRecordTypeId();
        caseRecord.CurrentQueue__c=queues1.Id;
        insert caseRecord;
        
        LiveChatDeployment depRecord = [SELECT Id, DeveloperName FROM LiveChatDeployment WHERE DeveloperName = 'MRKT_CA_LIVE_CHAT_DEP' LIMIT 1];
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        LiveChatTranscript transRecord = new LiveChatTranscript();
        transRecord.AccountId = accountRecordId;
        transRecord.Body = 'Test data';
        transRecord.CaseId = caseRecord.Id;
        transRecord.Email__c = 'testuser@mail.com';
        transRecord.OwnerId = UserInfo.getUserId();
        transRecord.ContactId = contactRecordId;
        transRecord.LiveChatDeploymentId = depRecord.Id;
        transRecord.LiveChatVisitorId = visitor.Id;
        insert transRecord;
        
        Test.startTest();
        DAOH_Case.SanofiTaskMilestone('T1');
        DAOH_Case.SanofiTaskMilestone('T2');
        DAOH_Case.SanofiTaskMilestone('T3');
        DAOH_Case.SanofiTaskMilestone('T4');
        DAOH_Case.SanofiTaskMilestone('T1L1');
        DAOH_Case.SanofiTaskMilestone('T2a');
        DAOH_Case.SanofiTaskMilestone('T2b');
        DAOH_Case.setRecordtypetoIQVIALiveChat(New List<Case>{caseRecord});
        Test.stopTest();
        
        ////System.assertEquals('Account Management', newCase.LOS__c, 'LOS is populated');
    }
    
    @isTest
    static void testPopulateLocationForRAndD() {
        User newUser = UTL_TestData.createUser('System Administrator', 1)[0];
        newUser.city = 'Lisbon';
        insert newUser;
        Case newCase = UTL_TestData.createCase();
        newCase.InitialQueue__c = 'RnD - Global Account Management';
        newCase.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        System.runAs(newUser) {
            Test.startTest(); 
            newCase.OwnerId = newUser.Id;
            insert newCase;
            Test.stopTest();
            
            newCase = [SELECT Id, RandD_Location__c FROM Case WHERE Id =: newCase.Id limit 1];
            //System.assertEquals('Lisbon', newCase.RandD_Location__c, 'LOcation is populated');
        }

    }
    
    @isTest
    static void testWillNotPopulateLocationForRAndD() {
        Case newCase = UTL_TestData.createCase();
        newCase.InitialQueue__c = 'RnD - Global Account Management';
        newCase.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        Test.startTest(); 
            insert newCase;
        Test.stopTest();
        
        newCase = [SELECT Id, RandD_Location__c FROM Case WHERE Id =: newCase.Id limit 1];
        System.assertNotEquals('Lisbon', newCase.RandD_Location__c, 'LOcation is populated');
    }
    
    @isTest
    static void testPopulateLocationForRAndDCaseUpdate() {
        User newUser = UTL_TestData.createUser('System Administrator', 1)[0];
        newUser.city = 'Lisbon';
        insert newUser;
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.Tier__c ='Tier 1';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUser1.Name ='Q1';
        queueUser1.QueueName__c ='Q1';
        queueUser1.Type__c ='User';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.Tier__c ='Tier 1';
        queueUser1.User__c = newUser.Id;
        insert queueUser1;
        Case newCase = UTL_TestData.createCase();
        newCase.InitialQueue__c = 'RnD - Global Account Management';
        newCase.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        insert newCase;
        System.runAs(newUser) {
            Test.startTest(); 
            newCase.OwnerId = newUser.Id;
            update newCase;
            Test.stopTest();
            
            newCase = [SELECT Id, RandD_Location__c FROM Case WHERE Id =: newCase.Id limit 1];
            //System.assertEquals('Lisbon', newCase.RandD_Location__c, 'LOcation is populated');
        }

    }
   
    @isTest
    static void testRestrictClosedCaseModificationAsServiceUserOnStatusUpdate(){
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        Account accountRecord = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];       
        Contact contactRecord = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Asset assetRecord = [SELECT Id FROM Asset WHERE Name = 'DDD' AND AccountId = :accountRecord.Id LIMIT 1];
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queueUserRelation = new Queue_User_Relationship__c(Name = 'Q1', User__c = serviceUser.Id, Type__c = 'User',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true, Tier__c ='Tier 1');
        insert queueUserRelation;
        Id dataRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Case caseRecord = CSM_TestDataFactory.createClosedCase(accountRecord.Id, dataRecordTypeId, null, TRUE, 'Customer Portal', 'Techno case', 'Test class to check case creation',
                                                                   serviceUser.Id, 'Closed', 'Dummy Text', 'CLIENT - DATA QUERY NOT VALID', assetRecord.Id, FALSE, queueUserRelation.Id);
        caseRecord.Force_CSAT_Email_Survey__c = true;
        insert caseRecord;
        Test.setCreatedDate(caseRecord.Id, DateTime.newInstance(2012,12,12));
        
        Test.startTest();
            System.runAs(serviceUser){
                DAOH_Case.isCaseUpdated = FALSE;
                caseRecord.Status = 'Canceled';
                try{
                    UPDATE caseRecord;
                }
                catch(Exception ex){
                    Boolean expectedExceptionThrown = ex.getMessage().contains('You can\'t update/modify the case fields') ? true : false;
                    //System.assertEquals(expectedExceptionThrown, true);
                }
            }
        Test.stopTest();
    }
    
    @isTest
    static void testRestrictClosedCaseModificationShouldUpdate(){
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        Account accountRecord = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];       
        Contact contactRecord = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Asset assetRecord = [SELECT Id FROM Asset WHERE Name = 'DDD' AND AccountId = :accountRecord.Id LIMIT 1];
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queueUserRelation = new Queue_User_Relationship__c(Name = 'Q1', User__c = serviceUser.Id, Type__c = 'User', Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1');
        insert queueUserRelation;
        
        Id dataRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();

        Case caseRecord = CSM_TestDataFactory.createClosedCase(accountRecord.Id, dataRecordTypeId, null, TRUE, 'Customer Portal', 'Techno case', 'Test class to check case creation',
                                                                   serviceUser.Id, 'Closed', 'Dummy Text', 'CLIENT - DATA QUERY NOT VALID', assetRecord.Id, FALSE, queueUserRelation.Id);
        caseRecord.Force_CSAT_Email_Survey__c = true;
        insert caseRecord;
        Test.setCreatedDate(caseRecord.Id, DateTime.newInstance(2012,12,12));
        
        Test.startTest();
        System.runAs(serviceUser){
            DAOH_Case.isCaseUpdated = FALSE;
            Boolean expectedExceptionThrown = false;
            caseRecord.Case_Type__c = 'PROJECT';
            try{
                UPDATE caseRecord;
            }
            catch(Exception ex){
                expectedExceptionThrown = ex.getMessage().contains('You can\'t update/modify the case fields') ? true : false;
            }           
            //System.assertEquals(expectedExceptionThrown, false);
            
        }
        Test.stopTest();
    }

    @isTest
    static void testRestrictClosedCaseModificationShouldRestrict(){
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        Account accountRecord = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];       
        Contact contactRecord = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Asset assetRecord = [SELECT Id FROM Asset WHERE Name = 'DDD' AND AccountId = :accountRecord.Id LIMIT 1];
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queueUserRelation = new Queue_User_Relationship__c(Name = 'Q1', User__c = serviceUser.Id, Type__c = 'User', Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1');
        insert queueUserRelation;
        
        Id dataRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Case caseRecord = CSM_TestDataFactory.createClosedCase(accountRecord.Id, dataRecordTypeId, null, TRUE, 'Customer Portal', 'Techno case', 'Test class to check case creation',
                                                                   serviceUser.Id, 'Closed', 'Dummy Text', 'CLIENT - DATA QUERY NOT VALID', assetRecord.Id, FALSE, queueUserRelation.Id);
        caseRecord.Force_CSAT_Email_Survey__c = true;
        insert caseRecord;
        Test.setCreatedDate(caseRecord.Id, DateTime.newInstance(2012,12,12));

        Boolean expectedExceptionThrown = false;        
        Test.startTest();
        System.runAs(serviceUser){
            DAOH_Case.isCaseUpdated = FALSE;
            caseRecord.Case_Type__c = 'PROJECT';
            caseRecord.Origin = 'Chat';
            try{
                UPDATE caseRecord;
            }
            catch(Exception ex){
                expectedExceptionThrown = ex.getMessage().contains('You can only update/modify the Case Type') ? true : false;
                //System.assertEquals(expectedExceptionThrown, true);
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSetFieldForDataShouldSet(){
        CSM_ReplyTo_Email__c replyTo = new CSM_ReplyTo_Email__c(Name = 'EmailAddress', Reply_To_Email_Address__c = 'test@example.com');
        CSM_ReplyTo_Email__c replyToAddress = new CSM_ReplyTo_Email__c(Name = 'EAddress', Reply_To_Email_Address__c = 'test@example.com');
        CSM_ReplyTo_Email__c replyToIMS = new CSM_ReplyTo_Email__c(Name = 'EmailAddressIMS', Reply_To_Email_Address__c = 'test@example.com');
        CSM_ReplyTo_Email__c replyToIMSUS = new CSM_ReplyTo_Email__c(Name = 'EmailAddressIMSUS', Reply_To_Email_Address__c = 'test@example.com');
        List<CSM_ReplyTo_Email__c> listOfReplyToEmail = new List<CSM_ReplyTo_Email__c>{replyTo, replyToAddress, replyToIMS, replyToIMSUS};        
        Insert listOfReplyToEmail;
        Test.startTest();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Account accountRecord = CSM_TestDataFactory.createAccount('Site');
        insert accountRecord;
        
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.Tier__c ='Tier 1';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUser1.Name = 'Q1';
        queueUser1.Tier__c ='Tier 1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Type__c = 'User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        Id dataRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Case caseRecord;
        User systemUser = [select Id,Name from user where Name ='System' Limit 1];
        System.runAs(systemUser) {
            caseRecord = CSM_TestDataFactory.createClosedCase(accountRecord.Id, dataRecordTypeId, null, TRUE, 'Email', 'Data case', 'Test class to check case creation',
                                                                   UserInfo.getUserId(), 'New', 'Dummy Text', 'CLIENT - DATA QUERY NOT VALID', null, FALSE, queues1.Id);
            caseRecord.Origin = 'Email';
            caseRecord.CaseOriginatorName__c = CON_CSM.S_DATA_GLOBAL_ESERVICE_QUEUE;
            caseRecord.InitialQueue__c = CON_CSM.S_DATA_GLOBAL_ESERVICE_QUEUE;
            Insert caseRecord;
            List<EmailMessage> newEmail = new List<EmailMessage>();
            newEmail.add(new EmailMessage(FromAddress = 'test@example.com', Incoming = true, ToAddress= 'test@example.com', Subject = 'Test email RD In', 
                                          TextBody = '23456 ', ParentId = caseRecord.Id, CcAddress = 'test@example.com')); 
            Insert newEmail;
            
            Case caseToBeUpdated = [SELECT Subject, CaseNumber, SubType1__c, RecordTypeName__c, Origin, CreatedById, CaseOriginatorName__c, InitialQueue__c,From_EmailToCase__c FROM Case WHERE RecordTypeName__c = 'DATACase' AND Id =: caseRecord.Id];
            
            try{
                caseToBeUpdated.Subject = 'SERVICE';
                Update caseToBeUpdated;
            }
            catch(Exception ex){
                ex.getMessage();
            }
            Test.stopTest();
        }

        Case updatedCase = [SELECT Id, Language__c, LOS__c FROM Case WHERE Id =: caseRecord.Id];
        //System.assertEquals('English', updatedCase.Language__c, 'Case Language not updated');
        //System.assertEquals('DATA', updatedCase.LOS__c, 'Case Language not updated');
    }

    @isTest
    static void testCheckActivityStatusForOpen() {
        CSM_case_Trigger_Handler__c trigeerHandler = new CSM_case_Trigger_Handler__c(CSM_Activity_Open_Validation__c = true);
        trigeerHandler.SetupOwnerId = UserInfo.getUserId();
        insert trigeerHandler;
        Test.startTest();
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = 'Data MX Client Services';
        newCase1.RecordTypeId = sltRecordType.getRecordType('RandDCase')[0].Id;
        try{
            insert newCase1;

            Activity__C newActivity = new Activity__C(Case__c = newCase1.Id, status__c = 'Open', 
                                                      LOS__c = 'EDC Support',Type__c = 'Quality Check' );
            insert newActivity;
            newCase1.Status = 'Resolved';
            update newCase1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.CSM_Activity_Open_Validation) ? true : false;
            //System.assertEquals(true,expectedExceptionThrown,'case is updated' );
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckActivityStatusForClosed() {
        CSM_case_Trigger_Handler__c trigeerHandler = new CSM_case_Trigger_Handler__c(CSM_Activity_Open_Validation__c = true);
        trigeerHandler.SetupOwnerId = UserInfo.getUserId();
        insert trigeerHandler;
        Test.startTest();
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = 'Data MX Client Services';
        newCase1.RecordTypeId = sltRecordType.getRecordType('RandDCase')[0].Id;
        try{
            insert newCase1;
            Activity__C newActivity = new Activity__C(Case__c = newCase1.Id, status__c = 'Done');
            insert newActivity;
            newCase1.Status = 'Resolved';
            update newCase1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.CSM_Activity_Open_Validation) ? true : false;
            //System.assertEquals(false,expectedExceptionThrown,'case is updated' );
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckActivityStatusNotTrigger() {
        Test.startTest();
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = 'Data MX Client Services';
        newCase1.RecordTypeId = sltRecordType.getRecordType('RandDCase')[0].Id;
        try{
            insert newCase1;
            Activity__C newActivity = new Activity__C(Case__c = newCase1.Id, status__c = 'Done');
            insert newActivity;
            newCase1.ServiceNow_Status__c = 'Completed';
            update newCase1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.CSM_Activity_Open_Validation) ? true : false;
            //System.assertEquals(false,expectedExceptionThrown,'case is updated' );
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateFirstResponseEmailTimeOnCase(){
        Case caseRecord = [SELECT Id, Status, Subject, First_response_email_time__c, First_response_sent__c FROM Case WHERE RecordTypeName__c='DATACase' AND First_response_email_time__c=NULL AND LOS__c='DATA' AND First_response_sent__c = FALSE LIMIT 1];
        caseRecord.First_response_sent__c = TRUE;
        Test.startTest();
        update caseRecord;
        Case cloneCase = caseRecord.clone();
        insert cloneCase;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateContactAlreadyInProcess(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Case newCase1 =  UTL_TestData.createCase();
        newCase1.RecordTypeId = new SLT_RecordType().getRecordType('DATACase')[0].Id;
        newCase1.contactId = conObjId;
        newCase1.AccountId = accObjId;
        newCase1.Self_Registration_Date__c = Date.today();
        Insert newCase1;
        newCase1.Self_Registration_Date__c = Date.today()+1;
        Test.startTest();
            update newCase1;        
            Case newCase2 =  UTL_TestData.createCase();
            newCase2.RecordTypeId = new SLT_RecordType().getRecordType('DATACase')[0].Id;
            newCase2.contactId = conObjId;
            newCase2.AccountId = accObjId;
               Insert newCase2;
        Test.stopTest();
        
        newCase1 = [select Id, Contact_Already_In_Self_Registration__c from Case where Id =:newCase1.Id limit 1];
        //System.assertEquals(false , newCase1.Contact_Already_In_Self_Registration__c, 'Contact Related to case is not in self registration');
        newCase2 = [select Id, Contact_Already_In_Self_Registration__c from Case where Id =:newCase2.Id limit 1];
        //System.assertEquals(true , newCase2.Contact_Already_In_Self_Registration__c, 'Contact Related to case is already in self registration');
        
    }
    
    @isTest
    static void testQueueCompleted(){
        Account acct = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        
        Contact Con = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: acct.Id][0];

        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = busId.Id,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue' , DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1', Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1', Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Group g2 = new Group(Name='Q2', type='Queue');
            insert g2;
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            Queue_User_Relationship__c qur2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true, Tier__c ='Tier 1', Name = grpUser2.group.Name,Type__c = 'Queue',Group_Id__c = grpUser2.groupId);
            insert qur2;
            Queue_User_Relationship__c qurUser2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1', Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser2;
            
            Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            ServiceNow_Group__c service = new ServiceNow_Group__c();
            service.Group_ID__c='EA-IQVIA';
            service.Name = 'EA-IQVIA';
            service.SystemType__c = 'IQVIA';
			service.Order__c = 1;
            insert service;
            
            ServiceNow_Group__c service2 = new ServiceNow_Group__c();
            service2.Group_ID__c='EA-BISM';
            service2.Name = 'EA-BISM';
            service2.SystemType__c = 'BISM';
			service2.Order__c = 1;
            insert service2;
            
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = rt;
            cs.Priority = 'Priority 4';
            cs.Origin = 'Phone';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.OwnerId = g1.Id;
            cs.External_System_Type__c = 'BISM';
            cs.ServiceNowSystemType__c = 'IQVIA';
            cs.ServiceNow_Group__c = service.Id;
            Test.startTest();
            insert cs;
            cs.Priority = 'Priority 3';
            cs.OwnerId = g2.Id;
            cs.Status = 'Resolved with Customer';
            cs.ServiceNowSystemType__c = 'BISM';
            cs.ServiceNow_Group__c = service2.Id;
            update cs;
            Test.stopTest();
            
        }
    }
    
    @isTest
    static void testBISMTEST(){
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE', AccountCountry__c = 'BR');
        insert acct;
        
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='briandent@trailhead.com',
            AccountId = acct.Id,PreferredLanguage__c = 'en_US');
        insert Con;
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = busId.Id,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue', DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1', Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1', Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Group g2 = new Group(Name='Q2', type='Queue');
            insert g2;
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            Queue_User_Relationship__c qur2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true, Tier__c ='Tier 1', Name = grpUser2.group.Name,Type__c = 'Queue',Group_Id__c = grpUser2.groupId);
            insert qur2;
            Queue_User_Relationship__c qurUser2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1', Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser2;
            
            Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            ServiceNow_Group__c service = new ServiceNow_Group__c();
            service.Group_ID__c='EA-IQVIA';
            service.Name = 'EA-IQVIA';
            service.SystemType__c = 'IQVIA';
			service.Order__c = 1;
            insert service;
            
            ServiceNow_Group__c service2 = new ServiceNow_Group__c();
            service2.Group_ID__c='EA-BISM';
            service2.Name = 'EA-BISM';
            service2.SystemType__c = 'BISM';
			service2.Order__c = 1;
            insert service2;
            
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = rt;
            cs.Priority = 'Priority 4';
            cs.Origin = 'Phone';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.OwnerId = g1.Id;
            cs.External_System_Type__c = 'BISM';
            cs.ServiceNowSystemType__c = 'IQVIA';
            cs.ServiceNow_Group__c = service.Id;
            Test.startTest();
            insert cs;
            cs.Priority = 'Priority 1';
            cs.Force_CSAT_Email_Survey__c = true;
            cs.Status = 'Closed';
            cs.OwnerId = g1.Id;
            update cs;
            Test.stopTest();
        }
    }
    
    @IsTest 
    private static void testSetIsStudyAttachedFirstTimeForRNDShouldSet() {
        Account account = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        Account acct2 = [SELECT Id FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1];
        
        Study__c studyWithoutInfo = [SELECT Id, Name, Sponsor__c FROM Study__c WHERE Name = 'testSetupCaseTestStudy' LIMIT 1];
        Study__c studyWithInfo = new Study__c(Name = 'studyWithInfo', Sponsor__c = acct2.Id, Study_Specific_Information__c = 'Test Info');
        List<Study__c> studyList = new List<Study__c>{studyWithInfo};
        insert studyList;
        
        Contact contact = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: account.Id][0];
        Queue_User_Relationship__c queueUser = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' LIMIT 1];       
        
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        List<StudySiteContactRelationship__c> studySiteConList = new List<StudySiteContactRelationship__c>();
        StudySiteContactRelationship__c siteConR1 = new StudySiteContactRelationship__c(Study__c = studyWithInfo.Id, Investigator_Name__c = contact.Id, Site_Name__c = account.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        StudySiteContactRelationship__c siteConR2 = new StudySiteContactRelationship__c(Study__c = studyWithoutInfo.Id, Investigator_Name__c = contact.Id, Site_Name__c = account.Id);
        siteConR2.SiteNumber__c = 'SITE02';
        siteConR2.Lab_Site_Number__c = 'LABSITE02';
        studySiteConList.add(siteConR1);
        studySiteConList.add(siteConR2);
        insert studySiteConList;
        
        List<Case> caseList = new List<Case>();
        Case cs1 = new Case(
            AccountId = account.Id,
            ContactId = contact.Id,
            Study__c = studyWithInfo.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queueUser.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'StudyWithInfo',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        caseList.add(cs1);
        Test.startTest();
            insert cs1;
        Test.stopTest();
        
        Case caseRecord = [SELECT Id, Is_Study_Attached_First_Time__c FROM Case WHERE Id =: cs1.Id];
        //System.assertEquals(true, caseRecord.Is_Study_Attached_First_Time__c, 'Study attached first time');
    }

    @isTest
    static void testUpdateSubStatusOnQuickAction(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Case newCase =  UTL_TestData.createCase();
        newCase.RecordTypeId = new SLT_RecordType().getRecordType('TechnologyCase')[0].Id;
        newCase.contactId = conObjId;
        newCase.AccountId = accObjId;
        newCase.Status = CON_CSM.S_AWAITING;
        newCase.SubStatus__c = 'Customer Info';
        Insert newCase;
        
        QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
        req.setQuickActionName(CON_CSM.S_TAKE_OWNERSHIP);
        newCase.Status = CON_CSM.S_IN_PROGRESS;
        req.record = newCase;
        Test.startTest();
            QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
        Test.stopTest();
        
        newCase = [SELECT Id, Status, SubStatus__c FROM Case WHERE Id =: newCase.Id];
        //System.assertEquals(true, res.isSuccess(), 'Quick action completed successfully');
        //System.assertEquals(null, newCase.SubStatus__c, 'SubStatus is updated');
        //System.assertEquals(CON_CSM.S_IN_PROGRESS, newCase.Status, 'Status is updated');
    }
    
    @isTest
    static void testUpdateMilestoneAction(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Case newCase =  UTL_TestData.createCase();
        newCase.RecordTypeId = new SLT_RecordType().getRecordType('TechnologyCase')[0].Id;
        newCase.contactId = conObjId;
        newCase.AccountId = accObjId;
        newCase.Status = 'Closed';
        newCase.Force_CSAT_Email_Survey__c = true;
        newCase.SubStatus__c = 'Customer Info';
        
        Test.startTest();
            Insert newCase;
        Test.stopTest();
        
        newCase = [SELECT Id, Status, NextMilestoneStatus__c FROM Case WHERE Id =: newCase.Id];
        //System.assertEquals('Stopped', newCase.NextMilestoneStatus__c, 'Quick action completed successfully');
    }

    @isTest
    static void testUpdateCaseDefaultBusinessHour() {
        Queue_User_Relationship__c queueUser = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' and Name='Q2 T2' LIMIT 1];
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Contact contact = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: account.Id][0];
        
        BusinessHours bHours = [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours WHERE IsActive = True AND Name = 'Default' LIMIT 1];
        BusinessHours bHours2 = [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours WHERE IsActive = True AND Name = 'EU Business Hours' LIMIT 1];
        BusinessHours bHours3 = [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours WHERE IsActive = True AND Name = 'AE-Std BH 9-17' LIMIT 1];  
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId = account.Id, Type = 'Data', BusinessHoursId = bHours2.Id,
                                          StartDate = Date.valueof(System.now().addDays(-2)), 
                                          EndDate = Date.valueof(System.now().addYears(2)));
        Insert ent;
        
        Id recordTypeIdData = new SLT_RecordType().getRecordType(CON_CSM.S_DATACASE)[0].Id;
        Case newCase = CSM_TestDataFactory.createCase(account.Id, contact.Id, recordTypeIdData, null, 'Agent Initiated', null, 'testDataCase', 'testDataCase', queueUser.Id);
        newCase.CurrentQueue__c = queueUser.Id;
        newCase.Status = 'New';
        newCase.EntitlementId = ent.Id;
        newCase.BusinessHoursId = bHours3.Id;     
        Insert newCase;
        
        Test.startTest();
            newCase.BusinessHoursId = bHours.Id;
            Update newCase;
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, BusinessHours.Name FROM Case WHERE Id =: newCase.Id];
        /** //System.assertEquals('EU Business Hours', updatedCase.BusinessHours.Name, 'BusinessHours Updated'); */
    }
    
    @isTest
    static void testUpdateMileStoneStatusAndValueShouldUpdatePriorValue() {
        Queue_User_Relationship__c queueUser = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'User' LIMIT 1];
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Contact contact = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: account.Id][0];

        Id recordTypeIdData = new SLT_RecordType().getRecordType(CON_CSM.S_DATACASE)[0].Id;
        Case newCase = CSM_TestDataFactory.createCase(account.Id, contact.Id, recordTypeIdData, null, 'Agent Initiated', null, 'testDataCase', 'testDataCase', queueUser.Id);
        newCase.Status = 'New';
        newCase.CurrentQueue__c = queueUser.Id;
        newCase.IsStopped =  False;
        newCase.NextMilestoneStatus__c = CON_CSM.S_ONGOING;    
        
        Test.startTest();
            Insert newCase;
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, NextMilestonePriorValue__c FROM Case WHERE Id =: newCase.Id];
        //System.assertEquals(CON_CSM.S_ONGOING, updatedCase.NextMilestonePriorValue__c, 'Milestone Prior value updated');
    }
    
    @isTest
    static void testUpdateMileStoneStatusAndValueShouldUpdateStatus() {
        Case newCase = [SELECT Id, Subject, Status, IsStopped FROM Case WHERE Subject = 'Data Test case' LIMIT 1];
        newCase.NextMilestoneStatus__c = CON_CSM.S_ONGOING;
        update newCase;

        Test.startTest();
            newCase.NextMilestoneStatus__c = CON_CSM.S_STOPPED;
            Update newCase; 
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, NextMilestoneStatus__c, NextMilestonePriorValue__c FROM Case WHERE Id =: newCase.Id];
        //System.assertEquals(CON_CSM.S_ONGOING, updatedCase.NextMilestoneStatus__c, 'Milestone Status updated');
    }
    
    @isTest
    private static void testUnfollowClosedCases() {
        List<User> listOfUser = [SELECT Id, Name, Profile.Name FROM User WHERE LastName = 'lastName123' AND (Profile.Name = 'System Administrator' OR Profile.Name = 'Service User')];      
        Account account = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];
        Contact contact = [SELECT Id, Name, PreferredLanguage__c, Account.Name FROM Contact WHERE AccountId =: account.Id][0];
        Queue_User_Relationship__c queueUser = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' and name ='Q2 T2' LIMIT 1];
        Id recordTypeIdData = new SLT_RecordType().getRecordType(CON_CSM.S_DATACASE)[0].Id;
        Case caseRecord = CSM_TestDataFactory.createCase(account.Id, contact.Id, recordTypeIdData, null, CON_CSM.S_CUSTOMER_PORTAL, null, 'testDataCase', 'testDataCase', queueUser.Id);
        //caseRecord.CurrentQueue__c = queueUser.Id;
        caseRecord.Status = 'Awaiting';
        caseRecord.OwnerId = UserInfo.getUserId();
        Case newCase = CSM_TestDataFactory.createCase(account.Id, contact.Id, recordTypeIdData, null, CON_CSM.S_CUSTOMER_PORTAL, null, 'testDataCaseNew', 'testDataCaseNew', queueUser.Id);
        //newCase.CurrentQueue__c = queueUser.Id;
        newCase.OwnerId = UserInfo.getUserId();
        newCase.Status = 'New';    
        insert new List<Case>{caseRecord, newCase};
        
        EntitySubscription eSub1 = new EntitySubscription(ParentID = caseRecord.Id, SubscriberId = listOfUser[0].Id);
        EntitySubscription eSub2 = new EntitySubscription(ParentID = caseRecord.Id, SubscriberId = listOfUser[1].Id);
        EntitySubscription eSub3 = new EntitySubscription(ParentID = caseRecord.Id, SubscriberId = listOfUser[2].Id);
        EntitySubscription eSub4 = new EntitySubscription(ParentID = newCase.Id, SubscriberId = listOfUser[0].Id);
        EntitySubscription eSub5 = new EntitySubscription(ParentID = newCase.Id, SubscriberId = listOfUser[1].Id);
        EntitySubscription eSub6 = new EntitySubscription(ParentID = newCase.Id, SubscriberId = listOfUser[2].Id);
        insert new List<EntitySubscription>{eSub1, eSub2, eSub3, eSub4, eSub5, eSub6};
        caseRecord.Force_CSAT_Email_Survey__c = true;
        caseRecord.Status = 'Closed';
        newCase.Force_CSAT_Email_Survey__c = true;
        newCase.Status = 'Closed';
        
        Test.startTest();
            Update new List<Case>{caseRecord, newCase};
        Test.stopTest();
        
        List<EntitySubscription> caseSubscriptionsList = [SELECT Id FROM EntitySubscription WHERE parentId IN: new Set<Id>{caseRecord.Id, newCase.Id}];
        //System.assertEquals(0, caseSubscriptionsList.size(), 'Unfollowed Closed Cases');
    }
    
    @isTest
    static void testsendEmailToLiquidPlanner() {
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        Account acct = [SELECT Id FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1].Id;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.runAs (usr) {
            Group g2 = new Group(Name='Q1', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue2@iqvia.com');
            insert g2;
            
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            
            BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c ='Tier 1', Name = 'Q1', User__c = UserInfo.getUserId(), Type__c = 'Queue');
            insert qurPortal;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = acct.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = acct.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            
            User user = New User(Alias = 'com', Email = 'john@acme.com', IsActive =true , ContactId = conObjId, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', LastLoginValue__c = System.now());
            insert user;
            
            CSMLiquidPlannerIntegration__c cMI = new CSMLiquidPlannerIntegration__c();
            cMI.name = g2.Id;
            cMI.Queue__c = 'Q1';
            cMi.Product__c ='MiPortal;EarlyView;PowerBI Excel Connector;DDD';
            cMi.EmailAddress__c = 'Akansha.gupta@metacube.com';
            cMi.ContactId__c = conObjId;
            cMi.OwnerID__c = (''+user.Id);
            insert cMI;
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = conObjId,
                Origin = 'Customer Portal',
                Status = 'In Progress',
                AssignCaseToCurrentUser__c = false,
                SubType1__c = 'DATA MGT/PRODUCTION',
                SubType2__c = 'DATA ISSUES',
                SubType3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)',
                OwnerId = g2.Id,
                RecordTypeId = RecordTypeIdCase,
                InitialQueue__c = qurPortal.Name,
                CurrentQueue__c = qurPortal.Id,
                ProductName__c = 'DDD',
                Description = 'Desc',
                Subject = 'Subh'
            );
            
            
            Map<Id,Case> caseMap = new Map<Id,Case>();
            Map<Id,Case> caseMap1 = new Map<Id,Case>();
            List<id> caseId = new List<Id>();
            List<id> caseRecordExistId = new List<Id>();
            Test.startTest();
            insert c;
            Case con = [Select id,OwnerId,Subject,Origin,ProductName__c,CaseNumber,Description,InitialQueue__c,Case_Thread_ID__c,Account_Name_Article__c from case where Subject='Subh' ];
            Map<Id,CSMLiquidPlannerIntegration__c> lpMap = new Map<Id,CSMLiquidPlannerIntegration__c>();
            List<CSMLiquidPlannerIntegration__c> csLp = CSMLiquidPlannerIntegration__c.getall().values();
            caseMap.put(con.Id,con);
            for(CSMLiquidPlannerIntegration__c cs : csLp){
                if(cs.Product__c.contains('MiPortal')) lpMap.put(con.Id,cs);    
            }
            
            string json = JSON.serialize(caseMap);
            string jsonCS = System.JSON.serialize(lpMap);
            
            con.ProductName__c = 'MiPortal';
            con.Status = 'In Progress';
            EXT_CSM_Validator_Cls.blnAlreadyDone = false;
            DAOH_case.sendEmailToLiquidPlannerFuture(json,jsonCS);
            Test.stopTest();
        }
    }
    
    
    @IsTest 
    private static void testLiquidPlanner() {
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        Account acct = [SELECT Id FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1].Id;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.runAs (usr) {
            Group g2 = new Group(Name='Q1', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue2@iqvia.com');
            insert g2;
            
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            
            BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1', Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,User__c = UserInfo.getUserId(), Type__c = 'Queue');
            insert qurPortal;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = acct.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = acct.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            
            User user = New User(Alias = 'com', Email = 'john@acme.com', IsActive =true , ContactId = conObjId, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', LastLoginValue__c = System.now());
            insert user;
            
            CSMLiquidPlannerIntegration__c cMI = new CSMLiquidPlannerIntegration__c();
            cMI.name = g2.Id;
            cMI.Queue__c = 'Q1';
            cMi.Product__c ='MiPortal;EarlyView;PowerBI Excel Connector;DDD';
            cMi.EmailAddress__c = 'Akansha.gupta@metacube.com';
            cMi.ContactId__c = conObjId;
            cMi.OwnerID__c = (''+user.Id);
            insert cMI;
            
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = conObjId,
                Origin = 'Customer Portal',
                Status = 'New',
                AssignCaseToCurrentUser__c = false,
                SubType1__c = 'DATA MGT/PRODUCTION',
                SubType2__c = 'DATA ISSUES',
                SubType3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)',
                OwnerId = g2.Id,
                RecordTypeId = RecordTypeIdCase,
                InitialQueue__c = qurPortal.Name,
                CurrentQueue__c = qurPortal.Id,
                ProductName__c = 'DDD',
                Description = 'Desc',
                Subject = 'Subh'
            );
            insert c;
            c.Subject = 'test subject';
            Test.startTest();
            update c;
            Test.stopTest();
        }
        
    }

    
    @istest
    static void testsendNotificationForDispatch(){
        Account acct = [SELECT Id FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1].Id;
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = busId.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User userRescord = new User(id = UserInfo.getUserId());
        system.debug('userRecord = '+userRescord);
        userRescord.Email ='aKANSHA.gupta@metacube.com';
        userRescord.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        update userRescord;
        User u = [Select id,Email,Name,Case_Comment_Work_Note__c from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        u.Case_Comment_Work_Note__c ='Assignment - Email;Assignment - Bell;Dispatch - Bell;Dispatch - Email';
        update u;
        system.runAs(u) {
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (UserOrGroupId = u.Id, GroupId = g1.Id);
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true, Name = 'group name', Type__c = 'Queue',tier__c ='Tier 1', Group_Id__c = g1.id);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Business_Hours__c = busId.Id, Out_Of_Office_Notification__c = true,
                Name = 'group name',Type__c = 'User',tier__c ='Tier 1', Group_Id__c = g1.id,User__c = u.id);
            
            insert qurUser;
			
			Queue_User_Relationship__c qur2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true, Name = 'group name', Type__c = 'Queue',tier__c ='Tier 2', Group_Id__c = g1.id);
            insert qur2;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = conObjId,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'group name',
                OwnerId = qurUser.Group_Id__c,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase,
                Subject ='Subject'
            );
            try{
            insert c;
            }catch(Exception ex ){
                system.debug('ex = '+ex.getMessage());
            }
            
            Test.startTest();
            Case caseRecord =[Select id,Subject,OwnerId from Case where Subject ='Subject'];
            caseRecord.OwnerId =  u.Id;
            caseRecord.CurrentQueue__c = qur2.Id;
            update caseRecord;
            caseRecord.OwnerId = qurUser.Group_Id__c;
            update caseRecord;
            Test.stopTest();
        }
    } 


    @istest
    static void testSendEmailAlertSLA(){
        Account acct = [SELECT Id FROM Account WHERE Name = 'testSetupTestSiteAccount1' LIMIT 1];
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1].Id;
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = busId.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User userRescord = new User(id = UserInfo.getUserId());
        system.debug('userRecord = '+userRescord);
        userRescord.Email ='aKANSHA.gupta@metacube.com';
        userRescord.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        update userRescord;
        User u = [Select id,Email,Name,Case_Comment_Work_Note__c from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        u.Case_Comment_Work_Note__c ='Milestone Alert - Email;';
        update u;
        system.runAs(u) {
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = 'group name',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Type__c = 'Queue',
                Group_Id__c = g1.id);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = 'group name',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Type__c = 'User',
                Group_Id__c = g1.id,User__c = u.id);
            
            insert qurUser;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = conObjId,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'group name',
                OwnerId = qurUser.Group_Id__c,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase,
                Subject ='Subject'
            );
            try{
            insert c;
            }catch(Exception ex ){
                system.debug('ex = '+ex.getMessage());
            }
            
            Test.startTest();
            Case caseRecord =[Select id,Subject,OwnerId from Case where Subject ='Subject'];
            caseRecord.NextMilestoneStatus__c = CON_CSM.S_REMAINING_8_HOURS;
            update caseRecord;
            DAOH_Case.isEmailAlertSLAHaveSent = false;
            caseRecord.OwnerId =  u.Id;
            caseRecord.NextMilestoneStatus__c = CON_CSM.S_REMAINING_2_HOURS;
            update caseRecord;
            Test.stopTest();

        }
    }
    
    @istest
    static void testcheckAccountBasedOnContact(){
        Case caseRecord = [Select id,Subject,Description from Case where Subject ='Techno Test case'];
        Contact c =[Select id from Contact where LastName ='testSetupContact'];
        Test.startTest();
        try{
            caseRecord.ContactId = c.id;
            update caseRecord;
        }
        catch(Exception e)   
        {
           Boolean expectedExceptionThrown =  e.getMessage().contains('Account is not associated with the contact selected') ? true : false;
           //System.assertEquals(expectedExceptionThrown, true);
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeliverRnDAutomatedFollowUpMail(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Study__c studyRecord = new Study__c(Name = 'testSetupCaseTestStudy', Sponsor__c = sponsorAcctId,Protocol__c ='STUDY123');
        insert studyRecord;
        StudySiteContactRelationship__c siteConR1=new StudySiteContactRelationship__c(Study__c = studyRecord.Id, SiteNumber__c = 'SN12345',Investigator_Name__c = conObjId, Site_Name__c = accObjId);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        
        Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueRecord.Name = 'RnD - Global Investigator Services';
        queueRecord.QueueName__c ='RnD - Global Investigator Services';
        queueRecord.Type__c ='Queue';
        queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueRecord;
        Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUserRecord.Name ='RnD - Global Investigator Services';
        queueUserRecord.QueueName__c = 'RnD - Global Investigator Services';
        queueUserRecord.Type__c ='User';
        queueUserRecord.TECH_QueueUser__c = queueRecord.Id;
        queueUserRecord.User__c = UserInfo.getUserId();
        queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
        insert queueUserRecord;
        
        List<Case> afuCaseList = new List<Case>();
        Case caseRecord = new Case();
        caseRecord.Origin = 'Email';
        caseRecord.RecordTypeId = recordTypeIdRnD;
        caseRecord.Study__c = studyRecord.Id;
        caseRecord.Site_Related_to_the_Study__c = siteConR1.Id;
        caseRecord.CurrentQueue__c = queueUserRecord.Id;
        caseRecord.RnD_Email_Flag__c = TRUE;
        caseRecord.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord.LOS__c = 'EDC Support';
        caseRecord.SubType1__c = 'ERT';
        caseRecord.SubType2__c = 'Administration';
        caseRecord.SubType3__c = 'Patient Call';
        caseRecord.Status = 'New';
        caseRecord.SubStatus__c = 'Automated FU - Standard';
        caseRecord.Count_of_AFU__c = 1;
        caseRecord.ContactId = conObjId;
        caseRecord.Owner__c = 'LTMS';
        caseRecord.SuppliedEmail = 'testSetupcon@iqvia.com';
        caseRecord.StudyProtocolName__c = 'STUDY123';
        caseRecord.Site_Number__c = 'SN12345';
        afuCaseList.add(caseRecord);
        
        Case caseRecord2 = new Case();
        caseRecord2.Origin = 'Email';
        caseRecord2.RecordTypeId = recordTypeIdRnD;
        caseRecord2.Study__c = studyRecord.Id;
        caseRecord2.Site_Related_to_the_Study__c = siteConR1.Id;
        caseRecord2.CurrentQueue__c = queueUserRecord.Id;
        caseRecord2.RnD_Email_Flag__c = TRUE;
        caseRecord2.AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com';
        caseRecord2.LOS__c = 'Account Management';
        caseRecord2.SubType1__c = 'INES';
        caseRecord2.SubType2__c = 'Create Site';
        caseRecord2.SubType3__c = 'Incorrect AMF';
        caseRecord2.Status = 'New';
        caseRecord2.SubStatus__c = 'Automated FU - Standard';
        caseRecord2.Count_of_AFU__c = 1;
        caseRecord2.ContactId = conObjId;
        afuCaseList.add(caseRecord2);
        insert afuCaseList;
        
        Test.startTest();
        afuCaseList[0].LabProjectCode__c = 'LAB123';
        afuCaseList[0].Status = 'Waiting for';
        afuCaseList[0].SubStatus__c = 'Automated FU - Urgent';
        afuCaseList[0].RnD_Email_Flag__c = TRUE;
        afuCaseList[0].Count_of_AFU__c = 2;
        afuCaseList[1].LabProjectCode__c = 'LAB123';
        afuCaseList[1].Status = CON_CSM.S_RESOLVED;
        afuCaseList[1].SubStatus__c = 'Automated FU';
        afuCaseList[1].RnD_Email_Flag__c = TRUE;
        afuCaseList[1].Count_of_AFU__c = 2;
        update afuCaseList;
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testCreateActivitesbyRnDTemplate() {
        List<Case> caseList = [SELECT Id, RecordTypeName__c, Template__c, LOS__c FROM Case WHERE RecordTypeName__c =: CON_CSM.S_ACTIVITY_R_T];        
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
        cc.Active__c = true;
        cc.Type__c = 'Activity';
        cc.Pillar__c = 'R&D';
        cc.LOS__c = 'Account Management';
        cc.RnD_Template__c = 'Pre-Study Migration';
        cc.Activitties__c = 'CLT Check;RR Received;RR Checked;System Settings Received;';
        insert cc;
        
        for(Case rndCase : caseList) {
            rndCase.LOS__c = 'Account Management';
            rndCase.Template__c = 'Pre-Study Migration';
        }
        
        Test.startTest();
            update caseList;
        Test.stopTest();
    }

    @IsTest
    private static void testUpdateTicketCSM2BISM() {
        CSM_ExternalClient_info__c externalClientInfo = new CSM_ExternalClient_info__c();
        externalClientInfo.Name = 'BISM';
        externalClientInfo.Profile_Id__c = 'test';
        insert externalClientInfo;
        Case techCase = [SELECT Id, Status FROM Case WHERE RecordTypeName__c = 'TechnologyCase' LIMIT 1];
        techCase.Status = 'Closed';
        techCase.Service_Now_Incident_Number__c = '123';
        
        Test.startTest();
            update techCase;
        Test.stopTest();
    }
    
    @IsTest
    private static void testUpdateTicketCSM2BISM_WSC() {
        CSM_ExternalClient_info__c externalClientInfo = new CSM_ExternalClient_info__c();
        externalClientInfo.Name = 'BISM';
        externalClientInfo.Profile_Id__c = 'test';
        insert externalClientInfo;
        Case techCase = [SELECT Id, Status FROM Case WHERE RecordTypeName__c = 'TechnologyCase' LIMIT 1];
        techCase.Status = 'Closed';
        techCase.Service_Now_Incident_Number__c = '123';
        techCase.ServiceNowSystemType__c = CON_CSM.S_BISM;
        techCase.Subject = 'update tech case';
        
        Test.startTest();
            update techCase;
        Test.stopTest();
    }
    
    @IsTest
    private static void testSaveOLACase() {
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(u) {
            Group g1 = new Group(Name = 'testQueue', type = 'Queue', DoesSendEmailToMembers = true, Email = 'testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = u.Id, GroupId = g1.Id);
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Name = grpUser.group.Name, Type__c = 'Queue',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Group_Id__c = grpUser.groupId);
            insert qur;
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Case techCase = [SELECT Id, CurrentQueue__c, Priority  FROM Case WHERE RecordTypeName__c =: CON_CSM.S_TECHNO_SOL LIMIT 1];
            techCase.Priority = 'Priority 1';
            techCase.Subject = 'Priority 1 update';
            techCase.AssignCaseToCurrentUser__c = true;
            techCase.CurrentQueue__c = qurUSer.Id;
            CaseOLA__c ola = new CaseOLA__c(Case__c = techCase.Id, IsActive__c = true, Previous_Queue__c = techCase.CurrentQueue__c, Current_Queue__c = 'testQueue',
                                            CompletionOLADate__c = null, Priority__c = techCase.Priority);
            insert ola;
            
            Test.startTest();
                update techCase;
            Test.stopTest();
        }

    }
    
    @IsTest
    private static void testSaveOLACaseOnUpdate() {
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(u) {
            Group g1 = new Group(Name = 'testQueue', type = 'Queue', DoesSendEmailToMembers = true, Email = 'testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = u.Id, GroupId = g1.Id);
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Name = grpUser.group.Name, Type__c = 'Queue',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Group_Id__c = grpUser.groupId);
            insert qur;
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true, Type__c = 'User', Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Case techCase = [SELECT Id, CurrentQueue__c, Priority  FROM Case WHERE RecordTypeName__c =: CON_CSM.S_TECHNO_SOL LIMIT 1];
            techCase.Priority = 'Priority 1';
            techCase.Subject = 'Priority 1 update';
            CaseOLA__c ola = new CaseOLA__c(Case__c = techCase.Id, IsActive__c = true, Previous_Queue__c = techCase.CurrentQueue__c, Current_Queue__c = 'testQueue',
                                            CompletionOLADate__c = null, Priority__c = techCase.Priority);
            insert ola;
            
            Test.startTest();
                update techCase;
            Test.stopTest();
        }
    }   
    
    @IsTest 
    private static void testCloneEmailMessagefromParentforRDCase() {
        Account accountRecord = [SELECT Id, Name, AccountCountry__c FROM Account WHERE Name = 'testSetupTestSiteAccount1'][0];       
        Contact contactRecord = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName testSetupContact' LIMIT 1];
        Study__c study = [SELECT Id, Name, Sponsor__c FROM Study__c WHERE Name = 'testSetupCaseTestStudy' LIMIT 1];
        Queue_User_Relationship__c queueUser = [SELECT Id FROM Queue_User_Relationship__c WHERE Type__c = 'Queue' LIMIT 1];       
        Id RecordTypeIdRandD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        StudySiteContactRelationship__c siteConR1 = new StudySiteContactRelationship__c(Study__c = study.Id, Investigator_Name__c = contactRecord.Id, Site_Name__c = accountRecord.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        insert email;
        
        Case caseRecord = CSM_TestDataFactory.createCase(accountRecord.Id, contactRecord.Id, RecordTypeIdRandD, null, 'Email', null, 'Activity Case', 'Actvity Case', null);
        caseRecord.Study__c = study.Id;
        caseRecord.CurrentQueue__c = queueUser.Id;
        caseRecord.Site_Related_to_the_Study__c = siteConR1.Id;
        caseRecord.Owner__c = email.Id;
        
        Test.startTest();
        insert caseRecord;
        DAOH_Case.updateCaseLastModifiedDateOnPostInsert(new List<Id>{caseRecord.Id});
        Test.stopTest();
    }
    
    @IsTest
    private static void testSendEmailtoOwnerDataPillar() {
        Queue_User_Relationship__c queues1 = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' AND Type__c = 'Queue'];
        Queue_User_Relationship__c queueUser1 = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' AND Type__c = 'User'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'testSetupTestSiteAccount1'];
        Contact contact = new Contact(Firstname = 'Brian', Lastname = 'Dent test', Phone = '(619)852-4569', Department = 'Mission Control', Title = 'Mission Specialist - Neptune',
                                      Email = 'john.test@acme.com', Portal_Case_Type__c = 'Information Offering', Contact_User_Type__c = 'HO User', PreferredLanguage__c = 'en_US', 
                                      AccountId = acc.Id);
        insert contact;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = queues1.Id;
        dT.Account__c = acc.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = queues1.Id;
        dd.Account__c = acc.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        
        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john.test@acme.com', IsActive = true, ContactId = contact.Id, ProfileId = profilId,
                             Username = 'johndata.test@acme.com.csh', LastName = 'testLastName', CommunityNickname = 'testCommunityNicknameCSH', 
                             TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert user;
        
        System.runAs(user) {
            Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Brian Dent test' LIMIT 1].Id;
            Queue_User_Relationship__c ff = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' LIMIT 1 ]; 
            Product2 p2 = UTL_TestData.createProduct();
            p2.Name = 'DDE';
            p2.SpecificToCSM__c = True;
            Insert p2;
            
            CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c();
            cc1.Product__c = p2.Id;
            cc1.Pillar__c = 'Information Offering';
            cc1.SubType1__c = 'DATA MGT/PRODUCTION';
            cc1.SubType2__c = 'DATA ISSUES';  
            cc1.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
            cc1.Active__c = true;
            Insert cc1;
            
            Case cs = new Case();
            cs.ContactId = conObjId;
            cs.AccountId = acc.Id;
            cs.AssignCaseToCurrentUser__c = false;
            cs.OwnerId = UserInfo.getUserId();
            cs.RecordTypeId = recordTypeIdData;
            cs.Priority = 'Medium';
            cs.Origin = 'Customer Portal';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Portal Data Test case';
            cs.Description = 'Portal Data Test case';
            cs.Status = 'New';
            cs.RootCause__c = 'Access Request';
            cs.CurrentQueue__c = ff.Id;
            cs.Previous_Queue__c = 'Tech CA TechSupport OK T2a';
            cs.Case_CategorizationId__c = cc1.Id;
            cs.SubType1__c = 'DATA MGT/PRODUCTION';
            cs.SubType2__c = 'DATA ISSUES';  
            cs.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
            cs.Device__c = 'iPhone';
            cs.Resolution__c = 'test resolution';
            cs.CSM_QI_Data_Originator__c = user.Id;
            cs.HCRSWebID__c = CON_CSM.S_ORGANIZATIONS;
            
            Test.startTest();
                Insert cs;
            Test.stopTest();
        }
    }
    
    @isTest
    static void testcheckAFUNextCloseDate(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTech = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Profile serviceProfile = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        PermissionSet techPS = [SELECT Id FROM PermissionSet WHERE Name = 'TECHNO_Case_Record_Type_Contact_Fields_Access'];
        User adminUser = new User(LastName = 'adminTestUser2', Alias = 'atest', Email = 'admintestuser@iqvia.com', Username = 'admintestuser@iqvia.com',
                                  CommunityNickname = 'adminTestUser', ProfileId = adminProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                  LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        adminUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert adminUser;
        User techUser = new User(LastName = 'techTestUser2', Alias = 'ttest', Email = 'testUser2@iqvia.com', Username = 'techTestUser@iqvia.com',
                                 CommunityNickname = 'techTestUser', ProfileId = serviceProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                 LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        techUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert techUser;
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        System.runAs(adminUser){
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            queueRecord.Name = 'Q1';
            queueRecord.QueueName__c = 'Q1';
            queueRecord.Type__c = 'Queue';
            queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            queueUserRecord.Name = 'Q1';
            queueUserRecord.QueueName__c = 'Q1';
            queueUserRecord.Type__c = 'User';
            queueUserRecord.User__c = UserInfo.getUserId();
            queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueUserRecord;
            
            Queue_User_Relationship__c techQueueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            techQueueUserRecord.Name = 'Q1';
            techQueueUserRecord.QueueName__c = 'Q1';
            techQueueUserRecord.Type__c = 'User';
            techQueueUserRecord.User__c = techUser.Id;
            techQueueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert techQueueUserRecord;
            
            Case c1 = new Case(
                AccountId = accObjId,
                ContactId = conObjId,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'Q1',
                CurrentQueue__c = queueUserRecord.Id,
                RecordTypeId = recordTypeIdTech,
                Subject = 'Test Subject 1',
                Description = 'Test Description 1'
            );
            insert c1;
        Test.startTest();
        try{
            c1.AFU_TECH__c = true;
            c1.Status = 'Closed';
            c1.Count_of_AFU__c = 4;
            c1.AFU_Email_Flag__c = true;
            update c1;
            
            Case techCaseRecord2 = new Case(
                        AccountId = accObjId,
                        ContactId = conObjId,
                        Origin = 'Agent Initiated',
                        Status = 'New',
                        InitialQueue__c = 'Q1',
                        CurrentQueue__c = techQueueUserRecord.Id,
                        RecordTypeId = recordTypeIdTech,
                        Subject ='Test Subject 2',
                        ParentId = c1.Id,
                        Description = 'Test Description 2'
                    );
                    insert techCaseRecord2;  
                    c1.AFU_TECH__c = true;
                    update c1;
                    techCaseRecord2.Status = 'InProgress';
                    update techCaseRecord2;
        }catch(Exception ex){}
        Test.stopTest();
        }
    }

    @isTest
    static void testTechValidationForAllPillar(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTech = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Profile serviceProfile = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        PermissionSet techPS = [SELECT Id FROM PermissionSet WHERE Name = 'TECHNO_Case_Record_Type_Contact_Fields_Access'];
        User adminUser = new User(LastName = 'adminTestUser2', Alias = 'atest', Email = 'admintestuser@iqvia.com', Username = 'admintestuser@iqvia.com',
                                  CommunityNickname = 'adminTestUser', ProfileId = adminProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                  LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        adminUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert adminUser;
        User techUser = new User(LastName = 'techTestUser2', Alias = 'ttest', Email = 'testUser2@iqvia.com', Username = 'techTestUser@iqvia.com',
                                 CommunityNickname = 'techTestUser', ProfileId = serviceProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                 LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        techUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert techUser;
        insert new PermissionSetAssignment(AssigneeId = techUser.id, PermissionSetId = techPS.Id);
        
        System.runAs(adminUser){            
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            queueRecord.Name = 'Q1';
            queueRecord.QueueName__c = 'Q1';
            queueRecord.Type__c = 'Queue';
            queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            queueUserRecord.Name = 'Q1';
            queueUserRecord.QueueName__c = 'Q1';
            queueUserRecord.Type__c = 'User';
            queueUserRecord.User__c = UserInfo.getUserId();
            queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueUserRecord;
            Queue_User_Relationship__c techQueueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            techQueueUserRecord.Name = 'Q1';
            techQueueUserRecord.QueueName__c = 'Q1';
            techQueueUserRecord.Type__c = 'User';
            techQueueUserRecord.User__c = techUser.Id;
            techQueueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert techQueueUserRecord;
            
            Case techCaseRecord1 = new Case(
                AccountId = accObjId,
                ContactId = conObjId,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'Q1',
                CurrentQueue__c = queueUserRecord.Id,
                RecordTypeId = recordTypeIdTech,
                Subject = 'Test Subject 1',
                Description = 'Test Description 1'
            );
            insert techCaseRecord1;
            
            Test.startTest();
            try{
                System.runAs(techUser){
                    Case techCaseRecord2 = new Case(
                        AccountId = accObjId,
                        ContactId = conObjId,
                        Origin = 'Agent Initiated',
                        Status = 'New',
                        ParentId = techCaseRecord1.Id,
                        InitialQueue__c = 'Q1',
                        CurrentQueue__c = techQueueUserRecord.Id,
                        RecordTypeId = recordTypeIdTech,
                        Subject ='Test Subject 2',
                        Description = 'Test Description 2'
                    );
                    insert techCaseRecord2;
                    
                    Case techCaseRecord3 = new Case(
                        AccountId = accObjId,
                        ContactId = conObjId,
                        Origin = 'Agent Initiated',
                        ParentId = techCaseRecord2.Id,
                        Status = 'New',
                        InitialQueue__c = 'Q1',
                        CurrentQueue__c = techQueueUserRecord.Id,
                        RecordTypeId = recordTypeIdTech,
                        Subject ='Test Subject 3',
                        Description = 'Test Description 3'
                    );
                    insert techCaseRecord3;
                    
                    Case techCaseRecord4 = new Case(
                        AccountId = accObjId,
                        ContactId = conObjId,
                        Origin = 'Agent Initiated',
                        Status = 'New',
                        ParentId = techCaseRecord3.Id,
                        InitialQueue__c = 'Q1',
                        CurrentQueue__c = techQueueUserRecord.Id,
                        RecordTypeId = recordTypeIdTech,
                        Subject ='Test Subject 4',
                        Description = 'Test Description 4'
                    );
                    insert techCaseRecord4;
                }
            }
            catch(Exception ex){}
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testDataValidationForAllPillar(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        PermissionSet dataPS = [SELECT Id FROM PermissionSet WHERE Name = 'DATARecordTypeUSFieldAccess'];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile serviceProfile = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        User adminUser = new User(LastName = 'adminTestUser2', Alias = 'atest', Email = 'admintestuser@iqvia.com', Username = 'admintestuser@iqvia.com',
                                  CommunityNickname = 'adminTestUser', ProfileId = adminProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                  LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        adminUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert adminUser;
        User dataUser = new User(LastName = 'dataTestUser2', Alias = 'dtest', Email = 'testUser2@iqvia.com', Username = 'dataTestUser@iqvia.com',
                                 CommunityNickname = 'dataTestUser', ProfileId = serviceProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                 LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        dataUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert dataUser;
        insert new PermissionSetAssignment(AssigneeId = dataUser.id, PermissionSetId = dataPS.Id);
        
        System.runAs(adminUser){
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            queueRecord.Name = 'Q1';
            queueRecord.QueueName__c ='Q1';
            queueRecord.Type__c ='Queue';
            queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
            queueUserRecord.Name = 'Q1';
            queueUserRecord.QueueName__c = 'Q1';
            queueUserRecord.Type__c = 'User';
            queueUserRecord.User__c = dataUser.Id;
            queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueUserRecord;
            
            System.runAs(dataUser){
                Case dataCase = new Case(
                    AccountId = sponsorAcctId,
                    ContactId = conObjId,
                    Origin = 'Customer Portal',
                    Status = 'New',
                    RecordTypeId = recordTypeIdData,
                    CurrentQueue__c = queueUserRecord.Id,
                    Subject = 'Test Subject'
                );
                Test.startTest();
                try{
                    insert dataCase;
                }
                catch(Exception ex){}
                Test.stopTest();
            }
        }
    }
    
    /** @isTest
    static void testRnDValidationForAllPillar(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        Profile serviceProfile = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole portalRole = [SELECT Id From UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        PermissionSet rndPS = [SELECT Id FROM PermissionSet WHERE Name = 'R_D_Case_Record_Type_Study_Activity_Objects_Access'];
        User adminUser = new User(LastName = 'adminTestUser2', Alias = 'atest', Email = 'admintestuser@iqvia.com', Username = 'admintestuser@iqvia.com',
                                  CommunityNickname = 'adminTestUser', ProfileId = adminProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                  LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        adminUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert adminUser;
        User rndUser = new User(LastName = 'rndTestUser2', Alias = 'rtest', Email = 'testUser2@iqvia.com', Username = 'rndTestUser2@iqvia.com',
                                CommunityNickname = 'rndTestUser', ProfileId = serviceProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserRoleId = portalRole.Id,
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        rndUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert rndUser;
        insert new PermissionSetAssignment(AssigneeId = rndUser.id, PermissionSetId = rndPS.Id);
        
        System.runAs(adminUser){
            Study__c studyRecord = new Study__c(Name = 'testSetupCaseTestStudy', Sponsor__c = sponsorAcctId);
            insert studyRecord;
            StudySiteContactRelationship__c siteConR1=new StudySiteContactRelationship__c(Study__c = studyRecord.Id, Investigator_Name__c = conObjId, Site_Name__c = accObjId);
            siteConR1.SiteNumber__c = 'SITE01';
            siteConR1.Lab_Site_Number__c = 'LABSITE01';
            insert siteConR1;
            
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c();
            queueRecord.Name = 'Q1';
            queueRecord.QueueName__c ='Q1';
            queueRecord.Type__c = 'Queue';
            queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c();
            queueUserRecord.Name = 'Q1';
            queueUserRecord.QueueName__c = 'Q1';
            queueUserRecord.Type__c = 'User';
            queueUserRecord.User__c = UserInfo.getUserId();
            queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueUserRecord;
            Queue_User_Relationship__c rndQueueUserRecord = new Queue_User_Relationship__c();
            rndQueueUserRecord.Name = 'Q1';
            rndQueueUserRecord.QueueName__c = 'Q1';
            rndQueueUserRecord.Type__c = 'User';
            rndQueueUserRecord.User__c = rndUser.Id;
            rndQueueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert rndQueueUserRecord;
            
            Case rndCaseRecord1 = new Case();
            rndCaseRecord1.Origin = 'Email';
            rndCaseRecord1.RecordTypeId = recordTypeIdRnD;
            rndCaseRecord1.Study__c = studyRecord.Id;
            rndCaseRecord1.Site_Related_to_the_Study__c = siteConR1.Id;
            rndCaseRecord1.CurrentQueue__c = queueUserRecord.Id;
            rndCaseRecord1.LOS__c = 'EDC Support';
            rndCaseRecord1.SubType1__c = 'ERT';
            rndCaseRecord1.SubType2__c = 'Administration';
            rndCaseRecord1.SubType3__c = 'Patient Call';
            rndCaseRecord1.Status = 'New';
            rndCaseRecord1.ContactId = conObjId;
            insert rndCaseRecord1;
            
            
            try{
                System.runAs(rndUser){
                    Case rndCaseRecord2 = new Case();
                    rndCaseRecord2.Origin = 'Email';
                    rndCaseRecord2.RecordTypeId = recordTypeIdRnD;
                    rndCaseRecord2.Study__c = studyRecord.Id;
                    rndCaseRecord2.Site_Related_to_the_Study__c = siteConR1.Id;
                    rndCaseRecord2.CurrentQueue__c = rndQueueUserRecord.Id;
                    rndCaseRecord2.LOS__c = 'EDC Support';
                    rndCaseRecord2.SubType1__c = 'ERT';
                    rndCaseRecord2.SubType2__c = 'Administration';
                    rndCaseRecord2.SubType3__c = 'Patient Call';
                    rndCaseRecord2.Status = 'New';
                    rndCaseRecord2.ParentId = rndCaseRecord1.Id;
                    rndCaseRecord2.ContactId = conObjId;
                    insert rndCaseRecord2;
                    Test.startTest();
                    Case rndCaseRecord3 = new Case();
                    rndCaseRecord3.Origin = 'Email';
                    rndCaseRecord3.RecordTypeId = recordTypeIdRnD;
                    rndCaseRecord3.Study__c = studyRecord.Id;
                    rndCaseRecord3.Site_Related_to_the_Study__c = siteConR1.Id;
                    rndCaseRecord3.CurrentQueue__c = rndQueueUserRecord.Id;
                    rndCaseRecord3.LOS__c = 'EDC Support';
                    rndCaseRecord3.SubType1__c = 'ERT';
                    rndCaseRecord3.SubType2__c = 'Administration';
                    rndCaseRecord3.SubType3__c = 'Patient Call';
                    rndCaseRecord3.Status = 'New';
                    rndCaseRecord3.ParentId = rndCaseRecord2.Id;
                    rndCaseRecord3.ContactId = conObjId;
                    insert rndCaseRecord3;
                    Test.stopTest();
                }
            }
            catch(Exception ex){}
            
            
        }
    }*/
 
    @istest
    static void testrestrictQueueForDispatch(){
        Account acct1 = new Account(
            Name = 'TestAcc',
            Website='http://www.iqvia.com',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct1;
        
        Contact Con1 = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct1.Id);
        insert Con1;
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct1.Id,Type = 'TECHNO',
                                          BusinessHoursId = busId.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        User userRescord = new User(id = UserInfo.getUserId());
        userRescord.Email ='aKANSHA.gupta@metacube.com';
        userRescord.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        update userRescord;
        User u = [Select id,Email,Name,Case_Comment_Work_Note__c from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        List <CSM_Queue_Dispatch_Case_Permissions__c> dispatchBalckListData = new List<CSM_Queue_Dispatch_Case_Permissions__c>();
        CSM_Queue_Dispatch_Case_Permissions__c dispatchCP = new CSM_Queue_Dispatch_Case_Permissions__c();
        system.runAs(u) {
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            Product2 p2 = UTL_TestData.createProduct();
            p2.Name = 'Nexxus MI';
            p2.SpecificToCSM__c = True;
            insert p2;
            CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
            cc.Product__c= p2.Id;
            cc.SubType1__c = 'Incident-Module';
            cc.SubType2__c = 'Formularies';  
            cc.SubType3__c = '--none--';
            cc.Active__c = true;
            cc.Type__c = 'Categorization';
            cc.Pillar__c = 'Information Offering';
            cc.ServiceNow_GUID__c = '123556575';
            insert cc;
		    ServiceNow_Group__c service=new ServiceNow_Group__c();
            service.Group_ID__c='123556575';
            service.Name = 'Service 123556575';
		    service.SystemType__c = 'Internal';
            service.Order__c = 1;
            insert service;
            Asset a3 = new Asset(Name = 'Nexxus MI', AccountId = acct1.Id, Product2Id = p2.id, Status ='Installed');
            insert a3;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Name = 'group name',
                Type__c = 'Queue',
                Group_Id__c = g1.id);
            insert qur;
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Name = 'group name',
                Type__c = 'User',
                Group_Id__c = g1.id,User__c = u.id);
            
            insert qurUser;
            Queue_User_Relationship__c qu2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
                Name = 'group name2',
                Type__c = 'Queue',
                Group_Id__c = g1.id);
            insert qu2;
            dispatchCP.Source_Queue__c =qur.id;
            dispatchCP.Destination_Queue__c = qu2.Id;
            dispatchCP.Products__c ='Nexxus MI';
            dispatchCP.Type__c = 'Restrict';
            dispatchCP.RecordType_Name__c = 'TechnologyCase';
            dispatchBalckListData.add(dispatchCP);
            insert dispatchBalckListData;
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct1.Id,
                ContactId = con1.Id,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'group name',
                OwnerId = qurUser.Group_Id__c,
                currentQueue__c = qurUser.id,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase,
                AssetId = a3.Id,
                Case_CategorizationId__c = cc.Id,
                ProductName__c= 'Nexxus MI',
                SubType1__c = 'Incident-Module',
                SubType2__c = 'Formularies',  
                SubType3__c = '--none--',
                Subject ='Subject',
                ServiceNow_Group__c = service.Id,
                ServiceNowSystemType__c = 'Internal'
            );
            try{ 
                Test.startTest();
                insert c;
                Case caseRecord =[Select id,Subject,OwnerId,currentQueue__c,Status,ProductName__c from Case where Subject ='Subject'];
                
                caseRecord.OwnerId =  u.Id;
                update caseRecord;   
                caseRecord.OwnerId = qurUser.Group_Id__c;
                update caseRecord;
                
            }
            
            catch(Exception e)   
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('You are not authorized to dispatch or assigned to the selected Tier. Please change the destination Queue.') ? true : false;
                //System.assertEquals(expectedExceptionThrown, true); 
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCheckForCRCAlertCaseProtocol(){
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Study__c std = CSM_Util.createStudy(sponsorAcctId);
        std.Name ='Custom Name1211';
        std.Protocol__c = 'Test Proto';
        insert std;
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
            Name = 'group name',
            Type__c = 'Queue',
            Group_Id__c = UserInfo.getUserId());
        insert qur;
        Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,
            Name = 'group name',
            Type__c = 'User',
            Group_Id__c = UserInfo.getUserId(),User__c = UserInfo.getUserId());
        insert qurUser;
        
        List<Case> caseList = new List<Case>();
        
        Case case1 = new Case();
        case1.RecordTypeId = recordTypeIdRnD;
        case1.ContactId = conObjId;
        case1.Origin = 'External Service';
        case1.CurrentQueue__c = qurUser.Id;
        case1.LabProjectCode__c = 'Test Data';
        case1.Subject = 'Dummy Data';
        case1.CRC_Issue_Insert_Date_time__c = (Datetime)Date.today();
        case1.StudyProtocolName__c = 'Test Proto';
        caseList.add(case1);
        Case case2 = new Case();
        case2.RecordTypeId = recordTypeIdRnD;
        case2.ContactId = conObjId;
        case2.Origin = 'External Service';
        case2.CurrentQueue__c = qurUser.Id;
        case2.LabProjectCode__c = 'Test Data 2';
        case2.Subject = 'Dummy Data 2';
        case2.CRC_Issue_Insert_Date_time__c = (Datetime)Date.today();
        caseList.add(case2);
        
        Test.startTest();
        insert caseList;
        Test.stopTest();
    }
    
    @isTest
    static void testSetCRCAlertCaseDetails(){
        Id sponsorAcctId = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestSponsorAccount1' LIMIT 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdRnD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Study__c std = CSM_Util.createStudy(sponsorAcctId);
        std.Name ='Custom Name1211';
        std.Protocol__c = 'Test Proto';
        insert std;
        Queue_User_Relationship__c qur = new Queue_User_Relationship__c(Name = 'RnD - Global CRC Alert',Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Type__c = 'Queue',Group_Id__c = UserInfo.getUserId(), Tier__c = 'Tier 1');
        insert qur;
        Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(Name = 'RnD - Global CRC Alert',Type__c = 'User', Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true,Tier__c = 'Tier 1', Group_Id__c = UserInfo.getUserId(), User__c = UserInfo.getUserId());
        insert qurUser;
        
        Case case1 = new Case();
        case1.RecordTypeId = recordTypeIdRnD;
        case1.ContactId = conObjId;
        case1.CurrentQueue__c = qurUser.Id;
        case1.LabProjectCode__c = 'Test Data';
        case1.CRC_Issue_Insert_Date__c = '2020-08-15';
        case1.CRC_Issue_Insert_Time__c = '10:10 AM';
        case1.CRC_Issue_Insert_Date_time__c = Datetime.now();
        case1.StudyProtocolName__c = 'Test Proto';
        case1.CRC_Account_Number__c = '121212';
        case1.CRC_Order_Unit__c = '10';
        case1.CRC_Alert_Category__c = 'UserGroup';
        insert case1;
        Test.startTest();
        case1.Service_Now_Incident_Number__c = '12453';
        case1.Prescriber__c = '44504';
        case1.Watch_List_User__c = Userinfo.getUserId()+',';
        case1.Status = 'In Progress';
        update case1;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseMilestoneForClosedCase(){
        Case techCase = [SELECT Id, SLA_Policies__c, Status, SubStatus__c, ContactId, AccountId FROM Case WHERE RecordTypeName__c = 'TechnologyCase' AND Origin = 'Customer Portal' LIMIT 1];
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=techCase.AccountId, BusinessHoursId = busId.Id, Type = 'Techno CC');
        insert entl;
        
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues1.Name ='Q1';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.Tier__c = 'Tier 1';
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUser1.Name ='Q1';
        queueUser1.QueueName__c ='Q1';
        queueUser1.Type__c ='User';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.Tier__c = 'Tier 1';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = queues1.Id;
        dT.Account__c = techCase.AccountId;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = queues1.Id;
        dd.Account__c = techCase.AccountId;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        Id csmProfileId = [select Id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User communityUser = New User(Alias = 'com', Email = 'testuser@mail.com',IsActive =true , ContactId = techCase.ContactId, ProfileId = csmProfileId, Username =' testuser@ss_mail.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert communityUser;
        Queue_User_Relationship__c a = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        a.Name ='Q1';
        a.QueueName__c ='Q1';
        a.Type__c ='User';
        a.Tier__c = 'Tier 1';
        a.User__c = communityUser.Id;
        insert a;
        Queue_User_Relationship__Share queues1Sh = new Queue_User_Relationship__Share();
        queues1Sh.ParentId = queues1.Id;
        queues1Sh.UserOrGroupId = communityUser.Id;
        queues1Sh.AccessLevel = 'Read';
        queues1Sh.RowCause='manual';
        Database.insert(queues1Sh,false);
        Queue_User_Relationship__Share queueUser1Sh = new Queue_User_Relationship__Share();
        queueUser1Sh.ParentId = queueUser1.Id;
        queueUser1Sh.UserOrGroupId = communityUser.Id;
        queueUser1Sh.AccessLevel = 'Read';
        queueUser1Sh.RowCause='manual';
        Database.insert(queueUser1Sh,false);
        Queue_User_Relationship__Share aSh = new Queue_User_Relationship__Share();
        aSh.ParentId = a.Id;
        aSh.UserOrGroupId = communityUser.Id;
        aSh.AccessLevel = 'Read';
        aSh.RowCause='manual';
        Database.insert(aSh,false);
        CSM_QI_Data_Portal_Queue_User_details__Share dTSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
        dTSh.ParentId = dT.Id;
        dTSh.UserOrGroupId = communityUser.Id;
        dTSh.AccessLevel = 'Read';
        dTSh.RowCause='manual';
        Database.insert(dTSh,false);
        CSM_QI_Data_Portal_Queue_User_details__Share ddSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
        ddSh.ParentId = ddSh.Id;
        ddSh.UserOrGroupId = communityUser.Id;
        ddSh.AccessLevel = 'Read';
        ddSh.RowCause='manual';
        Database.insert(ddSh,false);
        techCase.Status = 'Resolved with Customer';
        techCase.SubStatus__c = 'Pending Resolution Confirmation';
        techCase.SLA_Policies__c = 'Non-Code';
        techCase.EntitlementId = entl.Id;
        techCase.OwnerId = communityUser.Id;
        update techCase;
        Test.startTest();
        System.runAs(communityUser){
            techCase.Status = 'Closed';
            techCase.Force_CSAT_Email_Survey__c = true;
            techCase.Device__c = 'Laptop';
            techCase.Resolution__c = 'Case Resolved';
            update techCase;
        }
        Test.stopTest();
    }

    @IsTest
    private static void testCaseRecordTypeUpdate() {
        Id bhId = [SELECT Id FROM BusinessHours WHERE Name = 'Default'].Id;
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(u) {
            Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            Id recordTypeIdTech = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            Case techCase = [SELECT Id, RecordTypeId, Priority,Urgency__c,Techno_Impact__c,Case_Type__c,ContactId  FROM Case WHERE RecordTypeName__c =: CON_CSM.S_TECHNO_SOL LIMIT 1];
            techCase.RecordTypeId = recordTypeIdData;
            update techCase;
            Test.startTest();
            techCase.OnBehalfOf__c = techCase.ContactId;
            techCase.RecordTypeId = recordTypeIdTech;
            update techCase;
            Test.stopTest();
        }
    }

    @isTest
    static void testPreventCaseCreationFromOOOE2C(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        CSM_Config_E2C_MessageList__c e2cList = new CSM_Config_E2C_MessageList__c();
        e2cList.Name = 'Out Of Office';
        e2cList.Message_Text__c = 'Out of Office';
        e2cList.RecordTypeNames__c = 'DATACase, RandDCase, TechnologyCase, ActivityPlan';
        insert e2cList;
        
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues1.Name ='Q1';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.Tier__c = 'Tier 1';
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='Q1';
        queueUser1.QueueName__c ='Q1';
        queueUser1.Type__c ='User';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.User__c = UserInfo.getUserId();
        queueUser1.Tier__c = 'Tier 1';
        insert queueUser1;
        
        Case e2cCase = new Case(
            Subject = 'Test E2C Out Of Office Case',
            Description = 'OOO Tech Case Description',
            AccountId = accObjId,
            ContactId = conObjId,
            Origin = 'Email',
            Status = 'New',
            InitialQueue__c = 'group name',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno,
            CurrentQueue__c = queueUser1.Id,
            CaseSource__c = 'Customer'
        );
        
        Test.startTest();
        try{
            insert e2cCase;
        }
        catch(Exception ex){
            Boolean flag = ex.getMessage().contains('Case can\'t be saved due to generated from Out Of Office') ? true : false;
            //System.assertEquals(True, flag);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAutomateCaseEscalation(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        BusinessHours busId = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.Tier__c = 'Tier 1';
        insert queues1;
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUser1.Name = 'Q1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Tier__c = 'Tier 1';
        queueUser1.Type__c = 'User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        
        Queue_User_Relationship__c queues2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues2.Name = 'Alphasoft';
        queues2.QueueName__c = 'Alphasoft';
        queues2.Type__c = 'Queue';
        queues2.Tier__c = 'Tier 1';
        insert queues2;
        Queue_User_Relationship__c queueUser2 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUser2.Name = 'Alphasoft';
        queueUser2.QueueName__c = 'Alphasoft';
        queueUser2.Type__c = 'User';
        queueUser2.User__c = UserInfo.getUserId();
        queueUser2.Tier__c = 'Tier 1';
        insert queueUser2;
        
        Queue_User_Relationship__c queues3 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queues3.Name = 'Tech - US Incent Tier1';
        queues3.QueueName__c = 'Tech - US Incent Tier1';
        queues3.Type__c = 'Queue';
        queues3.Tier__c = 'Tier 1';
        insert queues3;
        Queue_User_Relationship__c queueUser3 = new Queue_User_Relationship__c(Business_Hours__c = busId.Id,
                Out_Of_Office_Notification__c = true);
        queueUser3.Name = 'Tech - US Incent Tier1';
        queueUser3.QueueName__c = 'Tech - US Incent Tier1';
        queueUser3.Type__c = 'User';
        queueUser3.Tier__c = 'Tier 1';
        queueUser3.User__c = UserInfo.getUserId();
        insert queueUser3;
        
        List<Case> caseList = new List<Case>();
        Case agentCase = new Case(
            Subject = 'Test case escalation from agent origin',
            Description = 'Test case escalation from agent origin',
            AccountId = accObjId,
            ContactId = conObjId,
            Origin = 'Agent Initiated',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno,
            CurrentQueue__c = queueUser1.Id,
            CaseSource__c = 'Customer',
            Device__c = 'Laptop'
        );
        caseList.add(agentCase);
        
        Case portalCase = new Case(
            Subject = 'Test case escalation from customer portal origin',
            Description = 'Test case escalation from customer portal origin',
            AccountId = accObjId,
            ContactId = conObjId,
            Origin = 'Customer Portal',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno,
            CurrentQueue__c = queueUser1.Id,
            CaseSource__c = 'Customer',
            Device__c = 'Laptop'
        );
        caseList.add(portalCase);
        insert caseList;
        
        Test.startTest();
        caseList[0].CurrentQueue__c = queueUser2.Id;
        caseList[1].CurrentQueue__c = queueUser2.Id;
        update caseList;        
        caseList[0].CurrentQueue__c = queueUser3.Id;
        caseList[1].CurrentQueue__c = queueUser3.Id;
        caseList[0].IsEscalated = True;
        caseList[1].IsEscalated = True;
        update caseList;
        caseList[0].Status = 'Closed';
        caseList[1].Status = 'Closed';
        caseList[0].Force_CSAT_Email_Survey__c = true;
        caseList[1].Force_CSAT_Email_Survey__c = true;
        update caseList;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseOnOutboundMail(){
        Case cr = [SELECT Id, RecordTypeId, IsOutboundEmail__c,Priority,Urgency__c,Techno_Impact__c,Case_Type__c  FROM Case WHERE RecordTypeName__c =: CON_CSM.S_TECHNO_SOL LIMIT 1];
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = cr.Id, Incoming=False);
        Test.startTest();
        insert message;
        
        cr.IsOutboundEmail__c = true;
        update cr;
        Test.stopTest();
    }
    
    @isTest
    static void testCaseRCADocforTechCase(){
        Case cr = [SELECT Id, RecordTypeId, IsOutboundEmail__c,Priority,Urgency__c,Techno_Impact__c,Case_Type__c  FROM Case WHERE RecordTypeName__c =: CON_CSM.S_TECHNO_SOL and Case_Type__c = 'Problem' LIMIT 1];
        ContentVersion cV1 = new ContentVersion(Title='OS07. Internal Root Cause Analysis Form.docx', PathOnClient ='OS07. Internal Root Cause Analysis Form.docx',VersionData = Blob.valueOf('Test Content'), origin = 'H');
        Test.startTest();
        insert cV1;
        try{
            update cr;
        }
        catch(Exception ex){
        }
        Test.stopTest();
    }
    @isTest
    static void testElapsedTimeAge(){
        case newCase = UTL_TestData.createCase();
        //newCase.Status = 'Resolved';
        //newCase.ResolvedDatetime__c = system.now().addDays(5);
        insert newCase;
        Test.setCreatedDate(newCase.Id, system.now().addDays(-1));
        Test.startTest();
        newCase.ResolvedDatetime__c = system.now().addDays(5).addHours(2).addMinutes(30).addSeconds(60);
        system.debug('Created Date' +newCase.CreatedDate);
        update newCase;
        Test.stopTest();
        
    }

    @isTest
    static void testsendEmailForRecommendedArticles(){
        Test.startTest();
        Account acc = UTL_TestData.CreateAccount();
        
        Contact conCase = new Contact();
        conCase.AccountId = acc.Id;
        conCase.FirstName = 'Saurabhi';
        conCase.LastName = 'Sharmai';
        conCase.Salutation = 'Eng';
        conCase.Email = 'noreply@dummyui.com';
        conCase.PreferredLanguage__c = 'en_US';
        conCase.Portal_Case_Type__c = 'Information Offering; Technology Solutions';
        conCase.Contact_User_Type__c = 'Rep User';
        conCase.EmployeeNumber__c = '44504565';
        insert conCase;

        
        Case cs = UTL_TestData.createCase();

        cs.OwnerId = '0056A000000jAPA';
        cs.Origin = 'Email';
        cs.Subject = 'Unwanted fields to be hidden on Invoice Initiation irrespective to the Invoice record Details t';
        cs.Description = 'Fields should be hidden on Invoice Initiation which are visible on the Invoice Details tab. As of now the same page layout is used for the details tab on Invoice and for Invoice initiation flow. As per the requirement there should be different page layouts to be used in the Invoice Initiation and on Invoice Details tab. So, we can configure different field on invoice detail page and initiation flow.';
        cs.ProductName__c = 'Test';
        cs.SuppliedEmail = 'Chirag.chanana@metacube.com';
        cs.Contactid  = conCase.id;
        cs.Accountid = acc.id;
        insert cs;
        Test.stopTest();
    }
	@isTest
    static void testCloseChildCases(){
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        
        CSM_QI_Case_Categorization__c cc = [SELECT Id,ProductName__c,SubType1__c,SubType2__c,SubType3__c FROM CSM_QI_Case_Categorization__c WHERE SubType1__c = 'Incident-Module' LIMIT 1];      
        
        
        List<Case> caseList = new List<Case>();
        Case parentCase = new Case(
            Subject = 'parentCase',
            Description = 'This is parentCase',
            AccountId = accObjId,
            ContactId = conObjId,
            Origin = 'Agent Initiated',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno,
            CaseSource__c = 'Customer',
            Device__c = 'Laptop',
            Resolution__c = 'provided resolution',
            Case_CategorizationId__c = cc.Id,
            //RootCause__c ='Bad Behaviour',
            ProductName__c = cc.ProductName__c,
            SubType1__c = cc.SubType1__c,
            SubType2__c = cc.SubType2__c,
            SubType3__c = cc.SubType3__c,
            Is_Parent__c = true,
            Close_all_child_case_with_parent__c = true
        );
        insert parentCase;
        //caseList.add(parentCase);
        Test.startTest();
        Case childCase = new Case(
            Subject = 'Child Case',
            Description = 'This is child Case.',
            AccountId = accObjId,
            ContactId = conObjId,
            Origin = 'Customer Portal',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno,
            CaseSource__c = 'Customer',
            Device__c = 'Laptop',
            ParentId = parentCase.Id
        );
        insert childCase;
        //caseList.add(childCase);
        
          Case littleChildCase = new Case(
            Subject = 'Little Child Case',
            Description = 'This is Little  child Case.',
            AccountId = accObjId,
            ContactId = conObjId,
            Origin = 'Customer Portal',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno,
            CaseSource__c = 'Customer',
            Device__c = 'Laptop',
            ParentId = childCase.Id
        );
        insert littleChildCase;
        //caseList.add(littleChildCase);
        //insert caseList;
        
        parentCase.Force_CSAT_Email_Survey__c = true;
        parentCase.Status = 'Closed';
        update parentCase;       
        Test.stopTest();
    }
}