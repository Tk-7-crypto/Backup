@isTest
public class TST_CNT_CRM_OliAddressSelector {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        
        List<SAP_Contact__c> sapContactList = UTL_TestData.createSAPContacts(addressList);
        for(SAP_Contact__c sc : sapContactList){
            sc.MDM_Validation_Status__c = 'Validated';
            sc.SAP_External_KEY__c = sc.SAP_Contact_Number__c;
            sc.RecordTypeId = CON_CRM.Validated_SAP_Contact_RecordId;
        }
        insert sapContactList;
        
        insert new Profit_Centre__c(name='xyz' ,ProfitCenterCode__c='USD', Profit_Center_Code_Chain__c = '(2W)->(ANDES)->(TOTGEO)->(OPRTN-R)');
        
        Product2 prod = UTL_TestData.createProduct();
        prod.Material_Type__c = 'ZPUB';
        prod.Therapy_Class__c = '24';
        insert prod;
        
        PricebookEntry PE = UTL_TestData.createPricebookEntry(prod.Id);
        insert PE;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.StageName = '7a. Closed Won';
        insert opp;
        
        OpportunityLineItem oli =UTL_TestData.createOpportunityLineItem(opp.Id, PE.Id);
        insert oli;
        
        Revenue_Analyst__c ra = UTL_TestData.createRevenueAnalyst();
        insert ra;
        
        BNF_Settings__c bnfSetting = BNF_Settings__c.getOrgDefaults();
        bnfSetting.Excluded_Products__c = 'ZQUI';
        upsert bnfSetting;
        
        BNF2__c TestBnf = UTL_TestData.createBNFRecord(opp, oli, addressList, ra.Id);
        new BNF2__c(Opportunity__c=opp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        TestBnf.IMS_Sales_Org__c = '[CH03] IQVIA AG, Branch Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.RecordTypeId  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
        insert TestBnf;
    }
    
    @isTest
    public static void testFetchAllDetails(){
        Test.startTest();
        Id recId = [SELECT Id FROM BNF2__c LIMIT 1].Id;
        Map<String, Object> returnMap = CNT_CRM_OliAddressSelector.fetchAllDetails(recId);
        List<Address__c> addList = (List<Address__c>) returnMap.get('addressList');
        System.assertEquals(true, returnMap.get('bnf') != null);
        System.assertEquals(true , addList.size() > 0);
        Test.stopTest();
    }
    
    @isTest
    public static void testSearchAddressByfilter(){
        Test.startTest();
        Map<String, Object> returnMap = CNT_CRM_OliAddressSelector.searchAddressByfilter('', 'Country 0', '', '');
        List<Address__c> addList = (List<Address__c>) returnMap.get('addressList');
        System.assertEquals(true , addList.size() > 0);
        System.assertEquals('BNF is currently submitted for approval and cannot be edited.' , CNT_CRM_OliAddressSelector.BNF_SUBMITTED_ERROR);
        System.assertEquals('Contract/Order has been created in SAP and BNF cannot be edited.' , CNT_CRM_OliAddressSelector.BNF_SAP_CONTRACT_CONFIRMED_ERROR);
        System.assertEquals('There is no Validated address on the account please go to Account and created and validate.' , CNT_CRM_OliAddressSelector.NO_ADDRESS_ERROR);
        Test.stopTest();
    }
    
    @isTest
    public static void testErrorMsg(){
        Id recId = [SELECT Id FROM BNF2__c LIMIT 1].Id;
        Test.startTest();
        
        Approval.ProcessSubmitRequest req1;
        BNF_Test_Data.create_User_LocaleSetting();
        req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(recId);
        Approval.ProcessResult result = Approval.process(req1);
        UTL_ExecutionControl.stopTriggerExecution = false;
        Map<String, Object> returnMap = CNT_CRM_OliAddressSelector.fetchAllDetails(recId);
        
        Test.stopTest();
    }
}