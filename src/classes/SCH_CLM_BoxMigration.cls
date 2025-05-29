/** 
* Scheduler Class for the migration of folders and files of Box from Contract to Agreement object
*/  
global class SCH_CLM_BoxMigration implements Schedulable {
    global String query;
    
    global SCH_CLM_BoxMigration(String query) {
        this.query = query;
    } 

    global void execute(SchedulableContext sc) {
        database.executebatch(new BCH_CLM_BoxMigration(query), 40);
    }
}