/**
 * @description       : 
 * @author            : mallikarjuna.reddyb@iqvia.com
 * @group             : 
 * @last modified on  : 11-18-2022
 * @last modified by  : mallikarjuna.reddyb@iqvia.com
**/
public class DAOH_EmailMessage {
    static Map<Id,EmailMessage> caseIds;
    static Map<Id, Case> incomingCases;
    static Map<Id, Case> outgoingCases;
    static Map<Id, Case> caseMap;
    public static void selectCaseDetails(List<EmailMessage> newList, Map<Id,EmailMessage> oldMap){
            caseIds = new Map<Id,EmailMessage>();
            incomingCases = new Map<Id, Case>();
            outgoingCases = new Map<Id, Case>();
            for(EmailMessage c : newList) {
                if(c.ParentId != null){
                    caseIds.put(c.ParentId,c);
                }
            }
            if(caseIds != null && !caseIds.isEmpty()){
                caseMap = new Map<Id, Case>(new SLT_Case().selectById(caseIds.keySet()));
                for(Id cid : caseMap.keySet()){
                    if(caseIds != null && caseIds.containsKey(cid)){
                        if(caseIds.get(cid).Incoming){
                            incomingCases.put(cid, caseMap.get(cid));
                        }else if(caseIds.get(cid).IsSendAsComment__c || caseIds.get(cid).Status == '3'){
                            outgoingCases.put(cid, caseMap.get(cid));
                        }
                        
                    }
                }
                //if(!incomingCases.isEmpty())
                //       UTL_CSM_SendMail.updateEmailMessageMail('Incoming Email',null,incomingCases);
            }    
    }
    
    /*public static void createActivityofEmailMessageOutgoing(List<EmailMessage> newList){
        selectCaseDetails(newList,null);
        if(outgoingCases != null && !outgoingCases.isEmpty()){
            List<Id> RDCaseId = new List<Id>();
            List<Activity__c> activityList = new List<Activity__c>();
            String caseId = null;
            Set<Id> tcaseIds = new Set<Id>();
            List<String> statusList = CON_CSM.S_C_TECH_STATUS;
            String name = UserInfo.getName();
            for(Case cs : outgoingCases.values()){
                if((cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                    activityList.add(createRndActivity(cs, false, false,caseIds.get(cs.Id)));
                }
                if(cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T && cs.template__c == CON_CSM.S_R_D_DATABASE_LOCK){
                    if (cs.SlaExitDate == null && cs.Subject.indexOf(CON_CSM.S_R_D_DATABASE_LOCK)!= -1){
                        RDCaseId.add(cs.id);
                    }      
                }
                if(CON_CSM.S_ALLOWED_RT_TIMESHEET.contains(cs.RecordTypeName__c) && !(name == CON_CSM.S_SYSTEM || name == CON_CSM.S_CSM_ADMIN  || UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || name == 'Integration ServiceNow' || name =='BISM CSM API User')){
                    tcaseIds.add(cs.Id);
                    if(!statusList.contains(cs.Status) || cs.Status == CON_CSM.S_RESOLVED_WITH_C){
                        caseId = cs.Id;
                    }
                }
            }
            if(!activityList.isEmpty()){
                SRV_CSM_AssignPermissionSet.createActivityFromEmailMessage(JSON.serialize(activityList));   
            }
            if(!RDCaseId.isEmpty()){
                DateTime completionDate = System.now();
                SRV_CSM_AssignPermissionSet.completeMilestone(RDCaseId, new List<String>{CON_CSM.S_R_D_DATABASE_LOCK} , completionDate);
            }
            if(!tcaseIds.isEmpty() && !System.isBatch() && !System.isFuture()){
                DAOH_Case.stopTechAutoTimer(tcaseIds,caseId,'OutboundEmail Sent');
            }
        }
    }*/
    
