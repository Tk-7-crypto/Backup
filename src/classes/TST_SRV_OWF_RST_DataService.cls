@isTest
public class TST_SRV_OWF_RST_DataService {
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

        Template_Data__c templateData = new Template_Data__c(Cell_Reference__c='NUMBER_OF_SCENARIOS',DML_Type__c='Read',Field_Name__c='Number_of_Scenarios__c',Object_Name__c='Bid_History__c',Migration_Id__c='1233333',Status__c='Active',Requested_By__c='test');
        insert templateData;
     }
    
    static testMethod void testgetData()
    {
        test.startTest();
        Bid_History__c bidHistory = [Select id from bid_History__c limit 1];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Bid_History__c');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('Id', bidHistory.Id);
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        
        
        String endPointURLString = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/OWFServices/DataServices?requestString='+gen+'requestedBy=\'test\'';
        String contentTypeString = 'application/json';
        String authorizationHeaderString = 'OAuth '+UserInfo.getSessionId();
        
        
        RestRequest req = new RestRequest();
        req.requestUri = endPointURLString;
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(gen.getAsString());
		
        RestResponse res = new RestResponse();
        RestContext.response = res;

        req.addHeader('content-type','application/json');
        RestContext.request = req;
        String resp = SRV_OWF_RST_DataService.getData();
        test.stopTest();						
    }
    static testMethod void testhandlePutAndPostRequest()
    {
        Bid_History__c bidHistory = [Select id from bid_History__c limit 1];
        test.startTest();
        String endPointURLString = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/OWFServices/DataSerevices';
        String contentTypeString = 'application/json';
        String authorizationHeaderString = 'OAuth '+UserInfo.getSessionId();
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Bid_History__c');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('Id', bidHistory.Id);
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        
        RestRequest req = new RestRequest();
        req.requestUri = endPointURLString;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(gen.getAsString());
		
        RestResponse res = new RestResponse();
        RestContext.response = res;

        req.addHeader('content-type','application/json');
        RestContext.request = req;
        Map<String, String> resp = SRV_OWF_RST_DataService.doPost();
        test.stopTest();						
    }
    
    static testMethod void testhandlePutAndPostRequest2()
    {
        Bid_History__c bidHistory = [Select id from bid_History__c limit 1];
        test.startTest();
        String endPointURLString = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/OWFServices/DataSerevices';
        String contentTypeString = 'application/json';
        String authorizationHeaderString = 'OAuth '+UserInfo.getSessionId();
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Bid_History__c');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('Id', bidHistory.Id);
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        
        RestRequest req = new RestRequest();
        req.requestUri = endPointURLString;
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(gen.getAsString());
		
        RestResponse res = new RestResponse();
        RestContext.response = res;

        req.addHeader('content-type','application/json');
        RestContext.request = req;
        Map<String, String> resp = SRV_OWF_RST_DataService.doPut();
        test.stopTest();						
    }

}