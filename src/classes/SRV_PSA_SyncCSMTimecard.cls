public without sharing class SRV_PSA_SyncCSMTimecard {
    public static string serviceSession='';
    public static integer allRecordCount=0;
    public static integer failedRecordCount=0;
    public static String getTimecardApiRequest(List<TimeSheet__c> timeSheetList){
        //Get data from query here and create json string
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject();     
        gen.writeFieldName('timecardrequest');
        gen.writeStartArray();
        for(TimeSheet__c timeSheet : timeSheetList){
            gen.writeStartObject();
            gen.writeStringField('SourceTimecardId', timeSheet.Id);
            gen.writeStringField('ProjectId', timeSheet.ProjectId__c);
            gen.writeStringField('AssignmentId', timeSheet.AssignmentId__c);
            if(timeSheet.MilestoneId__c != null){
            gen.writeStringField('MileStoneId', timeSheet.MilestoneId__c);
            }
            if(timeSheet.Comment__c != null){
            gen.writeStringField('Comment', timeSheet.Comment__c);
            }
            gen.writeDateTimeField('TimeCardDate', timeSheet.StartTime__c);
            if(timeSheet.Timeinhours__c != null){
            gen.writeNumberField('TimecardHours', timeSheet.Timeinhours__c);
            }
            else{
                 gen.writeNumberField('TimecardHours', 0);
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeStringField('sourceOfReq', 'CSM');
        gen.writeEndObject();
        System.debug('CPU Time taken-Request:'+System.Limits.getCpuTime());
        return gen.getAsString();
    }
    
    public static String saveTimecardApiRequest(string requeststring, List<TimeSheet__c> timesheetList){
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setTimeout(120000);
            //CSMConnect This is named credential we created connection direct by using this.
            request.setEndpoint('callout:SyncTimecardToLIConnect/services/apexrest/updateTimecardPSA/');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requeststring);
            //string responseCall='Success';
            //Before send request we will set PSA_Sync_Status__c to 'Sync in progress' this will be use for same record comes in bulk for process then we will not pick
            CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
            string adminUser = csmCustomsetting.CSM_Timesheet_Sync_User_Name__c; //'radharaman.singhal@metacube.com';//This will be from custom setting
            string adminUserPwd =csmCustomsetting.CSM_Timesheet_Sync_passoword__c; //'iqvia@CSM1';//This will be from custom setting
            string sessionId = getUserSession(adminUser, adminUserPwd);
            system.debug('sessionid:'+sessionId);
            serviceSession = sessionId;
            string responseCall = setInprocessStatusCallout(timesheetList);
            System.debug('CPU Time taken-SyncInProcess:'+System.Limits.getCpuTime());
            //system.debug('responseCall:'+responseCall);
            if(responseCall == 'Success'){
                try{                    
                    System.debug('CPU Time taken4:'+System.Limits.getCpuTime());
                    System.debug('CPU Time:'+Limits.getLimitCpuTime());
                    HTTPResponse response = http.send(request); 
                    System.debug('CPU Time taken4.1:'+System.Limits.getCpuTime());
                    System.debug('CPU Time:'+Limits.getLimitCpuTime());
                    //System.debug('Test:'+ response.getBody());
                    //System.debug('Test:'+ response.getHeader('Location'));
                    
                    while(response.getStatusCode() == 302) {
                        request.setEndpoint(response.getHeader('Location'));
                        response = new Http().send(request);
                    }
                    System.debug('CPU Time taken-SaveTime:'+System.Limits.getCpuTime());
                    if(response.getStatusCode() == 200){
                        System.debug(response.getBody());
                        return response.getBody();
                    }
                    else{
                        
                        //System.debug('Failed-'+responsenew.getBody());
                        return 'Failed-' + response.getBody();
                    }
                }
                catch(Exception e){
                    system.debug('FailRR-'+'Failed-' + e.getStackTraceString() + ' ' + e.getMessage());
                    return 'Failed-' + e.getStackTraceString() + ' ' + e.getMessage();
                }
            }
            else{
                return 'Failed-' + 'Sync in progress status update failed';
            }
        }
        catch(Exception ex){
            return 'Failed-' + ex.getStackTraceString() + ' ' + ex.getMessage();
        }
    }
    
    public static void processTimecardAPIResponse(string responseString, List<TimeSheet__c> timeSheetList){
        system.debug('responsestring:'+ responseString);
        List<TimecardResponseHandler> liTimecardresponse = (List<TimecardResponseHandler>)JSON.deserialize(responseString, List<TimecardResponseHandler>.Class);
        Set<Id> sourceTimecardIdSet = new Set<Id>();
        if(liTimecardresponse != null) {
            /*
            for(TimecardResponseHandler sid: liTimecardresponse){
                sourceTimecardIdSet.add(sid.SourceTimecardId);
            }*/
            Map<Id,TimeSheet__c> timeSheetMap = new Map<Id,TimeSheet__c>();
            for(TimeSheet__c sid: timesheetList){
                timeSheetMap.put(sid.Id, sid);
            }
            List<TimeSheet__c> timeSheetUpdateList = new List<TimeSheet__c>();
            //Map<Id,TimeSheet__c> timeSheetMap = new Map<Id,TimeSheet__c>([select id,LITimecardId__c,SyncErrorMessage__c, PSA_Sync_Status__c, PSA_Sync_Count__c from TimeSheet__c where id in :sourceTimecardIdSet]); 
            allRecordCount=liTimecardresponse.size();
            for(TimecardResponseHandler sid: liTimecardresponse){
                TimeSheet__c timeSheet = timeSheetMap.get(sid.SourceTimecardId);
                timeSheet.LITimecardId__c = sid?.LITimecardId;
                timeSheet.PSA_Sync_Status__c = sid.SyncStatus;
                if(sid.SyncStatus=='Failed'){
                    failedRecordCount=failedRecordCount+1;
                }
                timeSheet.PSA_Sync_Date__c = System.now();
                if(sid.SyncErrorMessage != null){
                timeSheet.SyncErrorMessage__c = string.join(sid.SyncErrorMessage, ',');
                }
                else{
                    timeSheet.SyncErrorMessage__c = '';
                }
                timeSheet.PSA_Sync_Count__c = timeSheet.PSA_Sync_Count__c == null ? 1 : timeSheet.PSA_Sync_Count__c + 1;
                timeSheetUpdateList.add(timeSheet);
            }
            update timeSheetUpdateList;
        }
    }
    
    public static void processFailedRecords(List<TimeSheet__c> timesheetList, string errormsg)
    {
        //Set<Id> sourceTimecardIdSet = new Set<Id>();
        Map<Id,TimeSheet__c> timeSheetMap = new Map<Id,TimeSheet__c>();
        for(TimeSheet__c sid: timesheetList){
            //sourceTimecardIdSet.add(sid.Id);
            timeSheetMap.put(sid.Id,sid);
        }
        List<TimeSheet__c> timeSheetUpdateList = new List<TimeSheet__c>();
        //Map<Id,TimeSheet__c> timeSheetMap = new Map<Id,TimeSheet__c>([select id,LITimecardId__c,SyncErrorMessage__c, PSA_Sync_Status__c, PSA_Sync_Count__c from TimeSheet__c where id in : sourceTimecardIdSet]); 
        for(Id sid: timeSheetMap.keySet()){
            TimeSheet__c timeSheet = timeSheetMap.get(sid);
            timeSheet.LITimecardId__c = null;
            timeSheet.PSA_Sync_Status__c = 'Failed';
            timeSheet.SyncErrorMessage__c = errormsg;
            timeSheet.PSA_Sync_Count__c= timeSheet.PSA_Sync_Count__c == null ? 1: timeSheet.PSA_Sync_Count__c + 1;
            timeSheet.PSA_Sync_Date__c = System.now();
            timeSheetUpdateList.add(timeSheet);
        }
        update timeSheetUpdateList;
    }
    
    
    
    //Function to be call on button click event
    public static string manualSyncPSATimecard()
    {
        //string adminUser = 'radharaman.singhal@metacube.com';//This will be from custom setting
        //string adminUserPwd = 'iqvia@CSM1';//This will be from custom setting
        //string sessionId = getUserSession(adminUser, adminUserPwd);
        //system.debug('sessionid:'+sessionId);
        //serviceSession=sessionId;
        system.debug('manual-call');
        try{
            CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
            boolean stopTimecradSync = csmCustomsetting.StopCSMTimesheetSync__c;
            boolean enablePartialTimecardSync = csmCustomsetting.EnableTimesheetPartialDataSync__c;
            Integer numberOfSyncAttempts = (Integer)csmCustomsetting.SyncNumberOfAttempts__c;
            CSM_case_Trigger_Handler__c userSetting = CSM_case_Trigger_Handler__c.getValues(Userinfo.getUserId());
            if(stopTimecradSync){
                return 'Error: Timecard syncing is not enabled';
            }
            if(!stopTimecradSync && enablePartialTimecardSync && (userSetting == null || !userSetting.EnableTimesheetPartialDataSync__c)){
                return 'Error: Your Timecard syncing is not enabled';
            }
            system.debug('manual-call2');
            List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c ,Comment__c, MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <:numberOfSyncAttempts) AND createdBy.Id =: Userinfo.getUserId()];
            system.debug('manual-call3-'+timesheetList);
            if(timesheetList?.size() > 0) {
                try{
                    string requestString =  SRV_PSA_SyncCSMTimecard.getTimecardApiRequest(timesheetList);
                    string responseString = SRV_PSA_SyncCSMTimecard.saveTimecardApiRequest(requestString, timesheetList);
                    if(!responseString.startsWith('Failed-')){
                        SRV_PSA_SyncCSMTimecard.processTimecardAPIResponse(responseString, timesheetList);
                        if(allRecordCount>0 && failedRecordCount>0 && failedRecordCount==allRecordCount){
                            return 'Error:Timecards sync failed';
                        }
                        else if(failedRecordCount>0){
                            return 'Warning: Records are successfully synced except '+ failedRecordCount +' number of records, Please goto the records to see the error';
                        }
                        else{
                            return 'Success:Timecards synced successfully';
                        }
                    }
                    else{
                        SRV_PSA_SyncCSMTimecard.processFailedRecords(timesheetList, responseString);
                        return 'Error:Timecards sync failed please retry or check sync error message in corresponsing Timecards';
                    }
                }
                catch(Exception Ex){
                    SRV_PSA_SyncCSMTimecard.processFailedRecords(timesheetList,'Failed-' + ex.getStackTraceString() + ' ' + ex.getMessage());
                    return 'Error:Timecards sync failed please check sync error message in corresponsing Timecards';
                } 
            }
           system.debug('manual-call3');
           return 'Error: No Timecards found to sync';
        }
        catch(Exception ex){
            system.debug('manual-call4');
             return 'Error: Manual sync process failed-' +  +ex.getStackTraceString() + ' '+ ex.getMessage();
        }
    }
    
    public static List<TimeSheet__c> getPartialSyncTimecardsList(List<TimeSheet__c> timeSheets){
        List<TimeSheet__c> timeSheetList = new List<TimeSheet__c>();
        for(TimeSheet__c timeSheet: timeSheets){
            CSM_case_Trigger_Handler__c custSetting = CSM_case_Trigger_Handler__c.getValues(timeSheet.CreatedById);
            if(custSetting != null && custSetting.EnableTimesheetPartialDataSync__c){
                timesheetList.add(timeSheet);
            }
        }
        return timeSheetList;
    }
    
    public static string setInprocessStatusCallout(List<TimeSheet__c> timesheetList){
        Set<Id> timesheetIds=new Set<Id>();
        for(TimeSheet__c sid: timesheetList){
            //sourceTimecardIdSet.add(sid.Id);
            timesheetIds.add(sid.Id);
        }
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String endPointURLString = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/synCSMTimecardUpdate';
        Http http = new Http();
        //request.setHeader('Content-Type', 'text/html');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPointURLString);
        //request.setEndpoint('callout:CSMInternalConnectService/services/apexrest/synCSMTimecardUpdate/');
        //string adminUser = 'radharaman.singhal@metacube.com';//This will be from custom setting
        //string adminUserPwd = 'iqvia@CSM1';//This will be from custom setting
        //string sessionId = UTL_CDAUtility.login(adminUser, adminUserPwd);
        //UserInfo.getSessionId()
        system.debug('serviceSession:'+serviceSession);
        request.setHeader('Authorization', 'OAuth '+ serviceSession);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setBody(JSON.serialize(timesheetList));
        system.debug('JSON.serialize(utlPsaRestApi) '+JSON.serialize(timesheetList));
        system.debug('request = ');        
        System.debug('CPU Time taken3:'+System.Limits.getCpuTime());
        System.debug('CPU Time:'+Limits.getLimitCpuTime());
        response = http.send(request);
        System.debug('CPU Time taken3.1:'+System.Limits.getCpuTime());
        System.debug('CPU Time:'+Limits.getLimitCpuTime());
        system.debug('response.getBody() '+response.getBody());
        system.debug('response '+response.getStatusCode()+'@ '+response.getStatus());
        string returnResult1 = (string)JSON.deserialize(response.getBody(), string.class);
        system.debug('result:'+returnResult1);
        while (response.getStatusCode() == 302) {
            request.setEndpoint(response.getHeader('Location'));
            response = new Http().send(request);
        }
        if(response.getStatusCode() == 200){
            System.debug(response.getBody());
            //return response.getBody();
           string returnResult = (string)JSON.deserialize(response.getBody(), string.class);
            //return response.getBody();
           system.debug('res:'+returnResult);
            return returnResult;
        }
        else{
            System.debug('FailedRR-'+response.getBody());
            //processFailedRecords(timesheetList, response.getBody());
            //return 'Failed';
            return 'Failed-' + response.getBody();
        }

        
    }
    public static string setInprocessStatus(List<TimeSheet__c> timesheetList)
    {
        string response='Success';
        List<TimeSheet__c> timeSheetUpdateList = new List<TimeSheet__c>();
        Map<Id,TimeSheet__c> timeSheetMap = new Map<Id,TimeSheet__c>();
        for(TimeSheet__c sid: timesheetList){
            timeSheetMap.put(sid.Id,sid);
        }
        for(Id sid: timeSheetMap.keySet()){
            TimeSheet__c timeSheet = timeSheetMap.get(sid);
            timeSheet.PSA_Sync_Status__c = 'Sync in progress';
            timeSheet.PSA_Sync_Date__c = System.now();
            timeSheetUpdateList.add(timeSheet);
        }
        Database.SaveResult[] saveResults = Database.update(timeSheetUpdateList, true);
        boolean isSuccess=true;
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                response='Failed';
                break;
            }
        }
        system.debug('responseRR:'+response);
        /*
        if(response=='Failed'){
            processFailedRecords(timeSheetUpdateList,'Failed:Sync in progress status update failed');
        }*/
        return response;
        //update timeSheetUpdateList;
    }
    
    public static string getUserSession(string userName, string userPassword) {    
        string sessionID;
        // = UserInfo.getSessionId();
        String user = userName;
        String password = userPassword;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(60000);
        String baseURL = System.Url.getOrgDomainUrl().toExternalForm();
        req.setEndpoint(baseURL + '/services/Soap/u/54.0');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', 'login');
        String body = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +user+ '</username><password>' + password + '</password></login></Body></Envelope>';
        req.setBody(body);
        if(!Test.isRunningTest()){            
            System.debug('CPU Time taken2:'+System.Limits.getCpuTime());
            System.debug('CPU Time:'+Limits.getLimitCpuTime());
            HttpResponse res = new Http().send(req);            
            System.debug('CPU Time taken2.1:'+System.Limits.getCpuTime());
            System.debug('CPU Time:'+Limits.getLimitCpuTime());
            try{
                Dom.XmlNode resultElmt = res.getBodyDocument().getRootElement()
                    .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                    .getChildElement('result', 'urn:partner.soap.sforce.com');
                sessionID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
                
            } catch (Exception e) {
                system.debug('in catch '+UserInfo.getSessionId()); 
            }
        }
        return sessionID; 
    }
    
    public class TimecardResponseHandler{
        public TimecardResponseHandler() {
            SourceTimecardId = null;
            SyncErrorMessage = new List<String>();
            LITimecardId = null;
            SyncStatus = '';
        }
        public  string SyncStatus{ get; set;}
        public  List<string> SyncErrorMessage{ get; set;}
        public  Id SourceTimecardId{ get; set;}
        public  Id LITimecardId{ get; set;}
    }
    
    

}