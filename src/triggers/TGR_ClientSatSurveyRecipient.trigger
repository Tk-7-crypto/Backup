trigger TGR_ClientSatSurveyRecipient on Client_Sat_Survey_Recipient__c (before insert) {
    fflib_SObjectDomain.triggerHandler(DAO_ClientSatSurveyRecipient.class);
}