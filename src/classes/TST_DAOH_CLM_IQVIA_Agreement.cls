/**
* This test class is used to test all methods in IQVIA trigger helper.
* version : 1.0
*/
@IsTest
private class TST_DAOH_CLM_IQVIA_Agreement {
    @TestSetup
    private static void testIQAgreementInsert() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.Enable_Agreement_Repository__c = true;
        insert clmConfiguration;

        Account account = new Account(Name = 'Avacare',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '5. Finalizing Deal';
        oppList.add(newOpportunity);
        insert oppList;
        
        Account acc = new Account(Name = 'PI-Account', Type2__c = 'Investigator', ParentId = account.Id, CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        
        Site_Submission__c siteSubmission = UTL_TestData.creatSiteSubmissionRecord(oppList.get(0).Id, acc.Id, null);
        insert siteSubmission;

        List<IQVIA_Agreement__c> lstAgreement = new List<IQVIA_Agreement__c>();
        IQVIA_Agreement__c agreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, true);
        agreement.Name = 'Test IQVIA Agreement';
        agreement.Related_Opportunity__c = oppList.get(0).Id;
        agreement.Account__c = account.Id;
        agreement.Services__c = 'FMV Navigator';
        agreement.Contract_End_Date__c = System.today();
        agreement.Requestor__c = UserInfo.getUserId();
        lstAgreement.add(agreement);
        
        IQVIA_Agreement__c childAgreement1 = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        childAgreement1.Name = 'Test Child Agreement1';
        childAgreement1.Agreement_Cloned_From__c = agreement.Id;
        childAgreement1.Version_Number__c = 1;
        childAgreement1.Agreement_Number__c = agreement.Agreement_Number__c;
        lstAgreement.add(childAgreement1);
        
        IQVIA_Agreement__c childAgreement2 = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        childAgreement2.Name = 'Test Child Agreement2';
        childAgreement2.Agreement_Cloned_From__c = agreement.Id;
        childAgreement2.Version_Number__c = 1;
        childAgreement2.Agreement_Number__c = agreement.Agreement_Number__c;
        lstAgreement.add(childAgreement2);
        
        IQVIA_Agreement__c agreement2 = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, true);
        agreement2.Name = 'Test IQVIA Agreement 2';
        agreement2.Related_Opportunity__c = oppList.get(0).Id;
        agreement2.Account__c = account.Id;
        agreement2.Services__c = 'FMV Navigator';
        lstAgreement.add(agreement2);
        
