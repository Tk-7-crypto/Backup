public class CNT_CRM_List_View {
    
    public static String userFullName = UserInfo.getName();
    
    @AuraEnabled(cacheable=true)
    public static List<Campaign> getMyCampaign(){
        return [SELECT Id,Name, StartDate, Channel__c, NumberOfResponses, NoOfMQLs__c FROM Campaign WHERE Marketing_Lead__c = :userFullName AND IsActive = true];
    }
    
    @AuraEnabled(cacheable=true)
    public static MetadataWrapper getMetadata(String objectApiName, String fields, String conditions){
        boolean showNameWithUrl = false;
        
        MetadataWrapper metadataWrapper = new MetadataWrapper();
        String q = 'SELECT '+ fields +' FROM '+ objectApiName +' WHERE '+ conditions;
        System.debug(q);
        metadataWrapper.records = Database.query(q);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        
        List<String> textType = new List<String>{'INTEGER','PICKLIST','STRING','DOUBLE'};
            if(!showNameWithUrl){
                textType.add('NAME');
            }
        SObjectType r = ((SObject)(Type.forName('Schema.'+objectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        if (fields.toLowercase().contains('id') && fields.toLowercase().contains('name')) {
            showNameWithUrl = true;
        }
        Set<String> fieldSet = new Set<String>();
        for(String fieldName : fields.split(',')){
            fieldName = fieldName.trim();
            if(!showNameWithUrl || fieldName.toLowercase() !='name'){
                fieldSet.add(fieldName);
            }
        }
        for(String fieldName : fieldSet){
            
            String type = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
            String label = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getLabel());
            gen.writeStartObject();
            if(textType.contains(type)){
                gen.writeStringField('label', label);
                gen.writeStringField('fieldName', fieldName);
                gen.writeStringField('type', 'text');
            }else if(type == 'ID'){
                gen.writeStringField('label', 'Name');
                gen.writeStringField('fieldName', 'recordURL');
                gen.writeStringField('type', 'url');
                gen.writeFieldName('typeAttributes');
                gen.writeStartObject();
                gen.writeFieldName('label');
                gen.writeStartObject();
                gen.writeStringField('fieldName', 'Name');
                gen.writeStringField('type', 'text');
                gen.writeEndObject();
                gen.writeEndObject();
            }else{
                gen.writeStringField('label', label);
                gen.writeStringField('fieldName', fieldName);
                gen.writeStringField('type', type);
            }
            gen.writeBooleanField('sortable', true);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        metadataWrapper.coloumnsJSON = gen.getAsString();
        metadataWrapper.showNameWithUrl = showNameWithUrl;
        return metadataWrapper;
    }
    
    public class MetadataWrapper{
        @AuraEnabled
        public List<sObject> records;
        @AuraEnabled
        public String coloumnsJSON;
        @AuraEnabled
        public Boolean showNameWithUrl;
    }
    
}