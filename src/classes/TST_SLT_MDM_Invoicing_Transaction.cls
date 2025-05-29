@isTest
public class TST_SLT_MDM_Invoicing_Transaction {
    
    @testSetup
    public static void dataSetup(){
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
        
        MDM_Invoicing_Transaction__c mit = UTL_TestData.createMDMInvoiceTransaction(add, listOfSc);
        insert mit;
    }
    
    @isTest
    public static void testGetInvoiceByCondition(){
        Test.startTest();
        Set<String> mdmFieldSet = new Set<String>{'SAP_Contact_1__c', 'SAP_Contact_2__c', 'SAP_Contact_3__c'};
            Map<Id,SAP_Contact__c> sapMap = new Map<Id,SAP_Contact__c> ([SELECT Id FROM SAP_Contact__c]);
        String mdmCondition = ' Id != null';
        
        List<MDM_Invoicing_Transaction__c> eInvoiceList= new SLT_MDM_Invoicing_Transaction().getInvoiceByCondition(mdmFieldSet, mdmCondition);
        System.assertEquals(1, eInvoiceList.size());
        eInvoiceList = new SLT_MDM_Invoicing_Transaction().getInvoiceBySapContact(mdmFieldSet, sapMap.keySet());
        System.assertEquals(1, eInvoiceList.size());
        Test.stopTest();
        
    }
    
}