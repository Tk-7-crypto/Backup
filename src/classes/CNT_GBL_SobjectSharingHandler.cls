public class CNT_GBL_SobjectSharingHandler {
    
    /*
    * @params 
    * Fetch Sobject sharing records
    */
    @AuraEnabled
    public static Map<String,Object> fetchSobjectSharingRecords(){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        List<String> batchProcessingList = new List<String>{CON_CRM.BATCH_PROCESSING_NEW, CON_CRM.BATCH_PROCESSING_IN_PROCESSING};
        //List<SObject_Sharing__c> currentUserDetails = [SELECT Parent_Sobject__c, Child_Sobject__c, Enable_Sharing_Calculation__c, Lookup_Relationship_Name__c, Child_Sobject_Share__c, Lookup_Name__c, Sharing_Owner_Label__c, Parent_Sobject_Share__c, Sharing_Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, Account_Country_Api_Name__c, Record_Type_Api_Name__c, Parent_Customer_Code_Api_Name__c, Business_Unit_Api_Name__c, Type__c, Parent_Sharing_Territory_Label__c, Parent_Sharing_Team_Label__c, Maintenance_Job_Status__c, Name, Id FROM SObject_Sharing__c where Parent_Sobject_Share__c != null];        
            List<SObject_Sharing__c> currentSharingRecords = [SELECT Parent_Sobject__c, Child_Sobject__c, Enable_Sharing_Calculation__c, 
                                                              Team_Sharing_Lookup_Field__c,Child_Sobject_Share__c, Lookup_Name__c, Sharing_Owner_Label__c, 
                                                              Parent_Sobject_Share__c, Sharing_Type__c, Sharing_Territory_Label__c, Sharing_Team_Label__c, 
                                                              Account_Country_Api_Name__c, Record_Type_Api_Name__c, Parent_Customer_Code_Api_Name__c, Business_Unit_Api_Name__c,
                                                              Type__c, Parent_Sharing_Territory_Label__c, Parent_Sharing_Team_Label__c,Maintenance_Job_Status__c, Name,
                                                              Id FROM SObject_Sharing__c where Parent_Sobject_Share__c != null AND 
                                                              Sharing_Type__c =: CON_CRM.SHARING_TYPE_DERIVED AND Enable_Sharing_Calculation__c = true order by CreatedDate DESC];        
        System.debug(currentSharingRecords.size()+'--'+currentSharingRecords);
        mapToReturn.put('allSharing',currentSharingRecords);
        mapToReturn.put('allTerritory',fetchAllTerritory());
        return mapToReturn;
    }
	@AuraEnabled
    public static List<SObject_Sharing__c> sObjectSharingProcessedRecords(){
        List<SObject_Sharing__c> currentSharingRecords = [SELECT Parent_Sobject__c, Maintenance_Job_Status__c from SObject_Sharing__c where Maintenance_Job_Status__c =: CON_CRM.BATCH_PROCESSING_IN_PROCESSING];

        return currentSharingRecords;
    }
    @AuraEnabled
    public static List<SObject> initiateSobjectSharing(String sharingType, List<String> sharingIds){
        List<SObject> allDataList = new List<SObject>();
        if(sharingType == 'allSharing'){
            List<SObject_Sharing__c> currentSharingRecords = [SELECT Parent_Sobject__c, Child_Sobject__c, Enable_Sharing_Calculation__c,Team_Sharing_Lookup_Field__c,
                                                              Child_Sobject_Share__c, Lookup_Name__c, Sharing_Owner_Label__c,Parent_Sobject_Share__c, Sharing_Type__c,
                                                              Sharing_Territory_Label__c, Sharing_Team_Label__c,Account_Country_Api_Name__c, Record_Type_Api_Name__c,
                                                              Parent_Customer_Code_Api_Name__c, Business_Unit_Api_Name__c,Type__c, Parent_Sharing_Territory_Label__c,
                                                              Parent_Sharing_Team_Label__c,Maintenance_Job_Status__c, Name, Id FROM SObject_Sharing__c where Id IN : sharingIds];
        allDataList.addAll(currentSharingRecords);
        }else if(sharingType == 'allTerritory'){
            List<Territory_Sharing__c> territorySharingList = [SELECT Id, Name, Maintenance_Job_Status__c, Record_Type__c, 
                                                               Account_Country__c, isActive__c, Parent_Sobject_Name__c,Business_Unit__c, Parent_Customer_Code__c FROM Territory_Sharing__c where
                                                               Id IN : sharingIds];
            System.debug('terr class ' + territorySharingList );
            allDataList.addAll(territorySharingList);
            System.debug('terr add '+allDataList );
        }
        if(allDataList.size() > 0){
            System.debug('terr class bactg'  );
            BCH_GBL_Sharing_Maintenance_Job sharingBatch = new BCH_GBL_Sharing_Maintenance_Job(allDataList); 
            database.executeBatch(sharingBatch);
        }
        return allDataList;
    }
    @AuraEnabled
    public static List<TerritoryModal> fetchAllTerritory(){
        List<Territory2> territoryList = [SELECT Id, Name, Territory2TypeId, ParentTerritory2Id, Territory2ModelId, Leaf_Node__c, 
                                          Sharing_Pillar__c, Included_in_Custom_Sharing__c, Legacy_Id__c FROM Territory2 where 
                                          Legacy_Id__c <> null and Leaf_Node__c = true and Sharing_Pillar__c = : CON_CRM.SHARING_PILLAR_GEOGRAPHY order by Name ASC limit 10];
        System.debug('-territoryList----'+territoryList);
        Map<String,Territory2> legacyIdToTerritoryMap = new Map<String,Territory2>();
        for(Territory2 ter : territoryList){
            legacyIdToTerritoryMap.put(ter.Legacy_Id__c,ter);
        }
        Map<String,Set<String>> legacyIdTostatusMap = new Map<String,Set<String>>();
        Map<String,List<Territory_Sharing__c>> legacyIdToTerritorySharingMap = new Map<String,List<Territory_Sharing__c>>();
        List<Territory_Sharing__c> territorySharingList = [SELECT Id, Name, Maintenance_Job_Status__c, Record_Type__c, Account_Country__c, isActive__c FROM Territory_Sharing__c where Account_Country__c IN : legacyIdToTerritoryMap.keySet()];
        for(Territory_Sharing__c tsc : territorySharingList){
            if(tsc.Maintenance_Job_Status__c != null){
                if(legacyIdTostatusMap.containsKey(tsc.Account_Country__c)){
                    legacyIdTostatusMap.get(tsc.Account_Country__c).add(tsc.Maintenance_Job_Status__c);
                }else{
                    legacyIdTostatusMap.put(tsc.Account_Country__c, new Set<String>{tsc.Maintenance_Job_Status__c});
                }
                if(legacyIdToTerritorySharingMap.containsKey(tsc.Account_Country__c)){
                    legacyIdToTerritorySharingMap.get(tsc.Account_Country__c).add(tsc);
                }else{
                    legacyIdToTerritorySharingMap.put(tsc.Account_Country__c, new List<Territory_Sharing__c>{tsc});
                }
            }else{
                legacyIdTostatusMap.put(tsc.Account_Country__c, new Set<String>{CON_CRM.BATCH_PROCESSING_NEW});
                legacyIdToTerritorySharingMap.put(tsc.Account_Country__c, new List<Territory_Sharing__c>{tsc});
            }
        }
        List<TerritoryModal> territoryModallist = new List<TerritoryModal>();
        for(String accCountry : legacyIdToTerritoryMap.keySet()){
            if(legacyIdTostatusMap.containsKey(accCountry)){
                if(legacyIdToTerritorySharingMap.containsKey(accCountry)){
                    territoryModallist.add(new TerritoryModal(legacyIdTostatusMap.get(accCountry),legacyIdToTerritoryMap.get(accCountry), legacyIdToTerritorySharingMap.get(accCountry))); 
                }else{
                    territoryModallist.add(new TerritoryModal(legacyIdTostatusMap.get(accCountry),legacyIdToTerritoryMap.get(accCountry), new List<Territory_Sharing__c>())); 
                }
                   
            }else{
                territoryModallist.add(new TerritoryModal(new Set<String>{CON_CRM.BATCH_PROCESSING_NEW},legacyIdToTerritoryMap.get(accCountry), new List<Territory_Sharing__c>()));
            }
        }
        return territoryModallist;
    }
    public class TerritoryModal{
        @AuraEnabled public String recId;
        @AuraEnabled public String recName;
        @AuraEnabled public String maintenanceStatus;
        @AuraEnabled public List<Id> terIdList;
        public TerritoryModal(Set<String> statusSet, Territory2 ter, List<Territory_Sharing__c> territorySharingList){
            recId = ter.Id;
            recName = ter.Name;
            terIdList = new List<Id>();
            if(territorySharingList.size() > 0){
                for(Territory_Sharing__c tsc : territorySharingList){
                    terIdList.add(tsc.Id);
                }
            }
            //maintenanceStatus = statusSet;
            if(statusSet.contains(CON_CRM.BATCH_PROCESSING_IN_PROCESSING)){
                maintenanceStatus = CON_CRM.BATCH_PROCESSING_IN_PROCESSING;
            }else if(statusSet.size() == 1){
                List<String> statusList = new List<String>();
                statusList.addAll(statusSet);
                maintenanceStatus = statusList[0];     
            }else{
                maintenanceStatus = CON_CRM.BATCH_PROCESSING_IN_PROCESSING;
                //maintenanceStatus = '';
            }
        }
    }
}