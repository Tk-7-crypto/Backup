/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for SLT_PSSF
 */
public class SLT_PSSF extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSSF() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSSF(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_PSSF(Boolean enforceFLS,Boolean enforceCRUD) {
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
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return PSSF__c.sObjectType;
    }
    
    public override String getOrderBy(){
      return 'createdDate DESC';
   }

    /**
     * This method used to get PSSF by Project
     * @return  list<PSSF__c>
     */
    public List<PSSF__c> getPSSFByProject(Set<ID> idSet, Set<String> fieldSet) {
        return (List<PSSF__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project_Name__c in :idSet and PSSF_Status__c = ' + '\'' + 'Published' + '\'').toSOQL());
    }
    /**
     * This method used to get PSSF by id
     * @return  list<PSSF__c>
     */
    public List<PSSF__c> getPSSFById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<PSSF__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('id in :idSet').toSOQL());
    }
    
    /**
     * This method used to get PSSF by PSSF_Parent__c
     * @return  list<PSSF__c>
     */
    public List<PSSF__c> getPSSFByPSSFParentDataSource(Set<ID> idSet, Set<String> fieldSet) {
        return (List<PSSF__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('PSSF_Parent__c in :idSet and Is_History_of_Changes_Record__c = false').toSOQL());
    }
    
    /**
     * This method used to get PSSF by PSSF_Parent__c
     * @return  list<PSSF__c>
     */
    public List<PSSF__c> getPSSFByPSSFParentHistoryChanges(Set<ID> idSet, Set<String> fieldSet) {
        return (List<PSSF__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('PSSF_Parent__c in :idSet and Is_History_of_Changes_Record__c = true').toSOQL());
    }
    
    /**
     * This method used to get PSSF for draft
     * @return  list<PSSF__c>
     */
    public List<PSSF__c> getPSSFDataForDraft(Id projectId, Set<String> fieldSet, String condition) {
        return (List<PSSF__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
     * This method used to get PSSF by status
     * @return  list<PSSF__c>
     */
    public List<PSSF__c> getPSSFDataForStatus(Id pssfId, Set<String> fieldSet, String condition, String status) {
        return (List<PSSF__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
     * This method used to get PSSF data by parent pssf
     * @return  list<PSSF__c>
     */
    public List<PSSF__c> getPSSFDataForParentPSSF(Id pssfParentRecId, Set<String> fieldSet, String condition) {
        return (List<PSSF__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
     * This method used to get PSSF focus field metadata
     * @return  list<PSA_PSSF_Focus_Field_Value__mdt>
     */
    public List<PSA_PSSF_Focus_Field_Value__mdt> getPSSFFocusFieldValData() {
        List<PSA_PSSF_Focus_Field_Value__mdt> focusFieldValMdtList = new List<PSA_PSSF_Focus_Field_Value__mdt>();
        focusFieldValMdtList = [Select Id, Label, Focus__c from PSA_PSSF_Focus_Field_Value__mdt LIMIT 1000];
        return focusFieldValMdtList;
    }
}
