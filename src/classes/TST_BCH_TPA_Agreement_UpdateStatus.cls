@isTest(seeAllData = false)
public class TST_BCH_TPA_Agreement_UpdateStatus {

	private static TPA_Request__c tpaRequest1;	
	private static TPA_Request__c TestAgreement1;
	
	private static Contact tpaContact;
	private static Address__c testClientAccount;
	private static Address__c testAccount;
	
	
	private TST_BCH_TPA_Agreement_UpdateStatus() {}
	
	public static testMethod void testBatchAgreementUpdateStatus() {
		

		TST_BCH_TPA_Agreement_UpdateStatus instance = new TST_BCH_TPA_Agreement_UpdateStatus();
		instance.setupTestData();
		Test.startTest();      
		BCH_TPA_Agreement_UpdateStatus agreementUpdateStatusTrigger = new BCH_TPA_Agreement_UpdateStatus();
		Database.executebatch(agreementUpdateStatusTrigger,1);
		Test.stopTest();
	}
	


	private void setupTestData() {
		
		Date todayDate = Date.today();

		testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Account',1111);  
		testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Client Account',9999);
		tpaContact = UTL_TPA_SetupTestData.createTestContact('Test contact',testAccount.Account__c); 
		

		tpaRequest1 = UTL_TPA_SetupTestData.CreateTestRequest(testClientAccount.id, testAccount.Id );
		tpaRequest1.Data_Access_Start_Date__c = todayDate.addDays(-5);
		tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-3);
		update tpaRequest1;

	}

}