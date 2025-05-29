public class UTL_TimeTracker {
	
    public static void logEditTime(String sObjectName, String recordId, Decimal startTimeStamp){
        //System.debug('logEditTime '+UserInfo.getUserId()+' : '+sObjectName+' : '+ recordId+' : '+ startTimeStamp);
        
        if(sObjectName == null || recordId == null || startTimeStamp == null)
            return;
        
        Time_Tracker__c tt = new Time_Tracker__c();
        tt.User__c = UserInfo.getUserId();
        tt.SObject_Name__c = sObjectName;
        tt.Time_Spent__c = ((DateTime.now().getTime() - startTimeStamp)/1000.0).setScale(2);
        tt.Record_Id__c = recordId;
        tt.Action__c = 'Edit';
        tt.Start_Time__c = Datetime.newInstance((Long)startTimeStamp);
        tt.End_Time__c = DateTime.now();
        updateLookupField(tt, sObjectName, recordId);
        validateTimeSpentWithThresholdTime(tt);
        insert tt;
    }
    
    public static void logCreateTime(String sObjectName){
        //System.debug('logCreateTime '+UserInfo.getUserId()+' : '+sObjectName);
        
        if(sObjectName == null)
            return;
        
        Time_Tracker__c tt = new Time_Tracker__c();
        tt.User__c = UserInfo.getUserId();
        tt.SObject_Name__c = sObjectName;
        tt.Start_Time__c = Datetime.now();
        tt.Action__c = 'Create';
        insert tt;  
    }
    
    public static void logSaveTime(String sObjectName, String recordId){
        //System.debug('logSaveTime '+UserInfo.getUserId()+' : '+sObjectName+' : '+recordId);
        
        if(sObjectName == null || recordId == null)
            return;
        
        String userId = UserInfo.getUserId();
        List<Time_Tracker__c> ttList = [SELECT Id, Start_Time__c from Time_Tracker__c where SObject_Name__c = :sObjectName AND User__c = :userId AND Record_Id__c = null AND Action__c = 'Create' Order by CreatedDate DESC LIMIT 1];
        
        if(ttList.size() == 1){
            Time_Tracker__c tt = ttList.get(0);
            tt.Record_Id__c = recordId;
            Datetime dt = tt.Start_Time__c;
            tt.Time_Spent__c = ((Datetime.now().getTime() - dt.getTime())/1000.0).setScale(2);
            tt.End_Time__c = DateTime.now();
            updateLookupField(tt, sObjectName, recordId);
            validateTimeSpentWithThresholdTime(tt);
            update tt;
        }
    }
    
    private static void updateLookupField(Time_Tracker__c tt, String sObjectName, String recordId){
        if(sObjectName == 'Opportunity'){
            tt.Opportunity__c = recordId;
        }
    }
    
    private static void validateTimeSpentWithThresholdTime(Time_Tracker__c tt){
        Time_Tracker_Settings__c tts = Time_Tracker_Settings__c.getInstance();
        if(tts.Threshold_Time__c != null ){
            if(tt.Time_Spent__c > tts.Threshold_Time__c){
                tt.Time_Spent__c = tts.Threshold_Time__c;
            }
        }else{
            if(tt.Time_Spent__c > 999999){
                tt.Time_Spent__c = 999999;
            }
        }
    }
    
    /** 
    * This method is used to log an opportunity edit start time.
    * Method is not being used anywhere right now, will be used in future implementation of time tracking
    * @params  sObjectName String API name of sObject
    * @params  recordId String record id of sObject
    * @return  void
    */
    public static void logEditStartTime(String sObjectName, String recordId){
        //System.debug('logEditTime '+UserInfo.getUserId()+' : '+sObjectName+' : '+ recordId+' : '+ startTimeStamp);
        
        if(sObjectName == null || recordId == null)
            return;
        
        Time_Tracker__c tt = new Time_Tracker__c();
        tt.User__c = UserInfo.getUserId();
        tt.SObject_Name__c = sObjectName;
        tt.Record_Id__c = recordId;
        tt.Action__c = 'Edit';
        tt.Start_Time__c = DateTime.now();
        updateLookupField(tt, sObjectName, recordId);
        insert tt;
    }
    
    /** 
    * This method is used to log an opportunity edit end time.
    * Method is not being used anywhere right now, will be used in future implementation of time tracking
    * @params  sObjectName String API name of sObject
    * @params  recordId String record id of sObject
    * @return  void
    */
    public static void logEditEndTime(String sObjectName, String recordId){
        System.debug('logEditEndTime '+UserInfo.getUserId()+' : '+sObjectName+' : '+recordId);
        
        if(sObjectName == null || recordId == null)
            return;
        
        String userId = UserInfo.getUserId();
        List<Time_Tracker__c> ttList = [SELECT Id, Start_Time__c from Time_Tracker__c where SObject_Name__c = :sObjectName AND User__c = :userId AND Record_Id__c = : recordId AND Action__c = 'Edit' AND End_Time__c = null Order by CreatedDate DESC LIMIT 1];
        
        if(ttList.size() == 1){
            Time_Tracker__c tt = ttList.get(0);
            tt.Record_Id__c = recordId;
            Datetime dt = tt.Start_Time__c;
            tt.Time_Spent__c = ((Datetime.now().getTime() - dt.getTime())/1000.0).setScale(2);
            tt.End_Time__c = DateTime.now();
            validateTimeSpentWithThresholdTime(tt);
            update tt;
        }
    }
    
    /** 
    * This method is used to log one or more opportunities edit time, method is intended to log the time for mass edit operation.
    * @params sObjectName String API name of sObject
    * @params recordIds List<String> list of record ids for that particular sObject type
    * @params startTime Datetime time when the mass edit operation started
    * @return  void
    */
    public static void logMassEditTime(String sObjectName, List<String> recordIds, Datetime startTime){
        //System.debug('logEditTime '+UserInfo.getUserId()+' : '+sObjectName+' : '+ recordId+' : '+ startTimeStamp);
        
        if(sObjectName == null || recordIds == null || recordIds.size()==0 || startTime == null)
            return;
        
        Datetime endTime = DateTime.now();
        Decimal averagetimeSpent = ((endTime.getTime() - startTime.getTime())/(1000.0 * recordIds.size())).setScale(2);
        //System.debug('averagetimeSpent : '+ averagetimeSpent);
        List<Time_Tracker__c> tts = new List<Time_Tracker__c>();
        for(String recordId : recordIds){
           	Time_Tracker__c tt = new Time_Tracker__c();
            tt.User__c = UserInfo.getUserId();
            tt.SObject_Name__c = sObjectName;
            tt.Time_Spent__c =  averagetimeSpent;
            tt.Record_Id__c = recordId;
            tt.Action__c = 'Edit';
            tt.Start_Time__c = startTime;
            tt.End_Time__c = endTime;
            updateLookupField(tt, sObjectName, recordId);
            //validateTimeSpentWithThresholdTime(tt); no need to validate with threshold time in case of mass edit
            tts.add(tt);
        }
        insert tts;
    }
}