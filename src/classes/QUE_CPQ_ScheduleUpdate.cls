public class QUE_CPQ_ScheduleUpdate implements Queueable {
    Id budgetId;
    Boolean handleException;
    public string GUID {get; set;}
    Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleListByOliId;
    public static boolean isTestRun = false;
    
    public static string GUID {
        get {
            if(GUID == null) {
                GUID = UTL_LogFactory.Guid;
            }
            return GUID;
        }
        set;
    }
    
    public QUE_CPQ_ScheduleUpdate(Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleListByOliId, Id budgetId, Boolean handleException) {
        this.lineItemScheduleListByOliId = lineItemScheduleListByOliId;
        this.budgetId = budgetId;
        this.handleException = handleException;
    }
    
    public void execute(QueueableContext context)
    {
        SavePoint sp = Database.setSavePoint();
        try {
            Map<Id, Integer> olisCountByOliId = new Map<Id, Integer>();
            Integer totalOlisCount = 0;
            for(Id oliId : lineItemScheduleListByOliId.keySet()){
                totalOlisCount += lineItemScheduleListByOliId.get(oliId).size();
                olisCountByOliId.put(oliId, lineItemScheduleListByOliId.get(oliId).size());
            }
            if (totalOlisCount > 0) {
                CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
                Integer numberOfInstallment = (Integer)cpqSetting.No_of_Installment_for_Schedule_Creation__c;
                Integer k = 200/numberOfInstallment;
                k= k*numberOfInstallment;
                Integer threshold = 0;
                List<OpportunitylineItemSchedule> insertOLISList = new List<OpportunitylineItemSchedule>();
                List<OpportunitylineItemSchedule> leftOLISList = new List<OpportunitylineItemSchedule>();
                
                Map<Id, List<OpportunityLineItemSchedule>> insertOlisMap = new Map<Id, List<OpportunityLineItemSchedule>>();
                Map<Id, List<OpportunityLineItemSchedule>> leftOlisMap = new Map<Id, List<OpportunityLineItemSchedule>>();
                
                if (totalOlisCount > 200) {
                    for(Id oliId : olisCountByOliId.keySet()) {
                        threshold += olisCountByOliId.get(oliId);
                        if(threshold <= k) {
                            insertOlisMap.put(oliId, lineItemScheduleListByOliId.get(oliId));
                        }
                        else {
                            leftOlisMap.put(oliId, lineItemScheduleListByOliId.get(oliId));
                        }
                    } 
                    for(List<OpportunityLineItemSchedule> olis : insertOlisMap.values()){
                        insertOLISList.addAll(olis);
                    }
                    upsert insertOLISList;
                    
                    QUE_CPQ_ScheduleUpdate scheduleUpdate = new QUE_CPQ_ScheduleUpdate(leftOlisMap, budgetId, True ); 
                    Id jobId = System.enqueueJob(scheduleUpdate);    
                    
                } else {
                    for(List<OpportunityLineItemSchedule> olis : lineItemScheduleListByOliId.values()) {
                        insertOLISList.addAll(olis);
                    }
                    upsert insertOLISList;
                    if (String.valueOf(budgetId.getsobjecttype()).equals('Apttus_Proposal__Proposal__c') && (!isTestRun)) {
                        String recordTypeDeveloperName = [SELECT Record_Type_Developer_Name__c FROM Apttus_Proposal__Proposal__c WHERE Id = :budgetId ].Record_Type_Developer_Name__c;
                        if (String.isNotBlank(recordTypeDeveloperName) && recordTypeDeveloperName == CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET) {
                            QUE_CPQ_SyncProtocolNumberToOpp protocolNoUpdate = new QUE_CPQ_SyncProtocolNumberToOpp(budgetId, True ); 
                            Id jobId = System.enqueueJob(protocolNoUpdate);
                        }
                    }
                    if (String.valueOf(budgetId.getsobjecttype()).equals('Quote__c')) {
                        update new Quote__c(Id = budgetId, Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = '');
                    } else {
                        update new Apttus_Proposal__Proposal__c(Id = budgetId,Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = '');
                    }
                }
            }
        } catch(Exception ex) {
            if (handleException) {
                Database.rollback(sp);
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage() + '\n' + ex.getStackTraceString(), CON_CPQ.CPQ, CON_CPQ.CUSTOM, CON_CPQ.DEBUG, Null, budgetId));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                if (String.valueOf(budgetId.getsobjecttype()).equals('Quote__c')) {
                    update new Quote__c(Id = budgetId, Execution_Message__c = (CON_CPQ.FAILED + ' : ' + ex.getMessage() + '\n' + ex.getStackTraceString()));
                } else {
                    update new Apttus_Proposal__Proposal__c(Id = budgetId, Execution_Status__c = CON_CPQ.FAILED, Execution_Message__c = ex.getMessage() + '\n' + ex.getStackTraceString());
                }
                if (!test.isRunningTest()) {
                    throw new CPQ_CustomException(ex.getMessage());
                }
            } else {
                throw ex; 
            } 
        }
    }
}