/**
* This test class is used to test all methods in opportunity trigger.
* version : 1.0
*/
@isTest
private class TST_DAOH_Opportunity {
    
    /**
* This method is used to setup data for all methods.
*/
    @testSetup
    static void dataSetup() {
        Test.startTest();
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Parent Acc';
        insert acc1;
        upsert new  Mulesoft_Integration_Control__c(name = 'testSetting', Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        Account acc = UTL_TestData.createAccount();
        acc.ParentId = acc1.Id;
        acc.AccountCountry__c = 'AL';
        insert acc;
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        userList[0].PIC_Eligible__c = true;
        userList[0].IsActive = true;
        userList[1].PIC_Eligible__c = true;
        userList[1].IsActive = true;
        insert userList;
        upsert new Email_Notification_To_User__c(User_Ids__c = userList[0].Id,Account_Ids__c = acc1.Id);
        Contact cnt = UTL_TestData.createContact(acc.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        cnt.Email = 'testContact1cnt205@iqvia.com';
        insert cnt;
        Group grp = new Group(name='Credit Control Groups');
        insert grp;  
        Id userId = UserInfo.getUserId();
        User testUser = [Select id, Name from User where id = :userId];
        System.runAs(testUser) {
            GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = userId);
            insert grpMember;
        }
        Test.stopTest();
    }
    
    /**
    * This test method used for insert and update opportunity record
    */ 
    static testMethod void testOpportunityUpdateStage() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        opp.StageName = CON_CRM.QUALIFYING_OPP_STAGE;
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        opp.Line_of_Business__c = 'Clinical';
        opp.Early_Engagement_COE__c = 'Not Applicable';
        update opp;
        Test.stopTest();
        List<Opportunity> OppList = [SELECT id , stageName FROM Opportunity WHERE name = 'TestOpportunity'];
        String expected = CON_CRM.QUALIFYING_OPP_STAGE;
        String actual = OppList[0].stageName;
        System.assertEquals(expected, actual);
    }
    
