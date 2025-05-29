/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for PSA Date Offset
 */
public class SLT_Date_Offset extends fflib_SObjectSelector {
    
    public SLT_Date_Offset() {
        super(true, false, false);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PSA_Date_Offset__c.Id,
            PSA_Date_Offset__c.Description__c,
            PSA_Date_Offset__c.Name,
            PSA_Date_Offset__c.Object__c,
            PSA_Date_Offset__c.Offset__c,
            PSA_Date_Offset__c.Program__c,
            PSA_Date_Offset__c.Project__c,
            PSA_Date_Offset__c.Service__c,
            PSA_Date_Offset__c.Service_Line__c,
            PSA_Date_Offset__c.Source_Date_Field__c,
            PSA_Date_Offset__c.Target_Date_Field__c,
            PSA_Date_Offset__c.Type_Field__c,
            PSA_Date_Offset__c.Type_Value__c,
            PSA_Date_Offset__c.Unit_Type__c
        };
    }
     
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return PSA_Date_Offset__c.sObjectType;
    }

    /**
     * This method used to get Date Offset by object
     */
    public List<PSA_Date_Offset__c> getDateOffsetByObject(Set<String> objectTypeSet, Set<String> fieldSet) {
        return new List<PSA_Date_Offset__c >((List<PSA_Date_Offset__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Object__c in :objectTypeSet').toSOQL()));
    }

    /**
     * This method used to get Date Offset by object and program id
     */
    public List<PSA_Date_Offset__c> getDateOffsetByObjectAndProgram(Set<String> objectTypeSet, Set<String> fieldSet, Set<Id> programIdSet ) {
        return new List<PSA_Date_Offset__c >((List<PSA_Date_Offset__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Object__c in :objectTypeSet AND Program__c in :programIdSet').toSOQL()));
    }

    /**
        Exception for failures in the selector class
     */
    public class SelectorException extends Exception {}

}