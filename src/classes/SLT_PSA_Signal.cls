/*
* Version       : 1.0
* Description   : This Apex class is selector layer for Signal
*/
public class SLT_PSA_Signal extends fflib_SObjectSelector {
    
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_PSA_Signal() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialise CRUD and FLS with a parameter for FLS.
    */
    public SLT_PSA_Signal(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_PSA_Signal(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
    * This method used to get field set of field names for the sobject
    * @return  Set<String>
    */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldLists();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }        
        return fieldNames;
    }  
    
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldLists () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }
    
    
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Signal__c.sObjectType;
    }
    
    public override String getOrderBy(){
        return 'createdDate DESC';
    }
    
    /**
    * This method used to get Project by Id
    * @return  Map<Id, Signal__c>
    */
    public Map<Id, Signal__c> getSignalMapBySignalIds(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Signal__c>((List<Signal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet and Project__r.Service_Line__r.name = ' + '\'' + 'Signal Management' + '\'').toSOQL()));
    }
    //check for reqd. permission set
    public List<PermissionSetAssignment> checkPermmission() {
        List<PermissionSetAssignment> permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        return permissionSetList;
    }
    
    /**
    * This method used to get Project by Id
    * @return  List<Signal__c>
    */
    public list<Signal__c> getSignalListById(Id signalId) {
        list<Signal__c> signalList  = [SELECT Id, Project__c
                                       FROM Signal__c
                                       WHERE Id =: signalId];
        return signalList;
    }
}
