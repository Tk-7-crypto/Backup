@isTest
public class TST_SRV_OWF_RST_RRSerevices {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = 'TSL';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
		
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.Is_this_IQVIA_Biotech__c = 'No';
        opp.QI_Invited_to_Present__c = 'Yes';
        opp.Bid_Defense_Date__c = Date.today().addDays(5);
        opp.Presentation_Country__c = 'Armenia';
        opp.Presentation_Date_Status__c = 'Estimated';
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        agreement.Opportunity_Type__c ='FSP_Skill';
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL';
        insert resourceRequest;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignment;
    }
    
    
    static testMethod void testDoPost()
    {
        test.startTest();
        UTL_ExecutionControl.stopTriggerExecution_OWF = true;
        pse__Assignment__c assignment = [Select Id, pse__Status__c from pse__Assignment__c where pse__Resource_Request__r.SubGroup__c = 'TSL' limit 1];
        assignment.pse__Status__c = 'Accepted';
        update assignment;
        UTL_ExecutionControl.stopTriggerExecution_OWF = false;
        String doPostCaseString = 'createBDRR';
        String endPointURLString = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/OWFServices/RRSerevices';
        String contentTypeString = 'application/json';
        String authorizationHeaderString = 'OAuth '+UserInfo.getSessionId();
        
        JSONGenerator reqBodyJson = JSON.createGenerator(true);
        reqBodyJson.writeStartObject();
        reqBodyJson.writeStringField('doPostCase',doPostCaseString);
        reqBodyJson.writeObjectField('reuqiredParams',new List<Id>{assignment.id});
        reqBodyJson.writeEndObject();
        
        RestRequest req = new RestRequest();
        req.requestUri = endPointURLString;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBodyJson.getAsString());
		
        RestResponse res = new RestResponse();
        RestContext.response = res;

        req.addHeader('content-type','application/json');
        RestContext.request = req;
        String resp = SRV_OWF_RST_RRSerevices.doPost('createBDRR',new List<String>{assignment.id});
        String respBad = SRV_OWF_RST_RRSerevices.doPost('createBDRR',new List<String>{});
        test.stopTest();						
    }
    
    static testMethod void testDoPost2()
    {
        test.startTest(); 
        
        pse__Assignment__c assignment = [Select Id, pse__Status__c from pse__Assignment__c where pse__Resource_Request__r.SubGroup__c = 'TSL' limit 1];
       	assignment.pse__Status__c = 'Accepted';
        update assignment;
        pse__Permission_Control__c permissionControlGroup = [Select id, pse__Group__c from pse__Permission_Control__c limit 1];
        delete permissionControlGroup;
        String doPostCaseString = 'createBDRR';
        String endPointURLString = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/OWFServices/RRSerevices';
        String contentTypeString = 'application/json';
        String authorizationHeaderString = 'OAuth '+UserInfo.getSessionId();
        
        JSONGenerator reqBodyJson = JSON.createGenerator(true);
        reqBodyJson.writeStartObject();
        reqBodyJson.writeStringField('doPostCase',doPostCaseString);
        reqBodyJson.writeObjectField('reuqiredParams',new List<Id>{assignment.id});
        reqBodyJson.writeEndObject();
        
        RestRequest req = new RestRequest();
        req.requestUri = endPointURLString;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBodyJson.getAsString());
		
        RestResponse res = new RestResponse();
        RestContext.response = res;

        req.addHeader('content-type','application/json');
        RestContext.request = req;
        String resp = SRV_OWF_RST_RRSerevices.doPost('createBDRR',new List<String>{assignment.id});
        String respBad = SRV_OWF_RST_RRSerevices.doPost('createBDRR',new List<String>{});
        test.stopTest();						
    }
}
