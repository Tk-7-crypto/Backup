global class BCH_CSM_CaseAutomationScheduler implements Database.Batchable<sObject>,Database.Stateful {
    public String htmlBody;
    public List<String> errorList = null;
    public BCH_CSM_CaseAutomationScheduler(){
        htmlBody = '<table style="border-collapse: collapse;border: 0.1px solid black;"> <tr> <th style="border: 1px solid black;">Case Automation Scheduler Name</th> <th style="border: 1px solid black;">Error Message</th></tr><tbody>';
        errorList = new List<String>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Active__c, Next_Run_Date__c, Primary_Owner__c, Secondary_Owner__c, FrequencyId__c FROM '+
            'CSM_QI_CaseAutomationScheduler__c WHERE Active__c = TRUE AND (Next_Run_Date__c < TODAY or Next_Run_Date__c = TODAY) ORDER BY Name ASC LIMIT 1000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CSM_QI_CaseAutomationScheduler__c> automationList) {
        Set<Id> automationIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> frequencyIdSet = new Set<Id>();
        Date todayDate = Date.today();
        for(CSM_QI_CaseAutomationScheduler__c aR : automationList){
            //if(aR.Active__c && aR.Next_Run_Date__c == todayDate){
            if(aR.Active__c){
                automationIdSet.add(aR.Id);
                userIdSet.add(aR.Primary_Owner__c);
                userIdSet.add(aR.Secondary_Owner__c);
                frequencyIdSet.add(aR.FrequencyId__c);
            }
        }
        if((automationIdSet != null && !automationIdSet.isEmpty()) && (userIdSet != null && !userIdSet.isEmpty())){
            List<CSM_QI_CaseAutomationScheduler__c> autoCaseList = new SLT_CaseAutomationScheduler().selectById(automationIdSet);
            Map<Id, User> userIdMap = new SLT_User().selectByUserId(userIdSet, new Set<String>{'Id', 'Name','IsActive'});
            List<OutOfOffice> outOfficeList = [SELECT Id, UserId FROM OutOfOffice WHERE UserId IN :userIdSet];
            Set<Id> userIds = new Set<Id>();
            if((userIdMap != null && !userIdMap.isEmpty()) && (outOfficeList != null && !outOfficeList.isEmpty())){
                for(OutOfOffice officeRecord : outOfficeList){
                    if(userIdMap.get(officeRecord.UserId) != null){
                        userIds.add(officeRecord.UserId);
                    }
                }
            }
            Id techRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            Id dataRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            
            Map<Id, CSM_QI_Frequency__c> frequencyMap = new Map<Id, CSM_QI_Frequency__c>();
            if(frequencyIdSet != null && !frequencyIdSet.isEmpty()){
                List<CSM_QI_Frequency__c> freqList = new SLT_Frequency().selectById(frequencyIdSet);
                if(freqList != null && !freqList.isEmpty()){
                    for(CSM_QI_Frequency__c freqRecord : freqList){
                        frequencyMap.put(freqRecord.Id, freqRecord);
                    }
                }
            }
            
            if(autoCaseList != null && !autoCaseList.isEmpty()){
                List<Case> caseList = new List<Case>();
                List<CSM_QI_CaseAutomationScheduler__c> autoSchedulerList = new List<CSM_QI_CaseAutomationScheduler__c>();
                for(CSM_QI_CaseAutomationScheduler__c autoRecord : autoCaseList){
                    Case caseRecord = new Case();
                    if(autoRecord.Pillar__c == CON_CSM.S_TECHNOLOGY_SOLUTIONS){
                        if(autoRecord.Next_Run_Date__c == todayDate){
                            caseRecord.RecordTypeId = techRecordTypeId;
                            caseRecord.NoContactKnown__c = autoRecord.No_Contact_Known__c;
                            caseRecord.AccountId = autoRecord.Account_Name__c;
                            caseRecord.Urgency__c = autoRecord.Urgency__c;
                            caseRecord.Techno_Impact__c = autoRecord.Impact__c;
                            caseRecord.Origin = autoRecord.Origin__c;
                            if(autoRecord.Creation_Date_In_Subject__c && autoRecord.Subject__c != null && autoRecord.Subject__c.length() <245){
                                caseRecord.Subject = autoRecord.Subject__c +' - ' + System.now().format('dd/MM/yyyy');
                            }else{
                                caseRecord.Subject = autoRecord.Subject__c;
                            }
                            caseRecord.Description = autoRecord.Description__c;
                            if(autoRecord.Primary_Owner_Current_Queue__c == null || userIds.contains(autoRecord.Primary_Owner__c) || (userIdMap.containsKey(autoRecord.Primary_Owner__c) && !userIdMap.get(autoRecord.Primary_Owner__c).IsActive)){
                                caseRecord.OwnerId = autoRecord.Secondary_Owner__c;
                                caseRecord.CurrentQueue__c = autoRecord.Secondary_Owner_Current_Queue__c;
                            }
                            else{
                                caseRecord.OwnerId = autoRecord.Primary_Owner__c;
                                caseRecord.CurrentQueue__c = autoRecord.Primary_Owner_Current_Queue__c;
                            }
                            caseRecord.ProductName__c = autoRecord.ProductName__c;
                            caseRecord.SubType1__c = autoRecord.SubType1__c;
                            caseRecord.SubType2__c = autoRecord.SubType2__c;
                            caseRecord.SubType3__c = autoRecord.SubType3__c;
                            caseRecord.Device__c = autoRecord.Device__c;
                            caseRecord.AssetId = autoRecord.Asset_Name__c;
                            caseList.add(caseRecord);
                        }
                        
                        if(autoRecord.Frequency__c == CON_CSM.S_FREQUENCY_DAILY){
                            autoRecord = calculateNextDate(autoRecord);
                        }else if(frequencyMap.get(autoRecord.FrequencyId__c) != null){
                            CSM_QI_Frequency__c frequencyRecord = frequencyMap.get(autoRecord.FrequencyId__c);
                            autoRecord = CNT_CSM_Frequency.calculateNextDate(autoRecord, frequencyRecord, CON_CSM.S_BATCH_EXECUTED);
                        }
                        
                        autoRecord.Last_Run_Date__c = Datetime.now();
                        autoSchedulerList.add(autoRecord);
                        
                    }
                    else if(autoRecord.Pillar__c.equalsIgnoreCase(CON_CSM.S_INFORMATION_OFFERING)){
                        
                    }
                }
                try{
                    insert caseList;
                    update autoSchedulerList;
                }
                catch(Exception ex){
                    htmlBody = htmlBody +'<td style="border: 1px solid black;"><a href="'+URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/CSM_QI_CaseAutomationScheduler__c/'+autoSchedulerList[0].Id+'/view">'+autoSchedulerList[0].Name+'</a></td><td style="border: 1px solid black;">'+ex.getMessage()+'</td></tr>';
                    errorList.add(ex.getStackTraceString());
                    System.debug('Error Message : '+ex.getMessage());
                }
            }
        }
    }
    
    private static CSM_QI_CaseAutomationScheduler__c calculateNextDate(CSM_QI_CaseAutomationScheduler__c autoRecord){
        Datetime currentDate = Date.today();
        Date nextDate;
        Datetime startDate;
        if(autoRecord.Next_Run_Date__c == currentDate){
            startDate = autoRecord.Next_Run_Date__c;    
        }else{
            startDate = Datetime.now();
        }
        
        Datetime tempStartDate;
        if(startDate.format('EEEE') == 'Friday'){
            tempStartDate = startDate + 3;
        }
        else if(startDate.format('EEEE') == 'Saturday'){
            tempStartDate = startDate + 2;
        }
        else{
            tempStartDate = startDate + 1;
        }
        nextDate = tempStartDate.date();
        autoRecord.Next_Run_Date__c = nextDate;
        return autoRecord;
    }
    
    global void finish(Database.BatchableContext BC){
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = null;
        System.debug(' errorList : '+errorList);
        if(!errorList.isEmpty() || Test.isRunningTest())
        {   
            List<Id> userIds = new List<Id>();
            List<PermissionSetAssignment> psa = Database.query('select Id, AssigneeId from PermissionSetAssignment where PermissionSet.Name =\'CSM_Case_Automation_Scheduler\' and Assignee.IsActive = true');
            for(PermissionSetAssignment p : psa){
                userIds.add(p.AssigneeId);
            }
            List<OrgWideEmailAddress> owa = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress('no.reply.support@iqvia.com',new Set<String>{'ID'});
            htmlBody+='</table>';
            String  hbody = 'Dear All,\n\n';
            hbody+='You are receiving this automated email because the below Case Automation Scheduler record failed to create the case.\n\n';
            hbody+='<<--table-->>\n\n';
            hbody+='Please check and reactivate the users thru VIA ticket or update the CSM Case Automation Scheduler record with active users.\n';
            hbody+='This is an automatic email, please do not respond.\n';
            hbody+='Regards,\n';
            hbody+='CSM System team';
            hbody = hbody.replace('<<--table-->>',htmlBody);
            for(Id e : userIds){
                email = new Messaging.SingleEmailMessage();
                email.setReplyTo('no.reply.support@iqvia.com');
                email.setOrgWideEmailAddressId(owa[0].id);
                email.setTargetObjectId(e);
                email.setHtmlBody(hbody);
                email.setSaveAsActivity(false);
                email.setSubject('CSM Case Automation Scheduler failed process');
                messages.add(email);    
            }
            System.debug('inside loop : ' + messages);
            if(!messages.isEmpty()) Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
        
    }
}