@IsTest
private class TST_SLT_CallCenter {

    @IsTest
    static void testSelectCallCenterOnUser(){
        CallCenter callCenterRecord = [SELECT Id, Name, InternalName FROM CallCenter WHERE Name LIKE '%Cisco%' LIMIT 1];
        List<User> userList = new SLT_User().selectById(new Set<Id> {UserInfo.getUserId()});
        userList[0].CallCenterId = callCenterRecord.Id;
        userList[0].EmployeeNumber = '070707765';
        update userList;
        Set<Id> callCenterIdSet = new Set<Id>();
        for(User userRecord : userList){
            if(userRecord.CallCenterId != null){
                callCenterIdSet.add(userRecord.CallCenterId);
            }
        }
        
        Test.startTest();
        new SLT_CallCenter().selectCallCenterOnUser(callCenterIdSet);
        Test.stopTest();
    }
    
    @IsTest
    static void testSelectById(){
        List<CallCenter> callCenterRecordList = [SELECT Id, Name, InternalName FROM CallCenter LIMIT 10];
        Set<Id> callCenterIdSet = new Set<Id>();
        for(CallCenter callRecord : callCenterRecordList){
            callCenterIdSet.add(callRecord.Id);
        }

        Test.startTest();
        new SLT_CallCenter().selectById(callCenterIdSet);
        Test.stopTest();
    }
}