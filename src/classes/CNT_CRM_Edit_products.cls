public with sharing class CNT_CRM_Edit_products {
    public CNT_CRM_Edit_products() {
        
    }
    
    public static Map<String, Object> fetchIBNFRecordDetails(String recsId){
        Map<String, Object> returnMap = BNFOpptyListLockedGridMobile.fetchAllDetailsOnLoad(recsId);
        return returnMap;
    }
    
    public static Map<String, Object> fetchEBNFRecordDetails(String recsId){
        Map<String, Object> returnMap = BNFProductControllerMobile.fetchAllDetailsOnLoad(recsId);
        return returnMap;
    }
    
    public static Map<String, Object> fetchMIBNFRecordDetails(String recsId){
        Map<String, Object> returnMap = MIBNF_ProductControllerLockedGridM.fetchAllDetailsOnLoad(recsId);
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> fetchAllDetailsOnLoad(String recsId){
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.putAll(getObjectAndRecordType(recsId));
        if(returnMap.get('objectType') == 'BNF2__c'){
            if(returnMap.get('RecordType') == 'Manual Setup in SAP'){
                returnMap.putAll(fetchEBNFRecordDetails(recsId));     // fetching EBNF records
            }else{
                returnMap.putAll(fetchIBNFRecordDetails(recsId));     // fetching IBNF records
            }
        }else if(returnMap.get('objectType') == 'MIBNF2__c' || returnMap.get('objectType') == 'MIBNF_Component__c'){
            returnMap.putAll(fetchMIBNFRecordDetails(recsId));
        }
        return  returnMap;
    }
    
    @AuraEnabled
    public static Decimal getRevisedPrice(Id oliId,boolean isOriginalRevSchedules){
        Decimal revenueAmount = 0.00;
        List<String> strRevSchedule = new List<String>();
        if(isOriginalRevSchedules){
            List<OpportunityLineItemSchedule> OLIS_List = [SELECT Id,Revenue,ScheduleDate FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId = :oliId];
            for (OpportunityLineItemSchedule OLIS:OLIS_List){
                revenueAmount = revenueAmount + OLIS.Revenue;
            }
        }
        else{
            OpportunityLineItem oli = [SELECT Id,Revised_Revenue_Schedule__c FROM OpportunityLineItem WHERE Id= :oliId];
            if (OLI.Revised_Revenue_Schedule__c != null && OLI.Revised_Revenue_Schedule__c != ''){
                strRevSchedule = OLI.Revised_Revenue_Schedule__c.split('\\|'); 
                //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                if (strRevSchedule[0] == 'x')
                    strRevSchedule.clear();       
                for (integer i=0;i<strRevSchedule.size();i++)
                {
                    revenueAmount = revenueAmount + Decimal.valueOf(strRevSchedule[i].split(':')[1]);
                }
            }
        }
        return revenueAmount;
    }
    
    public static Map<String, Object> getObjectAndRecordType(Id recsId){
        Map<String, Object> returnMap = new Map<String,Object>();
        String objectType = recsId.getsobjecttype().getDescribe().getName();
        returnMap.put('objectType',objectType);
        if(objectType == 'BNF2__c'){
            BNF2__c bnf = [SELECT Id,RecordType.Name FROM BNF2__c WHERE Id =:recsId];
            returnMap.put('RecordType',bnf.RecordType.Name);
        }
        List<Document> glossaryDocumentList = [SELECT Id FROM Document where DeveloperName = : MDM_Defines.Document_Dev_Name_IMSSFDCGlossary];
        if(glossaryDocumentList.size() > 0){
            returnMap.put('glossaryDocumentId',glossaryDocumentList[0].Id);
        }
        return returnMap;
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean getIsAboveThreshold(Id recsId){
        Map<String, Object> dataMap= getObjectAndRecordType(recsId);
        Boolean isAboveThreshold = true;
        BNF_Settings__c bnfSettings = BNF_Settings__c.getOrgDefaults();
        Decimal threshold = bnfSettings.BNF_Opportunity_Threshold__c;
        Decimal opportunityNumber;
        if(dataMap.get('objectType') == 'BNF2__c' && dataMap.get('RecordType') == 'SAP SD Integrated'){
            opportunityNumber = Decimal.valueOf([SELECT Id,Opportunity_Number__c from BNF2__c WHERE Id =:recsId].Opportunity_Number__c);
        }
        else if(dataMap.get('objectType') == 'MIBNF_Component__c' ){
            opportunityNumber = Decimal.valueOf([SELECT Id,Opportunity__r.Opportunity_Number__c from MIBNF_Component__c WHERE Id =:recsId].Opportunity__r.Opportunity_Number__c);
        }
        if(threshold != null && opportunityNumber != null && threshold >= opportunityNumber){
            isAboveThreshold = false;
        }
        return isAboveThreshold;
    }
}