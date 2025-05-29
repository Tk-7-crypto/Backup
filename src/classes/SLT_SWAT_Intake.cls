public class SLT_SWAT_Intake extends fflib_SObjectSelector {
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            SWAT_Intake__c.Id,
            SWAT_Intake__c.Submit_Form_To_SWAT_Team__c,
            SWAT_Intake__c.Opportunity__c,
            SWAT_Intake__c.Last_Submitted_Date__c
                };
                    }
    
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return SWAT_Intake__c.sObjectType;
    }
    
    /**
    * This method used to get SWAT_Intake__c by Id
    * @return  List<SWAT_Intake__c>
    */
    public List<SWAT_Intake__c> selectByOppId(Set<ID> oppId) {
        return Database.query(newQueryFactory(true).setCondition('Opportunity__c  =:oppId').toSOQL());
    }
    /**
    * This method used to get SWAT_Intake__c by Id
    * @return  List<SWAT_Intake__c>
    */
    public List<SWAT_Intake__c> selectBySwatId(Set<ID> idSet) {
        return Database.query(newQueryFactory(true).setCondition('Id  =:idSet').toSOQL());
    }
}