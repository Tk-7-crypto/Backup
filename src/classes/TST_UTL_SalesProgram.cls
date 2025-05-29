/**
* This test class is used to test all methods in class UTL_SalesProgram.
* version : 1.0
*/
@isTest
public class TST_UTL_SalesProgram {
    
    @testSetup
    static void dataSetup() {
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Parent Acc';
        insert acc1;
        upsert new  Mulesoft_Integration_Control__c(name = 'testSetting', Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        Account acc = UTL_TestData.createAccount();
        acc.ParentId = acc1.Id;
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
    }
    
    @isTest
    static void testUpdateSalesProgram(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        List<Sales_Program__c> SalesProgramList = new List<Sales_Program__c>();
        Sales_Program__c sp = UTL_TestData.createSalesProgram(acc.Id);
        Sales_Program__c sp1 = UTL_TestData.createSalesProgram(acc.Id);
        SalesProgramList.add(sp);
        SalesProgramList.add(sp1);
        
        insert SalesProgramList;
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
        
        Test.startTest();
        
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
        update opp;
        
        sp1 = [SELECT Id, TPAP__c, Total_Won__c, Total_Lost__c FROM Sales_Program__c where Id = :sp1.Id];
        
        delete opp;
        
        Sales_Program__c sp2 = [SELECT Id, TPAP__c, Total_Won__c, Total_Lost__c FROM Sales_Program__c where Id = :sp1.Id];
        
        Test.stopTest();
        
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
}