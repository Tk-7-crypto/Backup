global class BCH_CSM_CaseUpdateOLAElapsed implements Database.Batchable<sObject>{
    global String[] errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = 'SELECT Id,Priority__c,Case__c,Case__r.Status,Case__r.RecordTypeName__c,IsActive__c,CreatedDate,QueueId__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c,Elapsed_OLA_Time__c,OLAEndDate__c  From CaseOLA__c Where OLAEndDate__c != null and CompletionOLADate__c = null and IsActive__c = true and OLAEndDate__c > TODAY LIMIT 2000';
        String query = 'SELECT Id,Priority__c,Case__c,Case__r.Status,Case__r.RecordTypeName__c,IsActive__c,CreatedDate,QueueId__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c,Elapsed_OLA_Time__c,OLAEndDate__c  From CaseOLA__c Where OLAEndDate__c != null and CompletionOLADate__c = null and IsActive__c = true LIMIT 2000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CaseOLA__c> coList){
        Map<Id,Id> qMap = new Map<Id,Id>();
        Set<Id> qSet = new Set<Id>();
        Set<Id> qcompletSet = new Set<Id>();
        Map<Id,Id> caseMap = new Map<Id,Id>();
        Map<Id,Decimal> caseMapTime = new Map<Id,Decimal>();
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        String bhId = null; 
        DateTime dtStart,dtEnd;
        DateTime dt = System.now();
        List<CaseOLA__c> uLst = new List<CaseOLA__c>();
        Map<Id,String> mapE = new Map<Id,String>();
        Map<Id,List<Id>> caseMaps = new Map<Id,List<Id>>();
        List<Id> usrIds = null;
        List<CaseOLA__c> cuOlaElapsed = new List<CaseOLA__c>();
        List<CaseOLA__c> completCaseOLASet = new List<CaseOLA__c>();
        olaS = getCSMSettingData();
        for(CaseOLA__c o : coList){
            if(o.OLAEndDate__c > System.today()){
                qSet.add(o.QueueId__c);
                cuOlaElapsed.add(o);
            }else if(o.OLAEndDate__c <= System.today()){
                qcompletSet.add(o.QueueId__c);
                completCaseOLASet.add(o);
            }
            
        }
        if(cuOlaElapsed != null && !cuOlaElapsed.isEmpty()){
            queueList = new SLT_QueueUserRelationshipC().selectByGroupOLA(qSet);
            BusinessHours bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Name = 'Default' and IsDefault = true];
            for(Queue_User_Relationship__c q : queueList ){
                qMap.put(q.Group_Id__c, q.Business_Hours__c);
            }
            for(CaseOLA__c o : cuOlaElapsed){
                if(qMap.containsKey(o.QueueId__c) ){
                    bhId = qMap.get(o.QueueId__c);
                }else{
                    bhId = bhSoql.Id; 
                }
                dtStart = o.CreatedDate;
                dtEnd = System.now();
                o.Elapsed_OLA_Time__c = BusinessHours.diff(bhId, dtStart, dtEnd)/1000/60;
                uLst.add(o);
                decimal munites = o.Elapsed_OLA_Time__c;
                decimal dhours = o.Elapsed_OLA_Time__c/60;
                integer ihours = integer.valueOF(math.floor(dhours));
                decimal remainderHours = dhours- ihours;
                decimal dMinutes = math.round(remainderHours * 60);
                integer iMinutes = integer.valueOf(math.floor(dMinutes));
                decimal remainderMinutes = dMinutes - iMinutes;
                mapE.put(o.Case__c,pad(ihours,2) +':'+  pad(iMinutes,2));
                if(olaS.containsKey(o.Case__r.RecordTypeName__c + ' ' + o.Priority__c)){
                    decimal targetM = olaS.get(o.Case__r.RecordTypeName__c + ' ' + o.Priority__c).Target_Time__c;
                    decimal rmin = targetM - munites;
                    if(o.Case__c != null && o.Case__r.Status != CON_CSM.S_CLOSED && ((rmin > 0 && rmin < 120) || (rmin > 121 && rmin < 240)) && (o.Priority__c == CON_CSM.S_PT1 || o.Priority__c == CON_CSM.S_PT2)){
                        caseMap.put(o.Case__c,o.QueueId__c);
                        caseMapTime.put(o.Case__c,rmin);
                    }
                    
                }
                
                
            }
            if(!uLst.isEmpty()){
                try{
                    update uLst;    
                }catch(System.DmlException e){}
                
            }
            
            List<Queue_User_Relationship__c> userEmails = new SLT_QueueUserRelationshipC().selectByOLAQueueUserEmails(caseMap.values());
            Set<Id> allUserIds = new Set<Id>();
            for(Id caseId : caseMap.keySet()){
                usrIds = new List<Id>();      
                for(Queue_User_Relationship__c q : userEmails ){
                    if(q.Group_Id__c == caseMap.get(caseId))
                        usrIds.add(q.User__c);
                    allUserIds.add(q.User__c);
                }
                caseMaps.put(caseId, usrIds);
            }
            if(caseMaps != null && !caseMaps.isEmpty()){
                Set<Id> caseSet = caseMaps.keySet();
                String senderId = null;
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                List<Case> uCases = Database.query('select Id,CaseNumber,Subject,Status,Priority,AssetName__c,Origin,OwnerId,Owner.Name, Account_Name_Article__c,AccountCountry__c,ContactId,RecordTypeName__c From Case where Id in:caseSet');
                CSM_Case_Details_Global_Setting__c caseOla1 = CSM_Case_Details_Global_Setting__c.getValues('Case OLA Reminder1');
                CSM_Case_Details_Global_Setting__c caseOla4 = CSM_Case_Details_Global_Setting__c.getValues('Case OLA Reminder4');
                CSM_Case_Details_Global_Setting__c orgWide = CSM_Case_Details_Global_Setting__c.getValues('Org Wide CSM');
                List<Messaging.RenderEmailTemplateBodyResult> resList = new List<Messaging.RenderEmailTemplateBodyResult>();
                List<Messaging.RenderEmailTemplateBodyResult> resListSubject = new List<Messaging.RenderEmailTemplateBodyResult>();
                Messaging.SingleEmailMessage mailMessage = null;
                string emailHtml = '<hr color=#3399FF size=3 width="100%" align=left>'+
                    '<font color="{!colors}" <b>Case Number <a href="{!Case.Link}">{!Case.CaseNumber}</a> with priority {!Case.Priority} OLA – Internal Response Time about to Breached with in {!times} hours</b></font>'+
                    '<ul><li><font face="Arial, Times" size="2"><b>Case Title:</b>{!Case.Subject}</font></li>'+
                    '<li><font face="Arial, Times" size="2"><b>Account Name:</b>{!Case.Account_Name_Article__c}</font></li>'+
                    '<li><font face="Arial, Times" size="2"><b>Case Owner:</b>{!Case.OwnerFullName}</font></li>'+
                    '<li><font face="Arial, Times" size="2"><b>Status:</b>{!Case.Status}</font></li>'+
                    '<li><font face="Arial, Times" size="2"><b>Priority:</b>{!Case.Priority}</font></li>'+
                    '<li><font face="Arial, Times" size="2"><b>Product:</b>{!Case.Asset}</font></li>'+
                    '<li><font face="Arial, Times" size="2"><b>Case Origin:</b>{!Case.Origin}</font></li></ul>'+
                    '<b>Please review the Case and take appropriate action.</b><br>'+
                    '<p>Click on the link to access the case: {!Case.Link}</p>'+
                    '<font color=red>** PLEASE DO NOT REPLY TO THIS AUTOMATED EMAIL **</font>'+
                    '<hr color=#3399FF size=3 width="100%" align=left>';
                Map<Id, User> userMap = new SLT_User().selectByUserId(allUserIds, new Set<String>{'Id', 'Case_Comment_Work_Note__c'});
                for(Case cs : uCases){
                    if(caseMaps.containsKey(cs.Id) && !caseMaps.get(cs.Id).isEmpty()){
                        for(Id userId : caseMaps.get(cs.Id)){
                            if(userMap.get(userId) != null && userMap.get(userId).Case_Comment_Work_Note__c != null && userMap.get(userId).Case_Comment_Work_Note__c.contains('OLA Alert - Email')){
                                mailMessage = new Messaging.SingleEmailMessage();
                                if(caseMapTime.get(cs.Id) > 0 && caseMapTime.get(cs.Id) < 120 && caseOla1 != null && caseOla1.Component_Id__c != null) {
                                    //mailMessage.setTemplateId(caseOla1.Component_Id__c);
                                    mailMessage.setSubject('Account Name: '+cs.Account_Name_Article__c+' - '+cs.AccountCountry__c+' - '+cs.CaseNumber+' OLA – Internal Response Time about to Breached with in 2 hours');
                                    emailHtml = emailHtml.replace('{!times}','2');
                                    emailHtml = emailHtml.replace('{!colors}','red');
                                }else if(caseMapTime.get(cs.Id) > 121 && caseMapTime.get(cs.Id) < 240 && caseOla4 != null && caseOla4.Component_Id__c != null) {
                                    //mailMessage.setTemplateId(caseOla4.Component_Id__c);
                                    mailMessage.setSubject('Account Name: '+cs.Account_Name_Article__c+' - '+cs.AccountCountry__c+' - '+cs.CaseNumber+' OLA – Internal Response Time about to Breached with in 4 hours');
                                    emailHtml = emailHtml.replace('{!times}','4');
                                    emailHtml = emailHtml.replace('{!colors}','orange');
                                }else{
                                    continue;
                                }
                                emailHtml = emailHtml.replace('{!Case.CaseNumber}',cs.CaseNumber);
                                if(cs.Subject != null) emailHtml = emailHtml.replace('{!Case.Subject}',cs.Subject);
                                if(cs.Status != null) emailHtml = emailHtml.replace('{!Case.Status}',cs.Status);
                                if(cs.Account_Name_Article__c != null) emailHtml = emailHtml.replace('{!Case.Account_Name_Article__c}',cs.Account_Name_Article__c);
                                if(cs.OwnerId != null) emailHtml = emailHtml.replace('{!Case.OwnerFullName}',cs.Owner.Name);
                                if(cs.Priority != null) emailHtml = emailHtml.replace('{!Case.Priority}',cs.Priority);
                                if(cs.AssetName__c != null) emailHtml = emailHtml.replace('{!Case.Asset}',cs.AssetName__c);
                                if(cs.Origin != null) emailHtml = emailHtml.replace('{!Case.Origin}',cs.Origin);
                                emailHtml = emailHtml.replace('{!Case.Link}',URL.getOrgDomainUrl().toExternalForm()+'/'+cs.Id);
                                resList = Messaging.renderEmailTemplate(null, cs.id, new List<String> {emailHtml});
                                mailMessage.setHtmlBody(resList[0].getMergedBody());
                                if(orgWide != null && orgWide.Component_Id__c != null) {
                                    mailMessage.setOrgWideEmailAddressId(orgWide.Component_Id__c);
                                }
                                mailMessage.setCharset('UTF-8');
                                mailMessage.setSaveAsActivity(false);
                                mailMessage.setTargetObjectId(userId);
                                //mailMessage.setWhatId(cs.Id);
                                emailList.add(mailMessage);
                            }
                        }
                    }
                    
                }
                
                if(emailList != null && emailList.size() > 0) {
                    try{
                        Messaging.sendEmail(emailList);
                    }
                    catch(Exception ex){
                        System.debug('Mail Exception: '+ex.getMessage());
                    }
                }
            }
        }else if(completCaseOLASet != null && !completCaseOLASet.isEmpty()){
            
            queueList = new SLT_QueueUserRelationshipC().selectByGroupOLA(qcompletSet);
            BusinessHours bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Name = 'Default' and IsDefault = true];
            for(Queue_User_Relationship__c q : queueList ){
                qMap.put(q.Group_Id__c, q.Business_Hours__c);
            }
            for(CaseOLA__c o : completCaseOLASet){
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
        BCH_CSM_AbandonedDuplicateCases batch = new BCH_CSM_AbandonedDuplicateCases();
        database.executeBatch(batch, 1);
        
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
    
}