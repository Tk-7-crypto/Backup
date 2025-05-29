@isTest
public class TST_UTL_OWF_DataProcessUtility {
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
        insert opp;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        insert bidHistory;
        Template_Data__c templateData = new Template_Data__c(Cell_Reference__c='NUMBER_OF_SCENARIOS',DML_Type__c='Read',Field_Name__c='Number_of_Scenarios__c',Object_Name__c='Bid_History__c',Migration_Id__c='1233333',Status__c='Active',Requested_By__c='test');
        insert templateData;
        Template_Data__c templateData2 = new Template_Data__c(Cell_Reference__c='BID_SENT_DATE',DML_Type__c='Write',Field_Name__c='Bid_Sent_Date__c',Object_Name__c='Bid_History__c',Migration_Id__c='1233313',Status__c='Active');
        insert templateData2;
    }
    
    @isTest
    public static void testGetData(){
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
        String response = UTL_OWF_DataProcessUtility.getData(gen.getAsString(),'test');
        System.assertNotEquals(null,response);
        test.stopTest();
    }
    @isTest
    public static void testhandlePutAndPostRequest(){
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
        String response = UTL_OWF_DataProcessUtility.handlePutAndPostRequest(gen.getAsString());
        System.assertNotEquals(null,response);
        test.stopTest();
    }
  
}