/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Report
 */
public class SLT_Report extends fflib_SObjectSelector{
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Report.Id,
            Report.Name,
            Report.Description
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Report.sObjectType;
    }
    
    /**
     * This method used to get Report by Id
     * @return  List<Report>
     */
    public List<Report> selectById(Set<ID> idSet) {
        return (List<Report>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Report by Id
     * @return  Map<Id, Report>
     */
      public Map<String, Report> getReportById(Set<String> idSet, Set<String> fieldSet) {
        return new Map<String, Report>((List<Report>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get  Report by ids
     * @return  List<Report>
     */
    public List<Report> selectById(List<String> reportIds) {
         return [SELECT Name, Id, Description FROM Report WHERE Id IN : reportIds];
    }
    
    /**
     * This method used to get Private Report
     * @return  List<Report>
     */
    public List<Report> selectPrivateReports(String userId) {
         return [SELECT Name, Id, Description FROM Report USING SCOPE allPrivate Where OwnerId=:userId];
    }
    
    /**
     * This method used to get Report by developer name
     * @return Report
     */
    public Report selectReportByDeveloperName(String reportDeveloperName) {
        return [SELECT Name, Id, Description FROM Report WHERE developerName=:reportDeveloperName]; 
    }
    
}