    public static void updateCasefromEmailMessageIncoming(List<EmailMessage> newList){
        selectCaseDetails(newList,null);
        if(incomingCases != null && !incomingCases.isEmpty()){
            UTL_CSM_SendMail.updateEmailMessageMail('Incoming Email',null,incomingCases);
            //getCSMEmailToCaseRouting();
            Map<Id,String> emailMap = new Map<Id,String>();
            List<Asset> assetList = new List<Asset>();
            List<CSM_QI_Case_Categorization__c> catCases = new List<CSM_QI_Case_Categorization__c>();
            Map<Id,Asset> assetMap = new Map<Id,Asset>();
            Map<Id,CSM_QI_Case_Categorization__c> catCsMap = new Map<Id,CSM_QI_Case_Categorization__c>();
            boolean checkUpdate = false;
            boolean firstE2c = false;
            Map<Id,Id> prodMap = new Map<Id,Id>();
            Map<Id,Id> catMap = new Map<Id,Id>();
            Map<Id,Id> accMap = new Map<Id,Id>();
            Map<Id,Id> conMap = new Map<Id,Id>();
            Map<Id,Queue_User_Relationship__c> mapOfQueue = new Map<Id,Queue_User_Relationship__c>();
            Set<Id> queueId = new Set<Id>();
            Map<String,String> priList = new Map<String,String>();
            List<Activity__c> activityList = new List<Activity__c>();
            List<Case> updateCase = new List<Case>();
            Set<String> ccEmailSet = new Set<String>();
            List<string> emailToRemoveSet = new List<String>{'email2casecsm@quintilesims.com','email2casecsm@iqvia.com','replytocsm@iqvia.com'};
            Map<Id,String> fromEmail = new Map<Id,String>();
            List<string> e2cAddress = new List<string>();
            Map<String,CSM_Email_To_Case_Custom_Settings__c> emails = new Map<String,CSM_Email_To_Case_Custom_Settings__c>();
            Map<String, Set<String>> senderEmailsByRecordType = new Map<String, Set<String>>();
            Map<String, Set<String>> stopClosedEmailByRecordType = new Map<String, Set<String>>();
            boolean isNotDataEService = true,isNotOutofOffice = true;
            String ccEmail = null;
            for(EmailMessage c : newList) {
                if(c.Incoming && c.ParentId != null){
                    if(c.ToAddress != null){
                        List<String> toAdd = c.ToAddress.split(';');
                        if(toAdd != null && !toAdd.isEmpty()){
                            for(String s : toAdd){
                                e2cAddress.add(s.trim());
                            }
                        }else{
                            e2cAddress.add(c.ToAddress);
                        }
                    }
                    if(c.CcAddress != null){
                        ccEmail = c.CcAddress;
                        List<String> ccAdd = c.CcAddress.split(';');
                        if(ccAdd != null && !ccAdd.isEmpty()){
                            for(String s : ccAdd){
                                e2cAddress.add(s.trim());
                            }
                        }else{
                            e2cAddress.add(c.CcAddress);
                        }
                    }
                }
            }
            if(e2cAddress != null && !e2cAddress.isEmpty()){
                List<CSM_Email_To_Case_Custom_Settings__c> e2cSettings = DataBase.query('select Id, Exclude_MessageList__c,E2C_Address__c, Queue_User_Relationship__c, Group_Id__c,Queue_Name__c,Keyword_Assignment__c, Type__c, Bypass_Route_Email__c, CaseSource__c, Categorization_Id__c, Product_Id__c, RecordTypeName__c, R_D_Enable_E2C_Description__c, SenderEmailToExclude__c, ServiceNowGroup__c, SN_Case_Type__c, Priority__c,Sender_Email_Address__c from CSM_Email_To_Case_Custom_Settings__c where E2C_Address__c in :e2cAddress OR Type__c =\'Prevent Status Change\' OR Type__c =\'Prevent Creation\'');
                if(e2cSettings != null && !e2cSettings.isEmpty()){
                    for(CSM_Email_To_Case_Custom_Settings__c e2c : e2cSettings){
                        if(e2c.E2C_Address__c != null){
                            emails.put(e2c.E2C_Address__c,e2c);
                            if(e2c.Bypass_Route_Email__c != null){
                                emails.put(e2c.Bypass_Route_Email__c,e2c);
                            }
                        }
                        if(e2c.Type__c == 'Prevent Status Change' && e2c.SenderEmailToExclude__c != null && e2c.SenderEmailToExclude__c != '' && e2c.RecordTypeName__c != null) {
                            Set<String> senderEmails = new Set<String>();
                            senderEmails.addAll(e2c.SenderEmailToExclude__c.split(';'));
                            senderEmailsByRecordType.put(e2c.RecordTypeName__c, senderEmails);
                        }
                        if(e2c.Type__c == 'Prevent Creation' && e2c.RecordTypeName__c != null && e2c.Keyword_Assignment__c != '') {
                            Set<String> keySet = new Set<String>();
                            keySet.addAll(e2c.Keyword_Assignment__c.split(';'));
                            stopClosedEmailByRecordType.put(e2c.RecordTypeName__c, keySet);
                        }
                    }
                }
            }
            for(EmailMessage c : newList) {
                if(c.Incoming && c.ParentId != null){
                    fromEmail.put(c.ParentId,c.FromAddress);
                    if(!emails.isEmpty() && emails.containsKey(c.ToAddress)){
                        if(emails.get(c.ToAddress) != null && emails.get(c.ToAddress).Bypass_Route_Email__c != null){
                            emailMap.put(c.ParentId,emails.get(c.ToAddress).Bypass_Route_Email__c);
                        }else{
                            emailMap.put(c.ParentId,c.ToAddress);
                        }
                    }else if(c.ToAddress != null){
                        List<String> toAdd = c.ToAddress.split(';');
                        if(toAdd != null && !toAdd.isEmpty()){
                            for(String s : toAdd){
                                if(s != null && emails.containsKey(s.trim())){
                                    if(emails.get(s.trim()) != null && emails.get(s.trim()).Bypass_Route_Email__c != null){
                                        emailMap.put(c.ParentId,emails.get(s.trim()).Bypass_Route_Email__c);
                                    }else{
                                        emailMap.put(c.ParentId,s.trim());
                                    }  
                                }
                            }
                        }
                    }
                    if(c.CcAddress != null){
                        List<String> ccAdd = c.CcAddress.split(';');
                        if(ccAdd != null && !ccAdd.isEmpty()){
                            for(String s : ccAdd){
                                if(s != null && emails.containsKey(s.trim())){
                                    emailMap.put(c.ParentId,s.trim());
                                }
                                if(!emailToRemoveSet.contains(s.toLowerCase().trim())) {
                                    ccEmailSet.add(s.toLowerCase());
                                }
                                
                            }
                        }else{
                            if(!emailToRemoveSet.contains(c.CcAddress.toLowerCase().trim())) {
                                ccEmailSet.add(c.CcAddress.toLowerCase());
                            }
                        }
                    }
                }
            }
            if(caseIds!=null && !caseIds.isEmpty()){
                for(Case cs : incomingCases.Values()) {
                    if(cs.IsClosed && cs.RecordTypeName__c == CON_CSM.S_DATACASE){
                        queueId.add(cs.CurrentQueue__c);    
                    }
                    if(cs.RecordTypeName__c == CON_CSM.S_R_D_CTP){
                        cs.Mail_CC_List__c = ccEmail;
                        checkUpdate = true;
                    }
                    if(cs.From_EmailToCase__c == null && cs.Case_ThreadToken__c == null && (Test.isRunningTest() || (UserInfo.getName() == 'System' && UserInfo.getUserId() == cs.CreatedById)) && emailMap.containsKey(cs.Id) && emails != null && emails.containsKey(emailMap.get(cs.Id)) && (CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_O_VOICE == cs.Origin)){
                        if((cs.RecordTypeName__c == CON_CSM.S_DATACASE || CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c)){
                            if(emails.get(emailMap.get(cs.Id)).Product_id__c != null){
                                prodMap.put(emails.get(emailMap.get(cs.Id)).Product_id__c,cs.Id);
                            }
                            if(cs.AccountId != null){
                                accMap.put(cs.AccountId,cs.Id);
                            }
                            if(cs.ContactId != null){
                                conMap.put(cs.ContactId,cs.Id);
                            }
                        }
                        if(emails.get(emailMap.get(cs.Id)).Categorization_Id__c != null){
                            catMap.put(emails.get(emailMap.get(cs.Id)).Categorization_Id__c, cs.Id);
                        }
                        
                    }
                    if((cs.RecordTypeName__c == CON_CSM.S_DATACASE || CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c) && cs.ContactId != null && cs.IsClosed){
                        conMap.put(cs.ContactId,cs.Id);   
                    }
                }
                
                if(!prodMap.isEmpty() && !accMap.isEmpty()){
                    assetList = new SLT_Asset().selectByAccountIdAndProductId(accMap.keySet(),prodMap.keySet());
                    for(Asset a : assetList){
                        if(accMap.containsKey(a.AccountId) && prodMap.containsKey(a.Product2Id) && accMap.get(a.AccountId) == prodMap.get(a.Product2Id)){
                            assetMap.put(accMap.get(a.AccountId),a);    
                        }
                        
                    }
                }
                if(!catMap.isEmpty()){
                    catCases = new SLT_CaseCategorization().getActiveCaseCategorization(catMap.keySet());
                    for(CSM_QI_Case_Categorization__c a : catCases){
                        if(catMap.containsKey(a.Id)){
                            catCsMap.put(catMap.get(a.Id),a);    
                        }
                    }
                }
                
                if(queueId != null && !queueId.isEmpty()) {
                    mapOfQueue = New SLT_QueueUserRelationshipC().selectByQueueId(queueId, New Set<String>{'Name'});
                }
                //priList = getCSMSenderE2CPriority();
                Map<Id,Account> acctMap = new Map<Id,Account>();
                Map<Id,Contact> contMap = new Map<Id,Contact>();
                boolean isAbanbon = false, isNotNewE2C = true;
                /* Set<Id> accIds = new Set<Id>();
                 for(Case cs : incomingCases.values()){
                    if(cs.AccountId != null && CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c){
                        accIds.add(cs.AccountId);
                    }
                }*/
                if(!accMap.isEmpty()){
                   acctMap = new SLT_Account().selectByAccountId(accMap.keySet(),new Set<String> {'Id','CSM_Forbidden_Email_to_Case__c','SendCaseCollaborationEmail__c'});
                }
                if(!conMap.isEmpty()){
                   contMap = new SLT_Contact().selectByContactId(conMap.keySet(),new Set<String> {'Id','PreferredLanguage__c'});
                }
                for(Case cs : incomingCases.values()){
                    checkUpdate = false;
                    if(cs.From_EmailToCase__c == null && cs.Case_ThreadToken__c == null && (Test.isRunningTest() || (UserInfo.getName() == 'System' && UserInfo.getUserId() == cs.CreatedById)) && emailMap.containsKey(cs.Id) && emails != null && emails.containsKey(emailMap.get(cs.Id)) && (CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_O_VOICE == cs.Origin)){
                        isNotNewE2C = false;
                        cs.From_EmailToCase__c = emailMap.get(cs.Id);
                        if(!String.isBlank(cs.Description) && (cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE) && cs.Origin == CON_CSM.S_EMAIL && CON_CSM.S_SYSTEM == UserInfo.getName()){
                            if(emails != null && emails.containsKey(cs.From_EmailToCase__c) && emails.get(cs.From_EmailToCase__c).R_D_Enable_E2C_Description__c == false){
                                cs.Description = '';
                                checkUpdate = true;
                            }
                        }
                        if(CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && cs.AccountId != null && cs.From_EmailToCase__c != null && acctMap.containsKey(cs.AccountId) && acctMap.get(cs.AccountId).CSM_Forbidden_Email_to_Case__c != null && acctMap.get(cs.AccountId).CSM_Forbidden_Email_to_Case__c.contains(cs.From_EmailToCase__c)){
                            cs.Status = CON_CSM.S_CASE_ABANDONED;
                            cs.EntitlementId = null;
                            isAbanbon = true;
                        }
                        if(cs.From_EmailToCase__c != null && emails != null && emails.containsKey(cs.From_EmailToCase__c)){
                            if(emails.get(cs.From_EmailToCase__c).Sender_Email_Address__c != null && emails.get(cs.From_EmailToCase__c).Sender_Email_Address__c.contains(cs.SuppliedEmail)){
                                //String  keySet = (cs.SuppliedEmail+'~'+ cs.From_EmailToCase__c).toLowercase();
                                List<String> supEmailList = emails.get(cs.From_EmailToCase__c).Sender_Email_Address__c.split(';');
                                for(String sup : supEmailList){
                                    if(sup != null && sup.contains(cs.SuppliedEmail) && sup.contains(',')){
                                        cs.Priority =  sup.split(',')[1];
                                        break;
                                    }
                                }
                            }
                            if(emails.get(cs.From_EmailToCase__c).Keyword_Assignment__c != null && cs.Description != null){
                                List<String> kwds = emails.get(cs.From_EmailToCase__c).Keyword_Assignment__c.toLowerCase().split(';');
                                String des = cs.Description.toLowerCase();
                                for(String k : kwds){
                                    if(des.containsIgnoreCase(k) && emails.get(cs.From_EmailToCase__c).Queue_User_Relationship__c != null){
                                        cs.CurrentQueue__c = emails.get(cs.From_EmailToCase__c).Queue_User_Relationship__c;
                                        cs.InitialQueueData__c = emails.get(cs.From_EmailToCase__c).Queue_User_Relationship__c;
                                        cs.InitialQueue__c = emails.get(cs.From_EmailToCase__c).Queue_Name__c;
                                        cs.OwnerId = emails.get(cs.From_EmailToCase__c).Group_Id__c;
                                        break;
                                    }
                                }
                            }
                            if(emails.get(cs.From_EmailToCase__c).CaseSource__c != null){
                                cs.CaseSource__c = emails.get(cs.From_EmailToCase__c).CaseSource__c;
                            }
                            if(emails.get(cs.From_EmailToCase__c).ServiceNowGroup__c != null){
                                cs.ServiceNow_Group__c = emails.get(cs.From_EmailToCase__c).ServiceNowGroup__c;
                                if(emails.get(cs.From_EmailToCase__c).SN_Case_Type__c != null){
                                    cs.Service_Now_Type__c = emails.get(cs.From_EmailToCase__c).SN_Case_Type__c;
                                }
                                cs.ServiceNowSystemType__c = 'Internal';
                                cs.Requested_Date__c = System.today();
                                cs.Customer_Requested_Date__c = System.today();
                            }
                            if(assetMap != null && !assetMap.isEmpty() && assetMap.containsKey(cs.Id)){
                                if(cs.AssetId == null){
                                    cs.AssetId = assetMap.get(cs.Id).Id;
                                }
                                if(cs.ProductName__c == null && (CON_CSM.S_DATACASE == cs.RecordTypeName__c || CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c)){
                                    cs.ProductName__c = assetMap.get(cs.Id).Name;
                                }
                            }
                            if(catCsMap != null && !catCsMap.isEmpty() && catCsMap.containsKey(cs.Id)){
                                if(cs.ProductName__c == null && (CON_CSM.S_DATACASE == cs.RecordTypeName__c || CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c)) {
                                    cs.ProductName__c = catCsMap.get(cs.Id).ProductName__c;
                                }else if(cs.LOS__c == null && (cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                                    cs.LOS__c = catCsMap.get(cs.Id).LOS__c;
                                }
                                if(cs.SubType1__c == null){
                                    cs.SubType1__c = catCsMap.get(cs.Id).SubType1__c;
                                }
                                if(cs.SubType2__c == null){
                                    cs.SubType2__c = catCsMap.get(cs.Id).SubType2__c;
                                }
                                if(cs.SubType3__c == null){
                                    cs.SubType3__c = catCsMap.get(cs.Id).SubType3__c;
                                }
                                if(cs.Case_CategorizationId__c == null){
                                    cs.Case_CategorizationId__c = catCsMap.get(cs.Id).Id;
                                }
                            }
                        }
                        
                        checkUpdate = true;
                        firstE2c = true;
                    }
                    
                    if(CON_CSM.S_DATACASE == cs.RecordTypeName__c && UserInfo.getName() ==CON_CSM.S_SYSTEM){
                        if(cs.From_EmailToCase__c != null && cs.CaseOriginatorEmail__c == null){
                            cs.CaseOriginatorEmail__c =  cs.From_EmailToCase__c;
                        }
                        if(cs.InitialQueue__c != null && cs.CaseOriginatorName__c == null){
                            cs.CaseOriginatorName__c =  cs.InitialQueue__c;
                        }
                        checkUpdate = true;
                    }
                    
                    //if(CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && cs.Status != CON_CSM.S_NEW && cs.IsClosed == false && caseIds.get(cs.Id).Subject != null && caseIds.get(cs.Id).Subject.contains(cs.Case_Thread_ID__c)){
                    if(isNotNewE2C && (CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c || cs.RecordTypeName__c == CON_CSM.S_R_D_CTP) && cs.Status != CON_CSM.S_NEW && cs.IsClosed == false){
                        cs.Status = CON_CSM.S_IN_PROGRESS;
                        cs.SubStatus__c = CON_CSM.S_RESPONSE_RECEIVED;
                        checkUpdate = true;
                    }
                    if(!(CON_CSM.S_NEW == cs.Status || cs.IsClosed  || (CON_CSM.S_WAITING_FOR == cs.Status && ((cs.RecordTypeName__c == CON_CSM.S_DATACASE && cs.SubStatus__c == 'Internal Support') || cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)))){
                        if(((cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE) && (senderEmailsByRecordType != null && !senderEmailsByRecordType.isEmpty() && senderEmailsByRecordType.containsKey(cs.RecordTypeName__c) && !senderEmailsByRecordType.get(cs.RecordTypeName__c).isEmpty() && caseIds.containsKey(cs.Id) && caseIds.get(cs.Id) != null && !senderEmailsByRecordType.get(cs.RecordTypeName__c).contains(caseIds.get(cs.Id).FromAddress)))) {
                            cs.Status = CON_CSM.S_IN_PROGRESS;
                            checkUpdate = true;
                        }else if(!isAbanbon && cs.RecordTypeName__c != CON_CSM.S_R_D_CTP && cs.RecordTypeName__c != CON_CSM.S_R_D_CDP && cs.RecordTypeName__c != CON_CSM.S_R_D_V_T && cs.RecordTypeName__c != CON_CSM.S_ACTIVITY_R_T && cs.RecordTypeName__c != CON_CSM.S_RDCASE) {
                            cs.Status = CON_CSM.S_IN_PROGRESS;
                            checkUpdate = true;                            
                        }
                    }
                    if(cs.IsClosed && stopClosedEmailByRecordType != null && !stopClosedEmailByRecordType.isEmpty() && stopClosedEmailByRecordType.containsKey(cs.RecordTypeName__c) && 
                           !stopClosedEmailByRecordType.get(cs.RecordTypeName__c).isEmpty() && caseIds.containsKey(cs.Id) && caseIds.get(cs.Id) != null) {
                            Set<String> e2cOOOList = stopClosedEmailByRecordType.get(cs.RecordTypeName__c);
                            for(String e2cOOO : e2cOOOList){
                                if(e2cOOO != null){
                                    for(EmailMessage e : newList) {
                                        if(e.Incoming && e.ParentId != null && e.Subject != null && e.Subject.containsIgnoreCase(e2cOOO)){
                                            isNotOutofOffice = false;
                                        }
                                    }
                               }
                        
                            }
                    }
                    if((cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                        activityList.add(createRndActivity(cs, true, firstE2c,caseIds.get(cs.Id)));
                        cs.Last_Incoming_Email_Date__c = System.now();
                        if(CON_CSM.S_NEW != cs.Status && ((senderEmailsByRecordType != null && !senderEmailsByRecordType.isEmpty() && senderEmailsByRecordType.containsKey(cs.RecordTypeName__c) && 
                           !senderEmailsByRecordType.get(cs.RecordTypeName__c).isEmpty() && caseIds.containsKey(cs.Id) && caseIds.get(cs.Id) != null && 
                           !senderEmailsByRecordType.get(cs.RecordTypeName__c).contains(caseIds.get(cs.Id).FromAddress)))) {
                            cs.SubStatus__c = CON_CSM.S_RESPONSE_RECEIVED;
                            if(!cs.Is_Parent__c && cs.IsClosed && (cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                                cs.Is_Parent__c = true;
                            }
                        }
                        checkUpdate = true;
                    }
                    
                    if(!String.isBlank(cs.CaseNumber) && cs.AFU_TECH__c ) {
                        cs.AFU_TECH__c = false;
                        checkUpdate = true;
                    }
                    if(cs.IsClosed && !mapOfQueue.isEmpty() && mapOfQueue.containsKey(cs.CurrentQueue__c) && mapOfQueue.get(cs.CurrentQueue__c).Name == CON_CSM.S_DATA_GLOBAL_ESERVICE_QUEUE) {
                        cs.status = CON_CSM.S_IN_PROGRESS;
                        isNotDataEService = false;
                        checkUpdate = true;
                    }
					
                    if(checkUpdate){
                        updateCase.add(cs);
                    }
                    
                }
                if(DAOH_Case.isRndEmailCreatedFromCase){
                    if(!activityList.isEmpty()){
                        try{
                            insert activityList;
                        }catch (DmlException e) {
                            System.debug('Failed due to : '+e);
                        }
                    }
                }
                if(!System.isBatch() && !System.isFuture()){
                    String cases = null,activity = null;
                    if(!updateCase.isEmpty()){
                        cases = JSON.serialize(updateCase);
                    }
                    if(!activityList.isEmpty()){
                        activity = JSON.serialize(activityList);
                    }
                    updateIncomingCaseDetails(cases,activity);
                    if(!incomingCases.isEmpty() && isNotDataEService && isNotOutofOffice){
                        mailSenderWhenEmailReceivedOnTechClosedCase(incomingCases.values(),contMap,fromEmail);  
                    }
                    if(firstE2c){
                        if(UserInfo.getName() == CON_CSM.S_SYSTEM || Test.isRunningTest()) {
                            DAOH_Case.insertCaseinInternalServiceNow(updateCase,null);
                        }
                        stopDuplicateCaseCreationinToAddress(newList);
                        sendEMailtoCcList(updateCase,acctMap,contMap,ccEmailSet);
                    }
                }
                
            }
        }
        
    }
    
    @future
    public static void updateIncomingCaseDetails(String jsonCase,String activityList){
        if(activityList != null){
            List<Activity__c> newList = (List<Activity__c>)JSON.deserialize(activityList, List<Activity__c>.Class);
            if(newList != null && !newList.isEmpty()){
                try{
                    insert newList;
                }catch (DmlException e) {
                    System.debug('Failed due to : '+e);
                }
            }
        }
        if(jsonCase != null){
            List<Case> caseList = (List<Case>)JSON.deserialize(jsonCase, List<Case>.class);
            if(caseList != null && !caseList.isEmpty()){
                try{
                    update caseList; 
                }catch (DmlException e) {
                    System.debug('Failed due to : '+e);
                }
            }    
        }
         
    }
    
    public static void sendEMailtoCcList(List<Case> caseList,Map<Id,Account> accMap,Map<Id,Contact> conMap,Set<String> emailList){
        Map<String,Id> emailTempMap = new Map<String,Id>();
        List<String> prodOpsList = new List<String>{'organoneb@iqvia.com','tsprodops-general@iqvia.com','tsprodops-change@iqvia.com','tsprodops-request@iqvia.com'};
        if(!caseList.isEmpty()){
            List<EmailTemplate> emailTempList = Database.query('select Id, Name, DeveloperName, IsActive, TemplateType, Encoding, Description, Subject from EmailTemplate where (DeveloperName like \'CSM_ET_TECH_%_Case_Collabrator_DESC_Creation\' or DeveloperName = \'CSM_DATA_E2C_Eservice_Case_Collabrator_Creation\') and IsActive = true');
            for(EmailTemplate e : emailTempList){
                emailTempMap.put(e.DeveloperName, e.Id);
            }
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            CSM_Case_Details_Global_Setting__c orgRep = CSM_Case_Details_Global_Setting__c.getInstance('Org Wide ReplytoCSM');
            CSM_Case_Details_Global_Setting__C orgNo = CSM_Case_Details_Global_Setting__C.getInstance('Org Wide No-Reply');
			String contLang = 'EN';
            for(Case c : caseList){
                if(c.From_EmailToCase__c != null){
                    if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                        if(!prodOpsList.contains(c.From_EmailToCase__c) && c.AccountId != null && c.contactId != null && accMap.containsKey(c.AccountId) && accMap.get(c.AccountId).SendCaseCollaborationEmail__c  && conMap.containsKey(c.ContactId)){
                                if(conMap.get(c.ContactId).PreferredLanguage__c != null){
                                    contLang = conMap.get(c.ContactId).PreferredLanguage__c;
                                }
                                if(contLang.contains('en_')){
                                    contLang = 'EN';
                                }else if(!contLang.contains('_')){
                                    contLang = contLang.toUpperCase();
                                }
                            if(emailTempMap.containsKey('CSM_ET_TECH_'+contLang+'_Case_Collabrator_DESC_Creation')){
                                mail = Messaging.renderStoredEmailTemplate(emailTempMap.get('CSM_ET_TECH_'+contLang+'_Case_Collabrator_DESC_Creation'), c.ContactId, c.Id);
                            }else{
                                mail = Messaging.renderStoredEmailTemplate(emailTempMap.get('CSM_ET_TECH_EN_Case_Collabrator_DESC_Creation'), c.ContactId, c.Id);
                            }
                        }else if(c.AccountId == null || prodOpsList.contains(c.From_EmailToCase__c)){
                            mail = Messaging.renderStoredEmailTemplate(emailTempMap.get('CSM_ET_TECH_EN_Case_Collabrator_DESC_Creation'), c.ContactId, c.Id);
                        }
                        mail.setSaveAsActivity(false);
                        mail.setToAddresses(new List<String>(emailList));
                        mail.setTreatTargetObjectAsRecipient(false);
                        mail.setReplyTo('replytocsm@iqvia.com');
                        if(orgRep != null){
                            mail.setOrgWideEmailAddressId(orgRep.Component_Id__c);
                        }
                        mail.setReferences(Cases.generateThreadingMessageId(c.Id));
                        messages.add(mail);
                    }else if(c.RecordTypeName__c == CON_CSM.S_DATACASE && c.AccountId != null && c.contactId != null && accMap.containsKey(c.AccountId) && accMap.get(c.AccountId).SendCaseCollaborationEmail__c ){
                        mail = Messaging.renderStoredEmailTemplate(emailTempMap.get('CSM_DATA_E2C_Eservice_Case_Collabrator_Creation'), c.ContactId, c.Id);
                        mail.setSaveAsActivity(false);
                        mail.setToAddresses(new List<String>(emailList));
                        mail.setTreatTargetObjectAsRecipient(false);
                        if(orgNo != null){
                            mail.setOrgWideEmailAddressId(orgNo.Component_Id__c);
                        }
                        mail.setReplyTo('no.reply.support@iqvia.com');
                        mail.setReferences(Cases.generateThreadingMessageId(c.Id));
                        messages.add(mail);
                    }
                }
            }
            
            if(!messages.isEmpty()){
                try{
                    Messaging.sendEmail(messages);
                }catch(Exception ex){
                    System.debug('Exception occured at sendEMailtoCcList : '+ex.getMessage());
                }
            }
        }
    }
    
    /** public static void createCaseCollabration(List<EmailMessage> newList){
        Set<Id> caseIds = new Set<Id>();
        List<string> emailToRemoveSet = new List<String>{'email2casecsm@quintilesims.com','email2casecsm@iqvia.com','replytocsm@iqvia.com'};
        for(EmailMessage c : newList) {
            if(c.ParentId != null && c.Incoming){
                caseIds.add(c.ParentId);   
            }
        }
        
        if(!caseIds.isEmpty()){
            List<Case> caseList = new SLT_Case().selectByEmailMessage(caseIds);
            List<EmailMessage> emailms = new SLT_EmailMessage().getEmailsByParendIds(caseIds);
            // storing cc and bcc email address list
            List<String> emailAddress = new List<String>();
            if(caseList != null && emailms != null && emailms.size() == 1)
            {
                Case_Collabrator__c cc = new Case_Collabrator__c();
                cc.Case__c = caseList.get(0).Id;
                cc.Case_Description__c = caseList.get(0).Description;
                cc.Case_CreatedDate__c = caseList.get(0).CreatedDate;
                for(EmailMessage em : newList){
                    if(!String.isBlank(em.CcAddress)){
                        if(em.CcAddress.contains(';')){
                            emailAddress.addAll((em.CcAddress.toLowerCase()).split(';'));
                        }else{
                            emailAddress.add(em.CcAddress.toLowerCase());
                        }
                    }
                    if(!String.isBlank(em.BccAddress)){
                        if(em.BccAddress.contains(';')){
                            emailAddress.addAll((em.BccAddress.toLowerCase()).split(';'));
                        }else{
                            emailAddress.add(em.BccAddress.toLowerCase());
                        }
                    }
                }    
                
                for(Integer index = (emailAddress.size()-1); index >= 0 ;index--) {
                        if(emailToRemoveSet.contains(emailAddress.get(index).trim())) {
                            emailAddress.remove(index);
                        }
                }
                
                SObjectType objToken = Schema.getGlobalDescribe().get('Case_Collabrator__c');
                DescribeSObjectResult objDef = objToken.getDescribe();
                Map<String, SObjectField> fields = objDef.fields.getMap(); 
                
                Set<String> fieldSet = fields.keySet();
                integer i=0;
                for(String s:fieldSet)
                {
                    SObjectField fieldToken = fields.get(s);
                    DescribeFieldResult selectedField = fieldToken.getDescribe();
                    if(selectedField.getName().indexOf('Address')!= -1 && emailAddress.size() > i){
                        if((emailAddress.get(i).length()) > 80){
                            if(emailAddress.get(i).contains('recipients_cn=')){
                                List<String> emails =  new List<String>();
                                emails = emailAddress.get(i).Split('recipients_cn=');
                                if(emails[1].length() < 81 ){
                                    cc.put(s, emails[1]);
                                }
                            }
                        }else{
                            cc.put(s, emailAddress.get(i));
                        }
                        i++;
                    }
                    
                }
                if(!emailAddress.isEmpty() && emailAddress.size() > 0 && (cc.Address1__c != null || cc.Address10__c != null)){
                    insert cc;    
                }
            }
        }
    }*/
    
    public static void cloneCaseStatusIsClosedEmailMessageonCase(List<EmailMessage> newList){
        Map<Id,EmailMessage> caseIds = new Map<Id,EmailMessage>();
        List<Case> cloneCaseList = new List<Case>();
        Case cloneCase = null;
        Map<Id,Case> caseMap = null;
        Set<String> caseField = null;
        String initialQueue = null;
        Set<Id> emIdSet = new Set<Id>();
        List<String> fieldsList = new List<String>();
        Set<Id> ids = new Set<Id>();
        boolean isCaseNotOpned = true;
        for(EmailMessage c : newList) {
            if(c.ParentId != null && c.Incoming){
                caseIds.put(c.ParentId,c);   
            }
        }
        
        if(caseIds!=null && !caseIds.isEmpty()){
            caseField = new Set<String>();
            String caseFieldString = 'AFU_TECH__c, Case_ThreadToken__c, Contact, Description, Origin, Parent, Priority, Subject, SuppliedName, Type, CSAT_Responded__c, CSAT_Sent__c, CaseOriginatorEmail__c, CaseOriginatorName__c, CaseTaskAction__c, First_Escalation_Time__c, Milestone_Violation__c, TaskMilestone__c, Techno_Impact__c, Urgency__c, '+
                'AFU_Next_Date__c, AFU_TimeStamp__c, Automated_FU_Email__c, CSM_QI_Data_Originator__c, Count_of_AFU__c, G_Inquiry_Investigation__c, Jira_Issue__c, Update_Survey_Sent_Date__c, Web2Case_Asset__c, Web2Case_CurrentQueue__c, Owner__c, ProductName__c, ServiceNow_Last_Updated_Date__c, Service_Now_Incident_Number__c, Service_Now_Type__c, SoftwareUpdatePatchHotFixNumber__c, StudyProtocolName__c, SubType1__c, SubType2__c, Version__c, Affects_Version__c, '+
                'ActualElapsedTimeInDays__c, ActualElapsedTimeInHrs__c, ActualElapsedTimeInMins__c, CMDB__c, IfyeshowmanylookupsrequiredCorrec__c, RequireAction__c, ResolutionsharedwithCustomer__c, SubType3__c, SupportTier__c, Target_Date__c, AssignCaseToCurrentUser__c, AutoClosed__c, ComplexityLevel__c, ConsumerHealthData__c, Customer_Requested_Date__c, Describetheissuedifferenceindetail__c, IssuedDifferencepreresearchconducted__c, ResolutionCode__c, ServiceNow_Group__c, ServiceNow_Status__c, Workaround__c, '+
                'Sponsor__c, SubcaseClasification__c, SupplierCustom__c, SupplierName__c, Supplier__c, SwitchAddGracePeriod__c, Tag__c, Timeline__c, TypeCustom__c, UserTrainedDate__c, NumberOfNotifications__c, OnBehalfOf__c, PlanEndDate__c, PlanStartDate__c, Plan_Name__c, PlannedFixDate__c, ProductPackSize__c, Release__c, SendResolutionEmail__c, Site__c, '+
                'CreatedByGroup__c, CreatedDate__c, CustomerRequiredDate__c, CustomerUrgency__c, ForeignCallerId__c, Impact__c, ItemNumber__c, JIRANotes__c, NextNotificationDate__c, NovartisCaseType__c, BusinessHours__c, BusinessUntilDueDate__c, COREClassification__c, CORESubClassification__c, CaseSource__c, ChildCaseDescription__c, CloseCode__c, CloseNotes__c, ConfigurationItem__c, CoreTicket__c, '+
                'ACN__c, Activity__c, AdditionalThirdPartyCase2__c, Approach__c, SlaStartDate, Source, Subject, SuppliedEmail, BusinessHours, Contact, Description, Entitlement, IsEscalated, IsStopped, Origin, Parent, Priority, RandD_Location__c, AdditionalThirdPartyCase__c, BusinessHours__c, CaseSource__c, CaseSubType1__c, '+
                'AccessionNumber__c, Case_CategorizationId__c, CurrentQueue1__c, CurrentQueue__c, IncompleteAMF__c, ProductName__c, Site_Related_to_the_Study__c, SubType1__c, SubType2__c, SubType3__c, ReOpenDate__c, ReOpened__c, ReOpener__c, Resolution__c, SendAutomaticAcknowledgmentEmail__c, SendResolutionEmail__c, Study__c, SubStatus__c, Template__c, ThirdPartyCase__c, '+
                'CaseSubType2__c, CaseSubType3__c, ClosedBy__c, Current_Queue__c, FollowUpDateLevel__c, LIMSLevel__c, LOS__c, LastModifiedDate__c, NoContactKnown__c, OnBehalfOf__c, RecordTypeName__c, ServiceNowSystemType__c, Region_Supported__c';
            fieldsList = caseFieldString.split(',');
            for(String field : fieldsList){
                caseField.add(field.trim());
            }
            caseMap = new SLT_Case().getCaseById(caseIds.keySet(),caseField);
            if(caseMap != null && !caseMap.isEmpty()){
                for(Case cs : caseMap.values()){
                    if((cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE) && CON_CSM.S_CLOSED == cs.Status){
                      
                        if(cs.ParentId != null){
                            ids.add(cs.ParentId);
                        }else{
                            ids.add(cs.Id);
                        }
                    }  
                }
                List<Case> csList = new SLT_Case().getOpenChildCases(ids);
                EmailMessage em = null;
                List<EmailMessage> emList = new List<EmailMessage>();
                if(csList != null && !csList.isEmpty()){
                    for(EmailMessage c : newList) {
                        if(c.ParentId != null && c.Incoming){
                             em = c.clone();
                            em.ParentId = csList[0].Id;
                            em.RelatedToId = csList[0].Id;
                            emList.add(em);
                        }
                    }
                }
                
                if(emList != null && !emList.isEmpty()){
                    insert emList;
                    isCaseNotOpned = false;
                }
            }
            if(isCaseNotOpned){
                for(Case cs : caseMap.values()){
                    if((cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE) && CON_CSM.S_CLOSED == cs.Status)
                    {
                        cloneCase = cs.clone();
                        cloneCase.CreateChildCase__c = true;
                        initialQueue = cs.CurrentQueue__c;
                        cloneCase.ParentId = cs.ParentId != null ? cs.ParentId : cs.Id;
                        cloneCase.Status = CON_CSM.S_NEW;
                        cloneCase.Origin = CON_CSM.S_EMAIL;
                        cloneCase.SubStatus__c = '';
                        cloneCase.ClosedDate = null;
                        cloneCase.Case_ThreadToken__c = null;
                        cloneCase.IsStopped = false;
                        cloneCase.StoppedTimeInDays__c = null;
                        cloneCase.StoppedTimeInHrs__c = null;
                        cloneCase.StoppedTimeInHrs__c = null;
                        cloneCase.Service_Now_Incident_Number__c = null;
                        cloneCase.ServiceNow_Group__c = null;
                        cloneCase.ServiceNow_Status__c = null;
                        cloneCase.ServiceNow_Last_Updated_Date__c = null;
                        cloneCase.Service_Now_Type__c = null;
                        cloneCase.CloseCode__c = null;
                        cloneCase.Customer_Requested_Date__c = null;
                        cloneCase.CloseNotes__c = null;
                        cloneCase.SlaStartDate = null;
                        cloneCaseList.add(cloneCase);
                        if(caseIds.containsKey(cs.Id)){
                            cloneCase.Owner__c = caseIds.get(cs.Id).Id;
                        }
                    }else if(cs.Owner__c != null && cs.Owner__c.startsWith('02s') && (cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                        emIdSet.add(cs.Owner__c);
                    }
                }
                if(initialQueue != null){
                    List<Queue_User_Relationship__c> initial = new SLT_QueueUserRelationshipC().selectByQueueIdSet(new Set<Id>{initialQueue},new Set<String>{'Id','Name','User__c','Group_Id__c'});
                    for(Case cas : cloneCaseList){
                        if(initial != null && !initial.isEmpty()){
                            cas.OwnerId = initial[0].Group_Id__c;
                            cas.CurrentQueue__c = initial[0].Id;
                            cas.InitialQueue__c = initial[0].Name;
                        }
                    }
                }
                if(!cloneCaseList.isEmpty() && !System.isBatch() && !System.isFuture()){
                    rndChildCaseCreate(JSON.serialize(cloneCaseList));
                }
                if(!emIdSet.isEmpty()){
                    List<ContentDocumentLink> closeAtt = new List<ContentDocumentLink>();
                    List<ContentDocumentLink> attachList = Database.query('SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.ContentModifiedDate, ContentDocument.ContentSize FROM ContentDocumentLink WHERE LinkedEntityId in :emIdSet');
                    ContentDocumentLink att = null;
                    for(ContentDocumentLink a : attachList){
                        att = a.clone();
                        att.LinkedEntityId = newList[0].Id;
                        att.ShareType = 'V';
                        closeAtt.add(att);
                    }
                
                    if(!closeAtt.isEmpty()){
                        insert closeAtt;
                    }
                }
            
            }
        }
    }
    
    @future
    public static void rndChildCaseCreate(String jsonCase){
        List<Case> caseList = (List<Case>)JSON.deserialize(jsonCase, List<Case>.class);
        if(caseList != null && !caseList.isEmpty()){
            try{
                insert caseList;
            }Catch(Exception e){
                
            }
        } 
    }
    
    public static void mailSenderWhenEmailReceivedOnTechClosedCase(List<Case> caseList, Map<Id,Contact> conMap,Map<Id,String> fromMap) {
        List<Messaging.SingleEmailMessage> mails = new List <Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = null;
        CSM_Case_Details_Global_Setting__c noReply = CSM_Case_Details_Global_Setting__c.getValues('Org Wide No-Reply');
        if (caseList != null && !caseList.isEmpty()) {
            Map<Id, String> conEmailMap = new Map<Id, String>();
            Set<String> tempSet = new Set<String>();
            if(conMap != null && !conMap.isEmpty()){
                for(Contact ct : conMap.values()){
                    conEmailMap.put(ct.Id, ct.Email);
                    if(ct.PreferredLanguage__c != null){
                        if(ct.PreferredLanguage__c.contains('_')){
                            tempSet.add('ET_TECH_'+ct.PreferredLanguage__c.substringBefore('_')+'_CLOSED_RESPONSE_TEMPLATE');
                        }else{
                            tempSet.add('ET_TECH_'+ct.PreferredLanguage__c+'_CLOSED_RESPONSE_TEMPLATE');
                        }
                    }else{
                        tempSet.add('ET_TECH_EN_CLOSED_RESPONSE_TEMPLATE'); 
                    }
                }
            }
            List<EmailTemplate> emailTemp = new List<EmailTemplate>();
            
            if(tempSet != null){
                if(!tempSet.contains('ET_TECH_EN_CLOSED_RESPONSE_TEMPLATE')){
                    tempSet.add('ET_TECH_EN_CLOSED_RESPONSE_TEMPLATE');
                }
                emailTemp = Database.query('Select id, Body from EmailTemplate where DeveloperName in :tempSet order by CreatedDate desc');
            }
            for (Case cs: caseList) {
                if ((CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c || CON_CSM.S_R_D_CTP == cs.RecordTypeName__c || (CON_CSM.S_DATACASE == cs.RecordTypeName__c && cs.AccountCountry__c != 'NZ' && cs.AccountCountry__c != 'AU')) && cs.IsClosed) {
                    if (emailTemp != null && !emailTemp.isEmpty()) {
                        mail = Messaging.renderStoredEmailTemplate(emailTemp[0].id, cs.ContactId, cs.Id);
                    }else{
                        mail = new Messaging.SingleEmailMessage();
                        mail.plaintextbody='This is to inform you that case is already closed and email sent on closed case is not taken into consideration. ';
                        mail.subject=cs.Subject +' -'+ cs.CaseNumber ; 
                    }
                    String senderId = '';
                    if(noReply != null){
                        senderId = noReply.Component_Id__c;
                    }
                    if(senderId != null && senderId.length() > 0) {
                        mail.setOrgWideEmailAddressId(senderId);
                    }
                    if(conEmailMap.get(cs.ContactId) == null){
                        mail.setToAddresses(new List<String>{fromMap.get(cs.Id)});
                        mail.setTreatTargetObjectAsRecipient(false);
                    }
                    mail.setTargetObjectId(cs.ContactId);
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(cs.Id);
                    mail.setReferences(Cases.generateThreadingMessageId(cs.Id));
                    mails.add(mail);
                }
            }
            if(!mails.isEmpty()){
                try{
                    Messaging.sendEmail(mails);
                }catch(Exception ex){}
            }
        }
    
    }
    
    /** public static void MailSenderWhenEmailReceivedOnTechClosedCase(List < EmailMessage > newList) {
        Map < Id, EmailMessage > caseIds = new Map < Id, EmailMessage > ();
        List < Case > caseList = null;
        List<EmailTemplate> emTmpl = new List<EmailTemplate>();
        for (EmailMessage c: newList) {
            if (c.ParentId != null && c.Incoming) {
                caseIds.put(c.ParentId, c);
            }
        }
        List<Messaging.SingleEmailMessage> mails = new List <Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        if (caseIds != null && !caseIds.isEmpty()) {
            caseList = new SLT_Case().selectById(caseIds.keySet());
            Set<Id> contactIds = new Set<Id>();
            for(Case c : caseList){
                if(c.ContactId != null){
                    contactIds.add(c.contactId);
                }
            }
            List<Contact> conList = new SLT_Contact().getContactEmails(contactIds);
            Map<Id, String> conEmailMap = new Map<Id, String>();
            Set<String> tempSet = new Set<String>();
            for(Contact ct : conList){
                conEmailMap.put(ct.Id, ct.Email);
                if(ct.PreferredLanguage__c != null){
                    if(ct.PreferredLanguage__c.contains('_')){
                        tempSet.add('ET_TECH_'+ct.PreferredLanguage__c.substringBefore('_')+'_CLOSED_RESPONSE_TEMPLATE');
                    }else{
                        tempSet.add('ET_TECH_'+ct.PreferredLanguage__c+'_CLOSED_RESPONSE_TEMPLATE');
                    }
                }else{
                   tempSet.add('ET_TECH_EN_CLOSED_RESPONSE_TEMPLATE'); 
                }
            }
            List<String> toAddresses = null;
            List<EmailTemplate> emailTemp = new List<EmailTemplate>();
            if(tempSet != null){
                if(!tempSet.contains('ET_TECH_EN_CLOSED_RESPONSE_TEMPLATE')) tempSet.add('ET_TECH_EN_CLOSED_RESPONSE_TEMPLATE');
                emailTemp = Database.query('Select id, Body from EmailTemplate where DeveloperName in :tempSet order by CreatedDate desc');
            }   
            for (Case cs: caseList) {
                if (CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && caseIds.get(cs.Id).Incoming && CON_CSM.S_CLOSED == cs.Status) {
                    
                    if (emailTemp != null && !emailTemp.isEmpty()) {
                        mail = Messaging.renderStoredEmailTemplate(emailTemp[0].id, cs.ContactId, cs.Id);
                    }
                    else
                    {
                        mail.plaintextbody='This is to inform you that case is already closed and email sent on closed case is not taken into consideration. ';
                        mail.subject=cs.Subject +' -'+ cs.CaseNumber ; 
                    }
                    String senderId = '';
                    if(DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL)!=null)
                        senderId= DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL).Component_Id__c;                         
                    
                    if(senderId != null && senderId.length() > 0) {
                        mail.setOrgWideEmailAddressId(senderId);
                    }
                    if(conEmailMap.get(cs.ContactId) == null){
                        toAddresses = new List<String>();
                        toAddresses.add(caseIds.get(cs.Id).FromAddress);
                        mail.setToAddresses(toAddresses);
                        mail.setTreatTargetObjectAsRecipient(false);
                    }
                    mail.setTargetObjectId(cs.ContactId);
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(cs.Id);
                    mail.setReferences(Cases.generateThreadingMessageId(cs.Id));
                    mails.add(mail);
                    if(mails.Size() > 0){
                        try{
                            Messaging.sendEmail(mails);
                        }catch(Exception ex){}
                    } 
                }
            }
        }
    }
    
    public static Map<String,CSM_QI_EmailToCaseRouting__c> emailToCase;
    public static Map<String, Set<String>> senderEmailsByRecordType;
    public static Map<String,CSM_QI_EmailToCaseRouting__c> getCSMEmailToCaseRouting() {
        if(emailToCase == null && senderEmailsByRecordType == null) {
            emailToCase = new Map<String,CSM_QI_EmailToCaseRouting__c>();
            senderEmailsByRecordType = new Map<String, Set<String>>();
            List<CSM_QI_EmailToCaseRouting__c> lst = CSM_QI_EmailToCaseRouting__c.getall().values();
            for(CSM_QI_EmailToCaseRouting__c c : lst) {
                if(c.RouteEmail__c != null) {
                    emailToCase.put(c.RouteEmail__c, c);
                }
                if(c.SenderEmailToExclude__c != null && c.SenderEmailToExclude__c != '' && c.RecordTypeName__c != null) {
                    Set<String> senderEmails = new Set<String>();
                    senderEmails.addAll(c.SenderEmailToExclude__c.split(';'));
                    senderEmailsByRecordType.put(c.RecordTypeName__c, senderEmails);
                }
            }
        }
        return emailToCase; 
    }*/
    
    public static void updateDeletedEmailAttachmentCountOnCase(List<EmailMessage> emailList){
        Set<Id> emailIds = new Set<Id>();
        for(EmailMessage emailRecord : emailList){
            if(emailRecord.ParentId != null && emailRecord.Incoming){
                emailIds.add(emailRecord.Id);
            }
        }
        if(emailIds != null && emailIds.size() > 0){
            List<EmailMessage> emailMessageCaseList = new SLT_EmailMessage().getCaseAttachmentListOnEmails(emailIds);
            if(emailMessageCaseList != null && emailMessageCaseList.size() > 0){
                List<Case> caseList = new List<Case>();
                for(EmailMessage emailRecord : emailMessageCaseList){
                    if(emailRecord.Attachments != null && emailRecord.Attachments.size() > 0){
                        if(emailRecord.Parent.Attachments__c != null){
                            Case caseRecord = new Case();
                            caseRecord.Id = emailRecord.ParentId;
                            Double attachmentCount = emailRecord.Parent.Attachments__c - emailRecord.Attachments.size();
                            caseRecord.Attachments__c = attachmentCount;
                            caseList.add(caseRecord);
                        }
                    }
                }
                if(caseList != null && caseList.size() > 0){
                    try{
                        update caseList;
                    }
                    catch(Exception ex){
                        ex.getStackTraceString();
                    }
                }
            }
        }
    }
    
    public static void caseClosedRnDRestrictEmail(List<EmailMessage> newList){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        Map<Id,EmailMessage> caseIds = new Map<Id,EmailMessage>();
        boolean check = false;
        boolean checkAccount = false;
        for(EmailMessage e : newList) {
            if(e.ParentId != null && !e.Incoming){
                caseIds.put(e.ParentId,e);   
            }
        }
        selectCaseDetails(newList,null);
        if(outgoingCases != null && !outgoingCases.isEmpty()){
            List<Case> caseList = outgoingCases.values(); 
            if(caseList != null && !caseList.isEmpty()) 
            {
                for(Case c : caseList){
                    if(c.isClosed == true && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T)){
                        check = true;
                        break;
                    }else if(c.AccountID == null && c.RecordTypeName__c == CON_CSM.S_R_D_CTP && c.RecordTypeName__c != CON_CSM.S_R_D_CDP && c.RecordTypeName__c != CON_CSM.S_R_D_V_T && c.RecordTypeName__c != CON_CSM.S_RDCASE && c.RecordTypeName__c != CON_CSM.S_ACTIVITY_R_T){
                        checkAccount = true;
                        break;
                    }
                }
                for(EmailMessage e : newList) {
                    if(check && hasCustomPermission == false){
                        e.addError('User not allowed to edit or send an email to the closed case.');
                    }else if(checkAccount && hasCustomPermission == false){
                        e.addError('Please select the Account.');
                    }
                }
            }
        }
    }
    
    public static void deleteEmailMessagefromCaseorNot(List<EmailMessage> newList){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        Set<Id> caseIds = new Set<Id>();
        for(EmailMessage e : newList) {
            if(e.ParentId != null){
                caseIds.add(e.ParentId);   
            }
        }
        
        if(!caseIds.isEmpty()){
            Map<Id,Case> caseMap = new SLT_Case().getCaseById(caseIds, new Set<String>{'Id','RecordTypeName__c'}); 
            
            if(caseMap != null && !caseMap.isEmpty()) 
            {
                String profileName = [Select Id,Name from Profile where Id=: UserInfo.getProfileId()].Name; 
                Boolean allow = true;
                CSM_QI_Data_Audit_Trail__c auditTrail = null;
                List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
                if(!Test.isRunningTest()){
                    String userId = UserInfo.getUserId();
                    if(userId != null){
                        List<PermissionSetAssignment> psa = DataBase.query('SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = \'CSM_R_D_ByPass_Email_Deletion\' and AssigneeId =: userId');
                        if(psa != null && !psa.isEmpty()){
                            allow = false;
                        }
                    }
                }
                for (EmailMessage a : (List<EmailMessage>)Trigger.old)
                {  
                    if(a.Status != '5'){
                        if(!profileName.containsIgnoreCase(CON_CSM.S_SYSTEM) && caseMap.containsKey(a.ParentId) && (caseMap.get(a.ParentId).RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || caseMap.get(a.ParentId).RecordTypeName__c == CON_CSM.S_RDCASE) && allow && hasCustomPermission == false){
                            Trigger.oldMap.get(a.Id).addError('Cannot delete Email with related to Case');
                        }else if (allow && (profileName == 'Service User' || profileName == 'CSM Customer Community Plus Login User') && hasCustomPermission == false)
                        {
                            Trigger.oldMap.get(a.Id).addError('Cannot delete Email with related to Case');
                        }else{
                            auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name=CON_CSM.S_EMAILMESSAGE,Case__c = a.ParentId);
                            auditTrailList.add(auditTrail);
                        }
                    }
                }
                if(auditTrailList != null){
                    insert auditTrailList;
                }
            }
        }
    }
    
    public static Map<String,String> e2cPriorityMap;
    public static Map<String,String> getCSMSenderE2CPriority() {
        List<CSM_Case_Priority_and_E2C_Sender_Config__c> e2cPriorityList = new List<CSM_Case_Priority_and_E2C_Sender_Config__c>();
        if(e2cPriorityMap == null) {
            e2cPriorityMap = new Map<String, String>();
            e2cPriorityList = CSM_Case_Priority_and_E2C_Sender_Config__c.getall().values();
            for(CSM_Case_Priority_and_E2C_Sender_Config__c con  : e2cPriorityList){
                String keyV = (con.Sender_Email_Address__c+'~'+con.E2C_Address__c).toLowercase();
                e2cPriorityMap.put(keyV, con.Priority__c);
            }
        }
        return e2cPriorityMap;    
    }
    
    public static Activity__c createRndActivity(Case cs, boolean isIncoming,boolean firstE2c,EmailMessage em) {
        Activity__c act = new Activity__c();
        act.Case__c = cs.Id;
        act.LOS__c = cs.LOS__c;
        if(cs.ContactId != null){
            act.Contact__c = cs.ContactId;
        }
        if(cs.AccountId != null){
            act.Site__c = cs.AccountId; 
        }
        if(cs.Study__c != null){
            act.Study__c = cs.Study__c;
        }
        if(cs.RandD_Location__c != null){
            act.RandD_Location__c = cs.RandD_Location__c;
        }
        if(firstE2c && cs.Origin == CON_CSM.S_O_VOICE){
            act.Type__c = isIncoming ? CON_CSM.S_O_VOICE_REC : CON_CSM.S_EMAILOUTBOUND;
        }else{
            act.Type__c = isIncoming ? CON_CSM.S_EMAILINBOUND: CON_CSM.S_EMAILOUTBOUND;
        }
        if(isIncoming){
            act.Status__c = 'Open';
        }
		
        act.Description__c = (em.TextBody != null)? em.TextBody : (em.HtmlBody != null)? em.HtmlBody.stripHtmlTags() : em.HtmlBody;
        act.StartDatetime__c = System.now();
        act.ActivityOwner__c = UserInfo.getUserId();
        act.RecordTypeId = CON_CSM.S_ACTIVITY_RT;
        act.EmailMessageId__c = em.Id;
        if(act.Type__c == CON_CSM.S_EMAILINBOUND || act.Type__c == CON_CSM.S_EMAILOUTBOUND || act.Type__c == CON_CSM.S_O_VOICE_REC){
            act.From_Address__c = em.FromAddress;
            act.To_Address__c = em.ToAddress;
            if(act.Type__c == CON_CSM.S_EMAILINBOUND && cs.Status == CON_CSM.S_CASE_CLOSED){
                act.Email_Categorization__c = CON_CSM.S_EC_NON_ACTIONABLE;
            }
        }
        return act;
    }

    public static void checkTagsInEmailMessageForCaseFields(List<EmailMessage> emailList){
        Map<Id, Map<String, String>> caseIdFieldMap = new Map<Id, Map<String, String>>();
        Map<String, String> fieldMap = new Map<String, String>();
        Set<String> fieldValueSet = new Set<String>();
        List<CSM_E2C_CaseTags__c> caseTagList = null;
        for(EmailMessage email : emailList){
            if(email.ParentId != null && email.Incoming){
                if(email.TextBody != null && email.TextBody.contains('<-')){
                    fieldMap = createFieldNameValueMapFromEmail(email.TextBody);
                    if(fieldMap != null && !fieldMap.isEmpty()){
                        caseIdFieldMap.put(email.ParentId, fieldMap);
                        if(fieldMap.containsKey(CON_CSM.S_CURRENT_QUEUE)){
                            fieldValueSet.add(fieldMap.get(CON_CSM.S_CURRENT_QUEUE));
                        }
                        if(fieldMap.containsKey(CON_CSM.S_CASE_OWNER)){
                            fieldValueSet.add(fieldMap.get(CON_CSM.S_CASE_OWNER));
                        }
                    }
                }
            }
        }
        
        if(!caseIdFieldMap.isEmpty()){
            Set<String> fieldSet = new Set<String>();
            caseTagList = CSM_E2C_CaseTags__c.getall().values();
            fieldSet.add('Id');
            fieldSet.add('RecordTypeName__c');
            for(CSM_E2C_CaseTags__c ct : caseTagList){
                fieldSet.add(ct.Field_API__c);
            }
            List<Case> caseList = new SLT_Case().selectByCaseIdList(caseIdFieldMap.keySet(),fieldSet);
            Map<String, Id> queueNameIdMap = new Map<String, Id>();
            Map<String, Id> groupNameIdMap = new Map<String, Id>();
            if(!fieldValueSet.isEmpty()){
                List<Queue_User_Relationship__c> queueList = new SLT_QueueUserRelationshipC().selectByQueueName(fieldValueSet);
                if(queueList != null && !queueList.isEmpty()){
                    for(Queue_User_Relationship__c q : queueList){
                        queueNameIdMap.put(q.Name, q.Id);
                        groupNameIdMap.put(q.Name, q.Group_Id__c);
                    }
                }
            }
            /** if(!groupValueSet.isEmpty()){
                List<Group> groupList = new SLT_Groups().getGroupByNameSet(new Set<String>{'Id', 'Name'}, groupValueSet);
                if(groupList != null && !groupList.isEmpty()){
                    for(Group groupRecord : groupList){
                        groupNameIdMap.put(groupRecord.Name, groupRecord.Id);
                    }
                }
            }*/
            
            if(caseList != null && !caseList.isEmpty()){
                List<Case> updatedCaseList = new List<Case>();
                boolean check = false;
                for(Case caseRecord : caseList){
                    Decimal timeDifference = Math.floor(Decimal.valueOf(caseRecord.LastModifiedDate.getTime() - caseRecord.CreatedDate.getTime())/(1000*60));
                    if(caseIdFieldMap.containsKey(caseRecord.Id)){
                        Set<String> fieldLabels = caseIdFieldMap.get(caseRecord.Id).keySet();
                        for(CSM_E2C_CaseTags__c caseTag : caseTagList){
                            List<String> recordTypesList = caseTag.RecordTypeNames__c.trim().split('\\s*,\\s*');
                            if(recordTypesList.contains(caseRecord.RecordTypeName__c) && fieldLabels.contains(caseTag.Field_Label__c)){
                                if(caseIdFieldMap.get(caseRecord.Id).containsKey(caseTag.Field_Label__c)){
                                    if(caseTag.Field_Label__c == CON_CSM.S_CURRENT_QUEUE && !queueNameIdMap.isEmpty() && timeDifference <= 1){
                                        caseRecord.put(caseTag.Field_API__c, queueNameIdMap.get(caseIdFieldMap.get(caseRecord.Id).get(caseTag.Field_Label__c)));
                                        check = true;
                                    }
                                    if(caseTag.Field_Label__c == CON_CSM.S_CASE_OWNER && !groupNameIdMap.isEmpty() && timeDifference <= 1){
                                        caseRecord.put(caseTag.Field_API__c, groupNameIdMap.get(caseIdFieldMap.get(caseRecord.Id).get(caseTag.Field_Label__c)));
                                        check = true;
                                    }
                                    if(caseTag.Field_Label__c != CON_CSM.S_CURRENT_QUEUE && caseTag.Field_Label__c != CON_CSM.S_CASE_OWNER && caseRecord.get(caseTag.Field_API__c) == null){
                                        caseRecord.put(caseTag.Field_API__c, caseIdFieldMap.get(caseRecord.Id).get(caseTag.Field_Label__c));
                                        check = true;
                                    }
                                }
                            }
                        }
                        if(check){
                            updatedCaseList.add(caseRecord);
                        }
                    }
                }

                if(updatedCaseList != null && !updatedCaseList.isEmpty()){
                    try{
                        update updatedCaseList;
                    }
                    catch(Exception ex){
                        ex.getStackTraceString();
                    }
                }
            }
        }
    }
    
    private static Map<String, String> createFieldNameValueMapFromEmail(String message){
        Map<String, String> fieldNameValueMap = new Map<String, String>();
        String[] msgArray = message.split('<-');
        for(String record : msgArray){
            if(record.contains('->')){
                String[] recArray = record.split('->');
                String fieldName = recArray[0];
                String value = recArray[1];
                if(value.contains('<"')){
                    String[] valArray = value.split('<"');
                    String xmlValue = valArray[1];
                    if(xmlValue.contains('">')){
                        String fieldValue = xmlValue.split('">')[0];
                        fieldNameValueMap.put(fieldName, fieldValue);
                    }
                }
            }
        }
        return fieldNameValueMap;
    }
    
    public static void improveQ1CaseCreation(List<EmailMessage> newList){
        if (String.isEmpty(Label.Replytocsm_Email)){
            return;
        }else{
            List<Id> emailMessagesIds = new List<Id>(),caseIds = new List<Id>();
            for(EmailMessage em : newList){
                if(em.ParentId != null && em.Incoming){
                    emailMessagesIds.add(em.Id);
                    caseIds.add(em.ParentId);
                }
            }
            if(!System.isBatch() && !System.isFuture()){
                improveQ1CaseCreation_Future(emailMessagesIds,caseIds);
            }
        }
    }
    
    @future
    private static void improveQ1CaseCreation_Future(List<Id> emailMessagesIds,List<Id> caseId){
        List<EmailMessage> emailMessages = [Select Id, Incoming, ParentId, ToAddress, CcAddress, BccAddress, Subject from EmailMessage where ParentId in :caseId and Incoming = true];
        List<String> emailList = splitEmails(Label.Replytocsm_Email); 
        Set<Id> caseIds = new Set<Id>();
        //Map<Id,String> caseIdSubjectMap = new Map<Id,String>();
        if(emailMessages != null && emailMessages.size() == 1){
            for(EmailMessage emailMessage : emailMessages){
                if(emailMessage.Incoming && emailMessage.ParentId != null){
                    Set<String> allEmails = new Set<String>();
                    if (!String.isEmpty(emailMessage.ToAddress)){
                        allEmails.addAll(splitEmails(emailMessage.ToAddress));
                    }
                    if (!String.isEmpty(emailMessage.CcAddress)){
                        allEmails.addAll(splitEmails(emailMessage.CcAddress));
                    }
                    if (!String.isEmpty(emailMessage.BccAddress)){
                        allEmails.addAll(splitEmails(emailMessage.BccAddress));
                    }
                    for(String email : emailList){
                        if(allEmails.contains(email)){
                            caseIds.add(emailMessage.ParentId);
                            //caseIdSubjectMap.put(emailMessage.ParentId, emailMessage.Subject);
                            break;
                        }
                    }
                }
            }
        }

        if(!caseIds.isempty()){

            List<String> address = new List<String>();
            List<Case> casesToDelete = new List<Case>();
            
            List<Case> cases = [Select Id, SuppliedEmail, Subject, CreatedById from Case where Id In :caseIds AND OwnerId = :Label.Q1_Owner_Id ];
            for(Case cs:cases){
                //if(caseIdSubjectMap.containskey(cs.Id) && caseIdSubjectMap.get(cs.Id) != null && !caseIdSubjectMap.get(cs.Id).contains(cs.Case_Thread_ID__c)){
                if(UserInfo.getName() == 'System' && UserInfo.getUserId() == cs.CreatedById){
                    casesToDelete.add(cs);
                    address.add(cs.SuppliedEmail);
                }
            }
            EmailTemplate template=[SELECT HtmlValue,Body FROM EmailTemplate WHERE Name='ET TECH EN Case Creation ReplyToCSM'];
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String  hbody = template.HtmlValue;
            CSM_Case_Details_Global_Setting__C orgE = CSM_Case_Details_Global_Setting__C.getInstance('Org Wide No-Reply');
            email.setReplyTo('no.reply.support@iqvia.com');
            if(orgE != null){
                email.setOrgWideEmailAddressId(orgE.Component_Id__c);
            }
            email.setToAddresses(address);
            email.setHtmlBody(hbody);
            email.setSubject('IQVIA - Case NOT registered');
            messages.add(email);
            if(address.size()>0){
                try{
                    Messaging.sendEmail(messages);
                }catch(Exception e){
                }
            }
            if(casesToDelete.size() >0){
                delete casesToDelete;
            }
        }
    }
    
    private static List<String> splitEmails(String emails){
        List<String> emailList = new List<String>();
        for(String value : emails.split(';')){
            emailList.add(value.trim().toLowerCase());
        }
        return emailList;
    }
    
    public static void deleteCasesCreatedBySpamMails(List<EmailMessage> newList){
        List<Id> emailMessagesIds = new List<Id>();
        for(EmailMessage emailMessage:newList){
            if(emailMessage.ParentId != null && emailMessage.Incoming && emailMessage.FromAddress != null){
                emailMessagesIds.add(emailMessage.Id);
            }
        }
        if(!System.isBatch() && !System.isFuture()){
            deleteCasesCreatedBySpamMails_Future(emailMessagesIds);
        }
    }
    
    @future
    private static void deleteCasesCreatedBySpamMails_Future(List<Id> emailMessagesIds){
        List<EmailMessage> emailMessages = [Select Id, ParentId, FromAddress from EmailMessage where Id IN :emailMessagesIds];
        if(emailMessages != null && !emailMessages.isEmpty() && emailMessages.size() == 1){
            Set<String> fromEmails = new Set<String>();
            for(EmailMessage emailMessage : emailMessages){
                fromEmails.add(emailMessage.FromAddress.toLowerCase());
            }
            List<CSM_Case_Black_List_Spam_Address__c> spamAddresses =  [Select Id, Spam_Email_Address__c, Count_of_Spam_Case__c from CSM_Case_Black_List_Spam_Address__c where Spam_Email_Address__c IN :fromEmails];
            if(!spamAddresses.isEmpty()){
                Map<String, CSM_Case_Black_List_Spam_Address__c> spamAddressesMap = new Map<String, CSM_Case_Black_List_Spam_Address__c>();
                for(CSM_Case_Black_List_Spam_Address__c spamAddress:spamAddresses){
                    spamAddressesMap.put(spamAddress.Spam_Email_Address__c, spamAddress);
                }
                Set<Id> casesIds = new Set<Id>();
                for(EmailMessage emailMessage : emailMessages){
                    if(emailMessage.FromAddress != null && spamAddressesMap.containsKey(emailMessage.FromAddress.toLowerCase())){
                        casesIds.add(emailMessage.ParentId);
                        spamAddressesMap.get(emailMessage.FromAddress.toLowerCase()).Count_of_Spam_Case__c++;
                    }
                }
                List<Case> casesToDelete = [Select Id from Case where Id IN :casesIds];
                
                Savepoint sp = Database.setSavepoint();
                try{
                    if(casesToDelete != null && !casesToDelete.isEmpty()) {
                        delete casesToDelete;
                    }
                    if(spamAddresses != null && !spamAddresses.isEmpty()){
                        update spamAddresses;
                    }
                }
                catch(Exception e){
                    Database.rollback(sp);
                }
            }
        }
    }

    public static void stopDuplicateCaseCreationinToAddress(List<EmailMessage> emailmessageList) {
        String timeSeconds = label.CSM_Time_E2c;
        Decimal strToDec = decimal.valueOf(timeSeconds);
        List<Case> caseDelList = new List<Case>();
        Set<Id> idSet = new Set<id>();
        if(CON_CSM.S_SYSTEM == userInfo.getName() || Test.isRunningTest()) {
            for(EmailMessage emailRecord : emailmessageList){
                if(emailRecord.Incoming){
                    idSet.add(emailRecord.ParentId);
                }
                
            }
            if(!idSet.isEmpty()){
                List<Case> recentCasesList = new SLT_Case().getCasesEmailtoCase();
                Case currentCase = null;
                for(Case c : recentCasesList){
                    if(idSet.contains(c.Id)){
                        currentCase = c; 
                    }
                }
                if(recentCasesList.size() > 0 && currentCase != null && currentCase.From_EmailToCase__c != 'investigatorservicesalertcommunications@iqvia.com'){
                    for(Case oldCase : recentCasesList){
                        if(currentCase.Id != oldCase.Id){
                            Decimal seconds = ((currentCase.CreatedDate.getTime())/1000) - ((oldCase.CreatedDate.getTime())/1000);
                            if(!idSet.contains(oldCase.Id) && oldCase.CreatedById == userInfo.getUserId() && CON_CSM.S_SYSTEM == userInfo.getName() && seconds >= 0 && seconds <= strToDec && CON_CSM.S_EMAIL == oldCase.Origin){
                                if(currentCase.Status == CON_CSM.S_NEW && currentCase.Status == oldCase.Status && (oldCase.RecordTypeName__c == CON_CSM.S_R_D_CTP || oldCase.RecordTypeName__c == CON_CSM.S_R_D_CDP || oldCase.RecordTypeName__c == CON_CSM.S_R_D_V_T || oldCase.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || oldCase.RecordTypeName__c == CON_CSM.S_RDCASE)  && (currentCase.RecordTypeName__c == CON_CSM.S_R_D_CTP || currentCase.RecordTypeName__c == CON_CSM.S_R_D_CDP || currentCase.RecordTypeName__c == CON_CSM.S_R_D_V_T || currentCase.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || currentCase.RecordTypeName__c == CON_CSM.S_RDCASE) && currentCase.Subject == oldCase.Subject && currentCase.Description == oldCase.Description){
                                    caseDelList.add(oldCase);
                                }
                            }
                        }
                    }
                    Savepoint sp = Database.setSavepoint();
                    try{
                        if(!caseDelList.isEmpty()){ 
                            delete caseDelList;
                        }
                    }
                    catch(Exception E){
                        Database.rollback(sp);
                    }
                }
            }
        }
    }
}
