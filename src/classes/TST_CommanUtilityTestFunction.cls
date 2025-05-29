/**
 * This class is used to test TST_CommanUtilityTestFunction
 */ 
@isTest
public class TST_CommanUtilityTestFunction {
    
    static testMethod void checkAll() {
        Test.startTest();
        CommanUtilityTestFunction.setUpSalesOrg();
        CommanUtilityTestFunction.createEngagement(new Contact(), new Profit_Centre__c(), new Account(), new SalesOrg__c());
        CommanUtilityTestFunction.createAccount();
        CommanUtilityTestFunction.createContact(new Account(), new SalesOrg__c(), new User());
        CommanUtilityTestFunction.createContact(new Account(), new SalesOrg__c(), new User(), new pse__Work_Calendar__c(), new Profit_Centre__c());
        CommanUtilityTestFunction.getProfile('System Administrator');
        CommanUtilityTestFunction.createTestUser(null);
        CommanUtilityTestFunction.createProduct();
        CommanUtilityTestFunction.createPricebookEntry(new Product2());
        CommanUtilityTestFunction.createOppLineItem(new Opportunity(), new PricebookEntry());
        List<Contact> cList = new List<COntact>();
        cList.add(new Contact());
        cList.add(new Contact());
        cList.add(new Contact());
        cList.add(new Contact());
        cList.add(new Contact());
        cList.add(new Contact());
        cList.add(new Contact());
        cList.add(new Contact());
        cList.add(new Contact());
        CommanUtilityTestFunction.createOpportunity1(new Account(), cList, new pse__Practice__c());
        CommanUtilityTestFunction.createOpportunity1(new Account());
        CommanUtilityTestFunction.setUpWorkCalender();
        CommanUtilityTestFunction.setUpRegion();
        Test.stopTest();
    }
}