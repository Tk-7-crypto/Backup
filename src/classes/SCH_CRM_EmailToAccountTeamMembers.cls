global class SCH_CRM_EmailToAccountTeamMembers implements Schedulable {
    global void execute(SchedulableContext sc) {
        BCH_CRM_EmailToAccountTeamMembers b = new BCH_CRM_EmailToAccountTeamMembers();
        Database.executebatch(b);
    }
}