@isTest
public class TST_CNT_CSM_TrainingManagement {
    @testSetup
    static void setup() {
        Product2 prod = new Product2(Name = 'TestProduct', ProductCode = '1234', isActive = true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Enabled_Sales_Orgs__c = 'CH04', CurrencyIsoCode = 'USD', Delivery_Media__c = 'DVD [DV]:CD [CD]', Delivery_Frequency__c = 'Monthly:Quaterly', Business_Type__c = 'I&A',Pillar__c = 'Information Offering;Technology Solutions');
        insert prod;
        Account acc = new Account(Name = 'IQVIA CONSOLIDATED ACCOUNT TEST', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',AccountCountry__c = 'AF', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        Contact con = new Contact(FirstName = 'TestFirstName', LastName = 'TestContact', accountId = acc.Id,Email='test@testmail.com');
        insert con;
        TS_LMS_Training_Management__c tlms = new TS_LMS_Training_Management__c(Contact__c=con.Id,Status__c='NEW',IQVIA_Key_Contact__c=con.Id);
        insert tlms;
        TS_LMS_Category__c tcat = new TS_LMS_Category__c(Product__c=prod.Id,Catalog__c='eLearning Prerequisites',Bundle__c='No Bundle',Pillar__c='Technology Solutions',Active__c=true,Account_Type__c='Customer');
        insert tcat;
        TS_LMS_Catalog_Relationship__c tlmsrel = new TS_LMS_Catalog_Relationship__c(Training_Management__c=tlms.Id,Catalog__c=tcat.Id,Licenses__c=10);
        insert tlmsrel;
    }
    @isTest
    static void tstGetProductsAndBundles(){
        Test.startTest();
            CNT_CSM_TrainingManagement.getProductsAndBundles();
        Test.stopTest();
    }
    @isTest
    static void tstGetRelatedCatalogs(){
        Product2 prd = [SELECT Id,Name from Product2 LIMIT 1];
        Test.startTest();
            CNT_CSM_TrainingManagement.getRelatedCatalogs(prd.Name,'No Bundle','Customer');
        Test.stopTest();
    }
    @isTest
    static void tstSaveLearningCatalogRelationships(){
        TS_LMS_Training_Management__c tlms = [SELECT ID from TS_LMS_Training_Management__c LIMIT 1];
        TS_LMS_Category__c tcat = [SELECT Id from TS_LMS_Category__c LIMIT 1];
        String json = '[{"Training_Management__c":"'+tlms.Id+'","Catalog__c":"'+tcat.Id+'","Licenses__c":"10"}]';
        Test.startTest();
            CNT_CSM_TrainingManagement.saveLearningCatalogRelationships(json);
        Test.stopTest();
    }
    @isTest
    static void tstGetLearningCatalogRelationships(){
        TS_LMS_Training_Management__c tlms = [SELECT ID from TS_LMS_Training_Management__c LIMIT 1];
        TS_LMS_Category__c tcat = [SELECT Id from TS_LMS_Category__c LIMIT 1];
        Test.startTest();
            CNT_CSM_TrainingManagement.getLearningCatalogRelationships(tlms.Id);
        Test.stopTest();
    }
}