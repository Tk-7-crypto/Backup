@isTest
public class TST_DAOH_CLM_APTS_DocumentVersion {
    
    @testSetup
    static void setUpTestData() {        
        List<User> testUserList = UTL_TestData.createUser('Sales User', 1);
        insert testUserList;
        
        List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name =: CON_CLM.CLM_USBU_PERMISSIONSET OR Name =: CON_CLM.CLM_IQVIA_BASE_PERMISSIONSET];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = testUserList[0].Id, PermissionSetId = ps[0].Id);
        psaList.add(psa1);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = testUserList[0].Id, PermissionSetId = ps[1].Id);
        psaList.add(psa2);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            upsert psaList;
        }
        
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__DocumentVersion__c', 'Apttus__DocumentVersion__Share','Agreement_Territory__c',
                                                                                              '', 'Derived', '', 'Account_Country__c', 'Record_Type_Developer_Name__c', '', '');
        socsList.add(sObjectParentSharing);
        insert socsList;
        List<Group> groupList = [Select Id from Group limit 1];
        Territory_Sharing__c territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__DocumentVersion__c');
        insert territorySharing;
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        List<IQVIA_Agreement__c> lstIQVAgreement = new List<IQVIA_Agreement__c>();
        IQVIA_Agreement__c iqvagreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqvagreement.Name = 'Test IQVIA Agreement';
        iqvagreement.Services__c = 'FMV Navigator';
        iqvagreement.Account__c = acc.Id;
        lstIQVAgreement.add(iqvagreement);
        IQVIA_Agreement__c iqvagreement2 = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqvagreement2.Name = 'Test IQVIA Agreement 2';
        iqvagreement2.Services__c = 'FMV Navigator';
        iqvagreement2.Account__c = acc.Id;
        lstIQVAgreement.add(iqvagreement2);
        insert lstIQVAgreement;
        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.GENERIC_RECORDTYPEID, false);
        agreement.Name = 'Test USBU Agreement';
        agreement.Apttus__Account__c = acc.Id;
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.IQVIA_Agreement__c = iqvagreement.Id;
        lstAgreement.add(agreement);
        Apttus__APTS_Agreement__c agreement2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        agreement2.Name = 'Test MSA Agreement';
        agreement2.Apttus__Account__c = acc.Id;
        agreement2.Apttus__Status__c = 'Request';
        agreement2.Apttus__Status_Category__c = 'Request';
        lstAgreement.add(agreement2);
        Apttus__APTS_Agreement__c agreement3 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.GENERIC_RECORDTYPEID, false);
        agreement3.Name = 'Test USBU Agreement 2';
        agreement3.Apttus__Account__c = acc.Id;
        agreement3.Apttus__Status__c = 'Request';
        agreement3.Apttus__Status_Category__c = 'Request';
        agreement3.IQVIA_Agreement__c = iqvagreement2.Id;
        lstAgreement.add(agreement3);
        insert lstAgreement;
        List<Apttus__DocumentVersion__c> lstDocVersion = new List<Apttus__DocumentVersion__c>();
        Apttus__DocumentVersion__c documentVersion = new Apttus__DocumentVersion__c();
        documentVersion.Apttus__IsTransient__c = false;
        documentVersion.Apttus__Title__c = 'test document';
        documentVersion.Apttus__LatestVersion__c = '1.0.0';
        documentVersion.Apttus__AgreementId__c = agreement.Id;
        documentVersion.Apttus__LatestReviewCycleStatus__c = CON_CLM.NOT_STARTED;
        lstDocVersion.add(documentVersion);
        Apttus__DocumentVersion__c documentVersion2 = new Apttus__DocumentVersion__c();
        documentVersion2.Apttus__IsTransient__c = false;
        documentVersion2.Apttus__Title__c = 'test document 2';
        documentVersion2.Apttus__LatestVersion__c = '1.0.0';
        documentVersion2.Apttus__AgreementId__c = agreement2.Id;
        lstDocVersion.add(documentVersion2);
        Apttus__DocumentVersion__c documentVersion3 = new Apttus__DocumentVersion__c();
        documentVersion3.Apttus__IsTransient__c = false;
        documentVersion3.Apttus__Title__c = 'test document 3';
        documentVersion3.Apttus__LatestVersion__c = '1.0.0';
        documentVersion3.Apttus__AgreementId__c = agreement.Id;
        documentVersion3.Apttus__LatestReviewCycleStatus__c = CON_CLM.IN_PROGRESS;
        lstDocVersion.add(documentVersion3);
        Apttus__DocumentVersion__c documentVersion4 = new Apttus__DocumentVersion__c();
        documentVersion4.Apttus__IsTransient__c = false;
        documentVersion4.Apttus__Title__c = 'test document 4';
        documentVersion4.Apttus__LatestVersion__c = '1.0.0';
        documentVersion4.Apttus__AgreementId__c = agreement.Id;
        documentVersion4.Apttus__LatestReviewCycleStatus__c = CON_CLM.IN_PROGRESS;
        lstDocVersion.add(documentVersion4);
        Apttus__DocumentVersion__c documentVersion5 = new Apttus__DocumentVersion__c();
        documentVersion5.Apttus__IsTransient__c = false;
        documentVersion5.Apttus__Title__c = 'test document 5';
        documentVersion5.Apttus__LatestVersion__c = '1.0.0';
        documentVersion5.Apttus__AgreementId__c = agreement3.Id;
        documentVersion5.Apttus__LatestReviewCycleStatus__c = CON_CLM.IN_PROGRESS;
        lstDocVersion.add(documentVersion5);
        insert lstDocVersion;

        Apttus__DocumentVersionDetail__c dvd = new Apttus__DocumentVersionDetail__c();
        dvd.Name = 'TestName';
        dvd.Apttus__DocumentVersionId__c = documentVersion.Id;
        dvd.Apttus__Title__c ='TestTitle';
        dvd.Apttus__VersionMajor__c = 1;
        dvd.Apttus__VersionMinor__c = 0;
        dvd.Apttus__VersionRevision__c = 0;
        insert dvd;
        
        SObject_Sharing_Settings__c sharingSetting = new SObject_Sharing_Settings__c();
        sharingSetting.Sharing_Daily_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Daily_Correction';
        sharingSetting.Sharing_Failure_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Failure_Correction';
        sharingSetting.Sharing_Maintenance_Job_Batch_Name__c = 'BCH_GBL_Sharing_Maintenance_Job';
        sharingSetting.Parent_Sharing_FieldSet_Name__c = 'SHR_Parent_FieldSet';
        sharingSetting.Child_Sharing_FieldSet_Name__c = 'SHR_Child_FieldSet';
        sharingSetting.Last_Sharing_Calculation_Timestamp__c = System.Now().addMinutes(-100);
        insert sharingSetting;
        
        Contact tlContact = new Contact();
        tlContact.FirstName = 'Test';
        tlContact.LastName = 'Team Lead Contact';
        tlContact.Email = 'testlead@example.com';
        tlContact.EmployeeNumber__c = testUserList[0].EmployeeNumber;
        tlContact.RecordTypeId = CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID;
        insert tlContact;
        
        IQVIA_Agreement_Team__c teamLead = new IQVIA_Agreement_Team__c();
        teamLead.Role__c = 'Team Lead';
        teamLead.Type__c = CON_CLM.IQVIA_USER_CONTACT_TYPE;
        teamLead.Agreement__c = iqvagreement2.Id;
        teamLead.Contact__c = tlContact.Id;
        insert teamLead;
    }
    
    @isTest
    static void testSetSharing(){
        List<Apttus__DocumentVersion__c> lstDV = [SELECT Id,Apttus__AgreementId__c,Last_Sharing_Calculation_Timestamp__c 
                                                  FROM Apttus__DocumentVersion__c 
                                                  WHERE Apttus__Title__c = 'test document'];
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.setSharing(lstDV, null);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id FROM Apttus__DocumentVersion__Share],'sharing not done when expected');
    }
    
    @isTest
    static void testSetLastSharingCalculationTimestamp() {
        
        Apttus__DocumentVersion__c oldDV = [SELECT Id,Apttus__AgreementId__c,Last_Sharing_Calculation_Timestamp__c 
                                            FROM Apttus__DocumentVersion__c 
                                            WHERE Apttus__Title__c = 'test document' LIMIT 1];
        
        Apttus__DocumentVersion__c newDV = oldDV.clone(true, false, false, false);
        newDV.Apttus__AgreementId__c = null;
        
        Map<Id, Apttus__DocumentVersion__c> oldMap = new Map<Id, Apttus__DocumentVersion__c>();
        oldMap.put(oldDV.Id, oldDV);

        Test.startTest();
        	DAOH_CLM_APTS_DocumentVersion.setLastSharingCalculationTimestamp(new List<Apttus__DocumentVersion__c>{newDV}, oldMap);
        Test.stopTest();
        
        Date expected = Date.today(); 
        DateTime dT = newDV.Last_Sharing_Calculation_Timestamp__c;
        Date actual = date.newinstance(dT.year(), dT.month(), dT.day());
        System.assertEquals(expected,actual);
    }
    
    @isTest
    static void testSetLastManualSharingFieldUpdate() {
        Apttus__DocumentVersion__c newDV = [SELECT Id,Apttus__AgreementId__c,Last_Sharing_Calculation_Timestamp__c 
                                            FROM Apttus__DocumentVersion__c 
                                            WHERE Apttus__Title__c = 'test document' LIMIT 1];
        
        newDV.Run_Sharing__c = true;

        Test.startTest();
        	DAOH_CLM_APTS_DocumentVersion.SetLastManualSharingFieldUpdate(new List<Apttus__DocumentVersion__c>{newDV}, null);
        Test.stopTest();
        
        System.assertNotEquals(null ,newDV.Last_Manual_Sharing_Execution__c , 'not same');
    }
    
    @isTest
    static void testSetDummyCreatorAccess(){
        List<Apttus__DocumentVersion__c> lstDV = [SELECT Id,Apttus__AgreementId__c,Last_Sharing_Calculation_Timestamp__c,OwnerId 
                                                  FROM Apttus__DocumentVersion__c 
                                                  WHERE Apttus__Title__c = 'test document'];
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.setDummyCreatorAccess(lstDV);
        Test.stopTest();
        
    }

    @isTest
    static void testUpdateAgreements(){
        Apttus__DocumentVersion__c oldDV = [SELECT Id,Apttus__AgreementId__c,Apttus__LatestReviewCycleStatus__c 
                                                    FROM Apttus__DocumentVersion__c 
                                                    WHERE Apttus__Title__c = 'test document 2' LIMIT 1];
        oldDV.Apttus__LatestReviewCycleStatus__c = null;
        Apttus__DocumentVersion__c newDV = oldDV.clone(true, false, false, false);
        newDV.Apttus__LatestReviewCycleStatus__c = CON_CLM.NOT_STARTED;
        
        Map<Id, Apttus__DocumentVersion__c> oldMap = new Map<Id, Apttus__DocumentVersion__c>();
        oldMap.put(oldDV.Id, oldDV);
        
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.updateAgreements(new List<Apttus__DocumentVersion__c>{newDV}, oldMap);
        Test.stopTest();

        System.assertEquals(CON_CLM.INTERNAL_REVIEW, [SELECT Id,Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Id =: oldDV.Apttus__AgreementId__c LIMIT 1].Apttus__Status__c,
            'Agreement status not updated when expected'); 
    }
    
    @isTest
    static void testUpdateIQVAgreements(){
        Apttus__DocumentVersion__c oldDV = [SELECT Id,Apttus__AgreementId__c,Apttus__LatestReviewCycleStatus__c 
                                                    FROM Apttus__DocumentVersion__c 
                                                    WHERE Apttus__Title__c = 'test document' LIMIT 1];
        Apttus__DocumentVersion__c newDV = oldDV.clone(true, false, false, false);
        newDV.Apttus__LatestReviewCycleStatus__c = CON_CLM.IN_PROGRESS;
        update newDV;
        
        IQVIA_Agreement__c oldAgreement = [SELECT Id, Status__c, Conga_Agreement_Id__c , OwnerId FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        oldAgreement.Conga_Agreement_Id__c  = oldDV.Apttus__AgreementId__c;
        update oldAgreement;
        
        Map<Id, Apttus__DocumentVersion__c> oldMap = new Map<Id, Apttus__DocumentVersion__c>();
        oldMap.put(oldDV.Id, oldDV);
        
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.updateAgreements(new List<Apttus__DocumentVersion__c>{newDV}, oldMap);
        Test.stopTest();

        System.assertEquals(CON_CLM.INTERNAL_LEGAL_REVIEW, [SELECT Id, Status__c, OwnerId FROM IQVIA_Agreement__c WHERE Conga_Agreement_Id__c  =: oldDV.Apttus__AgreementId__c LIMIT 1].Status__c,
            'Agreement status not updated when expected');
    }

    @isTest
    static void testUpdateIQVAgreementsCompleted(){
        Apttus__DocumentVersion__c oldDV = [SELECT Id,Apttus__AgreementId__c,Apttus__LatestReviewCycleStatus__c 
                                                    FROM Apttus__DocumentVersion__c 
                                                    WHERE Apttus__Title__c = 'test document 5' LIMIT 1];
        Apttus__DocumentVersion__c newDV = oldDV.clone(true, false, false, false);
        newDV.Apttus__LatestReviewCycleStatus__c = CON_CLM.COMPLETED;
        update newDV;
        
        IQVIA_Agreement__c oldAgreement = [SELECT Id, Status__c, Conga_Agreement_Id__c , OwnerId FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement 2' LIMIT 1];
        oldAgreement.Conga_Agreement_Id__c  = oldDV.Apttus__AgreementId__c;
        update oldAgreement;
        
        Map<Id, Apttus__DocumentVersion__c> oldMap = new Map<Id, Apttus__DocumentVersion__c>();
        oldMap.put(oldDV.Id, oldDV);
        
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.updateAgreements(new List<Apttus__DocumentVersion__c>{newDV}, oldMap);
        Test.stopTest();

        System.assertEquals(CON_CLM.INTERNAL_REVIEW, [SELECT Id, Status__c, OwnerId FROM IQVIA_Agreement__c WHERE Conga_Agreement_Id__c  =: oldDV.Apttus__AgreementId__c LIMIT 1].Status__c,
            'Agreement status not updated when expected');
        
        System.assertNotEquals(oldAgreement.OwnerId, [SELECT Id, Status__c, OwnerId FROM IQVIA_Agreement__c WHERE Conga_Agreement_Id__c  =: oldDV.Apttus__AgreementId__c LIMIT 1].OwnerId,
            'Owner not updated when expected');
    }

    @isTest
    static void testUpdateIQVAgreementsCancelled(){
        Apttus__DocumentVersion__c oldDV = [SELECT Id,Apttus__AgreementId__c,Apttus__LatestReviewCycleStatus__c 
                                                    FROM Apttus__DocumentVersion__c 
                                                    WHERE Apttus__Title__c = 'test document 5' LIMIT 1];
        Apttus__DocumentVersion__c newDV = oldDV.clone(true, false, false, false);
        newDV.Apttus__LatestReviewCycleStatus__c = CON_CLM.CANCELLED;
        update newDV;
        
        IQVIA_Agreement__c oldAgreement = [SELECT Id, Status__c, Conga_Agreement_Id__c , OwnerId FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement 2' LIMIT 1];
        oldAgreement.Conga_Agreement_Id__c  = oldDV.Apttus__AgreementId__c;
        update oldAgreement;
        
        Map<Id, Apttus__DocumentVersion__c> oldMap = new Map<Id, Apttus__DocumentVersion__c>();
        oldMap.put(oldDV.Id, oldDV);
        
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.updateAgreements(new List<Apttus__DocumentVersion__c>{newDV}, oldMap);
        Test.stopTest();

        System.assertEquals(CON_CLM.INTERNAL_REVIEW, [SELECT Id, Status__c, OwnerId FROM IQVIA_Agreement__c WHERE Conga_Agreement_Id__c  =: oldDV.Apttus__AgreementId__c LIMIT 1].Status__c,
            'Agreement status not updated when expected');
    }
    
    @isTest
    static void testUpdateIQVAgreementsMultipleReviewCycles(){
        List<Apttus__DocumentVersion__c> oldDV = [SELECT Id,Apttus__AgreementId__c,Apttus__LatestReviewCycleStatus__c 
                                                    FROM Apttus__DocumentVersion__c 
                                                    WHERE Apttus__Title__c = 'test document 3' OR Apttus__Title__c = 'test document 4'];
        Apttus__DocumentVersion__c newDV1 = oldDV[0].clone(true, false, false, false);
        Apttus__DocumentVersion__c newDV2 = oldDV[1].clone(true, false, false, false);
        newDV1.Apttus__LatestReviewCycleStatus__c = CON_CLM.COMPLETED;
        update newDV1;
        
        List<Apttus__DocumentVersion__c> newDV = new List<Apttus__DocumentVersion__c>{newDV1, newDV2};
        
        IQVIA_Agreement__c oldAgreement = [SELECT Id, Status__c, Conga_Agreement_Id__c , OwnerId FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        oldAgreement.Conga_Agreement_Id__c  = oldDV[0].Apttus__AgreementId__c;
        update oldAgreement;
        
        Map<Id, Apttus__DocumentVersion__c> oldMap = new Map<Id, Apttus__DocumentVersion__c>();
        oldMap.put(oldDV[0].Id, oldDV[0]);
        oldMap.put(oldDV[1].Id, oldDV[1]);
        
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.updateAgreements(newDV, oldMap);
        Test.stopTest();

        System.assertEquals(CON_CLM.INTERNAL_LEGAL_REVIEW, [SELECT Id, Status__c, OwnerId FROM IQVIA_Agreement__c WHERE Conga_Agreement_Id__c  =: oldDV[0].Apttus__AgreementId__c LIMIT 1].Status__c,
            'Agreement status updated when not expected');
    }

    @isTest
    static void testUnlockDocumentVersion(){
        Apttus__DocumentVersion__c oldDV = [SELECT Id,Apttus__AgreementId__c,Apttus__LatestReviewCycleStatus__c 
                                                    FROM Apttus__DocumentVersion__c 
                                                    WHERE Apttus__Title__c = 'test document' LIMIT 1];
        oldDV.Apttus__LatestReviewCycleStatus__c = null;
        Apttus__DocumentVersionDetail__c dvd = [SELECT Id FROM Apttus__DocumentVersionDetail__c 
                                                    WHERE Apttus__DocumentVersionId__c =: oldDV.Id LIMIT 1];
        Apttus__DocumentVersion__c newDV = oldDV.clone(true, false, false, false);
        newDV.Apttus__LatestReviewCycleStatus__c = CON_CLM.NOT_STARTED;
        newDV.Apttus__CheckoutById__c = UserInfo.getUserId();
        newDV.Apttus__CheckoutDate__c = Date.today();
        newDV.Apttus__CheckoutVersionDetailId__c = dvd.Id;
        
        Map<Id, Apttus__DocumentVersion__c> oldMap = new Map<Id, Apttus__DocumentVersion__c>();
        oldMap.put(oldDV.Id, oldDV);
        
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.unlockDocumentVersion(new List<Apttus__DocumentVersion__c>{newDV}, oldMap);
        Test.stopTest();

        System.assertEquals(null, newDV.Apttus__CheckoutVersionDetailId__c, 'Expected null value checkout version detail'); 
        System.assertEquals(null, newDV.Apttus__CheckoutDate__c, 'Expected null value of checkout date'); 
    }

    @isTest
    static void testUpdateIQAGRRecordTypeName() {
        Apttus__DocumentVersion__c docVersion = [SELECT Id,Apttus__AgreementId__c,Apttus__LatestReviewCycleStatus__c 
                                                    FROM Apttus__DocumentVersion__c 
                                                    WHERE Apttus__Title__c = 'test document 5' LIMIT 1];
        
        Test.startTest();
            DAOH_CLM_APTS_DocumentVersion.updateIQAGRRecordTypeName(new List<Apttus__DocumentVersion__c>{docVersion});
        Test.stopTest();

        System.assertEquals('USBU', docVersion.IQ_Agreement_Record_Type_Developer_Name__c, 'Expected USBU Record Type'); 
    }
}