@isTest
public class TST_DAO_Account_Compliance {
	@isTest
    public Static void testInsertion(){
        Account acc = new Account(Name = 'TestAccount', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        Account_Compliance__c accComp = new Account_Compliance__c(Account__c = acc.Id);
        insert accComp;
    } 
}