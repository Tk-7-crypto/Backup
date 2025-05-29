@IsTest
private class TST_CNT_CSM_CAPACloseAction {
    @testSetup
    static void setup() {
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.CustomerSegment__c = 'GOVERNMENT';
        accCase.Sub_Industry__c = 'STATE';
        insert accCase;
        
        Contact conCase = new Contact();
        conCase.AccountId = accCase.Id;
        conCase.FirstName = 'test';
        conCase.LastName = 'con';
        conCase.Salutation = 'Eng';
        conCase.Email = 'noreply@dummy.com';
        insert conCase;
        
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='Q1';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='Q1';
        queueUser1.QueueName__c ='Q1';
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Case csData = new Case();
        csData.AccountId = accCase.Id;
        csData.AssignCaseToCurrentUser__c = false;
        csData.RecordTypeId = RecordTypeIdData;
        csData.OwnerId = UserInfo.getUserId();
        csData.LOS__c = 'DATA';
        csData.SubType1__c = 'DATA MGT/PRODUCTION';
        csData.SubType2__c = 'DATA ISSUES';
        csData.SubType3__c = 'Account';
        csData.Priority = 'High';
        csData.Origin = 'Agent Initiated';
        csData.Subject = 'Data Test case';
        csData.Description = 'No information available';
        csData.Status = 'In Progress';
        csData.CurrentQueue__c = queueUser1.Id;
        csData.InitialQueueData__c = queueUser1.Id;
        csData.First_response_email_time__c = null;
        csData.First_response_sent__c = FALSE;
        insert csData;
        
        CSM_QI_CAPA__c csmCAPA = new CSM_QI_CAPA__c();
        csmCAPA.Sub_Type_3__c = 'Account';
        csmCAPA.Query_Type_Area__c = 'Activation Link';
        csmCAPA.Resolution_Code__c = 'CLIENT - ACCESS PROVIDED';
        csmCAPA.Corrective_Action__c  = 'User account activated';
        insert csmCAPA;

        List <CSMLiquidPlannerIntegration__c> csContactFieldList = new List<CSMLiquidPlannerIntegration__c>();
        CSMLiquidPlannerIntegration__c csContactFields = new CSMLiquidPlannerIntegration__c();
        csContactFields.Name = 'MIProductName';
        csContactFields.Product__c = 'DDD';
        csContactFields.Queue__c = 'testLastName';
        csContactFields.EmailAddress__c = 'test@testmail.com';
        csContactFieldList.add(csContactFields);
        CSMLiquidPlannerIntegration__c csContactFieldProduct = new CSMLiquidPlannerIntegration__c();
        csContactFieldProduct.Name='DashboardProductName'; 
        csContactFieldProduct.Product__c = 'Dashboards (SFE/CBG)';
        csContactFieldProduct.Queue__c = 'Data AU BI Support';
        csContactFieldProduct.EmailAddress__c = 'test@testmail.com';
        csContactFieldList.add(csContactFieldProduct);   
        insert csContactFieldList;
    }
    
    @IsTest
    private static void testGetRecord() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Data Test case'];
        
        Test.startTest();
            String result = CNT_CSM_CAPACloseAction.getRecord(caseRecord.Id);
        Test.stopTest();
        
        CNT_CSM_CAPACloseAction.CaseWrapper wrapper = (CNT_CSM_CAPACloseAction.CaseWrapper)System.JSON.deserialize(result, CNT_CSM_CAPACloseAction.CaseWrapper.class);
        System.assertEquals(true, wrapper.caseRecord != null, 'Got Case record');
    }
    
    @IsTest
    private static void testGetCAPAValuesWithAggregate() {
        String query = 'SELECT Query_Type_Area__c FROM CSM_QI_CAPA__c WHERE Sub_Type_3__c = \'Account\' Group By Query_Type_Area__c';
        
        Test.startTest();
            List<AggregateResult> result = CNT_CSM_CAPACloseAction.getCAPAValuesWithAggregate(query);
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Got CAPA values');
    }
    
    @IsTest
    private static void testCheckFieldRequirement() {
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_PROFILENAME, 1);
        insert listOfUser;
        User userToRunAs = listOfUser[0];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: CON_CSM.S_CSM_DATA_CAPA_CLOSE_CASE_ACCESS];
        insert new PermissionSetAssignment(AssigneeId = userToRunAs.id, PermissionSetId = ps.Id);
        
        System.runAs(userToRunAs) {
            Test.startTest();
                Boolean allFieldsRequired = CNT_CSM_CAPACloseAction.checkFieldRequirement();
            Test.stopTest();
            System.assertEquals(true, allFieldsRequired, 'All fields are required for the user');
        }
    }
    
    @IsTest
    private static void testSaveRecord() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Data Test case'];
        CNT_CSM_CAPACloseAction.CaseWrapper caseWrapperInstance = new CNT_CSM_CAPACloseAction.CaseWrapper();
        caseWrapperInstance.caseRecord = caseRecord;
        caseWrapperInstance.queryTypeArea = 'Activation Link';
        
        Test.startTest();
            CNT_CSM_CAPACloseAction.saveRecord(JSON.serialize(caseWrapperInstance));
        Test.stopTest();

        Case updatedCase = [SELECT Id, Query_Type_Area__c FROM Case WHERE Id =: caseRecord.Id];        
        System.assertEquals('Activation Link', updatedCase.Query_Type_Area__c , 'Case record Updated');
    }
    
    @IsTest
    private static void testGetPickListValues() {
        
        Test.startTest();
            String result = CNT_CSM_CAPACloseAction.getPickListValues();
        Test.stopTest();
        
        CNT_CSM_CAPACloseAction.PicklistWrapper picklistWrapperInstance = (CNT_CSM_CAPACloseAction.PicklistWrapper)System.JSON.deserialize(result, CNT_CSM_CAPACloseAction.PicklistWrapper.class);
        System.assertEquals(true, picklistWrapperInstance.statusValues != null, 'Got Status picklist values');
        System.assertEquals(true, picklistWrapperInstance.subStatusValues != null, 'Got substatus picklist values');
    }
    
    @IsTest
    private static void testGetPickListValuesByFieldName() {
        
        Test.startTest();
            List<CNT_CSM_CAPACloseAction.SelectOption> selectOptionList = CNT_CSM_CAPACloseAction.getPickListValuesByFieldName('Case', 'SubStatus__c');
        Test.stopTest();
        
        System.assertEquals(true, selectOptionList.size() > 0, 'Got substatus picklist values');
    }
    
    @IsTest
    private static void testGetDependentPicklistMap() {
        
        Test.startTest();
            String result = CNT_CSM_CAPACloseAction.getDependentPicklistMap('Case', 'Status', 'SubStatus__c');
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Got dependant substatus picklist map');
    }
}