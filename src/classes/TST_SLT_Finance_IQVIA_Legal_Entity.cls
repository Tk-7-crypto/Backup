/**
* Test class for SLT_Finance_IQVIA_Legal_Entity
*/
@isTest
public class TST_SLT_Finance_IQVIA_Legal_Entity {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        Contact contact = new Contact(AccountId = acc.Id, FirstName='test', Email='test@example.com', LastName ='lastname', RecordTypeId = CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID,
                                     EmployeeNumber__c = '123456789');
        insert contact;

        Finance_IQVIA_Legal_Entity__c financeLegalEntity = new Finance_IQVIA_Legal_Entity__c();
        financeLegalEntity.Name = 'Test Entity';
        financeLegalEntity.Legacy_Entity_Code__c = 'QUTHV';
        financeLegalEntity.Address_Line_1__c = 'Test Address';
        financeLegalEntity.Country_Description__c = 'USA';
        financeLegalEntity.Effective_Status__c = 'Active';
        financeLegalEntity.Incorporation__c = 'Test';
        financeLegalEntity.RecordTypeId = CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID;
        insert financeLegalEntity;   
        
        Finance_IQVIA_Legal_Entity_Extension__c financeLEE = new Finance_IQVIA_Legal_Entity_Extension__c();
        financeLEE.Contact__c = contact.Id;
        financeLEE.IQVIA_Legal_Entity__c = financeLegalEntity.Id;
        insert financeLEE;
    }

    @isTest
    private static void testGetFinanceIQVIALegalEntityDetailsByName() {
        Set<String> nameSet = new Set<String>{'Test Entity'};
        Set<String> fieldSet = new Set<String>{'Id'};
        Set<Id> recordTypeIds = new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID};
                
        Test.startTest();
            List<Finance_IQVIA_Legal_Entity__c> lstFinanceIQVIAEntity = new SLT_Finance_IQVIA_Legal_Entity()
                .getFinanceIQVIALegalEntityDetailsByName(nameSet, fieldSet, recordTypeIds);
        Test.stopTest();
        
        System.assertEquals(1, lstFinanceIQVIAEntity.size(), 'The size of the list returned should be 1');
    }

    @isTest
    private static void testGetFinanceIQVIALegalEntityDetailsByCode() {
        Set<String> codeSet = new Set<String>{'QUTHV'};
        Set<String> fieldSet = new Set<String>{'Id'};
        Set<Id> recordTypeIds = new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID};
                
        Test.startTest();
            List<Finance_IQVIA_Legal_Entity__c> lstFinanceIQVIAEntity = new SLT_Finance_IQVIA_Legal_Entity()
                .getFinanceIQVIALegalEntityDetailsByCode(codeSet, fieldSet, recordTypeIds);
        Test.stopTest();
        
        System.assertEquals(1, lstFinanceIQVIAEntity.size(), 'The size of the list returned should be 1');
    }

    @isTest
    private static void testGetFinanceIQVIALegalEntityDetails() {
        Finance_IQVIA_Legal_Entity__c legalEntity = [Select Id, Legacy_Entity_Code__c From Finance_IQVIA_Legal_Entity__c Where Name = 'Test Entity' LIMIT 1];
        Set<Id> ids = new Set<Id>{legalEntity.Id};
        Set<String> therapyArea = new Set<String>{'Oncology'};
        String childCondition = 'Therapy_Area__c IN : therapyArea';   
                
        Test.startTest();
            List<Finance_IQVIA_Legal_Entity__c> lstFinanceIQVIAEntity = new SLT_Finance_IQVIA_Legal_Entity()
                .getFinanceIQVIALegalEntityDetails(ids,new Set<String>{'Legacy_Entity_Code__c', 'Id'}, new Set<String>{'Contact__c', 'Therapy_Area__c'},
                null, childCondition, new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID}, therapyArea);
        Test.stopTest();
        
        System.assertEquals(true, lstFinanceIQVIAEntity.size()>0, 'The size of the list returned should be greater than 0');
    }
}