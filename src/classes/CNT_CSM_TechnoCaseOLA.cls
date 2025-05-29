public class CNT_CSM_TechnoCaseOLA {
    
    public class EXT_CSM_OLATime {
        
        @AuraEnabled
        public decimal elapsedTime{set; get;}
        @AuraEnabled
        public decimal remainingTime{set;get;}
        @AuraEnabled
        public String priority{set;get;}
        @AuraEnabled
        public boolean isCompleted{set;get;}
        @AuraEnabled
        public decimal timeleftinDay{set;get;}
        @AuraEnabled
        public boolean isOutOfBH{set;get;}
    }
    
    public static Map<String, CaseOLASettings__c> olaS;
    public static Map<String, CaseOLASettings__c> getCSMSettingData() {
        if(olaS == null) {
            olaS = new Map<String, CaseOLASettings__c>();
            for(CaseOLASettings__c o : CaseOLASettings__c.getall().values()) {
                olaS.put(o.Name , o);
            }
        }
        return olaS;
    }
    
    @AuraEnabled
    public static String getCasePriority(String caseId){
        String priority = '';
        if(caseId != null){
            List<Case> cList = new SLT_case().selectByCaseIdList(new Set<ID> {caseId}, new Set<String> {'Id','Priority'});
            if(cList != null && !cList.isEmpty()){
                priority =  cList[0].Priority;
            }
        }
        return priority;
    }

    @AuraEnabled
    public static EXT_CSM_OLATime getCaseCurrentQueueCompleted(String caseId){
        
        EXT_CSM_OLATime ola = new EXT_CSM_OLATime();
        String bhId = null; 
        DateTime dtStart,dtEnd;
        decimal targetM ,elapsed = 0;
        BusinessHours bhSoql = null;
        List<CaseOLA__c> coList = Database.query('SELECT Id,Priority__c,Case__c,Case__r.RecordTypeName__c,IsActive__c,CreatedDate,QueueId__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c,Elapsed_OLA_Time__c From CaseOLA__c Where Case__c =:caseId and IsActive__c = true');
        if(coList != null && !coList.isEmpty()){
            olaS = getCSMSettingData();
            dtStart = coList[0].CreatedDate;
            dtEnd = System.now();
            if(coList != null && !coList.isEmpty() && coList[0].CompletionOLADate__c != null && coList[0].Elapsed_OLA_Time__c != null){
                ola.elapsedTime = coList[0].Elapsed_OLA_Time__c;
                ola.isCompleted = true;    
            }else if(coList[0].QueueId__c != null ){
                ola.isCompleted = false;
                List<Queue_User_Relationship__c> queueList = new SLT_QueueUserRelationshipC().selectByGroupOLA(new Set<Id> {coList[0].QueueId__c});
                if(queueList != null){
                    if(!queueList.isEmpty() && queueList[0] != null && queueList[0].Business_Hours__c != null){
                        bhId = queueList[0].Business_Hours__c;
                        bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Id =: bhId];
                    }else{
                        bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Name = 'Default' and IsDefault = true];
                        bhId = bhSoql.Id;
                    }
                }
                elapsed = BusinessHours.diff(bhId, dtStart, dtEnd)/60000;
                ola.elapsedTime = elapsed;
                ola.priority = coList[0].Priority__c;
                String rtName = coList[0].Case__r.RecordTypeName__c;
                if(olaS.containsKey(rtName + ' ' + ola.priority)){
                    targetM = olaS.get(rtName + ' ' + ola.priority).Target_Time__c;
                    decimal rmin = targetM - elapsed;
                    if(math.signum(rmin) != -1){
                        ola.remainingTime = rmin;
                    }else{
                        ola.remainingTime = 0;
                    }
                }
                ola.isOutOfBH = BusinessHours.isWithin(bhId, dtEnd);
                Timezone tz = Timezone.getTimeZone(bhSoql.TimeZoneSidKey);
                if(bhSoql.get(dtEnd.format('EEEE')+'EndTime') != null){
                    String dtTZEnd = dtEnd.format('yyyy-MM-dd\'T\'HH:mm:ss',tz.getID());
                    dtTZEnd += '.000Z'; 
                    dtTZEnd = '"'+dtTZEnd+'"';
                    Datetime dtEndTd =  (Datetime)JSON.deserialize(dtTZEnd, Datetime.class);
                    Date dEnd = dtEndTd.date();
                    if(String.valueOf(bhSoql.get(dtEnd.format('EEEE')+'EndTime')) == '00:00:00.000Z'){
                        Datetime dtCon = Datetime.newInstanceGmt(dEnd, Time.newInstance(23, 59, 59, 999));
                        ola.timeleftinDay = ((dtCon.getTime() - dtEndTd.getTime())/60000);
                    }else{
                        String[] str = String.valueOf(bhSoql.get(dtEnd.format('EEEE')+'EndTime')).removeEnd('.000Z').split(':');
                        Datetime dtCon = Datetime.newInstanceGmt(dEnd, Time.newInstance(Integer.valueOf(str[0]), Integer.valueOf(str[1]), Integer.valueOf(str[2]), 999));
                        ola.timeleftinDay = ola.isOutOfBH ? ((dtCon.getTime() - dtEndTd.getTime())/60000) : 0;
                    }
                    
                }
            }
            
            
        }else{
            ola.elapsedTime = 0;
            ola.remainingTime= 0;
            ola.timeleftinDay = 0;
        }
        return ola; 
    }
    
    public static String pad(integer num, integer size) {
        String s = '0000' + num;
        return s.substring(s.length() - size);
    }
}
