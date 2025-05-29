@isTest
public class TST_BCH_GBL_Sharing_Daily_Correction {
    
    @testSetup
    static void dataSetup() {   
        
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
        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        agreement.Last_Sharing_Calculation_Timestamp__c = System.Now();
        insert agreement;
    }
    
    @isTest
    static void testDailySharing() {
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share','Agreement_Territory__c',
                                                                                              'Agreement_Team__c', 'Manual', 'Agreement__c', '', '', '', '');
        socsList.add(sObjectParentSharing);
        insert socsList;
        Test.startTest();
        BCH_GBL_Sharing_Daily_Correction dailySharingBatch = new BCH_GBL_Sharing_Daily_Correction();
        Database.executeBatch(dailySharingBatch);
        Test.stopTest();
    }
    
    @isTest
    static void testDailySharing3() {
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share','Agreement_Territory__c',
                                                                                              'Agreement_Team__c', 'Derived', 'Agreement__c', 'Account_Country__c', 'Record_Type__c', '', '');
        socsList.add(sObjectParentSharing);
        
        SObject_Sharing__c sObjectChildSharing = UTL_TestData.createSObjectSharingChildData('Account', 'AccountShare', 'Apttus__APTS_Agreement__c',
                                                                                            'Apttus__APTS_Agreement__Share', 'Apttus__Account__c', '', '', 
                                                                                            '','','','');
        sObjectChildSharing.Sharing_Type__c = 'Manual';
        socsList.add(sObjectChildSharing);
        insert socsList;
        Test.startTest();
        BCH_GBL_Sharing_Daily_Correction dailySharingBatch = new BCH_GBL_Sharing_Daily_Correction();
        Database.executeBatch(dailySharingBatch);
        Test.stopTest();
    }
    
}