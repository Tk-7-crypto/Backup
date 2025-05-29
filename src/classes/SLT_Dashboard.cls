/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Dashboard
 */
public class SLT_Dashboard extends fflib_SObjectSelector{
    /**
     * This method used to get field list of sobject
     */

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Dashboard.Id,
            Dashboard.Title,
            Dashboard.Description
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Dashboard.sObjectType;
    }
    
    /**
     * This method used to get Dashboard by Id
     * @return  List<Dashboard>
     */
    public List<Dashboard> selectById(Set<ID> idSet) {
        return (List<Dashboard>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Dashboard by Id
     * @return  Map<Id, Dashboard>
     */
      public Map<String, Dashboard> getDashboardById(Set<String> idSet, Set<String> fieldSet) {
        return new Map<String, Dashboard>((List<Dashboard>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
     /**
     * This method used to get Dashboard by ids
     * @return  List<Dashboard>
     */
    /** public List<Dashboard> selectById(List<String> dashboardIds) {
         return [SELECT Title, Id, Description FROM Dashboard WHERE Id IN : dashboardIds];
    }*/
}