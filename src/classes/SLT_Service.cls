/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for SLT_Service
 */
public class SLT_Service extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Service () {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to get field set of field names for the sobject
     * @return  Set<String>
     */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldList();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }        
        return fieldNames;
    }    
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Service__c.sObjectType;
    }

    /**
     * This method used to get Service by Id
     * @return  Map<Id, Service__c>
     */
    public Map<Id, Service__c> getServiceById(Set<Id> idSet, Set<String> fieldSet) {
        return new Map<Id, Service__c>((List<Service__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get active services by Service Code 
     * @return  Map<String, Service__c>
     */
    public Map<String, Service__c> getActiveServiceByServiceCode(Set<String> serviceCodeSet, Set<String> fieldSet) {
        List<Service__c> services = (List<Service__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Active__c = True AND Service_Code__c in :serviceCodeSet').toSOQL());
        Map<String, Service__c> serviceCodeToServiceMap = new Map<String, Service__c>();
        for(Service__c service : services){
            serviceCodeToServiceMap.put(service.Service_Code__c, service);
        }
        return serviceCodeToServiceMap;
    }
}