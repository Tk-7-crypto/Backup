/**
* This test class is used to test Opportunity record triggered flow for after insert and after update event
* version : 1.0
*/
@isTest
public class TST_CRM_OPP_RecordTriggered_After {
	
     /**
	* This method is used to setup data for all methods.
	*/
    @testSetup
    static void dataSetup(){
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
    * This test method used for testing R&D Opp Loss alert
    */ 
    static testMethod void testRDOppLossAlert(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();
        opp.Actual_Close_Date__c = null;
        opp.Conversion_Rate_To_USD__c = 1;
        opp.Amount = 60000;
        insert opp;
        
        opp.Actual_Close_Date__c = System.today().addYears(1);
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Primary_Win_Reason__c = null;
        opp.Win_Type__c = null;
        opp.Primary_Win_Reason_Detail__c = null;
        opp.Main_Delivery_Country__c = 'Germany';
        opp.Primary_Loss_Reason__c ='Account marked as do not sell';
     
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(cnt.id,opp.Id);
        insert oppContactRole;
        
        update opp;
        Test.stopTest();
    }
    
    /**
    * This test method used for testing TAKEDA Account finalizing deal alert
    */
    static testMethod void testTakedaFinalizingDealAlert(){
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'TAKEDA';
        insert acc1;
        Account acc = UTL_TestData.createAccount();
        acc.ParentId = acc1.Id;
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id );
            conList.add(con);
        }
        insert conList;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();
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
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Clinical';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.InterventionType__c = 'Device';
        opp.BidTeam_2__c = conList[0].Id;
        opp.Is_this_IQVIA_Biotech__c = 'Yes';
        opp.Awarded_Date__c = Date.today();
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        update opp;
        Test.stopTest();
    }
    
    /**
    * This test method used for testing IQVIA Biotech loss alert
    */
    static testMethod void testIQVIABiotechLossAlert(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();
        insert opp;
        
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Primary_Win_Reason__c = null;
        opp.Win_Type__c = null;
        opp.Primary_Win_Reason_Detail__c = null;
        opp.Primary_Loss_Reason__c ='Account marked as do not sell';
        opp.Is_this_IQVIA_Biotech__c = CON_CRM.YES_STRING;
        
        update opp;
        Test.stopTest();
        
    }
    
    /**
    * This test method used for testing RD&S opp finalizing deal alert
    */
    static testMethod void testRDSOppFinalizingDealAlert(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];      
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id );
            conList.add(con);
        }
        insert conList;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();
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
        opp.Amount = 101;
        opp.Line_of_Business__c = 'Evidence Based Medicine (EBM)';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Awarded_Date__c = Date.today();
        opp.StageName = CON_CRM.FINALIZING_DEAL_STAGE;
        update opp;
        Test.stopTest();
    }
    
    /**
    * This test method used for testing RDS opp closed lost alert
    */
    static testMethod void testRDSOppClosedLostAlert(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();
        insert opp;
        
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Line_of_Business__c = CON_CRM.LOB_Data_Science;
        opp.Primary_Win_Reason__c = null;
        opp.Win_Type__c = null;
        opp.Primary_Win_Reason_Detail__c = null;
        opp.Primary_Loss_Reason__c ='Account marked as do not sell';
		opp.Lost_Date__c = System.today();
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(cnt.id,opp.Id);
        insert oppContactRole;
        
        update opp;
        System.debug(opp.Loss_Type__c);
        Test.stopTest();
    }
    
    /**
    * This test method used to test Task creation based on opportunity bid defense date scheduled flow
    */
    static testMethod void testTaskCreationBasedOnPresentationDate(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();        
        opp.Line_of_Business__c = CON_CRM.LOB_Core_Clinical;
        opp.QI_Invited_to_Present__c = CON_CRM.YES_STRING;
        opp.Bid_Defense_Date__c = System.Today().addDays(14);
        insert opp;
        Test.stopTest();
    }
    
    /**
    * This test method used for testing Novel trial design when Stage is Changed
    */ 
    static testMethod void testNovelTrial_StageChanged(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();
        opp.Amount = 60000;
        opp.StageName = CON_CRM.QUALIFYING_OPP_STAGE;
        opp.DMD_Opportunity_Id__c = null;
        opp.Novel_Trial_Design__c = null;
        insert opp;
        
        opp.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp.Novel_Trial_Design__c = 'External Comparators';

     
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(cnt.id,opp.Id);
        insert oppContactRole;
        
        update opp;
        Test.stopTest();
        
    }
    
    /**
    * This test method used for testing Novel trial design
    */ 
    static testMethod void testNovelTrialDesign(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        Test.startTest();
        opp.Amount = 60000;
        opp.StageName = CON_CRM.QUALIFYING_OPP_STAGE;
        opp.DMD_Opportunity_Id__c = null;
        opp.Novel_Trial_Design__c = null;
        insert opp;
        
        opp.Novel_Trial_Design__c = 'Adaptive Designs';

     
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(cnt.id,opp.Id);
        insert oppContactRole;
        
        update opp;
        Test.stopTest();
        
    }
}