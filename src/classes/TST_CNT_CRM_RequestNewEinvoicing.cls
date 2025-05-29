@isTest
public class TST_CNT_CRM_RequestNewEinvoicing {
    
    @testSetup
    static void dataSetup() {
        
        Account ac = UTL_TestData.createAccount();
        insert ac;
        
        Address__c add = UTL_TestData.createAddresses(ac)[0];
        add.Enabled_Sales_Orgs__c = 'AE04:US30';
        add.MDM_Validation_Status__c = 'Validated';
        add.RecordTypeId = CON_CRM.Validated_Address_RecordId;
        add.SAP_Reference__c = '123';
        insert add;
        
        List<SAP_Contact__c> listOfSc = new List<SAP_Contact__c>();
        for(Integer i =0; i<4; i++){
            SAP_Contact__c sc = new SAP_Contact__c();
            sc.First_Name__c = 'Test ';
            sc.Last_Name__c = String.valueof(i);
            sc.Address__c = add.Id;
            sc.SAP_External_KEY__c = '000'+i;
            sc.SAP_Contact_Number__c = '000'+i;
            sc.MDM_Validation_Status__c = 'Validated';
            sc.RecordTypeId = CON_CRM.Validated_SAP_Contact_RecordId;
            listOfSc.add(sc);
        }
        insert listOfSc;
    }
    
    @isTest
    public static void testFetchBaseData(){
        Address__c address = [SELECT Id, SAP_Reference__c FROM Address__c LIMIT 1];
        Test.startTest();
        Map<String, Object> returnMap = CNT_CRM_RequestNewEinvoicing.fetchBaseData(address.Id);
        System.assertEquals(true, returnMap.get('address') != null);
        Test.stopTest();
    }
    
    @isTest
    public static void testSubmitEinvoicingViaAPI(){
        Address__c address = [SELECT Id, SAP_Reference__c FROM  Address__c limit 1];
        List<SAP_Contact__c> sapConList = [SELECT Id, SAP_Contact_Number__c FROM SAP_Contact__c];
        MDM_Invoicing_Transaction__c mit = new MDM_Invoicing_Transaction__c();
        mit.Address__c = address.Id;
        mit.Sales_Org__c = 'AE01';
        mit.SAP_Contact_1__c = sapConList[0].Id;
        mit.SAP_Contact_2__c = sapConList[1].Id;
        mit.SAP_Contact_3__c = sapConList[2].Id;
        
        Test.startTest();
        Map<String, Object> returnMap = CNT_CRM_RequestNewEinvoicing.submitEinvoicingViaAPI(mit, address);
        //System.assertEquals(true, returnMap.containsKey('Success'));
        Test.stopTest();
    }
    
    @isTest
    public static void testSubmitEinvoicingViaAPI3(){
        Address__c address = [SELECT Id, SAP_Reference__c FROM  Address__c limit 1];
        List<SAP_Contact__c> sapConList = [SELECT Id, SAP_Contact_Number__c FROM SAP_Contact__c];
        MDM_Invoicing_Transaction__c mit = new MDM_Invoicing_Transaction__c();
        mit.Address__c = address.Id;
        mit.Sales_Org__c = 'AE01';
        mit.SAP_Contact_1__c = null;
        mit.SAP_Contact_2__c = null;
        mit.SAP_Contact_3__c = null;
        
        Test.startTest();
        //You must populate at least one field (SAP Contact 1, SAP Contact 2, or SAP Contact 3) when submitting a request for e-invoicing.
        Map<String, Object> returnMap = CNT_CRM_RequestNewEinvoicing.submitEinvoicingViaAPI(mit, address);
        System.assertEquals(true, returnMap.containsKey('error'));
        
        mit.SAP_Contact_1__c = sapConList[0].Id;
        mit.SAP_Contact_2__c = sapConList[1].Id;
        mit.SAP_Contact_3__c = sapConList[2].Id;
        insert mit;
        
        //You cannot submit duplicate e-invoicing request because selected Sales Org has already available for these sap contacts.
        returnMap = CNT_CRM_RequestNewEinvoicing.submitEinvoicingViaAPI(mit, address);
        System.assertEquals(true, returnMap.containsKey('error'));
        
        //You cannot submit a request for e-invoicing because Selected Sales Org has already 3 SAP contacts.
        mit.SAP_Contact_1__c = sapConList[3].Id;
        mit.SAP_Contact_2__c = null;
        mit.SAP_Contact_3__c = null;
        returnMap = CNT_CRM_RequestNewEinvoicing.submitEinvoicingViaAPI(mit, address);
        System.assertEquals(true, returnMap.containsKey('error'));
        
        Test.stopTest();
    }
}