    /**
* This test method used for add zrep products 
*/ 
    static testMethod void testOpportunityWithZREPProduct() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        opp.StageName = CON_CRM.DELIVERING_PROP_STAGE;
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        product.Hierarchy_Level__c = 'Material';
        product.Offering_Group_Code__c = CON_CRM.PRODUCT_OFFERING_GROUP_CODE;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        List<Contact> conList = [SELECT id,Email FROM Contact where Salesforce_User__c != null LIMIT 1];
        conList[0].Email = 'testmailconlist112132@iqvia.com';
        update conList;
        opp.Principle_inCharge__c = conList[0].Id;
        opp.Potential_Competitor_1__c = comp.Id;
        update opp;
        opp.Principle_inCharge__c = null;
        UTL_ExecutionControl.stopTriggerExecution = true;
        update opp;
        UTL_ExecutionControl.stopTriggerExecution = false;
        opp.Principle_inCharge__c = conList[0].Id;
        update opp;
        Test.stopTest();
    }
    
    /**
* This test method used for add zrep products 
*/ 
    static testMethod void testOpportunityWithZREPProduct1() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        List<User> userList = [SELECT id FROM User where LastName = 'lastName123' LIMIT 2];
        List<Contact> conList = [SELECT id FROM Contact where Salesforce_User__c != null LIMIT 1];
        System.runAs(userList[0]) {
            opp.Principle_inCharge__c = conList[0].Id;
            opp.Proposal_Sent_Date__c = System.today() - 1; 
            Test.startTest();
            opp.Proposal_Sent_Date__c = System.today() - 1; 
            insert opp;
            Contact cnt = [SELECT id,Email FROM Contact WHERE LastName = 'TestContact'];
            cnt.Email = 'testmailcnt112132@iqvia.com';
            update cnt;
            OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
            insert contactRole;
            Product2 product = UTL_TestData.createProduct();
            product.Material_Type__c = 'ZREP';
            product.Hierarchy_Level__c = 'Material';
            insert product;
            PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
            insert pbEntry;
            OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
            insert oppLineItem;
            Competitor__c comp = UTL_TestData.createCompetitor();
            insert comp;
            opp.Principle_inCharge__c = cnt.Id;
            opp.Potential_Competitor_1__c = comp.Id;
            opp.StageName = CON_CRM.DELIVERING_PROP_STAGE;
            update opp;
            UTL_ExecutionControl.stopTriggerExecution = true;
            opp.Principle_inCharge__c = null;
            update opp;
            UTL_ExecutionControl.stopTriggerExecution = false;
            opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
            try {
                update opp;
                System.assert(false);  // code doesn't reach here
            } catch(DmlException ex) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            } 
            Test.stopTest();           
        }
    }
    
    
    /**
* This test method used for add zrep products 
*/ 
    /*static testMethod void testOpportunityWithZREPProduct2() {   
Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
List<User> userList = [SELECT id FROM User where LastName = 'lastName123' LIMIT 2];
System.runAs(userList[0]) {
Test.startTest();
insert opp;
Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
insert contactRole;
Product2 product = UTL_TestData.createProduct();
product.Material_Type__c = 'ZREP';
product.Hierarchy_Level__c = 'Material';
insert product;
PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
insert pbEntry;
OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
insert oppLineItem;
Competitor__c comp = UTL_TestData.createCompetitor();
insert comp;
Id splitTypeId = SRV_CRM_OpportunitySplit.getOpportunitySplitTypeIdByName(CON_CRM.SPLIT_TYPE_NAME);
OpportunitySplit oppSplit = UTL_TestData.createOpportunitySplit(opp.Id, userList[1].Id, splitTypeId);
insert oppSplit;
opp.Potential_Competitor_1__c = comp.Id;
opp.StageName = CON_CRM.DELIVERING_PROP_STAGE;
try {
update opp;
System.assert(false);  // code doesn't reach here
} catch(DmlException ex) {
System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
} 
Test.stopTest();           
}
}*/
    
    /**
* This test method used for insert and update opportunity record
*/ 
    static testMethod void testOpportunityUpdateStageError() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        opp.StageName = CON_CRM.QUALIFYING_OPP_STAGE;
        try {
            update opp;
            system.assert(false); // code doesn't reach here
        } catch (DmlException e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        Test.stopTest();
    }
    
    
    /**
* This test method used to create OutboundMessageDeletionQueue
*/ 
    static testMethod void testCreateOutboundMessageDeletionQueue() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.LI_Opportunity_Id__c = 'gvgyfygiubjhvghsc';
        opp.LQ_Opportunity_Id__c = 'bvhgt66ybkhkhgcfd';
        Test.startTest();
        insert opp;
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        delete oppList;
        List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        Test.stopTest();
        System.assertEquals(1, outboundList.size());
    }
    
    /**
* This test method used to test method setMuleSoftSyncFields
*/ 
    static testMethod void testSetMuleSoftSyncFields() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Legacy_Org_Link__c legacyLink = UTL_TestData.createLegacyOrgLink();
        upsert legacyLink;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        mulesoftIntegrationSettings.Enable_Opportunity_Sync_Validation__c = true;
        upsert mulesoftIntegrationSettings;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        opp.name = 'Opp 2';
        CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
        CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
        try {
            update opp;
            System.assert(false);  // code doesn't reach here
        } catch(DmlException ex) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        } 
        Mulesoft_Opportunity_Sync__c muleOppSync = [SELECT id, LI_Mulesoft_Sync_Status__c, LQ_Mulesoft_Sync_Status__c, LI_Mulesoft_Update_GUID__c FROM Mulesoft_Opportunity_Sync__c WHERE Opportunity__c = :opp.Id];
        muleOppSync.LI_Opportunity_Id__c = opp.Id;
        muleOppSync.LQ_Opportunity_Id__c = opp.Id;
        muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
        muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
        CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
        CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
        update muleOppSync;
        opp.name = 'TestOpp11';
        opp.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI;
        update opp;
        CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
        CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
        opp.name = 'TestOpp11';
        opp.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ;
        update opp;
        Test.stopTest();
        
    }
    
    /**
* This test method used to test method setMuleSoftSyncMechanism
*/ 
    static testMethod void testSetMuleSoftSyncMechanism() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Legacy_Org_Link__c legacyLink = UTL_TestData.createLegacyOrgLink();
        upsert legacyLink;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        mulesoftIntegrationSettings.Enable_Opportunity_Sync_Validation__c = true;
        upsert mulesoftIntegrationSettings;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        Mulesoft_Opportunity_Sync__c muleOppSync = [SELECT id, LI_Mulesoft_Sync_Status__c, LQ_Mulesoft_Sync_Status__c, LI_Mulesoft_Update_GUID__c FROM Mulesoft_Opportunity_Sync__c WHERE Opportunity__c = :opp.Id];        
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            update muleOppSync;
            opp.name = 'TestOpp11';
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LI_Opportunity_Id__c = opp.Id;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LI_Opportunity_Id__c = opp.Id;
            muleOppSync.LQ_Opportunity_Id__c = opp.Id;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            update muleOppSync;
            opp.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        
        Test.stopTest();
    }
    
    /**
* This test method used to test method setMuleSoftSyncMechanism
*/ 
    static testMethod void testSetMuleSoftSyncMechanismv1() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Legacy_Org_Link__c legacyLink = UTL_TestData.createLegacyOrgLink();
        upsert legacyLink;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        mulesoftIntegrationSettings.Enable_Opportunity_Sync_Validation__c = true;
        upsert mulesoftIntegrationSettings;
        upsert new Trigger_Control_For_Migration__c(Disable_OWF_OPP_Flow__c = true);
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Mulesoft_Opportunity_Sync__c muleOppSync = [SELECT id, LI_Mulesoft_Sync_Status__c, LQ_Mulesoft_Sync_Status__c, LI_Mulesoft_Update_GUID__c FROM Mulesoft_Opportunity_Sync__c WHERE Opportunity__c = :opp.Id];        
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            opp.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        Test.startTest();
        try{ 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        try { 
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            muleOppSync.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
            muleOppSync.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
            update muleOppSync;
            update opp;
        } catch(Exception e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        Test.stopTest();
    }
    
    /**
* This test method used for insert and update opportunity record when Proxy Agreeement is Activated.
*/ /*
    static testMethod void testOpportunityUpdateForProxyAgreement() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        Proxy_SCM_Agreement__c scmAgreement = UTL_TestData.createProxySCMAgreement(opp.Id);
        insert scmAgreement;
        try {
            opp.AccountId = null;
            update opp;
            system.assert(false); // code doesn't reach here
        } catch (DmlException e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        Test.stopTest();
    }
	*/
    
    /**
* This test method used for insert and update opportunity record when Proxy Agreeement is Activated.
*/ 
    static testMethod void testOpportunityUpdateForProxyAgreement1() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        Proxy_SCM_Agreement__c scmAgreement = UTL_TestData.createProxySCMAgreement(opp.Id);
        insert scmAgreement;
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        try {
            update opp;
            system.assert(false); // code doesn't reach here
        } catch (DmlException e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        Test.stopTest();
    }
    
    /**
* This test method used for insert and update opportunity record when Proxy Agreeement is Activated.
*/ 
/*
    static testMethod void testOpportunityUpdateForProxyAgreement2() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        Proxy_SCM_Agreement__c scmAgreement = UTL_TestData.createProxySCMAgreement(opp.Id);
        insert scmAgreement;
        try {
            opp.Contract_Start_Date__c = System.today();
            update opp;
            //system.assert(false); // code doesn't reach here
        } catch (DmlException e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        Test.stopTest();
    }
    */
    /**
* This test method used for insert and update opportunity record when Proxy Agreeement is Activated.
*/ 
/*
    static testMethod void testOpportunityUpdateForProxyAgreement3() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        Proxy_SCM_Agreement__c scmAgreement = UTL_TestData.createProxySCMAgreement(opp.Id);
        insert scmAgreement;
        try {
            opp.Contract_End_Date__c = System.today();
            update opp;
            system.assert(false); // code doesn't reach here
        } catch (DmlException e) {
            System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
        }
        Test.stopTest();
    }
    */
    /**
* This test method used to test method ExcludePACheck
*/ /*
    static testMethod void testExcludePACheck() {
        User salesUser = [Select Id FROM User Where Email = 'testuser3133@iqvia.com' and  Profile.Name = 'System Administrator' order by createddate limit 1];
        Test.startTest();
        System.runAs(salesUser) {
            Account acc = UTL_TestData.createAccount();
            acc.Website = 'https://www.test.com';
            insert acc;
            Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
            insert opp;
            opp.Exclude_from_Pricing_Assistant__c = true;
            try {
                update opp;
            } catch(Exception e) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            }
        }
        Test.stopTest();
    }
    */
    @IsTest
    static void testUpdateConversionRate() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        Test.stopTest();
        opp = [select Id, Conversion_Rate_To_USD__c from Opportunity where Id =: opp.Id limit 1];
        System.assertEquals(1, opp.Conversion_Rate_To_USD__c, 'Opportunity Conversion rate is not updated');
    }
	
    /*@IsTest
    static void testaddLIGError() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        upsert new  Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = false);
        upsert new  User_Permissions__c(Is_ZQUI_Product_Access__c = true);
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Material_Type__c = 'ZQUI';
        product.ZQUI_Product__c = true;
        product.Offering_Group_Code__c = 'GPRDSX';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        pbEntry.isActive = true;
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.UnitPrice = 6000000;
        oppLineItem.TotalPrice = null;
        insert oppLineItem;
        Test.stopTest();
        opp.Amount = 101;
        opp.CurrencyIsoCode = 'INR';
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Lab';
        try{
        update opp;
        }catch(Exception ex){
            system.assertEquals(true, ex.getMessage().contains('Some R&D fields are required in order to move in desired stage. Please complete R&D fields first'));
        } 
        //DAOH_Opportunity.addLIGError(new List<Opportunity>{opp}, oppMap);
    }*/
    
    @IsTest
    static void testprocessProjectAwardedAndSignedPrice() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        Test.stopTest();
        opp = [SELECT Id, Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c, OwnerId FROM Opportunity WHERE Id =: opp.Id limit 1];
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        oppMap.put(opp.Id,opp);
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        update opp;
        DAOH_Opportunity.processProjectAwardedAndSignedPrice(new List<Opportunity>{opp}, oppMap,false);
    }

    @IsTest
    static void testprocessProjectAwardedAndSignedPrice2() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        Test.stopTest();
        opp = [SELECT Id, Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c, OwnerId FROM Opportunity WHERE Id =: opp.Id limit 1];
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        oppMap.put(opp.Id,opp);
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        update opp;
        DAOH_Opportunity.processProjectAwardedAndSignedPrice(new List<Opportunity>{opp}, oppMap,true);
    }
    @IsTest
    static void testsendEmails() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        upsert new IQVIA_Biotech_Opportunity_User__c(Recipients_Users_Email__c = 'test@metacube.com');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        acc.AccountCountry__c = 'US';
        update acc;
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id );
            con.Email = 'testEmailCon32' + i + i + i + '@iqvia.com';
            conList.add(con);
        }
        insert conList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        opp.Early_Engagement_COE__c = 'Gastroenterology';
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        insert opp;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(conList[0].Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Material_Type__c = 'ZREP';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        Test.stopTest();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id,InterventionType__c,Principle_inCharge__c,Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c from Opportunity where Id =: opp.Id limit 1]);
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.InterventionType__c = 'Device';
        opp.BidTeam_2__c = conList[0].Id;
        opp.Is_this_IQVIA_Biotech__c = 'Yes';
        opp.Awarded_Date__c = Date.today();
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        update opp;
        DAOH_Opportunity.sendEmails(new List<Opportunity>{opp}, oppMap);
    }
    @IsTest
    static void testsendEmails2() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id );
            con.Email = 'testEmailCon322' + i + i + i + '@iqvia.com';
            conList.add(con);
        }
        insert conList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        Test.stopTest();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id,InterventionType__c,Principle_inCharge__c,Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c from Opportunity where Id =: opp.Id limit 1]);
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.InterventionType__c = 'Cell and Gene Therapy';
        opp.BidTeam_2__c = conList[0].Id;
        update opp;
        DAOH_Opportunity.sendEmails(new List<Opportunity>{opp}, oppMap);
    }
    @IsTest
    static void testsendEmails3() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id);
            con.Email = 'testEmailCon323' + i + i + i + '@iqvia.com';
            conList.add(con);
        }
        insert conList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        Test.stopTest();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id,InterventionType__c,Principle_inCharge__c,Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c from Opportunity where Id =: opp.Id limit 1]);
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.InterventionType__c = 'Biosimilar';
        opp.BidTeam_2__c = conList[0].Id;
        opp.name = opp.name + ' Bio';
        update opp;
        DAOH_Opportunity.sendEmails(new List<Opportunity>{opp}, oppMap);
    }
    @IsTest
    static void testsubmitUnvalidatedAccounts() {  
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Parent Ac';
        insert acc1;
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(FirstName = 'TestFirstName', LastName = 'TestAp');
        conList.add(con);
        insert conList;
        Opportunity opp = UTL_TestData.createOpportunity(acc1.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        Test.stopTest();
    }
	/*
    @IsTest
    static void testvalidateBidTeamMembers(){
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id);
            conList.add(con);
        }
        insert conList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        Test.startTest();
        insert opp;
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id,InterventionType__c,Principle_inCharge__c,Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c from Opportunity where Id =: opp.Id limit 1]);
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.InterventionType__c = 'Biosimilar';
        opp.BidTeam_2__c = conList[0].Id;
        opp.BidTeam_3__c = conList[2].Id;
        opp.BidTeam_4__c= conList[3].Id;
        update opp;
        Test.stopTest();
        System.runas(UTL_TestData.createUser('Sales User', 1)[0]){
            DAOH_Opportunity.validateBidTeamMembers(new List<Opportunity>{opp}, null);
        }
        System.assert(true);
    }
	*/
    @IsTest
    static void testaddProxyBNFValidation() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.StageName = CON_CRM.CLOSED_WON_STAGE;
        opp.CurrencyIsoCode = 'USD';
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olis;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        for(Integer index = 0; index < addressList.size(); index++) {
            addressList[index].MDM_Validation_Status__c = 'Validated';
            addressList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
        }
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Test.startTest();
        BNF2__c bnfRecord = UTL_TestData.createBNFRecord(opp, oppLineItem, addressList, revenueAnalyst.Id);
        bnfRecord.CurrencyIsoCode = 'INR';
        insert bnfRecord;
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        BNF_Test_Data.create_User_LocaleSetting();
        /*req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(bnfRecord.Id);
        result = Approval.process(req1);*/
        update opp;
        Test.stopTest();
    }
	/*
    @IsTest
    static void test2(){
        User userMap = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'lastName123',
            Email = 'testuser3133@iqvia.com',
            Username = 'testuser3133@imshealth.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            PIC_Eligible__c = true,
            isActive = true,
            Alias = 'alia3133',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            employeeNumber= '080808081'

        );
        insert userMap;
        System.debug('-----'+userMap);
        system.runAs(userMap){
            upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
            Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
            mic.Ignore_Validation_Rules__c = false;
            upsert mic;
            upsert new  IQVIA_Biotech_Opportunity_User__c(Recipients_Users_Email__c = userMap.Email);
            Account acc = UTL_TestData.createAccount();
            acc.Website = 'https://www.test.com';
            insert acc;
            List<Contact> conList = new List<Contact>();
            for(Integer i =2;i<12;i++){
                Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT,Salesforce_User__c = userMap.Id);
                conList.add(con);
            }
            insert conList;
            Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
            opp.CurrencyIsoCode = 'USD';
            Test.startTest();
            insert opp;
            Proxy_BNF__c pfb = new Proxy_BNF__c(Opportunity__c=opp.Id,LI_Record_Id__c='gfgghjfgffjcgc6r',Record_Type_Name__c='Test',BNF_Status__c='New');
            insert pfb;   
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id,InterventionType__c,Principle_inCharge__c,Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c from Opportunity where Id =: opp.Id limit 1]);
            opp.Amount = 101;
            opp.PA_Required__c = true;
            opp.CurrencyIsoCode = 'INR';
            opp.Awarded_Date__c = Date.today();
            opp.Is_this_IQVIA_Biotech__c = CON_CRM.YES_STRING;
            opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
            opp.Line_of_Business__c = 'Clinical';
            opp.Principle_inCharge__c = conList[1].Id;
            opp.InterventionType__c = 'Biosimilar';
            opp.BidTeam_2__c = conList[0].Id;
            opp.BidTeam_3__c = conList[2].Id;
            opp.BidTeam_4__c= conList[3].Id;
            opp.BidTeam_5__c= conList[4].Id;
            opp.BidTeam_6__c= conList[5].Id;
            opp.BidTeam_7__c= conList[6].Id;
            opp.BidTeam_8__c= conList[7].Id;
            opp.Early_Engagement_COE__c = 'Not Applicable';
            UTL_ExecutionControl.stopTriggerExecution = true;
            update opp;
            UTL_ExecutionControl.stopTriggerExecution = false;
            Test.stopTest();
            DAOH_Opportunity.validateBidTeamMembers(new List<Opportunity>{opp}, null);
            System.assert(true);
        }
    }
	*/
    
    @isTest
    public static void notifyToOppTeamTest(){
        User userMap = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            LastName = 'lastName123',
            Email = 'testuser3133@iqvia.com',
            Username = 'testuser3133@imshealth.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            PIC_Eligible__c = true,
            isActive = true,
            Alias = 'alia3133',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            employeeNumber= '080808081'
        );
        insert userMap;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp.Line_of_Business__c = 'Data Sciences';
        opp.Early_Engagement_COE__c = 'Gastroenterology';
        opp.Potential_Regions__c = 'Asia Pacific';
        insert opp;
        Contact projectLead = UTL_TestData.createContact(acc.id);
        projectLead.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        projectLead.Salesforce_User__c = userMap.id;
        insert projectLead;
        Contact testcontact = new Contact(LastName = 'TestAp',RecordTypeId=CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT,Salesforce_User__c = userMap.Id);
        testcontact.Email = 'testcontact2805@iqvia.com';
        insert testcontact;
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(testcontact.id,opp.Id);
        insert oppContactRole;
        Product2 product = UTL_TestData.createProduct();
        product.material_Type__c = 'ZREP';
        product.Offering_Group_Code__c = CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND;
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        opp = [SELECT Id, Name, StageName FROM Opportunity where Name = 'TestOpportunity'];
        opp.Principle_inCharge__c = testcontact.id;
        opp.Awarded_Date__c = System.today();
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        Test.startTest();
        update opp;
        opp = [SELECT Id, Name, StageName FROM Opportunity where Name = 'TestOpportunity'];
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Lost_Date__c = System.today();
        opp.Loss_Type__c = 'Competitive bid';
        opp.Primary_Loss_Reason__c = 'Commercial Terms';
        opp.Primary_Win_Reason__c = null;
        opp.Win_Type__c = null;
        update opp;
        Test.stopTest();
    }
    
    @isTest
    public static void testsendmail(){
        List<User> userList = UTL_TestData.createUser('Sales User', 1);
        Account_Setting__c accSetting = new Account_Setting__c();
        accSetting.Christoph_Catta_Employee_Number__c = '12334';
        accSetting.Christoph_Catta_Parent_Account_MDMIDs__c = 'HNCSP82779,HNCSP81605,HNCSP28800';
        insert accSetting;
        userList[0].LastName = 'Christoph Catta';
        userList[0].EmployeeNumber = '12334';
        insert userList;
        Account parentAcc = UTL_TestData.createAccount();
        parentAcc.name = 'ASTRAZENECA';
        parentAcc.MDMID__c = 'HNCSP82779';
        parentAcc.OwnerId = userList[0].id;
        insert parentAcc;
        Account acc = [Select id from Account where name = 'TestAccount'];
        acc.ParentId = parentAcc.id;
        acc.OwnerId = userList[0].id;
        update acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        insert opp;
        Test.startTest();
        opp = [SELECT Id, Name, StageName FROM Opportunity where AccountId = :acc.Id];
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Lost_Date__c = System.today();
        opp.Loss_Type__c = 'Competitive bid';
        opp.Primary_Loss_Reason__c = 'Commercial Terms';
        opp.Primary_Win_Reason__c = null;
        opp.Win_Type__c = null;
        update opp;
        Test.stopTest();
    }

    /**
     * This method is used to test setParentNumber method
     */
    @isTest
    public static void testSetParentNumber() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp1 = UTL_TestData.createOpportunity(acc.Id);
        opp1.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp1.Line_of_Business__c = 'Data Sciences';        
        opp1.Potential_Regions__c = 'Asia Pacific';
        Opportunity opp2 = UTL_TestData.createOpportunity(acc.Id);
        opp2.Name = 'Test';
        opp2.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp2.Line_of_Business__c = 'Data Sciences';        
        opp2.Potential_Regions__c = 'Asia Pacific';
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp1);
        oppList.add(opp2);
        Test.startTest();
        insert oppList;
        opp1 = [SELECT Id FROM Opportunity where Name = 'TestOpportunity'];
        opp2.Parent_Opportunity__c = opp1.Id;
        update opp2;
        delete opp1; 
        Test.stopTest();
    }
    
     /**
     * This method is used to test updateLeadStatusOnClose method
     */
    @isTest
    public static void testUpdateLeadStatusOnClose(){  
        Mulesoft_Integration_Control__c testsetting = [select id from Mulesoft_Integration_Control__c where name = 'testSetting'];
        delete testsetting;
        
        Test.startTest();
        Lead lead = UTL_TestData.createLead();
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setConvertedStatus('Closed - Opportunity');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        
        Id oppid = [Select id,ConvertedOpportunityId from Lead limit 1][0].ConvertedOpportunityId;
        Opportunity opp = [Select id,IsClosed from Opportunity where id = :oppid];
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Lost_Date__c = System.today();
        opp.Loss_Type__c = 'Competitive bid';
        opp.Potential_Competitor_1__c = comp.Id;
        opp.Primary_Loss_Reason__c = 'Commercial Terms';
        opp.Primary_Win_Reason__c = null;
        opp.Win_Type__c = null;
        update opp;             
        Test.stopTest();
    }
    
    /**
     * This method is used to test setPathProbabilityOnClosedWonOpp method
     */
    @isTest
    public static void testSetPathProbabilityOnClosedWonOpp() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity oppClosedWonUpdate = UTL_TestData.createOpportunity(acc.Id);
        insert oppClosedWonUpdate;
        oppClosedWonUpdate = [Select id,StageName,Path_Probability__c from Opportunity where StageName != :CON_CRM.CLOSED_WON_STAGE];
        Test.startTest();
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, oppClosedWonUpdate.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.Offering_Group_Code__c = CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(oppClosedWonUpdate.Id, pbEntry.Id);
        insert oppLineItem;
        oppClosedWonUpdate.StageName = CON_CRM.CLOSED_WON_STAGE;
        update oppClosedWonUpdate;
        List<Opportunity> oppList = [Select id,StageName,Path_Probability__c from Opportunity where StageName = :CON_CRM.CLOSED_WON_STAGE];
        System.assertEquals(CON_CRM.VERBAL, oppList[0].Path_Probability__c);
        Test.stopTest();
    }
    static testMethod void testOppMIBNFCmp() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Test.startTest();
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2; 
        List<Address__c> TestAddress_Array = new List<Address__c>();
        for (Integer i = 0; i < 5; i++) {
            Address__c TempAddress = new Address__c();
            TempAddress.Name = String.valueOf(i);
            TempAddress.Enabled_Sales_Orgs__c='IHA, IMS Health Rotkreuz [CH03]';
            TempAddress.Account__c= acc.Id;
            TempAddress.Street__c = 'Street ' + i.format();
            TempAddress.City__c = 'City '+ i.format();
            TempAddress.Country__c = 'Country ' + i.format();
            TempAddress.SAP_Reference__c = String.valueOf(495000+i);
            TempAddress.International_Name__c = 'Test Address Name' + i;
            TestAddress_Array.add(TempAddress);
        }
        MIBNF_Component__c mibnfCmp = UTL_TestData.createMIBNF_Comp(mibnf2, TestAddress_Array);
        mibnfCmp.BNF_Status__c = 'Accrual';
        insert mibnfCmp;
        opp.Line_of_Business__c = 'Clinical';
        update opp; 
        Test.stopTest();
    }
    
    static final String GROUP_NAME = 'My_Test_Group_12345';
    @isTest
    public static void testWinLossAlertEmail(){
        
        List<User> userList = UTL_OWF_TestData.createUser('Sales User', 2);
        userList[0].IsActive = true;
        insert userList;
        
        CollaborationGroup testGroup = new CollaborationGroup(Name=GROUP_NAME, CollaborationType='Private');
        insert testGroup;
        CON_CRM.cgName = GROUP_NAME;
        CollaborationGroupMember cgm = new CollaborationGroupMember(MemberId = userList[0].Id, CollaborationGroupId=testGroup.Id);
        insert cgm;
        CollaborationGroup testGroup2 = new CollaborationGroup(Name=GROUP_NAME+'1', CollaborationType='Private');
        insert testGroup2;
        CON_CRM.cgName2 = GROUP_NAME+'1';
        CollaborationGroupMember cgm2 = new CollaborationGroupMember(MemberId = userList[1].Id, CollaborationGroupId=testGroup2.Id);
		insert cgm2;
		        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        insert opp;
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Primary_Win_Reason__c =null;
        opp.Win_Type__c = null;
        opp.Primary_Loss_Reason__c ='Account marked as do not sell';
        
        
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Delivery_Country__c = 'Romania';
        oppLineItem.List_Price__c = 100000;
        insert oppLineItem;
        update opp;
        Test.stopTest();        
    }
    
    @IsTest
    static void testNotifyUsersOnStage5() { 
        upsert new  BNF_Settings__c(Enable_IQVIA_BNF_Validation__c = true);
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance();
        mic.Ignore_Validation_Rules__c = false;
        upsert mic;
        upsert new IQVIA_Biotech_Opportunity_User__c(Recipients_Users_Email__c = 'test@metacube.com');
        upsert new Credit_Control_Groups__c(Name = 'Group Names', Group_Names__c = 'Super Credit Control Admins,Credit Control Groups');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        acc.AccountCountry__c = 'US';
        update acc;
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id );
            con.Email = 'testContactemail' + i + 'em' + i + '@iqvia.com';
            conList.add(con);
        }
        insert conList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.CurrencyIsoCode = 'USD';
        opp.Early_Engagement_COE__c = 'Gastroenterology';
        insert opp;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(conList[0].Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Material_Type__c = 'ZREP';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id,InterventionType__c,Principle_inCharge__c,Conversion_Rate_To_USD__c,Amount,StageName,Line_of_Business__c from Opportunity where Id =: opp.Id limit 1]);
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.InterventionType__c = 'Device';
        opp.BidTeam_2__c = conList[0].Id;
        opp.Is_this_IQVIA_Biotech__c = 'Yes';
        opp.Awarded_Date__c = Date.today();
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        update opp;
        opp.Is_Frozen__c = 'Frozen';
        update opp;
        Test.stopTest();
        List<Workflow_Email_Record__c> records = [Select Id from Workflow_Email_Record__c];
        System.assertEquals(records.size()>0, true); 
    }
    
    /**
     * This method is used to test updateSalesSpotCompetitor method
     */
    @isTest
    public static void testUpdateSalesSpotCompetitor() {
        Competitor__c comp1 = UTL_TestData.createCompetitor();
        comp1.SalesSpot_Enabled__c = true;
        insert comp1;
        Competitor__c comp2 = UTL_TestData.createCompetitor();
        comp2.SalesSpot_Enabled__c = false;
        insert comp2;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp1 = UTL_TestData.createOpportunity(acc.Id);
        opp1.Potential_Competitor_1__c = comp1.Id;
        opp1.Potential_Competitor_2__c = comp2.Id;
        Test.startTest();
        insert opp1;
        opp1.Potential_Competitor_1__c = comp2.Id;
        update opp1;
        opp1.Potential_Competitor_1__c = null;
        update opp1;
        opp1.Potential_Competitor_2__c = null;
        update opp1;
        opp1.Potential_Competitor_1__c = comp1.Id;
        opp1.Potential_Competitor_2__c = comp1.Id;
        update opp1;
        Test.stopTest();
    }
    
    @isTest
    Static void testUpdatePreviousSurveySendDate(){
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'US';
        insert acc;
        
        Contact testContact = UTL_TestData.createContact(acc.id);
        testContact.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        insert testContact;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opportunitynew = new Opportunity(Name = 'Test Opportunity', StageName = CON_CRM.IDENTIFYING_OPP_STAGE, CloseDate = Date.today(),
                                                     Line_of_Business__c = 'Clinical', Is_this_IQVIA_Biotech__c = 'No', Research_Study_Classification__c = 'Not a research study',
                                                     Actual_Close_Date__c = Date.today().addDays(-30), Conversion_Rate_To_USD__c = 1,   accountId = acc.Id, Pass_through_Expenses__c = 100,
                                                     Survey_Recipient__c = testContact.Id,Path_Probability__c = 'Potential', Expected_Project_Start_Date__c = Date.today().addMonths(-3), Executive_Sponsor__c = 'Test Executive 1',
                                                     Proposal_Due_Date__c = Date.today(), Is_there_a_regulatory_purpose__c = 'No',CurrencyIsoCode = 'USD');
        oppList.add(opportunitynew);
        Opportunity opportunitynew2 = new Opportunity(Name = 'Test Opportunity', StageName = CON_CRM.IDENTIFYING_OPP_STAGE ,CloseDate = Date.today(),
                                                        Actual_Close_Date__c = Date.today().addDays(-30),Conversion_Rate_To_USD__c = 1,  accountId = acc.Id, Research_Study_Classification__c = 'Not a research study',
                                                        Survey_Recipient__c = testContact.Id, Awarded_Date__c = Date.today().addYears(-1).addDays(-2),Signed_Contract_Date__c = Date.today(), Pass_through_Expenses__c = 100,
                                                        Line_of_Business__c = 'Outcome', Is_this_IQVIA_Biotech__c = 'No', Contract_Start_Date__c = Date.today().addYears(-1), Contract_End_Date__c = Date.today(),Previous_survey_sent_date__c = Date.today().addMonths(-6), Executive_Sponsor__c = 'Test Executive 2',
                                                        Proposal_Due_Date__c = Date.today(), Is_there_a_regulatory_purpose__c = 'No', Real_World_Categories__c = 'Disease Registry',CurrencyIsoCode = 'USD');
        oppList.add(opportunitynew2);
        insert oppList;
        
        List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(testContact.Id, opportunitynew.Id);
        OpportunityContactRole contactRole2 = UTL_TestData.createOpportunityContactRole(testContact.Id, opportunitynew2.Id);
        contactRoleList.add(contactRole);
        contactRoleList.add(contactRole2);
        insert contactRoleList;
        
        Test.startTest();
        Product2 product = UTL_TestData.createProduct();
        product.Offering_Type__c ='Commercial Tech';
        product.Material_Type__c='ZREP';
        product.Offering_Segment__c='Commercial Solutions';
        product.Billing_System__c = 'PeopleSoft';
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opportunitynew.Id, pbEntry.Id);
        oppLineItem.List_Price__c = null;
        oppLineItem.TotalPrice = null;
        oppLineItem.UnitPrice = 7000000.00;
        oppLineItemList.add(oppLineItem);
        
        OpportunityLineItem oppLineItem2 = UTL_TestData.createOpportunityLineItem(opportunitynew2.Id, pbEntry.Id);
        oppLineItem2.List_Price__c = null;
        oppLineItem2.TotalPrice = null;
        oppLineItem2.UnitPrice = 7000000.00;
        oppLineItemList.add(oppLineItem2);
        
        insert oppLineItemList;
        
        oppList = new List<Opportunity>();
        opportunitynew = [Select Id,Is_Survey_Eligible_for_RDS_Manual__c, Is_Survey_Eligible_for_RDS_Auto__c,Amount, Upcoming_Survey_Send_Date__c from Opportunity where Id =:opportunitynew.Id];
        opportunitynew.StageName = CON_CRM.IN_HAND_STAGE;
        opportunitynew.US_government_fully_or_partially_funded__c = 'No';
        opportunitynew.Proposal_Due_Date__c = System.today() + 1; 
        opportunitynew.Is_there_a_regulatory_purpose__c = 'No';
        opportunitynew2 = [Select Id,Is_Survey_Eligible_for_RDS_Manual__c, Is_Survey_Eligible_for_RDS_Auto__c,Amount, Upcoming_Survey_Send_Date__c from Opportunity where Id =:opportunitynew2.Id];
        opportunitynew2.StageName = CON_CRM.IN_HAND_STAGE;
        opportunitynew2.US_government_fully_or_partially_funded__c = 'No';
        opportunitynew2.Proposal_Due_Date__c = System.today() + 1; 
        opportunitynew2.Is_there_a_regulatory_purpose__c = 'No';
        oppList.add(opportunitynew);
        oppList.add(opportunitynew2);
        update oppList;
        Test.stopTest();
    }

    @istest
    public static void testUpdateSurveyField(){
        List<User> userList = new List<User>();
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser1.PIC_Eligible__c = true;
        userList.add(testUser1);
        User testUser2 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser2.PIC_Eligible__c = true;
        userList.add(testUser2);
        User testUser3 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser3.PIC_Eligible__c = true;
        userList.add(testUser3);
        insert userList;
        
        Account acc = [Select id from Account limit 1][0];
        
        List<Contact> contactList = new List<Contact>();
        Contact testContact = UTL_TestData.createContact(acc.id);
        testContact.Salesforce_User__c = testUser1.id;
        testContact.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContact.Email = 'testContact1205@iqvia.com';
        Contact testContact1 = UTL_TestData.createContact(acc.id);
        testContact1.Salesforce_User__c = testUser2.id;
        testContact1.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContact1.Email = 'testContact11205@iqvia.com';
        Contact testContact2 = UTL_TestData.createContact(acc.id);
        testContact2.Salesforce_User__c = testUser3.id;
        testContact2.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID; 	
        Contact testContact3 = UTL_TestData.createContact(acc.id);
        contactList.add(testContact);
        contactList.add(testContact1);
        contactList.add(testContact2);
        contactList.add(testContact3);
        insert contactList;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = UTL_TestData.createOpportunity(acc.id);
        opp.StageName = 'In-Hand';
        opp.Path_Probability__c = 'Verbal';
        opp.Line_of_Business__c = 'Data Sciences';
        opp.Principle_inCharge__c = testContact.id;
        opp.Survey_Recipient__c = testContact.id;
        opp.Is_this_IQVIA_Biotech__c = 'No';
        opp.Potential_Regions__c = 'Asia Pacific';
        oppList.add(opp);
        Opportunity opp2 = UTL_TestData.createOpportunity(acc.id);
        opp2.StageName = 'In-Hand';
        opp2.Line_of_Business__c = 'Commercial Solutions';
        opp2.Is_this_a_renewal__c = 'No';
        opp2.Principle_inCharge__c = testContact.id;
        opp2.Survey_PIC__c = testContact.id;
        opp2.Survey_Recipient__c = testContact.id;
        opp2.Is_this_IQVIA_Biotech__c = 'No';
        opp2.Potential_Regions__c = 'Asia Pacific';
        oppList.add(opp2);
        insert oppList;
        
        Product2 product = UTL_TestData.createProduct();
        product.Offering_Segment__c = 'Commercial Solutions';
        product.Offering_Type__c = 'Commercial Engagement Services';
        product.COE_Name__c = 'CES Excl Meeting Fees';
        product.Product_Group__c = 'Contract Sales & Medical Solutions';
        insert product;

        PricebookEntry priceBookEntry = UTL_TestData.createPricebookEntry(product.id);
        insert priceBookEntry;
        
        List<OpportunityLineItem> opportunityProductList = new List<OpportunityLineItem>();
        OpportunityLineItem opportunityProduct = UTL_TestData.createOpportunityLineItem(opp.id, priceBookEntry.id); 
        opportunityProduct.List_Price__c = null;
        opportunityProduct.TotalPrice = null;
        opportunityProduct.UnitPrice = 7000000.00;
        opportunityProductList.add(opportunityProduct);
        OpportunityLineItem opportunityProduct2 = UTL_TestData.createOpportunityLineItem(opp2.id, priceBookEntry.id); 
        opportunityProduct2.List_Price__c = null;
        opportunityProduct2.TotalPrice = null;
        opportunityProduct2.UnitPrice = 7000000.00;
        opportunityProductList.add(opportunityProduct2);
        insert opportunityProductList;
        
        List<Client_Sat_Survey__c> csList = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c cs = UTL_TestData.createClientSatSurveyRecord('test', 'Yes', testContact.id, opp.id);
        Client_Sat_Survey__c cs2 = UTL_TestData.createClientSatSurveyRecord('test', 'Yes', testContact.id, opp2.id);
        csList.add(cs);
        csList.add(cs2);
        insert csList;
        
        Test.startTest();
        oppList = [Select id,name from Opportunity where AccountId = :acc.id];
        oppList[0].Principle_inCharge__c = testContact1.id;
        oppList[0].BidTeam_2__c = testContact2.id;
        oppList[0].Survey_Recipient__c = testContact3.id;
        oppList[0].Survey_Recipient_2__c = testContact3.id;
        oppList[0].Survey_Recipient_3__c = testContact3.id;
        oppList[0].Survey_PIC__c = testContact1.id;
        oppList[1].Survey_PIC__c = testContact1.id;
        update oppList;
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetOppMapWithOppTeamMembers(){
        Set<Id> oppidSet = new Set<Id>();
        Map<Id,List<String>> mapof = new  Map<Id,List<String>>();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        oppidSet.add(opp.Id);
        Test.startTest();
      		 mapof = DAOH_Opportunity.getOppMapWithOppTeamMembers(oppidSet);
        Test.stopTest();
        System.assertEquals(true, mapof.size() > 0);
    }

    @isTest
    static void testcreditAssessmentCheck(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        upsert new Credit_Control_Groups__c(Name = 'Group Names', Group_Names__c = 'Credit Control Groups,Super Credit Control Admins');
        Group grp = [Select id From Group where developername = 'Super_Credit_Control_Admins' limit 1]; 
        Id userId = UserInfo.getUserId();
        User testUser = new User(id = userId);
        System.runAs(testUser) {
            GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = userId);
            insert grpMember;            
        }
        List<Credit_Control_Threshold__c> creditControlList = new List<Credit_Control_Threshold__c>();
        Credit_Control_Threshold__c cct = new Credit_Control_Threshold__c(Account__c=acc.Id, Threshold_value_USD__c=50.00, Description__c='test');
        creditControlList.add(cct);
        Credit_Control_Threshold__c cct2 = new Credit_Control_Threshold__c(Threshold_value_USD__c=1000.00, Description__c='test', Business_Unit__c = 'CSMS');
        creditControlList.add(cct2);
        Credit_Control_Threshold__c cct3 = new Credit_Control_Threshold__c(Country__c = 'AL', Threshold_value_USD__c=50.00, Description__c='test', Business_Unit__c = 'RDS');
        creditControlList.add(cct3);
        Credit_Control_Threshold__c cct4 = new Credit_Control_Threshold__c(Threshold_value_USD__c=500.00, Description__c='test');
        creditControlList.add(cct4);
        insert creditControlList;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c ='Clinical';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.FPI_Date__c = Date.newInstance(2021, 12, 9);
        opp.FSP__c = 'No';
        opp.Global_project_unit__c = 'Biostats';
        opp.Population_Age_Group__c = 'Unknown';
        opp.Verbatim_Indication_Term__c = 'Test';
        opp.InterventionType__c = 'Biosimilar';
        insert opp;
        List<Contact> conList =[Select Id,Name From Contact];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(conList[0].Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Offering_Group_Code__c = 'GPRDSX';
        product.Material_Type__c = 'ZQUI';
        insert product;
        Product2 product2 = UTL_TestData.createProduct();
        product2.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product2.ProductCode = 'Test02';
        product2.Offering_Segment__c = 'Commercial Solutions';
        product2.Offering_Type__c = 'Commercial Engagement Services';
        product2.COE_Name__c = 'CES Excl Meeting Fees';
        product2.Product_Group__c = 'Contract Sales & Medical Solutions';
        insert product2;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        PricebookEntry pbEntry2 = UTL_TestData.createPricebookEntry(product2.Id);
        insert pbEntry2;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.TotalPrice = 10001;
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        insert oppLineItem;
        OpportunityLineItem oppLineItem2 = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry2.Id);
        oppLineItem2.Description = 'Testing2';
        oppLineItem2.TotalPrice = 500;
        oppLineItem2.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        insert oppLineItem2;
        Test.startTest();
        opp.StageName =CON_CRM.DEVELOPING_PROP_STAGE;
        opp.Early_Engagement_COE__c = 'Not Applicable';
        opp.Line_of_Business__c = 'Clinical';
        update opp;
        Test.stopTest();
    }
    
    @isTest
    static void testcreditAssessmentCheck2() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        upsert new Credit_Control_Groups__c(Name = 'Group Names', Group_Names__c = 'Credit Control Groups,Super Credit Control Admins');
        Group grp = [Select id From Group where developername = 'Super_Credit_Control_Admins' limit 1]; 
        Id userId = UserInfo.getUserId();
        User testUser = new User(id = userId);
        System.runAs(testUser) {
            GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = userId);
            insert grpMember;            
        }
        List<Credit_Control_Threshold__c> creditControlList = new List<Credit_Control_Threshold__c>();
        Credit_Control_Threshold__c cct = new Credit_Control_Threshold__c(Country__c = 'AL', Threshold_value_USD__c=50.00, Description__c='test');
        creditControlList.add(cct);
        Credit_Control_Threshold__c cct2 = new Credit_Control_Threshold__c(Account__c=acc.Id, Threshold_value_USD__c=50.00, Description__c='test', Business_Unit__c = 'RDS');
        creditControlList.add(cct2);
        insert creditControlList;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c ='Clinical';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.FPI_Date__c = Date.newInstance(2021, 12, 9);
        opp.FSP__c = 'No';
        opp.Global_project_unit__c = 'Biostats';
        opp.Population_Age_Group__c = 'Unknown';
        opp.Verbatim_Indication_Term__c = 'Test';
        opp.InterventionType__c = 'Biosimilar';
        insert opp;
        List<Contact> conList =[Select Id,Name From Contact];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(conList[0].Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Offering_Group_Code__c = 'GPRDSX';
        product.Material_Type__c = 'ZQUI';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.TotalPrice = 10001;
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        insert oppLineItem;
        Test.startTest();
        opp.StageName =CON_CRM.DEVELOPING_PROP_STAGE;
        opp.Early_Engagement_COE__c = 'Not Applicable';
        opp.Line_of_Business__c = 'Clinical';
        update opp;
        Test.stopTest();
    }
    
    @isTest
    static void testcreditAssessmentCheck3() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        upsert new Credit_Control_Groups__c(Name = 'Group Names', Group_Names__c = 'Credit Control Groups,Super Credit Control Admins');
        Group grp = [Select id From Group where developername = 'Super_Credit_Control_Admins' limit 1]; 
        Id userId = UserInfo.getUserId();
        User testUser = new User(id = userId);
        System.runAs(testUser) {
            GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = userId);
            insert grpMember;            
        }
        List<Credit_Control_Threshold__c> creditControlList = new List<Credit_Control_Threshold__c>();
        Credit_Control_Threshold__c cct = new Credit_Control_Threshold__c(Threshold_value_USD__c=50.00, Description__c='test');
        creditControlList.add(cct);
        Credit_Control_Threshold__c cct2 = new Credit_Control_Threshold__c(Threshold_value_USD__c=50.00, Description__c='test', Business_Unit__c = 'TCS');
        creditControlList.add(cct2);
        insert creditControlList;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c ='Clinical';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.FPI_Date__c = Date.newInstance(2021, 12, 9);
        opp.FSP__c = 'No';
        opp.Global_project_unit__c = 'Biostats';
        opp.Population_Age_Group__c = 'Unknown';
        opp.Verbatim_Indication_Term__c = 'Test';
        opp.InterventionType__c = 'Biosimilar';
        insert opp;
        List<Contact> conList =[Select Id,Name From Contact];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(conList[0].Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test04';
        product.Offering_Type__c = 'Commercial Tech';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.TotalPrice = 10001;
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        insert oppLineItem;
        Test.startTest();
        opp.StageName =CON_CRM.DEVELOPING_PROP_STAGE;
        opp.Early_Engagement_COE__c = 'Not Applicable';
        opp.Line_of_Business__c = 'Clinical';
        update opp;
        Test.stopTest();
    }
    
    @isTest
    static void testValidateOppForOutcome(){
        Boolean expectedExceptionThrown = false;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c ='Outcome';
        opp.Hybrid_Study__c = false;
        opp.Phase_P__c = 'Phase 3';
        opp.Is_there_a_regulatory_purpose__c = 'No';
        insert opp;
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        User_Permissions__c up = User_Permissions__c.getInstance(UserInfo.getUserId());
        up.Is_ZQUI_Product_Access__c = true;
        upsert up;
        Product2 product = UTL_TestData.createProduct();
        Product.ZQUI_Product__c = true;
        product.Material_Type__c = 'ZQUI';
        product.ProductCode = 'Test01';
        Product.Offering_Group_Code__c ='GPRDSX';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        Test.startTest();
        	try{
                opp.StageName = CON_CRM.DEVELOPING_PROP_STAGE;
                update opp;
	        }
	        catch(Exception ex){
	            System.debug(ex.getMessage());
	            expectedExceptionThrown = ex.getMessage().contains('are mandatory for OUTCOME or TECH & DATA Line of Business and the selected products') ? true : false;
	        }
        Test.stopTest();
        System.assertEquals(expectedExceptionThrown, true);
    }
    
    @isTest
    static void testUpdateSalesProgram(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Sales_Program__c sp = UTL_TestData.createSalesProgram(acc.Id);
        Sales_Program__c sp1 = UTL_TestData.createSalesProgram(acc.Id);
        
        Test.startTest();
        insert sp;
        insert sp1;
        
        opp.Sales_Program__c = sp.Id;
        insert opp;

        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser1.PIC_Eligible__c = true;
        Contact testContact = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        testContact.Salesforce_User__c = testUser1.id;
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(testContact.id,opp.Id);
        insert oppContactRole;
        Product2 product = UTL_TestData.createProduct();
        product.material_Type__c = 'ZREP';
        product.Offering_Group_Code__c = CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND;
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        
        opp.Line_of_Business__c = 'Commercial Solutions';
        opp.Is_this_a_renewal__c = 'No';
        opp.Principle_inCharge__c = testContact.id;
        opp.Survey_PIC__c = testContact.id;
        opp.Survey_Recipient__c = testContact.id;
        opp.Is_this_IQVIA_Biotech__c = 'No';
		
        opp.StageName = CON_CRM.CLOSED_WON_STAGE;
        opp.Primary_Win_Reason__c = 'Experience';
        opp.Win_Type__c = null;
        opp.Primary_Win_Reason_Detail__c = null;
        
        update opp;
        
        sp = [SELECT Id, TPAP__c, Total_Won__c, Total_Lost__c FROM Sales_Program__c where Id = :sp.Id];
        
        opp.Sales_Program__c = sp1.Id;
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Primary_Win_Reason__c = null;
        opp.Primary_Loss_Reason__c = 'Experience';
        opp.Loss_Type__c = null;
        opp.Primary_Loss_Reason_Detail__c = null;
        opp.Lost_Date__c = null;
        Test.stopTest();
        update opp;
        
        sp1 = [SELECT Id, TPAP__c, Total_Won__c, Total_Lost__c FROM Sales_Program__c where Id = :sp1.Id];
        
        delete opp;
        
        Sales_Program__c sp2 = [SELECT Id, TPAP__c, Total_Won__c, Total_Lost__c FROM Sales_Program__c where Id = :sp1.Id];
        
        
        System.assertEquals(sp.TPAP__c == 0, true);
        System.assertEquals(sp.Total_Won__c == 1 , true);
        System.assertEquals(sp.Total_Lost__c == 0, true);
        
        System.assertEquals(sp1.TPAP__c == 0, true);
        System.assertEquals(sp1.Total_Won__c == 0 , true);
        System.assertEquals(sp1.Total_Lost__c == 1, true);
        
        System.assertEquals(sp2.TPAP__c == 0, true);
        System.assertEquals(sp2.Total_Won__c == 0 , true);
        System.assertEquals(sp2.Total_Lost__c == 0, true);

    }
    
    @isTest
    static void testsendEmailToRemovePICUser(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        List<Contact> conList = [SELECT Id FROM Contact where Salesforce_User__c != null LIMIT 1];
        update new Contact(Id = conList[0].Id, Email = 'test@iqvia.com.invalid');
        UTL_ExecutionControl.stopTriggerExecution = true;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        try{
        opp.Principle_inCharge__c = conList[0].Id;
        update opp;
        opp.Principle_inCharge__c = Null;
        UTL_ExecutionControl.stopTriggerExecution = false;
        update opp;
        } catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateGUP1(){
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        Account acc = [SELECT Id, AccountCountry__c, Name FROM Account WHERE Name = 'TestAccount'];
        acc.AccountCountry__c = 'AU';
        update Acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CRM.LOB_Core_Clinical;
        opp.Identified_Business__c = 'ELS';
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.YES_STRING;
        
        insert opp;
        Test.stopTest();  
    }
    
    @isTest
    static void testUpdateGUP2(){
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        Account acc = [SELECT Id, AccountCountry__c, Name FROM Account WHERE Name = 'TestAccount'];
        acc.AccountCountry__c = 'AU';
        update Acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CRM.LOB_Core_Clinical;
        opp.Identified_Business__c = 'ELS';
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.No_String;
        
        insert opp;
        Test.stopTest();  
    }
    
    @isTest
    static void testUpdateGUP3(){
        Test.startTest();
        Account acc = [SELECT Id, AccountCountry__c, Name FROM Account WHERE Name = 'TestAccount'];
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Endocrinology');
        insert indication;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CRM.LOB_Core_Clinical;
        opp.Identified_Business__c = 'ELS';
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.No_String;
        opp.Indication_List__c = indication.Id;
        insert opp;
        Test.stopTest();  
    }
    @isTest
    static void testUpdateGUP4(){
        Test.startTest();
        Account acc = [SELECT Id, AccountCountry__c, Name FROM Account WHERE Name = 'TestAccount'];
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Erosive esophagitis', 'Acute Care');
        insert indication;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CRM.LOB_Core_Clinical;
        opp.Identified_Business__c = 'ELS';
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.No_String;
        opp.Indication_List__c = indication.Id;
        insert opp;
        Test.stopTest();  
    }
    
    @isTest
    static void testUpdateGUP5(){
        Test.startTest();
        Account acc = [SELECT Id, ParentId,AccountCountry__c, Name FROM Account WHERE Name = 'TestAccount'];
        Account parentAcc = UTL_TestData.createAccount();
        parentAcc.Name = 'Biogen';
        insert parentAcc;
        acc.ParentId = parentAcc.Id;
        update acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CRM.LOB_Core_Clinical;
        opp.Identified_Business__c = 'Cenduit';
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.No_String;
        insert opp;
        Test.stopTest();  
    }
    
    @isTest
    static void testUpdateGUP6(){
        Test.startTest();
        Account acc = [SELECT Id, ParentId,AccountCountry__c, Name FROM Account WHERE Name = 'TestAccount'];
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Erosive esophagitis', 'Oncology');
        insert indication;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CRM.LOB_Core_Clinical;
        opp.Identified_Business__c = 'ELS';
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.No_String;
        insert opp;
        
        Indication_List__c indication2 = UTL_OWF_TestData.createIndication('COVID-19', 'Oncology');
        insert indication2;
        opp.Indication_List__c = indication2.Id;
        opp.Global_project_unit__c = '';
        update opp;
        Test.stopTest();  
    }
    
    @isTest
    static void testUpdateGUP7(){
        Test.startTest();
        Account acc = [SELECT Id, ParentId,AccountCountry__c, Name FROM Account WHERE Name = 'TestAccount'];
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Erosive esophagitis', 'Oncology');
        insert indication;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CRM.LOB_EarlyClinicalDevelopment;
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.No_String;
        insert opp;
        
        Indication_List__c indication2 = UTL_OWF_TestData.createIndication('Test', 'Oncology');
        insert indication2;
        opp.Indication_List__c = indication2.Id;
        opp.Global_project_unit__c = '';
        update opp;
        Test.stopTest();  
    }
    
    @isTest
    static void testUpdatePricingToolRecommended1() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Erosive esophagitis', 'Oncology');
        insert indication;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c ='Clinical';
        opp.Potential_Regions__c = 'Asia Pacific';
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test04';
        product.Offering_Type__c = 'Commercial Tech';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.TotalPrice = 10001;
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        insert oppLineItem;
        Test.startTest();            
            opp.Main_Delivery_Country__c = 'Latin America Regional';
            opp.PA_Required__c = true;
        	update opp;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdatePricingToolRecommended2() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Erosive esophagitis', 'Oncology');
        insert indication;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c ='Clinical';
        opp.Potential_Regions__c = 'Asia Pacific';
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test04';
        product.Offering_Type__c = 'Commercial Engagement Services';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.TotalPrice = 10001;
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        insert oppLineItem;
        Test.startTest();            
            opp.Main_Delivery_Country__c = 'Latin America Regional';
        	update opp;
        Test.stopTest();
    }
    
    @isTest
    static void testdealDeskApproval() {
        List<User> userList = UTL_TestData.createUser('Tech Solutions User', 1);	
        System.runAs(userList[0]) {
            
            Account acct = UTL_TestData.createAccount();
            acct.Name = 'Test Deal Desk';
            acct.AccountCountry__c = 'US';
            insert acct;
            Opportunity opp = UTL_TestData.createOpportunity(acct.Id);
            opp.StageName = CON_CRM.DEVELOPING_PROP_STAGE;
            insert opp;
            
            Contact cnt = UTL_TestData.createContact(acct.Id);
            cnt.MailingCountry = 'USA';
            insert cnt;
            OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
            insert contactRole;
            
            Product2 product = UTL_TestData.createProduct();
            product.Local_Product_Code__c = 'CE1447';
            insert product;
            
            PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
            insert pbEntry;
            
            OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
            oppLineItem.Description = 'Testing';
            oppLineItem.TotalPrice = 10001;
            insert oppLineItem;
            
            Test.startTest();
            try{
                opp.StageName =  CON_CRM.FINALIZING_DEAL_STAGE;
                update opp;
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains(System.Label.CRM_CL0045_OPP_STAGE3_DEAL_DESK_ERROR) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            try{
                opp.StageName =  CON_CRM.CLOSED_WON_STAGE;
                update opp;
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains(System.Label.CRM_CL0045_OPP_STAGE3_DEAL_DESK_ERROR) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();        
        }
    }
	
	@isTest
    static void testSetBoxFolderURLonOpp(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Box_End_Point__c boxEndPoint = new Box_End_Point__c(End_Point_for_Folders__c = 'https://api.box.com/2.0', End_Point__c = 'https://app.box.com');
        insert boxEndPoint;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        box__FRUP__c boxFrup = new box__FRUP__c(box__Object_Name__c = 'Opportunity', box__Record_ID__c = opp.Id, box__Folder_ID__c = '12345678');
        insert boxFrup;
        Test.startTest();
        	opp.Line_of_Business__c = CON_CRM.LOB_Q2_Solutions;
        	update opp;
        Test.stopTest(); 
    }
    
    @isTest
    static void testavacareOppValidations(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1);
        insert userList;
        UserRole avacareUserRole = [Select id from UserRole where Name = 'Avacare'];
        User testUserAvacare = new User();
        testUserAvacare = userList[0];
        testUserAvacare.UserRoleId = avacareUserRole.id;
        update testUserAvacare;
        System.runAs(testUserAvacare){
            Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
            opp.Line_of_Business__c = 'Avacare'; 
            opp.Potential_Regions__c = 'Asia Pacific';
            opp.Forecast_Category__c = 'Pipeline';
            opp.LeadSource = 'Email';
            opp.Anticipated_RFP_Date__c = System.today() + 10;
            opp.Is_this_a_renewal__c = 'No';
            opp.Anticipated_RFP_Date__c = System.today() + 10;
            opp.QI_Invited_to_Present__c = 'No';
            opp.Potential_Services__c = 'DCT Direct To/From Patient Shipping';
            opp.Test_Type__c = 'Anatomic Pathology';
            opp.Protocol_Number__c = '31231';
            opp.US_government_fully_or_partially_funded__c = 'No';
            opp.Global_Public_Health__c = 'No';
            opp.Population_Age_Group__c = 'Infants - 1 Month to 2 Years';
            opp.Extension_Continuation_Part_of_Progam__c = 'N/A';
            opp.Does_study_include_LNS__c = 'No';
            opp.GPM_to_be_located_in_specific_region__c = 'Japan';
            opp.Expected_Project_Start_Date__c = System.today() + 2;
            opp.Expected_Project_End_Date__c = System.today() + 20;
            opp.Proposal_Sent_Date__c = System.today() - 2;
            opp.Will_Contract_have_a_fixed_price__c = 'No';
            opp.Win_Type__c = 'Non-competitive bid';
            opp.Primary_Win_Reason__c = 'Domain Expertise';
            opp.Expect_ATP_or_WO_in_Awarded_Qtr__c = 'Not Likely';
            opp.RFP_ReceivedDate__c = System.today() + 20;
            opp.InterventionType__c = 'Device';
            insert opp;
            Site_Submission__c siteSubmission = new Site_Submission__c();
            siteSubmission.Name = 'Test Site Submission';
            siteSubmission.Opportunity__c = opp.id;
            siteSubmission.Status__c = 'PSV Scheduled';
            siteSubmission.PSV_Scheduled_for__c = system.today();
            insert siteSubmission;
            Test.startTest();
            opp.StageName = CON_CRM.DELIVERING_PROP_STAGE;
            Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
            OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
            insert contactRole;
            Product2 product = UTL_TestData.createProduct();
            product.Material_Type__c = 'ZQUI';
            product.Hierarchy_Level__c = 'Material';
            product.Offering_Group_Code__c = CON_CRM.PRODUCT_OFFERING_GROUP_CODE;
            product.ProductCode = 'Q_112941';
            insert product;
            PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
            insert pbEntry;
            OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
            insert oppLineItem;
            Competitor__c comp = UTL_TestData.createCompetitor();
            insert comp;
            List<Contact> conList = [SELECT id,Email FROM Contact where Salesforce_User__c != null LIMIT 1];
            conList[0].Email = 'testmailconlist112132@iqvia.com';
            update conList;
            opp.Principle_inCharge__c = conList[0].Id;
            opp.Potential_Competitor_1__c = comp.Id;
            update opp;
            opp.Principle_inCharge__c = null;
            UTL_ExecutionControl.stopTriggerExecution = true;
            update opp;
            UTL_ExecutionControl.stopTriggerExecution = false;
            opp.Principle_inCharge__c = conList[0].Id;
            update opp;
            Test.stopTest(); 
        }
    }
    
    @isTest
    static void testgetSiteSubUpdateByOpprtunity(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1);
        insert userList;
        UserRole avacareUserRole = [Select id from UserRole where Name = 'Avacare'];
        User testUserAvacare = new User();
        testUserAvacare = userList[0];
        testUserAvacare.UserRoleId = avacareUserRole.id;
        update testUserAvacare;
        System.runAs(testUserAvacare){
            Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
            opp.Line_of_Business__c = 'Avacare'; 
            opp.Potential_Regions__c = 'Asia Pacific';
            opp.Forecast_Category__c = 'Pipeline';
            opp.LeadSource = 'Email';
            opp.Anticipated_RFP_Date__c = System.today() + 10;
            opp.Is_this_a_renewal__c = 'No';
            opp.Anticipated_RFP_Date__c = System.today() + 10;
            opp.QI_Invited_to_Present__c = 'No';
            opp.Potential_Services__c = 'DCT Direct To/From Patient Shipping';
            opp.Test_Type__c = 'Anatomic Pathology';
            opp.Protocol_Number__c = '31231';
            opp.US_government_fully_or_partially_funded__c = 'No';
            opp.Global_Public_Health__c = 'No';
            opp.Population_Age_Group__c = 'Infants - 1 Month to 2 Years';
            opp.Extension_Continuation_Part_of_Progam__c = 'N/A';
            opp.Does_study_include_LNS__c = 'No';
            opp.GPM_to_be_located_in_specific_region__c = 'Japan';
            opp.Expected_Project_Start_Date__c = System.today() + 2;
            opp.Expected_Project_End_Date__c = System.today() + 20;
            opp.Proposal_Sent_Date__c = System.today() - 2;
            opp.Will_Contract_have_a_fixed_price__c = 'No';
            opp.Win_Type__c = 'Non-competitive bid';
            opp.Primary_Win_Reason__c = 'Domain Expertise';
            opp.Expect_ATP_or_WO_in_Awarded_Qtr__c = 'Not Likely';
            opp.RFP_ReceivedDate__c = System.today() + 20;
            opp.InterventionType__c = 'Device';
            insert opp;
            Product2 product = UTL_TestData.createProduct();
            product.Material_Type__c = 'ZQUI';
            product.Hierarchy_Level__c = 'Material';
            product.Offering_Group_Code__c = CON_CRM.PRODUCT_OFFERING_GROUP_CODE;
            product.ProductCode = 'Q_112941';
            insert product;
            PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
            insert pbEntry;
            Site_Submission__c siteSubmission = new Site_Submission__c();
            siteSubmission.Name = 'Test Site Submission';
            siteSubmission.Opportunity__c = opp.id;
            siteSubmission.Status__c = 'PSV Scheduled';
            siteSubmission.PSV_Scheduled_for__c = system.today();
            insert siteSubmission;
            Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication Cardiovascular', 'Cardiovascular');
            insert indication;
            opp.Indication_List__c = indication.id;
            Test.startTest();
            update opp;
            Test.stopTest(); 
        }
    }
    @isTest
    static void testUpdateGPU(){
        List<Account> accList = new List<Account>();
        
        for(integer i=0;i<7;i++){
            Account acc = UTL_TestData.createAccount();
            acc.name = 'Test Account '+i;
            accList.add(acc);
        }
        
            accList[0].Name = 'Gilead';
            accList[1].Name = 'Roche';
            accList[2].Name = 'Boehringer Ingelheim';
            accList[3].Name = 'GlaxoSmithKline';
            accList[4].Name = 'Daiichi Sankyo';
            accList[5].Name = 'BioNTech';
            accList[6].Name = 'Novo Nordisk';
        
        insert accList;
        
        List<Account> accList2 = new List<Account>();
        
        for(integer i=0;i<7;i++){
            Account acc = UTL_TestData.createAccount();
            acc.name = 'Test Account '+i;
            accList2.add(acc);
        }
        
            accList2[0].ParentId = accList[0].Id;
            accList2[1].ParentId = accList[1].Id;
            accList2[2].ParentId = accList[2].Id;
            accList2[3].ParentId = accList[3].Id;
            accList2[4].ParentId = accList[4].Id;
            accList2[5].ParentId = accList[5].Id;
            accList2[6].ParentId = accList[6].Id;
        
        insert accList2;
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(integer i=0;i<7;i++){
            Opportunity opp = UTL_TestData.createOpportunity(accList2[i].id);
            opp.Line_of_Business__c = 'Clinical';
            opp.Global_project_unit__c = null;
            oppList.add(opp);
        }
        
        Test.startTest();
        insert oppList;
        Test.stopTest(); 
        
    }
    
    @isTest
    static void testawardedBidMandatory(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        List<User> userList = [SELECT id FROM User where LastName = 'lastName123' LIMIT 2];
        List<Contact> conList = [SELECT id FROM Contact where Salesforce_User__c != null LIMIT 1];
        opp.Proposal_Sent_Date__c = System.today() - 1;
        opp.Proposal_Sent_Date__c = System.today() - 1;
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Forecast_Category__c = 'Pipeline';
        opp.LeadSource = 'Email';
        opp.QI_Invited_to_Present__c = 'No';
        insert opp;
        Contact cnt = [SELECT id,Email FROM Contact WHERE LastName = 'TestContact'];
        cnt.Email = 'testmailcnt112132@iqvia.com';
        update cnt;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        product.Hierarchy_Level__c = 'Material';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        opp.Principle_inCharge__c = cnt.Id;
        opp.Potential_Competitor_1__c = comp.Id;
        opp.Principle_inCharge__c = conList[0].Id;
        opp.StageName = CON_CRM.DELIVERING_PROP_STAGE;
        update opp;
        Bid_History__c bid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        bid.Bid_Stopped__c = 'No';
        bid.Is_Study_Awarded__c = 'Yes';
        update bid;
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        
        Test.startTest();
        update opp;
        Test.stopTest();           
    }
    
    
    @isTest
    static void testusRenewableOpportunityRequired(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        List<User> userList = [SELECT id FROM User where LastName = 'lastName123' LIMIT 2];
        List<Contact> conList = [SELECT id FROM Contact where Salesforce_User__c != null LIMIT 1];
        opp.Proposal_Sent_Date__c = System.today() - 1;
        opp.Proposal_Sent_Date__c = System.today() - 1;
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Forecast_Category__c = 'Pipeline';
        opp.LeadSource = 'Email';
        opp.QI_Invited_to_Present__c = 'No';
        insert opp;
        Contact cnt = [SELECT id,Email FROM Contact WHERE LastName = 'TestContact'];
        cnt.Email = 'testmailcnt112132@iqvia.com';
        update cnt;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        product.Hierarchy_Level__c = 'Material';
        product.COE_Name__c = 'Analytics Solutions';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Delivery_Country__c = 'USA';
        insert oppLineItem;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        opp.Principle_inCharge__c = cnt.Id;
        opp.Potential_Competitor_1__c = comp.Id;
        opp.Principle_inCharge__c = conList[0].Id;
        opp.StageName = CON_CRM.DELIVERING_PROP_STAGE;
        update opp;
        Bid_History__c bid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        bid.Bid_Stopped__c = 'No';
        bid.Is_Study_Awarded__c = 'Yes';
        update bid;
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        
        Test.startTest();
        update opp;
        Test.stopTest();           
    }
    
    @isTest
    static void testQ2Solution(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        List<User> userList = [SELECT id FROM User where LastName = 'lastName123' LIMIT 2];
        List<Contact> conList = [SELECT id FROM Contact where Salesforce_User__c != null LIMIT 1];
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.Proposal_Sent_Date__c = System.today() - 1;
        opp.Proposal_Sent_Date__c = System.today() - 1;
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Forecast_Category__c = 'Pipeline';
        opp.LeadSource = 'Email';
        opp.Anticipated_RFP_Date__c = System.today() + 10;
        opp.Is_this_a_renewal__c = 'No';
        opp.Anticipated_RFP_Date__c = System.today() + 10;
        opp.QI_Invited_to_Present__c = 'No';
        opp.Potential_Services__c = 'DCT Direct To/From Patient Shipping';
        opp.Test_Type__c = 'Anatomic Pathology';
        opp.Protocol_Number__c = '31231';
        opp.US_government_fully_or_partially_funded__c = 'No';
        opp.Global_Public_Health__c = 'No';
        opp.Population_Age_Group__c = 'Infants - 1 Month to 2 Years';
        opp.Q2_Budget_Tool__c = 'PRISM';
        opp.Q2_CTMS_Picklist__c = 'LTMS';
        opp.Extension_Continuation_Part_of_Progam__c = 'N/A';
        opp.Does_study_include_LNS__c = 'No';
        opp.GPM_to_be_located_in_specific_region__c = 'Japan';
        opp.Expected_Project_Start_Date__c = System.today() + 2;
        opp.Expected_Project_End_Date__c = System.today() + 20;
        opp.Proposal_Sent_Date__c = System.today() - 2;
        opp.Will_Contract_have_a_fixed_price__c = 'No';
        opp.Win_Type__c = 'Non-competitive bid';
        opp.Primary_Win_Reason__c = 'Domain Expertise';
        opp.Expect_ATP_or_WO_in_Awarded_Qtr__c = 'Not Likely';
        opp.RFP_ReceivedDate__c = System.today() + 20;
        opp.InterventionType__c = 'Device';
        insert opp;
        Contact cnt = [SELECT id,Email FROM Contact WHERE LastName = 'TestContact'];
        cnt.Email = 'testmailcnt112132@iqvia.com';
        update cnt;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        product.Hierarchy_Level__c = 'Material';
        product.COE_Name__c = 'Analytics Solutions';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Delivery_Country__c = 'USA';
        insert oppLineItem;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        opp.Principle_inCharge__c = cnt.Id;
        opp.Potential_Competitor_1__c = comp.Id;
        opp.Principle_inCharge__c = conList[0].Id;
        opp.StageName = CON_CRM.DELIVERING_PROP_STAGE;
        update opp;
        Bid_History__c bid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        bid.Bid_Stopped__c = 'No';
        bid.Is_Study_Awarded__c = 'Yes';
        update bid;
        opp.Awarded_Date__c = System.today() + 1 ;
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        
        Test.startTest();
        update opp;
        Test.stopTest();           
    }
}