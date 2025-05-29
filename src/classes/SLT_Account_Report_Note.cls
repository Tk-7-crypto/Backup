/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Account Report Notes
 */
public class SLT_Account_Report_Note extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Account_Report_Note() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Account_Report_Note(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Account_Report_Note(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
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
    public Schema.SObjectType getSObjectType() {
        return Account_Report_Note__c.sObjectType;
    }

    /**
     * This method used to get Account Report Notes by their account lookup
     *  @params Set<Id> accountIdSet
     *  @return Map<Id, Account_Report_Note__c>
     */
    public Map<Id, Account_Report_Note__c> getAccountReportNotesByAccountId(Id accountId) {
        return getAccountReportNotesByAccountId(new Set<Id> {accountId});
    }

    public Map<Id, Account_Report_Note__c> getAccountReportNotesByAccountId(Set<Id> accountIdSet) {
        fflib_QueryFactory ARNQueryFactory = newQueryFactory(true);
        ARNQueryFactory.selectFields(new Set<String>{'Id', 'Name', 'Account__c', 'Legacy_ID__c', 'Notes__c', 'Spreadsheet_Link__c', 'CreatedDate'});
        ARNQueryFactory.setCondition('Account__c in :accountIdSet');
        ARNQueryFactory.setOrdering(new fflib_QueryFactory.Ordering(Account_Report_Note__c.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING));
        String queryString = ARNQueryFactory.toSOQL();
        system.debug(queryString);
        return new Map<Id, Account_Report_Note__c>((List<Account_Report_Note__c>) Database.query(queryString));
    }
}