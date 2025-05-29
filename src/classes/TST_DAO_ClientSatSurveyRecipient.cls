@IsTest
public class TST_DAO_ClientSatSurveyRecipient {
    
    @istest
    public static void testBeforeInsert(){
        Client_Sat_Survey__c clientSurvey = new Client_Sat_Survey__c();
        clientSurvey.Survey_Send_Date__c = System.today();
        insert clientSurvey;
        
        Client_Sat_Survey_Recipient__c csRec = new Client_Sat_Survey_Recipient__c();
        csRec.Client_Sat_Survey__c = clientSurvey.id;
        Test.startTest();
        insert csRec;
        Test.stopTest();
    }

}