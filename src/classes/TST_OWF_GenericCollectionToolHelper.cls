@isTest
public class TST_OWF_GenericCollectionToolHelper {
    @testSetup
    private static void setupData() {
        Test.startTest();
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;

        OWF_GenericCollectionToolHelper.CollectionToolConfig config = new OWF_GenericCollectionToolHelper.CollectionToolConfig();
        config.headerText = 'test';
        config.tableHeading = 'test';
        config.enableNewRow = true;
        config.newRowButtonLabel = 'test';
        config.showTableNumber = 'test';
        config.enableDeleteRow = true;
        config.enableClearRow = true;
        config.enableCloneTable = true;
        config.allowAllRowDeletion = true;
        config.showSumOfRows =true;
        config.displayDeleteFirstRow = true;
        config.cloneTableButtonLabel = 'test';
        config.redirectToBid = true;
        config.unsavedDataInformationMessage = 'test';
        config.keyMessage = 'test';
        config.requiredValidationFirstRowOnly = true;
        config.requiredErrorMessage = 'test';
        config.showRowNumber = true;
        config.displayUnsaveDataMessage = true;
        
        OWF_GenericCollectionToolHelper.Column column = new OWF_GenericCollectionToolHelper.Column();
        column.label = 'test';
        column.helpText = 'test';
        column.multiSelect = 'test';
        column.required = true;
        column.minValue = 1;
        column.maxValue = 1;
        column.stepValue = 1.00;
        column.length = 4;
        column.hide = true;

        OWF_GenericCollectionToolHelper.RecordPicker recordPicker = new OWF_GenericCollectionToolHelper.RecordPicker();
        recordPicker.objectApiName = 'test';

        OWF_GenericCollectionToolHelper.Criteria criteria = new OWF_GenericCollectionToolHelper.Criteria();
        criteria.fieldPath = 'test';
        criteria.operator = 'test';
        criteria.value = new List<String>{'test'};

        recordPicker.criteria = new List<OWF_GenericCollectionToolHelper.Criteria>{criteria};
        column.recordPicker = recordPicker;
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'BioSciences';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Study_Number__c='02';
        insert bidHistory;
        Product2 product = UTL_TestData.createProduct();
        product.SAP_Code__c='Q_111814';
        product.ProductCode='Q_111814';
        insert product; 
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Bid_History__c gccBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_GCC_SHORT_FORM_BID_HISTORY_RECORD_TYPE_ID);
        gccBidHistory.Bid_History_Status__c = CON_OWF.OWF_BID_HISTORY_STATUS_AWAITING_CUSTOMER_FEEDBACK;
        gccBidHistory.Opportunity_Type__c = CON_OWF.OWF_BID_HISTORY_OPPORTUNITY_TYPE_INTERNAL;
        gccBidHistory.RFP_Deliverables__c = CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_HIGH_LEVEL_COST;
        gccBidHistory.One_Off_Fees_For_Service_Implementation__c = 50;
        gccBidHistory.Number_of_Scenarios__c = 1;
        insert gccBidHistory;
        
        Bid_History__c bidHistory2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory2.Bid_Number__c = 0;
        bidHistory2.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory2.PCS__c = True;
        bidHistory2.Payments_Forecasting__c = true;
        bidHistory2.eCOA__c = true;
        bidHistory2.Complete_Consent__c	 = true;
        bidHistory2.Grant_Plan__c = true;
        bidHistory2.eTMF__c = true;
        bidHistory2.Site_Portal__c = true;
        bidHistory2.Clinical_Trial_Payments__c = true;
        bidHistory2.IRT__c = true;
        bidHistory2.One_Home_for_Sites__c = true;
        bidHistory2.Participant_Payments__c = true;
        bidHistory2.Bid_Category__c = 'Combined';
        bidHistory2.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory2.Rate_card_MSA_explanation__c = 'Test Class';
        bidHistory2.Estimated_Fees__c = CON_OWF.ESTIMATED_FEE_LESS_THAN_5M;
        bidHistory2.LPI_Date__c = System.today();
        bidHistory2.DBL_Date__c = System.today();
        bidHistory2.Number_of_Scenarios__c = 2;
        bidHistory2.Requested_Services__c = 'CD - ECG';
        bidHistory2.Cardiac_Safety_Equipment_Vendor__c = 'TT';
        bidHistory2.Connected_Devices_Logistics_Vendor__c = 'Test';
        bidHistory2.OWF_Potential_Regions__c = 'Latin America';
        bidHistory2.Study_Start_Date__c =  system.today();
        bidHistory2.Study_End_Date__c = system.today().addMonths(1);
        insert bidHistory2;

