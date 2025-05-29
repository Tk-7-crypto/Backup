@isTest
private class TST_WSC_CSM_ServiceNowCom {
    @Istest
    static void setup() {
        WSC_CSM_SNow_Internal_SforceCase.insert_element insertElmt = new WSC_CSM_SNow_Internal_SforceCase.insert_element();
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        CSM_ExternalClient_info__c cc = new CSM_ExternalClient_info__c();
        cc.Name = 'Internal';
        cc.Client_Url__c = 'Internal';
        cc.Password__c = 'Internal';
        cc.Account_Id__c = acct.Id;
        insert cc;
        Contact Con = new Contact( Firstname='BrianSNow', Lastname='DentSNow', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='udo.rischa@snow.com',
            AccountId = acct.Id);
        insert Con;
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId,Business_Hours__c = bhId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Group g2 = new Group(Name='Q2', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue2@iqvia.com');
            insert g2;
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            Queue_User_Relationship__c qur2 = new Queue_User_Relationship__c(
                Name = grpUser2.group.Name,Type__c = 'Queue',Group_Id__c = grpUser2.groupId);
            insert qur2;
            Queue_User_Relationship__c qurUser2 = new Queue_User_Relationship__c(
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser2;
            
            Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            ServiceNow_Group__c sng = new ServiceNow_Group__c();
            sng.Account_Id__c = acct.Id;
            sng.Name ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng.Group_ID__c ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng.Queue__c = 'Q1';
            sng.SystemType__c ='Internal';
            insert sng;
            ServiceNow_Group__c sng1 = new ServiceNow_Group__c();
            sng1.Account_Id__c = acct.Id;
            sng1.Name ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng1.Group_ID__c ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng1.Queue__c = 'Q1';
            sng1.SystemType__c ='Internal';
            insert sng1;
            Product2 p1 = UTL_TestData.createProduct();
            p1.Name = 'STAR';
            p1.SpecificToCSM__c = True;
            insert p1;
            Asset a1 = new Asset(Name = 'STAR', AccountId = acct.Id, Product2Id = p1.id);
            insert a1;
            
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = rt;
            cs.Priority = 'Priority 4';
            cs.Origin = 'Phone';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.RecordTypeId = rt;
            cs.OwnerId = g1.Id;
            cs.ServiceNow_Group__c = sng1.Id;
            cs.ServiceNowSystemType__c = 'Internal';
            insert cs;
            if(cs != null){
                Case c =[select CaseNumber, ContactId, Description, Id, Origin, OwnerId, Priority, Status, Subject, SN_Sub_Categrory__c, Case_CategorizationId__c, SN_Category__c, CMDB__c, Contact_Info__c, Customer_Requested_Date__c, SN_Prod_Line__c, SN_Product_Offering__c, ProductName__c, RecordTypeName__c, Service_Now_Type__c , ServiceNow_Group__c, SubType1__c, SubType2__c, SubType3__c, SuppliedEmail, type from Case];
                try { 
                    Test.startTest();
                    Test.setMock(WebServiceMock.class, new TST_WSC_CSM_ServiceNowCom_WSMock());
                    WSC_CSM_ServiceNowCom.ServiceNowSoap soap = new WSC_CSM_ServiceNowCom.ServiceNowSoap();
                    WSC_CSM_SNow_Internal_SforceCase.insertResponse_element[] response = soap.insert_x(c.CaseNumber, c.ContactId, c.Description, c.Id, c.Origin, c.OwnerId, c.Priority, c.Status, c.Subject, c.Case_CategorizationId__c, c.SN_Category__c, c.CMDB__c, '', c.Contact_Info__c, null, c.SN_Prod_Line__c, c.SN_Product_Offering__c, c.ProductName__c, c.RecordTypeName__c, '', c.Service_Now_Type__c , '', c.SN_Category__c, c.SN_Prod_Line__c, c.SN_Product_Offering__c, c.SN_Sub_Categrory__c, c.SN_Sub_Categrory__c, c.SubType1__c, c.SubType2__c, c.SubType3__c, c.SuppliedEmail, c.type);
                    Test.stopTest();
                } catch ( CalloutException ce) { 
                    System.debug('Exce : '+ce.getCause());
                    System.debug('Stack'+ ce.getStackTraceString());
                    
                } catch ( Exception e) { 
                    // Standard Exception Handling 
                }
            }
            
        }
    }
    
}