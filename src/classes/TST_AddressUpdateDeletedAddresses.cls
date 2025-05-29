/*
* Name              : TST_AddressUpdateDeletedAddresses
* Created By        : Suman Sharma
* Created Date      : 14 April, 2017
* Revision          : 
* Description       : Test Class for AddressUpdateDeletedAddresses apex class
*/
@isTest
public class TST_AddressUpdateDeletedAddresses {
  static testMethod void addressInsertUpdateTest() 
    {
        Account TempAccount = new Account(Name='Test Account',Status__c=MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED'),CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        TempAccount.MDM_Validation_Status__c = 'Validated';
        insert TempAccount;
        
        Address__c TempAddress = New Address__c(Name='Test Address',
                                                    Account__c=TempAccount.Id,
                                                    Street__c = 'Street',
                                                    City__c = 'City',
                                                    Country__c = 'Country',
                                                    Marked_For_Deletion__c = false,
                                                    SAP_Reference__c = '700010',
                                                   Status__c = 'In Review',
                                                   //OwnerId = '005390000058oJTAAY',
                                                   PO_Required__c = FALSE,MDM_Validation_Status__c = 'Validated');
            
        insert TempAddress;        
        TempAddress.SAP_Reference__c = '700011';       
        update TempAddress;
        delete TempAddress;
    }

}