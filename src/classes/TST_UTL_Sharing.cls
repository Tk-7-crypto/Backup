@isTest
private class TST_UTL_Sharing {
    @testSetup
    static void dataSetup() {
        SObject_Sharing_Settings__c sharingSetting = new SObject_Sharing_Settings__c();
        sharingSetting.Sharing_Daily_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Daily_Correction';
        sharingSetting.Sharing_Failure_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Failure_Correction';
        sharingSetting.Sharing_Maintenance_Job_Batch_Name__c = 'BCH_GBL_Sharing_Maintenance_Job';
        sharingSetting.Child_Sharing_FieldSet_Name__c	= 'SHR_Child_FieldSet';
        sharingSetting.Parent_Sharing_FieldSet_Name__c = 'SHR_Parent_FieldSet';
        insert sharingSetting;
        
        List<SObject_Sharing__c> sObjectSharingList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share','Agreement_Territory__c',
                                                                                              'Agreement_Team__c', 'Derived', 'Agreement__c', 'Account_Country__c', 'Record_Type__c', '', '');
        SObject_Sharing__c sObjectChildSharing = UTL_TestData.createSObjectSharingChildData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share', 'Apttus__AgreementLineItem__c', 'Agreement_Products__Share',
                                                                                            'Apttus__AgreementId__c', 'Agreement_Territory__c', 'Owner', 'sharing owner label', 'parent sharing team label', 'Agreement_Territory__c', 'TeamMemberRole');
        sObjectChildSharing.Enable_Sharing_Calculation__c = true;
        sObjectChildSharing.Account_Country_Api_Name__c = 'Country__c';

        sObjectSharingList.add(sObjectParentSharing);
        sObjectSharingList.add(sObjectChildSharing);
        insert sObjectSharingList;
        
        List<Group> groupList = [Select Id from Group Limit 1];
        List<Territory_Sharing__c> territoryList = new List<Territory_Sharing__c>();
        Territory_Sharing__c territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__APTS_Agreement__c');
        territoryList.add(territorySharing);
        territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__APTS_Agreement__c');
        territorySharing.Account_Country__c = 'AT';
        territoryList.add(territorySharing);
        insert territoryList;
        
        List<Account> accList = new List<Account>();
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        accList.add(acc);
        acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AT';
        accList.add(acc);
        insert accList;
        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement(); 
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
        
        Product2 testProduct = UTL_testData.createProduct();
        insert testProduct;
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Account_Country__c, Apttus__Account__c from Apttus__APTS_Agreement__c];
        Apttus__AgreementLineItem__c aggrementLineItem = UTL_TestData.createAgreementLineItem(agreementList[0].id,testProduct.id );
        aggrementLineItem.Country__c = 'Algeria';
        aggrementLineItem.Apttus__AgreementId__c = agreementList[0].id;
        insert aggrementLineItem;
    }
    
    @isTest
    public static void testSetSharingRuleForChild(){
        Test.startTest();
        UTL_Sharing.isFuture = true;
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Account_Country__c, Apttus__Account__c from Apttus__APTS_Agreement__c];
        Apttus__AgreementLineItem__c aggrementLineItem = [Select id, Country__c, Apttus__AgreementId__c from Apttus__AgreementLineItem__c][0];
        system.debug(aggrementLineItem);
        try {
            agreementList[0].Account_Country__c = 'CL';
            system.debug(agreementList);
            update agreementList;
            Map<String,Set<String>> objectNameToAccountCountryMap = new Map<String,Set<String>>();
            objectNameToAccountCountryMap.put('Apttus__AgreementLineItem__c', new Set<String>{'Algeria', 'Armenia', 'Aruba'});
            List<SObject_Sharing__c> socsList = [select Id, Child_Sobject__c, Maintenance_Job_Status__c, Parent_Sobject__c, Lookup_Name__c, Child_Sobject_Share__c, Parent_Sobject_Share__c, Enable_Sharing_Calculation__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Business_Unit_Api_Name__c, Parent_Customer_Code_Api_Name__c, Sharing_Type__c, Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Sharing_Owner_Label__c, Team_Sharing_Lookup_Field__c,Parent_Sharing_Team_Label__c, Parent_Sharing_Territory_Label__c from SObject_Sharing__c WHERE Type__c = 'Child'];
            system.debug(socsList[0]);
            UTL_Sharing.setSharingRuleForChild(new List<Apttus__AgreementLineItem__c>{aggrementLineItem}, null, 'Apttus__AgreementLineItem__c');
        } catch(Exception ex) {
            system.debug(ex.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void testSharingParent(){
        Test.startTest();
        UTL_Sharing.isFuture = false;
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Apttus__Account__c from Apttus__APTS_Agreement__c];
        List<Account> accList = [SELECT Id FROM Account WHERE AccountCountry__c = 'AT'];
        system.debug(agreementList[0].Apttus__Account__c);
        agreementList[0].Apttus__Account__c = accList[0].Id;
        system.debug(agreementList[0].Apttus__Account__c);
        update agreementList;
        try {
            accList = [SELECT Id FROM Account WHERE AccountCountry__c = 'AL'];
            agreementList[0].Apttus__Account__c = accList[0].Id;
            update agreementList;
            accList[0].AccountCountry__c = 'CL';
            update accList[0];
        } catch(Exception ex) {
            system.debug(ex.getMessage());
        }
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void testCheckUser() {
        Test.startTest();
        
        Product2 testProduct = UTL_testData.createProduct();
        insert testProduct;
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Account_Country__c, Apttus__Account__c from Apttus__APTS_Agreement__c];
        SObject_Sharing__c testSobjectSharing = [select id, type__c from SObject_Sharing__c where type__c != 'Parent' limit 1][0];
        system.debug(testSobjectSharing);
        UTL_Sharing.checkUser(UserInfo.getUserId());
        Test.stopTest();        
    }
    
    @isTest 
    public static void testChildSharing() {
        Test.startTest();
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Account_Country__c, Apttus__Account__c from Apttus__APTS_Agreement__c];
        List<Apttus__AgreementLineItem__c> agreementLineItemList = [Select id, Country__c, Apttus__AgreementId__c from Apttus__AgreementLineItem__c];
        UTL_Sharing.checkSharingValidation();
        UTL_Sharing.setChildSharingRecords(new Set<ID>{agreementList[0].id});
        Test.stopTest();
    }
    
    @isTest 
    public static void testTeamSharing() {
        Test.startTest();
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Account_Country__c, Apttus__Account__c from Apttus__APTS_Agreement__c];
        List<Apttus__AgreementLineItem__c> agreementLineItemList = [Select id, Country__c, Apttus__AgreementId__c from Apttus__AgreementLineItem__c];
        UTL_Sharing.checkSharingValidation();
        system.debug(agreementLineItemList);
        Team_Sharing__c teamSharingObj = UTL_TestData.createTeamSharingData('Apttus__APTS_Agreement__c', 'Apttus__AgreementLineItem__c', 'OpportunityTeamMember', 'Opportunity Owner');
        insert teamSharingObj;
        Map<Id,SObject> oldmap = new Map<Id,SObject>();
        oldmap.put(teamSharingObj.id,teamSharingObj);
        try{
            UTL_Sharing.setParentTeamSharing(new Set<Id>{agreementList[0].id}, 'Apttus__APTS_Agreement__c');
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        try{
            UTL_Sharing.setTeamSharing(new List<SObject> {teamSharingObj}, oldmap, 'Apttus__APTS_Agreement__c', 'Apttus__AgreementId__c');
            
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest 
    public static void testChildTeamSharing() {
        Test.startTest();
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Account_Country__c, Apttus__Account__c from Apttus__APTS_Agreement__c];
        List<Apttus__AgreementLineItem__c> agreementLineItemList = [Select id, Country__c, Apttus__AgreementId__c from Apttus__AgreementLineItem__c];
        UTL_Sharing.checkSharingValidation();
        system.debug(agreementLineItemList);
        List<SObject_Sharing__c> socsList = [Select id, Child_Sobject__c, Maintenance_Job_Status__c, Parent_Sobject__c, Lookup_Name__c, Child_Sobject_Share__c, Parent_Sobject_Share__c, Enable_Sharing_Calculation__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Business_Unit_Api_Name__c, Parent_Customer_Code_Api_Name__c, Sharing_Type__c, Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Sharing_Owner_Label__c, Team_Sharing_Lookup_Field__c,Parent_Sharing_Team_Label__c, Parent_Sharing_Territory_Label__c from SObject_Sharing__c where Type__c = 'Child'];
        system.debug(socsList);
        Team_Sharing__c teamSharingObj = UTL_TestData.createTeamSharingData('Apttus__APTS_Agreement__c', 'Apttus__AgreementLineItem__c', 'OpportunityTeamMember', 'Opportunity Owner');
        insert teamSharingObj;
        Map<Id,SObject> oldmap = new Map<Id,SObject>();
        oldmap.put(teamSharingObj.id,teamSharingObj);
        try{
            UTL_Sharing.setParentSharingOrder(JSON.serialize(agreementList), 'Apttus__APTS_Agreement__c', 'SHR_Parent_FieldSet', true);
        }catch(Exception ex){
            
        }
        try{
            UTL_Sharing.setChildTeamSharing(agreementLineItemList, 'Apttus__AgreementLineItem__c', socsList);
        }catch(Exception ex){
            
        }
        UTL_Sharing.createFailRecord(agreementList[0].id, agreementLineItemList[0].id);
        Sobject obj = [Select id, ParentId from Apttus__APTS_Agreement__Share limit 1][0];
        
        UTL_Sharing.shareObjectDeleteList.add(obj);
        UTL_Sharing.shareObjectInsertList.add(obj);
        try{
            throw new DMLException('exception occured');
        }catch(Exception ex){
            UTL_Sharing.failRecordCreation(ex, true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testSetSharingForChildRecords(){
        Test.startTest();
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Account_Country__c, Apttus__Account__c from Apttus__APTS_Agreement__c];
        List<Apttus__AgreementLineItem__c> agreementLineItemList = [Select id, Country__c, Apttus__AgreementId__c from Apttus__AgreementLineItem__c];
        List<SObject_Sharing__c> socsList = [Select id, Child_Sobject__c, Maintenance_Job_Status__c, Parent_Sobject__c, Lookup_Name__c, Child_Sobject_Share__c, Parent_Sobject_Share__c, Enable_Sharing_Calculation__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Business_Unit_Api_Name__c, Parent_Customer_Code_Api_Name__c, Sharing_Type__c, Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Sharing_Owner_Label__c, Team_Sharing_Lookup_Field__c,Parent_Sharing_Team_Label__c, Parent_Sharing_Territory_Label__c from SObject_Sharing__c where Type__c != 'Child'];
        delete socsList;
        UTL_Sharing.checkSharingValidation();
        try{
            UTL_Sharing.setSharingForChildRecords(new Set<id>{agreementList[0].id}, new Set<Id>{agreementLineItemList[0].id});
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
        Test.stopTest();
    }
    
}