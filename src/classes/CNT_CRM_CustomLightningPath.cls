public with sharing class CNT_CRM_CustomLightningPath {
    public CNT_CRM_CustomLightningPath() {
        
    }
    
    @AuraEnabled(Cacheable=true)
    public static map<String,Custom_Sales_Path_Configuration__mdt> getData(){
        Id profileId = UserInfo.getProfileId();
        Map<String,Custom_Sales_Path_Configuration__mdt> mdtMap= new Map<String,Custom_Sales_Path_Configuration__mdt>();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        List<Custom_Sales_Path_Configuration__mdt> mdtList = [SELECT Id, profile__c,Opp_Stage__c, Key_Field1__c,Key_Field2__c,Key_Field3__c, Key_Field4__c, Key_Field5__c,Key_Field6__c, Key_Field7__c, Key_Field8__c, Key_Field9__c, Key_Field10__c,
                                                              Key_Field11__c, Key_Field12__c, Key_Field13__c, Key_Field14__c, Key_Field15__c, Guidelines__c  FROM Custom_Sales_Path_Configuration__mdt  WHERE Profile__c = :profileName];
        if(mdtList.size() <= 0)
            mdtList = [SELECT Id, profile__c,Opp_Stage__c, Key_Field1__c,Key_Field2__c,Key_Field3__c, Key_Field4__c, Key_Field5__c,Key_Field6__c, Key_Field7__c, Key_Field8__c, Key_Field9__c, Key_Field10__c,
                       Key_Field11__c, Key_Field12__c, Key_Field13__c, Key_Field14__c, Key_Field15__c, Guidelines__c  FROM Custom_Sales_Path_Configuration__mdt WHERE Profile__c = NULL];
        for(Custom_Sales_Path_Configuration__mdt mdt : mdtList ){
            mdtMap.put(mdt.Opp_Stage__c,mdt);
        }
        return mdtMap;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getKeyFields(String stageName,Map<String,Custom_Sales_Path_Configuration__mdt> mdt){
        List<String> fields = new List<String>();
        if(mdt.containsKey(stageName)){
            Custom_Sales_Path_Configuration__mdt metadata = mdt.get(stageName);
            if(metadata.Key_Field1__c != null)
                fields.add(metadata.Key_Field1__c);
            if(metadata.Key_Field2__c != null)
                fields.add(metadata.Key_Field2__c);
            if(metadata.Key_Field3__c != null)
                fields.add(metadata.Key_Field3__c);
            if(metadata.Key_Field4__c != null)
                fields.add(metadata.Key_Field4__c);
            if(metadata.Key_Field5__c != null)
                fields.add(metadata.Key_Field5__c);
            if(metadata.Key_Field6__c != null)
                fields.add(metadata.Key_Field6__c);
            if(metadata.Key_Field7__c != null)
                fields.add(metadata.Key_Field7__c);
            if(metadata.Key_Field8__c != null)
                fields.add(metadata.Key_Field8__c);
            if(metadata.Key_Field9__c != null)
                fields.add(metadata.Key_Field9__c);
            if(metadata.Key_Field10__c != null)
                fields.add(metadata.Key_Field10__c);
            if(metadata.Key_Field11__c != null)
                fields.add(metadata.Key_Field11__c);
            if(metadata.Key_Field12__c != null)
                fields.add(metadata.Key_Field12__c);
            if(metadata.Key_Field13__c != null)
                fields.add(metadata.Key_Field13__c);
            if(metadata.Key_Field14__c != null)
                fields.add(metadata.Key_Field14__c);
            if(metadata.Key_Field15__c != null)
                fields.add(metadata.Key_Field15__c);
        }
        if(fields.size() > 0)
            return fields;
        else 
            return null;
    }
    
    @AuraEnabled(Cacheable=true)
    public static String getGuidance(String stageName,Map<String,Custom_Sales_Path_Configuration__mdt> mdt){
        String guidance;
        if(mdt.containsKey(stageName)){
            Custom_Sales_Path_Configuration__mdt metadata = mdt.get(stageName);
            return metadata.Guidelines__c;
        }
        return null;
    }
    
}