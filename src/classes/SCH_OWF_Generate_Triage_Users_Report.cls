global class SCH_OWF_Generate_Triage_Users_Report implements Schedulable{

	@TestVisible
    String batchMod;
    
    public SCH_OWF_Generate_Triage_Users_Report(String mod)
    {
        batchMod = mod;
    }
    global void execute(SchedulableContext SC) {
    OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_Generate_Triage_Users_Report);
        Integer batchSize;
        if(batchConfig != null && batchConfig.Batch_Size__c != null)
            batchSize = (Integer)batchConfig.Batch_Size__c;
        else
            batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
        BCH_OWF_Generate_Triage_Users_Report batch = new BCH_OWF_Generate_Triage_Users_Report();
        batch.batchMod = batchMod;
        CON_OWF.runFutureJob = false;
        database.executeBatch(batch, batchSize);
    }
}