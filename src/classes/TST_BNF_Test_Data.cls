/**
* This class is used to test BNF_Test_Data
*/ 
@isTest
public class TST_BNF_Test_Data {
    
    static testMethod void testGetProfile() {
        Test.startTest();
        Profile profile = BNF_Test_Data.getProfile();
        Test.stopTest();
    }
    
    static testMethod void testCreateProductList() {
        Test.startTest();
        List<Product2> productList = BNF_Test_Data.createProductList();
        System.assertEquals('test1', productList[0].Name);
        Test.stopTest();
    }
    
    static testMethod void testCreatePriceBook() {
        Test.startTest();
        List<PricebookEntry> pbeList = BNF_Test_Data.cretaePriceBook();
        System.assertEquals(5, pbeList.size());        
        Test.stopTest();
    }
    
    static testMethod void testCreateBNFSetting() {
        Test.startTest();
        BNF_Settings__c bnfSettings = BNF_Test_Data.createBNFSetting();
        System.assertEquals(1000, bnfSettings.BNF_Opportunity_Threshold__c);
        Test.stopTest();
    }
    
    static testMethod void testCreateCurrentReleaseVersionSetting() {
        Test.startTest();
        Current_Release_Version__c currentReleaseVersion = BNF_Test_Data.createCurrentReleaseVersionSetting();
        System.assertEquals('2019.02', currentReleaseVersion.Current_Release__c);
        Test.stopTest();
    }
    
    static testMethod void testCreate_User_LocaleSetting() {
        Test.startTest();
        List<User_Locale__c> userLocaleList = BNF_Test_Data.create_User_LocaleSetting();
        System.assertEquals('Format1', userLocaleList[0].Name);
        Test.stopTest();
    }
    
    static testMethod void testBNFTestData() {
        Account acc = BNF_Test_Data.createAccount();
        System.assertEquals('Test Account', acc.Name);
        Opportunity opp = BNF_Test_Data.createOpp();
        System.assertEquals('test', opp.Name);
        User user = BNF_Test_Data.createUser();
        System.assertEquals('lstname', user.LastName);
        Revenue_Analyst__c revenueAnalyst = BNF_Test_Data.createRA();
        System.assertEquals('TestRA', revenueAnalyst.Name);
        Contact contact = BNF_Test_Data.createContact();
        System.assertEquals('Contact', contact.LastName);
        List<Address__c> addressList = BNF_Test_Data.createAddress_Array();
        System.assertEquals(5, addressList.size());
        List<SAP_Contact__c> sapContactList = BNF_Test_Data.createSapContact_Array();
        System.assertEquals(5, sapContactList.size());
        BNF2__c bnf2 = BNF_Test_Data.createBNF();
        System.assertEquals('New', bnf2.BNF_Status__c);
        List<OpportunityLineItem> oliList = BNF_Test_Data.createOppLineItem();
        System.assertEquals('New', oliList[0].Sale_Type__c);
        Test.startTest();
        MIBNF2__c mibnf2 = BNF_Test_Data.createMIBNF();
        System.assertEquals('IMS Spain', mibnf2.IMS_Sales_Org__c);
        MIBNF_Component__c mibnfComponent = BNF_Test_Data.createMIBNF_Comp();
        System.assertEquals('New', mibnfComponent.BNF_Status__c);
        MI_BNF_LineItem__c miBnfLineItem = BNF_Test_Data.createMI_BNF_LineItem();
        System.assertEquals(mibnfComponent.Id, miBnfLineItem.MIBNF_Component__c);
        List<Billing_Schedule__c> billingSchedule = BNF_Test_Data.createBillingSchedule();
        System.assertEquals(5, billingSchedule.size());
        List<Billing_Schedule_Item__c> billingScheduleItemList = BNF_Test_Data.createBillingScheduleItem();
        System.assertEquals(10, billingScheduleItemList.size());
        Test.stopTest();
    }    
}