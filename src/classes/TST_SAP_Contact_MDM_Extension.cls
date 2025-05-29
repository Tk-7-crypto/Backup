/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TST_SAP_Contact_MDM_Extension {

    static testMethod void myUnitTest() 
    {
        User TestUser = [select Id,Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
		Account TestAccount = new Account(Name='Test Account',Status__c=MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED'),CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
    	insert TestAccount;
    	Address__c TestAddress = New Address__c(Name='Test Address',
    												Account__c=TestAccount.Id,
    												Street__c = 'Street',
    												City__c = 'City',
    												Country__c = 'Country',
    												Marked_For_Deletion__c = false,
    												SAP_Reference__c = '495001');
		insert TestAddress;   
		SAP_Contact__c TestContact = new SAP_Contact__c(Address__c=TestAddress.Id,
														Name='Test SAP Contact'); 												
    	system.runAs(TestUser)
		{       
        	Apexpages.currentPage().getParameters().put('AddressId',TestAddress.Id);
        	//  Create an instance of the standard controller
	        ApexPages.StandardController stc = new ApexPages.StandardController(TestContact);	     
	        //  Create an instance of the controller extension       
	        SAP_Contact_MDM_Extension controller = new SAP_Contact_MDM_Extension(stc);
	        controller.getTitles();
	        controller.SendNewContactRequestNotificationEmail();
            controller.GoBack();
		}
    }
    
    static testMethod void myUnitTest1() 
    {
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        User TestUser = [select Id,Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        Account TestAccount = new Account(Name='Test Account',Status__c=MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED'),CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert TestAccount;
        Address__c TestAddress = New Address__c(Name='Test Address',
                                                Account__c=TestAccount.Id,
                                                Street__c = 'Street',
                                                City__c = 'City',
                                                Country__c = 'Country',
                                                Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001');
        insert TestAddress;   
        SAP_Contact__c TestContact = new SAP_Contact__c(Address__c=TestAddress.Id,
                                                        Name='Test SAP Contact'); 												
        system.runAs(TestUser)
        {       
            Apexpages.currentPage().getParameters().put('AddressId',TestAddress.Id);
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestContact);	     
            //  Create an instance of the controller extension       
            SAP_Contact_MDM_Extension controller = new SAP_Contact_MDM_Extension(stc);
            controller.getTitles();
            controller.SendNewContactRequestNotificationEmail();
            controller.GoBack();
        }
    }
}