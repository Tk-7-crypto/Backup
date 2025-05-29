/*
* Version       : 1.0
* Description   : This test class is used for Select AgreementEmailAlert
*/
@isTest
private  class TST_SLT_AgreementEmailAlert {
    
    @testSetup
    static void dataSetup() {
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'CA&S',
            Sub_Group__c = 'CP&A-CA&S',
            Name = 'CA&S'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'ASL',
            Sub_Group__c = 'Analytics Strategy Lead',
            Name = 'ASL'
        ));
        insert resourceToSubGroupSettingList;
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        insert bidHistory;
        System.debug('bidHistory ' + bidHistory.Id);
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        resourceRequest.pse__End_Date__c = system.today();
        insert resourceRequest;
        
        Indication_List__c indicationList = new Indication_List__c(Name= 'Test Indication', Therapy_Area__c = 'Oncology');
        insert indicationList;

        Agreement_Email_Alert__c agEmailRec = new Agreement_Email_Alert__c(
            Alerting_Email__c ='Test123@mail1.com', Account__c = acc.Id,
            Indication__c = indicationList.id,
            Region__c = 'Global',
            Intervention_Type__c = 'Vaccine',
            Drug_Classification_Product_Name__c = 'Test',
            Phase__c = 'Phase 2',
            Line_of_Business__c = 'Novella',
            Country__c ='US',
            Incl_on_re_bids__c ='Yes',
            Is_this_IQVIA_Biotech__c = 'Yes',
            Is_this_a_virtual_trials_study__c = 'Yes Fully Virtual',
            Is_there_a_Client_Bid_Grid__c = 'Yes',
            FSP__c = 'Yes', Service__c = 'Biostatistical',
            Age_Group__c = 'Infants - 1 Month to 2 Years'
        );
        Insert agEmailRec;
    }
    @isTest
    static void testgetEmailReceipieantsByMatchingLogic() {
        Test.startTest();
        List<Agreement_Email_Alert__c> agEmailRecList = new SLT_AgreementEmailAlert().getEmailReceipieantsByMatchingLogic();
        System.debug('====>'+agEmailRecList.size());
        Test.stopTest();
        System.assertEquals(agEmailRecList[0].Country__c, 'US');
    }
    @isTest 
    static void testgetSObjectFieldList(){
        Test.startTest();
        new SLT_AgreementEmailAlert().getSObjectFieldList();
        Test.stopTest();
    }
    @isTest 
    static void testgetSObjectType(){
        Test.startTest();
        new SLT_AgreementEmailAlert().getSObjectType();
        Test.stopTest();
    }
    
    @isTest
    static void testGetEmailReceipieantsByMatchingFilter(){
        Bid_History__c agRecord = [select id, Therapy_Area__c, Indication__c,Intervention_Type__c,
                                                    Drug_Name__c, RFP_Ranking__c, Phase__c, Line_of_Business__c, Full_Service__c, IQVIA_biotech__c, 
                                                     Is_there_a_Client_Bid_Grid__c, Bid_History_Related_Opportunity__r.Potential_Regions__c, Targeted_Countries__c,
                                                    Requested_Services__c from Bid_History__c limit 1];
        Opportunity oppRecord = [Select Id
                                 from Opportunity Limit 1];
        
        
        Test.startTest();
        new SLT_AgreementEmailAlert().getEmailReceipieantsByMatchingFilter(agRecord, oppRecord, 'Asia Pacific', 'US', '', 'Neonates - Newborn to 1 Month');
        Test.stopTest();
    }
} 