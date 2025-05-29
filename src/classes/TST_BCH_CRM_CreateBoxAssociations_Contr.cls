@isTest
public class TST_BCH_CRM_CreateBoxAssociations_Contr {
	@isTest static void testCreateBoxAssociation_Contracts() {
        Account acc = new Account(Name='TestAccount',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc; 
        Contract con = new Contract(AccountId=acc.Id, Quintiles_Contract_Box_ID__c='1234567890',Specific_Contract_Type__c = 'Master Independent Contractor Agreement');
        insert con;
        
        Test.startTest();
        	Database.executeBatch(new BCH_CRM_CreateBoxAssociations_Contr());
        Test.stopTest();
    }
}