/**
 * @File Name          : TST_CNT_CLP_CallOut.cls
 * @Description        : 
 * @Author             : Anup Kage
 * @Group              : 
 * @Last Modified By   : Anup Kage 
 * @Last Modified On   : 5/19/2020, 2:40:55 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/19/2020        Anup Kage               Initial Version
**/
@isTest
public class TST_CNT_CLP_CallOut {
    /**
    * @description 
    * @author Anup Kage  | 5/19/2020 
    * @return void 
    **/
    @testSetup
    static void setup(){
        
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
        
        Unity_Living_Proposal__c record = Unity_Living_Proposal__c.getOrgDefaults();
        record.End_Point__c ='http://test.com';
        record.X_API_Key__c = 'test';
        record.Unity_Api_Time_Out__c = 120;
        upsert record;
    }

    /**
    * @description 
    * @author Anup Kage  | 5/19/2020 
    * @return testMethod 
    **/
    static testMethod void testCallOut(){
        String agId = [SELECT id FROM Bid_History__c LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new TST_MockHttpSucessResponseGenerator());
        Test.startTest();
        String response =  CNT_CLP_CallOut.getAgreementValues(agId);
        Test.stopTest();
        Bid_History__c record = [SELECT id, Unity_Living_Proposal__c FROM Bid_History__c WHERE ID=: agId LIMIT 1];

        // system.assertEquals(t, actMatch.size());
        system.assertEquals(false,String.isEmpty(record.Unity_Living_Proposal__c));
    }
    /**
    * @description 
    * @author Anup Kage  | 5/19/2020 
    * @return testMethod to cover error part
    **/
    static testMethod void testCallOutError(){
        String agId = [SELECT id FROM Bid_History__c LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new TST_MockHttpErrorResponseGenerator());
        Test.startTest();
        String response =  CNT_CLP_CallOut.getAgreementValues(agId);
        Test.stopTest();
        Bid_History__c record = [SELECT id, Unity_Living_Proposal__c FROM Bid_History__c WHERE ID=: agId LIMIT 1];
        system.assertEquals(false, String.isEmpty(record.Unity_Living_Proposal__c));
        // system.assertEquals(1, actMatch.size());
        // system.assertEquals(response,200); 
    }
    /**
    * @description 
    * @author Anup Kage | 10-01-2020 
    * @return testMethod 
    **/
    static testMethod void testFromTrigger(){
        Id agId = [SELECT id FROM Bid_History__c LIMIT 1].Id;
        Set<Id> agreemnetIdSet = new Set<Id>();
        agreemnetIdSet.add(agId);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_MockHttpSucessResponseGenerator());
        CNT_CLP_CallOut.getAgreementDetails(agreemnetIdSet);
        Test.stopTest();
    }
    /**
    * @description 
    * @author Anup Kage | 10-01-2020 
    * @return testMethod 
    **/
    static testMethod void refreshPageTest(){
        List<Id> agreementIdList = new List<Id>();
        agreementIdList.add([SELECT id FROM Bid_History__c LIMIT 1].Id);
        Test.startTest();
        CNT_CLP_CallOut.refreshUnityLink(agreementIdList);
        Test.stopTest();
    }
    
    static testMethod void testAuraMethod(){
        Bid_History__c agreement = [SELECT id, CreatedDate FROM Bid_History__c LIMIT 1];
        Test.startTest();
        CNT_CLP_CallOut.getAgreementDetail(agreement.Id);
        CNT_CLP_CallOut.isRecordCreatedNow(agreement.CreatedDate);
        Test.stopTest();
    }
    
    public class TST_MockHttpErrorResponseGenerator implements HttpCalloutMock{
        public  HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"value":[{"name":"Avkash","email":"anup@fake"}],"msg":"Proposal users must be in a valid format.","param":"proposalUsers","location":"body"}]');
            res.setStatusCode(400);
            return res;
        } 
    }  
    public class TST_MockHttpSucessResponseGenerator implements HttpCalloutMock{
        public  HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"Unity record for this opportunity already exists. Scroll down for the Unity Link.","url":"http://iqvia-unity-web-app.s3-website.us-east-2.amazonaws.com/app/proposals/07cb0bfa-7124-4b48-be9b-be7be1b70e58"}');
            res.setStatusCode(200);
            return res;
        } 
    }  
} 