@isTest(SeeAllData=false)
public class TST_SLT_ATCOTCClassification {
    @testSetup
    static void dataSetup(){
        Account testAccount = UTL_TestData.createAccount();
        testAccount.Name = 'Test Acc1';
        insert testAccount;
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        
        Product2 product1 = new Product2();
        product1.IsActive = true;
        product1.Name = 'Test Bundle';
        product1.ProductCode = 'CPQ-Bundle';
        product1.Apttus_Config2__ConfigurationType__c = 'Bundle';
        insert product1;
        Product2 product11 = new Product2();
        product11.IsActive = true;
        product11.Name = 'Test Option';
        product11.ProductCode = 'CPQ-TS-AMESA-Data-PI-KLPO';
        product11.Apttus_Config2__ConfigurationType__c = CON_CPQ.OPTION;
        insert product11;
        
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.Key_Generation_Org__c = UserInfo.getOrganizationId();
        insert cpqSetting; 
        
        ATC_OTC_Classification__c atcClass = new ATC_OTC_Classification__c();
        atcClass.Hierarchy1_Code__c = 'A0';
        atcClass.Hierarchy1_Name__c = 'A0 ALIMENTARY T.& METABOLISM';
        atcClass.Hierarchy2_Code__c = 'A01';
        atcClass.Hierarchy2_Name__c = 'A01 STOMATOLOGICALS';
        atcClass.Hierarchy3_Code__c = 'A01A';
        atcClass.Hierarchy3_Name__c = 'A01A STOMATOLOGICALS';
        atcClass.Hierarchy4_Code__c = 'A01A0';
        atcClass.Hierarchy4_Name__c = 'A01A0 STOMATOLOGICALS';
        atcClass.Country_Code__c = 'KW';
        atcClass.Market_Share__c = 0.24;
        atcClass.Market_Type__c = 'LPO';
        atcClass.Standard_Type__c = CON_CPQ.EPHMRA;
        atcClass.Type__c = CON_CPQ.ATC;
        atcClass.Migration_Id__c = 'TD-20';
        insert atcClass;
    }
    
    @isTest(SeeAllData=false)
    static void testGetATC_Classes() {
        List<ATC_OTC_Classification__c> atcOTCList;
        List<ATC_OTC_Classification__c> atcClasses;
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Acc1'];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE AccountId =: testAccount.Id ];
        Apttus_Config2__PriceList__c testPriceList = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        Apttus_Proposal__Proposal__c testProposal = TST_TestGeneratorClass.setProposalData(CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.AMESA, null,testPriceList.Id);
        Id atcclassId = [SELECT Id FROM ATC_OTC_Classification__c][0].Id;
        Product2 testBundleProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Bundle' AND ProductCode = 'CPQ-Bundle'];
        Product2 testOptionProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Option' AND ProductCode = 'CPQ-TS-AMESA-Data-PI-KLPO'];
        
        insert  TST_TestGeneratorClass.createOptionConfigLineItem(TST_TestGeneratorClass.buildTestConfiguration(testProposal.Id), 1, 1, testBundleProduct.Id, testOptionProduct.Id, 1, 0);
        
        Apttus_Config2__LineItem__c lineItem = [SELECT Id, Name From Apttus_Config2__LineItem__c Limit 1];
        
        Apttus_Config2__ProductAttributeValue__c pav= new Apttus_Config2__ProductAttributeValue__c();
        pav.Catergory__c = CON_CPQ.PARTIAL;
        pav.Data_Delivery_Frequency__c = CON_CPQ.QUARTERLY;
        pav.Eligible_Countries__c = 'KW';
        pav.Apttus_Config2__LineItemId__c = lineItem.Id;
        insert pav;
        Apttus_Config2__LineItem__c itemObj = new Apttus_Config2__LineItem__c();
        itemObj.Id = lineItem.Id;
        itemObj.Apttus_Config2__AttributeValueId__c = pav.Id;
        update itemObj;
        
        Test.startTest();
        String atcOTCData = CNT_CPQ_ATCClassesController.getATC_Classes(lineItem.Id);
        atcOTCList = new SLT_ATCOTCClassification().selectById(new set<Id>{atcclassId});
        atcClasses = new SLT_ATCOTCClassification().selectedATCOTCrecoreds('Consumer NTR', 'EG', 'OTC', 'EG_OTC_National', CON_CPQ.ATCOTCFIELDSET, CON_CPQ.EPHMRA);
        Test.stopTest();
        System.assert( atcOTCData != null, 'ATC/OTC Data fetched Successfully');
		System.assert( atcOTCList != null, 'ATC/OTC Without subProduct Data fetched Successfully');
		System.assert( atcClasses != null, 'ATC/OTC SubProduct Data fetched Successfully');
    }
}