        Bid_History__c bidHistory3 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory3.Bid_Number__c = 0;
        bidHistory3.Bid_Type__c = CON_CPQ.REBID;
        bidHistory3.PCS__c = True;
        bidHistory3.Payments_Forecasting__c = true;
        bidHistory3.eCOA__c = true;
        bidHistory3.Complete_Consent__c	 = true;
        bidHistory3.Grant_Plan__c = true;
        bidHistory3.eTMF__c = true;
        bidHistory3.Site_Portal__c = true;
        bidHistory3.Clinical_Trial_Payments__c = true;
        bidHistory3.IRT__c = true;
        bidHistory3.One_Home_for_Sites__c = true;
        bidHistory3.Participant_Payments__c = true;
        bidHistory3.Bid_Category__c = 'Combined';
        bidHistory3.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory3.Rate_card_MSA_explanation__c = 'Test Class';
        bidHistory3.Estimated_Fees__c = CON_OWF.ESTIMATED_FEE_LESS_THAN_5M;
        bidHistory3.LPI_Date__c = System.today();
        bidHistory3.DBL_Date__c = System.today();
        bidHistory3.Number_of_Scenarios__c = 2;
        bidHistory3.Requested_Services__c = 'CD - ECG';
        bidHistory3.Cardiac_Safety_Equipment_Vendor__c = 'TT';
        bidHistory3.Connected_Devices_Logistics_Vendor__c = 'Test';
        bidHistory3.OWF_Potential_Regions__c = 'Latin America';
        bidHistory3.Study_Start_Date__c =  system.today();
        bidHistory3.Study_End_Date__c = system.today().addMonths(1);
        insert bidHistory3;
        
        List<CollectionTool__c> listCollectionToolData = new List<CollectionTool__c>();
        CollectionTool__c collectionTool = new CollectionTool__c();
        collectionTool.Countries__c = 'United States of America';
        collectionTool.Bid_History__c = gccBidHistory.Id;
        collectionTool.Number_of_Sites__c = 2.00;
        collectionTool.Description_if_not_within_library__c = 'NA';
        collectionTool.COA_Library_Assessment__c = '01_Not within Library'; 
        collectionTool.Select_Device_Type__c = 'Tablet';
        collectionTool.Specific_Device_Strategy__c = 'TEST';   
        collectionTool.Scenario_Number__c = 1.00;
        collectionTool.Number_of_Enrolled_Patients__c = 10.00;
        collectionTool.Service_Hours_Start__c = '05:00';
        collectionTool.Service_Hours_Start__c = '05:00';
        collectionTool.recordTypeId = Schema.SObjectType.CollectionTool__c.getRecordTypeInfosByDeveloperName().get('GCC').getRecordTypeId();
    	collectionTool.Type__c = 'Countries in Scope';
        listCollectionToolData.add(collectionTool);
        CollectionTool__c collectionTool3 = UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
        collectionTool3.Countries__c = 'United States of America';
        collectionTool3.Site_Global__c='Ithaca';
        collectionTool3.RecordTypeId = CON_OWF.OWF_COLLECTIONTOOL_Q2_Solutions_RECORD_TYPE_ID;
        collectionTool3.ServiceLine__c=product.id;
        collectionTool3.Type__c = 'BioSciences';
        collectionTool3.Bid_History__c = bidHistory.Id;
        collectionTool3.Number_of_Sites__c = 2.00;
        collectionTool3.Description_if_not_within_library__c = 'NA';
        collectionTool3.COA_Library_Assessment__c = '01_Not within Library'; 
        collectionTool3.Select_Device_Type__c = 'Tablet';
        collectionTool3.Specific_Device_Strategy__c = 'TEST';   
        collectionTool3.Scenario_Number__c = 1.00;
        collectionTool3.Number_of_Enrolled_Patients__c = 10.00;
        listCollectionToolData.add(collectionTool3);
        
