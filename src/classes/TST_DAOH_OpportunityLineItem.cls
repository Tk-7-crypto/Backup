/**
 * This test class is used to test all methods in opportunity trigger helper.
 * version : 1.0
 */
@isTest 
private class TST_DAOH_OpportunityLineItem {

    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;       
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        User_Permissions__c us = new User_Permissions__c();
        us.Is_ZQUI_Product_Access__c = true;
        upsert us;
        upsert new RWEStudyProduct__c(Name='Q_100339', Product_Code__c='Q_100339');
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = false, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true,SetupOwnerId = UserInfo.getOrganizationId());
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.LI_Opportunity_Id__c = '0661234567890';
        opp.Proposal_Sent_Date__c = System.today() - 1 ;
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Material_Type__c = 'ZQUI';
        product.ZQUI_Product__c = true;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        PrivacyAnalyticsProductCode__c papc = new PrivacyAnalyticsProductCode__c();
        papc.Name = 'Test01';
        papc.Product_Code__c = 'Test01';
        insert papc;
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
		insert userList;
        OpportunityTeamMember otm = UTL_TestData.createOpportunityTeamMember(opp.Id, userList[0].Id);
        insert otm;
        Group gp = new Group();
        gp.Name = 'Platform Analytics Sales Group';
        insert gp;
        System.runAs(userList[0]) {
            GroupMember gm = UTL_TestData.createGroupMember(gp.Id, userList[0].Id);
            insert gm;
        }
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        System.runAs(userList[0]) {  
            insert oppLineItem;
        }
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olis;
    }
    
    /**
     * This test method used to create OutboundMessageDeletionQueue
     */ 
    static testMethod void testCreateOutboundMessageDeletionQueue() {   
        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem];
        Test.startTest();
            delete oliList;
            List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        Test.stopTest();
        System.assertEquals(1, outboundList.size());
    }
    
    /**
     * This test method used to test the method SetOLIS
     */ 
    static testMethod void testSetOLIS() {
        OpportunityLineItem oli = [SELECT Id, OpportunityLineItemSchedule_JSON__c, (SELECT Id, Revenue, scheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem LIMIT 1];
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();
        for(OpportunityLineItemSchedule olis : oli.OpportunityLineItemSchedules) {
            OpportunityLineItemSchedule olisJSON = new OpportunityLineItemSchedule();
            olisJSON.Revenue = olis.Revenue;
            olisJSON.ScheduleDate = olis.ScheduleDate;
            olisList.add(olisJSON);
        }
        oli.OpportunityLineItemSchedule_JSON__c = JSON.serialize(olisList);
        Test.startTest();
            upsert oli;
        Test.stopTest();
    }
    
    /**
     * This test method used to test the method SetOLIS
     */ 
    static testMethod void testSetOLISMulesoft() {
        Mulesoft_Integration_Control__c mulesoftIntegration = [Select Enable_OLIS_JSON__c,Is_Mulesoft_User__c,Enable_OLI_Sync_Validation__c,SetupOwnerId from Mulesoft_Integration_Control__c where SetupOwnerId =: UserInfo.getOrganizationId()];
        mulesoftIntegration.Is_Mulesoft_User__c = true;
        update mulesoftIntegration;
        OpportunityLineItem oli = [SELECT Id, OpportunityLineItemSchedule_JSON__c, (SELECT Id, Revenue, scheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem LIMIT 1];
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();
        for(OpportunityLineItemSchedule olis : oli.OpportunityLineItemSchedules) {
            OpportunityLineItemSchedule olisJSON = new OpportunityLineItemSchedule();
            olisJSON.Revenue = olis.Revenue;
            olisJSON.ScheduleDate = olis.ScheduleDate;
            olisList.add(olisJSON);
        }
        oli.OpportunityLineItemSchedule_JSON__c = JSON.serialize(olisList);
        Test.startTest();
            upsert oli;
        Test.stopTest();
    }
    
    /**
     * This test method used to test the method SetOLIS 
     */ 
    static testMethod void testSetOLISChangeCountry() {
        OpportunityLineItem oli = [SELECT Id, Delivery_Country__c FROM OpportunityLineItem LIMIT 1];
        oli.Delivery_Country__c = 'India';
        Test.startTest();
            upsert oli;
            oli = [SELECT Id, OpportunityLineItemSchedule_JSON__c FROM  OpportunityLineItem LIMIT 1];
        Test.stopTest();
        system.assertEquals(false, String.ISBLANK(oli.OpportunityLineItemSchedule_JSON__c));
    }
    
    /**
     * This test method used to test the method validateMulesoftFieldUpdates 
     */ 
    static testMethod void testValidateMulesoftFieldUpdates() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.LI_Opportunity_Id__c = opp.Id;
        update opp;
        Mulesoft_Opportunity_Sync__c mos = [SELECT Id, LI_Opportunity_Id__c, Opportunity__c FROM Mulesoft_Opportunity_Sync__c LIMIT 1];
        mos.LI_Opportunity_Id__c = mos.Opportunity__c;
        update mos; 
        PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oli.Description = 'Testing';
            insert oli;
            Mulesoft_OpportunityLineItem_Sync__c olisync = [SELECT Id , Mulesoft_Sync_Status__c FROM Mulesoft_OpportunityLineItem_Sync__c WHERE OpportunityLineItemId__c = :oli.id];
            try {
                CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
                oli.Delivery_Country__c = 'China';
                update oli;
            } catch(Exception e) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            }
            try {
                olisync.Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_FAILED;
                update olisync;
                CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
                oli.Delivery_Country__c = 'India';
                update oli;
            } catch(Exception e) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            }
            try {
                olisync.LI_OpportunityLineItem_Id__c = oli.id;
                update olisync;
                CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
                oli.Delivery_Country__c = 'India';
                update oli;
            } catch(Exception e) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            }
            Product2 product = [SELECT Id from Product2 LIMIT 1];
            product.Material_Type__c = CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI;
            update product;
            try {
                CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
                oli.Delivery_Country__c = 'India';
                update oli;
            } catch(Exception e) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            }
            try {
                olisync.LQ_OpportunityLineItem_Id__c = oli.id;
                update olisync;
                CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
                oli.Delivery_Country__c = 'India';
                update oli;
            } catch(Exception e) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            }
        Test.stopTest();
    }
    
    /**
     * This test method used to test the method validationOnOliForProxyProject 
     */ 
    static testMethod void testvalidationOnOliForProxyProject() {
        Opportunity opp = [Select id from Opportunity LIMIT 1];
        Test.startTest();
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.id);
        proxyProject.LI_OpportunityLineItem_Id__c = opp.id;
        insert proxyProject;
        OpportunityLineItem oli = [Select id from OpportunityLineItem LIMIT 1];
            try {
                delete oli;
            } catch(DMLException e) {
            }
        Test.stopTest();
        
    }
    
    /**
     * This test method used to test the method setProxyProjectFields. 
     */ 
    static testMethod void testsetProxyProjectFields() {
        Opportunity opp = [Select id from Opportunity LIMIT 1];
        Test.startTest();
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.id);
        proxyProject.LI_OpportunityLineItem_Id__c = opp.id;
        proxyProject.LI_Record_id__c = '000000000000000125';
        insert proxyProject;
        OpportunityLineItem oli = [Select id from OpportunityLineItem LIMIT 1];
            try {
                oli.PSA_Project__c = '000000000000000125';
                update oli;
                oli.PSA_Project__c = '';
                update oli;
            } catch(DMLException e) {
            }
        Test.stopTest();
        
    }
    
    /**
    * This test method used to test the method setMC_CESAndSegmantFlag. 
    */ 
    @IsTest
    private static void testSetMC_CESAndSegmantFlag() {
        Product2 product = [SELECT Id, Offering_Type__c, Offering_Segment__c FROM Product2 LIMIT 1];
        product.Offering_Type__c = 'Market Measurement';
        product.Offering_Segment__c = 'Real World Solutions Adjusted';
        update product;
        List<OpportunityLineItem> oliList = [SELECT Id, PricebookEntryId, MC_CES__c, Segment_Flag__c FROM OpportunityLineItem];
        Test.startTest();
        DAOH_OpportunityLineItem.setMC_CESAndSegmantFlag(oliList);
        Test.stopTest();
        
        //System.assertEquals('Innovation', oliList[0].MC_CES__c, 'MC CES not updated');
        //System.assertEquals('Real World Insights', oliList[0].Segment_Flag__c, 'Segment Flag not updated');   
    }
    
    /**
     *  This method is used to verify Privacy Analytics TeamMember.
     */ 
    @isTest
    private static void testVerifyPrivacyAnalyticsTeamMember() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<User> userList = UTL_TestData.createUser('Mulesoft System Administrator', 1);
        userList[0].EmployeeNumber = '298101';
        insert userList;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        Group gp = [SELECT Id FROM Group WHERE Name = 'Platform Analytics Sales Group' LIMIT 1];
        GroupMember gm = UTL_TestData.createGroupMember(gp.Id, userList[0].Id);
        insert gm;
        //Test.startTest();
        System.runAs(userList[0]) {
            insert oppLineItem;
        }
        Test.stopTest();
    }
    
    /**
    * This test method used to test the method upsertIqviaLiZquiMappingObject. 
    */
    @isTest
    public static void testUpsertIqviaLiZquiMappingObject(){
        Product2 testProduct = [Select id from Product2 limit 1];
        OpportunityLineItem oli = [SELECT Id, Delivery_Country__c FROM OpportunityLineItem where Product2Id = : testProduct.id];
        for(Schema.FieldSetMember sf : Schema.SObjectType.OpportunityLineItem.fieldSets.Mulesoft_Synced_Fields.getFields()) {
            String fieldAPI = sf.getFieldPath();
            if(sf.getType() == Schema.DisplayType.STRING && sf.getSObjectField().getDescribe().isUpdateable()){
                oli.put(fieldAPI,'test');
                break;
            }  
        }
        Test.startTest();
        update oli;
        IQVIA_LI_ZQUI_MAPPING__c actual = [select id,QI_OpportunityLineItem_Id__c,Action_type__c,Mulesoft_Sync_Status__c,Pricebookentry_external_id__c,LI_Opportunity_Id__c  from IQVIA_LI_ZQUI_MAPPING__c where QI_OpportunityLineItem_Id__c =: oli.id ];
        System.assertEquals(true, actual.Mulesoft_Sync_Status__c == 'Pending');
        System.assertEquals(true, actual.Action_type__c == 'Upsert');
        Test.stopTest();
    }
    
     /**
    * This test method used to test the method deleteIqviaLiZquiMappingObject. 
    */
    @isTest
    public static void testDeleteIqviaLiZquiMappingObject(){
        Product2 testProduct = [Select id from Product2 limit 1];
        OpportunityLineItem oli = [SELECT Id, Delivery_Country__c FROM OpportunityLineItem where Product2Id = : testProduct.id];
        Test.startTest();
        delete oli;
        IQVIA_LI_ZQUI_MAPPING__c actual = [select id,QI_OpportunityLineItem_Id__c,Action_type__c,Mulesoft_Sync_Status__c,Pricebookentry_external_id__c,LI_Opportunity_Id__c  from IQVIA_LI_ZQUI_MAPPING__c where QI_OpportunityLineItem_Id__c =: oli.id ];
        System.assertEquals(true, actual.Mulesoft_Sync_Status__c == 'Pending');
        System.assertEquals(true, actual.Action_type__c == 'Delete');
        Test.stopTest();
    }
    
    /**
    * This test method used to test the method addZeroValueProduct adds an error. 
    */
    @istest
    public static void testInsertZeroValueProductByNonCommercialOpsUser(){
        Mulesoft_Integration_Control__c testCustomSetting = [select id,Enable_Opportunity_Sync_Validation__c from Mulesoft_Integration_Control__c];
        testCustomSetting.Enable_Opportunity_Sync_Validation__c = false;
        update testCustomSetting;
        Product2 product = [Select id from Product2 where ProductCode = 'Test01'];
        product.ZQUI_Product__c = true;
        product.Material_Type__c = CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI;
        update product;
        Test.startTest();
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        PricebookEntry pbEntry = [Select id from PricebookEntry where product2id = : product.id];
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.UnitPrice = 0;
        try{
            insert oppLineItem;
            Opportunity opp2 = [Select id from Opportunity limit 1][0];
            opp2.StageName = CON_CRM.IN_HAND_STAGE;
            update opp2;
            OpportunityLineItem oppLineItem2 = UTL_TestData.createOpportunityLineItem(opp2.Id, pbEntry.Id);
            oppLineItem2.TotalPrice = 0;
            insert oppLineItem2;
        }catch(Exception ex){
            
        }
       
        Test.stopTest();
    }
    
     /**
    * This test method used to test the method addZeroValueProduct allows the commercialOpsUser to add a zero value product. 
    */
    @istest
    public static void testInsertZeroValueProductByCommercialOpsUser(){
        Test.startTest();
        Mulesoft_Integration_Control__c testCustomSetting = [select id,Enable_Opportunity_Sync_Validation__c from Mulesoft_Integration_Control__c];
        testCustomSetting.Enable_Opportunity_Sync_Validation__c = false;
        update testCustomSetting;
        User commercialOpsUser = UTL_TestData.createUser(CON_CRM.COMMERCIAL_OPERATION_PROFILE,1)[0];
        commercialOpsUser.EmployeeNumber = '568221';
        insert commercialOpsUser;
        //Test.startTest();
        Account acc = [Select id from Account limit 1][0];
        Contact testContact = [Select id from Contact where accountId = :acc.id][0];
        Opportunity opp = [Select id from Opportunity where accountId = :acc.id][0];
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(testContact.id, opp.id);
        insert oppContactRole;
        opp.OwnerId = commercialOpsUser.id;
        opp.StageName = CON_CRM.CLOSED_WON_STAGE;
        opp.Win_Type__c = 'Non-competitive bid';
        opp.Primary_Win_Reason__c = 'Commercial Terms';
        update opp;
        System.runAs(commercialOpsUser){
            Product2 product = [Select id from Product2 where ProductCode = 'Test01'];
            product.ZQUI_Product__c = true;
            product.Material_Type__c = CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI;
            update product;
            PricebookEntry pbEntry = [select id from PricebookEntry where Product2Id =: product.id];
            OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
            oppLineItem.TotalPrice = 0;
            insert oppLineItem;
        }
        Test.stopTest();
    }
    
    static final String GROUP_NAME = 'My_Test_Group_12345';
    @isTest
    public static void testWinLossAlertEmail(){
        Test.startTest();

        Mulesoft_Integration_Control__c testCustomSetting = [select id,Enable_Opportunity_Sync_Validation__c from Mulesoft_Integration_Control__c];
        testCustomSetting.Enable_Opportunity_Sync_Validation__c = false;
        update testCustomSetting;
        
        List<User> userList = UTL_OWF_TestData.createUser('Sales User', 2);
        userList[0].IsActive = true;
        insert userList;
        
        CollaborationGroup testGroup = new CollaborationGroup(Name=GROUP_NAME, CollaborationType='Private');
        insert testGroup;
        CON_CRM.cgName = GROUP_NAME;
        CollaborationGroupMember cgm = new CollaborationGroupMember(MemberId = userList[0].Id, CollaborationGroupId=testGroup.Id);
        insert cgm;
        CollaborationGroup testGroup2 = new CollaborationGroup(Name=GROUP_NAME+'1', CollaborationType='Private');
        insert testGroup2;
        CON_CRM.cgName2 = GROUP_NAME+'1';
        CollaborationGroupMember cgm2 = new CollaborationGroupMember(MemberId = userList[1].Id, CollaborationGroupId=testGroup2.Id);
		insert cgm2;
        
        Account acc = [Select id from Account limit 1][0];        
        Contact testContact = [Select id from Contact where accountId = :acc.id][0];

        Opportunity opp = [Select id from Opportunity where accountId = :acc.id][0];
        
        OpportunityContactRole oppContactRole = UTL_TestData.createOpportunityContactRole(testContact.id, opp.id);
        insert oppContactRole;
        
        opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
        opp.Primary_Win_Reason__c =null;
        opp.Win_Type__c = null;
        opp.Primary_Loss_Reason__c ='Account marked as do not sell';
        update opp;
        
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.List_Price__c = 100000;
        insert oppLineItem;
        oppLineItem.Delivery_Country__c = 'Germany';
        update oppLineItem;
        
        Test.stopTest();        
    }
}