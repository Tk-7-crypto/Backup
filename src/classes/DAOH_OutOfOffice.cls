public class DAOH_OutOfOffice {
    public static void updateUserNameWithMessage(List<OutOfOffice> outOfficeRecordList, Map<Id, OutOfOffice> oldMap) {
        Set<Id> setOfUserId = new Set<Id>();
        for (OutOfOffice outOfOfficeRecord : outOfficeRecordList) {
            setOfUserId.add(outOfOfficeRecord.UserID);
        }
        if(!setOfUserId.isEmpty()) {
            Id serviceUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Service User'][0].Id;
            List<User> usersToUpdate = new List<User>();
            Map<Id, User> userMap = new SLT_User().selectByUserId(setOfUserId, new Set<String>{'Id', 'LastName', 'ProfileId'});
            for(OutOfOffice outOfOfficeRecord : outOfficeRecordList) {
                if(userMap != null && userMap.containsKey(outOfOfficeRecord.UserID) && userMap.get(outOfOfficeRecord.UserID) != null) {
                    User userRecord = userMap.get(outOfOfficeRecord.UserID);
                    if(userRecord.ProfileId == serviceUserProfileId) {
                        String lastName = userRecord.LastName;
                        if(Trigger.isInsert) {
                            lastName += ' ('+outOfOfficeRecord.Message+')';
                        }
                        else if(Trigger.isUpdate && oldMap != null && oldMap.containsKey(outOfOfficeRecord.Id) && oldMap.get(outOfOfficeRecord.Id) != null ) {
                            String oldMessage = ' ('+oldMap.get(outOfOfficeRecord.Id).Message+')';
                            String newMessage = ' ('+outOfOfficeRecord.Message+')';
                            lastName = lastName.containsIgnoreCase(oldMessage) ? lastName.replace(oldMessage, newMessage) : lastName+newMessage;
                        } 
                        else if(Trigger.isDelete && oldMap != null && oldMap.containsKey(outOfOfficeRecord.Id) && oldMap.get(outOfOfficeRecord.Id) != null) {
                            String oldMessage = ' ('+oldMap.get(outOfOfficeRecord.Id).Message+')';
                            lastName = lastName.containsIgnoreCase(oldMessage) ? lastName.removeEndIgnoreCase(oldMessage) : lastName;
                        }
                        userRecord.LastName = lastName;
                        usersToUpdate.add(userRecord);
                    }
                }
            }
            if(usersToUpdate != null && usersToUpdate.size() > 0) {
                update usersToUpdate;
            }
        }
    }
}