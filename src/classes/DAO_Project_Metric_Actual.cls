/**
* This is Project Metric Actual trigger handler class.
* version : 1.0
*/
public class DAO_Project_Metric_Actual extends fflib_SObjectDomain {
    
    /**
* Constructor of this class
* @params sObjectList List<Project_Metric_Actual__c>
*/
    public DAO_Project_Metric_Actual(List<Project_Metric_Actual__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Project_Metric_Actual(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Project Metric Actual trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_PSA_Project_Metric_Actual.validateProjectMetricActualByServiceLine((List<Project_Metric_Actual__c>) Records);
        DAOH_PSA_Project_Metric_Actual.preventDuplicateRecords((List<Project_Metric_Actual__c>) Records);
    }
}
