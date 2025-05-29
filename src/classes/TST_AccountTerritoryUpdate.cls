@isTest
public class TST_AccountTerritoryUpdate {
	testmethod static void testUpdateAcountTerritory() {
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        
        Account newAccount = UTL_TestData.createAccount();
        newAccount.AccountCountry__c = 'IN';
        insert newAccount;
            
        newAccount.AccountCountry__c = 'AL';
        update newAccount;
        Test.stopTest();
    }

}