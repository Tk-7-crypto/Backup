global class BCH_CSM_CompleteCaseOLA  implements Database.Batchable<sObject>{
    global String[] errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id,Priority__c,Case__c,Case__r.RecordTypeName__c,IsActive__c,CreatedDate,QueueId__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c,Elapsed_OLA_Time__c,OLAEndDate__c  From CaseOLA__c Where OLAEndDate__c != null and CompletionOLADate__c = null and IsActive__c = true and OLAEndDate__c <= TODAY LIMIT 2000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CaseOLA__c> coList){
        Map<Id,Id> qMap = new Map<Id,Id>();
        Set<Id> qSet = new Set<Id>();
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        String bhId = null; 
        DateTime dtStart,dtEnd;
        Map<String, CaseOLASettings__c> olaS = CNT_CSM_TechnoCaseOLA.getCSMSettingData();
        for(CaseOLA__c o : coList){
            qSet.add(o.QueueId__c);
        }
        
        List<CaseOLA__c> uLst = new List<CaseOLA__c>();
        Map<Id,String> mapE = new Map<Id,String>();
        if(coList != null && !coList.isEmpty()){
            queueList = new SLT_QueueUserRelationshipC().selectByGroupOLA(qSet);
            BusinessHours bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Name = 'Default' and IsDefault = true];
            for(Queue_User_Relationship__c q : queueList ){
                qMap.put(q.Group_Id__c, q.Business_Hours__c);
            }
            for(CaseOLA__c o : coList){
                if(qMap.containsKey(o.QueueId__c) ){
                    bhId = qMap.get(o.QueueId__c);
                }else{
                    bhId = bhSoql.Id; 
                }
                dtStart = o.CreatedDate;
                dtEnd = System.now();
                o.Elapsed_OLA_Time__c = BusinessHours.diff(bhId, dtStart, dtEnd)/1000/60;
                o.CompletionOLADate__c = dtEnd;
                uLst.add(o);
                decimal munites = o.Elapsed_OLA_Time__c;
                if(olaS.containsKey(o.Case__r.RecordTypeName__c + ' ' + o.priority__c)){
                    o.StandardOLAviolated__c = math.signum(olaS.get(o.Case__r.RecordTypeName__c + ' ' + o.priority__c).Target_Time__c - munites) == -1 ? true : false;
                }
                decimal dhours = o.Elapsed_OLA_Time__c/60;
                integer ihours = integer.valueOF(math.floor(dhours));
                decimal remainderHours = dhours- ihours;
                decimal dMinutes = math.round(remainderHours * 60);
                integer iMinutes = integer.valueOf(math.floor(dMinutes));
                decimal remainderMinutes = dMinutes - iMinutes;
                mapE.put(o.Case__c,pad(ihours,2) +':'+  pad(iMinutes,2));
            }
            if(!uLst.isEmpty()){
                try{
                    update uLst;    
                }catch(System.DmlException e){}
                
            }
        }
        Set<Id> caseIds = mapE.keySet();
        if(caseIds != null){
        List<Case> uCases = Database.query('select Id,OLA_Elapsedtime__c, Status From Case where Id in:caseIds and Status not in (\'Closed\')');
        try {
            for(Case c : uCases){
                if(mapE.containsKey(c.Id)){
                    c.OLA_Elapsedtime__c = mapE.get(c.Id);
                }
            }
            if(!ucases.isEmpty()){
              update ucases;  
            }
            
        } catch(Exception e) {
            errors.add(e.getLineNumber()+' - ' + e.getMessage());
        }
        }
    }
    
    public static String pad(integer num, integer size) {
        String s = '0000' + num;
        return s.substring(s.length() - size);
    }
    global void finish(Database.BatchableContext BC){
        
        
    }
    
}