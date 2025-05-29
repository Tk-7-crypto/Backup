@isTest
public class TST_BCH_GBL_Sharing_Maintenance_Job {
    
    @testSetup
    static void dataSetup() {
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share','Agreement_Territory__c',
                                                                                              'Agreement_Team__c', 'Derived', 'Agreement__c', 'Account_Country__c', 'Record_Type__c', '', '');
        socsList.add(sObjectParentSharing);
        insert socsList;
        List<Group> groupList = [Select id from Group limit 1];
        List<Territory_Sharing__c> territorySharingList = new List<Territory_Sharing__c>();
        Territory_Sharing__c territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__APTS_Agreement__c');
        territorySharingList.add(territorySharing);
        territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__APTS_Agreement__c');
        territorySharing.Account_Country__c = 'US';
        territorySharingList.add(territorySharing);
        insert territorySharingList;
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        SObject_Sharing_Settings__c sharingSetting = new SObject_Sharing_Settings__c();
        sharingSetting.Sharing_Daily_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Daily_Correction';
        sharingSetting.Sharing_Failure_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Failure_Correction';
        sharingSetting.Sharing_Maintenance_Job_Batch_Name__c = 'BCH_GBL_Sharing_Maintenance_Job';
        sharingSetting.Parent_Sharing_FieldSet_Name__c = 'SHR_Parent_FieldSet';
        sharingSetting.Child_Sharing_FieldSet_Name__c = 'SHR_Child_FieldSet';
        insert sharingSetting;
        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
    }
    
    @isTest
    static void testMaintenanceSharingBatch() {
        Test.startTest();
        List<SObject_Sharing__c> socsList = [select Id, Child_Sobject__c, Maintenance_Job_Status__c, Parent_Sobject__c, Lookup_Name__c, Child_Sobject_Share__c, Parent_Sobject_Share__c, Enable_Sharing_Calculation__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Business_Unit_Api_Name__c, Parent_Customer_Code_Api_Name__c, Sharing_Type__c, Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Sharing_Owner_Label__c, Team_Sharing_Lookup_Field__c,Parent_Sharing_Team_Label__c, Parent_Sharing_Territory_Label__c from SObject_Sharing__c WHERE Enable_Sharing_Calculation__c = true];
        BCH_GBL_Sharing_Maintenance_Job sharingMaintenanceBatch = new BCH_GBL_Sharing_Maintenance_Job(socsList);
        Database.executeBatch(sharingMaintenanceBatch);
        List<Territory_Sharing__c> territorySharingList = [SELECT Id, Name, Maintenance_Job_Status__c, Record_Type__c, Parent_Customer_Code__c, Account_Country__c, Business_Unit__c, isActive__c, Parent_Sobject_Name__c FROM Territory_Sharing__c];
        sharingMaintenanceBatch = new BCH_GBL_Sharing_Maintenance_Job(territorySharingList);
        Database.executeBatch(sharingMaintenanceBatch);
        Test.stopTest();
    }
}