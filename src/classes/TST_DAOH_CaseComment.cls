@isTest
private class TST_DAOH_CaseComment {
    @testSetup
    static void setup() {
        Account account = UTL_TestData.createAccount();
        account.Website='http://www.iqvia.com';
        insert account;
        
        Contact con = new Contact(FirstName = 'TestFirstName', Lastname = 'lastName123', Phone = '(619)852-4569', Department = 'Mission Control', 
                                  Title = 'Mission Specialist - Neptune', Email='testuser3133@iqvia.com', AccountId = account.Id,
                                  Portal_Case_Type__c = 'Information Offering', Contact_User_Type__c = 'HO User');
        insert con;
        Product2 product = UTL_TestData.createProduct();
        product.Name = 'DDD';
        product.SpecificToCSM__c = True;
        insert product;
        Asset asset = new Asset(Name = 'DDD', AccountId = account.Id, Product2Id = product.id);
        insert asset;
        
        List<CSM_QI_Data_Portal_Queue_User_details__c> DPQueue = new List<CSM_QI_Data_Portal_Queue_User_details__c>();
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = account.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        //insert dT;
        DPQueue.add(dT);
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.IQVIA_User__c = UserInfo.getUserId();
        dd.Account__c = account.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        //insert dd;
        DPQueue.add(dd);
        insert DPQueue;
        CSM_Case_Details_Global_Setting__c tempPRM = new CSM_Case_Details_Global_Setting__c(Name='ET TECH EN PRM OOO Queue Message',Component_Id__c ='0D26A000000L1W5');
        insert tempPRM;
        OutOfOffice ooo = new OutOfOffice(StartDate = Date.today(), EndDate = Date.today().addDays(1), Message='My message',UserId = UserInfo.getUserId());
        insert ooo;
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_P_CSM_COMMUNITY, 1);
        listOfUser[0].ContactId = con.Id;
        insert listOfUser[0];
    }
    
    static testmethod void testupdateStatusforLogAWorkNoteonCase(){
        
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact con = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName lastName123' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
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
                Name = grpUser.group.Name,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId, TECH_QueueUser__c = qur.Id,
                Type__c = 'User',
                Group_Id__c = grpUser.groupId);
            
            insert qurUser;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Customer Portal',
                Status = 'New',
                InitialQueue__c = 'group name',
                AssignCaseToCurrentUser__c = false,
                OwnerId = g1.Id,
                EntitlementId = ent.Id,
				External_System_Type__c = 'BISM',
                RecordTypeId = RecordTypeIdCase
            );
            insert c;
            
            Case cs2 = new Case();
            cs2.ContactId = con.Id;
            cs2.AccountId = acct.Id;
            cs2.AssignCaseToCurrentUser__c = false;
            cs2.OwnerId = UserInfo.getUserId();
            cs2.RecordTypeId = RecordTypeIdCase;
            cs2.Origin = 'Partner Portal';
            cs2.Mail_CC_List__c = 'nodata@info.com';
            cs2.External_System_Type__c = 'BISM';
            cs2.Subject = 'Techno case';
            cs2.Description = 'Test class to check case creation';
            cs2.Status = 'New';
            insert cs2;
            
            List<CaseComment> newComment = new List<CaseComment>();
            newComment.add(new CaseComment(ParentId = c.Id,CommentBody = 'Test Comment Case CommentBoby',IsPublished = true)); 
            newComment.add(new CaseComment(ParentId = cs2.Id,CommentBody = 'Test Comment Case CommentBoby',IsPublished = true)); 
            insert newComment;      
        }
    }
    
    static testMethod void testCCMailOnCaseComment(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact con = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName lastName123' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            
            CSM_Case_Details_Global_Setting__c custsettObj1 = new CSM_Case_Details_Global_Setting__c();
            custsettObj1.Name = 'Email Template Default CaseComment';
            custsettObj1.Setting_Type__c = 'Email Template';
            custsettObj1.Country__c = 'Default';
            custsettObj1.Other_Details__c = 'CaseComment';
            insert custsettObj1;
            
            CSM_Case_Details_Global_Setting__c custsettObj2 = new CSM_Case_Details_Global_Setting__c();
            custsettObj2.Name = 'Org Wide No-Reply';
            custsettObj2.Setting_Type__c = 'Org Wide';
            custsettObj2.Other_Details__c = 'Customer Portal';
            custsettObj2.Origin__c = 'Customer Portal';
            insert custsettObj2;
            
            CSM_Case_Details_Global_Setting__c custsettObj3 = new CSM_Case_Details_Global_Setting__c();
            custsettObj3.Name = 'Email Template register PEP';
            custsettObj3.Setting_Type__c = 'Email Template';
            custsettObj3.Country__c = 'Default PEP';
            custsettObj3.Component_Id__c = '0D26A000000L1W5';
            custsettObj3.Other_Details__c = 'New';
            custsettObj3.Origin__c = 'Partner Portal';
            insert custsettObj3;
            
            CSM_Case_Details_Global_Setting__c custsettObj4 = new CSM_Case_Details_Global_Setting__c();
            custsettObj4.Name = 'ET_TECH_EN_Case Closed  PEP';
            custsettObj4.Setting_Type__c = 'Email Template';
            custsettObj4.Country__c = 'PEP';
            custsettObj4.Component_Id__c = '0D26A000000L1W5';
            custsettObj4.Other_Details__c = 'Closed';
            custsettObj4.Origin__c = 'Partner Portal';
            insert custsettObj4;
            
            CSM_Case_Details_Global_Setting__c custsettObj5 = new CSM_Case_Details_Global_Setting__c();
            custsettObj5.Name = 'Email Template Update PEP';
            custsettObj5.Setting_Type__c = 'Email Template';
            custsettObj5.Country__c = 'PEP';
            custsettObj5.Component_Id__c = '0D26A000000L1W5';
            custsettObj5.Other_Details__c = 'CaseComment';
            custsettObj5.Origin__c = 'Partner Portal';
            insert custsettObj5;
            
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = UserInfo.getUserId(),
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,TECH_QueueUser__c = qur.Id,
                Type__c = 'User',
                Group_Id__c = grpUser.groupId);
            
            insert qurUser;
            
            Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = recordTypeIdTechno;
            cs.Priority = 'Medium';
            cs.Origin = CON_PEP.S_PARTNER_PORTAL;
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.AssignCaseToCurrentUser__c = false;
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.External_System_Type__c = 'BISM';
            cs.OwnerId = g1.Id;
            
            insert cs;
            //DAOH_CaseComment.sendLatestCommenttoDataCaseOriginator(new List<Case>{cs});
            List<Case> caseList = [SELECT Id, Origin, Subject FROM Case];
            List<CaseComment> commentList = new List<CaseComment>();
            for(Case csc : caseList){
                CaseComment csCommentObj = new CaseComment();
                csCommentObj.IsPublished = true;
                csCommentObj.ParentId = csc.Id;
                csCommentObj.CommentBody = 'Demo text to test case comment';
                commentList.add(csCommentObj);
            }
            
            insert commentList;
        }
    }
    
    @IsTest
    static void testDataPortalUsersAssignment() {
        List<Asset> assets = new List<Asset>();
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact contact = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName lastName123' LIMIT 1];
        Queue_User_Relationship__c qp1 = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qp1;
        Queue_User_Relationship__c qp2 = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'User');
        insert qp2;
        CSM_Case_Details_Global_Setting__c custSet = new CSM_Case_Details_Global_Setting__c();
        custSet.Name = 'CAS_ET_CSM_Data_OriginatorNotification';
        custSet.Setting_Type__c = 'Email Template';
        custSet.Country__c = CON_CSM.S_DEFAULT;
        custSet.Origin__c = 'Customer Portal';	
        custSet.Component_Id__c = '00X6A000000hM1F';
        custSet.Other_Details__c =  CON_CSM.S_ORG_CASECOMMENT;
        insert custSet;
        
        CSM_Case_Details_Global_Setting__c custSet1 = new CSM_Case_Details_Global_Setting__c();
        custSet1.Name = 'CAS_ET_Data_OriginNotification';
        custSet1.Setting_Type__c = 'Email Template';
        custSet1.Country__c = 'IN';
        custSet1.Origin__c = 'Customer Portal';	
        custSet1.Component_Id__c = '00X6A000000hM1F';
        custSet1.Other_Details__c =  CON_CSM.S_ORG_CASECOMMENT;
        insert custSet1;
        
        
        
        User user = [select Id From User Where LastName = 'lastName123' LIMIT 1];
        
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = user.Id, Type__c = 'User');
        insert qurPortal;
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Test.startTest();
        system.runAs(user){
            Case c = new Case(
            AccountId = account.Id,
            ContactId = contact.Id,
            Origin = 'Customer Portal',
            Status = 'New',
            AssignCaseToCurrentUser__c = false,
            Subtype3__c='OUTLET VOLUME INVESTIGATION',
            LastCaseComment__c = 'New Comment',
            OwnerId = UserInfo.getUserId(),
            CSM_QI_Data_Originator__c = UserInfo.getUserId(),
            RecordTypeId = RecordTypeIdCase
        );
        insert c;
            List<CaseComment> commentList = new List<CaseComment>();
            CaseComment csCommentObj = new CaseComment();
            csCommentObj.IsPublished = true;
            csCommentObj.ParentId = c.Id;
            csCommentObj.CommentBody = 'Demo text to test case comment';
            commentList.add(csCommentObj);
            insert commentList;
        }
        Test.stopTest();
    }
    
    @isTest
    static void testQueueCompleted(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact con = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName lastName123' LIMIT 1];
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        List<CaseOLASettings__c> pList = new List<CaseOLASettings__c>();
        CaseOLASettings__c p1 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 1',Priority__c = 'Priority 1',Target_Time__c = 120);
        pList.add(p1);
        CaseOLASettings__c p2 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 2',Priority__c = 'Priority 2',Target_Time__c = 240);
        pList.add(p2);
        CaseOLASettings__c p3 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 3',Priority__c = 'Priority 3',Target_Time__c = 360);
        pList.add(p3);
        CaseOLASettings__c p4 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 4',Priority__c = 'Priority 4',Target_Time__c = 480);
        pList.add(p4);
        CaseOLASettings__c ol = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' OLA',Priority__c = 'Priority 4',Target_Time__c = 1440);
        pList.add(ol);
        insert pList;
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId,Business_Hours__c = bhId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(TECH_QueueUser__c = qur.Id,
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Group g2 = new Group(Name='Q2', type='Queue');
            insert g2;
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            Queue_User_Relationship__c qur2 = new Queue_User_Relationship__c(
                Name = grpUser2.group.Name,Type__c = 'Queue',Group_Id__c = grpUser2.groupId);
            insert qur2;
            Queue_User_Relationship__c qurUser2 = new Queue_User_Relationship__c(TECH_QueueUser__c = qur2.Id,
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser2;
            
            Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
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
            insert cs;
            Test.startTest();
            cs.OwnerId = g2.Id;
            update cs;
            cs.OwnerId = g1.Id;
            update cs;
            DAOH_CaseComment.completeOLA(new List<Id>{cs.Id});
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testUpdateCSHStatusChangeOnComment() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description',EmployeeNumber ='080808082');
        insert accOwner;
        
        System.runAs (accOwner) {
            List<Asset> assets = new List<Asset>();
            Account account = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
            Contact contact = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName lastName123' LIMIT 1];
            Queue_User_Relationship__c qp1 = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
            insert qp1;
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qp1.Id;
            dT.Account__c = account.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qp1.Id;
            dd.Account__c = account.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            
            
            Asset asset = [SELECT ID,Name,AccountId,Product2Id FROM Asset WHERE Name = 'DDD'];
                        
            Product2 product1 = UTL_TestData.createProduct();
            product1.Name = 'Nexxus MI';
            product1.SpecificToCSM__c = True;
            insert product1;
            
            
            Asset asset1 = new Asset(Name = 'Nexxus MI', AccountId = account.Id, Product2Id = product1.id, Status ='Installed');
            insert asset1;
            
            CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
            cc.Product__c= product1.Id;
            cc.SubType1__c = 'Incident-Module';
            cc.SubType2__c = 'Formula';  
            cc.SubType3__c = '--none--';
            cc.Type__c = 'Categorization';
            cc.Active__c = true;
            cc.Pillar__c = 'Information Offering';
            insert cc;
            
            Group g1 = new Group(Name='group name', type='Queue');
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
                Type__c = 'User',
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            User user = [select Id From User Where LastName = 'lastName123' LIMIT 1];
            
            GroupMember portalUser = new GroupMember (
                UserOrGroupId = user.Id,
                GroupId = g1.Id);
            
            insert portalUser;
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(
                Name = portalUser.group.Name,
                User__c = portalUser.UserOrGroupId,
                Type__c = 'User',
                Group_Id__c = portalUser.groupId);
            
            insert qurPortal;
            
            Test.startTest();
            system.runAs(user){
                Id RecordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
                Case c1 = new Case(
                    AccountId = account.Id,
                    ContactId = contact.Id,
                    Origin = 'Customer Portal',
                    Status = 'Awaiting',
                    Subject = 'TestCaseMacro',
                    Priority = 'Priority 4',
                    AssignCaseToCurrentUser__c = false,
                    OwnerId = qurPortal.Group_Id__c,
                    Owner__c = qurPortal.Group_Id__c,
                    RecordTypeId = RecordTypeIdTechno
                );
                insert c1;
                
                CaseComment newCaseComment = new CaseComment(ParentId = c1.id);
                insert newCaseComment;
                c1 = [select Id, Status from Case where Id =: c1.Id];
                System.assertEquals('In Progress', c1.Status,'status is not updated');
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testUpdateTechAFUFlagOnNewComment(){
        Account accountRecord = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact contactRecord = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName lastName123' LIMIT 1];
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = accountRecord.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = accountRecord.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        User portalUser = [select Id From User Where LastName = 'lastName123' LIMIT 1];
        
        User userRecord = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        CSM_QI_Data_Portal_Queue_User_details__Share dTSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
        dTSh.ParentId = dT.Id;
        dTSh.UserOrGroupId = portalUser.Id;
        dTSh.AccessLevel = 'Read';
        dTSh.RowCause='manual';
        Database.insert(dTSh,false);
        CSM_QI_Data_Portal_Queue_User_details__Share ddSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
        ddSh.ParentId = dd.Id;
        ddSh.UserOrGroupId = portalUser.Id;
        ddSh.AccessLevel = 'Read';
        ddSh.RowCause='manual';
        Database.insert(ddSh,false);
        system.runAs(userRecord){
            Group groupRecord = new Group(Name='Tech Q1 Group', type='Queue');
            insert groupRecord;
            GroupMember memberRecord = new GroupMember (
                UserOrGroupId = portalUser.Id,
                GroupId = groupRecord.Id);
            insert memberRecord;
            
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c();
            queueRecord.Name = 'Tech Q1 Group';
            queueRecord.QueueName__c = 'Tech Q1 Group';
            queueRecord.Type__c = 'Queue';
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c();
            queueUserRecord.Name = 'Tech Q1 Group';
            queueUserRecord.QueueName__c = 'Tech Q1 Group';
            queueUserRecord.Type__c = 'User';
            queueUserRecord.TECH_QueueUser__c = queueRecord.Id;
            queueUserRecord.User__c = portalUser.Id;
            insert queueUserRecord;

            Queue_User_Relationship__share qurSh = new Queue_User_Relationship__share();
            qurSh.ParentId = queueRecord.Id;
            qurSh.UserOrGroupId = portalUser.Id;
            qurSh.AccessLevel = 'Read';
            qurSh.RowCause='manual';
            Database.insert(qurSh,false);
            Queue_User_Relationship__share qurPortalSh = new Queue_User_Relationship__share();
            qurPortalSh.ParentId = queueUserRecord.Id;
            qurPortalSh.UserOrGroupId = portalUser.Id;
            qurPortalSh.AccessLevel = 'Read';
            qurPortalSh.RowCause='manual';
            Database.insert(qurPortalSh,false);
        }
        Product2 product1 = new Product2(Name = 'Nexxus MI',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert product1;
        
        Asset asset1 = new Asset(Name = 'Nexxus MI', AccountId = accountRecord.Id, Product2Id = product1.id, Status ='Installed');
        insert asset1;
        
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
        cc.Product__c= product1.Id;
        cc.SubType1__c = 'Incident-Module';
        cc.SubType2__c = 'Formularies';  
        cc.SubType3__c = '--none--';
        cc.Type__c = 'Categorization';
        cc.Active__c = true;
        cc.Pillar__c = 'Technology Solutions';
        insert cc;
        CSM_QI_Case_Categorization__share ccSh = new CSM_QI_Case_Categorization__share();
        ccSh.ParentId = cc.Id;
        ccSh.UserOrGroupId = portalUser.Id;
        ccSh.AccessLevel = 'Read';
        ccSh.RowCause='manual';
        Database.insert(ccSh,false);
        Entitlement entitlementRecord = new Entitlement(Name = 'Testing', AccountId = accountRecord.Id, Type = 'TECHNO',
                                                        BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                                        StartDate = Date.valueof(System.now().addDays(-2)), 
                                                        EndDate = Date.valueof(System.now().addYears(2)));
        insert entitlementRecord;
        
        Id technoRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        List<CaseComment> commentList = new List<CaseComment>();
        
        System.runAs(portalUser){
            Case caseRecord = new Case(
                AccountId = accountRecord.Id,
                ContactId = contactRecord.Id,
                Origin = 'Customer Portal',
                Status = 'New',
                InitialQueue__c = 'Tech Q1 Group',
                AssignCaseToCurrentUser__c = false,
                OwnerId = portalUser.Id,
                EntitlementId = entitlementRecord.Id,
                RecordTypeId = technoRecordTypeId,
                ProductName__c= 'Nexxus MI',
                SubType1__c = 'Incident-Module',
                SubType2__c = 'Formularies',
                SubType3__c = '--none--'
            );
            insert caseRecord;
            Test.startTest();
            caseRecord.AFU_TECH__c = TRUE;
            caseRecord.Resolution__c = 'Case Resolved';
            caseRecord.RootCause__c = 'Access Request';
            caseRecord.Device__c = 'iPhone';
            update caseRecord;
            CaseComment commentRecord1 = new CaseComment();
            commentRecord1.CommentBody = 'CSH Comment';
            commentRecord1.IsPublished = TRUE;
            commentRecord1.ParentId = caseRecord.Id;
            commentList.add(commentRecord1);
            CaseComment commentRecord2 = new CaseComment();
            commentRecord2.CommentBody = 'Internal Comment';
            commentRecord2.IsPublished = TRUE;
            commentRecord2.ParentId = caseRecord.Id;
            commentList.add(commentRecord2);
            insert commentList;
        }
        delete commentList;
        Test.stopTest();
    }
    @istest
    public static void testsendNotificationBell(){
        Account acct1 = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact con1 = [SELECT Id, Name FROM Contact WHERE Name = 'TestFirstName lastName123' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct1.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User userRescord = new User(id = UserInfo.getUserId());
        userRescord.Email ='aKANSHA.gupta@metacube.com';
        userRescord.Case_Comment_Work_Note__c ='Comment - Email;Comment - Bell';
        userRescord.EmployeeNumber = '6545434';
        update userRescord;
        User u = [Select id,Email,Name from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
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
                Name = grpUser.group.Name,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                Type__c = 'User',TECH_QueueUser__c = qur.Id,
                Group_Id__c = grpUser.groupId,User__c = u.id);
            
            insert qurUser;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct1.Id,
                ContactId = con1.Id,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'group name',
                AssignCaseToCurrentUser__c = false,
                OwnerId = g1.Id,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase,
                Subject ='Subject'
            );
            insert c;
            Case caseRecord =[Select id,Subject from Case where Subject ='Subject'];
            CaseComment caseCom = new CaseComment(CommentBody ='Body1',ParentId =caseRecord.id);
            
            Test.startTest();
            insert caseCom;
            //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            DAOH_CaseComment.sendNotify(caseRecord.Id,'Body1');
            Test.stopTest();
        }
    }
}
