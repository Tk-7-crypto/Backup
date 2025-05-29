global class BCH_CSM_UserOutOfOfficeMessage implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date last2Days = Date.today().addDays(-2);
        Date currDate = Date.today();
        if(Test.isRunningTest()) {
            currDate = Date.today().addDays(3);
        }
        String query = 'SELECT Id, UserId, Message FROM OutOfOffice WHERE User.Profile.Name = \'Service User\' AND EndDate <: currDate AND EndDate >=: last2Days '+(Test.isRunningTest()?' LIMIT 2':'');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OutOfOffice> outOfOfficeList) {
        Map<Id, OutOfOffice> userAndOutOfOfficeMap = new Map<Id, OutOfOffice>();
        for(OutOfOffice outOfOfficeRecord: outOfOfficeList) {
            userAndOutOfOfficeMap.put(outOfOfficeRecord.UserId, outOfOfficeRecord);
        }
        if(userAndOutOfOfficeMap != null) {
            updateUserName(userAndOutOfOfficeMap);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    @testVisible
    private static void updateUserName(Map<Id, OutOfOffice> userAndOutOfOfficeMap) {
        List<User> userList = [SELECT Id, LastName FROM User WHERE Id IN : UserAndOutOfOfficeMap.keySet() AND Profile.Name = 'Service User'];
        List<User> userListToBeUpdated = new List<User>();
        if(userList != null && userList.size() > 0) {
            for(User userRecord : userList) {
                if(userAndOutOfOfficeMap.containsKey(userRecord.Id) && userAndOutOfOfficeMap.get(userRecord.Id) != null) {
                    String oldMessage = ' ('+userAndOutOfOfficeMap.get(userRecord.Id).Message+')';
                    String lastName = userRecord.LastName;
                    lastName = lastName.containsIgnoreCase(oldMessage) ? lastName.removeEndIgnoreCase(oldMessage) : lastName;
                    userRecord.LastName = lastName;
                    userListToBeUpdated.add(userRecord);
                }
            }
        }
        if(userListToBeUpdated.size() > 0) {
            try{
                update userListToBeUpdated;
            } catch(Exception ex) {
                system.debug('Error Message = '+ex.getMessage());
            }
        }
    }
}