        IQVIA_Agreement__c agreement3 = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.AVACARE_IQVIA_RECORDTYPEID, false);
        agreement3.Name = 'Test IQVIA Avacare';
        agreement3.Related_Opportunity__c = oppList.get(0).Id;
        agreement3.Subtype__c = CON_CLM.INVESTIGATOR_CONTRACT;
        agreement3.Site_Submission__c = siteSubmission.Id;
        lstAgreement.add(agreement3);
        upsert lstAgreement;
        
        Apttus__APTS_Agreement__c congaAgr = TST_CLM_TestDataFactory.createAgreement(CON_CLM.GENERIC_RECORDTYPEID, false);
        congaAgr.Name = 'Test IQVIA Agreement 2';
        congaAgr.IQVIA_Agreement__c = agreement2.Id;
        insert congaAgr;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';      
        cv.PathOnClient = 'abc.pdf';
        cv.VersionData = Blob.valueOf('Test Content'); 
        cv.Description = 'Final Signed Document';
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title FROM ContentDocument WHERE Title = 'Test'];
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = agreement.Id;
        contentDocLink.ContentDocumentId = contDocs[0].Id; 
        insert contentDocLink;
    }
    
    @isTest
    private static void testSetIQVIAAgreementNumber() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.setIQVIAAgreementNumber(new Set<Id>{agreement.Id});
        Test.stopTest();
        
        IQVIA_Agreement__c updateAGR = [SELECT Id, Agreement_Number__c, Contract_Auto_Number__c FROM IQVIA_Agreement__c WHERE Id =: agreement.Id];
        System.assertEquals(updateAGR.Agreement_Number__c, updateAGR.Contract_Auto_Number__c, 'Returned agreement number should match');
    }
    
    @isTest
    private static void testCreateCongaAgreementFromIqvAgreement() {
        IQVIA_Agreement__c oldAgreement = [SELECT id, Name, Status_Category__c, Status__c,Conga_Agreement_Id__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        oldAgreement.Status_Category__c = 'Request';
        oldAgreement.Status__c = 'Request';
        IQVIA_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Status_Category__c = 'Request';
        newAgreement.Status__c = 'Assigned';
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.createCongaAgreementFromIqvAgreement(new List<IQVIA_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        Apttus__APTS_Agreement__c congaAGR = [SELECT Id, IQVIA_Agreement__c FROM Apttus__APTS_Agreement__c WHERE IQVIA_Agreement__c =: newAgreement.Id LIMIT 1];
        System.assertNotEquals(null, congaAGR, 'Conga Agreement not created from IQVIA Agreement');
    }
    
    @isTest
    private static void testCreateAPTSAgreement() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name, Subtype__c, Account_Country__c, OwnerId, Requestor__c, Contract_Auto_Number__c
                                        FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        
        Test.startTest();
        	Apttus__APTS_Agreement__c congaAgr = DAOH_CLM_IQVIA_Agreement.createAPTSAgreement(agreement);
        Test.stopTest();
        
        System.assertNotEquals(null, congaAgr, 'Returned agreement number should match');
    }

    @isTest
    private static void testUpdateRequestDate() {
        IQVIA_Agreement__c oldAgreement = [SELECT id, Name, Status_Category__c, Status__c,Conga_Agreement_Id__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        oldAgreement.Status_Category__c = CON_CLM.IN_AUTHORING;
        oldAgreement.Status__c = CON_CLM.STATUS_OTHER_PARTY_REVIEW;
        IQVIA_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Status_Category__c = CON_CLM.IN_AUTHORING;
        newAgreement.Status__c = CON_CLM.INTERNAL_REVIEW;
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.updateRequestDate(new List<IQVIA_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals(Datetime.now(), newAgreement.Request_Date__c, 'Request Date is not populated when expected');
    }
    
    @isTest 
    private static void testUpdateParallelChangeOrderAmendments() {
        IQVIA_Agreement__c childAgr = [SELECT Id, Name, Status_Category__c, Status__c, Agreement_Cloned_From__c,
            Agreement_Number__c, Version_Number__c FROM IQVIA_Agreement__c WHERE Name = 'Test Child Agreement1' LIMIT 1];
         
        IQVIA_Agreement__c parentAgr = [SELECT Id, Name, Status_Category__c, Status__c, Agreement_Cloned_From__c,
            Agreement_Number__c, Version_Number__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(childAgr.Id, childAgr);
        IQVIA_Agreement__c newChildAgr = childAgr.clone(true, false, false, false);
        newChildAgr.Status_Category__c = CON_CLM.IN_EFFECT;
        newChildAgr.Status__c = CON_CLM.ACTIVATED;
        newChildAgr.Version_Number__c = 2;
        Test.startTest();
            parentAgr.Status_Category__c = CON_CLM.IN_EFFECT;
            parentAgr.Status__c = CON_CLM.ACTIVATED;
            parentAgr.Contract_End_Date__c = System.today() + 1;
            update parentAgr;
            DAOH_CLM_IQVIA_Agreement.updateParallelChangeOrderAmendments(new List<IQVIA_Agreement__c>{newChildAgr}, oldMap);        
        Test.stopTest();
        
        System.assertEquals('Being Amended', newChildAgr.Status__c, 'Status field must be updated');
    }
    
    @isTest
    private static void testUpdatePreviousAgrForParallelCO() { 
        IQVIA_Agreement__c agreement = [SELECT Id, Name, Status_Category__c, Status__c FROM 
            IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        
        Test.startTest(); 
            DAOH_CLM_IQVIA_Agreement.updatePreviousAgrForParallelCO(new Map<Id, String>{agreement.Id => CON_CLM.AMENDED});
        Test.stopTest();
        
        IQVIA_Agreement__c result = [SELECT Id, Status_Category__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        System.assertEquals(CON_CLM.AMENDED, result.Status_Category__c, 'The Status Category should match');
    }
    
    @isTest
    private static void testChangePreviousAgrForParallelCO() { 
        IQVIA_Agreement__c agreement1 = [SELECT Id, Name FROM 
            IQVIA_Agreement__c WHERE Name = 'Test Child Agreement1' LIMIT 1];
        IQVIA_Agreement__c agreement2 = [SELECT Id, Name, Status_Category__c, Agreement_Cloned_From__c FROM 
            IQVIA_Agreement__c WHERE Name = 'Test Child Agreement2' LIMIT 1];
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.changePreviousAgrForParallelCO(new Map<Id, Id>{agreement2.Id => agreement1.Id});
        Test.stopTest();
        
        IQVIA_Agreement__c result = [SELECT Id, Agreement_Cloned_From__c FROM IQVIA_Agreement__c 
            WHERE Name = 'Test Child Agreement2' LIMIT 1];
        System.assertEquals(agreement1.Id, result.Agreement_Cloned_From__c, 'Previous Agreement should update');
    }

    @isTest
    private static void testUpdateCongaAgreementName() { 
        IQVIA_Agreement__c agreement = [SELECT Id, Name, Conga_Agreement_Id__c FROM 
            IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement 2' LIMIT 1];
        Apttus__APTS_Agreement__c congaAgreement = [SELECT ID, IQVIA_Agreement__c FROM 
            Apttus__APTS_Agreement__c WHERE IQVIA_Agreement__c =: agreement.Id LIMIT 1];
        agreement.Conga_Agreement_Id__c = congaAgreement.Id;
        update agreement;
        IQVIA_Agreement__c newAgreement = agreement.clone(true, false, false, false);
        newAgreement.Name = 'Test IQVIA Agreement 2.1';
        
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(agreement.Id, agreement);
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.updateCongaAgreementName(new List<IQVIA_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        Apttus__APTS_Agreement__c result = [SELECT Id, Name, IQVIA_Agreement__c FROM Apttus__APTS_Agreement__c 
            WHERE IQVIA_Agreement__c =: agreement.Id LIMIT 1];
        System.assertEquals(result.Name, newAgreement.Name, 'Conga Agreement Name Not Updated.');
    }

    @isTest
    private static void testUpdateSearchField() { 
        IQVIA_Agreement__c agreement = [SELECT Id, Name, Account__c, Account__r.Name, Search_Field__c, FF_Agreement_Number__c  
            FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.updateSearchField(new List<IQVIA_Agreement__c>{agreement}, null);
        Test.stopTest();
        
        System.assertEquals(agreement.Account__r.Name+''+agreement.FF_Agreement_Number__c, agreement.Search_Field__c, 'Conga Agreement Name Not Updated.');
    }
    
    @isTest
    private static void testActivateFullySignedAgreements() {
        IQVIA_Agreement__c oldAgreement = [SELECT id, Name, Status_Category__c, Status__c,Conga_Agreement_Id__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        oldAgreement.Status_Category__c = CON_CLM.IN_AUTHORING;
        oldAgreement.Status__c = CON_CLM.STATUS_OTHER_PARTY_REVIEW;
        IQVIA_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Status_Category__c = CON_CLM.IN_SIGNATURES;
        newAgreement.Status__c = CON_CLM.FULLY_SIGNED;
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.activateFullySignedAgreements(new List<IQVIA_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        IQVIA_Agreement__c updatedAgreement = [SELECT id, Status__c FROM IQVIA_Agreement__c WHERE Id = :newAgreement.Id][0];
        System.assertEquals(CON_CLM.ACTIVATED, updatedAgreement.Status__c, 'Agreement should be Activated');
    }

    @isTest
    private static void testUpdateAGROnFullySigned() {
        IQVIA_Agreement__c oldAgreement = [SELECT id, Name, Status_Category__c, Status__c,Conga_Agreement_Id__c,Requestor__c,OwnerId FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement'];
        oldAgreement.Status_Category__c = CON_CLM.IN_AUTHORING;
        oldAgreement.Status__c = CON_CLM.STATUS_OTHER_PARTY_REVIEW;
        IQVIA_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Status_Category__c = CON_CLM.IN_SIGNATURES;
        newAgreement.Status__c = CON_CLM.FULLY_SIGNED;
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.updateAGROnFullySigned(new List<IQVIA_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals(newAgreement.OwnerId, newAgreement.Requestor__c, 'Owner is not changed when expected');
    }

    @isTest
    private static void testUpdateActivationFields() {
        IQVIA_Agreement__c oldAgreement = [SELECT id, Name, Status_Category__c, Status__c,Conga_Agreement_Id__c,Requestor__c,OwnerId FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        oldAgreement.Status_Category__c = CON_CLM.IN_SIGNATURES;
        oldAgreement.Status__c = CON_CLM.FULLY_SIGNED;
        IQVIA_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Status_Category__c = CON_CLM.IN_EFFECT;
        newAgreement.Status__c = CON_CLM.ACTIVATED;
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.updateActivationFields(new List<IQVIA_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals(newAgreement.Activated_By__c, UserInfo.getUserId(), 'Activated by not updated when expected');
        System.assertEquals(newAgreement.Activated_Date__c, Date.today(), 'Activated Date not updated when expected');
    }
    
    @isTest
    private static void testSetDefaultAccount() {
        IQVIA_Agreement__c iqAgr = [SELECT Id, Site_Submission__c, Subtype__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Avacare' LIMIT 1];
        
        Test.startTest();
            DAOH_CLM_IQVIA_Agreement.setDefaultAccount(new List<IQVIA_Agreement__c>{iqAgr});
        Test.stopTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'PI-Account' LIMIT 1];
        System.assertEquals(acc.Id, iqAgr.Account__c, 'The account must be defaulted.');
    }

    @isTest
    private static void testCreateARAfterAgreementActivation() {
        IQVIA_Agreement__c iqAgr = [SELECT Id, Status__c, Subtype__c, Status_Category__C, Agreement_Repository_Number__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA Agreement' LIMIT 1];
        iqAgr.Status_Category__c = CON_CLM.IN_SIGNATURES;
        iqAgr.Status__c = CON_CLM.FULLY_SIGNED;
        IQVIA_Agreement__c newAgreement = iqAgr.clone(true, false, false, false);
        newAgreement.Status_Category__c = CON_CLM.IN_EFFECT;
        newAgreement.Status__c = CON_CLM.ACTIVATED;
        Map<Id, IQVIA_Agreement__c> oldMap = new Map<Id, IQVIA_Agreement__c>();
        oldMap.put(iqAgr.Id, iqAgr);
        
        Test.startTest();
            update newAgreement;
            DAOH_CLM_IQVIA_Agreement.createAROnActivation(new List<IQVIA_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        Agreement_Repository__c ar = [Select Id, AR_Number__c FROM Agreement_Repository__c Where IQVIA_Agreement__c=:newAgreement.Id][0];
        Assert.isTrue(ar.AR_Number__c != null, 'Should not be Null');       
    }
}