        CollectionTool__c collectionTool1 = new CollectionTool__c();
        collectionTool1.Countries__c = 'United States of America';
        collectionTool1.Bid_History__c = bidHistory2.Id;
        collectionTool1.Number_of_Sites__c = 2.00;
        collectionTool1.Description_if_not_within_library__c = 'NA';
        collectionTool1.COA_Library_Assessment__c = '01_Not within Library'; 
        collectionTool1.Select_Device_Type__c = 'Tablet';
        collectionTool1.Specific_Device_Strategy__c = 'TEST';   
        collectionTool1.Scenario_Number__c = 1.00;
        collectionTool1.Type__c = 'Other';
        collectionTool1.Number_of_Enrolled_Patients__c = 10.00;
        collectionTool1.Screened_Patients__c = 20;
        collectionTool1.recordTypeId = Schema.SObjectType.CollectionTool__c.getRecordTypeInfosByDeveloperName().get('IQVIA_Technologies').getRecordTypeId();
        listCollectionToolData.add(collectionTool1);
        CollectionTool__c collectionTool2 = new CollectionTool__c();
        collectionTool2.Countries__c = 'United States of America';
        collectionTool2.Bid_History__c = bidHistory3.Id;
        collectionTool2.Number_of_Sites__c = 2.00;
        collectionTool2.Description_if_not_within_library__c = 'NA';
        collectionTool2.COA_Library_Assessment__c = '01_Not within Library'; 
        collectionTool2.Select_Device_Type__c = 'Tablet';
        collectionTool2.Specific_Device_Strategy__c = 'TEST';   
        collectionTool2.Scenario_Number__c = 1.00;
        collectionTool2.Type__c = 'Other';
        collectionTool2.Number_of_Enrolled_Patients__c = 10.00;
        collectionTool2.Screened_Patients__c = 20;
        collectionTool2.recordTypeId = Schema.SObjectType.CollectionTool__c.getRecordTypeInfosByDeveloperName().get('IQVIA_Technologies').getRecordTypeId();
        
