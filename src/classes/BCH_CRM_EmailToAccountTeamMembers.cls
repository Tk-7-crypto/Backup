public class BCH_CRM_EmailToAccountTeamMembers implements Database.Batchable<Sobject> , Database.Stateful   {
    list<String> userEmailIds;
    String htmlBody;
    Boolean isMultiTeamMembersFound;
    String userId;
    public BCH_CRM_EmailToAccountTeamMembers() {
        userEmailIds = new list<String>();
        Set<Id> userIds = new Set<Id>();
        htmlBody = '<table style="border-collapse: collapse;border: 0.1px solid black;"> <tr> <th style="border: 1px solid black;">Account Name</th> <th style="border: 1px solid black;">MDM ID</th> <th style="border: 1px solid black;">User Name</th> <th style="border: 1px solid black;">User Email</th> <th style="border: 1px solid black;">User Role</th> </tr> <tbody>';
        isMultiTeamMembersFound = false;
        List<GroupMember> groupMemberList = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =: CON_CRM.GROUP_ACCOUNT_TEAM_MEMBERS_BIOTECH];
        for (GroupMember gm : groupMemberList) {
            userIds.add(gm.UserOrGroupId);
        }
        Map<Id, User> usersMap = new SLT_User().selectByUserId(userIds, new Set<String>{'Id','Email'});
        for(Id userId : usersMap.keySet()){
            userEmailIds.add(usersMap.get(userId).Email);
            if(userId!=null)
                userId = userId;
        }
    }
    /**
    * start method 
    * @params  Database.BatchableContext context
    * @return  Database.QueryLocator
    */
    public Database.QueryLocator start( Database.BatchableContext context ) {
        String role = CON_CRM.ACCOUNT_TEAMROLE;
        //List<Account> accList =  new SLT_Account().selectByAccTeamMember(new Set<String>{'Id','MDMID__c','Name'}, new Set<String>{'TeamMemberRole','User.Name','User.Email'},CON_CRM.ACCOUNT_TEAMROLE);
        //return accList;
        return Database.getQueryLocator('SELECT Id, MDMID__c, Name,(SELECT AccountId, Id, TeamMemberRole, User.Email, User.Name, UserId FROM AccountTeamMembers WHERE TeamMemberRole=: role ORDER BY CreatedDate ASC NULLS FIRST) FROM Account ORDER BY Name ASC NULLS LAST');
    }
    
    /**
    * start method 
    * @params  Database.BatchableContext context
    * @return  Database.QueryLocator
    */
    public void execute(Database.BatchableContext context, List<sobject> records) {
        for(Account acc: (List<Account>)records){
            if(acc.AccountTeamMembers != null && acc.AccountTeamMembers.size() > 1){
                isMultiTeamMembersFound = true;
                String mdmId = '';
                if(acc.MDMID__c != null){
                    mdmId = acc.MDMID__c;
                }
                htmlBody = htmlBody +'<tr> <td style="border: 1px solid black;" rowspan="'+acc.AccountTeamMembers.size()+'"><a href="'+URL.getOrgDomainUrl().toExternalForm()+'/'+acc.Id+'">'+acc.Name+'</a></td> <td style="border: 1px solid black;" rowspan="'+acc.AccountTeamMembers.size()+'">'+mdmId+'</td>';
                Integer count = 0;
                for(AccountTeamMember atm : acc.AccountTeamMembers){
                    if(count == 0){
                        htmlBody = htmlBody +'<td style="border: 1px solid black;">'+atm.User.Name+'</td><td style="border: 1px solid black;">'+atm.User.Email+'</td><td style="border: 1px solid black;">'+atm.TeamMemberRole+'</td></tr>';
                        count++; 
                    }else{
                        htmlBody = htmlBody +'<tr><td style="border: 1px solid black;">'+atm.User.Name+'</td><td style="border: 1px solid black;">'+atm.User.Email+'</td><td style="border: 1px solid black;">'+atm.TeamMemberRole+'</td></tr>';
                    }   
                }
            }
        }
    }
    public void finish(Database.BatchableContext context) {
        if(isMultiTeamMembersFound){
            htmlBody = htmlBody + '</tbody></table>';
            if(userEmailIds.size() > 0){
                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                message.toEmails = userEmailIds;
                message.subject = CON_CRM.IQVIA_ACCOUNT_TEAMMEMBER_BIOTECH;
                message.staticContent = htmlBody;
                message.whatId = userId;
                UTL_CRM_SendEmail.sendEmailThroughWorkflow(new List<UTL_CRM_SendEmail.MessageWrapper>{message});
            }
        }
    }
}