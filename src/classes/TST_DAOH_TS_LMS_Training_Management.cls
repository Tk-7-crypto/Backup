@isTest
public class TST_DAOH_TS_LMS_Training_Management {
	@testSetup
    static void setup() {
        Account acc = new Account(Name = 'IQVIA CONSOLIDATED ACCOUNT TEST', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',AccountCountry__c = 'AF',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        Contact con = new Contact(FirstName = 'TestFirstName', LastName = 'TestContact', accountId = acc.Id,Email='test@testmail.com');
        insert con;
    }
    @isTest
    static void tstSetAccountOfContact(){
        Contact con = [SELECT Id,accountId from Contact where email='test@testmail.com' LIMIT 1];
        TS_LMS_Training_Management__c tlms = new TS_LMS_Training_Management__c(Contact__c=con.Id,Status__c='NEW',IQVIA_Key_Contact__c=con.Id);
        Test.startTest();
            insert tlms;
        Test.stopTest();
    }
}