/**
 * @description       : Used to code coverage CAS_FLW_CSM_Case_SendAllEmailAlerts and
 *                      CAS_FL01_Portal_UpdateCaseOwnerWithOwner
 * @author            : mallikarjuna.reddyb@iqvia.com
 * @group             : 
 * @last modified on  : 9-15-2023
 * @last modified by  : mallikarjuna.reddyb@iqvia.com
**/
@isTest
private class TST_CAS_FLW_CSM_Case_SendAllEmailAlerts {
    @testSetup
    static void dataSetup() {
        Group g1 = new Group(Name='SendAllEmailAlerts', type='Queue');
        insert g1;
        QueuesObject q1 ;
        system.runAs(new User(id = UserInfo.getUserId())){
            q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
        }
        CSM_case_Trigger_Handler__c triggerControlSetting = new CSM_case_Trigger_Handler__c(SetupOwnerId=UserInfo.getOrganizationId(),Disable_Case_Trigger__c = true, Name='IQVIA',Difference_By_Last_Created_Time_Case__c = 60);
        insert triggerControlSetting;
        Account acct = new Account(Name = 'TestAccSendAllEmailAlerts',AccountCountry__c = 'BR', RDCategorization__c = 'Site',SendAutomaticCaseAcknowledgmentEmail__c = true, CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct;
        List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='EN', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsEN@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        
        Contact con2 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='PL', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsPL@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'pl', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con3 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='pt_BR', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertspt_BR@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'pt_BR', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con4 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='ro', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsro@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'ro', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con5 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='tr', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertstr@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'tr', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con6 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='de', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsde@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'de', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con7 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='fr', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsfr@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'fr', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con8 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='fi', Phone='(619)852-4569', Department='Mission Control',
                                   Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsfi@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'fi', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con9 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='ja', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsja@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'ja', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con10 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='ru', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsru@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'ru', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con11 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='uk', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsuk@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'uk', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con12 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='ko', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsko@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'ko', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con13 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='es', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertses@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'es', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con14 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='it', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsit@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'it', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con15 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='nl_NL', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsnl_NL@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'nl_NL', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        Contact con16 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='hu', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertshu@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'hu', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        conList.add(con1);conList.add(con2);conList.add(con3);conList.add(con4);conList.add(con5);conList.add(con6);conList.add(con7);
        conList.add(con8);conList.add(con9);conList.add(con10);conList.add(con11);conList.add(con12);conList.add(con13);conList.add(con14);
        conList.add(con15);conList.add(con16);
        insert conList;
        
        List<Asset> aList = new List<Asset>();
        Product2 p1 = new Product2( Name = 'DDD', Pillar__c = 'Information Offering; Technology Solutions',SpecificToCSM__c = True);
        insert p1;
        Product2 p2 = new Product2(Name = 'Nexxus MI', Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
        
        Asset a1 = new Asset(Name = 'DDD', AccountId = acct.Id, Product2Id = p1.id, Status ='Installed');
        aList.add(a1);
        
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        aList.add(a2);
        insert aList;
        List<CSM_QI_Case_Categorization__c> ccList = new List<CSM_QI_Case_Categorization__c>();
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c(Product__c = p1.Id, SubType1__c = 'Incident-Module',
        SubType2__c = 'Formularies', SubType3__c = '--none--', Active__c = true, Type__c = 'Categorization', Pillar__c = 'Technology Solutions');
        ccList.add(cc);
        CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c(Product__c= p2.Id, SubType1__c = 'Incident-Module',
        SubType2__c = 'Formularies', SubType3__c = '--none--', Active__c = true, Type__c = 'Categorization', Pillar__c = 'Information Offering');
        ccList.add(cc1);
        insert ccList;
        
        Queue_User_Relationship__c q = new Queue_User_Relationship__c(Name ='SendAllEmailAlerts',Tier__c ='Tier 1',Type__c ='Queue',User__c = UserInfo.getUserId()); 
        insert q;
        Queue_User_Relationship__c qu = new Queue_User_Relationship__c(Name ='SendAllEmailAlerts',Tier__c ='Tier 1',TECH_QueueUser__c = q.Id,Type__c ='User',User__c = UserInfo.getUserId());
        insert qu;
        List<CSM_QI_Data_Portal_Queue_User_details__c> dpList = new List<CSM_QI_Data_Portal_Queue_User_details__c>();
        CSM_QI_Data_Portal_Queue_User_details__c dpt = new CSM_QI_Data_Portal_Queue_User_details__c( Queue_User_Relationship__c = q.Id, Account__c = acct.Id, All_Current_Users__c = true, AccountCountry__c = 'BR',CaseRecordType__c = 'TechnologyCase',Type__c ='Queue Assignment',Order__c = 1);
        dpList.add(dpt);
        CSM_QI_Data_Portal_Queue_User_details__c dpd = new CSM_QI_Data_Portal_Queue_User_details__c( Queue_User_Relationship__c = q.Id,Account__c = acct.Id, All_Current_Users__c = true, AccountCountry__c = 'BR',CaseRecordType__c = 'DATACase',Type__c ='Queue Assignment',Order__c = 1);
        dpList.add(dpd);
            insert dpList;
        conList = [Select Id, PreferredLanguage__c,Email,Name from Contact where FirstName = 'EmailAlertsFirstName'];
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = null;
        List<User> lstUser = new List<User>();
        User autoUser = [select Id,Name from user where Name ='System' Limit 1 ];
        for(Contact con : conList){
            user = new User(Alias = 'a1s'+con.PreferredLanguage__c, Email = con.Email ,IsActive =true , ContactId = con.Id, ProfileId = profilId,Username =con.Email, LastName= con.Name, CommunityNickname ='dt1a'+con.PreferredLanguage__c, TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            lstUser.add(user);
        }
        insert lstUser;
        System.runAs(autoUser){
                try{
                    Id RecordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
                    List<Case> caselist = new List<Case>();
                    Case cs = null;
                    for(Contact con : conList){
                        cs = new Case(
                            Origin = 'Email',  AccountId = acct.ID,ContactId = con.Id,            
                            Subject = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:System '+con.PreferredLanguage__c,
                            Description = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:System '+con.PreferredLanguage__c,
                            SuppliedEmail = con.Email,
                            Status = 'New',
                            RecordTypeId = RecordTypeIdTechno,
                            From_EmailToCase__c = 'replytocsm@iqvia.com',
                            SendAutomaticAcknowledgmentEmail__c = 'Yes',
                            OwnerId = UserInfo.getUserId(),
                            Owner__c = UserInfo.getUserId(),
                            CurrentQueue__c = q.Id
                        );
                        caselist.add(cs);
                    }
                    insert caselist;
                }
                catch(Exception ex){
                    
                }
            }
        
    }
    
    @isTest
    static void testSystemLatestComentSendtoContact(){
        Test.startTest();
        try{
            List<Case> caselist = [Select Id,Status,CaseNumber,NewCaseComment__c,LastCaseComment__c,origin from Case where Subject like 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:System%'];
            for(Case cs : caselist){
                cs.NewCaseComment__c = true;
                cs.LastCaseComment__c = 'Test Comment '+cs.CaseNumber;
                cs.origin = 'Customer Portal';
                
            }
            update caselist;
        }
        catch(Exception ex){
            
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testSystemResolvedWithCustomer(){
        Test.startTest();
                try{
                    List<Case> caselist = [Select Id,Status,CaseNumber,NewCaseComment__c,LastCaseComment__c from Case where Subject like 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:System%'];
                    for(Case cs : caselist){
                        cs.From_EmailToCase__c = null;
                        cs.SendResolutionEmail__c = true;
                        cs.CaseSource__c = 'Customer';
                        cs.Status = 'Resolved with customer';
                        cs.SendAutomaticAcknowledgmentEmail__c = 'Account Choice';
                        cs.NewCaseComment__c = true;

                    }
                    update caselist;
                }
                catch(Exception ex){
                    
                }
            
        Test.stopTest();
    }
    
    @isTest
    static void testSystemClosed(){
        Test.startTest();
                try{
                    List<Case> caselist = [Select Id,Status,CaseNumber from Case where Subject like 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:System%'];
                    for(Case cs : caselist){
                        cs.From_EmailToCase__c = null;
                        cs.SendResolutionEmail__c = true;
                        cs.CaseSource__c = 'Customer';
                        cs.SendAutomaticAcknowledgmentEmail__c = 'Account Choice';
                        cs.Status = 'Closed';
                    }
                    update caselist;
                }
                catch(Exception ex){
                    
                }
            
        Test.stopTest();
    }
    
    @isTest
    static void testAgentSendEmails(){
        
        Test.startTest();
                try{
                    Account acct = [Select Id From Account limit 1];
                    List<Contact> conList = [Select Id, PreferredLanguage__c,Email from Contact where FirstName = 'EmailAlertsFirstName'];
                    Queue_User_Relationship__c q = [Select Id from Queue_User_Relationship__c Where Name ='SendAllEmailAlerts' and Type__c ='Queue' LIMIT 1];
                    Id RecordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
                    List<Case> caselist = new List<Case>();
                    Case cs = null;
                    for(Contact con : conList){
                        cs = new Case(
                            Origin = 'Chat',  AccountId = acct.ID,ContactId = con.Id,            
                            Subject = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Agent '+con.PreferredLanguage__c,
                            Description = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Agent '+con.PreferredLanguage__c,
                            CaseSource__c = 'Customer',
                            SuppliedEmail = con.Email,
                            Status = 'New',
                            RecordTypeId = RecordTypeIdTechno,
                            SendAutomaticAcknowledgmentEmail__c = 'Yes',
                            OwnerId = UserInfo.getUserId(),
                            CurrentQueue__c = q.Id
                        );
                        caselist.add(cs);
                    }
                    insert caselist;
                }
                catch(Exception ex){
                    
                }
        Test.stopTest();
    }
    
    @isTest
    static void testDataSystemSendEmail(){
        User autoUser = [select Id,Name from user where Name ='System' Limit 1 ];
        Test.startTest();
            System.runAs(autoUser){
                try{
                    Account acct = [Select Id From Account limit 1];
                    Contact con = [Select Id, PreferredLanguage__c,Email from Contact where FirstName = 'EmailAlertsFirstName' and  Lastname = 'EN' LIMIT 1];
                    Queue_User_Relationship__c q = [Select Id from Queue_User_Relationship__c Where Name ='SendAllEmailAlerts' and Type__c ='Queue' LIMIT 1];
                    Id RecordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
                    List<Case> caselist = new List<Case>();
                    Case cs = null;
                    List<String> datE2CList = new List<String>{'azsupport@iqvia.com','csm-in-requests@iqvia.com','eservice@iqvia.com','resteam@uk.imshealth.com','securnet.hscn@iqvia.com'};
                    for(String em : datE2CList){
                        cs = new Case(
                            Origin = 'Email',  AccountId = acct.ID,ContactId = con.Id,            
                            Subject = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Data:System '+con.PreferredLanguage__c,
                            Description = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Data:System '+con.PreferredLanguage__c,
                            SuppliedEmail = con.Email,
                            Status = 'New',
                            CaseSource__c = 'Customer',
                            RecordTypeId = RecordTypeIdTechno,
                            From_EmailToCase__c = em,
                            SendAutomaticAcknowledgmentEmail__c = 'Yes',
                            OwnerId = UserInfo.getUserId(),
                            CurrentQueue__c = q.Id
                        );
                        caselist.add(cs);
                    }
                    cs = new Case(
                        Origin = 'Web',  AccountId = acct.ID,ContactId = con.Id,            
                        Subject = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Data:Agent '+con.PreferredLanguage__c,
                        Description = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Data:Agent '+con.PreferredLanguage__c,
                        SuppliedEmail = con.Email,
                        Status = 'New',
                        CaseSource__c = 'Customer',
                        RecordTypeId = RecordTypeIdTechno,
                        SendAutomaticAcknowledgmentEmail__c = 'Account choice',
                        OwnerId = UserInfo.getUserId(),
                        Owner__c = UserInfo.getUserId(),
                        CurrentQueue__c = q.Id
                    );
                    caselist.add(cs);
                    insert caselist;
                }
                catch(Exception ex){
                    
                }
            }
        List<Case> caselist = [Select Id,Status,CaseNumber from Case where Subject like 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Data:%'];
        for(Case cs : caselist){
            cs.Status = 'Resolved';
        }
        update caselist;
        for(Case cs : caselist){
            cs.Status = 'Closed';
        }
        update caselist;
        Test.stopTest();
    }
    
    @isTest
    static void testTechPortalSendEmail(){
        
        Account acct = [Select Id From Account limit 1];
        List<User> autoUserList = [select Id,Name,ContactId,Email from user where Name like 'EmailAlertsFirstName%'];
        Queue_User_Relationship__c q = [Select Id from Queue_User_Relationship__c Where Name ='SendAllEmailAlerts' and Type__c ='Queue' LIMIT 1];
        Id RecordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        List<Case> caselist = new List<Case>();
        Case cs = null;
        
        Test.startTest();
        for(User autoUser : autoUserList){
            System.runAs(autoUser){
                try{
                    cs = new Case(
                        Origin = 'Customer Portal',  AccountId = acct.ID,ContactId = autoUser.ContactId,            
                        Subject = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Tech:Portal '+autoUser.ContactId,
                        Description = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Tech:Portal '+autoUser.ContactId,
                        SuppliedEmail = autoUser.Email,
                        Status = 'New',
                        CaseSource__c = 'Customer',
                        RecordTypeId = RecordTypeIdTechno,
                        SendAutomaticAcknowledgmentEmail__c = 'Yes',
                        OwnerId = UserInfo.getUserId(),
                        Owner__c = UserInfo.getUserId(),
                        CurrentQueue__c = q.Id
                    );
                    caselist.add(cs);
                }
                catch(Exception ex){
                    
                }
            }
        }
        cs = new Case(AccountId = acct.Id,
                      Origin = 'Chat', ContactId = autoUserList[0].ContactId,RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('IQVIALiveChat').getRecordTypeId(),
                      OwnerId = UserInfo.getUserId(),Owner__c = UserInfo.getUserId(),CurrentQueue__c = q.Id);
        caselist.add(cs);
           insert caselist; 
        Test.stopTest();
    }
}