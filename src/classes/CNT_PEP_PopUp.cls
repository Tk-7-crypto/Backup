public with sharing class CNT_PEP_PopUp {
    
    @AuraEnabled
    public static In_App_Guidance__c getPageDetails(String pageName){
        Date dateToday = Date.Today();
        return new SLT_InAppGuidance().getGuidanceDescription(pageName, dateToday);
    }
    
}