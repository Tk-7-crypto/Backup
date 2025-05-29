public with sharing class CNT_CPQ_DynamicApprovalProcess {

    public static Map<String, Map<Integer, WPR_CPQ_ApprovalMatrix>> approvalMatrixByPriorityByLevel = null;
    public static Set<Id> existingApproversIdSet = new Set<Id>();

    @AuraEnabled(cacheable = true)
    public static string getApprovers(Id recordId, String ojectName, Boolean withPriority) {
        WPR_CPQ_ApprovalMatrixMap approversByLevelMap = new WPR_CPQ_ApprovalMatrixMap();
        try {
            List<Criteria_Matrix__c> criteriaMatrixList = [SELECT Id, Object_Name__c, Field_Type__c, Field_Name__c, Condition__c, Order__c, Approval_Matrix_Field_Name__c FROM Criteria_Matrix__c WHERE Object_Name__c =: ojectName ORDER BY Order__c];
            if (criteriaMatrixList.size() == 0) {
                approversByLevelMap.isSuccess = false;
                approversByLevelMap.errorMsg = 'No records found for Criteria Matrix.';
                return JSON.serialize(approversByLevelMap, true);
            }
            String query = 'SELECT Id';
            for(Criteria_Matrix__c obj: criteriaMatrixList) {
                if (!query.contains(obj.Field_Name__c)) {
                    query += ', ' + obj.Field_Name__c;
                }
            }
            query += ' FROM ' + ojectName + ' WHERE Id =: recordId';
            List<sObject> onjList = Database.query(query);

            approvalMatrixByPriorityByLevel = fetchApprover(onjList[0], criteriaMatrixList, ojectName, withPriority);
            approversByLevelMap.approvalMatrixByPriorityByLevel = approvalMatrixByPriorityByLevel;  
        } catch(Exception e) {
            approversByLevelMap.isSuccess = false;
            approversByLevelMap.errorMsg = e.getMessage();
        }
        return JSON.serialize(approversByLevelMap, true);
    }

    public static sObject getSObjectInstance(Id recordId, String objectName) {
        String query = 'SELECT Id, Name, Approver_Level__c, Related_Opportunity__r.name, Opportunity_Number__c, Priority__c, OwnerId';
        query += ' FROM ' + objectName;
        query += ' WHERE Id =: recordId';

        sObject newObject = Database.query(query);

        return newObject;
    }

    public class WPR_CPQ_ApprovalMatrixMap {
        @AuraEnabled
        public Map<String, Map<Integer, WPR_CPQ_ApprovalMatrix>> approvalMatrixByPriorityByLevel{get; set;}
        @AuraEnabled
        public String errorMsg{get; set;}
        @AuraEnabled
        public Boolean isSuccess{get; set;}
        
        public WPR_CPQ_ApprovalMatrixMap() {
            this.isSuccess = true;
        }
    }


    public static Map<String, Map<Integer, WPR_CPQ_ApprovalMatrix>> fetchApprover(sObject sObj, List<Criteria_Matrix__c> criteriaMatrixList, String ojectName, Boolean withPriority) {
        Set<String> countryCodes = new Set<String>();
        countryCodes.add('All');

        Set<String> fieldSet = new Set<String> {CON_CPQ.ID , CON_CPQ.APPROVE_ON_FIRST_RESPONSE, CON_CPQ.LEVELS, CON_CPQ.PRIORITY,CON_CPQ.COUNTRY, CON_CPQ.MIN_AMOUNT, CON_CPQ.MAX_AMOUNT, CON_CPQ.MIN_GORSS_MARGIN, CON_CPQ.MAX_GORSS_MARGIN, CON_CPQ.MIN_DISCOUNT_PERCENT, CON_CPQ.MAX_DISCOUNT_PERCENT, CON_CPQ.MIN_DISCOUNT_AMOUNT, CON_CPQ.MAX_DISCOUNT_AMOUNT, CON_CPQ.APPROVER1, CON_CPQ.APPROVER2, CON_CPQ.APPROVER3, CON_CPQ.APPROVER4, CON_CPQ.APPROVER5, CON_CPQ.OBJECT_NAME, CON_CPQ.TRACK_NAME, CON_CPQ.PRICING_TOOL, CON_CPQ.AUTO_APPROVE, CON_CPQ.NOTIFIER1, CON_CPQ.NOTIFIER2, CON_CPQ.NOTIFIER3, CON_CPQ.NOTIFIER4, CON_CPQ.NOTIFIER5};
        String condition = 'Object_Name__c like ' + '\'' +'%' +  ojectName + '%' +  '\'';

        for (Integer i=0; i<criteriaMatrixList.size(); i++) {
            Criteria_Matrix__c obj = criteriaMatrixList[i];
            if (obj.Field_Type__c == 'String') {
                condition += ' AND ' + obj.Approval_Matrix_Field_Name__c + ' ' + obj.Condition__c + ' ' + '\'' + sObj.get(obj.Field_Name__c) + '\'';
            } else if (obj.Field_Type__c == 'multipicklist') {
                String temp = '(';
                for (String str: ((String)sObj.get(obj.Field_Name__c)).split(';')) {
                    temp += '\'' + str + '\'' + ', ';
                }
                temp += '\''  + '\'' + ')';
                condition += ' AND ' + obj.Approval_Matrix_Field_Name__c + ' ' + obj.Condition__c + ' ' + temp;
            } else if (obj.Field_Type__c == 'country') {
                String countryList = '(' + '\'' + CON_CPQ.ALL + '\'' + ',';
                if (sObj.get(obj.Field_Name__c) != null) {
                    for (String str: ((String)sObj.get(obj.Field_Name__c)).split(';')) {
                        countryList += '\'' + str + '\'' + ', ';
                    }
                }
                countryList += '\''  + '\'' + ')';
                condition += ' AND ' + obj.Approval_Matrix_Field_Name__c + ' ' + obj.Condition__c + ' ' + countryList;
            } else {
                condition += ' AND ' + obj.Approval_Matrix_Field_Name__c + ' ' + obj.Condition__c + ' ' + (sObj.get(obj.Field_Name__c) == null ? 0: sObj.get(obj.Field_Name__c));
            }
        }
        condition += ' AND Track_Name__c = ' + '\'' + CON_CPQ.CPQ + '\'' +
            ' AND Process_Type__c = ' + '\'' + CON_CPQ.APPROVAL_PROCESS + '\'';
        
        List<Approval_Matrix__c> approvalMatrix = new SLT_ApprovalMatrix().getApprover(fieldSet, condition, countryCodes);
        
        approvalMatrixByPriorityByLevel = new Map<String, Map<Integer, WPR_CPQ_ApprovalMatrix>>();
        Map<Integer, WPR_CPQ_ApprovalMatrix> approvalMatrixByPriority;
        Integer priority = withPriority ? 0 : 1;
        Decimal apmPiority = null;
        for (Approval_Matrix__c apm : approvalMatrix) {
            if (withPriority && apm.Priority__c != apmPiority) {
                apmPiority = apm.Priority__c;
                priority++;
            }
            approvalMatrixByPriority = new Map<Integer, WPR_CPQ_ApprovalMatrix>();
            WPR_CPQ_ApprovalMatrix wcam = new WPR_CPQ_ApprovalMatrix();
            if (approvalMatrixByPriorityByLevel.containsKey(apm.Levels__c)) {
                approvalMatrixByPriority = approvalMatrixByPriorityByLevel.get(apm.Levels__c);
                if (approvalMatrixByPriority.containsKey(priority)) {
                    wcam = approvalMatrixByPriority.get(priority);
                }
            }
            if (apm.Approver_1__c != null) {
                wcam.approverIds.add(apm.Approver_1__c);
            }
            if (apm.Approver_2__c != null) {
                wcam.approverIds.add(apm.Approver_2__c);
            }
            if (apm.Approver_3__c != null) {
                wcam.approverIds.add(apm.Approver_3__c);
            }
            if (apm.Approver_4__c != null) {
                wcam.approverIds.add(apm.Approver_4__c);
            }
            if (apm.Approver_5__c != null) {
                wcam.approverIds.add(apm.Approver_5__c);
            }
            if (apm.Notifier_1__c != null) {
                wcam.notifiers.add(apm.Notifier_1__c);
            }
            if (apm.Notifier_2__c != null) {
                wcam.notifiers.add(apm.Notifier_2__c);
            }
            if (apm.Notifier_3__c != null) {
                wcam.notifiers.add(apm.Notifier_3__c);
            }
            if (apm.Notifier_4__c != null) {
                wcam.notifiers.add(apm.Notifier_4__c);
            }
            if (apm.Notifier_5__c != null) {
                wcam.notifiers.add(apm.Notifier_5__c);
            }
            wcam.approveOnFirstResponse = apm.Approve_On_First_Response__c;
            wcam.autoApprove = apm.Auto_Approve__c;
            wcam.withPriority = withPriority;
            approvalMatrixByPriority.put(priority, wcam);
            approvalMatrixByPriorityByLevel.put(apm.Levels__c, approvalMatrixByPriority);
        }
        return approvalMatrixByPriorityByLevel;
    }

    @AuraEnabled
    public static String submitApprovalRequest(Id recordId, String objectName, String approversMapJSON, List<String> chosenApprovers) {
        String returnMessage = '';
        try {
            Integer currentPriority = 1;
            WPR_CPQ_ApprovalMatrixMap jsonToApproversMap = (WPR_CPQ_ApprovalMatrixMap)JSON.deserialize(approversMapJSON, WPR_CPQ_ApprovalMatrixMap.class);
            approvalMatrixByPriorityByLevel = jsonToApproversMap.approvalMatrixByPriorityByLevel;
            sObject newObject = getSObjectInstance(recordId, objectName);
            List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
            Map<Integer, WPR_CPQ_ApprovalMatrix> approvalMatrixByPriority;
            WPR_CPQ_ApprovalMatrix aprObj = null;

            if (approvalMatrixByPriorityByLevel.containsKey('Level 1')) {
                approvalMatrixByPriority = approvalMatrixByPriorityByLevel.get('Level 1');
                if (approvalMatrixByPriority.containsKey(1)) {
                    aprObj = approvalMatrixByPriority.get(currentPriority);
                }
            }
            if (aprObj != null || Test.isRunningTest()) {
                newObject.put('Approver_Level__c', 1);
                if (aprObj.approveOnFirstResponse) {
                    if (aprObj.withPriority) {
                        newObject.put('Priority__c', 2);
                    }
                } else {
                    if (aprObj.withPriority) {
                        newObject.put('Priority__c', 1);
                    }
                }
                List<Id> approverList = new List<Id>();
                if (chosenApprovers != null && chosenApprovers.size() > 0) {
                    approverList = chosenApprovers;
                } else {
                    approverList.addAll(aprObj.approverIds);
                }
                for (integer i = 1; i <= 5; i++) {
                    if (aprObj.autoApprove) {
                        newObject.put('Approver_' + i + '__c', UserInfo.getUserId());
                    } else if (approverList.size() >= i && approverList.get(i - 1) != null) {
                        newObject.put('Approver_' + i + '__c', approverList.get(i - 1));
                    } else {
                        newObject.put('Approver_' + i + '__c', newObject.get('Approver_' + (i - 1) + '__c'));
                    }
                }
                update newObject;
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for first level of approval');
                req1.setObjectId(newObject.id);
                req1.setSubmitterId((Id)newObject.get('OwnerId'));
                approvalRequests.add(req1);
            
                Approval.process(approvalRequests);
                returnMessage = 'Success';
            } else {
                returnMessage = 'Something went wrong';
            }
        } catch (Exception e) {
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }

    @AuraEnabled
    public static String approveProcessWorkItemRequest(Id recordId, string comment, String objectName, String approversMapJSON) {
        try {
            WPR_CPQ_ApprovalMatrixMap jsonToApproversMap = (WPR_CPQ_ApprovalMatrixMap)JSON.deserialize(approversMapJSON, WPR_CPQ_ApprovalMatrixMap.class);
            approvalMatrixByPriorityByLevel = jsonToApproversMap.approvalMatrixByPriorityByLevel;
            sObject newObject = getSObjectInstance(recordId, objectName);
            List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(recordId);
            boolean isPendingForAppr = false;
            Integer currentLevel = (Integer)(Decimal)newObject.get('Approver_Level__c');
            Integer currentPriority = (Integer)(Decimal)newObject.get('Priority__c');
            Map<Integer, WPR_CPQ_ApprovalMatrix> approvalMatrixByPriority = approvalMatrixByPriorityByLevel.get('Level ' + currentLevel);
            WPR_CPQ_ApprovalMatrix aprObj1 = approvalMatrixByPriority.get(currentPriority);
            Id piwiToUpdate = null;
            for(ProcessInstanceWorkitem piwi : workItemIds) {
                if (piwi.ProcessInstance.Status == CON_CPQ.PENDING && piwi.ActorId != UserInfo.getUserId()) {
                    isPendingForAppr = true;
                }
                if (piwi.ActorId == UserInfo.getUserId()) {
                    piwiToUpdate = piwi.Id;
                }
            }
            if (aprObj1.approveOnFirstResponse) {
                isPendingForAppr = false;
            }
            if (!isPendingForAppr && workItemIds.size() > 0) {                           
                String nextLevel ='Level ' + (Integer)(currentLevel + 1);
                if (approvalMatrixByPriority.containsKey(currentPriority + 1)) {
                    currentPriority++;
                    checkForAutoApprove(currentLevel, currentPriority, newObject, piwiToUpdate, comment, objectName);
                } else {
                    if (approvalMatrixByPriorityByLevel.containsKey(nextLevel)) {
                        currentLevel++;
                        currentPriority = aprObj1.withPriority ? currentPriority + 1 : currentPriority;
                        checkForAutoApprove(currentLevel, currentPriority, newObject, piwiToUpdate, comment, objectName);
                    } else {
                        isPendingForAppr = true;
                    }
                }
            }
            if (aprObj1.approveOnFirstResponse && workItemIds.size() > 0) {
                if (workItemIds.size() > 1) {
                    approveAllRecords(recordId, comment);
                } else {
                    List<ProcessInstanceWorkitem> piwiList = [SELECT ID FROM ProcessInstanceWorkitem WHERE Id =: piwiToUpdate];
                    if (piwiList.size() > 0) {
                        Approval.process(createProcessWorkItemRequest(piwiToUpdate, null, 'Approve', comment));
                    }
                }  
            }  else if (piwiToUpdate != null && isPendingForAppr) {
                Approval.process(createProcessWorkItemRequest(piwiToUpdate, null, 'Approve', comment));
            }
            CPQ_RMUtility.unlockDynamicApprovalProcess(new List<Id>{newObject.Id});
            return 'Approved';
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String rejectProcessWorkItemRequest(Id recordId, string comment) {
        Id workItemId = null;
        List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(recordId);       
        Id nextApproverId = UserInfo.getUserId();
        String approvalAction = 'Reject';
        String commentFromApprover = comment;
        for (ProcessInstanceWorkitem pi : workItemIds) {
            if (pi.ActorId == UserInfo.getUserId()) {
                workItemId = pi.Id;
            }
        }
        if (workItemId != null) {
            try {
                Approval.process(createProcessWorkItemRequest(workItemId, nextApproverId, approvalAction, commentFromApprover));
            } catch (Exception e) {
                return 'Error';
            }
        }
        return 'Rejected';
    }

    public static void checkForAutoApprove(Integer level, Integer currentPriority, sObject prop, Id piwiToUpdate, String comment, String objectName){
        Map<Integer, WPR_CPQ_ApprovalMatrix> approvalMatrixByPriority = approvalMatrixByPriorityByLevel.get('Level ' + level);
        WPR_CPQ_ApprovalMatrix newMatrix = approvalMatrixByPriority.get(currentPriority);

        if (newMatrix != null && newMatrix.autoApprove) { 
            prop.put('Approver_Level__c', level);
            prop.put('Priority__c', currentPriority);
            for (integer i = 1; i <= 5; i++) {                                                        
                prop.put('Approver_' + i + '__c', UserInfo.getUserId());
            }
            update prop;

            if (newMatrix.notifiers.size() > 0) {
                sendEmailToNotifier(newMatrix, prop, objectName);
            }
            if (piwiToUpdate == null) {
                List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(prop.Id);
                if (workItemIds.size() > 0) {
                    Approval.process(createProcessWorkItemRequest(workItemIds[0].Id, null, 'Approve', 'Auto approved'));
                }                
            } else {
                Approval.process(createProcessWorkItemRequest(piwiToUpdate, null, 'Approve', comment));
            }
            if (approvalMatrixByPriority.containsKey(currentPriority + 1)) {
                currentPriority++;
                checkForAutoApprove(level, currentPriority, prop, null, 'Auto approved', objectName);
            } else {
                Integer nextLevel = level + 1;
                if (approvalMatrixByPriorityByLevel.containsKey('Level ' + nextLevel)) {
                    level++;
                    currentPriority = newMatrix.withPriority ? currentPriority + 1 : currentPriority;
                    checkForAutoApprove(level, currentPriority, prop, null, 'Auto approved', objectName);
                } else {
                    List<ProcessInstanceWorkitem> workItemId = getProcessInstanceWorkItems(prop.Id);
                    if (workItemId.size() > 0) {
                        Approval.process(createProcessWorkItemRequest(workItemId[0].Id, null, 'Approve', 'Auto approved'));
                    }
                }
            }
        } else {
            List<Id> approverList = new List<Id>();
            approverList.addAll(newMatrix.approverIds);
            for (integer i = 1; i <= 5; i++) {
                if (approverList.size() >= i && approverList.get(i - 1) != null) {
                    prop.put('Approver_' + i + '__c', approverList.get(i - 1));
                } else {
                    prop.put('Approver_' + i + '__c', prop.get('Approver_' + (i - 1) + '__c'));
                }
            }
            prop.put('Approver_Level__c', level);
            if (newMatrix.withPriority) {
                prop.put('Priority__c', currentPriority);
            }
            update prop;
            if (newMatrix.notifiers.size() > 0) {
                sendEmailToNotifier(newMatrix, prop, objectName);
            }
            List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(prop.Id);
            if (workItemIds.size() > 0) {
                Approval.ProcessResult processResult = Approval.process(createProcessWorkItemRequest(workItemIds[0].Id, null, 'Approve', comment)); 
            }
        }
    }

    @future 
    public static void approveAllRecords(Id recordId, String comment) {
        List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(recordId);
        for (ProcessInstanceWorkitem piwi : workItemIds) {
            Approval.process(createProcessWorkItemRequest(piwi.Id, null, 'Approve', comment));
        }
        CPQ_RMUtility.unlockDynamicApprovalProcess(new List<Id>{recordId});
    }

    public static List<ProcessInstanceWorkitem> getProcessInstanceWorkItems(Id objectId) {
        List<ProcessInstanceWorkitem> lst = [SELECT Id, ActorId, ProcessInstance.Status, ProcessInstanceId, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: objectId ORDER BY CreatedDate];
        return lst;
    }      
    
    public static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, Id approverId, String approvalAction, String commentFromApprover) {
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);
        if (approverId != null) {
            result.setNextApproverIds(new List<Id>{approverId});
        }
        return result;
    }

    public static void sendEmailToNotifier(WPR_CPQ_ApprovalMatrix approvalMatrix, sObject sobj, String ojectName) {
        Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
        try {
            objWorkFlowEmail.Related_To_Object_Id__c = sObj.Id;
            objWorkFlowEmail.Related_To_Object_Api__c = ojectName;
            objWorkFlowEmail.Module_Name__c = CON_CPQ.CPQ;
            objWorkFlowEmail.Email_Action__c = 'CPQ_03_SendEmail';
            objWorkFlowEmail.Email_Subject__c = 'Approval Request Notification ' + sobj.get('Opportunity_Number__c') + ' ' + sobj.getSObject('Related_Opportunity__r').get('Name') + ' ' + sobj.get('Name');
            objWorkFlowEmail.content_1__c = URL.getOrgDomainUrl().toExternalForm() + '/' + sobj.Id;
            List<String> notifiersList = new List<String>();
            notifiersList.addAll(approvalMatrix.notifiers);
            
            for (integer i = 1; i <= 5; i++) {
                if (notifiersList.size() >= i && notifiersList.get(i-1) != null) {                                     
                    objWorkFlowEmail.put('To_Email_' + i + '__c', notifiersList.get(i-1));
                }  
            }
            insert objWorkFlowEmail;
        }
        catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage());
        }
    }

    public class WPR_CPQ_ApprovalMatrix {
        @AuraEnabled
        public Set<Id> approverIds {get; set;}
        @AuraEnabled
        public boolean approveOnFirstResponse {get; set;}
        @AuraEnabled
        public boolean withPriority {get; set;}
        @AuraEnabled
        public boolean autoApprove {get; set;}
        @AuraEnabled
        public Set<String> notifiers {get; set;}

        public WPR_CPQ_ApprovalMatrix() {
            this.approverIds = new Set<Id>();
            this.approveOnFirstResponse = false;
            this.autoApprove = false;
            this.notifiers = new Set<String>();
            this.withPriority = false;
        }
    }
    
    @AuraEnabled
    public static String requestApprovedAndReject(Id recordId, String comment, String action) {
        String status;
        Id workItemId = null;
        List<ProcessInstanceWorkitem> workItemIds = getProcessInstanceWorkItems(recordId);
        if (workItemIds.size() > 0) {
		    for (ProcessInstanceWorkitem pi : workItemIds) {
                if (pi.ActorId == UserInfo.getUserId()) {
                    workItemId = pi.Id;
                }
            } 
		}
        
        if (workItemId != null) {
            try {
                Approval.ProcessResult processResult = Approval.process(createProcessWorkItemRequest(workItemId, null, action, comment)); 
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        status = action == 'Approve' ? 'Approved' : 'Rejected';
        
        if (status == 'Rejected') {
            Set<String> fieldSet = new Set<String>{CON_CPQ.AGREEMENT_OWNER_EMAIL, CON_CPQ.OWNER_NAME, CON_CPQ.RELATED_OPPORTUNITY_NUMBER, CON_CPQ.RELATED_OPPORTUNITY_NAME, CON_CPQ.NAME, CON_CPQ.IQVIA_QUOTE_PRICING_TOOL};
                Quote__c quote = new SLT_IQVIA_Quote().getQuoteId(recordId, fieldSet);
            sendEmailToOwner(quote, comment);
        }
        return status;
    }
	
    @AuraEnabled
    public static void deleteUploadedFiles(List<String> fileIds){
        try {
            List<ContentDocument> filesToDelete = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id In: fileIds
            ];
            delete filesToDelete;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future
    public static void aprroveRequestByEmail(Id recordId, String comment) {
        List<ProcessInstanceWorkitem> workItemIds = CNT_CPQ_DynamicApprovalProcess.getProcessInstanceWorkItems(recordId);
        for (ProcessInstanceWorkitem piwi : workItemIds) {
            Approval.process(CNT_CPQ_DynamicApprovalProcess.createProcessWorkItemRequest(piwi.Id, null, 'Approve', comment));
        }
    }
    
    public static void updateNextApprovalStep(List<sObject> sObjectList, String objectName, Map<Id, sObject> oldRecordsMap) {
        Map<Id, sObject> sObjectByIdMap = new Map<Id, sObject>();
        Map<Id, Set<Id>> existingApproversIdMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> pendingApproversIdMap = new Map<Id, Set<Id>>();
        for (sObject sb : sObjectList) {
            if ((sb.get('Priority__c') != null && sb.get('Priority__c') != oldRecordsMap.get(String.valueOf(sb.get('Id'))).get('Priority__c')) || (sb.get('Approval_Stage__c') == CON_CPQ.REJECTED_STATUS && oldRecordsMap.get(String.valueOf(sb.get('Id'))).get('Approval_Stage__c') == CON_CPQ.PENDING_APPROVAL)) {
                sObjectByIdMap.put(string.valueOf((sb.get('Id'))), sb);
            }
        }
        if (sObjectByIdMap.size() > 0) {
            for (ProcessInstancestep pis: [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstancestep where ProcessInstance.TargetObjectId IN: sObjectByIdMap.keySet() AND StepStatus =: CON_CPQ.APPROVED]) {
                if (!existingApproversIdMap.containsKey(String.valueOf(pis.ProcessInstance.TargetObjectId))) {
                    existingApproversIdMap.put(String.valueOf(pis.ProcessInstance.TargetObjectId), new Set<Id>());
                } 
                Set<Id> actorIds = existingApproversIdMap.get(String.valueOf(pis.ProcessInstance.TargetObjectId));
                actorIds.add(pis.ActorId);
                existingApproversIdMap.put(String.valueOf(pis.ProcessInstance.TargetObjectId), actorIds);
            }
            for (ProcessInstanceWorkItem piw: [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId IN: sObjectByIdMap.keySet()]) {
                if (!pendingApproversIdMap.containsKey(String.valueOf(piw.ProcessInstance.TargetObjectId))) {
                    pendingApproversIdMap.put(String.valueOf(piw.ProcessInstance.TargetObjectId), new Set<Id>());
                }
                Set<Id> actorIds = pendingApproversIdMap.get(String.valueOf(piw.ProcessInstance.TargetObjectId));
                actorIds.add(piw.ActorId);
                pendingApproversIdMap.put(String.valueOf(piw.ProcessInstance.TargetObjectId), actorIds);
            }
            for (Id key: sObjectByIdMap.keySet()) {
                Boolean isCurrentLevelEven = System.Math.mod(Integer.valueOf(sObjectByIdMap.get(key).get('Priority__c')), 2) == 0 ? true : false;
                String approveDetails = CNT_CPQ_DynamicApprovalProcess.getApprovers(key, objectName, true);
                CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrixMap jsonToApproversMap = (CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrixMap)JSON.deserialize(approveDetails, CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrixMap.class);
                approvalMatrixByPriorityByLevel = jsonToApproversMap.approvalMatrixByPriorityByLevel;
                if (!approvalMatrixByPriorityByLevel.containsKey('Level 1')) {
                    return;
                }
                Map<Integer, CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrix> approvalMatrixByPriority = approvalMatrixByPriorityByLevel.get('Level 1');
                Integer priority = (Integer.valueOf(sObjectByIdMap.get(key).get('Priority__c')) + 1) / 2;
                sObject newObject = getSObjectInstance(key, objectName);

                if (sObjectByIdMap.get(key).get('Approval_Stage__c') == CON_CPQ.REJECTED_STATUS) {
                    if (pendingApproversIdMap.containsKey(key)) {
                        existingApproversIdSet.addAll(pendingApproversIdMap.get(key));
                    }
                    existingApproversIdSet.remove(userInfo.getUserId());
                    if (existingApproversIdSet.size() > 0) {
                        String subject = 'Others have rejected ' + newObject.get('Opportunity_Number__c') + ' ' + newObject.getSObject('Related_Opportunity__r').get('Name') + ' ' + newObject.get('Name');
                        String content = '<br><br>The following Quote has been rejected by ' + userInfo.getName() + '<br>';
                        content += URL.getOrgDomainUrl().toExternalForm() + '/' + newObject.Id + '<br>';
                        content += 'You will not need to provide approval anymore, but feel free to review.' + '<br>';
                        content += '<br> Thanks';
                        sendEmail(existingApproversIdSet, newObject, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, CON_CPQ.CPQ_05_SEND_EMAIL, subject, content);
                    }
                    continue;
                }

                if (pendingApproversIdMap.containsKey(key)) {
                    existingApproversIdSet.addAll(pendingApproversIdMap.get(key));
                }
                Set<Id> sendEmailIdSet = new Set<Id>();
                sendEmailIdSet.addAll(existingApproversIdSet);
                sendEmailIdSet.remove(userInfo.getUserId());
                if (sendEmailIdSet.size() > 0) {
                    String subject = 'Others have approved ' + newObject.get('Opportunity_Number__c') + ' ' + newObject.getSObject('Related_Opportunity__r').get('Name') + ' ' + newObject.get('Name');
                    String content = '<br><br>The following Quote has been approved by ' + userInfo.getName() + '<br>';
                    content += URL.getOrgDomainUrl().toExternalForm() + '/' + newObject.Id + '<br>';
                    content += 'You will not need to provide approval anymore, but feel free to review.' + '<br>';
                    content += '<br> Thanks';
                    sendEmail(sendEmailIdSet, newObject, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, CON_CPQ.CPQ_05_SEND_EMAIL, subject, content);
                }
                
                if (approvalMatrixByPriority.containsKey(priority)) {
                    CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrix aprObj1 = approvalMatrixByPriority.get(priority);
                    if (aprObj1.autoApprove) {
                        while(approvalMatrixByPriority.containsKey(priority + 1) && approvalMatrixByPriority.get(priority + 1).autoApprove) {
                            priority++;
                        }
                        for (integer i = 1; i <= 5; i++) {                                                        
                            sObjectByIdMap.get(key).put('Approver_' + i + '__c', UserInfo.getUserId());
                        }
                        sObjectByIdMap.get(key).put('Priority__c', priority * 2);
                    } else {
                        Set<Id> approversIdSet = aprObj1.approverIds;
                        
                        if (existingApproversIdMap.containsKey(key)) {
                            existingApproversIdSet.addAll(existingApproversIdMap.get(key));
                        }
                        approversIdSet.removeAll(existingApproversIdSet);
                        List<Id> approverList = new List<Id>();
                        approverList.addAll(approversIdSet);
                        if (approverList.size() > 0) {
                            for (integer i = 1; i <= 5; i++) {
                                if (approverList.size() >= i && approverList.get(i - 1) != null) {
                                    sObjectByIdMap.get(key).put('Approver_' + i + '__c', approverList.get(i - 1));
                                } else {
                                    sObjectByIdMap.get(key).put('Approver_' + i + '__c', sObjectByIdMap.get(key).get('Approver_' + (i - 1) + '__c'));
                                }
                            }
                            if (isCurrentLevelEven == true && aprObj1.approveOnFirstResponse == false) {
                                sObjectByIdMap.get(key).put('Priority__c', Integer.valueOf(sObjectByIdMap.get(key).get('Priority__c')) - 1);
                            } else if (isCurrentLevelEven == false && aprObj1.approveOnFirstResponse == true) {
                                sObjectByIdMap.get(key).put('Priority__c', Integer.valueOf(sObjectByIdMap.get(key).get('Priority__c')) + 1);
                            }
                        } else {
                            while(true) {
                                if (approvalMatrixByPriority.containsKey(priority + 1)) {
                                    Set<Id> approversSet = new Set<Id>();
                                    aprObj1 = approvalMatrixByPriority.get(priority + 1);
                                    approversSet = aprObj1.approverIds;
                                    approversSet.removeAll(existingApproversIdSet);
                                    if (approversSet.size() == 0 || aprObj1.autoApprove) {
                                        priority++;
                                    } else {
                                        break;
                                    }
                                } else {
                                    break;
                                }
                            }
                            for (integer i = 1; i <= 5; i++) {                                                        
                                sObjectByIdMap.get(key).put('Approver_' + i + '__c', UserInfo.getUserId());
                            }
                            sObjectByIdMap.get(key).put('Priority__c', priority * 2);
                        }
                    }
                    
                    if (aprObj1 != null && aprObj1.notifiers.size() > 0) {
                        CNT_CPQ_DynamicApprovalProcess.sendEmailToNotifier(aprObj1, newObject, objectName);
                    }
                } else {
                    sObjectByIdMap.get(key).put('Priority__c', null);
                }
            }  
        }
    }
    
    public static void checkForAutoApproval(List<Quote__c> newList, String objectName, Map<Id, Quote__c> oldRecordsMap) {
        Map<Id, sObject> sObjectByIdMap = new Map<Id, sObject>();
        for(sObject sb : newList) {
            if (sb.get('Priority__c') != null && sb.get('Priority__c') != oldRecordsMap.get(sb.Id).get('Priority__c')) {      
                   sObjectByIdMap.put(string.valueOf((sb.get('Id'))), sb);
            }
        }
        if (sObjectByIdMap.size() > 0) {
            List<Id> quoteIdList = new List<Id>();
            for(Id key: sObjectByIdMap.keySet()) {
                quoteIdList.add(key);
                Map<Integer, CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrix> approvalMatrixByPriority = approvalMatrixByPriorityByLevel.get('Level 1');
                CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrix aprObj1;
                sObject newObject = getSObjectInstance(key, objectName);
                Integer priority = (Integer.valueOf(sObjectByIdMap.get(key).get('Priority__c')) + 1) / 2;
                if (approvalMatrixByPriority.containsKey(priority)) {
                    aprObj1 = approvalMatrixByPriority.get(priority);
                    Set<Id> approverIdSet = aprObj1.approverIds;
                    approverIdSet.removeAll(existingApproversIdSet);
                    if (aprObj1.autoApprove == true || approverIdSet.size() == 0) {
                        CNT_CPQ_DynamicApprovalProcess.aprroveRequestByEmail(key, 'Auto Approved');
                    }
                }
                if (aprObj1 != null && aprObj1.notifiers.size() > 0) {
                    sendEmailToNotifier(aprObj1, newObject, objectName);
                }
            }
        }
    }

    public static void sendEmail(Set<Id> userIdSet, sObject sobj, String ojectName, String emialAction, String subject, String content) {
        Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
        try {
            objWorkFlowEmail.Related_To_Object_Id__c = sObj.Id;
            objWorkFlowEmail.Related_To_Object_Api__c = ojectName;
            objWorkFlowEmail.Module_Name__c = CON_CPQ.CPQ;
            objWorkFlowEmail.Email_Action__c = emialAction;
            objWorkFlowEmail.Email_Subject__c = subject;
            objWorkFlowEmail.content_1__c = content;
            List<Id> notifiersList = new List<Id>();
            notifiersList.addAll(userIdSet);
            for (integer i = 1; i <= notifiersList.size(); i++) {
                if (notifiersList.size() >= i && notifiersList.get(i-1) != null) {                                     
                    objWorkFlowEmail.put('To_User_' + i + '__c', notifiersList.get(i-1));
                }  
            }
            insert objWorkFlowEmail;
        }
        catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage());
        }
    }
	
    @AuraEnabled
    public static void updateMsaDiscountReasonOnQuote(Id recordId, Boolean isMsaOrHistoricalDiscountReason, String urlLink){
        fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Quote__c.SobjectType
                    }
        );
        UTL_ExecutionControl.stopTriggerExecutionCPQ = true;
        uowProposal.registerDirty(new Quote__c(Id = recordId,
                                               Is_Msa_Or_Historical_Discount_Reason__c = isMsaOrHistoricalDiscountReason,
                                               File_URL_Link__c = urlLink
                                              ));
        uowProposal.commitWork();
        UTL_ExecutionControl.stopTriggerExecutionCPQ = false;
	}
    
    public static void sendEmailToOwner(Quote__c quote, String comment) {
        Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
        
        try {
            objWorkFlowEmail.Related_To_Object_Id__c = quote.Id;
            objWorkFlowEmail.Related_To_Object_Api__c = CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME;
            objWorkFlowEmail.Module_Name__c = CON_CPQ.CPQ;
            objWorkFlowEmail.Email_Subject__c = 'Rejected ' + quote.Related_Opportunity__r.Opportunity_Number__c + ' ' + quote.Related_Opportunity__r.Name + ' ' + quote.Name;
            objWorkFlowEmail.content_1__c = quote.Owner.Name;
            objWorkFlowEmail.content_2__c = quote.Id;
            if (quote.Pricing_Tools__c == CON_CPQ.EMEA) {
                objWorkFlowEmail.Email_Action__c = 'CPQ_06_SendEmail';
                objWorkFlowEmail.content_3__c = comment;
            } else {
                objWorkFlowEmail.Email_Action__c = 'CPQ_07_SendEmail';
            }
            objWorkFlowEmail.To_Email_1__c = test.isRunningTest() ? 'test@example.com' : quote.owner.email;
            
            insert objWorkFlowEmail;
        }
        catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage());
        }
    }
}