global class SCH_CSM_ChatterGroupUserDelete Implements Schedulable {
global void execute(SchedulableContext sc)
        {
         BCH_CSM_ChatterGroupDelete deleteBatch = new BCH_CSM_ChatterGroupDelete();
         Database.executebatch(deleteBatch,10);
        }
    
}