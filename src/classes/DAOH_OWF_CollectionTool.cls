public class DAOH_OWF_CollectionTool {
    
    public static void updateRevLabID(List<CollectionTool__c> newList, Map<Id, CollectionTool__c> oldMap){ 
        List<CollectionTool__c> collectionList = new List<CollectionTool__c>();
        Set<Id> productIdSet =  new Set<Id>();
        Set<String> sites = new Set<String>(); 
		Set<String> businessAreas = new Set<String>();        
        for(CollectionTool__c col :newList){       
            if(getEligibleRecordToUpdateRevLabId(col,oldMap)){
                collectionList.add(col);
                productIdSet.add(col.ServiceLine__c);
                sites.add(col.Site_Global__c);
                businessAreas.add(col.Type__c);
            }
        }
        
        if(!collectionList.isEmpty() && !productIdSet.isEmpty()){           
            Map<Id,Product2> productMap= new Map<ID, Product2>(new SLT_Product2().selectById(productIdSet));
            Set<String> sapCodes = new Set<String>();
            for (Product2 product : productMap.values()) {
                sapCodes.add(product.SAP_Code__c);
            }            
            List<OWF_Q2_RevLabId_Matrix__mdt> revLabMetadata = [Select Id, DeveloperName, Site__c, Rev_Lab_Id__c, Service_Line__c, Business_Area__c 
                                                                FROM OWF_Q2_RevLabId_Matrix__mdt 
                                                                WHERE Site__c IN :sites
                                                                	AND Service_Line__c IN :sapCodes
                                                                	AND Business_Area__c IN :businessAreas];
            
            Map<String, string> revLabIdMap = new  Map<String, string>();
            for(OWF_Q2_RevLabId_Matrix__mdt metaRecord : revLabMetadata){
                String key = metaRecord.Business_Area__c + '-' + metaRecord.Service_Line__c + '-' + metaRecord.Site__c;
                revLabIdMap.put(key.toLowerCase(), metaRecord.Rev_Lab_Id__c );                               
            }           
            for(CollectionTool__c collectionRecord :collectionList){
                string key = collectionRecord.Type__c + '-' + productMap?.get(collectionRecord.ServiceLine__c).SAP_Code__c + '-' + collectionRecord.Site_Global__c;
                if(revLabIdMap.containsKey(key.toLowerCase())){
                    collectionRecord.Rev_Lab_ID__c = revLabIdMap?.get(key.toLowerCase());
                }
                else{
                    collectionRecord.Rev_Lab_ID__c ='';
                }
            }            
            
        }
        
    }   
    
    private static Boolean getEligibleRecordToUpdateRevLabId(CollectionTool__c collectionRecord, Map<Id, CollectionTool__c> oldMap){
        if((collectionRecord.RecordTypeId == CON_OWF.OWF_COLLECTIONTOOL_Q2_SOLUTIONS_RECORD_TYPE_ID && (
            CON_OWF.Q2_BUSINESS_AREA_LIST.contains(collectionRecord.Type__c) || CON_OWF.DISCOVERY_BUDGET_TOOLS_LIST.contains(collectionRecord.Type__c))) && collectionRecord.Site_Global__c!=null && collectionRecord.ServiceLine__c!=null &&
            (oldMap==null || (oldMap!=null &&(collectionRecord.Site_Global__c!=oldMap.get(collectionRecord.Id).Site_Global__c ||
            collectionRecord.ServiceLine__c!=oldMap.get(collectionRecord.Id).ServiceLine__c)))){
             return true;  
        }
        return false;  
    }
}