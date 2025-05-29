global class BCH_CRM_DeleteSurvey implements Database.Batchable<Sobject>{
    public Date datebefore7Days;
    /**
    * start method 
    * @params  Database.BatchableContext context
    * @return  Database.QueryLocator
    */
    public BCH_CRM_DeleteSurvey(){
        datebefore7Days = Date.today().addDays(-7);
    }
    global Database.QueryLocator start( Database.BatchableContext context ) {
        return Database.getQueryLocator([Select Id from Client_Sat_Survey__c where Send_Survey__c = null AND Survey_Send_Date__c <=: datebefore7Days]);
        
    }
    /**
    * execute method 
    * @params  Database.BatchableContext context
    * @return  List<Client_Sat_Survey__c> scope
    * Used to remove surveys
    */
    global void execute(Database.BatchableContext context, List<Client_Sat_Survey__c> scope){
        Database.delete(scope, false);
    }
    
    global void finish(Database.BatchableContext info){
       
    }
}