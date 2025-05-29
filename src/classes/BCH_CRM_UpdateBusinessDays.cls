/*
 * Version       : 1.0
 * Description   : This Batch Class to update Current Stage Business Days on Contract Stage Detail Object
 */
public class BCH_CRM_UpdateBusinessDays  implements Database.Batchable<Sobject> , Database.Stateful{
    
    BusinessHours businesshourRecord;

    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        businesshourRecord = [SELECT Id, Name FROM BusinessHours WHERE Name = 'US East BH' and isActive = true];
        return Database.getQueryLocator([SELECT Id, Status, (SELECT Id, Contract_Number__c, CreatedDate, Status__c FROM Contract_Stage_Details__r ORDER BY CreatedDate DESC LIMIT 1) FROM Contract WHERE ActivatedDate = NULL]);
    }
    
    /**
     * execute method 
     * @params  Database.BatchableContext context
     * @params  List<Contract> records
     * @return  void
     */
    public void execute(Database.BatchableContext context, List<Contract> contractList) {
        List<Contract_Stage_Detail__c> CSDsToUpdate = new List<Contract_Stage_Detail__c>();
        for(Contract cntrt : contractList) {
            if(cntrt.Contract_Stage_Details__r.size() > 0 && cntrt.Contract_Stage_Details__r[0] != null){
                Contract_Stage_Detail__c stageDetail = cntrt.Contract_Stage_Details__r[0];
                Long businessMiliSeconds = BusinessHours.diff(businesshourRecord.Id, stageDetail.CreatedDate, System.Now());
                Integer businessDays = (Integer)(businessMiliSeconds/(1000*60*60*9));
                stageDetail.Business_Days_in_Stage__c = businessDays;
                CSDsToUpdate.add(stageDetail);
            }
        }
        if(CSDsToUpdate.size() > 0){
            update CSDsToUpdate;
        }
            
    }
    
    /**
     * finish method 
     * @params  Database.BatchableContext context
     * @return  void
     */
    public void finish(Database.BatchableContext context) {
       
    }
}