@isTest
public class TST_DAOH_APTS_Agreement {
    
    @testSetup
    static void setUpTestData() {        
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share','Agreement_Territory__c',
                                                                                              'Agreement_Team__c', 'Derived', 'Agreement__c', 'Account_Country__c', 'Record_Type__c', '', '');
        socsList.add(sObjectParentSharing);
        insert socsList;
        List<Group> groupList = [Select Id from Group limit 1];
        Territory_Sharing__c territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__APTS_Agreement__c');
        insert territorySharing;
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        SObject_Sharing_Settings__c sharingSetting = new SObject_Sharing_Settings__c();
        sharingSetting.Sharing_Daily_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Daily_Correction';
        sharingSetting.Sharing_Failure_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Failure_Correction';
        sharingSetting.Sharing_Maintenance_Job_Batch_Name__c = 'BCH_GBL_Sharing_Maintenance_Job';
        sharingSetting.Parent_Sharing_FieldSet_Name__c = 'SHR_Parent_FieldSet';
        sharingSetting.Child_Sharing_FieldSet_Name__c = 'SHR_Child_FieldSet';
        sharingSetting.Last_Sharing_Calculation_Timestamp__c = System.Now().addMinutes(-100);
        insert sharingSetting;
    }
    
    @isTest
    static void testSetSharing(){
        Test.startTest();
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
        Test.stopTest();
    }
    
    @isTest
    static void testSetAccountCountry(){
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        
        Test.startTest();
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
        Test.stopTest();
        Apttus__APTS_Agreement__c agr = [SELECT Id,Account_Country__c FROM Apttus__APTS_Agreement__c WHERE Id = :agreement.Id];
        system.assertEquals(acc.AccountCountry__c, agr.Account_Country__c);
    }
    
    @isTest
    static void testSetLastSharingCalculationTimestamp(){
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
        
        Test.startTest();
        agreement.Name = 'Update Agreement';
        agreement.Apttus__Account__c = null;
        update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id,Last_Sharing_Calculation_Timestamp__c FROM Apttus__APTS_Agreement__c WHERE Id = :agreement.Id];
        Date expected = Date.today(); 
        DateTime dT = agr.Last_Sharing_Calculation_Timestamp__c;
        Date actual = date.newinstance(dT.year(), dT.month(), dT.day());
        system.assertEquals(expected,actual);
    }
    
    @isTest
    static void testSetLastManualSharingFieldUpdate(){
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
        Test.startTest();
        agreement.Run_Sharing__c = true;
        update agreement;
        Test.stopTest();
        Apttus__APTS_Agreement__c agr = [SELECT Id,Last_Manual_Sharing_Execution__c FROM Apttus__APTS_Agreement__c WHERE Id = :agreement.Id];
        Date expected = Date.today(); 
        DateTime dT = agr.Last_Manual_Sharing_Execution__c;
        Date actual = date.newinstance(dT.year(), dT.month(), dT.day());
        system.assertEquals(expected,actual);
    }
    
}