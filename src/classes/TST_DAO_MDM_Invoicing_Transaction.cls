@isTest
public class TST_DAO_MDM_Invoicing_Transaction {
    
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
        for(Integer i=0; i<3; i++){
            SAP_Contact__c sc = new SAP_Contact__c();
            sc.First_Name__c = 'Test ';
            sc.Last_Name__c = String.valueof(i);
            sc.Address__c = add.Id;
            sc.SAP_External_KEY__c = '000' + i;
            sc.MDM_Validation_Status__c = 'Validated';
            sc.RecordTypeId = CON_CRM.Validated_SAP_Contact_RecordId;
            listOfSc.add(sc);
        }
        insert listOfSc;
    }
    
    @isTest
    public static void testInsertion() {
        Address__c add = [SELECT Id FROM Address__c];
        List<SAP_Contact__c> sc = [SELECT Id FROM SAP_Contact__C ORDER BY Last_Name__c LIMIT 3];
        Test.startTest();
        MDM_Invoicing_Transaction__c mit = UTL_TestData.createMDMInvoiceTransaction(add, sc);
        insert mit;
        
        SAP_Contact__c sc01 = [SELECT Id,Enabled_Sales_Orgs_for_e_invoicing__c FROM SAP_Contact__c Last_Name__c LIMIT 1];
        System.assertEquals('AE01',sc01.Enabled_Sales_Orgs_for_e_invoicing__c);
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdation() {
        Address__c add = [SELECT Id FROM Address__c];
        List<SAP_Contact__c> sc = [SELECT Id FROM SAP_Contact__C Order by Last_Name__c LIMIT 3];
        Test.startTest();
        MDM_Invoicing_Transaction__c mit = UTL_TestData.createMDMInvoiceTransaction(add, sc);
        insert mit;
        
        mit.SAP_Contact_1__c = sc[1].Id;
        mit.SAP_Contact_2__c = sc[0].Id;
        update mit;
        
        SAP_Contact__c sc01 = [SELECT Id,Enabled_Sales_Orgs_for_e_invoicing__c FROM SAP_Contact__c Last_Name__c][1];
        System.assertEquals('AE01',sc01.Enabled_Sales_Orgs_for_e_invoicing__c);
        Test.stopTest();
    }
    
}