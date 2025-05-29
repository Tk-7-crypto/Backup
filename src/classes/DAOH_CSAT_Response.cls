public class DAOH_CSAT_Response {
    
    Public Static Void updateAnswer(List<CSAT_Responses__c> newList) {
        for(CSAT_Responses__c cSatResponse: newList) {
            if(cSatResponse != null && cSatResponse.Answer__c != null && cSatResponse.Answer__c.isNumeric() && Integer.valueOf(cSatResponse.Answer__c) < 10) {
                cSatResponse.Answer_Numeric__c = Integer.valueOf(cSatResponse.Answer__c);
            }
        }
    }
}