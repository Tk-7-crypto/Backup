/**
* @Author: Vikram Singh Fartyal on 24Jan2017
* Class: TPA_Schedular_Daily_Exception_Rpt_Local
* Purpose:  generates a custom reports on daily basis to trak the dicrepancy in a request flow, DiscrepentDSEnvopes and mail as an attachment to the local team (ER-3434).
* */
global class SCH_TPA_Daily_Exception_Rpt_Local implements Schedulable {
   
    global void execute(SchedulableContext sc) {
        
        BCH_TPA_AutoWeeklyExceptionReport bchObj = new BCH_TPA_AutoWeeklyExceptionReport('check TPA requests');
        Database.executeBatch(bchObj,1);
        
        BCH_TPA_CheckDiscrepentDSEnvelopes exceptionsReport= new BCH_TPA_CheckDiscrepentDSEnvelopes();
        Database.executebatch(exceptionsReport,1);
    }
}