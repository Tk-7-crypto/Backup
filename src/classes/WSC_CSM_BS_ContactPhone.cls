@RestResource(urlMapping='/v2/getCaseDetailsbyPhone/*')
global with sharing class WSC_CSM_BS_ContactPhone {
    
    //wrapper class for the response to an API request
    global class responseWrapper {
		
        global String status {get;set;} //status string
        global String CaseNumber {get;set;} //18 character Contact record Id
        global String CTIInfo {get;set;} //18 character Task record Id
        global String message {get;set;} //message string
        global Datetime createDate {get;set;} //message string
        global Datetime latestDate {get;set;} //message string
        global Integer order {get;set;} //message string
		
        //constructor
        global responseWrapper() {
            //default all values
            this.status = 'success';
        }
    }
    
    @HttpGet
    global static List<Case> getCasebyContactPhone() {
        RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        String phone = request.params.get('phone');
        String createdDate = request.params.get('date');
        List<Case> caseList = null;
        List<Id> userIds = new List<Id>();
        List<Case> cases = new List<Case>();
        if(!String.isBlank(phone) && !String.isBlank(createdDate)) {
            Datetime dt = (DateTime)JSON.deserialize('"' + createdDate + '"', DateTime.class);

            String query = 'SELECT id,CaseNumber,LastModifiedById,Owner__c,ContactPhone,Contact.MobilePhone,Contact.Phone,CreatedDate,LastModifiedDate FROM Case WHERE LastModifiedDate > :dt AND (ContactPhone LIKE \'%'+Phone+'\' OR Contact.MobilePhone LIKE \'%'+Phone+'\') order by LastModifiedDate DESC LIMIT 10';
            caseList = Database.query(query);
            if(caseList != null && !caseList.isEmpty()){
                for(Case c : caseList){
                    userIds.add(c.LastModifiedById);
                }
                Map<Id,User> userMap = new Map<Id,User>((List<User>)Database.query('Select Id From User where Id in :userIds LIMIT 1'));
                if(userMap != null && !userMap.isEmpty()){
                    for(Case c : caseList){
                        if(userMap.containsKey(c.LastModifiedById)){
                            //c.Owner__c = '';
                            //cases.add(c);
                        }
                    }  
                }
            }
        }
        return cases;
    }
    
    @HttpPost
    @RestResource(urlMapping='/post/*')
    global static List<responseWrapper> getCasebyPhone(String phone) {
        RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        //String phone = request.params.get('phone');
        //String createdDate = request.params.get('date');
        List<Task> taskList = null;
        List<responseWrapper> rwList = new List<responseWrapper>();
        responseWrapper rw = null;
        if(!String.isBlank(phone)) {
            String query = 'select Id, Subject, WhoId , WhatId , CreatedDate, LastModifiedDate, CallObject, what.Name ,CompletedDateTime, CallType from Task where CallType =\'Inbound\' and CSM_QI_CTI_Phone__c like \'%'+Phone+'\' and CreatedDate <= LAST_N_DAYS:1 order by CreatedDate desc LIMIT 1';
            taskList = Database.query(query);
            integer i = 1;
            if(taskList != null){
                for(Task t : taskList){
                    rw = new responseWrapper();
                    if(t.WhatId != null && t.WhoId != null && String.valueOf(t.WhoId).startsWith('003') && String.valueOf(t.WhatId).startsWith('500')){
                        rw.message = 'Case linked and Contact found in SF';
                        rw.CaseNumber = t.what.Name;
                    }else if(t.WhatId != null && t.WhoId == null && String.valueOf(t.WhatId).startsWith('500')){
                        rw.message = 'Case linked and Contact not found in SF';
                        rw.CaseNumber = t.what.Name;
                    }else if(t.WhatId == null && t.WhoId != null && String.valueOf(t.WhoId).startsWith('003')){
                        rw.message = 'Case not linked and Contact found in SF';
                    }else if(t.WhatId == null && t.WhoId == null){
                        rw.message = 'Case not Linked and Contact not found in SF';
                    }
                    
                    rw.status = 'success';
                    rw.createDate = t.CreatedDate;
                    rw.latestDate = t.LastModifiedDate;
                    rw.CTIInfo = '';
                    rw.order = i;
                    i++;
                    rwList.add(rw);
                }
            }
        }
        return rwList;
    }
}