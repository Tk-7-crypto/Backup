/**************************************************************************************************
* @Author:      Sai vamshi takkadapelly
* @Date:        29/11/2022
* @PageCode:    
* @CurErrCode: 
* @Description: IQVIACBEX-2837: This is a Test class for callout to Digi Contractor API and fetch cost estimates based on Bid and Opportunity data
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***************************************************************************************************/
@isTest
public class TST_CNT_CBEX_DigitalContractor {
    @testSetup
    static void setup(){
        CBEX_Price_Modular_Cred__c pmc = UTL_TestData.createCBEXPriceModularCred();
        upsert pmc;
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
        Opportunity oppnew2 = UTL_OWF_TestData.createOpportunity(acc.Id);
        oppnew2.Potential_Regions__c = 'Asia Pacific;Japan';
        oppnew2.Phase_P__c = 'Phase 3';
        insert oppnew2;
        Bid_History__c bidHistorytwo = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppnew2.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistorytwo.Bid_Number__c = 0;
        insert bidHistorytwo;
    }
    
    /**************************************************************************************************
    * @Author:      Sai vamshi takkadapelly
    * @Date:        29/11/2022
    * @PageCode:    
    * @CurErrCode: 
    * @Description: IQVIACBEX-2837: This is a method for callout to Digi Contractor when Opportunity is Phase 3
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***************************************************************************************************/
    @isTest
    static void testGetCostEstimationForPhaseTwo(){
        //Fetch Bid record from Setup data to pass to Main class method
        List<Bid_History__c> bidHistoryList = [Select Id from Bid_History__c where Bid_History_Related_Opportunity__r.Phase_P__c = 'Phase 3' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CNT_CBEX_DigitalContractor_Mock());
        Test.startTest();
             CNT_CBEX_DigitalContractor.getCostEstimation(new List<String>{bidHistoryList[0].Id});
        Test.stopTest();
        Bid_History__c bidObj = [SELECT id, Bid_History_Related_Opportunity__r.Digital_Contractor_Estimate__c from Bid_History__c where Id =: bidHistoryList[0].Id LIMIT 1];
       	System.assertEquals(false, String.isEmpty(String.valueOf(bidObj.Bid_History_Related_Opportunity__r.Digital_Contractor_Estimate__c)),'is not Empty');
    }
    
    /**************************************************************************************************
    * @Author:      Sai vamshi takkadapelly
    * @Date:        29/11/2022
    * @PageCode:    
    * @CurErrCode: 
    * @Description: IQVIACBEX-2837: Negative Test Scnario
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***************************************************************************************************/
     @isTest
     static void negativeGetCostEstimation(){
        Boolean isException = false;
        //Fetch Bid record from Setup data to pass to Main class method
        List<Bid_History__c> bidHistoryList = [Select Id from Bid_History__c LIMIT 1];
         try{
              Test.startTest();
                 CNT_CBEX_DigitalContractor.getCostEstimation(new List<String>{bidHistoryList[0].Id});
              Test.stopTest();
         }catch(Exception ex){
             isException = true;
         }
         System.assertEquals(false, isException, 'no Exception');
    }
}