public class SLT_Entitlement extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Entitlement() {
        super(false, true, true);
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
        return Entitlement.sObjectType;
    }
    
    /**
     * This method used to get Entitlement by Id
     * @return  Map<Id, User>
     */
    public Map<Id, Entitlement> selectByEntitlementId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Entitlement>((List<Entitlement>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    public List<Entitlement> selectByAccountId(Set<Id> idSet,Set<Id> eidSet) {
        return Database.query('Select Status, StartDate, Id, EndDate, AccountId, Type, BusinessHoursId From Entitlement Where AccountId IN: idSet And ((StartDate <= Today and Status =\'Active\') or (Id IN: eidSet)) and Type IN (\'R&D\',\'DATA\',\'DATA E-SERVICE\',\'TECHNO\',\'TECHNOCC\',\'TECHCentris\',\'TECH IDP/MDM\',\'TECHSmartSolve\',\'TECH IQVIA HIS\',\'TECHNO SMART IT\',\'TECH ROCHE\',\'TECH Orchestrated Analytics\',\'TECH Dashboard & Reports\')');
    }
}