        listCollectionToolData.add(collectionTool2);
        insert listCollectionToolData;
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testGetCollectionDataQ2SolutionBioScieces() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c where RecordType.name = : CON_OWF.RECORD_TYPE_Q2_SOLUTION LIMIT 1];
        Test.startTest();
			OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistory.Id, CNT_OWF_GenericCollectionTool.MDT_CONFIG_NAME_Q2SOLUTIONS_BIOSCIENCE);
        	OWF_GenericCollectionToolHelper.CollectionToolData collectionData = helper.getCollectionData();
        Test.stopTest();
        System.assertEquals(true, collectionData.tables.size() == 2);
    }
    
    @isTest
    private static void testSaveCollectionDataQ2SolutionBioScieces() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c where RecordType.name =: CON_OWF.RECORD_TYPE_Q2_SOLUTION LIMIT 1];
        OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistory.Id, CNT_OWF_GenericCollectionTool.MDT_CONFIG_NAME_Q2SOLUTIONS_BIOSCIENCE);
        OWF_GenericCollectionToolHelper.CollectionToolData collectionData =  helper.getCollectionData();
        Test.startTest();
        	helper.saveCollectionData(JSON.serialize(collectionData.tables));
        Test.stopTest();
        List<CollectionTool__c> collectionTool  = [Select Id from  CollectionTool__c where Bid_History__c =: bidHistory.Id];
        System.assertEquals(1, collectionTool.size());        
    }
    
    @isTest
    private static void testSaveCollectionDataGCC() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c  where RecordType.name =: CON_OWF.RECORD_TYPE_GCC LIMIT 1];
        CollectionTool__c collectionToll = [SELECT Id FROM CollectionTool__c LIMIT 1];
        OWF_GenericCollectionToolHelper helperForGCC = new OWF_GenericCollectionToolHelper(bidHistory.Id, CNT_OWF_GenericCollectionTool.MDT_CONFIG_NAME_GCC_COUNTRIES_IN_SCOPE);
        OWF_GenericCollectionToolHelper.CollectionToolData collectionDataForGCC =  helperForGCC.getCollectionData();
        collectionDataForGCC.tables[0].rows[0].cells.get('Service_Hours_Start__c').value = '06:00';
        collectionDataForGCC.tables[0].rows[0].action='UPDATE';
        Test.startTest();
        	helperForGCC.saveCollectionData(JSON.serialize(collectionDataForGCC.tables));
        Test.stopTest();       
        List<CollectionTool__c> collectionTool  = [Select Id from  CollectionTool__c where Bid_History__c =: bidHistory.Id];
        System.assertEquals(true, collectionTool.size() != 0,'GCC Collection Tool Data Saved Succesfully');  
    }
    @isTest
    private static void testSaveCollectionDataGCCForDeleteAction() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c  where RecordType.name =: CON_OWF.RECORD_TYPE_GCC LIMIT 1];
        CollectionTool__c collectionToll = [SELECT Id FROM CollectionTool__c LIMIT 1];
        OWF_GenericCollectionToolHelper helperForGCC = new OWF_GenericCollectionToolHelper(bidHistory.Id, CNT_OWF_GenericCollectionTool.MDT_CONFIG_NAME_GCC_COUNTRIES_IN_SCOPE);
        OWF_GenericCollectionToolHelper.CollectionToolData collectionDataForGCC =  helperForGCC.getCollectionData();
        collectionDataForGCC.tables[0].rows[0].cells.get('Service_Hours_Start__c').value = '06:00';
        collectionDataForGCC.tables[0].rows[0].action='DELETE';
        Test.startTest();
        	helperForGCC.saveCollectionData(JSON.serialize(collectionDataForGCC.tables));
        Test.stopTest();       
        List<CollectionTool__c> collectionTool  = [Select Id from  CollectionTool__c where Bid_History__c =: bidHistory.Id];
        System.assertEquals(false, collectionTool.size() != 0,'GCC Collection Tool Data Saved Succesfully');  
    }
    @isTest
    private static void testSaveCollectionDataCSS() {
        Bid_History__c bidHistory = [Select Id from  Bid_History__c where RecordTypeId =: CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        CollectionTool__c collectionToll = [SELECT Id FROM CollectionTool__c LIMIT 1];
        Test.startTest();
        for(String configName : CNT_OWF_GenericCollectionTool.getConfig(bidHistory.Id)){
            OWF_GenericCollectionToolHelper helperForGCC = new OWF_GenericCollectionToolHelper(bidHistory.Id, configName);
        	OWF_GenericCollectionToolHelper.CollectionToolData collectionDataForCSS =  helperForGCC.getCollectionData();
        }
        Test.stopTest();       
        List<CollectionTool__c> collectionTool  = [Select Id from  CollectionTool__c where Bid_History__c =: bidHistory.Id];
        System.assertEquals(true, collectionTool.size() != 0,'CSS Collection Tool Data Saved Succesfully');  
    }
}