@istest
public with sharing class TST_CNT_BOX_NestedFoldersCreation {
    @TestSetup
    public static void setup(){
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
    }
    static testMethod void testFolderCreation(){
        Bid_History__c bidHistory = [SELECT id, Bid_History_Related_Opportunity__c from Bid_History__c Limit 1];
        CNT_BOX_NestedFoldersCreation.creatingNestedFolders(bidHistory.Id, bidHistory.Bid_History_Related_Opportunity__c, 'Bid History');
    }
    static testMethod void testMovingFiles(){
        Test.setMock(HttpCalloutMock.class, new TST_MockHttpResponseGenerator());
        Test.startTest();
        CNT_BOX_NestedFoldersCreation.moveFilesToRFP('12345', '6789');
        Test.stopTest();
    }
    public class TST_MockHttpResponseGenerator implements HttpCalloutMock{
        public  HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"total_count":3,"entries":[{"type":"file","id":"685376509019","file_version":{"type":"file_version","id":"727615157819","sha1":"737b7bf731ee4d1290d282bf70fa6ac008c9f111"},"sequence_id":"0","etag":"0","sha1":"737b7bf731ee4d1290d282bf70fa6ac008c9f111","name":"download.png"]}');
            // res.setBody('[{"entries": [{ "id": 12345, "etag": 1,"type": "file","sequence_id": 3, "name": "Contract.pdf", "sha1": "85136C79CBF9FE36BB9D05D0639C70C265C18D37","file_version": {'+
            //           '"id": 12345,"type": "file_version","sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc"},"description": "Contract for Q1 renewal","size": 629644,'+
            //         '"path_collection": {"total_count": 1, "entries": [{"id": 12345, "etag": 1,"type": "folder", "sequence_id": 3,"name": "Contracts"} ] },'+
            //         '"parent": {"id": 12345, "etag": 1, "type": "folder","sequence_id": 3,"name": "Contracts"},'+
            //         '"item_status": "active","allowed_invitee_roles": [  "editor" ], "is_externally_owned": true,"has_collaborations": true } ],"limit": 1000,"offset": 2000, "order": [{ "by": "type", "direction": "ASC"}], "total_count": 5000 }]');
            res.setStatusCode(200);
            return res;
        } 
    }
}