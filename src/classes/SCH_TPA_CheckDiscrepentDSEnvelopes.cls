global class SCH_TPA_CheckDiscrepentDSEnvelopes implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_TPA_CheckDiscrepentDSEnvelopes exceptionsReport= new BCH_TPA_CheckDiscrepentDSEnvelopes();
        Database.executebatch(exceptionsReport,1);
    }
}