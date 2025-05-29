@isTest
public class TST_DAO_APTS_DocumentVersion {
	@testSetup
    static void setUpTestData() {        
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__DocumentVersion__c', 'Apttus__DocumentVersion__Share','Agreement_Territory__c',
                                                                                              '', 'Derived', '', 'Account_Country__c', 'Record_Type_Developer_Name__c', '', '');
        socsList.add(sObjectParentSharing);
        insert socsList;
        List<Group> groupList = [Select Id from Group limit 1];
        Territory_Sharing__c territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__DocumentVersion__c');
        insert territorySharing;
        
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
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        agreement.Apttus__Account__c = acc.Id;
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Status_Category__c = 'Request';
        insert agreement;
        Apttus__DocumentVersion__c documentVersion = new Apttus__DocumentVersion__c();
        documentVersion.Apttus__IsTransient__c = false;
        documentVersion.Apttus__Title__c = 'test document';
        documentVersion.Apttus__LatestVersion__c = '1.0.0';
        documentVersion.Apttus__AgreementId__c = agreement.Id;
        
        Test.startTest();
            insert documentVersion;
        	update documentVersion;
        Test.stopTest();
        
        System.assertNotEquals(null, [SELECT Id FROM Apttus__DocumentVersion__Share],'sharing not done when expected');
    }
}