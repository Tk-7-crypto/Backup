@isTest
public class TST_TGRH_Account_Compliance {
	@isTest
    public Static void testInsertAndUpdate(){
        Test.startTest();
        Account acc = new Account(Name = 'TestAccount',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        Account_Compliance__c accComp = new Account_Compliance__c(Account__c = acc.Id,Client_TPA_Compliance_Hold__c=true,Vendor_TPA_Compliance_Hold__c=true);
        insert accComp;
        Account_Compliance__c accCompUpdated = [Select Id,Client_TPA_Compliance_Hold_Date__c,Vendor_TPA_Compliance_Hold_Date__c,Client_TPA_Compliance_Hold__c From Account_Compliance__c Limit 1][0];
        
        
        accComp.Client_TPA_Compliance_Hold__c = false;
        accComp.Vendor_TPA_Compliance_Hold__c = false;
        update accComp;
        Test.stopTest();
    } 
}