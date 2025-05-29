public class CNT_OWF_MassUpdate{
    public List<SObject> obj{get;set;}
    private ApexPages.StandardSetController sctrl;
    
    public CNT_OWF_MassUpdate(ApexPages.StandardSetController controller) {
        obj = (List<SObject>) controller.getSelected();
        this.sctrl = controller;
    }
    
    @AuraEnabled(cacheable=false)
    public static list<SObject> getRecords(String sObjectname,List<String> recordIds, List<String> fieldNames){
        list<SObject> records= new SLT_SObject().selectSObjectListByIds(Schema.getGlobalDescribe().get(sObjectname),new Set<String>(recordIds), new Set<String>(fieldNames));
        return records;     
    }
    
    @AuraEnabled
    public static void updateRecords(List<SObject> sObjectType){
        try{
            update sObjectType;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public PageReference navigationtoPreviouspage() {
        return sctrl.cancel();
    }
    
    @auraEnabled(cacheable=true)
    public static id getrecordtypeId(String ObjectName,String RecordTypeName){
        id recId;
        if(ObjectName=='pse__Resource_Request__c')
            recId= Schema.SObjectType.pse__Resource_request__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        else if(ObjectName=='pse__Assignment__c'){       
            recId= Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        }
        return recId;
    }
}