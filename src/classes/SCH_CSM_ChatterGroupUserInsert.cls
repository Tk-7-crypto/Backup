global class SCH_CSM_ChatterGroupUserInsert Implements Schedulable {
global void execute(SchedulableContext sc)
        {
         BCH_CSM_ChatterGroupInsert insertBatch = new BCH_CSM_ChatterGroupInsert();
         Database.executebatch(insertBatch,10);
        }
    
}