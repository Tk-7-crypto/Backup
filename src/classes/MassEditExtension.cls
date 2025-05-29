public with sharing class MassEditExtension {
    public ApexPages.StandardSetController setController{get;set;}  
    private String objectName;
    public String userCountry{get; set;}
    public Boolean isCanadaUser{get; set;}
    public Boolean hasSalesWithBidHistoryPermission{get; set;}
    private Set<String> massEditActivityFields = new Set<String>{'Status__c', 'ActivityOwner__c', 'Description__c', 'PassFail__c', 
        'LOS__c', 'Type__c', 'EscalationType__c', 'RandD_Location__c', 'Email_Categorization__c'};
    private Datetime startTime;
            
    public MassEditExtension(ApexPages.StandardSetController setCon){
        startTime = DateTime.now();
        setController = setCon;
        List<SObject> records = setController.getSelected();
        objectName = records.getSObjectType() != null ? records.getSObjectType().getDescribe().getName() : null;
        String userId = UserInfo.getUserId();
        List<User> userList = new SLT_User().getUserById(new Set<Id> {userId}, new Set<String>{'User_Country__c', 'Profile.Name'});
        userCountry = userList[0].User_Country__c ;
        String profile = userList[0].Profile.Name;
        hasSalesWithBidHistoryPermission = FeatureManagement.checkPermission('Sales_with_Bid_History');
        isCanadaUser = userCountry == 'Canada' && (profile =='Sales User' || profile =='Commercial Operations User' || profile == 'Marketing User IQVIA');
    }
    
    public PageReference save(){
        if(objectName != null && objectName == 'Activity__c') {
            updateActivityOwner();            
        }
        PageReference prf = setController.save();
        if(prf != null){
            List<String> recordIds = new List<String>();
            for(SObject record : setController.getSelected()){
                recordIds.add(record.Id);
            }
            UTL_TimeTracker.logMassEditTime(objectName, recordIds, startTime);
          	startTime = DateTime.now();  
        }
        return null;
    }
    
    private void updateActivityOwner() {
        List<User> userList;
        if(Test.isRunningTest()) {
            userList = [SELECT Id FROM User WHERE Name LIKE :CON_CSM.S_SYSTEM AND IsActive = True LIMIT 1];
        }
        else {
            userList = new SLT_User().selectUserByName(CON_CSM.S_SYSTEM);
        }
        User systemUser = userList != null && userList.size() > 0 ? userList[0] : null;
        
        Set<Id> activityIdSet = new Set<Id>();
        List<Activity__c> editedActivities = (List<Activity__c>)setController.getSelected();
        for(Activity__c activity: editedActivities) {
            activityIdSet.add(activity.Id);
        }
        
        if(activityIdSet != null && !activityIdSet.isEmpty()) {
            Map<Id, Activity__c> oldActivityMap = new SLT_ActivityC().selectByActivityId(activityIdSet, massEditActivityFields);             
            for(Activity__c activity: editedActivities) {
                if(oldActivityMap != null && oldActivityMap.containsKey(activity.Id) && oldActivityMap.get(activity.Id) != null &&
                   oldActivityMap.get(activity.Id).ActivityOwner__c != null && systemUser != null && 
                   oldActivityMap.get(activity.Id).ActivityOwner__c == systemUser.Id) {
                    for (String field : massEditActivityFields) { 
                        String fieldName = field.toLowerCase();
                        try { 
                            if(activity.get(fieldName) != oldActivityMap.get(activity.Id).get(fieldName)) {
                                activity.ActivityOwner__c = UserInfo.getUserId();
                                break;
                            }
                        } 
                        catch (Exception e) {
                            System.debug('Error: ' + e); 
                        } 
                    } 
                }            
            } 
        }
    }
}