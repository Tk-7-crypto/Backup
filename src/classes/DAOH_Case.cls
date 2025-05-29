/**
 * @description       : 
 * @author            : mallikarjuna.reddyb@iqvia.com
 * @group             : 
 * @last modified on  : 11-18-2022
 * @last modified by  : mallikarjuna.reddyb@iqvia.com
**/
public class DAOH_Case
{
    static BusinessHours bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Name = 'Default' and IsDefault = true];
    public static boolean isRndEmailCreatedFromCase = false;
    static Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
    /**
    * This method is used for get the current user profile name to use in other methods
    * @params  userProfileId String
    * @return  void
    */
    public static Profile getCSMProfile(String userProfileId){
        List<Profile> proList = Database.query('select Id,Name from Profile where Id= :userProfileId Limit 1');
        if(proList != null && proList.size() > 0 ){
            return proList[0];
        }else{
            return null;
        }
    }
    
    public static void updateAssetBeforeInsert(List<Case> newList){
        Map<Id,Id> feedIds = new Map<Id,Id>();
        Map<String, String> feedIdVsGroupId = new Map<String, String>();
        Map<String, String> groupIdVsProductId = new Map<String, String>();
        Map<String, String> productIdVsAssetId = new Map<String, String>();
        for(Case cs: newList){
            if(cs.FeedItemId != null && CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c){
                feedIds.put(cs.FeedItemId,cs.AccountId);
            }
        }
        if(feedIds.size()>0){
            for(FeedItem rec: [SELECT Id, ParentId, RelatedRecordId FROM FeedItem where Id in:feedIds.keySet()]){
                feedIdVsGroupId.put(rec.Id, rec.ParentId);
            }
            if(feedIdVsGroupId.size()>0){
                for(Product_Group_Relationship__c rec : [SELECT Id, Collaboration_Group_Id__c, Product__c FROM Product_Group_Relationship__c where Collaboration_Group_Id__c in:feedIdVsGroupId.values()]){
                    groupIdVsProductId.put(rec.Collaboration_Group_Id__c, rec.Product__c);
                }
                if(groupIdVsProductId.size()>0){
                    for(Asset rec: [select id, Product2Id from Asset where AccountId != null AND AccountId in:feedIds.values() AND Product2Id in:groupIdVsProductId.values()]){
                        productIdVsAssetId.put(rec.Product2Id, rec.Id);
                    }
                    if(productIdVsAssetId.size()>0){
                        for(Case cs: newList){
                            if(cs.FeedItemId != null){
                                String groupId = feedIdVsGroupId.get(cs.FeedItemId);
                                if(groupId != null){
                                    String productId = groupIdVsProductId.containsKey(groupId) ? groupIdVsProductId.get(groupId) : null;
                                    if(productId != null){
                                        String assetId = productIdVsAssetId.containsKey(productId) ? productIdVsAssetId.get(productId) : null;
                                        if(assetId != null){
                                            cs.AssetId = assetId;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void sendEmailToPartnerQueueOOO(List<Case> newCases, Map<Id, Case> oldMap) {
        Map<Id, Id> caseQueueMap = new Map<Id, Id>();
        List<Case> casesToProcess = new List<Case>();
        
        for (Case c : newCases) {
            if (Test.isRunningTest() || (c.Origin == 'Partner Portal' && oldMap != Null && c.InitialQueueData__c != oldMap.get(c.id).InitialQueueData__c && UserInfo.getUserType().contains(CON_CSM.S_POWER_PARTNER))) {
                caseQueueMap.put(c.InitialQueueData__c, c.Id);
                casesToProcess.add(c);
            }
        }
        
        if (!caseQueueMap.isEmpty()) {
            Map<Id, Queue_User_Relationship__c> queueUserMap = new Map<Id, Queue_User_Relationship__c>([SELECT Id, Business_Hours__c,Out_Of_Office_Notification__c FROM Queue_User_Relationship__c WHERE Id IN :caseQueueMap.keySet()]);
            
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            CSM_Case_Details_Global_Setting__c noReply = CSM_Case_Details_Global_Setting__c.getValues('Org Wide No-Reply PEP');
            CSM_Case_Details_Global_Setting__c tempPRM = CSM_Case_Details_Global_Setting__c.getValues('ET TECH EN PRM OOO Queue Message');
            Map<String, String> templateIdNameMap = new Map<String, String>();
            for (Case c : casesToProcess) {
                system.debug('Cases to process '+c.id);
                Queue_User_Relationship__c queueUser = queueUserMap.get(c.InitialQueueData__c);
                if (queueUser != null && queueUser.Business_Hours__c != null && queueUser.Out_Of_Office_Notification__c) {
                    Boolean isWithinBusinessHours = BusinessHours.isWithin(queueUser.Business_Hours__c, DateTime.now());
                    if (Test.isRunningTest() || (!isWithinBusinessHours && tempPRM != null && tempPRM.Component_Id__c != null)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(templateIdNameMap != null){
                            email.setToAddresses(new String[] { c.ContactEmail});
                            email.setSaveAsActivity(false);
                            email.setTemplateId(tempPRM.Component_Id__c);
                            email.setTargetObjectId(c.ContactId);
                            email.setTreatTargetObjectAsRecipient(false);
                            email.setWhatId(c.Id);
                            email.setReferences(Cases.generateThreadingMessageId(c.Id));
                            if(noReply != null && noReply.Component_Id__c != null && noReply.Component_Id__c.length() > 0) {
                                email.setOrgWideEmailAddressId(noReply.Component_Id__c);
                            }
                            emailsToSend.add(email);
                        }
                    }
                }
                
            }
            
            if (!emailsToSend.isEmpty()) {
                try{
                     Messaging.sendEmail(emailsToSend);
                }
                catch(Exception ex){
                    System.debug('Mail Exception: '+ex.getMessage());
                }
               
            }
        }  
    }
    
    public static Map<String,List<Queue_User_Relationship__c>> getGroupId_UsersMap(set<Id> queueIds){
        List<Queue_User_Relationship__c> lstQueue = new SLT_QueueUserRelationshipC().selectByQueueUserforRoundRobin(queueIds);
        Map<String,List<Queue_User_Relationship__c>> mapGrpWithUser = new Map<String,List<Queue_User_Relationship__c>>(); 
        String key = null;
        for(Queue_User_Relationship__c record : lstQueue){
            key = (record.Type__c == 'Queue') ? record.Id : record.TECH_QueueUser__c;
            if(mapGrpWithUser.containsKey(key))
                mapGrpWithUser.get(key).add(record);
            else
                mapGrpWithUser.put(key,new List<Queue_User_Relationship__c>{record});
        }
        return mapGrpWithUser;
    }
    
    public static Map<Id,List<CaseHistory__C>> getCaseHistoryMap( set<Id> groupIds, set<Id> caseIds){
        List<CaseHistory__C> ch = [SELECT Id,OldCaseOwner__c, OldCurrentQueue__c, OldCaseOwnerId__c, Case__c from CaseHistory__C where OldCurrentQueue__c in:groupIds and Case__c in : caseIds order by DateTimeofchange__c  desc ];
        Map<Id,List<CaseHistory__C>> mapCH = new Map<Id,List<CaseHistory__C>>();
        for(CaseHistory__C record : ch){
            if(mapCH.containsKey(record.Case__c)){
                mapCH.get(record.Case__c).Add(record); 
            }             
            else{
                mapCH.put(record.Case__c,new List<CaseHistory__C>{record});
            }
        }
        return mapCH;
    }
    
    public static Queue_User_Relationship__c getRecordByUserId(List<Queue_User_Relationship__c> usersInQueue, string recordId){
        Queue_User_Relationship__c record;
        for(Queue_User_Relationship__c rec : usersInQueue){
            if(rec.user__c == recordId){
                record = rec; break;
            }
        }
        if(record!= null)
            return record;
        else
            return null;
    }
    
    public static List<Queue_User_Relationship__c> getUserInQueueByGrpId(Map<Id,List<Queue_User_Relationship__c>> mapGrpWithUser,string grpId,boolean isRoundRobin){
        List<Queue_User_Relationship__c> roundRobinList = mapGrpWithUser.get(grpId);
        List<Queue_User_Relationship__c> usersInQueue = new List<Queue_User_Relationship__c>();
        for(Queue_User_Relationship__c qur : roundRobinList){
            if(qur.Type__c == CON_CSM.S_USER 
               && (
                   (qur.OutOfOffice_StartDate__c == null && qur.OutOfOffice_EndDate__c == null)
                   || !(qur.OutOfOffice_StartDate__c != null && qur.OutOfOffice_EndDate__c != null && qur.OutOfOffice_StartDate__c <= System.now() && qur.OutOfOffice_EndDate__c >= System.now())
               )){                     
                   usersInQueue.add(qur);
               }else if(qur.Type__c == CON_CSM.S_QUEUE){
                   isRoundRobin = qur.Enable_Round_Robin__c;
               }
        }
        if(usersInQueue!= null && !usersInQueue.isEmpty())
            return usersInQueue;
        else
            return null;
    }
    
    public static void AssignCaseOwner(Case c,Queue_User_Relationship__c record){
        if(c.Origin == CON_CSM.S_CUSTOMER_PORTAL && UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
            c.Owner__c = record.User__c;
        }else{
            c.OwnerId = record.User__c;
        }
        DateTime now = DateTime.now();
        record.LastAssignedCaseTime__c = now;
        record.LastAssignedCaseMilliseconds__c = now.millisecondGMT();
    }
   
    public static void assignUserToCaseByRoundRobinOnUpdate(List<Case> newList,Map<Id, Case> oldMap){
        
        set<Id> groupIds = new Set<Id>();  
        set<Id> caseIds = new Set<Id>();
        Set<Id> queueIds = new Set<Id>();
        Map<String,List<Queue_User_Relationship__c>> mapGrpWithUser = null;
        for(case c : newList){
            if(oldMap != null && (((string)c.OwnerId).startsWith('00G')) && (c.OwnerId != oldMap.get(c.Id).OwnerId || c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c) && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T)){
                caseIds.Add(c.Id);
                queueIds.Add(c.CurrentQueue__c);
            }
            
        }
        
        if(queueIds != null && !queueIds.isEmpty()){
            mapGrpWithUser = getGroupId_UsersMap(queueIds);    
        }
        
        if(mapGrpWithUser!=null && !mapGrpWithUser.isEmpty()){
            
            Map<Id,List<CaseHistory__C>> mapCH = getCaseHistoryMap(queueIds,caseIds);            
            boolean isRoundRobin = false;
            boolean foundInHistory = false;
            List<Queue_User_Relationship__c> usersInQueue = new List<Queue_User_Relationship__c>();
            List<Queue_User_Relationship__c> userToUpdate = new List<Queue_User_Relationship__c>();
            List<Queue_User_Relationship__c> roundRobinList = null;
            List<CaseHistory__C> chistory = null;
            for(Case c : newList){
                if((oldMap!=null && oldMap.get(c.Id)!= null && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c)){
                    
                    if(mapGrpWithUser!=null && !mapGrpWithUser.isEmpty() && mapGrpWithUser.containsKey(c.CurrentQueue__c)){
                        
                        roundRobinList = mapGrpWithUser.get(c.CurrentQueue__c);
                        for(Queue_User_Relationship__c qur : roundRobinList){
                            if(qur.Type__c == CON_CSM.S_USER 
                               && (
                                   (qur.OutOfOffice_StartDate__c == null && qur.OutOfOffice_EndDate__c == null)
                                   || !(qur.OutOfOffice_StartDate__c != null && qur.OutOfOffice_EndDate__c != null && qur.OutOfOffice_StartDate__c <= System.now() && qur.OutOfOffice_EndDate__c >= System.now())
                               )){                     
                                   usersInQueue.add(qur);
                               }else if(qur.Type__c == CON_CSM.S_QUEUE){
                                   isRoundRobin = qur.Enable_Round_Robin__c;
                               }
                        }
                        
                        if(usersInQueue != null && !usersInQueue.isEmpty()){
                            
                            if(isRoundRobin && (c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T)) {                            
                               if(mapCH != null && !mapCH.isEmpty() &&mapCH.containsKey(c.Id) ){
                                   chistory = mapCH.get(C.Id);
                                   for(CaseHistory__c his : chistory){
                                       if(his.OldCurrentQueue__c == c.CurrentQueue__c){
                                           Queue_User_Relationship__c record = getRecordByUserId(usersInQueue,his.OldCaseOwnerId__c);
                                           if(record!=null){
                                               AssignCaseOwner(c,record);
                                               userToUpdate.add(record);
                                               foundInHistory=true;
                                               break;
                                           }
                                       }
                                   }
                               }
                               if(!foundInHistory && !usersInQueue.isEmpty()){
                                   AssignCaseOwner(c,usersInQueue[0]);
                                   userToUpdate.add(usersInQueue[0]);
                               }
                            }
                        }
                    }
                }
            } 
            
            if(!userToUpdate.IsEmpty()){
                update userToUpdate;
            }
        }
    }

    /* PRM-1015: Included to send email when queue business hour is in Holiday*/
    public static void assignUserToCaseByRoundRobin(List<Case> newList,String initialQueue){
        List<Queue_User_Relationship__c> userToUpdate = new List<Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> usersInQueue = new List<Queue_User_Relationship__c>();
        boolean isRoundRobin = false;
        CSM_Case_Details_Global_Setting__c noReply = CSM_Case_Details_Global_Setting__c.getValues('Org Wide No-Reply');
        CSM_Case_Details_Global_Setting__c tempCSH = CSM_Case_Details_Global_Setting__c.getValues('ET TECH EN CSH OOO Queue Message');
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        if(Test.isRunningTest() || UserInfo.getUserType().contains(CON_CSM.S_POWER_PARTNER) || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || UserInfo.getName() ==CON_CSM.S_SYSTEM){
            List<Queue_User_Relationship__c> roundRobinList = new SLT_QueueUserRelationshipC().selectByQueueNameforRoundRobin(initialQueue);
            if(roundRobinList != Null && !roundRobinList.isEmpty()){
                for(Queue_User_Relationship__c qur : roundRobinList){
                    if(Test.isRunningTest() || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || UserInfo.getName() ==CON_CSM.S_SYSTEM){
                        if(qur.Type__c == CON_CSM.S_USER && ((qur.OutOfOffice_StartDate__c == null && qur.OutOfOffice_EndDate__c == null) || !(qur.OutOfOffice_StartDate__c != null && qur.OutOfOffice_EndDate__c != null && qur.OutOfOffice_StartDate__c <= System.now() && qur.OutOfOffice_EndDate__c >= System.now()))){
                            usersInQueue.add(qur);
                        }else if(qur.Type__c == CON_CSM.S_QUEUE){
                            isRoundRobin = qur.Enable_Round_Robin__c;
                        }
                    }
                    if(newList != null && !newList.isEmpty() && qur.Type__c == CON_CSM.S_QUEUE && qur.Business_Hours__c != null && qur.Out_Of_Office_Notification__c){
                        Boolean isWithinBusinessHours = BusinessHours.isWithin(qur.Business_Hours__c, DateTime.now());
                        if (Test.isRunningTest() || (!isWithinBusinessHours && tempCSH != null&& tempCSH.Component_Id__c != null)) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(noReply != null && noReply.Component_Id__c != null && noReply.Component_Id__c.length() > 0) {
                                email.setOrgWideEmailAddressId(noReply.Component_Id__c);
                            }
                            email.setSaveAsActivity(false);
                            if(UserInfo.getName() ==CON_CSM.S_SYSTEM){
                            email.setToAddresses(new String[] {newList[0].SuppliedEmail});
                            }else{
                            email.setToAddresses(new String[] {UserInfo.getUserEmail()});
                            }
                            if(newList[0].ContactId != null){
                                email.setTemplateId(tempCSH.Component_Id__c);
                                email.setTargetObjectId(newList[0].ContactId);
                                email.setTreatTargetObjectAsRecipient(false);
                                email.setWhatId(newList[0].Id);
                            }else{
                                email.setSubject('Out Of Office Support');
                                email.setPlainTextBody('Dear Customer,\n\nThank you for contacting us! Our office is closed today and we will not be able to respond to your case.\nWe will do our best to get back to you as soon as possible.\nRegards');
                            }
                            emailsToSend.add(email);
                        }
                    }
                    
                }
                if (!emailsToSend.isEmpty()) {
                    try{
                       Messaging.sendEmail(emailsToSend); 
                    }catch(Exception e){
                        
                    }
                    
                }
            }    
        }
        for(Case c : newList){
            if(isRoundRobin && !usersInQueue.isEmpty() && (c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T)){
                    if(c.Origin == CON_CSM.S_CUSTOMER_PORTAL && UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                        c.Owner__c = usersInQueue[0].User__c;   //CSH
                    }else {
                        c.OwnerId = usersInQueue[0].User__c;   //e2c 
                    }
                    DateTime now = DateTime.now();
                    usersInQueue[0].LastAssignedCaseTime__c = now;
                    usersInQueue[0].LastAssignedCaseMilliseconds__c = now.millisecondGMT();
                    userToUpdate.add(usersInQueue[0]);
            }
        }
        if(userToUpdate.size()>0){
            try{
                update userToUpdate;
            }Catch(DmlException ex){
                String s = ex.getStackTraceString();
            }
        }
    }

    public static boolean checkMilestoneOrFieldUpdate(List<Case> newList,Map<Id, Case> oldMap,String action){
        boolean check = true;
        for(Case c : newList){
            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && (c.CSAT_Sent__c != oldMap.get(c.Id).CSAT_Sent__c || c.NextMilestoneStatus__c != oldMap.get(c.Id).NextMilestoneStatus__c || (c.CaseOriginatorName__c != oldMap.get(c.Id).CaseOriginatorName__c && (CON_CSM.S_INITIAL_RES_FAIL == c.CaseOriginatorName__c || CON_CSM.S_RESOLUTION_FAILD == c.CaseOriginatorName__c || CON_CSM.S_INITIAL_RES_FAIL == oldMap.get(c.Id).CaseOriginatorName__c || CON_CSM.S_RESOLUTION_FAILD == oldMap.get(c.Id).CaseOriginatorName__c)) )){
                check = false;
                break;
            }
        }
        if(!check){
            if(action == 'Before'){
                updateMileStoneStatusAndValue(newList);
                updateMilestoneAction(newList,oldMap);
            }else if(action == 'After'){
                updateCaseTaskQuickAction(newList,oldMap);
                completeCaseMilestone(newList,oldMap);    
            }
        }
        return check;
    }

    /**
    * This method is used to for Omni Channel Live Chat to set the record type IqviaLiveChat 
    * @params  newList List<Case>
    * @return  void
    */
    public static void setRecordtypetoIQVIALiveChat(List<Case> newList){
        Set<Id> caseIds = new Set<Id>();
        Map<Id,LiveChatTranscript> caseOwner = new Map<Id,LiveChatTranscript>(); 
        Set<String> queue = new Set<String>();
        String userId = '';
        Id accountId = null;
        CSM_QI_Data_Portal_Queue_User_details__c selectedData = null;
        boolean isFromBot = false;
        for(Case cas : newList){
            if(cas.InitialQueue__c == null && cas.CurrentQueue__c == null ){
                caseIds.add(cas.Id);
                if(cas.AccountId != null){
                    accountId = cas.AccountId;
                }
            }
        }
        List<LiveChatTranscript> liveChatList = Database.query('select Id,OwnerId,CaseId,Email__c,ContactId,LiveChatButtonId,LiveChatButton.QueueId,LiveChatButton.Queue.Name From LiveChatTranscript where CaseId in :caseIds');
        if(liveChatList != null && !liveChatList.isEmpty() ){
            for(LiveChatTranscript lct : liveChatList){
                if(lct.LiveChatButtonId != null &&  lct.LiveChatButton.QueueId != null && lct.LiveChatButton.Queue.Name != 'IQVIA Einstein Bot Queue'){
                    caseOwner.put(lct.CaseId , lct);
                }else{
                    isFromBot = true;
                }
                
            }

            if(accountId != null && isFromBot){
                List<CSM_QI_Data_Portal_Queue_User_details__c> outputDataList = Database.query('select Id, ClientContact__c, Queue_User_Relationship__c,Queue_User_Relationship__r.Name,Queue_User_Relationship__r.Group_Id__c, ContactUser__c, Account__c, Order__c, IQVIA_User__c, CaseRecordType__c, UserStatus__c From CSM_QI_Data_Portal_Queue_User_details__c where Type__c = \'Queue Assignment\' AND CaseRecordType__c = \'TechnologyCase\' and Account__c =:accountId and Order__c = 1 order by Order__c DESC');
                for(CSM_QI_Data_Portal_Queue_User_details__c data : outputDataList){
                    selectedData = data;
                    break;
                }
            }
            for(Case cas : newList){
                if(caseOwner.containskey(cas.Id)){
                    cas.InitialQueue__c = caseOwner.get(cas.Id).LiveChatButton.Queue.Name;
                    queue.add(cas.InitialQueue__c);
                    userId = cas.OwnerId;
                }else if(selectedData != null){
                    cas.CurrentQueue__c = selectedData.Queue_User_Relationship__c;
                    cas.InitialQueue__c = selectedData.Queue_User_Relationship__r.Name;
                    cas.OwnerId = selectedData.Queue_User_Relationship__r.Group_Id__c;
                }
                cas.Origin = 'Chat';
            }
            
            if(queue != null && !queue.isEmpty()){
                List<Queue_User_Relationship__c> listQueue = new SLT_QueueUserRelationshipC().selectByUserQueueName(new Set<Id> {userId},queue);
                for(Case c : newList){
                    for( Queue_User_Relationship__c q : listQueue){
                        if(q.Name == c.InitialQueue__c){
                            c.CurrentQueue__c = q.Id; 
                        }    
                    }
                }  
            }
        }
        
    }

    /**
    * This method is used to to update the Account/Site entitlement process Id and bussiness hour for all Pillars
    * @params  newList List<Case>
    * @return  void
    */
    public static void entitlemebtAccAPCase01(List<Case> newList,Map<Id, Case> oldMap,Map<Id,Account> accountMDMs){
        Map<Id,Id> acct = new Map <Id,Id>();
        Map<Id,Id> con = new Map<Id,Id>();
        Map<Id,Id> conRDMAP = new Map <Id,Id>();
        Map<Id,Id> studyIdMap = new Map <Id,Id>();
        Set<Id> eIds = new Set <Id>();
        Map<Id,Id> siteAccountIdRDMap = new Map <Id,Id>();
        Map<String, Id> EntMap = new Map<String, Id>();
        Map<String, Id> bHoMap = new Map<String, Id>();
        Map<String, Id> conReqMap = new Map<String, Id>();
        Map<Id, Id> conReqBHMap = new Map<Id, Id>();
        Set<Case> caseSet = new Set<Case>();
        String recordType;
        String mytype = null;
        for (Case c : newList) {
            if(c.EntitlementId != null ){
                eIds.add(c.EntitlementId);
            }
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && ((oldMap == null && (c.Country_of_the_requester2__c != null || (c.ProductName__c != null && c.SubType1__c != null && c.SubType2__c != null))) || (oldMap != null && c.Country_of_the_requester2__c != oldMap.get(c.Id).Country_of_the_requester2__c)) ){
                caseSet.add(c);
                recordType = c.RecordTypeId;
            }
            if((c.RecordTypeName__c == CON_CSM.S_DATACASE || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T) && (Trigger.isInsert || (oldMap != null && Trigger.IsUpdate && (c.RecordTypeName__c == CON_CSM.S_DATACASE && ((c.Subtype3__c != null && c.Subtype3__c != oldMap.get(c.Id).Subtype3__c ) || ( c.Substatus__c != null && c.Substatus__c != oldMap.get(c.Id).Substatus__c))) || ( c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (c.SLA_Policies__c != oldMap.get(c.Id).SLA_Policies__c || (c.ProductName__c != null && c.ProductName__c != oldMap.get(c.Id).ProductName__c && (c.ProductName__c.containsIgnoreCase(CON_CSM.S_SmartSolve) || c.ProductName__c.containsIgnoreCase(CON_CSM.S_CENTRIS) || c.ProductName__c == CON_CSM.S_DR || c.ProductName__c == CON_CSM.S_IDP || c.ProductName__c == 'IQVIA HIS' || c.ProductName__c == CON_CSM.S_MDM || c.ProductName__c == 'DIT' || c.ProductName__c == 'DOC' || c.ProductName__c == 'DSM' || c.ProductName__c == 'MobiRep' || c.ProductName__c == 'Pharm In Touch' || c.ProductName__c == 'VET' || c.ProductName__c.containsIgnoreCase(CON_CSM.S_EFX))))) || (c.Status != null && c.Status != oldMap.get(c.Id).Status) || (c.SubType1__c  != null && c.SubType1__c != oldMap.get(c.Id).SubType1__c) || (c.SubType2__c  != null && c.SubType2__c != oldMap.get(c.Id).SubType2__c)  || (c.Case_Type__c  != null && c.Case_Type__c != oldMap.get(c.Id).Case_Type__c)  || (c.AccountId != null && c.AccountId != oldMap.get(c.Id).AccountId )))){
                if (c.AccountId != Null) {
                    acct.put(c.AccountId, c.Id);
                    if(c.EntitlementId != null && c.AccountId != null && oldMap != null && oldMap.get(c.Id) != null && c.AccountId != oldMap.get(c.Id).AccountId){
                        c.EntitlementId = null;
                        c.BusinessHoursId = bhSoql.Id;
                    }
                }else if(c.ContactId != Null) {
                    con.put(c.ContactId, c.Id);
                }
            //}else if((c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE) && (Trigger.isInsert || (oldMap != null && Trigger.IsUpdate && c.Study__c != null && c.Site_Related_to_the_Study__c != null && (c.Study__c != oldMap.get(c.Id).Study__c || c.Site_Related_to_the_Study__c != oldMap.get(c.Id).Site_Related_to_the_Study__c || c.SubType3__c != oldMap.get(c.Id).SubType3__c || c.Template__c != oldMap.get(c.Id).Template__c) ) )) {
            }else if((c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE) && (Trigger.isInsert || (oldMap != null && Trigger.IsUpdate && (c.Study__c != oldMap.get(c.Id).Study__c || c.SubType3__c != oldMap.get(c.Id).SubType3__c || c.Template__c != oldMap.get(c.Id).Template__c) ) )) {
                if(c.Study__c != Null ){
                    studyIdMap.put(c.Study__c, c.Id);
                    if(c.EntitlementId != null && c.Study__c != null && oldMap != null && oldMap.get(c.Id) != null && c.Study__c != oldMap.get(c.Id).Study__c){
                        c.EntitlementId = null;
                        c.BusinessHoursId = bhSoql.Id;
                    }
                }
                /*if(c.Site_Related_to_the_Study__c != Null ){
                    siteIdMap.put(c.Site_Related_to_the_Study__c, c.Id);
                    if(c.EntitlementId != null && c.Site_Related_to_the_Study__c != null && oldMap != null && oldMap.get(c.Id) != null && c.Site_Related_to_the_Study__c != oldMap.get(c.Id).Site_Related_to_the_Study__c){
                        c.EntitlementId = null;
                        c.BusinessHoursId = bhSoql.Id;
                    }
                }else if(c.ContactId != Null) {
                    con.put(c.ContactId, c.Id);
                }*/
            }  
            if(Trigger.isInsert){
                c.StatusChangedTime__c = System.now();
                c.BusinessElapsedTime__c = 0;
            }
        }
        Set<String> prodSet = new Set<String>();
        Set<String> sub1Set = new Set<String>();
        Set<String> sub2Set = new Set<String>();
        Set<String> sub3Set = new Set<String>();
        List<CSM_QI_Case_Categorization__c> ccList = new List<CSM_QI_Case_Categorization__c>();
        if(caseSet != null && !caseSet.isEmpty()){
            sub3Set.add('--none--');
            for(Case cs : caseSet){
                if(cs.Country_of_the_requester2__c != null){
                    conReqMap.put(cs.Country_of_the_requester2__c,cs.Id);
                }
                if(oldMap == null){
                    if(cs.ProductName__c != null){
                        prodSet.add(cs.ProductName__c);
                        if(cs.SubType1__c != null){
                            sub1Set.add(cs.SubType1__c);
                        }
                        if(cs.SubType2__c != null){
                            sub2Set.add(cs.SubType2__c);
                        }
                        if(cs.SubType3__c != null){
                            sub3Set.add(cs.SubType3__c);
                        }
                    }
                }
            }
            if(!conReqMap.isEmpty() || !prodSet.isEmpty()){
                ccList = new SLT_CaseCategorization().getCaseCategorizationList(conReqMap.keySet(),prodSet,sub1Set,sub2Set,sub3Set,recordType);
                for(CSM_QI_Case_Categorization__c cc : ccList){
                    if(conReqMap.containsKey(cc.CountryOfRequester__c)){
                        conReqBHMap.put(conReqMap.get(cc.CountryOfRequester__c), cc.Business_Hours__c);
                    }
                }
            }
        }
        if (con.isEmpty() == false) {
            for (Contact cont : [select Id, AccountId from Contact where Id In:con.keySet() limit 50000]) {
                acct.put(cont.AccountId, cont.Id);
                conRDMAP.put(cont.Id, cont.AccountId); 
            }
        }
        if(!studyIdMap.isEmpty()) {
            List<Study__c> studyList = new SLT_StudyC().selectAccountByStudyId(studyIdMap.keyset(),new Set<String> {CON_CSM.S_ID,'Sponsor__c'}); 
            for (Study__c s : studyList) {
                  if(studyIdMap.containsKey(s.Id)){
                    acct.put(s.Sponsor__c, s.Id);
                    siteAccountIdRDMap.put(s.Id,s.Sponsor__c);
                }
            }
        }
        /*if(siteIdMap.isEmpty() == false) {
            List<StudySiteContactRelationship__c> siteList = new SLT_StudySiteContactRelationship().selectAccountBySiteId(siteIdMap.keyset(),new Set<String> {CON_CSM.S_ID,'Site_Name__c'}); 
            for (StudySiteContactRelationship__c s : siteList) {
                  if(siteIdMap.containsKey(s.Id)){
                    acct.put(s.Site_Name__c, s.Id);
                    siteAccountIdRDMap.put(s.Id,s.Site_Name__c);
                }
            }
        }*/
        Map<Id,Date> eMapStart = new Map<Id,Date>();
        Map<Id,Date> eMapEnd = new Map<Id,Date>();
        if(acct.isEmpty() == false){
            List<Entitlement> entList = new SLT_Entitlement().selectByAccountId(acct.keyset(),eIds);
            for(Entitlement e : entList){
                if(e.Status == 'Active'){
                    entMap.put(e.AccountId+'_'+e.Type, e.Id);
                    if(e.BusinessHoursId != null){ bHoMap.put(e.Id, e.BusinessHoursId); }
                }else if(e.Status != 'Active'){
                    eMapEnd.put(e.Id, e.EndDate);
                }
                eMapStart.put(e.Id, e.StartDate);
            }
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('ROCHESNOW');
            for (Case c : newList) {
                mytype = null;
                if((c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE)) {
                    mytype = CON_CSM.S_E_R_D;
                }else if (c.RecordTypeName__c == CON_CSM.S_DATACASE) {
                    if(c.InitialQueue__c != null && c.InitialQueue__c == CON_CSM.S_DATA_ESQ ){
                        mytype = CON_CSM.S_DATA_ES;
                    }else {
                        mytype = CON_CSM.S_E_DATA;
                    }
                }else if (c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T) {
                    if(c.AccountId != null && ecc != null && c.AccountId == ecc.Account_Id__c){
                        mytype = CON_CSM.S_TECH_ROCHE;
                    }else if(c.ProductName__c != null && (c.ProductName__c == CON_CSM.S_DR || c.ProductName__c ==  'OA EMEA Application Services' || c.ProductName__c == CON_CSM.S_FIC || c.ProductName__c == CON_CSM.S_IVAPBI || c.ProductName__c == CON_CSM.S_QLIKVIEW || c.ProductName__c == CON_CSM.S_QLIKSENSE || c.ProductName__c == CON_CSM.S_EMEA_DR)){
                        mytype = CON_CSM.S_TECHDR;
                    }else if(c.ProductName__c == CON_CSM.S_IDP || c.ProductName__c == CON_CSM.S_MDM){
                        mytype = CON_CSM.S_TECH_IDPMDM;
                    }else if(c.ProductName__c == 'DIT' || c.ProductName__c == 'DOC' || c.ProductName__c == 'DSM' || c.ProductName__c == 'MobiRep' || c.ProductName__c == 'Pharm In Touch' || c.ProductName__c == 'VET'){
                        mytype = 'TECHNO SMART IT';
                    }else if(c.ProductName__c != null && c.ProductName__c == 'IQVIA HIS'){
                        mytype = 'TECH IQVIA HIS';
                    }else if(c.ProductName__c != null && c.ProductName__c.containsIgnoreCase(CON_CSM.S_OA)){
                        mytype = CON_CSM.S_TOA;
                    }else if(c.ProductName__c != null && c.ProductName__c.containsIgnoreCase(CON_CSM.S_SmartSolve)){
                        mytype = CON_CSM.S_TECHSmartSolve;
                    }else if(c.ProductName__c != null && (c.ProductName__c.containsIgnoreCase(CON_CSM.S_CENTRIS) || c.ProductName__c.containsIgnoreCase(CON_CSM.S_EFX))){
                        mytype = CON_CSM.S_TECHCentris;
                    }else if(c.SLA_Policies__c != null){
                        mytype = CON_CSM.S_E_TECHNOCC;    
                    }else{
                        mytype = CON_CSM.S_E_TECHNO; 
                    }
                }
                
                if(mytype != null){
                    if(CON_CSM.S_E_R_D.equals(mytype) && entMap != null){
                        /*if(con != null && conRDMAP != null && con.containsKey(c.ContactId) && entMap.containsKey(conRDMAP.get(c.ContactId)+'_'+mytype)) {
                            c.EntitlementId = entMap.get(conRDMAP.get(c.ContactId)+'_'+mytype);
                        }else if(siteIdMap != null && siteIdMap.containsKey(c.Site_Related_to_the_Study__c) && entMap.containsKey(siteAccountIdRDMap.get(c.Site_Related_to_the_Study__c)+'_'+mytype)){
                            c.EntitlementId = entMap.get(siteAccountIdRDMap.get(c.Site_Related_to_the_Study__c)+'_'+mytype);
                        }else */
                        if(studyIdMap != null &&  studyIdMap.containsKey(c.Study__c) && entMap.containsKey(siteAccountIdRDMap.get(c.Study__c)+'_'+mytype)){
                            c.EntitlementId = entMap.get(siteAccountIdRDMap.get(c.Study__c)+'_'+mytype);
                        }
                    }else if(!(CON_CSM.S_E_R_D.equals(mytype))){
                        if(con != null && conRDMAP != null && con.containsKey(c.ContactId) && entMap.containsKey(conRDMAP.get(c.ContactId)+'_'+mytype)) {
                            c.EntitlementId = entMap.get(conRDMAP.get(c.ContactId)+'_'+mytype);
                        }else if(c.AccountId != null && entMap.containsKey(c.AccountId+'_'+mytype)){
                            c.EntitlementId = entMap.get(c.AccountId+'_'+mytype);
                        }   
                    }
                    if(c.EntitlementId != null && bHoMap.get(c.EntitlementId) != null){
                        c.BusinessHoursId =  bHoMap.get(c.EntitlementId);   
                    }else if (entMap != null && entMap.size() == 0){
                        c.EntitlementId = null;
                    }
                } 
                if(Trigger.isUpdate && oldMap != null && oldMap.get(c.Id) != null && c.EntitlementId != oldMap.get(c.Id).EntitlementId){
                    DateTime dT = c.CreatedDate;
                    Date created = date.newinstance(dT.year(), dT.month(), dT.day());
                    if(EMapStart.containsKey(c.EntitlementId) && created < EMapStart.get(c.EntitlementId)){
                        c.EntitlementId = oldMap.get(c.Id).EntitlementId;
                        c.BusinessHoursId = oldMap.get(c.Id).BusinessHoursId;
                    }
                    if(EMapEnd.containsKey(c.EntitlementId) && created < EMapEnd.get(c.EntitlementId)){
                        c.EntitlementId = oldMap.get(c.Id).EntitlementId;
                        c.BusinessHoursId = oldMap.get(c.Id).BusinessHoursId;
                    }
                }                
            }    
        }
        /*BusinessHoursId selected based on country Of Requester2 */
        for (Case c : newList) {
            if(conRDMAP != null && !conRDMAP.isEmpty() && c.AccountId == null && c.ContactId != null && conRDMAP.containsKey(c.ContactId)){
                c.AccountId = conRDMAP.get(c.ContactId);
            }
            if(conReqBHMap != null && !conReqBHMap.isEmpty() && conReqBHMap.containsKey(c.Id)){
                c.BusinessHoursId = conReqBHMap.get(c.Id);
            }
            for(CSM_QI_Case_Categorization__c cc : ccList){
                if(cc.CaseType__c != null && c.ProductName__c == cc.ProductName__c && c.SubType1__c == cc.SubType1__c && c.SubType2__c == cc.SubType2__c && c.SubType3__c == cc.SubType3__c){
                    c.Case_Type__c = cc.CaseType__c;
                }
            }
        }
        
    }
    
    /**
    * This method is used when user reopen the closed case then milestone completionDate also changed to empty so that milestones will active
    * @params  newList List<Case>
    * @return  void
    */
    @future
    public static void reOpenMilestone(List<Id> newList) {  
        Boolean updateCheck = false;
        String milestoneName = CON_CSM.S_FIRST_RESPONSE_T;
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate,MilestoneType.Name from CaseMilestone cm where caseId in :newList and cm.MilestoneType.Name != :milestoneName];
        if(!cmsToUpdate.isEmpty()) {
            for (CaseMilestone mileStoneData : cmsToUpdate){
                if(mileStoneData.completionDate != null && !CON_CSM.S_FIRST_RESPONSE_T.equalsIgnoreCase(mileStoneData.MilestoneType.Name) ) {
                    mileStoneData.completionDate = null;
                    updateCheck = true;
                }
            }
            try {
                if(updateCheck) {
                    update cmsToUpdate;
                }
                
            } catch (DmlException e) {}
            
        }
    }
    
    /**
    * This method is used complete the case milestone by setting completionDate as current system date
    * @params  newList List<Case>
    * @return  void
    */
    public static void completeCaseMilestone(List<Case> newList,Map<Id, Case> oldMap){
        if (UserInfo.getUserType() == 'Standard' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
            DateTime completionDate = System.now();
            List<Id> updateCases = new List<Id>();
            //List<Id> updateCaseForTechno = new List<Id>();
            List<Id> updateFirstResponse = new List<Id>();
            List<Id> updateReopenCase = new List<Id>();
            List<Id> updateViolation = new List<Id>();
            List<CaseMilestone> cmsToUpdate = new  List<CaseMilestone>();
            for (Case c : newList){
                if(CON_CSM.S_DATACASE == c.RecordTypeName__c && CON_CSM.S_CLOSED == oldMap.get(c.Id).Status &&  (CON_CSM.S_CASE_Acknowledged == c.Status || CON_CSM.S_IN_PROGRESS == c.Status || CON_CSM.S_WAITING_FOR == c.Status || CON_CSM.S_NEW == c.Status)) {
                    updateReopenCase.add(c.Id);
                }
                /**if ((CON_CSM.S_TECHNOLOGY_R_T.equalsIgnoreCase(c.RecordTypeName__c) && (c.Status!= null) && (c.Status == CON_CSM.S_RESOLVED_WITH_C) && oldMap != null && oldmap.get(c.Id) != null && (!c.Status.equalsIgnoreCase(oldMap.get(c.Id).Status)))){
                    updateCaseForTechno.add(c.Id);
                }**/
                if (c.isClosed == true && c.IsClosed != oldMap.get(c.Id).IsClosed){
                    updateCases.add(c.Id);
                }else if (CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.Milestone_Violation__c != oldMap.get(c.Id).Milestone_Violation__c && c.Milestone_Violation__c && c.SlaExitDate == null){
                    updateViolation.add(c.Id);
                /** }else if (CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.IsClosed && c.SlaExitDate == null){
                    updateFirstResponse.add(c.Id); **/
                }
                
            }
            
            if (updateCases.isEmpty() == false){
                List<CaseMilestone> cmsToComplete = [select Id, completionDate from CaseMilestone cm where caseId in :updateCases and completionDate = null];
                if (cmsToComplete.isEmpty() == false){
                    for (CaseMilestone cm : cmsToComplete){
                        cm.completionDate = completionDate;
                        cmsToUpdate.add(cm);
                    }
                }   
            }
            /** if(updateCaseForTechno != null && !updateCaseForTechno.isEmpty() && updateCaseForTechno.size() > 0){
                String milestoneName = CON_CSM.S_RESOLUTION_TIME;
                List<CaseMilestone> cmsToComplete = [select Id, completionDate,TargetDate,IsViolated from CaseMilestone cm where caseId in :updateCaseForTechno and cm.MilestoneType.Name = :milestoneName and completionDate = null];
                if (cmsToComplete.isEmpty() == false){
                    for (CaseMilestone cm : cmsToComplete){
                        cm.completionDate = completionDate;  
                        cmsToUpdate.add(cm);
                    }
                }
            } **/
            if (updateFirstResponse.isEmpty() == false && updateFirstResponse.size() > 0){
                String milestoneName = CON_CSM.S_FIRST_RESPONSE_T;
                List<CaseMilestone> cmsToFirstRes = [select Id, completionDate from CaseMilestone cm where caseId in :updateFirstResponse and cm.MilestoneType.Name = :milestoneName and completionDate = null];
                if (cmsToFirstRes.isEmpty() == false){
                    for (CaseMilestone cm : cmsToFirstRes){
                        cm.completionDate = completionDate;
                        cmsToUpdate.add(cm);
                    }
                }
            }else if(updateViolation != null && !updateViolation.isEmpty() && updateViolation.size() > 0){
                String milestoneName = CON_CSM.S_COMMUNICATION_UPD;
                List<CaseMilestone> cmsToViolation = [select Id, completionDate,TargetDate,IsViolated from CaseMilestone cm where caseId in :updateViolation and cm.MilestoneType.Name = :milestoneName and completionDate = null];
                if (cmsToViolation.isEmpty() == false){
                    for (CaseMilestone cm : cmsToViolation){
                        cm.completionDate = completionDate;  
                        cmsToUpdate.add(cm);
                    }
                }
            }
            try {
                if(cmsToUpdate.isEmpty() == false && cmsToUpdate.size() > 0){
                    update cmsToUpdate;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
            if(!(System.isFuture() || System.isBatch())){
                if(!updateReopenCase.isEmpty() && updateReopenCase.size() > 0){
                    reopenMilestone(updateReopenCase);    
                }
                if(updateViolation!= null && !updateViolation.isEmpty() && updateViolation.size() > 0){
                    SRV_CSM_AssignPermissionSet.updateMilestoneVilotaion(updateViolation);    
                }
            } 
        }
    }
    
    /**
    * This method is used complete the case single milestone by setting completionDate as current system date
    * @params  newList List<Case>
    * @return  void
    */
    public static void completeMilestone(List<Id> caseIds,String milestoneName, DateTime complDate) {
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone cm where caseId in :caseIds and cm.MilestoneType.Name = :milestoneName and completionDate = null limit 1];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            try {
                if(cmsToUpdate.isEmpty() == false && cmsToUpdate.size() > 0){
                    update cmsToUpdate;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
    }
    
    /**
    * This method is used complete the list of case milestone by setting completionDate as current system date
    * @params  newList List<Case>
    * @return  void
    */
    public static void completeMilestone(List<Id> caseIds,List<String> milestoneNames, DateTime complDate) {
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone cm where caseId in :caseIds and cm.MilestoneType.Name in :milestoneNames and completionDate = null];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            try {
                if(cmsToUpdate.isEmpty() == false && cmsToUpdate.size() > 0){
                    update cmsToUpdate;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
    }
    
    /**
    * This method is used update the case fields with case milestone fields
    * @params  newList List<Case>
    * @return  void
    */
    public static void updateCaseWithMilestone(List<Case> newList) {
        List<Id> caseIdList = new List<Id>();
        Map<Id,CaseMilestone> cmsMap=new Map<Id,CaseMilestone>();
        for (Case c : newList){
            caseIdList.add(c.Id);
        }
        if(caseIdList.isEmpty() == false){
            List<CaseMilestone> cmsList = [select Id,CaseId,StoppedTimeInMins,StoppedTimeInHrs,StoppedTimeInDays,ActualElapsedTimeInMins,ActualElapsedTimeInHrs,ActualElapsedTimeInDays from CaseMilestone cm where caseId in :caseIdList];
            for (CaseMilestone cms : cmsList){
                cmsMap.put(cms.CaseId,cms);
            }
        }
        
        if(cmsMap.isEmpty() == false){
            CaseMilestone cmsIf=null;
            for(Case c : newList){
                if(cmsMap.containsKey(c.Id) ){
                    cmsIf = cmsMap.get(c.Id);
                    c.StoppedTimeInMins__c = cmsIf.StoppedTimeInMins;
                    c.StoppedTimeInHrs__c = cmsIf.StoppedTimeInHrs;
                    c.StoppedTimeInDays__c = cmsIf.StoppedTimeInDays;
                    c.ActualElapsedTimeInMins__c = cmsIf.ActualElapsedTimeInMins;
                    c.ActualElapsedTimeInHrs__c = cmsIf.ActualElapsedTimeInHrs;
                    c.ActualElapsedTimeInDays__c = cmsIf.ActualElapsedTimeInDays;  
                }
                
            }
            
        }
    }
    
    /**
    * This method is used update the case fields with Study Site Contact and Stydy for R&D,
    * Priority for Techno and Case Originator Name and Email for Data
    * @params  newList List<Case>
    * @return  void
    */
    public static void createCaseRelationfields(List<Case> newList, Map<Id,Case> oldMap) {
        
        Set<Id> studySet = new Set<Id>();
        Set<Id> siteContSet = new Set<Id>();
        Map<Id,Study__c> studyMap =null;
        Map<Id,StudySiteContactRelationship__c> siteContMap =null;
        Map<Id,String> accountMap = new Map<Id,String>();
        List<Account> accountList =null;
        Map<Id,Id> siteAccountMap = new Map<Id,Id>();
        Map<Id,String> sNowPrescriberMap = new Map<Id,String>();
        CSM_Case_Details_Global_Setting__c gd = CSM_Case_Details_Global_Setting__c.getValues('Tech_RCA_Document');
        for(Case c : newList) {
            if(Trigger.isInsert){
                c.CurrencyIsoCode = 'USD';
            }
            if(c.Id != null){
               c.Case_ThreadToken__c = EmailMessages.getFormattedThreadingToken(c.Id);
            }
            if(oldMap != null && (c.Status != oldMap.get(c.Id).Status || c.SubStatus__c != oldMap.get(c.Id).SubStatus__c)){
                c.CaseUpdatedTime__c = System.now();
            }
            if(c.RecordTypeName__c == CON_CSM.S_R_D_V_T){
                if(c.SuppliedEmail != null){
                    if(Trigger.isInsert){
                        c.Web_Email__c = c.SuppliedEmail; 
                    }else if(c.Patient__c){
                        c.SuppliedEmail = null;
                    }
                }else if(c.Web_Email__c != null && !c.Patient__c){
                    c.SuppliedEmail = c.Web_Email__c;
                }  
            }
            if(((oldMap == null) ||(oldMap!=null && oldMap.get(c.Id) != null)) && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && String.isEmpty(c.Device__c) && c.Status =='Closed'){
                c.Device__c ='Others';
            }
            if(((oldMap == null) ||(oldMap!=null && oldMap.get(c.Id) != null)) && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Status == CON_CSM.S_NEW && c.ProductName__c == 'ONEKEY' && c.SubType1__c == 'Service Request' && c.SubType2__c  == 'New Field Request'){
                c.Status = CON_CSM.S_IN_PROGRESS;
            }
            if(c.PII__c != null && c.RecordTypeName__c == CON_CSM.S_R_D_V_T && oldMap != null && oldMap.get(c.Id) != null && c.Service_Now_Incident_Number__c != null && c.Service_Now_Incident_Number__c != oldMap.get(c.Id).Service_Now_Incident_Number__c){
                c.PII__c = 'Anonymized';
            }
            if((c.Status =='Closed' || c.isClosed) && c.RecordTypeName__c == CON_CSM.S_R_D_CDP && (c.Phone_Number__c != null || c.ClientEmail__c != null)){
                c.Phone_Number__c = null;
                c.ClientEmail__c = null;
            }
            if(!((UserInfo.getName() == CON_CSM.S_CSM_MT && UserInfo.getUserType() == 'Standard') || UserInfo.getName() == CON_CSM.S_SYSTEM || UserInfo.getName() == CON_CSM.S_CSM_ADMIN  || UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || UserInfo.getName() == 'Integration ServiceNow' || UserInfo.getName() == 'BISM CSM API User' || UserInfo.getName() == 'ROCHE CSM API User')) {
                c.Last_Modified_by_Agent__c = UserInfo.getUserId();
                c.Last_Modified_by_Agent_Date__c = System.now();
            }
            if(c.Prescriber__c != null && (c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && ((Trigger.isInsert && c.Service_Now_Incident_Number__c != null) || (oldMap != null && oldMap.get(c.Id) != null && c.Service_Now_Incident_Number__c != null && c.Service_Now_Incident_Number__c != oldMap.get(c.Id).Service_Now_Incident_Number__c))){
                sNowPrescriberMap.put(c.Id, c.Prescriber__c);
            }
            if((c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || c.RecordTypeName__c == CON_CSM.S_DATACASE) && c.Mail_CC_List__c !=null && (oldMap == null || (oldMap != null && oldMap.get(c.Id) != null && oldMap.get(c.Id).Mail_CC_List__c != c.Mail_CC_List__c))){
                Pattern patt = Pattern.compile('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
                Matcher match = null;
                for(String mail : c.Mail_CC_List__c.split(';')){
                    match = patt.matcher(mail.trim());
                    if(!match.matches()){
                        c.addError('Invalid Email Address Format In Mail CC List');
                    }
                }
            }
            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.ScheduledDatetime__c != null && c.Status == 'Merged' && oldMap != null && oldMap.get(c.Id) != null && c.Status != oldMap.get(c.Id).Status){
                c.ScheduledDatetime__c = null;
                c.SubStatus__c = null;
            }
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && gd != null && c.RCA_Document_Link__c == null && c.Case_Type__c != null && c.Case_Type__c == 'Problem'){
                    c.RCA_Document_Link__c =  gd.Other_Details__c;
            }
            if(c.RecordtypeId != null && (CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c || c.RecordTypeName__c == CON_CSM.S_DATACASE || c.RecordTypeName__c == CON_CSM.S_DATACreateService ) && oldMap != null && oldMap.get(c.Id) != null && (c.RecordtypeId != oldMap.get(c.Id).RecordtypeId || c.AccountId != oldMap.get(c.Id).AccountId )){
                if(!(c.RecordtypeId == oldMap.get(c.Id).RecordtypeId && CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.AccountId != oldMap.get(c.Id).AccountId)){
                    c.AssetId = null;
                    c.ProductName__c = null;
                    c.SubType1__c  = null;
                    c.SubType2__c  = null;
                    c.SubType3__c  = null;
                }
                if(c.RecordTypeName__c == CON_CSM.S_DATACreateService ){
                    c.Case_CategorizationId__c = null;
                    c.Media_Date__c = null;
                    c.Media_Date_Label__c = null;
                    c.Media_Download_Date__c = null;
                }
                else{
                    c.Status = CON_CSM.S_IN_PROGRESS;
                }
                if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c){
                    if(c.Priority != null && !c.Priority.containsIgnoreCase('Priority')){
                        c.Priority = CON_CSM.PL_D2T_PRIORITY.get(c.Priority);
                        List<String> str = CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(c.Priority).split('~');
                        if(str != null &&  !str.isEmpty() ){
                            c.Urgency__c = str[0]; 
                            c.Techno_Impact__c = str[1];
                        }
                    } 
                    c.Case_Type__c = 'Incident';
                }else if(CON_CSM.S_DATACASE == c.RecordTypeName__c){
                    if(c.Priority != null && c.Priority.containsIgnoreCase('Priority')){
                        c.Priority = CON_CSM.PL_T2D_PRIORITY.get(c.Priority);
                    }
                    c.Urgency__c = null;
                    c.Techno_Impact__c = null;
                }
            }
            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c){
                if(c.Priority != null && c.Priority.containsIgnoreCase('Priority') && c.Origin == CON_CSM.S_EMAIL && CON_CSM.S_SYSTEM == userInfo.getName()){
                    List<String> str = CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(c.Priority).split('~');
                    if(str != null &&  !str.isEmpty() ){
                        c.Urgency__c = str[0]; 
                        c.Techno_Impact__c = str[1];
                    }
                }else if(c.Urgency__c != null && c.Techno_Impact__c != null && c.Origin == CON_CSM.S_EMAIL && !c.Priority.containsIgnoreCase('Priority')){
                    c.Priority = CON_CSM.PL_TECHNO_PRIORITY.get(c.Urgency__c+'~'+c.Techno_Impact__c);
                }else if(c.Urgency__c != null && c.Techno_Impact__c != null && (Trigger.isInsert || (Trigger.isUpdate && oldMap != null && (c.Urgency__c != oldMap.get(c.Id).Urgency__c || c.Techno_Impact__c != oldMap.get(c.Id).Techno_Impact__c)))){
                    c.Priority = CON_CSM.PL_TECHNO_PRIORITY.get(c.Urgency__c+'~'+c.Techno_Impact__c);
                }
                if(c.Priority != null && CON_CSM.PL_T2MILE_PRIORITY.containsKey(c.Priority) && (oldMap == null || (oldMap != null && oldMap.get(c.Id) != null && c.Priority != oldMap.get(c.Id).Priority))){
                    if(oldMap == null || c.TaskMilestone__c == null || ((oldMap != null && oldMap.get(c.Id) != null && c.RecordTypeId != oldMap.get(c.Id).RecordTypeId))){
                        c.TaskMilestone__c = 'IRT'+CON_CSM.PL_T2MILE_PRIORITY.get(c.Priority)+';RP'+CON_CSM.PL_T2MILE_PRIORITY.get(c.Priority);
                    }else if(oldMap !=null && c.TaskMilestone__c != null && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_PLAN_PROVID) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_PLAN) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_FAILD) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_FIRST_RESPONSE_T) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.PL_T2MILE_PRIORITY.get(oldMap.get(c.Id).Priority))){
                        c.TaskMilestone__c += ';IRT'+CON_CSM.PL_T2MILE_PRIORITY.get(c.Priority)+';RP'+CON_CSM.PL_T2MILE_PRIORITY.get(c.Priority);
                    }else if(oldMap !=null && oldMap.get(c.Id) != null && c.TaskMilestone__c != null && CON_CSM.PL_T2MILE_PRIORITY.containsKey(oldMap.get(c.Id).Priority) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_PLAN_PROVID) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_PLAN) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_FAILD) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_FIRST_RESPONSE_T) && c.TaskMilestone__c.containsIgnoreCase(CON_CSM.PL_T2MILE_PRIORITY.get(oldMap.get(c.Id).Priority))){
                        c.TaskMilestone__c = c.TaskMilestone__c.replaceAll(CON_CSM.PL_T2MILE_PRIORITY.get(oldMap.get(c.Id).Priority), CON_CSM.PL_T2MILE_PRIORITY.get(c.Priority));
                    }else if(oldMap !=null && oldMap.get(c.Id) != null && c.TaskMilestone__c != null && CON_CSM.PL_T2MILE_PRIORITY.containsKey(oldMap.get(c.Id).Priority) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_PLAN_PROVID) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_PLAN) && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_RESOLUTION_FAILD) && c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_FIRST_RESPONSE_T) && c.TaskMilestone__c.containsIgnoreCase('RP'+CON_CSM.PL_T2MILE_PRIORITY.get(oldMap.get(c.Id).Priority))){
                        c.TaskMilestone__c = c.TaskMilestone__c.replaceAll('RP'+CON_CSM.PL_T2MILE_PRIORITY.get(oldMap.get(c.Id).Priority), 'RP'+CON_CSM.PL_T2MILE_PRIORITY.get(c.Priority));
                    }
                }
            }
            if(CON_CSM.S_TECHNOLOGY_R_T == (c.RecordTypeName__c) && c.TaskMilestone__c != null && c.TaskMilestone__c.contains(CON_CSM.S_RCA_REQ) && !c.TaskMilestone__c.contains(CON_CSM.S_RCA_DELIVERED) && CON_CSM.S_RESOLVED_WITH_C == (c.Status)){
                c.SubStatus__c = CON_CSM.S_RCA;
            }
            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && Trigger.isInsert && ((c.Origin == 'Customer Portal' && UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) || (c.Origin == 'Email' && CON_CSM.S_SYSTEM == userInfo.getName()) || (c.Origin == 'Partner Portal' && UserInfo.getUserType().contains('Partner')))){
                c.CaseSource__c = CON_CSM.S_CUSTOMER;
            }
            if(Trigger.isInsert && CON_CSM.S_DATACASE == c.RecordTypeName__c && CON_CSM.S_SYSTEM != (UserInfo.getName())){
                if(c.CaseOriginatorName__c == null){
                    c.CaseOriginatorName__c = UserInfo.getName();    
                }
                if(c.CaseOriginatorEmail__c == null){
                    c.CaseOriginatorEmail__c = UserInfo.getUserEmail();
                }
            }
            if((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || CON_CSM.S_ACTIVITY_R_T == c.RecordTypeName__c || CON_CSM.S_R_D_V_T == c.RecordTypeName__c || c.RecordTypeName__c == CON_CSM.S_RDCASE) && c.First_Date_Resolved__c == null && c.Status == CON_CSM.S_RESOLVED){
                c.First_Date_Resolved__c = System.now();
            }
            if((CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.First_Date_Resolved__c == null) && (c.Status == CON_CSM.S_RESOLVED_WITH_C || (c.Status == CON_CSM.S_AWAITING && c.SubStatus__c == CON_CSM.S_CUSTOMER_CONFIRMATION_CLOSE))){
                c.First_Date_Resolved__c = System.now();
            }
            if(CON_CSM.S_DATACASE == c.RecordTypeName__c && c.First_Date_Resolved__c == null && c.Status == CON_CSM.S_RESOLVED){
                c.First_Date_Resolved__c = System.now();
            }
            if(Trigger.isInsert && c.Status != null && (((CON_CSM.S_RESOLVED == c.Status || CON_CSM.S_RESOLVED_WITH_C == c.Status) && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c || c.RecordTypeName__c == CON_CSM.S_DATACASE)) ||(c.Status == CON_CSM.S_AWAITING && c.SubStatus__c == CON_CSM.S_CUSTOMER_CONFIRMATION_CLOSE && CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c))){
                c.ResolvedDatetime__c = System.now();
                c.DateResolved__c = System.today();
                c.ResolvedBy__c = UserInfo.getUserId();
            }else if(Trigger.isUpdate && c.Status != null && oldMap != null &&  oldMap.get(c.Id)!= null && (c.Status != oldMap.get(c.Id).Status || c.SubStatus__c != oldMap.get(c.Id).SubStatus__c ) && (((CON_CSM.S_RESOLVED == c.Status || CON_CSM.S_RESOLVED_WITH_C == c.Status) && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c || c.RecordTypeName__c == CON_CSM.S_DATACASE)) ||(c.Status == CON_CSM.S_AWAITING && c.SubStatus__c == CON_CSM.S_CUSTOMER_CONFIRMATION_CLOSE && CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c))){
                    c.ResolvedDatetime__c = System.now();
                    c.DateResolved__c = System.today();
                    c.ResolvedBy__c = UserInfo.getUserId();
            }
            if(c.Status != null && CON_CSM.S_CLOSED == c.Status && (Trigger.isInsert || ( Trigger.isUpdate && oldMap != null && oldMap.get(c.Id) != null && c.Status != oldMap.get(c.Id).Status))){
                c.ClosedBy__c = UserInfo.getUserId();
            }
            
            if ((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && (Trigger.isInsert || (oldMap != null && oldMap.get(c.Id) != null && Trigger.isUpdate && (c.Study__c != oldMap.get(c.Id).Study__c || c.Site_Related_to_the_Study__c != oldMap.get(c.Id).Site_Related_to_the_Study__c) )) ) {
                if(c.get(CON_CSM.S_STUDYC) != null ){
                    studySet.add((Id)c.get(CON_CSM.S_STUDYC)); 
                }
                if(c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C) != null){
                    siteContSet.add((Id)c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C)); 
                }
            }
            if(oldMap!=null && CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.AFU_TECH__c != oldMap.get(c.Id).AFU_TECH__c && c.AFU_TECH__c == true ){
                c.Status = CON_CSM.S_AWAITING; 
                c.SubStatus__c = CON_CSM.S_Customer_Info;
            }
            if(oldMap!=null && CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.Status != oldMap.get(c.Id).Status && c.AFU_TECH__c == true && (c.Status == CON_CSM.S_IN_PROGRESS || c.Status == CON_CSM.S_RESOLVED_WITH_C || c.Status == CON_CSM.S_Internal_Solution_Provided) ){
                c.AFU_TECH__c = false;
            }
        }
        if(!studySet.isEmpty()){
            studyMap = new SLT_StudyC().selectByStudyId(studySet,new Set<String>{CON_CSM.S_ID,CON_CSM.S_NAME,CON_CSM.S_LABPROJECTCODE_C,CON_CSM.S_STUDYID_C});
        }
        if(!siteContSet.isEmpty()){
            siteContMap = new SLT_StudySiteContactRelationship().selectByStudySiteContactRelationshipId(siteContSet,new Set<String>{CON_CSM.S_ID,CON_CSM.S_NAME,CON_CSM.S_SITENUM_C,CON_CSM.S_LABSITENUM_C,'Site_Name__c'});
            for(Id studySiteId: siteContMap.keySet()){
                siteAccountMap.put(siteContMap.get(studySiteId).Site_Name__c,studySiteId);
            }
        }
        
        if(siteAccountMap.size() > 0){
            accountList  =  new SLT_Account().selectById( siteAccountMap.keySet());
            if(accountList != null){
                for(Account acc : accountList){
                    accountMap.put(siteAccountMap.get(acc.Id),acc.Name);
                }    
            }
        } 
        
        if(studyMap != null && siteContSet != null && (!studyMap.isEmpty() || !siteContSet.isEmpty())){
            for(Case c : newList) {
                if ((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T)) {
                    if(c.get(CON_CSM.S_STUDYC) != null && studyMap.containsKey((Id)c.get(CON_CSM.S_STUDYC)) ){
                        if(c.ProjectCode__c != studyMap.get(c.Study__c).StudyID__c){
                            c.ProjectCode__c = studyMap.get(c.Study__c).StudyID__c;  
                        }
                        if(c.StudyProtocolName__c != studyMap.get(c.Study__c).Name){
                            c.StudyProtocolName__c = studyMap.get(c.Study__c).Name;  
                        }
                        /* if(c.LabProjectCode__c != studyMap.get(c.Study__c).LabProjectCode__c){
                            c.LabProjectCode__c = studyMap.get(c.Study__c).LabProjectCode__c;  
                        }*/
                    }
                    if(c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C) != null && siteContMap.containsKey((Id)c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C))){
                        if(c.LabSiteNumber__c != siteContMap.get(c.Site_Related_to_the_Study__c).Lab_Site_Number__c){
                            c.LabSiteNumber__c = siteContMap.get(c.Site_Related_to_the_Study__c).Lab_Site_Number__c;  
                        }
                    }
                    if(c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C) != null && accountMap.containsKey((Id)c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C))){
                        if(c.Case_SiteName__c != accountMap.get((Id)c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C))){
                            c.Case_SiteName__c = accountMap.get((Id)c.get(CON_CSM.S_STUDY_SITE_RELATED_TO_STUDY_C));  
                        }
                    }
                    
                }
            }

        }

        if(!sNowPrescriberMap.isEmpty()){
            Map<String,Id> conMap = new Map<String,Id>();
            List<Contact> conList = new SLT_Contact().getContactByEmployeeNumbers(new Set<String>{'Id','EmployeeNumber__c'}, sNowPrescriberMap.values());
            if(conList != null && !conList.isEmpty()){
                for(Contact cn : conList){
                    conMap.put(cn.EmployeeNumber__c, cn.Id);
                }
                for(Case c : newList) {
                    if(conList != null && !conList.isEmpty() && sNowPrescriberMap.containsKey(c.id) && conMap.containsKey(sNowPrescriberMap.get(c.id))){
                        c.ContactId = conMap.get(sNowPrescriberMap.get(c.id));
                    }
                }    
            }
            
        }

    }
    
    /**
    * This method is used for Milestone update when the techno Task Quick action selected
    * @params  newList List<Case>
    * @return  void
    */
    public static void updateCaseTaskQuickAction(List<Case> newList, Map<Id,Case> oldMap) {
        List<Id> caseList = new List<Id>();
        for(Case c : newList){
            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.CaseOriginatorName__c != null && (CON_CSM.S_INITIAL_RES_FAIL == c.CaseOriginatorName__c || CON_CSM.S_RESOLUTION_FAILD == c.CaseOriginatorName__c)){
                caseList.add(c.Id);
            }        
        }
        
        if(!caseList.isEmpty() && !System.isFuture() && !System.isBatch()){
            SRV_CSM_AssignPermissionSet.updateMilestoneVilotaion(caseList);
        }
    }
    
    /**
    * This method is used for create a new Data Audit Trail when the new case record is created.
    * @params  newList List<Case>
    * @return  void
    */
    
    public static void saveAuditLogAfterInsertCase(List<Case> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail=null;
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        if(newList.size()>0)
        {
            for(Case c : newList) {
                if(c.RecordTypeName__c == CON_CSM.S_DATACreateService || c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_DATACASE || c.RecordTypeName__c == CON_CSM.S_DATACASE)
                {
                    auditTrail=new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name=CON_CSM.S_CASE,Case__c = c.Id);
                    auditTrailList.add(auditTrail);
                }
            }
        }
        
        try {
            if(auditTrailList != null && auditTrailList.size() > 0){
                insert auditTrailList;  
            }
        } catch (DmlException e) {
            System.debug('Failed due to : '+e);
        }
        
    }
    /**
    * This method is used for create a new Data Audit Trail when the case record fields are updated to track the History on of the case fields.
    * @params  newList List<Case>,oldMap Map<Id, Case> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateCaseFields(List<Case> newList, Map<Id, Case> oldMap,List<FieldDefinition> fields) {
        
        if(fields != null && fields.size()>0)
        {
            CSM_QI_Data_Audit_Trail__c auditTrail = null;
            List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
            EXT_CSM_CaseRelatedToObject caseRelatedTo = null;
            List<EXT_CSM_CaseRelatedToObject> caseRelatedToList = new List<EXT_CSM_CaseRelatedToObject>(); 
            
            for(Case c : newList) { 
                if(c.RecordTypeName__c == CON_CSM.S_DATACreateService || c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_DATACASE)
                {
                    for( FieldDefinition fd: fields){
                        if(fd.QualifiedApiName.equals(CON_CSM.s_comments)){
                            continue;
                        }
                        
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_URL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PHONE) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_EMAIL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_CHECKBOX) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_BOOLEAN)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_FORMULA) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_TEXT)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Case__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Case__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Case__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_LOOKUP) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                caseRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,fd.RelationshipName,CON_CSM.S_CASE,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),null,c.Id);
                                caseRelatedToList.add(caseRelatedTo);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                caseRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,fd.RelationshipName,CON_CSM.S_CASE,fd.MasterLabel,null,(Id)c.get(fd.QualifiedApiName),c.Id);
                                caseRelatedToList.add(caseRelatedTo);    
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                caseRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,fd.RelationshipName,CON_CSM.S_CASE,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),(Id)c.get(fd.QualifiedApiName),c.Id);
                                caseRelatedToList.add(caseRelatedTo);
                            }
                        }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                            if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),Case__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }
                        
                    }
                }
            }
            
            if(caseRelatedToList.size() > 0)
            {
                Set<Id> accSet = new Set<Id>(),cntSet = new Set<Id>(),usrSet = new Set<Id>(),actSet = new Set<Id>(),studSet = new Set<Id>(),pcsSet = new Set<Id>(),serviceNowSet = new Set<Id>(),queueSet = new Set<Id>(),bHoursSet = new Set<Id>(),entitSet = new Set<Id>(),siteConSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj:caseRelatedToList){
                    if(CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        accSet.add(obj.oldId);
                        accSet.add(obj.newId);
                    }else if(CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        cntSet.add(obj.oldId);
                        cntSet.add(obj.newId);
                    }else if(CON_CSM.S_ACTIVITYC.equals(obj.objRelName)){
                        actSet.add(obj.oldId);
                        actSet.add(obj.newId);
                    }else if(CON_CSM.S_STUDYC.equals(obj.objRelName)){
                        studSet.add(obj.oldId);
                        studSet.add(obj.newId);
                    }else if(CON_CSM.S_CASE.equals(obj.objRelName)){
                        pcsSet.add(obj.oldId);
                        pcsSet.add(obj.newId);
                    }else if(CON_CSM.S_USER.equals(obj.objRelName)){
                        usrSet.add(obj.oldId);
                        usrSet.add(obj.newId);
                    }else if(CON_CSM.S_SERVICENOW_GROUP_C.equals(obj.objRelName)){
                        serviceNowSet.add(obj.oldId);
                        serviceNowSet.add(obj.newId);
                    }else if(CON_CSM.S_QUSERRELC.equals(obj.objRelName)){
                        queueSet.add(obj.oldId);
                        queueSet.add(obj.newId);
                    }else if(CON_CSM.S_BHOUR.equals(obj.objRelName)){
                        bHoursSet.add(obj.oldId);
                        bHoursSet.add(obj.newId);
                    }else if(CON_CSM.S_ENTITLEMENT.equals(obj.objRelName)){
                        entitSet.add(obj.oldId);
                        entitSet.add(obj.newId);
                    }else if(CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP.equals(obj.objRelName)){
                        siteConSet.add(obj.oldId);
                        siteConSet.add(obj.newId);
                    }
                }
                Set<String> fieldSet  =  new Set<String> {CON_CSM.S_ID, CON_CSM.S_NAME};
                Map<Id, Account> accountMap  = null;
                Map<Id, Contact> contactMap  = null;
                Map<Id, Activity__c> activityMap = null;
                Map<Id, Study__c> studyMap = null;
                Map<Id, Case> parentCaseMap = null;
                Map<Id, User> usrMap = null;
                Map<Id, ServiceNow_Group__c> serviceNowMap = null;
                Map<Id, Queue_User_Relationship__c> queueMap = null;
                Map<Id, BusinessHours> bHoursMap = null;
                Map<Id, Entitlement> entitMap = null;
                Map<Id, StudySiteContactRelationship__c> siteConMap = null;
                if(accSet.size() > 0){
                    accountMap  =  new SLT_Account().selectByAccountId(accSet, fieldSet);
                }
                if(cntSet.size() > 0){
                    contactMap  =  new SLT_Contact().selectByContactId(cntSet, fieldSet);
                }
                if(actSet.size() > 0){
                    activityMap  =  new SLT_ActivityC().selectByActivityId(actSet, fieldSet);
                }
                if(studSet.size() > 0){
                    studyMap  =  new SLT_StudyC().selectByStudyId(studSet, fieldSet);
                }
                if(pcsSet.size() > 0){
                    parentCaseMap  =  new SLT_Case().selectByCaseId(pcsSet, new Set<String>{CON_CSM.S_ID,CON_CSM.S_CASENUM});
                }
                if(usrSet.size() > 0){
                    usrMap  =  new SLT_User().selectByUserId(usrSet, fieldSet);
                }
                if(serviceNowSet.size() > 0){
                    serviceNowMap  =  new SLT_ServiceNowGroupC().selectByServiceNowId(serviceNowSet, fieldSet);
                }
                if(queueSet.size() > 0){
                    queueMap  =  new SLT_QueueUserRelationshipC().selectByQueueId(queueSet, fieldSet);
                }
                if(bHoursSet.size() > 0){
                    bHoursMap  =  new SLT_BusinessHours().selectByBusinessHoursId(bHoursSet, fieldSet);
                }
                if(entitSet.size() > 0){
                    entitMap  =  new SLT_Entitlement().selectByEntitlementId(entitSet, fieldSet);
                }
                if(siteConSet.size() > 0){
                    siteConMap  =  new SLT_StudySiteContactRelationship().selectByStudySiteContactRelationshipId(siteConSet, fieldSet);
                }

                for(EXT_CSM_CaseRelatedToObject obj : caseRelatedToList){
                    
                    if(accountMap != null && accountMap.size() > 0 && CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = accountMap.containsKey(obj.oldId) ? accountMap.get(obj.oldId).Name : '',New_Value__c = accountMap.containsKey(obj.newId) ? accountMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(contactMap != null && contactMap.size() > 0 && CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = contactMap.containsKey(obj.oldId) ? contactMap.get(obj.oldId).Name : '',New_Value__c = contactMap.containsKey(obj.newId) ? contactMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(activityMap != null && activityMap.size() > 0 && CON_CSM.S_ACTIVITYC.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = activityMap.containsKey(obj.oldId) ? activityMap.get(obj.oldId).Name : '',New_Value__c = activityMap.containsKey(obj.newId) ? activityMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(studyMap != null && studyMap.size() > 0 && CON_CSM.S_STUDYC.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = studyMap.containsKey(obj.oldId) ? studyMap.get(obj.oldId).Name : '',New_Value__c = studyMap.containsKey(obj.newId) ? studyMap.get(obj.newId).Name : '', Study__c = obj.oldId);
                        auditTrailList.add(auditTrail);
                    }else if(parentCaseMap != null && parentCaseMap.size() > 0 && CON_CSM.S_CASE.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = parentCaseMap.containsKey(obj.oldId) ? parentCaseMap.get(obj.oldId).CaseNumber :'',New_Value__c = parentCaseMap.containsKey(obj.newId) ? parentCaseMap.get(obj.newId).CaseNumber : ''); 
                        auditTrailList.add(auditTrail);
                    }else if(usrMap != null && usrMap.size() > 0 && CON_CSM.S_USER.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = usrMap.containsKey(obj.oldId) ? usrMap.get(obj.oldId).Name : '',New_Value__c = usrMap.containsKey(obj.newId) ? usrMap.get(obj.newId).Name : ''); 
                        auditTrailList.add(auditTrail);
                    }else if(serviceNowMap != null && serviceNowMap.size() > 0 && CON_CSM.S_SERVICENOW_GROUP_C.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = serviceNowMap.containsKey(obj.oldId)?serviceNowMap.get(obj.oldId).Name :'',New_Value__c = serviceNowMap.containsKey(obj.newId) ? serviceNowMap.get(obj.newId).Name : ''); 
                        auditTrailList.add(auditTrail);
                    }else if(queueMap != null && queueMap.size() > 0 && CON_CSM.S_QUSERRELC.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = queueMap.containsKey(obj.oldId)?queueMap.get(obj.oldId).Name :'',New_Value__c = queueMap.containsKey(obj.newId) ? queueMap.get(obj.newId).Name : ''); 
                        auditTrailList.add(auditTrail);
                    }else if(bHoursMap != null && bHoursMap.size() > 0 && CON_CSM.S_BHOUR.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = bHoursMap.containsKey(obj.oldId) ? bHoursMap.get(obj.oldId).Name : '',New_Value__c = bHoursMap.containsKey(obj.newId) ? bHoursMap.get(obj.newId).Name : ''); 
                        auditTrailList.add(auditTrail);
                    }else if(entitMap != null && entitMap.size() > 0 && CON_CSM.S_ENTITLEMENT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = entitMap.containsKey(obj.oldId) ? entitMap.get(obj.oldId).Name : '',New_Value__c = entitMap.containsKey(obj.newId) ? entitMap.get(obj.newId).Name : ''); 
                        auditTrailList.add(auditTrail);
                    }else if(siteConMap != null && siteConMap.size() > 0 && CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Case__c  =  obj.objectId,Old_Value__c = siteConMap.containsKey(obj.oldId) ? siteConMap.get(obj.oldId).Name : '',New_Value__c = siteConMap.containsKey(obj.newId) ? siteConMap.get(obj.newId).Name : ''); 
                        auditTrailList.add(auditTrail);
                    }
                    
                }
            }
            
            try {
                if(auditTrailList != null && auditTrailList.size() > 0){
                    insert auditTrailList;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
        
    }
    
    /**
    * This method is used for selecting the Current queue based on the Case owner field when case is creating
    * @params  newList List<Case>
    * @return  void
    */
    public static void AP_Case(List<Case> newList,Set<Id> profileSet) {
        Map<Id,String> addOId = new Map<Id,String>();
        Set<Id> caseCurrentSet = new Set<Id>();
        Map<Id,Queue_User_Relationship__c> caseQueue = new Map<Id,Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> grpQueue = new List<Queue_User_Relationship__c>();
        String selectTask = '';
        String currentQueueNamee ='';
        for(Case c : newList) {
            if(c.isClone()){
                c.Case_ThreadToken__c = null;
                c.SlaStartDate = null;
                c.Service_Now_Incident_Number__c = null;
                if(c.IsEscalated){
                    c.IsEscalated = false;
                    c.First_Escalated_By__c = Null;
                }
                if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c){
                    //c.CurrentQueue__c = null;
                    c.InitialQueue__c = null;
                    c.PreviousQueue__c = null;
                    c.BusinessElapsedTime__c = 0;
                }
            }
            if(c.CurrentQueue__c == null){
                addOId.put(c.OwnerId,(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c) ? 'Technology Solutions':(CON_CSM.S_DATACASE == c.RecordTypeName__c) ? 'Information Offering' :(c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE|| c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T)? 'R&D' : '');    
            }else if(c.CurrentQueue__c != null){
                caseCurrentSet.add(c.CurrentQueue__c);
            }
            c.CaseOwnerModifiedDate__c = System.now(); 
            c.CaseUpdatedTime__c = System.now();
        }
        boolean checkUser = false;
        Queue_User_Relationship__c defaultQ;
        if(caseCurrentSet.isEmpty() == false){
            Map<Id,Queue_User_Relationship__c> currentQueueMap = new SLT_QueueUserRelationshipC().selectByQueueId(caseCurrentSet, new Set<String>{CON_CSM.S_ID, CON_CSM.S_NAME, CON_CSM.S_GROUP_ID,'LOS__c','Tier__c','AccountId__c','User__c','IsDefaultQueue__c'});
            Map<Id,Queue_User_Relationship__c> userQueueList = new SLT_QueueUserRelationshipC().selectBasedOnQueueId(caseCurrentSet);
            for(Queue_User_Relationship__c q : userQueueList.values()){
                if(q.Type__c == 'User' && q.User__c == UserInfo.getUserId()){
                    if(q.IsDefaultQueue__c){
                        defaultQ = q;
                    }
                    checkUser = true;
                }
            }

            for (Case c : newList) {
                selectTask = '';
                currentQueueNamee = '';
                if(defaultQ != null && defaultQ.TECH_QueueUser__c != null){
                    c.InitialQueue__c = defaultQ.Name;
                    c.CurrentQueue__c = defaultQ.TECH_QueueUser__c;
                    c.InitialQueueData__c = defaultQ.TECH_QueueUser__c;
                }
                if(((!checkUser && c.isClone()) || (hasCustomPermission == false && userQueueList.size() == 0)) && !(c.G_Inquiry_Investigation__c != null && CON_CSM.G_INQUIRY == (c.G_Inquiry_Investigation__c)) && c.CRC_Issue_Insert_Date_time__c == null) {
                    c.adderror(label.SelectQueue);
                }else if(userQueueList.size() >= 1) {
                    if (c.InitialQueue__c == Null) {
                        c.InitialQueue__c = currentQueueMap.get(c.CurrentQueue__c).Name;
                    }
                    if (c.AccountId == null && currentQueueMap != null && currentQueueMap.containsKey(c.CurrentQueue__c) && currentQueueMap.get(c.CurrentQueue__c).AccountId__c != null) {
                        c.AccountId = currentQueueMap.get(c.CurrentQueue__c).AccountId__c;
                    }
                    if(CON_CSM.S_EMAIL == c.Origin && UserInfo.getName() == 'System' && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE|| c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && c.CurrentQueue__c != null && userQueueList.get(c.CurrentQueue__c) != null && userQueueList.get(c.CurrentQueue__c).Los__c != null){
                        c.Los__c = userQueueList.get(c.CurrentQueue__c).Los__c;
                    }
                    if(currentQueueMap != null && userQueueList != null && currentQueueMap.containsKey(c.CurrentQueue__c) && currentQueueMap.get(c.CurrentQueue__c).Group_Id__c != null && userQueueList.containsKey(currentQueueMap.get(c.CurrentQueue__c).Group_Id__c) && userQueueList.get(currentQueueMap.get(c.CurrentQueue__c).Group_Id__c).Tier__c != null){
                        c.SupportTier__c =  userQueueList.get(currentQueueMap.get(c.CurrentQueue__c).Group_Id__c).Tier__c;
                    }
                    c.CurrentQueue__c = userQueueList.get(currentQueueMap.get(c.CurrentQueue__c).Group_Id__c).Id;                        

                    if((c.RecordTypeName__c == CON_CSM.S_DATACASE || CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c) && c.CurrentQueue__c != null){
                        c.InitialQueueData__c = c.CurrentQueue__c;
                    }
                    if(CON_CSM.S_TECHNOLOGY_R_T == (c.RecordTypeName__c) && c.CurrentQueue__c != null && userQueueList.get(c.CurrentQueue__c) != null && userQueueList.get(c.CurrentQueue__c).Name != null){ 
                        if(userQueueList.get(c.CurrentQueue__c).Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                            if(c.TaskMilestone__c == null){
                                c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                            }else if(c.TaskMilestone__c != null){
                                c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                            }
                        }
                        currentQueueNamee = userQueueList.get(c.CurrentQueue__c).Name;
                        selectTask = SanofiTaskMilestone(userQueueList.get(c.CurrentQueue__c).Name);
                    }
                }
                if(c.TaskMilestone__c != null && !c.TaskMilestone__c.containsIgnoreCase(selectTask)){
                    c.TaskMilestone__c += ';' + selectTask;
                }else if(c.TaskMilestone__c == null){
                    c.TaskMilestone__c = selectTask; 
                }
                if(currentQueueNamee == CON_CSM.S_TECH_GPSQ && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_TECH_GPSQ)){
                    if(c.TaskMilestone__c == null){
                        c.TaskMilestone__c = CON_CSM.S_TECH_GPSQ;
                    }else if(c.TaskMilestone__c != null){
                        c.TaskMilestone__c += ';' + CON_CSM.S_TECH_GPSQ;
                    }                    
                }
            }
        }else if(addOId.isEmpty() == false){
            Set<Id> key = addOId.keySet();
            Map<Id,Queue_User_Relationship__c> defaultQueueMap = new Map<Id,Queue_User_Relationship__c>();
            List<User> pUser = [select Id from User where (Id In: key and ProfileId In: profileSet) or (Name = 'System' and Id In: key)];
            List<Queue_User_Relationship__c> userGroupList = new SLT_QueueUserRelationshipC().selectBasedOnUserGroup(key);
            String initialQueue = null;
            if(userGroupList.isEmpty() == False){
                for(Queue_User_Relationship__c qu : userGroupList){
                    if(CON_CSM.S_USER == qu.Type__c){
                        caseQueue.put(qu.User__c,qu);
                        if(addOId.containsKey(qu.User__c) && addOId.get(qu.User__c) == qu.Pillar__c && qu.IsDefaultQueue__c){
                            defaultQueueMap.put(qu.User__c,qu);
                        }
                    }else if(CON_CSM.S_QUEUE == qu.Type__c){
                        grpQueue.add(qu);
                    }
                }
                for (Case c : newList) { 
                    selectTask = '';
                    if(string.valueOf(c.OwnerId).startsWith(CON_CSM.S_QUEUE_ID)) {
                        c.CurrentQueue__c = grpQueue[0].Id;
                        if(grpQueue[0].Tier__c != null){
                            c.SupportTier__c = grpQueue[0].Tier__c;
                        }
                        c.InitialQueueData__c = grpQueue[0].Id;
                        if (c.InitialQueue__c == Null) {
                            c.InitialQueue__c = grpQueue[0].Name;
                        }
                        if(CON_CSM.S_EMAIL == c.Origin && UserInfo.getName() == 'System' && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE|| c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && grpQueue[0].Los__c != null){
                            c.Los__c = grpQueue[0].Los__c;
                        }
                        if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.CurrentQueue__c != null && grpQueue[0].Name != null){
                            if(grpQueue[0].Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                                if(c.TaskMilestone__c == null){
                                    c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                                }else if(c.TaskMilestone__c != null){
                                    c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                                }
                            }
                            currentQueueNamee = grpQueue[0].Name;
                            selectTask = SanofiTaskMilestone(grpQueue[0].Name);
                        }
                        if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Origin == CON_CSM.S_EMAIL && c.InitialQueue__c == (CON_CSM.S_TECH_UK_NHS_SERVICE_DESK_T1) && UserInfo.getName() == CON_CSM.S_SYSTEM){
                            c.Device__c = 'Others';
                        }
                        if (c.AccountId == null && grpQueue[0].AccountId__c != null) {
                            c.AccountId = grpQueue[0].AccountId__c;
                        }
                    }else if(string.valueOf(c.OwnerId).startsWith(CON_CSM.S_USER_ID) && pUser.size() == 0) {
                        if(hasCustomPermission == false && grpQueue.size() == 0 && c.CurrentQueue__c == null && !(c.G_Inquiry_Investigation__c != null && CON_CSM.G_INQUIRY == (c.G_Inquiry_Investigation__c))) {
                            c.adderror(label.SelectQueue);
                        }else if(grpQueue.size() == 1 && c.CurrentQueue__c == null) {
                            c.CurrentQueue__c = grpQueue[0].Id;
                            if(grpQueue[0].Tier__c != null){
                                c.SupportTier__c =  grpQueue[0].Tier__c;
                            }
                            c.InitialQueueData__c = grpQueue[0].Id;
                            if (c.InitialQueue__c == Null) {
                                c.InitialQueue__c = grpQueue[0].Name;
                            }
                        }else if(grpQueue.size() > 1 && c.CurrentQueue__c == null) {
                            if(defaultQueueMap.containsKey(c.OwnerId)){
                                c.CurrentQueue__c = defaultQueueMap.get(c.OwnerId).TECH_QueueUser__c;
                                if(defaultQueueMap.containsKey(c.OwnerId) && defaultQueueMap.get(c.OwnerId).Tier__c != null){
                                    c.SupportTier__c = defaultQueueMap.get(c.OwnerId).Tier__c;
                                }
                                c.InitialQueueData__c = defaultQueueMap.get(c.OwnerId).TECH_QueueUser__c;
                                if (c.InitialQueue__c == Null) {
                                    c.InitialQueue__c = defaultQueueMap.get(c.OwnerId).Name;
                                }
                                if (c.AccountId == null && grpQueue[0].AccountId__c != null) {
                                    c.AccountId = defaultQueueMap.get(c.OwnerId).AccountId__c;
                                }
                            }else if(((CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.isClone()) || CON_CSM.S_DATACASE == c.RecordTypeName__c)){
                                c.CurrentQueue__c = grpQueue[0].Id;
                                if(grpQueue[0].Tier__c != null){
                                    c.SupportTier__c =grpQueue[0].Tier__c;
                                }
                                c.InitialQueueData__c = grpQueue[0].Id;
                                if (c.InitialQueue__c == Null) {
                                    c.InitialQueue__c = grpQueue[0].Name;
                                }
                            } else if(hasCustomPermission == false && grpQueue.size() > 1 && (c.RecordTypeName__c == CON_CSM.S_DataCreateService_R_T  || c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T) && c.CurrentQueue__c == null){
                                c.adderror(label.QueueListErrorMSG);
                            }
                        }
                        
                        if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.CurrentQueue__c != null && c.InitialQueue__c != null){ 
                            if(c.InitialQueue__c.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                                if(c.TaskMilestone__c == null){
                                    c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                                }else if(c.TaskMilestone__c != null){
                                    c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                                }
                            }
                            currentQueueNamee = grpQueue[0].Name;
                            selectTask = SanofiTaskMilestone(grpQueue[0].Name);
                        }
                        if (c.AccountId == null && grpQueue[0].AccountId__c != null) {
                            c.AccountId = grpQueue[0].AccountId__c;
                        }
                    }
                    if(c.TaskMilestone__c != null && !c.TaskMilestone__c.containsIgnoreCase(selectTask)){
                        c.TaskMilestone__c += ';' + selectTask;
                    }else if(c.TaskMilestone__c == null){
                        c.TaskMilestone__c = selectTask; 
                    }
                    if(currentQueueNamee == CON_CSM.S_TECH_GPSQ && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_TECH_GPSQ)){
                        if(c.TaskMilestone__c == null){
                            c.TaskMilestone__c = CON_CSM.S_TECH_GPSQ;
                        }else if(c.TaskMilestone__c != null){
                            c.TaskMilestone__c += ';' + CON_CSM.S_TECH_GPSQ;
                        }                    
                    }
                    initialQueue = c.InitialQueue__c;
                }    
            }else{
                for (Case c : newList) {
                    /* Bypass the Case owner not in any queue error for G Inquiry interface, CSH and Email to Case */
                    if((c.G_Inquiry_Investigation__c != null && CON_CSM.G_INQUIRY.equalsIgnoreCase(c.G_Inquiry_Investigation__c)) || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || (c.SuppliedEmail == null && c.CreatedById == CON_CSM.S_SYSTEM_USERID) || c.SuppliedEmail != null || c.CRC_Issue_Insert_Date_time__c != null){
                        
                    }else if(hasCustomPermission == false){
                        c.adderror(label.SelectQueue);
                    }
                }
            }
            if(initialQueue != null){
                assignUserToCaseByRoundRobin(newList,initialQueue);
            }
        }
        /*for (Case c : newList) {
            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.InitialQueue__c != Null){
                c.SupportTier__c = (c.InitialQueue__c.containsIgnoreCase('T1') ? 'Tier 1': c.InitialQueue__c.containsIgnoreCase('T2') ? 'Tier 2':c.InitialQueue__c.containsIgnoreCase('T3') ? 'Tier 3':c.InitialQueue__c.containsIgnoreCase('T4') ? 'Tier 4' :'');  
            }
        }*/
    }
    
    /**
    * This method is used for update the Curren queue based on selection of Case owner or Current queue.
    * @params  newList List<Case> 
    * @return  void
    */
    
    public static void AP_Case01(List<Case> uptList,Map<Id,Case> oldMap,Set<Id> profileSet){
        Set<Id> caseIds = new Set<Id>();
        Set<Id> uptOId = new Set<Id>();
        Set<Id> currId = new Set<Id>();
        Set<Id> initialQueue = new Set<Id>();
        Set<string> queueNameSet = new set<string>();
        Map<Id, Id> getcurrName = new Map<Id, Id>();
        List<Queue_User_Relationship__c> caseUptQueue = new List<Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> grpUptQueue = new List<Queue_User_Relationship__c>();
        boolean isTimeforDataCreate = false;
        for (Case uptCase : uptList) {
            if(uptCase.CurrentQueue__c == null && oldMap.get(uptCase.Id).CurrentQueue__c != null && uptCase.CurrentQueue__c != oldMap.get(uptCase.Id).CurrentQueue__c){
                uptCase.CurrentQueue__c = oldMap.get(uptCase.Id).CurrentQueue__c;
            }
            if(uptCase.AssignCaseToCurrentUser__c == true && uptCase.Owner__c == UserInfo.getUserId() && uptCase.OwnerId == UserInfo.getUserId()){
                uptCase.AssignCaseToCurrentUser__c = false;
                uptCase.Owner__c = null;
            }
            if(uptCase.RecordTypeName__c == CON_CSM.S_DATACreateService && (uptCase.OwnerId != oldMap.get(uptCase.Id).OwnerId || (uptCase.Status != oldMap.get(uptCase.Id).Status && uptCase.Status == CON_CSM.S_CLOSED)) && UserInfo.getUserId() != uptCase.OwnerId && uptCase.getQuickActionName() != 'Case.Take_Ownership_Component'){
                isTimeforDataCreate = true;
                caseIds.add(uptCase.Id);
            }
            if(CON_CSM.S_WEB.equals(uptCase.Origin) && uptCase.HCRSWebID__c != null && (uptCase.HCRSWebID__c.startsWith(CON_CSM.S_ORGANIZATIONS) || uptCase.HCRSWebID__c.startsWith(CON_CSM.S_PROFESSIONALS)) ){
                String[] onekeyIds = uptCase.HCRSWebID__c.split('~');
                if(!onekeyIds.isEmpty() && onekeyIds.size() > 1){
                    uptCase.HCRSWebID__c = onekeyIds[1];    
                }else{
                    uptCase.HCRSWebID__c = null;
                }
            }else if(uptCase.AssignCaseToCurrentUser__c == true && !(uptCase.getQuickActionName() == 'Case.Macros_Only' || uptCase.getQuickActionName() == 'Case.Macro_Fields' || uptCase.getQuickActionName() == 'Case.R_D_Macros_Only' || uptCase.getQuickActionName() == 'Case.R_D_AR_Macros_Only')) {
                uptCase.AssignCaseToCurrentUser__c = false;
                uptCase.CaseOwnerModifiedDate__c = System.now();
                uptCase.CaseUpdatedTime__c = System.now();
            }else if(uptCase.OwnerId != null && (uptCase.OwnerId != oldMap.get(uptCase.Id).OwnerId || uptCase.CurrentQueue__c != oldMap.get(uptCase.Id).CurrentQueue__c)){
                uptOId.add(uptCase.OwnerId);
                if(uptCase.CurrentQueue__c != null){
                    currId.add(uptCase.CurrentQueue__c);    
                }
            }else if(uptCase.InitialQueueData__c != null && uptCase.InitialQueueData__c != oldMap.get(uptCase.Id).InitialQueueData__c){
                initialQueue.add(uptCase.InitialQueueData__c);
            }
        }
        if(initialQueue.IsEmpty() == false){
            List<Queue_User_Relationship__c> q = new SLT_QueueUserRelationshipC().selectByQueueIdSet(initialQueue, new Set<String>{'Id','Name'});
            for(Case c : uptList) {  
                c.InitialQueue__c = q[0].Name;
            }
        }
        if(isTimeforDataCreate && !caseIds.isEmpty()){
            String userId = UserInfo.getUserId();
            boolean isError = false;
            List<TimeSheet__c> tsList = Database.query('select Id,CreatedDate,Time_Type__c,Timeinhours__c from TimeSheet__c WHERE Case__c in :caseIds AND Type__c =\'Manual\' AND Status__c = \'stop\' AND CreatedById =:userId ORDER BY CreatedDate DESC LIMIT 1');
            if(tsList != null && !tsList.isEmpty()){
                for(TimeSheet__c ts : tsList){
                    Long minutes = (System.now().getTime() - ts.CreatedDate.getTime()) / 60000;
                    if(minutes > 3){
                        isError = true;
                        break;
                    }else if(ts.Timeinhours__c < 0.01 || ts.Time_Type__c == null){
                        isError = true;
                        break;
                    }
                }
            }else{
                isError = true;
            }

            if(!hasCustomPermission && isError){
                String msg = 'Please add your Time (in Minutes) and Time Type in the Time Sheet component';
                for(Case c : uptList) {
                    if(c.Status == CON_CSM.S_CLOSED){
                        c.addError(msg+' before assign the case to User');
                    }else{
                       c.addError(msg+' before closing the case'); 
                    }
                }   
            }
        }
        if(uptOId.isEmpty() == false){
            List<User> pUser = [select Id from User where (Id In: uptOId and ProfileId In: profileSet) or (Name = 'System' and Id In: uptOId)];
            List<Queue_User_Relationship__c> userGroupList = new SLT_QueueUserRelationshipC().selectByUserGrop(uptOId);
            if(userGroupList.isEmpty() == False){
                for(Queue_User_Relationship__c qu : userGroupList){
                    if(CON_CSM.S_USER.equalsIgnoreCase(qu.Type__c)){
                        caseUptQueue.add(qu);  
                    }else if(CON_CSM.S_QUEUE.equalsIgnoreCase(qu.Type__c)){
                        grpUptQueue.add(qu);
                    }
                }
            }
            for (Queue_User_Relationship__c q : new SLT_QueueUserRelationshipC().selectByQueueIdSet(currId, new Set<String>{'Id','Name'})) {
                queueNameSet.add(q.Name);
            }
            // look  for user queue  
            for (Queue_User_Relationship__c getNameCurr : new SLT_QueueUserRelationshipC().selectByUserQueueName(uptOId,queueNameSet)) {
                if(getNameCurr.TECH_QueueUser__c != null){
                    getcurrName.put(getNameCurr.Id, getNameCurr.TECH_QueueUser__c);
                }else{
                    getcurrName.put(getNameCurr.Id, getNameCurr.Id);
                }
            }
            String selectTask;
            String currentQueueNamee;
            for(Case c : uptList) {
                selectTask='';
                currentQueueNamee = '';
                if(string.valueOf(c.OwnerId).startsWith(CON_CSM.S_QUEUE_ID)) {
                    if(grpUptQueue.size()>0) {
                        c.CurrentQueue__c = grpUptQueue[0].Id;
                        if(grpUptQueue[0].Tier__c != null){
                            c.SupportTier__c =  grpUptQueue[0].Tier__c;
                        }
                        if(c.InitialQueueData__c == null){
                            c.InitialQueueData__c = grpUptQueue[0].Id;
                        }
                        if (c.InitialQueue__c == Null) {
                            c.InitialQueue__c = grpUptQueue[0].Name;
                        }
                        if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && grpUptQueue[0].Name != null){
                            if(grpUptQueue[0].Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                                if(c.TaskMilestone__c == null){
                                    c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                                }else if(c.TaskMilestone__c != null){
                                    c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                                }
                            }
                            selectTask = SanofiTaskMilestone(grpUptQueue[0].Name);
                            //c.SupportTier__c = (selectTask.containsIgnoreCase('T1') ? 'Tier 1': selectTask.containsIgnoreCase('T2') ? 'Tier 2':selectTask.containsIgnoreCase('T3') ? 'Tier 3':selectTask.containsIgnoreCase('T4') ? 'Tier 4' :'');
                        }
                    }
                }
                
                if(string.valueOf(c.OwnerId).startsWith(CON_CSM.S_USER_ID) && pUser.size() == 0) {
                    if(hasCustomPermission == false && caseUptQueue.size() == 0 && !(c.G_Inquiry_Investigation__c != null && CON_CSM.G_INQUIRY.equalsIgnoreCase(c.G_Inquiry_Investigation__c))) {
                        c.adderror(label.SelectQueue);
                    }
                    if(caseUptQueue.size() == 1) {
                        c.CurrentQueue__c = caseUptQueue[0].TECH_QueueUser__c ;
                        if(caseUptQueue[0].Tier__c != null){
                            c.SupportTier__c = caseUptQueue[0].Tier__c;
                        }
                        if(c.InitialQueueData__c == null){
                            c.InitialQueueData__c = caseUptQueue[0].TECH_QueueUser__c;
                        }
                        if (c.InitialQueue__c == Null) {
                            c.InitialQueue__c = caseUptQueue[0].Name;
                        }
                        if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.CurrentQueue__c != null && caseUptQueue.size() > 0 && caseUptQueue[0].Name != null){ 
                            if(caseUptQueue[0].Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                                if(c.TaskMilestone__c == null){
                                    c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                                }else if(c.TaskMilestone__c != null){
                                    c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                                }
                            }
                            currentQueueNamee = caseUptQueue[0].Name;
                            selectTask = SanofiTaskMilestone(caseUptQueue[0].Name);
                            //c.SupportTier__c = (selectTask.containsIgnoreCase('T1') ? 'Tier 1': selectTask.containsIgnoreCase('T2') ? 'Tier 2':selectTask.containsIgnoreCase('T3') ? 'Tier 3':selectTask.containsIgnoreCase('T4') ? 'Tier 4' :'');
                        }
                    }
                    
                    if(hasCustomPermission == false && caseUptQueue.size() > 1 && c.CurrentQueue__c == null && UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) == false && !(c.Status == CON_CSM.S_NEW && c.G_Inquiry_Investigation__c != null && CON_CSM.G_INQUIRY.equalsIgnoreCase(c.G_Inquiry_Investigation__c))) {
                        c.adderror(label.QueueListErrorMSG);
                    }
                    
                    if(caseUptQueue.size() > 1 && c.CurrentQueue__c != null) {
                        if(getcurrName.size() == 0) {
                            if(c.AssignCaseToCurrentUser__c == true) {
                                c.CurrentQueue__c = caseUptQueue[0].TECH_QueueUser__c;
                                if(caseUptQueue[0].Tier__c != null){
                                    c.SupportTier__c =  caseUptQueue[0].Tier__c;
                                }
                                if(c.InitialQueueData__c == null){
                                    c.InitialQueueData__c = caseUptQueue[0].TECH_QueueUser__c;
                                }
                                if (c.InitialQueue__c == Null) {
                                    c.InitialQueue__c = caseUptQueue[0].Name;
                                }
                                if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.CurrentQueue__c != null && caseUptQueue.size() > 0 && caseUptQueue[0].Name != null){ 
                                    if(caseUptQueue[0].Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                                        if(c.TaskMilestone__c == null){
                                            c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                                        }else if(c.TaskMilestone__c != null){
                                            c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                                        }
                                    }
                                    selectTask = SanofiTaskMilestone(caseUptQueue[0].Name);
                                    currentQueueNamee = caseUptQueue[0].Name;
                                }
                            } else if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) == false && !(c.Status == CON_CSM.S_NEW && c.G_Inquiry_Investigation__c != null && CON_CSM.G_INQUIRY.equalsIgnoreCase(c.G_Inquiry_Investigation__c))){
                                c.CurrentQueue__c = caseUptQueue[0].TECH_QueueUser__c;
                                if(caseUptQueue[0].Tier__c != null){
                                    c.SupportTier__c =  caseUptQueue[0].Tier__c;
                                }
                            }    
                        } else {
                            for (string nameKey : getcurrName.keySet()) {
                                if(getcurrName.containsKey(nameKey)) {
                                    c.CurrentQueue__c = getcurrName.get(nameKey);
                                    if(c.InitialQueueData__c == null){
                                        c.InitialQueueData__c = getcurrName.get(nameKey);
                                    }
                                    if (c.InitialQueue__c == Null) {
                                        string addQueueNameSet = string.valueOf(queueNameSet);
                                        addQueueNameSet = addQueueNameSet.replaceAll('[{}]', '');
                                        c.InitialQueue__c = string.valueOf(addQueueNameSet);
                                    }
                                    if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && c.CurrentQueue__c != null && caseUptQueue.size() > 0 && caseUptQueue[0].Name != null){ 
                                        if(caseUptQueue[0].Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                                            if(c.TaskMilestone__c == null){
                                                c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                                            }else if(c.TaskMilestone__c != null){
                                                c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                                            }
                                        }
                                        currentQueueNamee = caseUptQueue[0].Name;
                                        selectTask = SanofiTaskMilestone(caseUptQueue[0].Name);
                                        //c.SupportTier__c = (selectTask.containsIgnoreCase('T1') ? 'Tier 1': selectTask.containsIgnoreCase('T2') ? 'Tier 2':selectTask.containsIgnoreCase('T3') ? 'Tier 3':selectTask.containsIgnoreCase('T4') ? 'Tier 4' :'');
                                    }
                                }
                                
                            }
                        }
                    }
                }
                c.CaseOwnerModifiedDate__c = System.now();
                c.CaseUpdatedTime__c = System.now();
                if(c.TaskMilestone__c != null && !c.TaskMilestone__c.containsIgnoreCase(selectTask)){
                    c.TaskMilestone__c += ';' + selectTask;
                }else if(c.TaskMilestone__c == null){
                    c.TaskMilestone__c = selectTask; 
                }
                if(currentQueueNamee == CON_CSM.S_TECH_GPSQ){
                    if(c.TaskMilestone__c == null){
                        c.TaskMilestone__c = CON_CSM.S_TECH_GPSQ;
                    }else if(c.TaskMilestone__c != null && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_TECH_GPSQ)){
                        c.TaskMilestone__c += ';' + CON_CSM.S_TECH_GPSQ;
                    }                    
                }
            }
        }
        set<String> initialQueueIds = new Set<String>();
        for(Case caseRecord : uptList){
            if((Trigger.isUpdate && caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T) && (caseRecord.Status == CON_CSM.S_RESOLVED_WITH_C && caseRecord.SubStatus__c != CON_CSM.S_RCA && caseRecord.SubStatus__c != CON_CSM.S_PRC)){
                caseRecord.SubStatus__c = Null;
            }
            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && caseRecord.FCR_Review_Escalation__c != 'Essential Escalation'){
                initialQueueIds.add(caseRecord.InitialQueue__c); 
            }
            if(caseRecord.Status == CON_CSM.S_NEW && caseRecord.OOO_FLag__c){
                List<Queue_User_Relationship__c> currentQueueList = new SLT_QueueUserRelationshipC().selectByQueueName(new Set<String>{CON_CSM.S_Queue_E2C_OOO});
                if(currentQueueList != null && !currentQueueList.isEmpty()){
                    caseRecord.CurrentQueue__c = currentQueueList[0].Id;
                    if(currentQueueList[0].Tier__c != null){
                        caseRecord.SupportTier__c = currentQueueList[0].Tier__c;
                    }
                    caseRecord.OwnerId = currentQueueList[0].Group_Id__c;
                    caseRecord.OOO_FLag__c = FALSE;
                }
            }
        }
        
        Map<String, Queue_User_Relationship__c> queueNameVsQueueUser = new Map<String, Queue_User_Relationship__c>();
        if(!initialQueueIds.isEmpty()){
            for(Queue_User_Relationship__c relation: [SELECT id,Name, Tier__c,Pillar__c  FROM Queue_User_Relationship__c WHERE Name in :initialQueueIds AND Tier__c = 'Tier 1' AND Pillar__c ='Technology Solutions']){
                queueNameVsQueueUser.put(relation.Name, relation);
            }
        }
        for(Case c: uptList){
            if(c.InitialQueue__c != null){
                if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.InitialQueue__c != null && c.PreviousQueue__c!=null && c.Current_Queue_Name__c != null && oldMap != null && oldMap.get(c.Id) != null
                   && (c.InitialQueue__c.contains('T1') || (queueNameVsQueueUser != null && queueNameVsQueueUser.size()>0 && queueNameVsQueueUser.containsKey(c.InitialQueue__c) && queueNameVsQueueUser.get(c.InitialQueue__c).Tier__c == 'Tier 1')) && c.IsEscalated
                   && (oldMap.get(c.Id).Current_Queue_Name__c != null && (c.PreviousQueue__c.contains('T2') || oldMap.get(c.Id).SupportTier__c == 'Tier 2')
                       && (c.Current_Queue_Name__c.contains('T3') || c.SupportTier__c == 'Tier 3' || c.Current_Queue_Name__c.contains('T4') || c.SupportTier__c == 'Tier 4') )){
                           c.FCR_Review_Escalation__c = 'Essential Escalation';
                       }
                else if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.FCR_Review_Check__c == true && c.IsEscalated && (c.InitialQueue__c.contains('T1') || (queueNameVsQueueUser != null && queueNameVsQueueUser.size()>0 && queueNameVsQueueUser.containsKey(c.InitialQueue__c) && queueNameVsQueueUser.get(c.InitialQueue__c).Tier__c == 'Tier 1'))){
                    c.FCR_Review_Escalation__c = 'Essential Escalation';
                }
                if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.SubStatus__c != CON_CSM.S_SUBSTATUS_VALUE && c.ScheduledDatetime__c != null && c.getQuickActionName() != 'Case.WforSchedule' && c.PreviousQueue__c != null && c.Current_Queue_Name__c != null && oldMap != null && oldMap.get(c.Id) != null && (c.PreviousQueue__c.contains('T3') || oldMap.get(c.Id).SupportTier__c == 'Tier 3' || c.PreviousQueue__c.contains('T2') || oldMap.get(c.Id).SupportTier__c == 'Tier 2') && (c.Current_Queue_Name__c.contains('T1') || c.SupportTier__c == 'Tier 1')){
                    c.ScheduledDatetime__c = null;
                }
            }
        }
        assignUserToCaseByRoundRobinOnUpdate(uptList, oldMap);
    }
    
    /**
    * This method is used for custom validation rules.
    * @params  newList List<Case> 
    * @return  void
    */
    public static void checkBouncedEmailFlagForRnDPillar(List<Case> newList){
        // Retrieve the list of email addresses on the new Case records
        Set<String> caseEmails = new Set<String>();
        Set<String> bouncedEmails = new Set<String>();
        for (Case newCase : newList) {
            if (newCase.AFU_Email_Addresses__c != null && (newCase.RecordTypeName__c == CON_CSM.S_RDCASE || newCase.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || newCase.RecordTypeName__c == CON_CSM.S_R_D_V_T)) {
                caseEmails.addAll(newCase.AFU_Email_Addresses__c.split(';'));
            }
        }
        // Query for contacts with bounced emails
        if(!caseEmails.isEmpty()){
            List<Contact> bouncedEmailContacts = new List<Contact>();
            bouncedEmailContacts = [SELECT Email FROM Contact WHERE Email IN :caseEmails and IsEmailBounced=true];
            for (Contact contactRecord : bouncedEmailContacts) {
                bouncedEmails.add(contactRecord.Email);
            }
            
            // Check if any case email matches a bounced contact email
            for (Case newCase : newList) {
                if (newCase.AFU_Email_Addresses__c != null && (newCase.RecordTypeName__c == CON_CSM.S_RDCASE || newCase.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || newCase.RecordTypeName__c == CON_CSM.S_R_D_V_T)) {
                    List<String> caseEmailList = newCase.AFU_Email_Addresses__c.split(';');
                    for (String email : caseEmailList) {
                        if (bouncedEmails.contains(email)) {
                            newCase.addError('Case cannot be saved because at least one AFU Email Address sent bounced email reply. Email bounced:' + email + ' Remove any bounced email to proceed with case creation.');
                        }
                    }
                }
            }
        }
    }
    public static void updateCaseValidationForAllPillar(List<Case> uptList,Map<Id,Case> oldMap){
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> dataQueueIds = new Set<Id>();
        Set<Id> dataDescQueueIds = new Set<Id>();
        String userId = userInfo.getUserId();
        Set<Id> groupId = new  Set<Id>();
        List<Queue_User_Relationship__c> GroupList = new List<Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> userGroupList = new List<Queue_User_Relationship__c>();
        for (Case c : uptList){
            if((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || (CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && !c.Close_all_child_case_with_parent__c)) && c.Status != oldMap.get(c.Id).Status && (CON_CSM.S_RESOLVED_WITH_C == c.Status || CON_CSM.S_RESOLVED == c.Status || CON_CSM.S_CLOSED == c.Status || (CON_CSM.S_WAITING_FOR == c.Status && (c.AFU_Email_Addresses__c == null && (CON_CSM.S_AFU_URGENT == c.SubStatus__c || CON_CSM.S_AFU_STANDARD == c.SubStatus__c))))){
                caseIdSet.add(c.Id);    
            }else if(CON_CSM.S_DATACASE == c.RecordTypeName__c && c.InitialQueueData__c != null && c.getQuickActionName() != 'Case.Macro_Fields' && c.Description != null && oldMap.get(c.Id).Description != null && replaceNewLine(c.Description) != replaceNewLine(oldMap.get(c.Id).Description)){
                dataDescQueueIds.add(c.InitialQueueData__c);
            }else if(CON_CSM.S_DATACASE == c.RecordTypeName__c && c.AccountCountry__c == 'US' && c.Status != null && ((c.Status != oldMap.get(c.Id).Status && CON_CSM.S_CLOSED == c.Status)) && c.InitialQueueData__c != null){
                dataQueueIds.add(c.InitialQueueData__c);
            }
            /** else if(hasCustomPermission == false && !Test.isRunningTest() && CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && userInfo.getName() != 'Automated Process' && CON_CSM.S_SYSTEM != userInfo.getName() && !UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) && c.OwnerId != UserInfo.getUserId() && c.OwnerId != oldMap.get(c.Id).OwnerId && !(c.getQuickActionName() == 'Case.Macros_Only' || c.getQuickActionName() == 'Case.Take_Ownership_Component' || c.getQuickActionName() == 'Case.Dispatch_Functionlity')){
                c.addError('User should allow to change the Case owner from Dispatch or Take Ownership');
            }
             if(!c.NoContactKnown__c && c.ParentId == null && !'system'.equalsIgnoreCase(UserInfo.getName()) && CON_CSM.S_DATACASE == c.RecordTypeName__c && c.ContactId != null && c.AccountId != null && (Trigger.isInsert || ( Trigger.isUpdate && oldMap != null && oldMap.get(c.Id) != null && (c.ContactId != oldMap.get(c.Id).ContactId || c.AccountId != oldMap.get(c.Id).AccountId)) )){
                dataValAccCon.put(c.ContactId, c.AccountId );
            } **/
        }
        
        /** if(dataValAccCon != null && !dataValAccCon.isEmpty() ){
            Set<Id> con = dataValAccCon.keySet();
            List<Id> acc = dataValAccCon.values();
            boolean check = false;
            List<AccountContactRelation> accConRel  = Database.query('select Id, AccountId, ContactId, IsActive  from AccountContactRelation where IsActive = true and ContactId in :con and AccountId in :acc');
            for(Case c : uptList){
                check = false;
                if(CON_CSM.S_DATACASE == c.RecordTypeName__c && c.ContactId != null && c.AccountId != null && (Trigger.isInsert || ( Trigger.isUpdate && oldMap != null && oldMap.get(c.Id) != null && (c.ContactId != oldMap.get(c.Id).ContactId || c.AccountId != oldMap.get(c.Id).AccountId)) )){
                    for(AccountContactRelation ac : accConRel){
                        if(c.AccountId == ac.AccountId && c.ContactId == ac.ContactId){
                            check = true;
                        }
                    }  
                }
                if(hasCustomPermission == false && !check){
                    c.adderror('Account is not associated with the contact selected.');
                } 
            }
        } **/ 
        
        if(dataQueueIds.isEmpty() == false){ 
            //List<PermissionSetAssignment> permissionSetList = Database.query('select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :userId and PermissionSet.Name =\'DATARecordTypeUSFieldAccess\'');
            
            /* if(permissionSetList != null && permissionSetList.isEmpty() == false ){
                GroupList = new SLT_QueueUserRelationshipC().selectByQueueIdSet(dataQueueIds,new Set<String>{'Id','Name','Type__c','Group_Id__c','User__c'} );
                for(Queue_User_Relationship__c qur : GroupList){
                    groupId.add(qur.Group_Id__c);
                } */
                userGroupList = new SLT_QueueUserRelationshipC().selectByUserTECHQueueIDSet(dataQueueIds,new Set<Id>{userId},new Set<String>{'Id','Name','Type__c','Group_Id__c','User__c'});
                for(Case c : uptList){
                    if(hasCustomPermission == false && userGroupList.isEmpty() && c.Status != null && !c.Status.equals(oldMap.get(c.Id).Status)){
                        c.adderror('Initial Queue members can close the case');
                    }
                }
            //}
        }else if(dataDescQueueIds != null && !dataDescQueueIds.isEmpty()){
            /* GroupList = new SLT_QueueUserRelationshipC().selectByQueueIdSet(dataDescQueueIds,new Set<String>{'Id','Name','Type__c','Group_Id__c','User__c'} );
            for(Queue_User_Relationship__c qur : GroupList){
                groupId.add(qur.Group_Id__c);
            }*/
            userGroupList = new SLT_QueueUserRelationshipC().selectByUserTECHQueueIDSet(dataDescQueueIds,new Set<Id>{userId},new Set<String>{'Id','Name','Type__c','Group_Id__c','User__c'});
            for(Case c : uptList){
                if(hasCustomPermission == false && c.Description != null && userGroupList.isEmpty() && !c.Description.equals(oldMap.get(c.Id).Description)){
                    c.adderror('Initial Queue members can edit the Description');
                }
            }
        }
        if(caseIdSet.isEmpty() == false){
            Set<Id> childCaseList = new SLT_Case().selectByStatusAndParentId(caseIdSet);
            //Set<Id> childCaseList =new Map<Id,Case>( (List<Case>) Database.query('select Id,ParentId from Case where ParentId != null and  ParentId in :caseIdSet and (Status not in (\'Resolved\',\'Closed\',\'Abandoned\',\'Canceled\',\'Merged\') and RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\'))')).keySet();          
            if(hasCustomPermission == false && childCaseList.isEmpty() == false){
                for(Case c : uptList){
                    c.adderror('Please close or resolve the related child case\'s');
                }
            }
        }

		Map<Id,Case> caseIdMap = new Map<Id,Case>();
        for (Case c : uptList){
            if ((c.Status == 'Closed' || c.Status == 'Abandoned') && oldMap.get(c.Id).Status != 'Closed' && c.RecordTypeName__c == 'TechnologyCase' && c.ProductName__c == 'PSA-RWS') {
                caseIdMap.put(c.Id, c);
                
            }
        }
		
        if(!caseIdMap.isEmpty()){
			Map<id,List<TimeSheet__c>> timeSheetMap = new Map<id,List<TimeSheet__c>>();
			List<TimeSheet__c> timeSheetRecords = new List<TimeSheet__c>();
			timeSheetRecords = [Select id,Case__c from TimeSheet__c where Case__c  In :caseIdMap.keySet() AND Time_Type__c = 'Case Completion Effort'];
			if(timeSheetRecords.size() != 0){
				for(TimeSheet__c ts : timeSheetRecords){
					if(timeSheetMap.containskey(ts.Case__c)){
						timeSheetMap.get(ts.Case__c).add(ts);
					}else{
						timeSheetMap.put(ts.Case__c,new List<TimeSheet__c>{ts});
					}
				}
			}
			
			for(id c : caseIdMap.keyset()){
				if(!timeSheetMap.containskey(c)){
					caseIdMap.get(c).addError('It is mandatory for closure to have one TimeSheet record of Case Completion effort Type for PSA-RWS product. Please proceed with Timesheet before closing.');
				}
			}
		}
    }
    
    /**
    * This method is used for CSH Data and Techno  records case owner,Initial and Current queue assignment when case created from CSH and Partner portal
    * @params  newList List<Case> 
    * @return  void
    */
    public static boolean createDataPillar(List<Case> newList) {
        boolean isDataPortalCase = false,check = false;
        String ClientContact = null,ContactUser = null,CaseSubtype3 = null,AccountId = null,RecordType = null, Country = null, Product = null, ContactTitle = null, LOS = null, CaseSubtype1 = null;
        CSM_QI_Data_Portal_Queue_User_details__c selectedData = null,serviceNow = null;
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        String initialQueue = null;
        for (Case c : newList) {
            if(c.RecordTypeName__c == CON_CSM.S_DATACASE) {
                /*  
                if(c.AccountCountry__c == 'US'){
                    c.SubType1__c = CON_CSM.S_DATAMGT;
                    c.SubType2__c = CON_CSM.S_DATAISSUE;    
                }
                */
                Product = c.ProductName__c;
                ContactUser = userInfo.getUserId();
                ClientContact = c.ContactId;
                CaseSubtype3 = c.SubType3__c;
                AccountId = c.AccountId;
                c.CaseOwnerModifiedDate__c = System.now();
                c.CaseUpdatedTime__c = System.now();
                if(c.LOS__c == null){
                    c.LOS__c = 'DATA';
                }
                RecordType = CON_CSM.S_DATACASE;
                check = true;
            }else if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                ContactUser = userInfo.getUserId();
                ClientContact = c.ContactId;
                ContactTitle = c.Contact_Title__c;
                AccountId = c.AccountId;
                c.CaseOwnerModifiedDate__c = System.now();
                c.CaseUpdatedTime__c = System.now();
                Country = c.AccountCountry__c;
                Product = c.ProductName__c;
                CaseSubtype3 = c.CSHSubType__c;
                RecordType = CON_CSM.S_TECHNO_SOL;
                check = true;
            }else if (c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) {
                LOS = c.LOS__c;
                ClientContact = c.ContactId;
                AccountId = c.AccountId;
                CaseSubtype1 = c.SubType1__c;
                c.CaseOwnerModifiedDate__c = System.now();
                c.CaseUpdatedTime__c = System.now();
                RecordType = CON_CSM.S_ACTIVITY_R_T;
                check = true;
            }
        }
        if(check && ClientContact == null){
            List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
            if(users.isEmpty() == false && users[0].ContactId != null){
                ClientContact = users[0].ContactId;
            }
        }
        if(check){
            isDataPortalCase = true;
            if(CON_CSM.S_DATACASE == RecordType){
                List<CSM_QI_Data_Portal_Queue_User_details__c> outputDataList = Database.query('select Id, ClientContact__c, Queue_User_Relationship__c,Queue_User_Relationship__r.Name,Queue_User_Relationship__r.Group_Id__c, ContactUser__c, Case_Subtype_3__c, Account__c, Order__c, IQVIA_User__c, CaseRecordType__c,UserStatus__c  From CSM_QI_Data_Portal_Queue_User_details__c where Type__c = \'Queue Assignment\' AND CaseRecordType__c = \'DATACase\' and ((order__c = 100 and Case_Subtype_3__c = :CaseSubtype3) or (order__c = 70 and Case_Subtype_3__c = :CaseSubtype3 and Account__c = :AccountId and Product__c =:Product and ClientContact__c = :ClientContact) or (order__c = 60 and Case_Subtype_3__c = :CaseSubtype3 and Account__c = :AccountId and ClientContact__c = :ClientContact) or (order__c = 50 and Case_Subtype_3__c = :CaseSubtype3 and Account__c = :AccountId and Product__c =:Product) or (order__c = 40 and Account__c = :AccountId and Product__c =:Product and ClientContact__c = :ClientContact) or (order__c = 30 and Account__c = :AccountId and ClientContact__c = :ClientContact and All_Current_Users__c = false) or (order__c = 25 and Account__c = :AccountId and Case_Subtype_3__c = :CaseSubtype3 and All_Current_Users__c = true) or (order__c = 20 and Account__c = :AccountId and Product__c =:Product and All_Current_Users__c = true) or (order__c = 1 and Account__c = :AccountId and All_Current_Users__c = true)) order by Order__c desc');
                for(CSM_QI_Data_Portal_Queue_User_details__c data : outputDataList){
                    selectedData = data;
                    break;
                }   
                
                if(selectedData != null && CON_CSM.S_DATACASE == RecordType && (selectedData.IQVIA_User__c != null || (selectedData.Queue_User_Relationship__r != null && selectedData.Queue_User_Relationship__r.Group_Id__c != null)) ){
                    queueList = new SLT_QueueUserRelationshipC().selectByGroupIdSet(new Set<Id>{( (selectedData.IQVIA_User__c != null && selectedData.UserStatus__c) ? selectedData.IQVIA_User__c : selectedData.Queue_User_Relationship__r.Group_Id__c)});
                }
                List<CSM_QI_Data_Portal_Queue_User_details__c> serviceNowList = Database.query('select Id, CMDB__c,ServiceNow_Group__c, ServiceNow_Type__c, CaseRecordType__c  From CSM_QI_Data_Portal_Queue_User_details__c where Type__c = \'Product Level Restriction\' AND CaseRecordType__c = \'DATACase\' and ClientContact__c = :ClientContact AND Account__c =:AccountId AND Product__c =:Product LIMIT 1');
                for(CSM_QI_Data_Portal_Queue_User_details__c d : serviceNowList){
                    serviceNow = d;
                }
                
            }else if(CON_CSM.S_TECHNO_SOL == RecordType){
                isDataPortalCase = true;
                List<CSM_QI_Data_Portal_Queue_User_details__c> outputDataList = Database.query('select Id, ClientContact__c, Queue_User_Relationship__c,Queue_User_Relationship__r.Name,Queue_User_Relationship__r.Group_Id__c, ContactUser__c, Account__c, Order__c, IQVIA_User__c, CaseRecordType__c, UserStatus__c From CSM_QI_Data_Portal_Queue_User_details__c where Type__c = \'Queue Assignment\' AND CaseRecordType__c = \'TechnologyCase\' and ((Account__c =:AccountId and Product__c =:Product and ClientContact__c = :ClientContact and Order__c = 8) or (Account__c =:AccountId and ClientContact__c = :ClientContact and Order__c = 7) or (AccountCountry__c =:Country and Account__c =:AccountId and Contact_User_Type__c =:ContactTitle and Product__c =:Product and CSH_Sub_Type__c =:CaseSubtype3 and Order__c = 6) or (AccountCountry__c =:Country and Account__c =:AccountId and Contact_User_Type__c =:ContactTitle and Product__c =:Product and Order__c = 5) or (AccountCountry__c =:Country and Account__c =:AccountId and Contact_User_Type__c =:ContactTitle and Order__c = 4) or (AccountCountry__c =:Country and Account__c =:AccountId and Product__c =:Product and CSH_Sub_Type__c =:CaseSubtype3 and Order__c = 3) or (AccountCountry__c =:Country and Account__c =:AccountId and Product__c =:Product and Order__c = 2) or (Account__c =:AccountId and Order__c = 1)) order by Order__c DESC'); 
                for(CSM_QI_Data_Portal_Queue_User_details__c data : outputDataList){
                    selectedData = data;
                    break;
                }
                
                List<CSM_QI_Data_Portal_Queue_User_details__c> serviceNowList = Database.query('select Id, CMDB__c,ServiceNow_Group__c, ServiceNow_Type__c, CaseRecordType__c  From CSM_QI_Data_Portal_Queue_User_details__c where Type__c = \'Product Level Restriction\' AND CaseRecordType__c = \'TechnologyCase\' and ClientContact__c = :ClientContact AND Account__c =:AccountId AND Product__c =:Product LIMIT 1'); 
                for(CSM_QI_Data_Portal_Queue_User_details__c d : serviceNowList){
                    serviceNow = d;
                }
            }else if (CON_CSM.S_ACTIVITY_R_T == RecordType) {
                List<CSM_QI_Data_Portal_Queue_User_details__c> outputDataList = Database.query('select Id, Queue_User_Relationship__c,Queue_User_Relationship__r.Name,Queue_User_Relationship__r.Group_Id__c, ContactUser__c, Account__c, Order__c, IQVIA_User__c, CaseRecordType__c, UserStatus__c From CSM_QI_Data_Portal_Queue_User_details__c where Type__c = \'Queue Assignment\' AND CaseRecordType__c = \'ActivityPlan\' and ((LOS__c =:LOS and Case_Subtype_1__c = :CaseSubtype1 and Account__c =:AccountId and Order__c = 30) or (LOS__c =:LOS and Account__c =:AccountId and Order__c = 20) or (Account__c =:AccountId and Order__c = 1)) order by Order__c DESC'); 
                for(CSM_QI_Data_Portal_Queue_User_details__c data : outputDataList){
                    selectedData = data;
                    break;
                }
            }
            
            for (Case c : newList) {
                if(selectedData != null && CON_CSM.S_DATACASE == selectedData.CaseRecordType__c){
                    c.CurrentQueue__c = selectedData.Queue_User_Relationship__c;
                    c.InitialQueueData__c = selectedData.Queue_User_Relationship__c;
                    c.InitialQueue__c = selectedData.Queue_User_Relationship__r.Name;
                    c.Owner__c = ((selectedData.IQVIA_User__c != null && selectedData.UserStatus__c) ? selectedData.IQVIA_User__c : selectedData.Queue_User_Relationship__r.Group_Id__c);
                    c.CSM_QI_Data_Originator__c = ((selectedData.IQVIA_User__c != null && selectedData.UserStatus__c) ? selectedData.IQVIA_User__c : selectedData.Queue_User_Relationship__r.Group_Id__c);
                    if(!queueList.isEmpty() && queueList.size() > 0){
                        c.CaseOriginatorName__c = ((selectedData.IQVIA_User__c != null && selectedData.UserStatus__c) ? queueList[0].User__r.Name : queueList[0].Name); 
                        c.CaseOriginatorEmail__c = ((selectedData.IQVIA_User__c != null && selectedData.UserStatus__c) ? queueList[0].User_Email__c : queueList[0].Queue_Email__c);  
                    }
                }else if(selectedData != null && CON_CSM.S_TECHNO_SOL == selectedData.CaseRecordType__c){
                    c.CurrentQueue__c = selectedData.Queue_User_Relationship__c;
                    c.InitialQueue__c = selectedData.Queue_User_Relationship__r.Name;
                    c.Owner__c = ((selectedData.IQVIA_User__c != null && selectedData.UserStatus__c) ? selectedData.IQVIA_User__c : selectedData.Queue_User_Relationship__r.Group_Id__c);
                    if(selectedData.Queue_User_Relationship__c != null &&  selectedData.Queue_User_Relationship__r.Name != null && selectedData.Queue_User_Relationship__r.Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                        c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                    }
                }else if(selectedData != null && CON_CSM.S_ACTIVITY_R_T == selectedData.CaseRecordType__c){
                    c.Owner__c = selectedData.Queue_User_Relationship__r.Group_Id__c;
                    c.CurrentQueue__c = selectedData.Queue_User_Relationship__c;
                    c.InitialQueue__c = selectedData.Queue_User_Relationship__r.Name;
                }
                if(serviceNow != null && (CON_CSM.S_TECHNO_SOL == serviceNow.CaseRecordType__c || CON_CSM.S_DATACASE == serviceNow.CaseRecordType__c)){
                    c.ServiceNowSystemType__c = 'Internal';
                    c.ServiceNow_Group__c = serviceNow.ServiceNow_Group__c;
                    if(c.Service_Now_Type__c == null){
                        c.Service_Now_Type__c = serviceNow.ServiceNow_Type__c;
                    }
                    c.CMDB__c = serviceNow.CMDB__c;
                    c.Customer_Requested_Date__c = System.today();
                }
                initialQueue = c.InitialQueue__c;
            }
            if(initialQueue != null) { 
                assignUserToCaseByRoundRobin(newList,initialQueue); 
            }
        }        
        return isDataPortalCase;
    }
    
    /**
    * This method is used send an email to Case Originator when the case created from Web or Email or CSH
    * @params  newList List<Case> 
    * @return  void
    */
    public static void sendEmailtoOwnerDataPillar(List<Case> newList) {
        Map<Id,Id> queueList = new Map<Id,Id>();
        List<String> toAddresses = new List<String>();
        for (Case c : newList) {
            if(CON_CSM.S_DATACASE == c.RecordTypeName__c && c.CSM_QI_Data_Originator__c != null && (c.CSM_QI_Data_Originator__c.startsWith(CON_CSM.S_QUEUE_ID) || c.CSM_QI_Data_Originator__c.startsWith(CON_CSM.S_USER_ID)) && (UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || ('Web'.equals(c.Origin) && c.HCRSWebID__c != null && (c.HCRSWebID__c.startsWith(CON_CSM.S_ORGANIZATIONS) || c.HCRSWebID__c.startsWith(CON_CSM.S_PROFESSIONALS))))) {
            //if(CON_CSM.S_DATACASE == c.RecordTypeName__c && c.CSM_QI_Data_Originator__c != null && (c.CSM_QI_Data_Originator__c.startsWith(CON_CSM.S_QUEUE_ID) || c.CSM_QI_Data_Originator__c.startsWith(CON_CSM.S_USER_ID)) && ('Web' == c.Origin && c.HCRSWebID__c != null && (c.HCRSWebID__c.startsWith(CON_CSM.S_ORGANIZATIONS) || c.HCRSWebID__c.startsWith(CON_CSM.S_PROFESSIONALS)))) {
                queueList.put(c.CSM_QI_Data_Originator__c,c.Id); 
            }
        }
        if(!queueList.isEmpty()){
            List<Queue_User_Relationship__c> queueUser = new SLT_QueueUserRelationshipC().selectByCSHUserorGroupSet(queueList.keySet());
            if(!queueUser.isEmpty()){
                Pattern patt = Pattern.compile(CON_CSM.S_EMAIL_REGEXP);
                Matcher match = null;
                String emailId,queueemailId;
                for (Queue_User_Relationship__c c : queueUser) {
                    if(CON_CSM.S_QUEUE == c.Type__c && c.Queue_Email__c != null){
                        emailId = c.Queue_Email__c;
                        queueemailId = c.Queue_Email__c;
                        break;
                    }else{
                        emailId = c.User_Email__c;
                    }
                    if(emailId != null){
                        match = patt.matcher(emailId.trim());
                        if(match.matches()){
                            toAddresses.add(emailId);
                        }
                    }   
                }
                if(queueemailId != null){
                    toAddresses.clear();
                    toAddresses.add(queueemailId);
                }
            }
        }
        if(!toAddresses.isEmpty()){
            List<Messaging.SingleEmailMessage> dataSendEmailList = new List<Messaging.SingleEmailMessage>();
            Set<Id> contactIds = new Set<Id>();
            List<Case> caseList = new List<Case>();
            for(Case caseRecord : newList){
                if(caseRecord.ContactId != null){
                    contactIds.add(caseRecord.ContactId);
                    caseList.add(caseRecord);
                }
            }
            Map<Id, String> conPLMap = new Map<Id, String>();
            if(contactIds != null && !contactIds.isEmpty()){
                List<Contact> contactList = new SLT_Contact().selectContactBasedOnId(contactIds);
                if(!contactList.isEmpty()){
                    for(Contact contactRecord : contactList){
                        if(contactRecord.PreferredLanguage__c != null){
                            conPLMap.put(contactRecord.Id, contactRecord.PreferredLanguage__c);
                        }
                    }
                }
            }
            for(Case caseRecord : caseList){
                Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
                if(caseRecord.ContactId != null && conPLMap != null && conPLMap.get(caseRecord.ContactId) != null && getCSMSettingData().get(conPLMap.get(caseRecord.ContactId) + CON_CSM.SPC_TILDE + caseRecord.RecordTypeId + CON_CSM.SPC_TILDE + caseRecord.Status) != null) {
                    mailMessage.setTemplateId(getCSMSettingData().get(conPLMap.get(caseRecord.ContactId) + CON_CSM.SPC_TILDE + caseRecord.RecordTypeId + CON_CSM.SPC_TILDE + caseRecord.Status).Component_Id__c);
                }else if(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + caseRecord.RecordTypeId + CON_CSM.SPC_TILDE + caseRecord.Status) != null) {
                    mailMessage.setTemplateId(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + caseRecord.RecordTypeId + CON_CSM.SPC_TILDE + caseRecord.Status).Component_Id__c);
                }
                else{
                    continue;
                }
                String senderId = '';
                if( ('Web' == caseRecord.Origin || CON_CSM.S_EMAIL == caseRecord.Origin || CON_CSM.S_CUSTOMER_PORTAL == caseRecord.Origin ) && getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL) != null) {
                    senderId = getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL).Component_Id__c;
                }else if(CON_CSM.S_AGENT_INITIATED == caseRecord.Origin && getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED) != null) {
                    senderId = getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED).Component_Id__c;
                }
                if(senderId != null && senderId.length() > 0) {
                    mailMessage.setOrgWideEmailAddressId(senderId);
                }
                mailMessage.setSaveAsActivity(false);
                mailMessage.setTargetObjectId(caseRecord.ContactId);
                mailMessage.setTreatTargetObjectAsRecipient(false);
                mailMessage.setToAddresses(toAddresses);
                mailMessage.setWhatId(caseRecord.Id);
                mailMessage.setReferences(Cases.generateThreadingMessageId(caseRecord.Id));
                dataSendEmailList.add(mailMessage);
            }
            if(dataSendEmailList != null && dataSendEmailList.size() > 0) {
                try{
                    Messaging.sendEmail(dataSendEmailList);
                }
                catch(Exception ex){
                    System.debug('Mail Exception: '+ex.getMessage());
                }
            }
        }
    }
    
    /**
    * This method is used for Custom validation Rules
    * @params  newList List<Case> 
    * @return  void
    */
    public static void ValidationForAllPillar(List<Case> newList, Map<Id,Case> oldMap) {
        Set<Id> parentIds = new Set<Id>();
        Map<Id,Id> dataValAccCon = new Map<Id,Id>();
        for (Case c : newList) {
            if(c.ParentId != null && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T)){
                parentIds.add(c.ParentId);
            }
            if(!c.NoContactKnown__c && c.ParentId == null && !'system'.equalsIgnoreCase(UserInfo.getName()) && CON_CSM.S_DATACASE == c.RecordTypeName__c && c.ContactId != null && c.AccountId != null && (Trigger.isInsert || ( Trigger.isUpdate && oldMap != null && oldMap.get(c.Id) != null && (c.ContactId != oldMap.get(c.Id).ContactId || c.AccountId != oldMap.get(c.Id).AccountId)) )){
                dataValAccCon.put(c.ContactId, c.AccountId );
            }
        }
        if(dataValAccCon != null && !dataValAccCon.isEmpty() ){
            Set<Id> con = dataValAccCon.keySet();
            List<Id> acc = dataValAccCon.values();
            boolean check = false;
            List<AccountContactRelation> accConRel = null;
            if(con != null && acc != null){
                accConRel = Database.query('select Id, AccountId, ContactId, IsActive from AccountContactRelation where IsActive = true and ContactId in :con and AccountId in :acc');
            }
            for(Case c : newList){
                check = false;
                if(CON_CSM.S_DATACASE == c.RecordTypeName__c && c.ContactId != null && c.AccountId != null && (Trigger.isInsert || ( Trigger.isUpdate && oldMap != null && oldMap.get(c.Id) != null && (c.ContactId != oldMap.get(c.Id).ContactId || c.AccountId != oldMap.get(c.Id).AccountId)) )){
                    for(AccountContactRelation ac : accConRel){
                        if(c.AccountId == ac.AccountId && c.ContactId == ac.ContactId){
                            check = true;
                        }
                    }
                    if(hasCustomPermission == false && !check){
                        c.adderror('Account is not associated with the contact selected.');
                    }
                }
                
            }
        }
        if(parentIds != null && parentIds.isEmpty() == false){
            Map<Id, Case> childChild = new SLT_Case().getCaseById(parentIds,new Set<String>{'Id','ParentId'});
            for (Case c : newList) {
                if(hasCustomPermission == false && childChild != null && childChild.isEmpty() == false && childChild.get(c.ParentId) != null && childChild.get(c.ParentId).ParentId != null && c.RecordTypeName__c != CON_CSM.S_TECHNOLOGY_R_T){
                    c.adderror('User can\'t create a child case for child case');
                }
            }
            if(childChild != null && !childChild.isEmpty()){
                Set<Id> superParentIds = new Set<Id>();
                for(Case caseRecord : childChild.values()){
                    if(caseRecord.ParentId != null){
                        superParentIds.add(caseRecord.ParentId);
                    }
                }
                if(superParentIds != null && !superParentIds.isEmpty()){
                    Map<Id, Case> superChildMap = new SLT_Case().getCaseById(superParentIds, new Set<String>{'Id','ParentId'});
                    for(Case childRecord : newList){
                        if(superChildMap != null && !superChildMap.isEmpty() && childRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                            if(hasCustomPermission == false && superChildMap.get(childChild.get(childRecord.ParentId).ParentId)!= null && superChildMap.get(childChild.get(childRecord.ParentId).ParentId).ParentId != null){
                                childRecord.addError('You can\'t create a child case below 3rd level hierarchy');
                            }
                        }
                    }
                }
            }
        }
    }
      
    /**
    * This method is used to create a child case for all pillers for CSM Quick Action
    * @params  newList List<Case> 
    * @return  void
    */
    public static void createChildCaseAllPillar(List<Case> newList, Map<Id,Case> oldMap) {
        Set<Id> parentIds = new Set<Id>();
        Set<Id> parentIdsUpdated = new Set<Id>();
        Set<Id> caseNoLongerParent = new Set<Id>();
        Map<Id,Case> parentMap = new Map<Id,Case>();
        Map<Id,Case> parentMapWithOldMap = new Map<Id,Case>();
        Map<Id,Case> parentCaseToUpdate  = new Map<Id,Case>();
        CSM_Case_Details_Global_Setting__c cdg = null;
        for (Case c : newList) {
            if (oldMap != null && oldMap.get(c.Id) != null) {
                if(oldMap.get(c.Id).ParentId != c.ParentId){
                    if(oldMap.get(c.Id).ParentId != null){
                        parentIdsUpdated.add(oldMap.get(c.Id).ParentId);
                    }
                    parentIds.add(c.ParentId);
                }
                c.Case_ThreadToken__c = EmailMessages.getFormattedThreadingToken(c.Id);
            }else if(oldMap == null && c.ParentId != null){
                c.Case_ThreadToken__c = null;
                parentIds.add(c.ParentId);
            }
        }
        
        if(parentIdsUpdated != null && !parentIdsUpdated.isEmpty()){
            List<AggregateResult> ars = new List<AggregateResult>();
            ars = [select count(id), ParentId from case where parentId in :parentIdsUpdated group by ParentId HAVING COUNT(ParentId) < 2];
            for(AggregateResult ar:ars){
                caseNoLongerParent.add(String.valueOf(ar.get('ParentId')));
            }
        }

        if(caseNoLongerParent != null && !caseNoLongerParent.isEmpty()){
            List<Case> parentList = new SLT_Case().selectById(caseNoLongerParent);
            for(Case parent : parentList){
                if(parent.Is_Parent__c){
                    parent.Is_Parent__c = false;
                    parentCaseToUpdate.put(parent.Id,parent);
                }
            }
        }
        
        if(parentIds != null && !parentIds.isEmpty()){
            List<Case> parentList = new SLT_Case().selectById(parentIds);
            for(Case parent : parentList){
                if(!parent.Is_Parent__c){
                    parent.Is_Parent__c = true;
                    parentCaseToUpdate.put(parent.Id,parent);
                }
                if(oldMap == null){
                    parentMap.put(parent.Id, parent);
                }else{
                    parentMapWithOldMap.put(parent.Id, parent);
                }

            }
            if(oldMap == null && parentMap != null && !parentMap.isEmpty()){
                for (Case c : newList) {
                    if(parentMap.containsKey(c.ParentId) && c.Owner__c != 'BulkCase'){
                        c.AlignmentName__c = parentMap.get(c.ParentId).AlignmentName__c;
                        c.CaseRequestBy__c = parentMap.get(c.ParentId).CaseRequestBy__c;
                        c.Case_CategorizationId__c = parentMap.get(c.ParentId).Case_CategorizationId__c;
                        c.CaseSubType1__c = parentMap.get(c.ParentId).CaseSubType1__c;
                        c.CaseSubType2__c = parentMap.get(c.ParentId).CaseSubType2__c;
                        c.CaseSubType3__c = parentMap.get(c.ParentId).CaseSubType3__c;
                        c.ClientObjectiveBusinessNeed__c = parentMap.get(c.ParentId).ClientObjectiveBusinessNeed__c;
                        c.CrossDatabase__c = parentMap.get(c.ParentId).CrossDatabase__c;
                        c.DataDeliveryEndDate__c = parentMap.get(c.ParentId).DataDeliveryEndDate__c;
                        c.DataMeasurement__c = parentMap.get(c.ParentId).DataMeasurement__c;
                        c.NoContactKnown__c = c.ContactId != null ? false : true;
                        c.NovartisCaseType__c = parentMap.get(c.ParentId).NovartisCaseType__c;
                        c.OnBehalfOf__c = parentMap.get(c.ParentId).OnBehalfOf__c;
                        if(!(UserInfo.getName() == CON_CSM.S_SYSTEM && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP ||  c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE))){
                            c.Origin = parentMap.get(c.ParentId).Origin;
                            c.Service_Now_Incident_Number__c = null;
                            c.ServiceNow_Group__c = null;
                            c.ServiceNow_Status__c = null;
                            c.ServiceNow_Last_Updated_Date__c = null;
                            c.Service_Now_Type__c = null;
                            c.CloseCode__c = null;
                            c.Customer_Requested_Date__c = null;
                            c.CloseNotes__c = null;
                        }
                        c.Reason = parentMap.get(c.ParentId).Reason;
                        c.SlaStartDate = null;
                        c.SuppliedCompany = parentMap.get(c.ParentId).SuppliedCompany;
                        c.SuppliedEmail = parentMap.get(c.ParentId).SuppliedEmail;
                        c.SuppliedName = parentMap.get(c.ParentId).SuppliedName;
                        c.SuppliedPhone = parentMap.get(c.ParentId).SuppliedPhone;
                        c.Tag__c = parentMap.get(c.ParentId).Tag__c;
                        c.Type = parentMap.get(c.ParentId).Type;
                        c.UrgentForCustomer__c = parentMap.get(c.ParentId).UrgentForCustomer__c;
                        c.Language__c = parentMap.get(c.ParentId).Language__c;
                        c.ProductMarketorOther__c = parentMap.get(c.ParentId).ProductMarketorOther__c;
                        c.Pharma_Product_Name__c = parentMap.get(c.ParentId).Pharma_Product_Name__c;
                        c.NDC_Number__c = parentMap.get(c.ParentId).NDC_Number__c;
                        c.Number_of_Corrective_Action_Lookups__c = parentMap.get(c.ParentId).Number_of_Corrective_Action_Lookups__c;
                        c.Did_this_Require_Corrective_Action__c = parentMap.get(c.ParentId).Did_this_Require_Corrective_Action__c;
                        c.RunDateOfReport__c = parentMap.get(c.ParentId).RunDateOfReport__c;
                        c.TimeIntervalsquestioningcomparing__c = parentMap.get(c.ParentId).TimeIntervalsquestioningcomparing__c;
                        c.ProductMarketOrOtherName__c = parentMap.get(c.ParentId).ProductMarketOrOtherName__c;
                        c.Product_Market_or_Other_Name__c = parentMap.get(c.ParentId).Product_Market_or_Other_Name__c;
                        c.CMFProd__c = parentMap.get(c.ParentId).CMFProd__c;
                        c.USC5__c = parentMap.get(c.ParentId).USC5__c;
                        c.AreyouquestioningcomparingProjected__c = parentMap.get(c.ParentId).AreyouquestioningcomparingProjected__c;
                        c.Auditsquestioningcomparing__c = parentMap.get(c.ParentId).Auditsquestioningcomparing__c;
                        c.Metricsquestioningcomparing__c = parentMap.get(c.ParentId).Metricsquestioningcomparing__c;
                        c.InternalOrExternalDI__c = parentMap.get(c.ParentId).InternalOrExternalDI__c;
                        c.Internal_or_External_DI__c = parentMap.get(c.ParentId).Internal_or_External_DI__c;
                        c.FillinthenameoftheClientCompanyt__c = parentMap.get(c.ParentId).FillinthenameoftheClientCompanyt__c;
                        c.PRSNumber__c = parentMap.get(c.ParentId).PRSNumber__c;
                        c.Channelsquestioningcomparing__c = parentMap.get(c.ParentId).Channelsquestioningcomparing__c;
                        c.MarketNameOnWeb__c = parentMap.get(c.ParentId).MarketNameOnWeb__c;
                        c.AgeGrouping__c = parentMap.get(c.ParentId).AgeGrouping__c;
                        c.MonoComboTherapy__c = parentMap.get(c.ParentId).MonoComboTherapy__c;
                        c.SpecialtyGrouping__c = parentMap.get(c.ParentId).SpecialtyGrouping__c;
                        c.DataWeekMonthofReportLifelink__c = parentMap.get(c.ParentId).DataWeekMonthofReportLifelink__c;
                        c.TimingofReportChanges__c = parentMap.get(c.ParentId).TimingofReportChanges__c;
                        c.RandD_Location__c = parentMap.get(c.ParentId).RandD_Location__c;
                        if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c){
                            c.Requested_Date__c = System.today();
                            c.External_System_Type__c = parentMap.get(c.ParentId).External_System_Type__c;
                            if(c.Country_of_the_requester2__c == null && parentMap.get(c.ParentId).Country_of_the_requester2__c != null){
                                c.Country_of_the_requester2__c = parentMap.get(c.ParentId).Country_of_the_requester2__c;
                            }
                        }
                        c.CreateChildCase__c = true;
                        if(CON_CSM.S_DATACASE == c.RecordTypeName__c){
                            c.Case_Type__c = parentMap.get(c.ParentId).Case_Type__c;
                        }
                        if(parentMap.get(c.ParentId).AccountId == c.AccountId && parentMap.get(c.ParentId).AssetId != null && (CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c || c.RecordTypeName__c == CON_CSM.S_DATACASE)){
                            c.AssetId = parentMap.get(c.ParentId).AssetId;
                            c.ProductName__c = parentMap.get(c.ParentId).ProductName__c;
                            c.SubType1__c = parentMap.get(c.ParentId).SubType1__c;
                            c.SubType2__c = parentMap.get(c.ParentId).SubType2__c;
                            c.SubType3__c = parentMap.get(c.ParentId).SubType3__c;
                        } else if(c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || CON_CSM.S_RDCASE == c.RecordTypeName__c || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T){
                            c.LOS__c = c.LOS__c != null ? c.LOS__c : parentMap.get(c.ParentId).LOS__c;
                            c.SubType1__c = c.SubType1__c != null ? c.SubType1__c : parentMap.get(c.ParentId).SubType1__c;
                            c.SubType2__c = c.SubType2__c != null ? c.SubType2__c : parentMap.get(c.ParentId).SubType2__c;
                            c.SubType3__c = c.SubType3__c != null ? c.SubType3__c : parentMap.get(c.ParentId).SubType3__c;
                            c.Template__c = parentMap.get(c.ParentId).Template__c;
                        }
                        if(c.Copy_Watch_List_User__c && parentMap.get(c.ParentId).Watch_List_User__c != null){
                            c.Watch_List_User__c = parentMap.get(c.ParentId).Watch_List_User__c;
                        }
                    }
                    if(parentMap.containsKey(c.ParentId) && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || CON_CSM.S_RDCASE == c.RecordTypeName__c || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T)){
                        cdg = CSM_Case_Details_Global_Setting__c.getValues(c.CurrentQueue__c);
                        if(cdg != null){
                            c.OwnerId = cdg.MailCC_Component_Id__c;
                            c.CurrentQueue__c = cdg.Component_Id__c;
                            c.InitialQueueData__c = cdg.Component_Id__c;
                            c.InitialQueue__c = cdg.Other_Details__c;
                        }
                        if(c.LOS__c == 'LTMS Investigator Site Support' || c.LOS__c == 'Q² Lab Investigator Services' || parentMap.get(c.ParentId).LOS__c == 'LTMS Investigator Site Support' || parentMap.get(c.ParentId).LOS__c == 'Q² Lab Investigator Services'){
                            c.LOS__c = 'Q² Investigator Site Support';
                            c.SubType1__c = null;
                            c.SubType2__c = null;
                            c.SubType3__c = null;
                            c.Template__c = null;
                        }
                    }
                }
            }

            if(parentMapWithOldMap != null && !parentMapWithOldMap.isEmpty()){
                for (Case c : newList) {
                    if (oldMap != null && oldMap.get(c.Id) != null) {
                        if(c.ParentId != null && oldMap.get(c.Id).ParentId != c.ParentId){
                            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c) {
                                c.Priority = parentMapWithOldMap.get(c.ParentId).Priority;
                                c.Urgency__c = parentMapWithOldMap.get(c.ParentId).Urgency__c;
                                c.Impact__c = parentMapWithOldMap.get(c.ParentId).Impact__c;
                            }
                        }
                    }
                }
            }
        }
        if(parentCaseToUpdate != null && parentCaseToUpdate.isEmpty() == false){
            try{
                update parentCaseToUpdate.values();
            }catch(DmlException e){
                for (Case c : newList) {
                    c.addError('Parent Case : '+e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': ['));
                    break;
                }
            }
        }
    }

    /* Added by Saurabh */
    public static Map<String, CSM_Case_Details_Global_Setting__c> csmSettData;
    public static Map<String, CSM_Case_Details_Global_Setting__c> getCSMSettingData() {
        if(csmSettData == null) {
            csmSettData = new Map<String, CSM_Case_Details_Global_Setting__c>();
            List<CSM_Case_Details_Global_Setting__c> lstCSMSetting = CSM_Case_Details_Global_Setting__c.getall().values();
            for(CSM_Case_Details_Global_Setting__c objCsmSett: lstCSMSetting) {
                if(objCsmSett.Setting_Type__c == 'Email Template' && objCsmSett.RecordTypeId__c != null) {                    
                    if(objCsmSett.Other_Details__c =='Resolved with Customer' && objCsmSett.MailCC_Component_Id__c != null ){
                        csmSettData.put(objCsmSett.Country__c + CON_CSM.SPC_TILDE + objCsmSett.RecordTypeId__c + CON_CSM.SPC_TILDE + objCsmSett.Other_Details__c , objCsmSett);
                    }else{
                        csmSettData.put(objCsmSett.Country__c + CON_CSM.SPC_TILDE + objCsmSett.RecordTypeId__c + CON_CSM.SPC_TILDE + objCsmSett.Other_Details__c, objCsmSett);
                    }
                    
                }else if(objCsmSett.Setting_Type__c == 'Email Template' && objCsmSett.RecordTypeId__c == null) {
                    csmSettData.put(objCsmSett.Country__c + CON_CSM.SPC_TILDE + objCsmSett.Other_Details__c, objCsmSett);
                }else if(objCsmSett.Setting_Type__c == 'Org Wide') {
                    csmSettData.put(objCsmSett.Other_Details__c, objCsmSett);
                }
            }
        }
        return csmSettData;
    }
    
    public static Map<String, CSM_Case_Details_Global_Setting__c> csmSettingData;
    public static Map<String, CSM_Case_Details_Global_Setting__c> getCSMSettingData(String dataW2cType) {
        if(csmSettingData == null) {
            csmSettingData = new Map<String, CSM_Case_Details_Global_Setting__c>();
            List<CSM_Case_Details_Global_Setting__c> lstCSMSetting = CSM_Case_Details_Global_Setting__c.getall().values();
            for(CSM_Case_Details_Global_Setting__c objCsmSett: lstCSMSetting) {
                if(dataW2cType != null && objCsmSett.Other_Details__c != null && objCsmSett.Other_Details__c.contains(dataW2cType)){
                    csmSettingData.put(objCsmSett.Other_Details__c , objCsmSett);
                }
            }
        }
        return csmSettingData;
    }
    
    public static boolean isCSMccEmailsHaveSent = false;
    public static void sendCaseCCEmails(List<Case> newList){
        if(!isCSMccEmailsHaveSent) {
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
            Boolean result = true;
            List<String> toAddresses;
            Pattern patt = null;
            Matcher match = null;
            List<Messaging.SingleEmailMessage> ccSendEmailList = new List<Messaging.SingleEmailMessage>();
            Set<Id> contactIds = new Set<Id>();
            List<Case> caseList = new List<Case>();
            Map<Id, Contact> contactMap;
            for(Case caseRecord : newList){
                if(caseRecord.ContactId != null){
                    contactIds.add(caseRecord.ContactId);
                    caseList.add(caseRecord);
                }
            }
            Boolean alreadyFetchedContact = false;
            if(contactIds != null && contactIds.size() > 0){
                if(contactMap != null && contactMap.size() > 0){
                    for(Id conId: contactMap.keySet()) {
                        if(contactIds.contains(conId)) {
                            alreadyFetchedContact = true;
                            break;
                        }
                    }
                }
                if(!alreadyFetchedContact) {
                    contactMap = new Map<Id, Contact>(new SLT_Contact().selectContactBasedOnId(contactIds));
                }
                List<Contact> contactList = contactMap.values();
                Map<Id, String> contactIdLanguageMap = new Map<Id, String>();
                if(!contactList.isEmpty()){
                    for(Contact contactRecord : contactList){
                        if(contactRecord.PreferredLanguage__c != null){
                            contactIdLanguageMap.put(contactRecord.Id, contactRecord.PreferredLanguage__c);
                        }
                    }
                }
                for(Case cs : caseList){
                    if(cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || cs.RecordTypeName__c == CON_CSM.S_DATACASE){
                        if(Trigger.isUpdate && cs.Status == ((Case)Trigger.oldMap.get(cs.Id)).Status && cs.Mail_CC_List__c != null && cs.Mail_CC_List__c.length() > 0){
                            continue;
                        }
                        toAddresses = new List<String>();
                        if(cs.Mail_CC_List__c != null && cs.Mail_CC_List__c != ''){
                            for(String mail : cs.Mail_CC_List__c.split(';')){
                                patt = Pattern.compile(emailRegex);
                                match = patt.matcher(mail.trim());
                                if(!match.matches()){
                                    result = false;
                                }else{
                                    toAddresses.add(mail);
                                }
                            }
                            
                            if(result){
                                Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
                                if(cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                                    if(cs.Origin == CON_PEP.S_PARTNER_PORTAL && getCSMSettingData().get('Default PEP~' + cs.Status) != null) {
                                        mailMessage.setTemplateId(getCSMSettingData().get('Default PEP~' + cs.Status).Component_Id__c);
                                    }
                                    else if(cs.Origin.equalsIgnoreCase(CON_PEP.S_PARTNER_PORTAL) && getCSMSettingData().get('PEP~' + cs.Status) != null) {
                                        mailMessage.setTemplateId(getCSMSettingData().get('PEP~' + cs.Status).Component_Id__c);
                                    }else if(!contactIdLanguageMap.isEmpty() && contactIdLanguageMap.get(cs.ContactId) != null){
                                            if(!contactIdLanguageMap.get(cs.ContactId).equalsIgnoreCase(CON_CSM.S_EN_US) && !contactIdLanguageMap.get(cs.ContactId).equalsIgnoreCase(CON_CSM.S_EN_GB) && getCSMSettingData().get(contactIdLanguageMap.get(cs.ContactId) + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE + cs.Status) != null )
                                            {                                   
                                                if(cs.Status =='Resolved with Customer' && cs.Origin == 'Customer Portal')
                                                {     
                                                    mailMessage.setTemplateId(getCSMSettingData().get(contactIdLanguageMap.get(cs.ContactId) + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE + cs.Status).MailCC_Component_Id__c);                                            
                                                }
                                            }
                                            else if(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE +  cs.Status) != null)
                                            {
                                                if(cs.Status =='Resolved with Customer' && cs.Origin == 'Customer Portal')
                                                {
                                                    mailMessage.setTemplateId(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE +  cs.Status).MailCC_Component_Id__c);                                                    
                                                }
                                                else
                                                {
                                                     mailMessage.setTemplateId(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE +  cs.Status).Component_Id__c); 
                                                }
                                            }
                                    }
                                    else if(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE + cs.Status) != null)
                                    {
                                        mailMessage.setTemplateId(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE +  cs.Status).Component_Id__c);
                                    }
                                    else{
                                        continue;
                                    }
                                }
                                else if(cs.RecordTypeName__c == CON_CSM.S_DATACASE){
                                    if(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE + cs.Status) != null) {
                                        mailMessage.setTemplateId(getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + cs.RecordTypeId + CON_CSM.SPC_TILDE +  cs.Status).Component_Id__c);
                                    }
                                    else{
                                        continue;
                                    }
                                }
                                String senderId = '';
                                if(CON_PEP.S_PARTNER_PORTAL.equalsIgnoreCase(cs.Origin) && getCSMSettingData().get(CON_PEP.S_PARTNER_PORTAL) != null) {
                                    senderId = getCSMSettingData().get(CON_PEP.S_PARTNER_PORTAL).Component_Id__c;
                                }
                                if(CON_CSM.S_CUSTOMER_PORTAL.equalsIgnoreCase(cs.Origin) && getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL) != null) {
                                    senderId = getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL).Component_Id__c;
                                }
                                else if(CON_CSM.S_AGENT_INITIATED.equalsIgnoreCase(cs.Origin) && getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED) != null) {
                                    senderId = getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED).Component_Id__c;
                                }
                                if(senderId != null && senderId.length() > 0) {
                                    mailMessage.setOrgWideEmailAddressId(senderId);
                                }
                                mailMessage.setSaveAsActivity(false);
                                mailMessage.setTargetObjectId(cs.ContactId);
                                mailMessage.setTreatTargetObjectAsRecipient(false);
                                mailMessage.setToAddresses(toAddresses);
                                mailMessage.setWhatId(cs.Id);
                                mailMessage.setReferences(Cases.generateThreadingMessageId(cs.Id));
                                ccSendEmailList.add(mailMessage);                            
                            }
                            else if(hasCustomPermission == false)
                            {
                                cs.addError('Invalid Email Address Format In Mail CC List');
                            }
                        }
                    }
                }
            }
            
            if(ccSendEmailList != null && ccSendEmailList.size() > 0) {
                try{
                    Messaging.sendEmail(ccSendEmailList);
                }
                catch(Exception ex){
                    System.debug('Mail Exception: '+ex.getMessage());
                }
            }
            isCSMccEmailsHaveSent = true;
        }
    }
    
    /* Added by Saurabh */
    /**
    * This method is used to create a case for Data piller from OneKey web site
    * @params  newList List<Case> 
    * @return  void
    */
    public static boolean web2caseCreation(List<Case> newList) {
        String email = null,typeQueue = null,asset = null,currentQueue = null,currentQueueName = null,ownerId = null,OriginEmail = null;
        Contact con = null;
        List<Asset> asetList = new List<Asset>();
        for(Case c : newList){
            if(c.HCRSWebID__c != null && c.SuppliedEmail != null ){
                email = c.SuppliedEmail;
                typeQueue = c.HCRSWebID__c;
                c.Priority = 'Low';
                break;
            }
        }
        if(typeQueue != null){
            String[] onekeyType = typeQueue.split('~');
            if(!onekeyType.isEmpty() && onekeyType.size() >= 1){
                typeQueue = onekeyType[0];  
            }    
        }
        if(email != null && typeQueue != null && getCSMSettingData(typeQueue) != null && !getCSMSettingData(typeQueue).isEmpty()){
            if(getCSMSettingData(typeQueue).get(typeQueue+ '-Asset') != null) { 
                asset = getCSMSettingData(typeQueue).get(typeQueue+ '-Asset').Component_Id__c;
            }
            if(getCSMSettingData(typeQueue).get(typeQueue+ '-Queue') != null){
                currentQueue = getCSMSettingData(typeQueue).get(typeQueue+ '-Queue').Component_Id__c;  
                ownerId = getCSMSettingData(typeQueue).get(typeQueue+ '-Queue').Setting_Type__c;
                currentQueueName = getCSMSettingData(typeQueue).get(typeQueue+ '-Queue').Name;
                OriginEmail = getCSMSettingData(typeQueue).get(typeQueue+ '-Queue').Origin__c;
            } 
            
            try{
                con = new SLT_Contact().selectByEmailId(email);   
                if(con != null){
                   asetList = new SLT_Asset().selectByDataAccountId(new Set<Id>{con.AccountId},asset);
                }
            }catch(QueryException ex){
                
            }
            
            for(Case c : newList){
                if(con != null){
                    c.AccountId = con.AccountId;
                    c.ContactId = con.Id;
                    if(c.Status == null){
                        c.Status = CON_CSM.S_NEW;   
                    }
                    if(asetList != null && !asetList.isEmpty()){
                        c.AssetId = asetList[0].Id;
                        c.ProductName__c = asetList[0].Name;
                    }
                    
                }else{
                    c.NoContactKnown__c = true;
                }
                c.CaseOwnerModifiedDate__c = System.now();
                c.CaseUpdatedTime__c = System.now();
                c.Owner__c = ownerId;
                if(ownerId != null){
                    c.OwnerId = ownerId;
                }
                c.CSM_QI_Data_Originator__c = ownerId;
                c.CurrentQueue__c = currentQueue;
                c.InitialQueueData__c = currentQueue;
                c.InitialQueue__c = currentQueueName;
                c.CaseOriginatorName__c = currentQueueName;
                c.CaseOriginatorEmail__c = OriginEmail;
                c.SubType1__c = CON_CSM.S_DATAMGT;
                c.SubType2__c = CON_CSM.S_DATAISSUE;
                if(c.HCRSWebID__c.startsWith(CON_CSM.S_ORGANIZATIONS)){
                    c.SubType3__c = CON_CSM.S_LOOK_ORGANIZATION; 
                }else if(c.HCRSWebID__c.startsWith(CON_CSM.S_PROFESSIONALS)){
                    c.SubType3__c = CON_CSM.S_LOOK_PRESCRIBER;
                }
            }
            return true;
        }
        return false;
    }
    
    
    public static CSM_Create_Forms__c cloneForm(CSM_Create_Forms__c form, Case cs) {
        // Return null early if form is null
        if (form == null || cs == null) {
            return null;
        }
        
        // Clone the form and manually assign case ID
        CSM_Create_Forms__c newForm = form.clone(false, true); // Shallow clone (non-Id, with related fields set to null)
        
        newForm.Case__c = cs.Id; // Assign new case ID
        
        return newForm;
    }
    
    
    
    
    public static void cloneForms(List<Case> newList) {
        // Map to hold caseIds and the associated forms
        Map<Id, List<CSM_Create_Forms__c>> caseFormMap = new Map<Id, List<CSM_Create_Forms__c>>();
        List<CSM_Create_Forms__c> newForms = new List<CSM_Create_Forms__c>();
        
        // Collect all cloned case Ids
        Set<Id> cloneCaseIds = new Set<Id>();
        for (Case cs : newList) {
            if (cs.isClone() && cs.RecordTypeName__c == CON_CSM.S_DATACreateService ) {
                cloneCaseIds.add(cs.getCloneSourceId());
            }
        }
        
        // If we have any cloned case Ids, fetch associated forms in one query
        if (!cloneCaseIds.isEmpty()) {
            List<CSM_Create_Forms__c> cfs = Database.query('SELECT Action__c,Request_ID__c,ReportAction__c, Audit_Type__c, Form_Request_Type__c,MarketToCopyFrom__c, ReportNumber__c,ReportClientNumber__c,ReportClientNumber2__c, Product_Group_Name__c, Client_Number__c,File_Code_Market_Number__c,File_Code_Market_Description__c, Case__c FROM CSM_Create_Forms__c WHERE Case__c IN :cloneCaseIds'); 
                
            // Organize forms by caseId for quick lookup
            for (CSM_Create_Forms__c form : cfs) {
                if (!caseFormMap.containsKey(form.Case__c)) {
                    caseFormMap.put(form.Case__c, new List<CSM_Create_Forms__c>());
                }
                caseFormMap.get(form.Case__c).add(form);
            }
            
            
            // Now loop over the original case list and clone forms for those that are clones
            for (Case cs : newList) {
                if (cs.isClone() && cs.RecordTypeName__c == CON_CSM.S_DATACreateService && caseFormMap.containsKey(cs.getCloneSourceId())) {
                    List<CSM_Create_Forms__c> formsToClone = caseFormMap.get(cs.getCloneSourceId());
                    for (CSM_Create_Forms__c form : formsToClone) {
                        newForms.add(cloneForm(form, cs));
                    }
                }
            }
            
            // Insert the cloned forms outside the loop to minimize DML operations
            if (!newForms.isEmpty()) {
                insert newForms;
            }
        }
    }

    public static void cloneAttachments(List<Case> newList){
        // Create a set to hold the original case IDs that are being cloned
        Set<Id> originalCaseIds = new Set<Id>();
        map<id,id> mapOrginalCaseNewCase = new map<id,id>();
        // Map to store clone source case IDs and their new case IDs
        Map<Id, Id> caseCloneMap = new Map<Id, Id>();
        
        // Collect case clone source IDs
        for (Case cs : newList) {
            if (cs.isClone() && cs.RecordTypeName__c == CON_CSM.S_DATACreateService) {
                caseCloneMap.put(cs.getCloneSourceId(), cs.Id);
            }
        }
        if(!caseCloneMap.isEmpty()){
            Set<Id> caseCloneMapKeys = caseCloneMap.keySet();
            List<ContentDocumentLink> documentLinks =  Database.query('SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : caseCloneMapKeys');
            
            if(documentLinks!=null && !documentLinks.isEmpty()){
                // Map to store the cloned documents and their associated cases
                Map<Id, Id> clonedDocumentsMap = new Map<Id, Id>();
                
                // Iterate over the fetched document links
                for (ContentDocumentLink cdl : documentLinks) {
                    // Clone the document and store the new document ID for each new case
                    clonedDocumentsMap.put(cdl.ContentDocumentId, caseCloneMap.get(cdl.LinkedEntityId));
                }
                if (!clonedDocumentsMap.isEmpty()) {
                    for (Id key : clonedDocumentsMap.keySet()) {
                        cloneDocument(clonedDocumentsMap.get(key),key);
                    }
                }
            }
        }
    }
    
    public static void cloneDocument(Id caseId, Id contentDocumentId) {
        // Fetch the latest version of the content document
        ContentVersion originalVersion = Database.query('SELECT Id, Title, VersionData, PathOnClient FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId ORDER BY VersionNumber DESC LIMIT 1'); 
        
        if(originalVersion != null){
            // Create a new ContentVersion
            ContentVersion newVersion = new ContentVersion();
            newVersion.Title = originalVersion.Title; // Copy title
            newVersion.VersionData = originalVersion.VersionData; // Copy the file data
            newVersion.PathOnClient = originalVersion.PathOnClient; // Original file name
            
            // Insert the new version, which will create a new ContentDocument
            insert newVersion;
            
            // Query the newly created ContentVersion to get the ContentDocumentId
            newVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newVersion.Id LIMIT 1];
            
            // Create a new ContentDocumentLink to associate the new ContentDocument with the case
            ContentDocumentLink newLink = new ContentDocumentLink();
            newLink.ContentDocumentId = newVersion.ContentDocumentId; // The new ContentDocumentId
            newLink.LinkedEntityId = caseId; // Associate with the case
            newLink.ShareType = 'V'; // View permission
            
            // Insert the link
            insert newLink;
            
        }
    }
    
    /**
    * This method is used to create clone email from closed parent case. 
    * @params  newList List<Case> 
    * @return  void
    */
    public static void cloneEmailMessagefromParentforRDCase(List<Case> newList) {
        Map<Id,String> emailId = new Map<Id,String>();
        List<EmailMessage> emailList = new List<EmailMessage>(); 
        List<EmailMessage> cloneEmail = new List<EmailMessage>();
        EmailMessage clone=null;
        
        for(Case cs : newList){
            if(cs.Owner__c !=null && cs.Owner__c.startsWith('02s') && (cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                emailId.put(cs.Owner__c,cs.Id);
            }
        }
        if(!emailId.isEmpty()){
           emailList = new SLT_EmailMessage().selectById(emailId.keySet(),new Set<String>{'BccAddress','CcAddress','FromAddress','FromName','HasAttachment','Headers','HtmlBody','IsExternallyVisible','Incoming','MessageDate','ParentId','RelatedToId','Status','Subject','TextBody','ToAddress'}); 
            for(EmailMessage em : emailList){
                if(emailId.containsKey(em.Id)){
                    clone = em.clone();
                    clone.ParentId = emailId.get(em.Id); 
                    cloneEmail.add(clone);
                }
            }
            if(!cloneEmail.isEmpty()){
                isRndEmailCreatedFromCase = true;
                insert cloneEmail;
            }
            
        }
        
    }
    
    public static boolean isCaseUpdated = false;
    public static boolean isClosedCaseUpdatableTechno = false;
    public static void restrictClosedCaseModification(List<Case> caseList, Profile userProfile){
        String errorMessage = 'You can\'t update/modify the case fields when the status is ';
        Boolean isCaseFieldUpdatableForData = false;
        if(!isCaseUpdated){
            if(userProfile !=null && userProfile.Name != null && userProfile.Name != 'IQVIA Salesforce Platform Support' && !userProfile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)){
                Set<String> caseFieldSet = CON_CSM.DATA_IOF_CASEFIELD;
                if(caseFieldSet != null){
                    caseFieldSet.add('InformationOfferingFormId__c');
                }
                if(caseList != null && caseList.size()>0){
                    for(Case caseRecord : caseList){
                        Decimal timeDifference = Math.floor(Decimal.valueOf(caseRecord.LastModifiedDate.getTime() - caseRecord.CreatedDate.getTime())/(1000*60));
                        if(timeDifference >= 1){
                            if(caseRecord.Is_Parent__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).Is_Parent__c){
                                isCaseFieldUpdatableForData = true;
                                isClosedCaseUpdatableTechno = true;
                            }else if(caseRecord.RecordTypeName__c == CON_CSM.S_DATACASE){
                                List<String> listOfUpdatedFieldsForData = getUpdatedFieldsName();
                                if(listOfUpdatedFieldsForData != null && !listOfUpdatedFieldsForData.isEmpty() && listOfUpdatedFieldsForData.size() > 1 && caseRecord.Case_Type__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).Case_Type__c){
                                    errorMessage = 'You can only update/modify the Case Type when the status is ';
                                }else if(listOfUpdatedFieldsForData != null && !listOfUpdatedFieldsForData.isEmpty() && listOfUpdatedFieldsForData.size() == 1 && listOfUpdatedFieldsForData[0] == CON_CSM.S_Case_Type_C) {
                                    isCaseFieldUpdatableForData = true;
                                }else if(listOfUpdatedFieldsForData != null && !listOfUpdatedFieldsForData.isEmpty() && listOfUpdatedFieldsForData.size() >= 1 && caseRecord.InformationOfferingFormId__c  != ((Case)Trigger.oldMap.get(caseRecord.Id)).InformationOfferingFormId__c){
                                    isCaseFieldUpdatableForData = true;
                                }else if(listOfUpdatedFieldsForData != null && !listOfUpdatedFieldsForData.isEmpty() && listOfUpdatedFieldsForData.size() >= 1){
                                    for(String fieldName: caseFieldSet) {
                                        if(((Case)Trigger.oldMap.get(caseRecord.Id)).get(fieldName) != caseRecord.get(fieldName)){
                                            isCaseFieldUpdatableForData = true;
                                        } 
                                            
                                    }
                                }
                            }else if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || caseRecord.RecordTypeName__c == CON_CSM.S_R_D_CTP || caseRecord.RecordTypeName__c == CON_CSM.S_R_D_CDP || caseRecord.RecordTypeName__c == CON_CSM.S_R_D_V_T || caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE){
                                List<String> lstOfUpdFieldsRD = getUpdatedFieldsName();
                                if(lstOfUpdFieldsRD != null && !lstOfUpdFieldsRD.isEmpty() && lstOfUpdFieldsRD.size() >= 1) {
                                    if((caseRecord.SLA_FCR_Reviewed_By__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).SLA_FCR_Reviewed_By__c || caseRecord.FCR_Escalation_Comment__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).FCR_Escalation_Comment__c || caseRecord.SLA_IRT_Reviewed_By__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).SLA_IRT_Reviewed_By__c || caseRecord.CSAT_Reviewed_by__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).CSAT_Reviewed_by__c || caseRecord.SLA_IRT_Reviewed__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).SLA_IRT_Reviewed__c || caseRecord.FCR_Review_Escalation__c != ((Case)Trigger.oldMap.get(caseRecord.Id)).FCR_Review_Escalation__c)){
                                    //if((lstOfUpdFieldsRD.containsIgnoreCase('SLA_FCR_Reviewed_By__c') || lstOfUpdFieldsRD.containsIgnoreCase('FCR_Escalation_Comment__c') || lstOfUpdFieldsRD.containsIgnoreCase('SLA_IRT_Reviewed_By__c') || lstOfUpdFieldsRD.containsIgnoreCase('SLA_IRT_Reviewed__c') || lstOfUpdFieldsRD.containsIgnoreCase('FCR_Review_Escalation__c'))){
                                        isCaseFieldUpdatableForData = true;
                                    }else{
                                        isCaseFieldUpdatableForData = false;
                                    }
                                }
                            }
                            if(!isCaseFieldUpdatableForData && !isClosedCaseUpdatableTechno) {
                                if(caseRecord.Status == ((Case)Trigger.oldMap.get(caseRecord.Id)).Status){
                                    if(hasCustomPermission == false && (caseRecord.Status == CON_CSM.S_CASE_CLOSED || caseRecord.Status == CON_CSM.S_CASE_CANCELED || caseRecord.Status == CON_CSM.S_CASE_ABANDONED)){
                                        caseRecord.addError(errorMessage+caseRecord.Status);
                                    }
                                }else if(caseRecord.Status != ((Case)Trigger.oldMap.get(caseRecord.Id)).Status){
                                    if(hasCustomPermission == false && (caseRecord.Status == CON_CSM.S_CASE_CLOSED || caseRecord.Status == CON_CSM.S_CASE_CANCELED || caseRecord.Status == CON_CSM.S_CASE_ABANDONED) && (((Case)Trigger.oldMap.get(caseRecord.Id)).Status == CON_CSM.S_CASE_CLOSED || ((Case)Trigger.oldMap.get(caseRecord.Id)).Status == CON_CSM.S_CASE_CANCELED || ((Case)Trigger.oldMap.get(caseRecord.Id)).Status == CON_CSM.S_CASE_ABANDONED)){
                                        caseRecord.addError(errorMessage+((Case)Trigger.oldMap.get(caseRecord.Id)).Status);
                                    }
                                }     
                            }  
                        }
                    }
                }
            }
            isCaseUpdated = true;
        }
    }
    
    /**
    * This method is used to get list of all updated fields
    * @return  List<String>
    */
    private static List<String> getUpdatedFieldsName() {
        Case updatedCase = (Case)trigger.new[0]; 
        Case oldCase = (Case)trigger.old[0]; 
        List<String> listOfUpdatedFields = new List<String>();
        Map<String, Schema.SObjectField> caseFieldsMap = Schema.SObjectType.Case.fields.getMap();
        for (String fieldName : caseFieldsMap.keyset()) {
            try {
                if(updatedCase.get(fieldName) != oldCase.get(fieldName) ) {
                    listOfUpdatedFields.add(fieldName);
                }
            } 
            catch (Exception e) {
                
            } 
        } 
        return listOfUpdatedFields;
    }
    
    /**
    * This method is used to queue history how much time the case is in that queue
    * @params  newList List<Case> 
    * @return  void
    */
    public static void saveQueueCaseHistory(List<Case> newList, Map<Id, Case> oldMap){
        Set<Id> userOwnerIds = new Set<Id>();
        Set<Id> userOldOwnerIds = new Set<Id>();
        Set<Id> groupOwnerIds = new Set<Id>();
        Set<Id> groupOldOwnerIds = new Set<Id>();
        CSM_Case_Owner_Status_SubStatus_History__c coh = null;
        List<CSM_Case_Owner_Status_SubStatus_History__c> cohList = new List<CSM_Case_Owner_Status_SubStatus_History__c>();
        CaseHistory__c hist = null;
        List<CaseHistory__c> historyList = new List<CaseHistory__c>();
        List<User> caseUser = new List<User>();
        List<User> oldCaseUser = new List<User>();
        List<Group> caseGroup = new List<Group>();
        List<Group> oldCaseGroup = new List<Group>();
        Long milliseconds;
        Datetime oldTime = null,newTime = null;
        String changeType = '';
        for(Case cs : newList){
            if(cs.CurrentQueue__c != null){
                changeType = '';
                if(cs.CaseOwnerModifiedDate__c != null && oldMap.get(cs.Id).CaseOwnerModifiedDate__c != null && (oldMap.get(cs.Id).CurrentQueue__c == null || cs.CurrentQueue__c != oldMap.get(cs.Id).CurrentQueue__c || cs.OwnerId != oldMap.get(cs.Id).OwnerId)){
                    newTime = (DateTime)cs.CaseOwnerModifiedDate__c;
                    oldTime = (DateTime)oldMap.get(cs.Id).CaseOwnerModifiedDate__c;
                    changeType = 'Owner';
                }
                if(cs.CaseUpdatedTime__c != null && oldMap.get(cs.Id).CaseUpdatedTime__c != null && (cs.Status != oldMap.get(cs.Id).Status || cs.SubStatus__c != oldMap.get(cs.Id).SubStatus__c)){
                    newTime = (DateTime)cs.CaseUpdatedTime__c;
                    oldTime = (DateTime)oldMap.get(cs.Id).CaseUpdatedTime__c;
                    if(changeType != null && changeType.length()>0) {
                        changeType += 'and Status/SubStatus';
                    }else{
                        changeType += 'Status/SubStatus';
                    }
                }
                if(newTime != null && oldTime != null && (newTime.getTime() - oldTime.getTime()) > 0){
                    if(String.valueOf(cs.OwnerId).startsWith(CON_CSM.S_USER_ID)){
                        userOwnerIds.add(cs.OwnerId);
                    }
                    if(String.valueOf(cs.OwnerId).startsWith(CON_CSM.S_QUEUE_ID)){
                        groupOwnerIds.add(cs.OwnerId);
                    }
                    if(String.valueOf(oldMap.get(cs.Id).OwnerId).startsWith(CON_CSM.S_USER_ID)){
                        userOldOwnerIds.add(oldMap.get(cs.Id).OwnerId);    
                    }
                    if(String.valueOf(oldMap.get(cs.Id).OwnerId).startsWith(CON_CSM.S_QUEUE_ID)){
                        groupOldOwnerIds.add(oldMap.get(cs.Id).OwnerId);    
                    }
                }
            }
        }
        if(userOwnerIds != null && !userOwnerIds.isEmpty()){
            caseUser = new SLT_User().selectById(userOwnerIds);    
        }
        if(userOldOwnerIds != null && !userOldOwnerIds.isEmpty()){
            oldCaseUser = new SLT_User().selectById(userOldOwnerIds);
        }
        if(groupOwnerIds != null && !groupOwnerIds.isEmpty()){
            caseGroup = new SLT_Groups().selectById(groupOwnerIds);    
        }
        if(groupOldOwnerIds != null && !groupOldOwnerIds.isEmpty()){
            oldCaseGroup = new SLT_Groups().selectById(groupOldOwnerIds);
        }
        for(Case cs : newList){
            if(cs.CurrentQueue__c != null){
                if(newTime != null && oldTime != null && changeType != null){
                    if(changeType.contains('Owner') && changeType.contains('Status/SubStatus')){
                        hist = new CaseHistory__c(Case__c = cs.Id, NewCurrentQueue__c = cs.CurrentQueue__c, OldCurrentQueue__c = oldMap.get(cs.Id).CurrentQueue__c, DateTimeofchange__c = cs.CaseOwnerModifiedDate__c);
                        coh = new CSM_Case_Owner_Status_SubStatus_History__c(Case__c = cs.Id, NewCurrentQueue__c = cs.CurrentQueue__c, OldCurrentQueue__c = oldMap.get(cs.Id).CurrentQueue__c,  NewCaseStatus__c = cs.Status, NewCaseSubStatus__c = cs.SubStatus__c, OldCaseStatus__c = oldMap.get(cs.Id).Status, OldCaseSubstatus__c = oldMap.get(cs.Id).SubStatus__c,ChangeType__c = 'Owner;Status;Substatus');
                    }else if(!changeType.contains('Owner') && changeType.contains('Status/SubStatus')){
                        coh = new CSM_Case_Owner_Status_SubStatus_History__c(Case__c = cs.Id, NewCaseStatus__c = cs.Status, NewCaseSubStatus__c = cs.SubStatus__c, OldCaseStatus__c = oldMap.get(cs.Id).Status, OldCaseSubstatus__c = oldMap.get(cs.Id).SubStatus__c);
                        if(cs.Status != oldMap.get(cs.Id).Status && cs.SubStatus__c != oldMap.get(cs.Id).SubStatus__c){
                            coh.ChangeType__c = 'Status;Substatus';
                        }else if(cs.Status != oldMap.get(cs.Id).Status){
                            coh.ChangeType__c = 'Status';
                        }else if(cs.SubStatus__c != oldMap.get(cs.Id).SubStatus__c){
                            coh.ChangeType__c = 'Substatus';
                        }
                    }else if(changeType.contains('Owner') && !changeType.contains('Status/SubStatus')){
                        coh = new CSM_Case_Owner_Status_SubStatus_History__c(Case__c = cs.Id, NewCurrentQueue__c = cs.CurrentQueue__c, OldCurrentQueue__c = oldMap.get(cs.Id).CurrentQueue__c, ChangeType__c = 'Owner');
                        hist = new CaseHistory__c(Case__c = cs.Id, NewCurrentQueue__c = cs.CurrentQueue__c, OldCurrentQueue__c = oldMap.get(cs.Id).CurrentQueue__c, DateTimeofchange__c = cs.CaseOwnerModifiedDate__c);
                    }
                    if(cs.BusinessHoursId != null){
                        milliseconds = BusinessHours.diff(String.valueOf(cs.BusinessHoursId), oldTime, newTime);
                        if(milliseconds > 0){
                            if(hist != null){ hist.NoofBusinesssincelastchange__c = milliseconds /(1000*60); } 
                            if(coh != null) {coh.NoofBusinesssincelastchange__c = milliseconds /(1000*60);}
                        }
                    }
                    milliseconds = newTime.getTime() - oldTime.getTime();
                    if(milliseconds > 0){
                        if(hist != null) {hist.No_of_hours_since_last_owner_change__c = milliseconds /(1000*60);}
                        if(coh != null) {coh.No_of_hours_since_last_owner_change__c = milliseconds /(1000*60);}
                    }
                    if(hist != null) {hist.NewOwnerType__c = string.valueOf(cs.OwnerId).startsWith(CON_CSM.S_QUEUE_ID) ? 'Queue' : 'User';}
                    if(hist != null) {hist.OldOwnerType__c = string.valueOf(oldMap.get(cs.Id).OwnerId).startsWith(CON_CSM.S_QUEUE_ID) ? 'Queue' : 'User';}
                    if(coh != null) {coh.NewOwnerType__c = string.valueOf(cs.OwnerId).startsWith(CON_CSM.S_QUEUE_ID) ? 'Queue' : 'User'; }
                    if(coh != null) {coh.OldOwnerType__c = string.valueOf(oldMap.get(cs.Id).OwnerId).startsWith(CON_CSM.S_QUEUE_ID) ? 'Queue' : 'User';}
                    if(hist != null) {hist.UserWhomadethechange__c = UserInfo.getUserId();}
                    if(caseUser != null && !caseUser.isEmpty()){
                        for(User us : caseUser){
                            if(cs.OwnerId.equals(us.Id)){
                                if(hist != null) {hist.NewCaseOwner__c = us.Name;hist.NewCaseOwnerId__c = us.Id;}
                                if(coh != null) {coh.NewCaseOwner__c = us.Name;coh.NewCaseOwnerId__c = us.Id;}
                            }   
                        }
                    }
                    if(caseGroup != null && !caseGroup.isEmpty()){
                        for(Group grp : caseGroup){
                            if(cs.OwnerId.equals(grp.Id)){
                                if(hist != null) {hist.NewCaseOwner__c = grp.Name;}
                                if(coh != null) {coh.NewCaseOwner__c = grp.Name;}
                            }   
                        }
                    }
                    if(oldCaseUser != null && !oldCaseUser.isEmpty()){
                        for(User ous : oldCaseUser){
                            if(oldMap.get(cs.Id).OwnerId.equals(ous.Id)){
                                if(hist != null) {hist.OldCaseOwner__c = ous.Name;hist.OldCaseOwnerId__c = ous.Id;}
                                if(coh != null) {coh.OldCaseOwner__c = ous.Name;coh.OldCaseOwnerId__c = ous.Id;}
                            }   
                        }
                    }
                    if(oldCaseGroup != null && !oldCaseGroup.isEmpty()){
                        for(Group oldGrp : oldCaseGroup){
                            if(oldMap.get(cs.Id).OwnerId.equals(oldGrp.Id)){
                                if(hist != null) {hist.OldCaseOwner__c = oldGrp.Name;}
                                if(coh != null) {coh.OldCaseOwner__c = oldGrp.Name;}
                            }   
                        }
                    }
                    
                    if(hist != null) {historyList.add(hist);}
                    if(coh != null) {cohList.add(coh);}
                }
            }
        }
        if(!historyList.isEmpty()){
            try{
                insert historyList;
            }catch(DmlException e){
                System.debug('Failed due to : '+e);
            }
        }
        
        if(!cohList.isEmpty()){
            try{
                insert cohList;
            }catch(DmlException e){
                System.debug('Failed due to : '+e);
            }
        }
    }
    
    
    /**
    * This method is used to queue history how much time the case is in that queue
    * @params  newList List<Case> 
    * @return  void
    */
    public static void saveOLACase(List<Case> newList, Map<Id, Case> oldMap){
        String bhId = null,tZone = null; 
        Datetime now = System.now();
        Set<Id> qIds = new Set<Id>();
        Map<Id,String> priIds = new Map<Id,String>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id,Id> groupMap = new Map<Id,Id>();
        Map<Id,String> caseRTNames = new Map<Id,String>();
        Boolean hasCP = FeatureManagement.checkPermission('CSM_OLA_Internal_Response_Time');
        CaseOLA__c ola = null;
        List<CaseOLA__c> olaList = new List<CaseOLA__c>();
        List<Queue_User_Relationship__c> queue = new List<Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> queueOld = new List<Queue_User_Relationship__c>();
        Long ms;
        /** BusinessHours bhSoql = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey from BusinessHours where IsActive = true and Name = 'Default' and IsDefault = true];*/
        Map<String, CaseOLASettings__c> olaS = CNT_CSM_TechnoCaseOLA.getCSMSettingData();
        if(Trigger.isUpdate){
            for(Case c : newList){
                if((CON_CSM.S_TECHNO_SOL == c.RecordTypeName__c || (hasCP && CON_CSM.S_DATACASE == c.RecordTypeName__c)) && c.CurrentQueue__c != null && oldMap != null && oldMap.get(c.Id).CurrentQueue__c != null && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c){
                    qIds.add(c.CurrentQueue__c);
                    qIds.add(oldMap.get(c.Id).CurrentQueue__c);
                }
                if(c.Priority != oldMap.get(c.Id).Priority){
                    priIds.put(c.Id,c.Priority);
                }
            }
            if(!qIds.isEmpty()){
                queue = new SLT_QueueUserRelationshipC().selectByQueueIdSet(qIds, new Set<String>{'Name','Id','Group_Id__c','Business_Hours__c','Business_Hours__r.TimeZoneSidKey'}); 
                Set<Id> ids = new Set<Id>();
                for(Queue_User_Relationship__c q : queue){
                    ids.add(q.Group_Id__c);
                    groupMap.put(q.Id,q.Group_Id__c);
                }
                for(Case c : newList){
                    if((CON_CSM.S_TECHNO_SOL == c.RecordTypeName__c || (hasCP && CON_CSM.S_DATACASE == c.RecordTypeName__c)) && c.CurrentQueue__c != null && oldMap != null && oldMap.get(c.Id).CurrentQueue__c != null && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c
                       && groupMap.get(c.CurrentQueue__c) != groupMap.get(oldMap.get(c.Id).CurrentQueue__c)){
                           caseIds.add(c.Id);
                           caseRTNames.put(c.Id, c.RecordTypeName__c);
                       }    
                }
                if(ids != null && !ids.isEmpty()){
                    queueOld = new SLT_QueueUserRelationshipC().selectByUserGrop(ids);     
                }
            }
            
            if(!caseIds.isEmpty()){
                List<CaseOLA__c> upOla = Database.query('SELECT Id,Case__c,IsActive__c,CreatedDate,Priority__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c From CaseOLA__c Where Case__c in :caseIds and IsActive__c = true'); 
                if(upOla != null){
                    for(CaseOLA__c u : upOla){
                        u.IsActive__c = false;
                        if(u.CompletionOLADate__c == null){
                            bHId =  bhSoql.Id;
                            for(Queue_User_Relationship__c q : queueOld){
                                if(q.Name == u.Current_Queue__c){
                                    if(q.Business_Hours__c != null){
                                        bHId = String.valueOf(q.Business_Hours__c);
                                    }else{
                                        bHId =  bhSoql.Id;
                                    }
                                    break;
                                }
                            }
                            ms = BusinessHours.diff(bHId, ((DateTime)u.CreatedDate), now);
                            if(ms > 0){
                                u.Elapsed_OLA_Time__c = ms /(1000*60);
                            }
                            u.CompletionOLADate__c = now;
                            if(caseRTNames.containsKey(u.Case__c) && olaS.containsKey(caseRTNames.get(u.Case__c) + ' ' + u.Priority__c)){
                                decimal targetM = olaS.get(caseRTNames.get(u.Case__c) + ' ' + u.Priority__c).Target_Time__c;
                                if(targetM > (ms/60000)){
                                    u.CompletionOLADate__c = now;
                                    u.OLAEndDate__c = now;
                                }else{
                                    u.StandardOLAviolated__c = true;
                                    u.CompletionOLADate__c = now;
                                    u.OLAEndDate__c = now;
                                }
                            }
                        }
                        olaList.add(u);
                    }
                }
                if(!olaList.isEmpty()){
                    update olaList; 
                }
            }else if(!priIds.isEmpty()){
                Set<Id> caseId = priIds.keySet();
                if(caseId != null){
                    List<CaseOLA__c> upOla = Database.query('SELECT Id,Case__c,IsActive__c,CreatedDate,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c From CaseOLA__c Where Case__c in :caseId and IsActive__c = true');
                    for(CaseOLA__c o : upOla){
                        if(priIds.containsKey(o.Case__c)){
                            o.Priority__c = priIds.get(o.Case__c);
                            olaList.add(o);
                        }
                    }
                    if(!olaList.isEmpty()){
                        update olaList; 
                    }
                }
            }
            if(!olaList.isEmpty()){
                olaList.clear();
                bHId = null;
            }
        }
        for(Case c : newList){
            if(c.CurrentQueue__c != null && (CON_CSM.S_TECHNO_SOL == c.RecordTypeName__c || (hasCP && CON_CSM.S_DATACASE == c.RecordTypeName__c)) && ((Trigger.isInsert && c.Origin == CON_CSM.S_O_ES )|| (Trigger.isUpdate && oldMap != null && oldMap.get(c.Id).CurrentQueue__c != null 
              && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c && groupMap.get(c.CurrentQueue__c) != groupMap.get(oldMap.get(c.Id).CurrentQueue__c)))){
                ola = new CaseOLA__c(IsActive__c = true, Case__c = c.Id,Priority__c = c.Priority);
                if(oldMap != null){
                   ola.Previous_Queue__c = oldMap.get(c.Id).CurrentQueue__c; 
                }
                for(Queue_User_Relationship__c q : queue){
                    if(q.Id == c.CurrentQueue__c ){
                        ola.Current_Queue__c = q.Name;
                    }else if(oldMap != null && q.Id == oldMap.get(c.Id).CurrentQueue__c){
                        ola.Previous_Queue__c = q.Name;
                    }
                }
                  if(Trigger.isInsert){
                      bHId =  bhSoql.Id;
                      tZone = bhSoql.TimeZoneSidKey;
                      ola.Current_Queue__c = c.InitialQueue__c;
                  }
                for(Queue_User_Relationship__c q : queueOld){
                    if(q.Name == ola.Current_Queue__c){
                        if(q.Business_Hours__c != null){
                            bHId = String.valueOf(q.Business_Hours__c);
                            tZone = q.Business_Hours__r.TimeZoneSidKey;
                        }else{
                            bHId =  bhSoql.Id;
                            tZone = bhSoql.TimeZoneSidKey;
                        }
                        break;
                    }
                }
                  if(bHId == null){
                      bHId =  bhSoql.Id;
                      tZone = bhSoql.TimeZoneSidKey; 
                  }
                decimal targetM = olaS.containsKey(c.RecordTypeName__c + ' OLA') ? olaS.get(c.RecordTypeName__c + ' OLA').Target_Time__c : 1440;
                ola.OLAEndDate__c = BusinessHours.addGmt(bHId, now, Integer.valueOf(targetM)*1000*60);
                olaList.add(ola);
            }    
        } 
        if(!olaList.isEmpty()){
            try{
               insert olaList;
            }catch(DmlException e){
                System.debug('Failed due to : '+e);
            }
        }
    }
    
    public static void updatePreviousQueue(List<Case> newList, Map<Id,Case> oldMap) {
        Set<Id> ids = new Set<Id>();
        for(Case c : newList){
            if((CON_CSM.S_TECHNO_SOL == c.RecordTypeName__c || CON_CSM.S_DATACASE == c.RecordTypeName__c) && c.CurrentQueue__c != null && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c){
                ids.add(oldMap.get(c.Id).CurrentQueue__c);
                ids.add(c.CurrentQueue__c);
            }
        }
        
        Map<Id, Queue_User_Relationship__c> queueMap = new SLT_QueueUserRelationshipC().selectByQueueId(ids, new Set<String> {'Id','Name'});
        
        if(queueMap != null && !queueMap.isEmpty()){
            for(Case c : newList){
                if(queueMap.containsKey(oldMap.get(c.Id).CurrentQueue__c) && 
                   queueMap.get(oldMap.get(c.Id).CurrentQueue__c) != null && queueMap.containsKey(c.CurrentQueue__c) && 
                   queueMap.get(c.CurrentQueue__c) != null && queueMap.get(oldMap.get(c.Id).CurrentQueue__c).Name != queueMap.get(c.CurrentQueue__c).Name){
                    c.OLA_DispatchDate__c = System.now();
                    c.PreviousQueue__c = queueMap.get(oldMap.get(c.Id).CurrentQueue__c).Name;
                }
            }
        }
    }
    
    /**
    * This method is used to update Contact fields in Case fields
    * @params  newList List<Case> 
    * @return  void
    */
    public static void setContactTitle(List<Case> newList) {
        Set<Id> idSet = new Set<Id>();
        for(Case c : newList) {
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.ContactId != null) {
                idSet.add(c.ContactId);
            }
        }
        if(idSet != null && !idSet.isEmpty()){
            Map<id,Contact> contactMap = new SLT_Contact().selectByContactId(idSet, new Set<String>{CON_CSM.S_CONTACT_TITLE});
            for(Case c : newList){
                if(contactMap.containsKey(c.ContactId)) {
                   c.Contact_Title__c = contactMap.get(c.ContactId).Contact_User_Type__c;
                }
            }
        }
           
    }
    
    /**
    * This method is used to update send a callender event to Current user 
    * when the status changed to Waiting for and Substatus changed to Schedule for Techno piller
    * @params  newList List<Case> 
    * @return  void
    */
    public static void SetCalendarEvent(List<Case> newList, Map<Id,Case> oldMap){
        String subject = '';
        DateTime scheduledDate = null ;
        String caseID;
        for(Case c : newList) {
            if(c.ScheduledDatetime__c != null && c.SubStatus__c != null && c.SubStatus__c == CON_CSM.S_SUBSTATUS_VALUE && (c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || CON_CSM.S_DATACASE == c.RecordTypeName__c)){

                if(oldMap != null && oldMap.get(c.Id) != null && (c.SubStatus__c != oldMap.get(c.Id).SubStatus__c || c.ScheduledDatetime__c != oldMap.get(c.Id).ScheduledDatetime__c)) {
                    subject = c.CaseNumber+'-'+ c.Subject+'-'+c.Account_Name_Article__c;
                    scheduledDate = c.ScheduledDatetime__c;
                }else if(oldMap == null && c.SubStatus__c  != null && c.SubStatus__c == CON_CSM.S_SUBSTATUS_VALUE && (c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || CON_CSM.S_DATACASE == c.RecordTypeName__c)) {

                    subject = c.CaseNumber+'-'+ c.Subject+'-'+c.Account_Name_Article__c;
                    scheduledDate = c.ScheduledDatetime__c;
                }
                caseID = c.id;
            }
        }
        if(!EXT_CSM_Validator_Cls.hasAlreadyDone()){
            if(subject !='' && scheduledDate!=Null ) {
                Blob fileBody = EXT_CSM_CalendarEvent.ext_GenerateEvent(UserInfo.getUserEmail(), subject, 'description', scheduledDate, scheduledDate, subject, 0);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(UserInfo.getUserId());
                List<EmailTemplate> emailTemp=[Select id,Body  from EmailTemplate where Name=:CON_CSM.S_CASE_CALENDAR_TEMPLATE];
                if(emailTemp.size()>0){
                   mail = Messaging.renderStoredEmailTemplate(emailTemp[0].id,UserInfo.getUserId(),caseID );
                }
                else{
                    mail.setPlainTextBody(System.Label.TextForCalendarMail);
                }
                mail.setWhatId(caseID);
                mail.setSaveAsActivity(false);
                mail.setSubject(subject);
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.filename = 'invite.ics';
                attach.ContentType = 'text/calendar; charset=utf-8; method=REQUEST;';
                attach.inline = true;
                attach.body = fileBody;
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                Messaging.sendEmail(new Messaging.Email[] {mail});
                EXT_CSM_Validator_Cls.setAlreadyDone();           
            }
        }
    }
    
    /** public static void setFirstEscalationTimeField(List<Case> caseList){
        for(Case c : caseList){
            if(c.IsEscalated){
                if(c.FirstEscalationDateTime__c == null){
                    c.FirstEscalationDateTime__c = System.now();
                }
                if(c.First_Escalation_Time__c == null && c.RecordTypeName__c ==  CON_CSM.S_TECHNOLOGY_R_T){
                    c.First_Escalation_Time__c = (Datetime.now().getTime() - c.CreatedDate.getTime())/(60*1000);
                }
                if(c.First_Escalated_By__c == null){
                    c.First_Escalated_By__c = UserInfo.getUserId();
                }
            }
        }
    }*/
    
    public static void validQuickAction(List<Case> records,Map<Id,Case> oldMap){
        
        for (Case c : records){
            boolean check = false;
            if (c.getQuickActionName() == 'Case.Macros_Only' || Test.isRunningTest()){
                    if (hasCustomPermission == false && c.AccountId != null && c.getQuickActionName() == 'Case.Macros_Only' && (c.ProductName__c == null || c.SubType1__c == null || c.SubType2__c == null || c.SubType3__c == null)){
                        c.addError('Case Categorization fields are mandatory or Asset not associate with account.');
                        check = true;
                    }
                    if(!check){
                        List<CSM_QI_Case_Categorization__c> categorizations = new List<CSM_QI_Case_Categorization__c>();
                        if(c.ProductName__c != null && c.SubType1__c != null && c.SubType2__c != null){
                            List<String> subType3Values = new List<String>();
                            if (c.SubType3__c != null) {
                                subType3Values.add(c.SubType3__c);
                            }
                            subType3Values.add('--none--');
                            categorizations = [SELECT Id, Product__c, ProductName__c, SubType1__c, SubType2__c, SubType3__c, CaseType__c FROM CSM_QI_Case_Categorization__c WHERE Product__r.Name= :c.ProductName__c AND SubType1__c= :c.SubType1__c AND SubType2__c= :c.SubType2__c AND SubType3__c IN :subType3Values ORDER BY SubType3__c DESC];
                        }
                        
                        List<Asset> assets = new List<Asset>();  
                        if(!categorizations.isEmpty()){
                            assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {c.AccountId},new Set<Id>{categorizations[0].Product__c});
                            if(assets.size() > 0 && assets[0].Status !='Obsolete'){
                                c.AssetId=assets[0].Id;
                                c.Case_CategorizationId__c = categorizations[0].Id;
                                c.ProductName__c = categorizations[0].ProductName__c;
                                c.SubType1__c = categorizations[0].SubType1__c;
                                c.SubType2__c = categorizations[0].SubType2__c;
                                c.SubType3__c = categorizations[0].SubType3__c;
                                if(categorizations[0].CaseType__c != null){
                                    c.Case_Type__c = categorizations[0].CaseType__c; 
                                }
                            }else if(hasCustomPermission == false && c.ProductName__c != null && c.AccountId != null && c.AccountId == oldMap.get(c.Id).AccountId){
                                c.addError('The asset does not exist or is obsolete.');
                            }
                        }else if(hasCustomPermission == false && c.ProductName__c != null && c.AccountId != null && c.AccountId == oldMap.get(c.Id).AccountId){
                            c.addError('Wrong categorization.');
                        }
                    }
                }
        }
    }

    public static boolean isStoppedCheckboxTicked = true;
    public static void tickStoppedCheckboxToPauseEntitlement(List<Case> caseList,Map<Id,Account> accountMDMs){
        if(isStoppedCheckboxTicked){
            for(Case c : caseList){
                if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && ((c.External_vendor__c && c.AccountId != null && accountMDMs != null && !accountMDMs.isEmpty() && accountMDMs.containsKey(c.AccountId) && accountMDMs.get(c.AccountId).MDMID__c == CON_CSM.S_ROCH_SWLD) || (CON_CSM.S_AWAITING == c.Status && c.SubStatus__c != null && CON_CSM.S_AWAITING_SUB.contains(c.SubStatus__c)))){
                    c.IsStopped = true;
                }else if(c.Status != null && c.RecordTypeName__c != CON_CSM.S_ACTIVITY_R_T){
                    if(((c.External_vendor__c && c.AccountId != null && accountMDMs != null && !accountMDMs.isEmpty() && accountMDMs.containsKey(c.AccountId) && accountMDMs.get(c.AccountId).MDMID__c == CON_CSM.S_ROCH_SWLD) || (CON_CSM.S_RESOLVED_WITH_C == c.Status && CON_CSM.S_RCA != c.SubStatus__c) || CON_CSM.S_CLOSED == c.Status || CON_CSM.S_WORKORDER == c.SubStatus__c || CON_CSM.S_WAITING_FOR == c.Status)){
                        c.IsStopped = true;
                    }
                    else{
                        c.IsStopped = false;
                    }
                }
            }
          isStoppedCheckboxTicked = false;
        }
    }
    
    public static void sendAutomatedFollowUp(List<Case> listOfCases){
        if(listOfCases != null && listOfCases.Size() > 0){
            List<Case> autoFu = new List<Case>();
            Set<String> contactIds = new Set<String>();
            List<Contact> contactPreferred = new List<Contact>();
            Map<Id,String> conLanguage = new Map<Id,String>();
            for(Case objCase : listOfCases){
                if(objCase.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && objCase.AFU_TECH__c && objCase.AFU_Email_Flag__c){
                    autoFu.add(objCase);
                    contactIds.add(objCase.ContactId);
                }
            }
            if(contactIds != null && !contactIds.isEmpty()){
                contactPreferred = Database.query('SELECT Id, PreferredLanguage__c, Email FROM Contact WHERE Id IN :contactIds AND PreferredLanguage__c != null');
            }
            if(contactPreferred != null && !contactPreferred.isEmpty()){
                for(Contact c : contactPreferred){
                    conLanguage.put(c.id,c.PreferredLanguage__c);
                }
            }
            if(autoFu != null && !autoFu.isEmpty()){
                List<CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c> AFUTemplates = CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c.getAll().values();
                List<id> ids = new List<id>();
                for(CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c cs : AFUTemplates){
                    ids.add(cs.AFU_No_Response_TemplateID__c);
                    ids.add(cs.AFU_Follow_Up_TemplateID__c);
                }
                
                Map<Id,EmailTemplate> mapOfEmailTemplate = new Map<Id,EmailTemplate>();
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                String fromEmail = '';
                List<EmailTemplate> listOfEmailTemplate = [SELECT Id, DeveloperName FROM EmailTemplate WHERE Id IN :ids];
                CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c csAFUTemplates;
                for(Case objCase : autoFu){
                    if(listOfEmailTemplate != null && listOfEmailTemplate.Size() > 0){
                        for(EmailTemplate objEM : listOfEmailTemplate){
                            if(conLanguage != null && conLanguage.containsKey(objCase.ContactId)){
                                csAFUTemplates = CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c.getValues(conLanguage.get(objCase.ContactId).toUpperCase());
                            }
                            if(csAFUTemplates == null){
                                csAFUTemplates= CSM_AFU_MULTIPLE_LANGUAGE_EMAIL_TEMPLATE__c.getValues('EN');
                            }
                            String templateId = objCase.Count_of_AFU__c == 4 ? csAFUTemplates.AFU_No_Response_TemplateID__c : csAFUTemplates.AFU_Follow_Up_TemplateID__c;
                            if(objEM.Id == templateId){
                                mapOfEmailTemplate.put(objCase.Id, objEM);
                            }                
                        }
                    }                
                }
                Map<String, Id> mapOfOrgWideEmails = getOrgWideEmailId();
                CSM_AFU_DEFAULT_EMAIL__c csdefaultEmail = CSM_AFU_DEFAULT_EMAIL__c.getOrgdefaults();    
                for(Case objCase : autoFu){
                    if(mapOfEmailTemplate != null && mapOfEmailTemplate.Size()>0){
                        fromEmail = String.isBlank(objCase.From_emailtocase__c) ? csdefaultEmail.Default_AFU_Email__c : objCase.From_emailtocase__c;                                            
                        EmailTemplate objTemplate = mapOfEmailTemplate.get(objCase.Id);
                        Id orgWideEmailID = null;
                        if(mapOfOrgWideEmails.size() > 0 && mapOfOrgWideEmails != null){
                            orgWideEmailID = mapOfOrgWideEmails.get(fromEmail);
                        }
                        if(objCase.Count_of_AFU__c != null && objCase.ContactEmail != null){
                            if(objCase.Count_of_AFU__c == 4){
                                objCase.AFU_TECH__c = FALSE;
                            }
                            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                            mail.setTemplateId(objTemplate.Id);
                            mail.setReplyTo(fromEmail);
                            mail.setSaveAsActivity(FALSE);
                            mail.setTargetObjectId(objCase.ContactId);
                            mail.setWhatId(objCase.Id);
                            mail.setReferences(Cases.generateThreadingMessageId(objCase.Id));
                            if(orgWideEmailID != null){
                                mail.setOrgWideEmailAddressId(orgWideEmailID);
                            }
                            mails.add(mail);
                            objCase.AFU_Email_Flag__c = false;
                            objCase.AFU_Sent_Date__c = system.now();
                        }
                    }
                }
                if(mails != null && mails.Size() > 0){
                    Messaging.sendEmail(mails);
                }
            }
        }
    }
    
    public static void setFieldForData(List<Case> caseList){
        List<Id> caseIdList = new List<Id>();
        List<Case> cases = new List<Case>();
        String emailCheck,customEmail =null;
        String emailCheckIMS, emailCheckIMSUS = null;
        List<EmailMessage> emailMsg = new List<EmailMessage>();
        List<String> fieldsList = new List<String>();
        String ccSeperate;
        String ccSeperateTo;
        CSM_ReplyTo_Email__c replyTo = CSM_ReplyTo_Email__c.getInstance('EmailAddress');
        CSM_ReplyTo_Email__c replyToAddress = CSM_ReplyTo_Email__c.getInstance('EAddress');
        CSM_ReplyTo_Email__c replyToIMS = CSM_ReplyTo_Email__c.getInstance('EmailAddressIMS');
        CSM_ReplyTo_Email__c replyToIMSUS = CSM_ReplyTo_Email__c.getInstance('EmailAddressIMSUS');
        
        if(replyTo!= null && replyToAddress !=null && replyToIMS != null && replyToIMSUS != null){
            emailCheck = replyTo.Reply_To_Email_Address__c;
            customEmail = replyToAddress.Reply_To_Email_Address__c;
            emailCheckIMS = replyToIMS.Reply_To_Email_Address__c;
            emailCheckIMSUS = replyToIMSUS.Reply_To_Email_Address__c;
        }
        for (Case c : caseList){
            if(CON_CSM.S_DATACASE.equalsIgnoreCase(c.RecordTypeName__c) && c.Origin != null && CON_CSM.S_EMAIL.equalsIgnoreCase(c.Origin) && UserInfo.getName() == 'System' && c.InitialQueue__c !=null && c.InitialQueue__c == CON_CSM.S_DATA_GLOBAL_ESERVICE_QUEUE ){
                caseIdList.add(c.Id);
                cases.add(c);
            }
        }
        if(caseIdList.isEmpty() == false){
            emailMsg = [select FromAddress, ParentId, ToAddress,CcAddress from EmailMessage where ParentId != null and ParentId in : caseIdList];
        }
        if(emailMsg.isEmpty()==false && emailMsg[0].CcAddress!=null){
            fieldsList =emailMsg[0].CcAddress.split(';');
            for(String seperate :fieldsList ){
                if(seperate == emailCheck || seperate == emailCheckIMS || seperate == emailCheckIMSUS){
                    ccSeperate = seperate;
                }
            }
        }
        if(emailMsg.isEmpty()==false && emailMsg[0].ToAddress!=null){
            fieldsList =emailMsg[0].ToAddress.split(';');
            for(String seperate :fieldsList ){
                if(seperate == emailCheck || seperate == emailCheckIMS || seperate == emailCheckIMSUS){
                    ccSeperateTo = seperate;
                }
            }
        }
        if(cases != null && !cases.isEmpty()){
            for(Case caseRecord : cases) {
                if(emailMsg != null && !emailMsg.isEmpty()){
                    if(caseRecord.RecordTypeName__c == 'DATACase' && UserInfo.getName() == 'System' && CaseRecord.InitialQueue__c !=null && CaseRecord.InitialQueue__c == CON_CSM.S_DATA_GLOBAL_ESERVICE_QUEUE && ((emailCheck == ccSeperateTo || emailCheck == ccSeperate) || (emailCheckIMS == ccSeperateTo || emailCheckIMS == ccSeperate) || (emailCheckIMSUS == ccSeperateTo || emailCheckIMSUS == ccSeperate))){
                        if(caseRecord.Language__c==null) {
                            caseRecord.Language__c = 'English';
                            caseRecord.LOS__c = 'DATA';
                            caseRecord.SubType1__c = 'SERVICE';
                            caseRecord.SubType2__c = 'CLIENT SUPPORT';
                            caseRecord.SubType3__c = 'CLIENT ACTIVITY'; 
                        } 
                    }
                    
                    if(caseRecord.RecordTypeName__c == CON_CSM.S_DATACASE && UserInfo.getName() == 'System' && CaseRecord.InitialQueue__c !=null && CaseRecord.InitialQueue__c == CON_CSM.S_DATA_GLOBAL_ESERVICE_QUEUE && (emailMsg[0].ToAddress ==customEmail )){
                        caseRecord.SendAutomaticAcknowledgmentEmail__c ='No';
                    }
                    
                }
            }
        }
    }
    
    public static void reOpenedClosedCase(List < Case > caseList,Map<Id, Case> oldMap) {
        if (caseList != null && caseList.size() > 0) {
            for (Case c : caseList) {
                if (c.Status != null && oldMap != null && oldMap.get(c.Id) != null && oldMap.get(c.Id).Status == CON_CSM.S_CASE_CLOSED && CON_CSM.S_CASE_CLOSED != c.Status && c.Status != oldMap.get(c.Id).Status) {
                    c.ReOpened__c = true;
                    c.ReOpenDate__c = Date.today();
                    c.ReOpener__c = UserInfo.getName();
                }
            }
        }
    }
    
    public static void checkFCRWhenCaseIsCreatedAsClosed(List < Case > caseList,Map<Id, Case> oldMap) {
        if (caseList != null && caseList.size() > 0) {
            for (Case c : caseList) {
                /* SP-28(CSM-224) First Call Resolution check*/
                if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (c.Status == CON_CSM.S_CLOSED || c.Status == CON_CSM.S_RESOLVED_WITH_C) && (Trigger.isInsert || (oldMap != null && Trigger.IsUpdate && (c.Status != oldMap.get(c.Id).Status || c.IsEscalated != oldMap.get(c.Id).IsEscalated) )) ){
                    if(!c.FirstCallResolution__c && !c.IsEscalated){
                        c.FirstCallResolution__c = true;    
                    }else if(c.IsEscalated){
                        c.FirstCallResolution__c = false;  
                    }
                    
                }
            }
        }
    }
    
     public static void checkFCRWhenCaseIsClosedWithInOneHour(List <Case> caseList) {     
        if (caseList != null && caseList.size() > 0) {
            for (Case c : caseList) {
                 if (CON_CSM.S_TECHNO_SOL == c.RecordTypeName__c && (c.ClosedDate != null) && (!c.FirstCallResolution__c) && (!c.ReOpened__c)){
                    Decimal hr = ((c.ClosedDate.getTime() - c.CreatedDate.getTime())/(1000*60*60));
                    if(hr<=1)
                    {
                       c.FirstCallResolution__c = true;
                    }
                }
            }
        }
    }
    
    public static void unCheckFCRWhenCaseIsReopened(List < Case > caseList) {
        if (caseList != null && caseList.size() > 0) {
            for (Case c : caseList) {
                if (CON_CSM.S_TECHNO_SOL == c.RecordTypeName__c && (c.FirstCallResolution__c) && c.ReOpened__c) {
                    c.FirstCallResolution__c = false;
                }
            }
        }
    }
    
    public static Map<Id,Account> checkSpecialHandlingClient(List < Case > caseList,Map<Id, Case> oldMap) {
            Map<Id,Account> accMap = null;
            if (caseList != null && caseList.size() > 0) {
            Set<Id> accSet = new Set<Id>();
            for (Case caseRecord: caseList) {
                if (caseRecord.AccountId != Null && (Trigger.isInsert || (Trigger.isUpdate && oldMap != null && oldMap.get(caseRecord.Id) != null && (caseRecord.External_vendor__c != oldMap.get(caseRecord.Id).External_vendor__c || caseRecord.AccountId != oldMap.get(caseRecord.Id).AccountId)) ) ) {
                    accSet.add(caseRecord.AccountId);
                }
            }
            if(accSet != null && !accSet.isEmpty()){
                accMap = new SLT_Account().selectByAccountId(accSet, new Set<String>{'Id','IsThisASpecialHandlingClient__c','MDMID__c'});
            }
            for (Case caseRecord: caseList) {
                if (caseRecord.AccountId != Null && accMap != null && !accMap.isEmpty()
                    && accMap.containsKey(caseRecord.AccountId)) {
                        caseRecord.IsThisASpecialHandlingClient__c = accMap.get(caseRecord.AccountId).IsThisASpecialHandlingClient__c;
                }
            }
        }
        return accMap;
    }
    
    public static void addDescriptionAsCaseComment(List<Case> caseList){
        List<CaseComment> ccList = new List<CaseComment>();
        CaseComment cc = null;
        if(caseList != null && caseList.size() > 0){
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('BISM');
            for(Case caseRecord : caseList){
                if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c && caseRecord.Description !=null && caseRecord.Description != '' && caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && caseRecord.Description.length() < 4000){
                    cc = new CaseComment();
                    cc.ParentId = caseRecord.Id;
                    cc.CommentBody = CON_CSM.S_Case_Description+caseRecord.Description;
                    ccList.add(cc);
                }
            }
            if(ccList != null && ccList.size() > 0){
                try{
                    insert ccList;
                }
                catch(Exception ex){
                    ex.getMessage();
                }
            }
        }
    }

    public static void completeRDCaseMilestone(List < Case > newList, Map < Id, Case > oldMap) {  
        DateTime completionDate = System.now();
        List<Id> updateCases = new List<Id>();
        List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
        for (Case c: newList) {
            if (CON_CSM.S_ACTIVITY_R_T == c.RecordTypeName__c &&  c.Status != null && c.SubStatus__c != null 
                && oldMap != null && oldMap.get(c.Id) != null 
                && c.SubStatus__c != oldMap.get(c.Id).SubStatus__c 
                && CON_CSM.S_WAITING_FOR == c.Status && CON_CSM.S_QC == c.SubStatus__c) {
                updateCases.add(c.Id);
            }
        }
        if (updateCases.isEmpty() == false) {  
               
            List<CaseMilestone> cmsToComplete = [select Id, completionDate from CaseMilestone cm where caseId in: updateCases and (cm.MilestoneType.Name =:CON_CSM.S_CRITICAL_ALERT or cm.MilestoneType.Name =:CON_CSM.S_NON_CRITICAL_ALERT) and completionDate = null];
            if (cmsToComplete != null && cmsToComplete.isEmpty() == false) {
                for (CaseMilestone cm: cmsToComplete) {
                    cm.completionDate = completionDate;
                    cmsToUpdate.add(cm);
                }
            }
        }
        try {
            if (cmsToUpdate.isEmpty() == false && cmsToUpdate.size() > 0) {
                update cmsToUpdate;
            }
        } catch (DmlException e) {
            System.debug('Failed due to : ' + e);
        }
    }

    public static void customEmailAddressesValidation(List<Case> caseList){
        //String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]+$';
        Pattern patt = null;
        Matcher match = null;
        if(caseList != null && caseList.size() > 0){
            for(Case c : caseList){
                if(c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE){
                    if(c.AFU_Email_Addresses__c != null && c.AFU_Email_Addresses__c != ''){
                        for(String mail : c.AFU_Email_Addresses__c.split(';')){
                            patt = Pattern.compile(emailRegex);
                            match = patt.matcher(mail.trim());
                            if(hasCustomPermission == false && !match.matches()){
                                c.addError('Invalid Email Address Format In AFU Email Addresses.');
                            }
                        }
                    }
                }
            }
        }
    }

    private static Map<String, Id> getOrgWideEmailId(){
       List<OrgWideEmailAddress> listOfOrgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress];
       Map<String, Id> mapOfOrgWideEmails = new Map<String, Id>();
       if(listOfOrgWideEmails.size() > 0 && listOfOrgWideEmails != null){
           for(OrgWideEmailAddress obj : listOfOrgWideEmails){
               mapOfOrgWideEmails.put(obj.Address, obj.Id);
           }
       }   
       return mapOfOrgWideEmails;
   }

    @future
    private static void saveActivityOnOutboundMail(String caseIdSet){
        if(caseIdSet != null && caseIdSet.length() > 0){
            Set<Case>  caseList = (Set<Case>)JSON.deserialize(caseIdSet, Set<Case>.class);
            List<Activity__c> activityList = new List<Activity__c>();
            Activity__c activityRecord = null;
            for(Case caseRecord : caseList){
                activityRecord = new Activity__c();
                activityRecord.Case__c = caseRecord.Id;
                if(caseRecord.RandD_Location__c != null){
                    activityRecord.Status__c = 'Done';
                }
                activityRecord.PassFail__c = 'Pass';
                activityRecord.Site__c = caseRecord.AccountId;
                activityRecord.Study__c = caseRecord.Study__c;
                activityRecord.Contact__c = caseRecord.ContactId;
                activityRecord.LOS__c = caseRecord.LOS__c;
                activityRecord.StartDatetime__c = System.now();
                activityRecord.CloseDatetime__c = System.now();
                activityRecord.RandD_Location__c = caseRecord.RandD_Location__c;
                activityRecord.Type__c = 'Automated Follow-up email sent';
                if(caseRecord.Count_of_AFU__c == 1){
                    activityRecord.EscalationType__c = 'Reminder 1';
                }else if(caseRecord.Count_of_AFU__c == 2){
                    activityRecord.EscalationType__c = 'Reminder 2';
                }else if(caseRecord.Count_of_AFU__c == 3){
                    activityRecord.EscalationType__c = 'Reminder 3';
                }
                activityList.add(activityRecord);
            }
            if(activityList != null && activityList.size() > 0){
                try{
                    insert activityList;
                }
                catch(Exception ex){
                    ex.getMessage();
                }
            }
        }
    }
    
    public static void createActivitesbyRnDTemplate(List <Case> caseList,Map<Id, Case> oldMap){
        
        List<Activity__c> activityList = new List<Activity__c>();
        Activity__c aR = null;
        List<CSM_QI_Case_Categorization__c>  ccList = new List<CSM_QI_Case_Categorization__c>();
        Map<String,String> ccmap = new Map<String,String>();
        Set<String> ccTempList = new Set<String>();
        Set<String> ccLos = new Set<String>();
        String activites = null;
        List<String> actList = new List<String>();
                
        for(Case c : caseList){
            if( oldMap != null && CON_CSM.S_ACTIVITY_R_T == c.RecordTypeName__c && c.Template__c != null && c.LOS__c != null
               && (c.Template__c != oldMap.get(c.Id).Template__c || c.LOS__c != oldMap.get(c.Id).LOS__c) ){
                ccTempList.add(c.Template__c);
                ccLos.add(c.LOS__c);
            }else if(Trigger.isInsert && CON_CSM.S_ACTIVITY_R_T == c.RecordTypeName__c && c.Template__c != null && c.LOS__c != null && c.Owner__c == 'BulkCase' ){
                ccTempList.add(c.Template__c);
                ccLos.add(c.LOS__c);
            }
        }
        if(ccTempList != null && !ccTempList.isEmpty()){
            ccList = new SLT_CaseCategorization().getCaseListForActivitesbyLosTemp(ccLos, ccTempList);
            if(ccList != null && !ccList.isEmpty() ){
                for(CSM_QI_Case_Categorization__c cz : ccList){
                    ccmap.put(cz.RnD_Template__c + cz.LOS__c , cz.Activitties__c);  
                }
                for(Case c : caseList){
                    if(ccmap.containsKey(c.Template__c + c.LOS__c)){
                        activites = ccmap.get(c.Template__c + c.LOS__c);
                        if(activites != null){
                            actList = activites.split(';');
                            if(actList != null && !actList.isEmpty()){
                                for(String act : actList){
                                    aR = new Activity__c();
                                    if(act != null){
                                        ar.Type__c = act;
                                    }
                                    aR.Case__c = c.Id;
                                    ar.Status__c = 'Open';
                                    if(c.AccountId != null){
                                        aR.Site__c = c.AccountId;
                                    }
                                    if(c.Study__c != null){
                                        aR.Study__c = c.Study__c;
                                    }
                                    if(c.ContactId != null){
                                        aR.Contact__c = c.ContactId;
                                    }
                                    if(c.LOS__c != null){
                                        aR.LOS__c = c.LOS__c;
                                    }
                                    aR.StartDatetime__c = System.now();
                                    if(c.RandD_Location__c != null){
                                        aR.RandD_Location__c = c.RandD_Location__c;
                                    }
                                    activityList.add(aR);    
                                }
                                
                            }
                        }
                        
                    }
                }
            }
        }
        if(activityList != null && activityList.size() > 0){
            try{
                insert activityList;
            }
            catch(Exception ex){
                ex.getMessage();
            }
        }
    }
    
    public static String SanofiTaskMilestone(String queue){
        String task = '';
        if(queue != null){
            if(queue.endsWithIgnoreCase('T1')){
                task = 'T1';
            }else if(queue.endsWithIgnoreCase('T2')){
                task = 'T2';
            }else if(queue.endsWithIgnoreCase('T3')){
                task = 'T3';
            }
            else if(queue.endsWithIgnoreCase('T4')){
                task = 'T4';
            }
            else if(queue.endsWithIgnoreCase('T1L1')){
                task ='T1L1';
            }
            else if(queue.endsWithIgnoreCase('T2a')){
                task ='T2a';
            }
            else if(queue.endsWithIgnoreCase('T2b')){
                task ='T2b';
            }
          
        }
        return task;
    }
    
    /**
    * This method is used for to call web service to verificy that one key id is available in system
    * @params  newList List<Case>
    * @return  void
    */
    public static void checkIfCaseIsAvaiableInOneKey(List<Case> caseList,Map<Id, Case> oldMap) {
        List<Id> IdOfCase = new List<Id>();
        if(!caseList.isEmpty()) {
            for(Case newCase : caseList) {
                if(newCase.RecordTypeName__c == CON_CSM_OneKey.S_HCP_ONE_KEY_REQUEST && newCase.Type == CON_CSM_OneKey.S_ERASURE && !System.isFuture() && (Trigger.isInsert || 
                    ( oldMap != null && Trigger.IsUpdate  && (oldMap.get(newCase.Id).OneKey_FirstName__c != newCase.OneKey_FirstName__c || 
                    oldMap.get(newCase.Id).oneKey_LastName__c != newCase.oneKey_LastName__c  || (oldMap.get(newCase.Id).OneKeyID__c != newCase.OneKeyID__c && 
                    newCase.OneKeyID__c != CON_CSM_OneKey.S_DELETED))))) {
                    IdOfCase.add(newCase.id);
                }
            }
        }
        if(!IdOfCase.isEmpty()) {
             WSC_CSM_OneKeyCaseVerification.checkIfOneKeyISAvailable(IdOfCase);
        }
    }
    
    /**
    * This method is used for to update oneKey Id if status of case is closed
    * @params  newList List<Case>
    * @return  void
    */
    public static void updateOnekeyIdToDeleted(List<case> listOfUpdatedCase) {
        for(Case c : listOfUpdatedCase) {
            if(c.RecordTypeName__c  == CON_CSM_OneKey.S_HCP_ONE_KEY_REQUEST && c.Status == CON_CSM_OneKey.S_CLOSED && c.OneKeyID__c != null) {
                c.OneKeyID__c = CON_CSM_OneKey.S_DELETED; 
            }
        }
    }
    
    /**
    * This method is used for to validate case type for data type case for specific latam
    * @params  newList List<Case>
    * @return  void
    */
    
    public static void checkCaseTypeForDataCase(List<case> listOfCase, Map<Id,Case> oldMap) {
        List<String> listOfDataQueue = Label.Data_Queue_values.split(';');
        if(listOfCase != null && !listOfCase.isEmpty()) {
            for(Case c : listOfCase) {
                if(hasCustomPermission == false && c.RecordTypeName__c == CON_CSM.S_DATACASE && c.Case_Type__c == null && c.G_Inquiry_Investigation__c == null && c.InitialQueue__c != null && listOfDataQueue.contains(c.InitialQueue__c)) {
                    c.addError(Label.Case_type_is_mandatory_for_this_Initial_queue);
                }
                if(c.RecordTypeName__c == CON_CSM.S_DATACreateService && oldMap != null){
                    if((c.Owner__c == 'EmailQuickAction' && c.Owner__c != oldMap.get(c.Id).Owner__c) || (c.Is_Parent__c && c.Is_Parent__c != oldMap.get(c.Id).Is_Parent__c) || (c.LastCaseComment__c != null && c.LastCaseComment__c != oldMap.get(c.Id).LastCaseComment__c) || (c.UpdatePost__c == 'Post Updated')){
                        c.Owner__c = 'QuickAction';
                        if(c.UpdatePost__c != null){
                            c.UpdatePost__c = null;
                        }
                    }else if(c.Owner__c == 'QuickAction'){
                        c.Owner__c = null;
                    }
                }
            }
        }
    }
    
    /**
    * This method is used for to update LOS of case according to Initial Queue
    * @params  newList List<Case>
    * @return  void
    */
    /** public static void populateLOSForRnDPillar(List<Case> newList) {
        for(Case newCase : newList) {
            if((newCase.RecordTypeName__c == CON_CSM.S_RDCASE || newCase.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && 
               !String.isEmpty(newCase.InitialQueue__c) && String.isEmpty(newCase.LOS__c) && Trigger.isInsert  ) {
                if(CON_CSM.INITIAL_QUEUE_AND_LOS_MAP.containskey(newCase.InitialQueue__c)) {
                    newCase.LOS__c = CON_CSM.INITIAL_QUEUE_AND_LOS_MAP.get(newCase.InitialQueue__c);                       
                }
            }
        }
    }*/
    
    /**
    * This method is used for to update RandD Location of case according case owner city
    * @params  newList List<Case>
    * @return  void
    */
    public static void populateLocationForRAndD(List<Case> newList, Map<Id, Case> oldMap) {
        List<String> listOfLoc = Label.Location_Name.split(';');
        Map<Id, User> mapOfIdAndUser = new Map<Id, User>();
        Set<Id> setOfUserId = new Set<Id>();
        for(case c : newList) {
            if(c.Origin != CON_CSM.S_EMAIL && c.ownerId != null && String.valueOf(c.ownerId).startsWith('005') && (oldMap == null || (oldMap != null && oldMap.get(c.Id) != null && oldMap.get(c.Id).ownerId != c.ownerId)) && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T)){
                setOfUserId.add(c.ownerId);     
            }
        }
        if(setOfUserId != null && !setOfUserId.isEmpty()){
            mapOfIdAndUser = new SLT_User().selectMapOfActiveUserByUserId(setOfUserId, new Set<String>{'Id','Name','city'});
            for(Case c : newList) {
                if(mapOfIdAndUser.containsKey(c.ownerId) && listOfLoc.contains(mapOfIdAndUser.get(c.ownerId).city)) {
                    c.RandD_Location__c = mapOfIdAndUser.get(c.ownerId).city;                       
                }
            }    
        }
        
    }

    /**
    * This method is used for to validate case if activity for related case is open
    * @params  newList List<Case>
    * @return  void
    */
    
    public static void checkActivityStatusForOpen(List<case> listOfCase) {
        if(CSM_case_Trigger_Handler__c.getOrgDefaults().CSM_Activity_Open_Validation__c) {
            Set<Id> setOfCaseId = new Set<Id>();
            for(Case newCase: listOfCase) {
                if((newCase.RecordTypeName__c == CON_CSM.S_R_D_V_T || newCase.RecordTypeName__c == CON_CSM.S_RDCASE || newCase.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && ((newCase.Status == CON_CSM.S_CLOSED && CON_CSM.S_Non_Actionable != newCase.SubStatus__c) || newCase.Status == CON_CSM.S_RESOLVED)){
                    setOfCaseId.add(newCase.Id);
                }
            }
            List<Activity__c> listOfRelatedActivity = new list<Activity__c>();
            if(!setOfCaseId.isEmpty()) {
                listOfRelatedActivity = new SLT_ActivityC().selectActivityByCaseId(setOfCaseId, new Set<String>{'Id','Description__c','Status__c','Case__r.Id','Type__c'});
                Map<Id, Activity__c> mapOfCaseIdAndActivity = new Map<Id, Activity__c>();
                for(Activity__c newActivity : listOfRelatedActivity) {
                    if(newActivity.status__c == CON_CSM.S_OPEN && !String.isEmpty(newActivity.Type__c) && newActivity.Type__c == CON_CSM.S_QUALITY_CHECK){
                        mapOfCaseIdAndActivity.put(newActivity.Case__r.Id, newActivity);
                    }
                }
                if(listOfCase != null && !listOfCase.isEmpty() && !mapOfCaseIdAndActivity.isEmpty()) {
                    for(case newCase : listOfCase) {
                        if(hasCustomPermission == false && mapOfCaseIdAndActivity.containsKey(newCase.Id)) {
                            newCase.addError(Label.CSM_Activity_Open_Validation);
                        }
                    }
                }
            }
        }
    }

    /** public static void updateFirstResponseEmailTimeOnCase(List<Case> caseList, Map<Id, Case> oldMap){
        for(Case caseRecord : caseList){
            if((caseRecord.RecordTypeName__c.equalsIgnoreCase(CON_CSM.S_DATACASE) && caseRecord.First_response_email_time__c == null) && 
               (caseRecord.First_response_sent__c && caseRecord.First_response_sent__c != oldMap.get(caseRecord.Id).First_response_sent__c)){
                caseRecord.First_response_email_time__c = Datetime.now();
            }
        }
    }**/

    public static void updateContactAlreadyInProcess(List<case> listOfCase) {
        Set<String> setOfId = new Set<String>();
        for(Case c : listOfCase) { 
            if(c.contactId != null && !c.Contact_Already_In_Self_Registration__c && (c.RecordTypeName__c == CON_CSM.S_DATACASE || c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T)){
                setOfId.add(c.contactId);
            }
        }
        if(!setOfId.isEmpty()){
            List<Case> listOfOldCase = new SLT_Case().selectByCaseByContact(setOfId, new Set<String>{'Id','contactId'});
            map<Id, Boolean> mapOfselfRegistration= new Map<ID, Boolean>();
            if(listOfOldCase != null && !listOfOldCase.isEMpty()) {
                for(Case c : listOfOldCase) {
                    mapOfselfRegistration.put(c.contactId, true);
                }
            }
            if(!mapOfselfRegistration.isEmpty()) {
                for(Case c : listOfCase) {
                    if(mapOfselfRegistration.containsKey(c.ContactId)) {
                        c.Contact_Already_In_Self_Registration__c = true;
                    }
                }
            }
        }
    }

    public static void setIsStudyAttachedFirstTimeForRND(List<Case> caseList, Map<Id, Case> oldMap) {
        if(caseList != null && caseList.size()>0) { 
            for(Case caseRecord : caseList) {
                if(caseRecord.RecordTypeName__c == CON_CSM.S_R_D_CTP || caseRecord.RecordTypeName__c == CON_CSM.S_R_D_CDP || caseRecord.RecordTypeName__c == CON_CSM.S_R_D_V_T || caseRecord.RecordTypeName__c.containsIgnoreCase(CON_CSM.S_RDCASE) || caseRecord.RecordTypeName__c.containsIgnoreCase(CON_CSM.S_ACTIVITY_R_T) ){
                    if((caseRecord.Study__c != null && !String.isBlank(caseRecord.Study__c) && Trigger.isInsert) || 
                       (Trigger.isUpdate && oldMap.get(caseRecord.Id) != null && caseRecord.Study__c != null && 
                        oldMap.get(caseRecord.Id).Study__c != caseRecord.Study__c )) {
                        caseRecord.Is_Study_Attached_First_Time__c = true;
                    }
                    else{
                        caseRecord.Is_Study_Attached_First_Time__c = false;
                    }
                }
            }
        }
    }

    public static void updateSubStatusOnQuickAction(List<case> listOfCase, Map<Id, Case> oldMap) {
        Map<String, String> mapSourceCaseIdToCategorizationId = new Map<String, String>();
        Map<String, String> mapSourceCaseIdToProductName = new Map<String, String>();
        Map<String, String> mapSourceCaseIdToSubtype1 = new Map<String, String>();
        Map<String, String> mapSourceCaseIdToSubtype2 = new Map<String, String>();
        Map<String, String> mapSourceCaseIdToSubtype3 = new Map<String, String>();
        Map<String, String> mapSourceCaseIdToAsset = new Map<String, String>();
        
        for(case newCase: listOfCase) {
            if((Trigger.isInsert && newCase.isClone() && newCase.Status == CON_CSM.S_NEW && newCase.RecordTypeName__c != CON_CSM.S_DATACreateService) ||
               (Trigger.isUpdate && newCase.getQuickActionName() == CON_CSM.S_TAKE_OWNERSHIP && newCase.Status == CON_CSM.S_IN_PROGRESS &&
                newCase.SubStatus__c == oldMap.get(newCase.Id).SubStatus__c)) {
                newCase.SubStatus__c = null;
            }
            if(Trigger.isInsert && newCase.isClone() && (CON_CSM.S_TECHNOLOGY_R_T == newCase.RecordTypeName__c || newCase.RecordTypeName__c == CON_CSM.S_DATACASE || newCase.RecordTypeName__c == CON_CSM.S_DATACreateService)) {
                mapSourceCaseIdToAsset.put(newCase.getCloneSourceId(), null);
            }
        }
        if(mapSourceCaseIdToAsset != null && !mapSourceCaseIdToAsset.isEmpty()) {
            for(Case c : [Select id, AssetId, Case_CategorizationId__c, ProductName__c, SubType1__c, SubType2__c, SubType3__c from case where id in: mapSourceCaseIdToAsset.keySet()]) {
                mapSourceCaseIdToAsset.put(c.id, c.AssetId);
                mapSourceCaseIdToCategorizationId.put(c.id, c.Case_CategorizationId__c);
                mapSourceCaseIdToProductName.put(c.id, c.ProductName__c);
                mapSourceCaseIdToSubtype1.put(c.id, c.SubType1__c);
                mapSourceCaseIdToSubtype2.put(c.id, c.SubType2__c);
                mapSourceCaseIdToSubtype3.put(c.id, c.SubType3__c);
            }
        }
        for(case newCase: listOfCase) {
            if(Trigger.isInsert && newCase.isClone() && (CON_CSM.S_TECHNOLOGY_R_T == newCase.RecordTypeName__c || newCase.RecordTypeName__c == CON_CSM.S_DATACASE || newCase.RecordTypeName__c == CON_CSM.S_DATACreateService)) {
                if(mapSourceCaseIdToAsset.get(newCase.getCloneSourceId()) != newCase.AssetId)
                {
                    newCase.Case_CategorizationId__c = null;
                    newCase.ProductName__c = null;
                    newCase.SubType1__c = null;
                    newCase.SubType2__c = null;
                    newCase.SubType3__c = null;
                } else {
                    newCase.Case_CategorizationId__c = mapSourceCaseIdToCategorizationId.get(newCase.getCloneSourceId());
                    newCase.ProductName__c = mapSourceCaseIdToProductName.get(newCase.getCloneSourceId());
                    newCase.SubType1__c = mapSourceCaseIdToSubtype1.get(newCase.getCloneSourceId());
                    newCase.SubType2__c = mapSourceCaseIdToSubtype2.get(newCase.getCloneSourceId());
                    newCase.SubType3__c = mapSourceCaseIdToSubtype3.get(newCase.getCloneSourceId());
                }
            }
        }
    }

    /*public static void updateAssignTocurrentQueueOnQuickAction(List<case> listOfCase, Map<Id, Case> oldMap) {
        for(case newCase : listOfCase) {
            if((Trigger.isUpdate && newCase.getQuickActionName() == CON_CSM.S_MACRO_ONLY && newCase.AssignCaseToCurrentUser__c == true) ){
                newCase.OwnerId = UserInfo.getUserId();
            }
             
        }
       
    }*/

    public static void saveBusinessElapsedTime(List<Case> newLst,Map<Id,Case> oldMap){
        DateTime dt = System.now();
        for(Case c : newLst){
            if(c.Status != oldMap.get(c.Id).Status || c.SubStatus__c != oldMap.get(c.Id).SubStatus__c){
                if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (!(oldMap.get(c.Id).Status == CON_CSM.S_AWAITING && oldMap.get(c.Id).SubStatus__c == CON_CSM.S_SS_CI) && oldMap.get(c.Id).Status != CON_CSM.S_RESOLVED_WITH_C && oldMap.get(c.Id).Status != 'Abandoned' && oldMap.get(c.Id).Status != CON_CSM.S_CLOSED)){
                    if(c.BusinessElapsedTime__c == null){
                        c.BusinessElapsedTime__c = 0;
                    }
                    if(c.BusinessHoursId != null && c.StatusChangedTime__c != null && dt != null){
                        c.BusinessElapsedTime__c += (BusinessHours.diff(c.BusinessHoursId, c.StatusChangedTime__c, dt)/1000/60);    
                    }
                }
                c.StatusChangedTime__c = dt;
            }
        }
    }

    public static void updateMilestoneAction(List<case> listOfCase, Map<Id, Case> oldMap) {
        for(case newCase : listOfCase) {
            if(newCase.IsStopped) {
                newCase.NextMilestoneStatus__c = CON_CSM.S_STOPPED;
            }
        }
    }

    public static void updateCaseDefaultBusinessHour(List<case> listOfCase, Map<Id, Case> oldMap) {
        Set<Id> entitlementIdSet = new Set<Id>();
        Set<Id> businessHoursIdSet = new Set<Id>();
        for(case newCase : listOfCase) {
            if((Trigger.isInsert && newCase.EntitlementId != null && newCase.BusinessHoursId != null) || 
               (Trigger.isUpdate && newCase.EntitlementId != null && newCase.BusinessHoursId != null && oldMap != null && 
                oldMap.get(newCase.Id) !=  null && newCase.BusinessHoursId != oldMap.get(newCase.Id).BusinessHoursId && UserInfo.getName() == CON_CSM.S_SYSTEM)) {
                    entitlementIdSet.add(newCase.EntitlementId);
                    businessHoursIdSet.add(newCase.BusinessHoursId);
                }
        }
        if(entitlementIdSet != null && !entitlementIdSet.isEmpty() && businessHoursIdSet != null && !businessHoursIdSet.isEmpty()) {
            Map<Id, Entitlement> entitlementMap = new SLT_Entitlement().selectByEntitlementId(entitlementIdSet, new Set<String>{'BusinessHoursId'});
            Map<Id, BusinessHours> businessHoursMap = new SLT_BusinessHours().selectByBusinessHoursId(businessHoursIdSet, new Set<String>{'Name'});
            for(case newCase : listOfCase) {
                if(entitlementMap != null && entitlementMap.containsKey(newCase.EntitlementId) && entitlementMap.get(newCase.EntitlementId) != null && 
                   entitlementMap.get(newCase.EntitlementId).BusinessHoursId != null && businessHoursMap != null && 
                   businessHoursMap.containsKey(newCase.BusinessHoursId) && businessHoursMap.get(newCase.BusinessHoursId) != null && 
                   businessHoursMap.get(newCase.BusinessHoursId).Name == CON_CSM.S_DEFAULT) {
                       newCase.BusinessHoursId = entitlementMap.get(newCase.EntitlementId).BusinessHoursId;
                   }
            }
        }
    }
        
    public static void updateMileStoneStatusAndValue(List<case> listOfCase) {
        for(case newCase : listOfCase) {
            if(!newCase.IsStopped) {
                if(newCase.NextMilestoneStatus__c == CON_CSM.S_ONGOING || newCase.NextMilestoneStatus__c == CON_CSM.S_REMAINING_2_HOURS || 
                   newCase.NextMilestoneStatus__c == CON_CSM.S_REACHED || newCase.NextMilestoneStatus__c == CON_CSM.S_COMPLETED || 
                   newCase.NextMilestoneStatus__c == CON_CSM.S_REMAINING_8_HOURS || newCase.NextMilestoneStatus__c == CON_CSM.S_REMAINING_16_HOURS) {
                       newCase.NextMilestonePriorValue__c = newCase.NextMilestoneStatus__c;
                }
                else if(newCase.NextMilestoneStatus__c == CON_CSM.S_STOPPED) {
                    newCase.NextMilestoneStatus__c = newCase.NextMilestonePriorValue__c;
                }
            }
        }
    } 
    
    /*public static void sendEmailsTofollowers(List<Case> newList,Map<Id, Case> oldMap){
        Set<Id> csIds = new Set<Id>();
        Map<Id,String> follMap = new Map<Id,String>();
        Set<String> lstStr = new Set<String>();
        Map<String,Id> etMap = new Map<String,Id>();
        for (Case c : newList) {
            if (c.Status != null && c.Status != oldMap.get(c.Id).Status) {
                csIds.add(c.Id);
            }
        }
        if(csIds != null && !csIds.isEmpty()){
            List<CSM_QI_Case_Follower__c> lstcon = Database.query('Select Id,Contact__c,Case__c,Account_Country__c from CSM_QI_Case_Follower__c where Case__c in :csIds');
            if(lstcon != null && !lstcon.isEmpty()){
                for(CSM_QI_Case_Follower__c f : lstcon){
                  follMap.put(f.Id, 'ET_TECH_' + f.Account_Country__c + '_Case_Status_Change_CSH');  
                }
                
                if(follMap != null){
                    lstStr.addAll(follMap.values());
                    lstStr.add('ET_TECH_US_Case_Status_Change_CSH');
                    List<EmailTemplate> etList = new SLT_EmailTemplate().selectEmailTemplatesByDeveloperNames(lstStr);
                    for(EmailTemplate et : etList){
                        etMap.put(et.DeveloperName,et.Id);
                    }
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                List<Messaging.Email> emList = new List<Messaging.Email>();
                for(CSM_QI_Case_Follower__c f : lstcon){
                    if(follMap.containsKey(f.Id) && etMap.containsKey(follMap.get(f.Id))){
                        mail.setWhatId(f.Case__c);
                        mail.setTargetObjectId(f.Contact__c);
                        mail.setTemplateId(etMap.get(follMap.get(f.Id)));
                    }else if(etMap.containsKey('ET_TECH_US_Case_Status_Change_CSH')){
                        mail.setWhatId(f.Case__c);
                        mail.setTargetObjectId(f.Contact__c);
                        mail.setTemplateId(etMap.get('ET_TECH_US_Case_Status_Change_CSH'));
                    }
                    emList.add(mail);
                } 
                Messaging.sendEmail(emList);
            }
        }
    }*/
    
     public static void updateServiceNowGroupCSM2BISM(List<Case> listCase,Map<Id, Case> oldMap) {
        Set<String> caseNowset = new Set<String>();
        String Queue = null, Product = null, Account = null;
        for(Case c : listCase){
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.External_System_Type__c != null) {
                if(c.Status == CON_CSM.S_RESOLVED_WITH_C && c.ServiceNowSystemType__c == CON_CSM.S_IQVIA){
                    if(c.External_System_Type__c == CON_CSM.S_BISM){
                        c.ServiceNowSystemType__c = CON_CSM.S_BISM;
                    }else if(c.External_System_Type__c == CON_CSM.S_ROCHE_SN){
                        c.ServiceNowSystemType__c = c.External_System_Type__c;
                    }
                }else if(c.Status == CON_CSM.S_AWAITING && c.Substatus__c != oldMap.get(c.Id).Substatus__c && !CON_CSM.PL_ROCHE_TECH_AWT_SUBS.contains(oldMap.get(c.Id).Substatus__c) && CON_CSM.PL_ROCHE_TECH_AWT_SUBS.contains(c.Substatus__c)){
                    if(c.External_System_Type__c == CON_CSM.S_ROCHE_SN){
                        c.ServiceNowSystemType__c = c.External_System_Type__c;
                    }
                }else if(c.ServiceNowSystemType__c != oldMap.get(c.Id).ServiceNowSystemType__c){
                    if(c.ServiceNowSystemType__c == CON_CSM.S_BISM || c.ServiceNowSystemType__c == CON_CSM.S_ROCHE_SN){
                        c.Status = CON_CSM.S_AWAITING;
                        c.SubStatus__c = CON_CSM.S_SS_CI;
                    }else{
                        c.Status = CON_CSM.S_IN_PROGRESS;
                    } 
                }
                if(c.Service_Now_Incident_Number__c != null && (c.ServiceNowSystemType__c == CON_CSM.S_ROCHE_SN || c.ServiceNowSystemType__c == CON_CSM.S_BISM || c.ServiceNowSystemType__c == CON_CSM.S_IQVIA) && (c.ServiceNowSystemType__c != oldMap.get(c.Id).ServiceNowSystemType__c || c.ServiceNow_Group__c == null)){
                    caseNowset.add(c.ServiceNowSystemType__c);
                    Queue = c.InitialQueue__c;
                    if(c.ProductName__c != null){
                        Product = c.ProductName__c;
                    }
                    if(c.AccountId != null){
                        Account = c.AccountId;
                    }
                }
            }
        }
        List<ServiceNow_Group__c>  sngList = null;
        if(caseNowset != null && !caseNowset.isEmpty() ){
            sngList = Database.query('select Id,Name,SystemType__c,Account_Id__c,ProductName__c from ServiceNow_Group__c where SystemType__c in :caseNowset and Queue__c = :Queue and (Order__c = 1 or (ProductName__c = :Product and Account_Id__c = :Account and Order__c = 2)) order by Order__c DESC LIMIT 1');
            for(Case c : listCase){
                for(ServiceNow_Group__c sn : sngList){
                    if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Service_Now_Incident_Number__c != null && c.ServiceNowSystemType__c == sn.SystemType__c && (c.ServiceNowSystemType__c == CON_CSM.S_ROCHE_SN || c.ServiceNowSystemType__c == CON_CSM.S_BISM || c.ServiceNowSystemType__c == CON_CSM.S_IQVIA) && c.ServiceNowSystemType__c != oldMap.get(c.Id).ServiceNowSystemType__c){
                        c.ServiceNow_Group__c = sn.Id;
                    }
                }
                
            }
        }
    }
    
    public static void UpdateTicketCSM2BISM(List<Case> listCase, Map<Id, Case> oldMap) {
        for(Case c : listCase){
            if(c.External_System_Type__c != null && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Service_Now_Incident_Number__c != null){
                CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(c.External_System_Type__c);
                if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c){
                    string json = JSON.serialize(c);
                    if(c.External_System_Type__c == CON_CSM.S_BISM){
                        if(c.Status != CON_CSM.S_RESOLVED_WITH_C && c.Status != CON_CSM.S_CLOSED && (c.ServiceNowSystemType__c == CON_CSM.S_BISM || c.ServiceNowSystemType__c == CON_CSM.S_IQVIA) && (c.ServiceNowSystemType__c != oldMap.get(c.Id).ServiceNowSystemType__c || c.Priority != oldMap.get(c.Id).Priority || c.Urgency__c != oldMap.get(c.Id).Urgency__c || c.Techno_Impact__c != oldMap.get(c.Id).Techno_Impact__c || c.Status != oldMap.get(c.Id).Status || c.Origin != oldMap.get(c.Id).Origin || c.Subject != oldMap.get(c.Id).Subject)){
                            if(!System.isFuture() && !System.isBatch()){
                                WSC_CSM_BISMSOAPCallout.UpdateTicketCSM2BISM(json, c.ServiceNowSystemType__c ,oldMap.get(c.Id).ServiceNowSystemType__c);
                            }
                            break;
                            }else if(c.Status != oldMap.get(c.Id).Status && c.Status == CON_CSM.S_RESOLVED_WITH_C){
                            }else if(c.Status != oldMap.get(c.Id).Status && c.Status == CON_CSM.S_CLOSED && (c.ServiceNowSystemType__c == CON_CSM.S_BISM || c.ServiceNowSystemType__c == CON_CSM.S_IQVIA)){
                                if(!System.isFuture() && !System.isBatch()){
                                    CaseComment cc = new CaseComment(ParentId = c.Id,CommentBody = CON_CSM.S_BISM_PUB_CC, IsPublished = true);
                                    insert cc;
                                }
                            }
                    }else if(!System.isFuture() && !System.isBatch() && c.External_System_Type__c == CON_CSM.S_ROCHE_SN){
                        if(c.Status != CON_CSM.S_RESOLVED_WITH_C && !c.IsClosed && (c.ServiceNowSystemType__c != oldMap.get(c.Id).ServiceNowSystemType__c || c.Priority != oldMap.get(c.Id).Priority || c.Urgency__c != oldMap.get(c.Id).Urgency__c || c.Techno_Impact__c != oldMap.get(c.Id).Techno_Impact__c || (c.Status == CON_CSM.S_AWAITING && c.Substatus__c != oldMap.get(c.Id).Substatus__c && !CON_CSM.PL_ROCHE_TECH_AWT_SUBS.contains(oldMap.get(c.Id).Substatus__c) && CON_CSM.PL_ROCHE_TECH_AWT_SUBS.contains(c.Substatus__c)))){
                            WSC_CSM_ROCHERestCallout.updateIncident(json, c.ServiceNowSystemType__c ,oldMap.get(c.Id).ServiceNowSystemType__c);
                            break;
                        }else if(c.Status == CON_CSM.S_RESOLVED_WITH_C && oldMap != null && oldMap.get(c.Id) != null && c.Status != oldMap.get(c.Id).Status){
                            WSC_CSM_ROCHERestCallout.resolveIncident(json);
                            break;
                        }else if(c.Status != oldMap.get(c.Id).Status && c.IsClosed){
                            String messageR = CON_CSM.S_BISM_PUB_CC;
                            messageR = messageR.replace('closed', c.Status);
                            CaseComment cc = new CaseComment(ParentId = c.Id,CommentBody = messageR, IsPublished = true);
                            insert cc;
                        }
                    }
                }
            }
        }
    }

    public static void unfollowClosedCases(List<Case> caseList, Map<Id, Case> existingRecords){
        Set<Id> setOfClosedCaseId = new Set<Id>();
        for(Case newCase : caseList) {
            if(newCase.Status == CON_CSM.S_CLOSED && existingRecords != null && existingRecords.containsKey(newCase.Id) && 
                existingRecords.get(newCase.Id).Status != newCase.Status) {
                setOfClosedCaseId.add(newCase.Id);
            }
        }
        if(!setOfClosedCaseId.isEmpty()) {
            List<EntitySubscription> caseSubscriptionsToDelete = new List<EntitySubscription>();
            List<EntitySubscription> caseSubscriptionsList = [SELECT Id FROM EntitySubscription WHERE parentId IN: setOfClosedCaseId LIMIT 1000];
            for(EntitySubscription caseSubscription: caseSubscriptionsList) {
                EntitySubscription entity = new EntitySubscription(Id = caseSubscription.Id);
                caseSubscriptionsToDelete.add(entity);
            }
            if(caseSubscriptionsToDelete != null && caseSubscriptionsToDelete.size() > 0) {
                new EntitySubscriptionDeletion().deleteSubscriptions(caseSubscriptionsToDelete);
            }
        }
    }
    
    public static void sendEmailToLiquidPlanner(List<Case> caseList,Map<Id,Case> oldMap){
        Map<Id,CSMLiquidPlannerIntegration__c> lpMap = new Map<Id,CSMLiquidPlannerIntegration__c>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        CSMLiquidPlannerIntegration__c lp = null;
        if(!EXT_CSM_Validator_Cls.hasAlreadyDone()){
            if(oldMap != null){
                for(Case c : caseList){
                    lp = CSMLiquidPlannerIntegration__c.getInstance(c.OwnerId);
                    if(Trigger.isUpdate && c.RecordTypeName__c == CON_CSM.S_DATACASE && c.ProductName__c != null && lp != null && lp.Product__c.contains(c.ProductName__c)){
                        caseMap.put(c.id,c);
                        lpMap.put(c.Id, lp);
                    }
                }
            } 
            
            if(caseMap != null && !caseMap.isEmpty() && !System.isBatch() && !System.isFuture()){
                string json = JSON.serialize(caseMap);
                string jsonCS = System.JSON.serialize(lpMap);
                sendEmailToLiquidPlannerFuture(json,jsonCS);
            }
            
        }
    }
    
    public static void sleep(Long milliSeconds)
    {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }
    
    @future
    public static void sendEmailToLiquidPlannerFuture(String casesJson,String csLpJson){
        CSMLiquidPlannerIntegration__c csLP = null;
        try {
            Map<Id, Object> metaCase = (Map<Id, Object>) JSON.deserialize(casesJson,Map<Id, SObject>.class);
            Map<Id, CSMLiquidPlannerIntegration__c> lpMap = (Map<Id, CSMLiquidPlannerIntegration__c>) JSON.deserialize(csLpJson,Map<Id, CSMLiquidPlannerIntegration__c>.class);
            Set<Id> caseSet = metaCase.keySet();
            List<String> lpEmail =new List<String>();
            for(CSMLiquidPlannerIntegration__c lp : lpMap.values()){
                lpEmail.add(lp.EmailAddress__c);
            }
            // List<Case> caseRecordsViaQuery = [select ContactEmail, contact.Name from case where id in : caseSet];
            if(!EXT_CSM_Validator_Cls.hasAlreadyDone()){
                sleep(60000);
                List<EmailMessage> emailMsg ;
                EmailMessage messageRecord = new EmailMessage();  
                if(lpEmail != null) {
                    emailMsg= [select id,ToAddress from EmailMessage  where ParentId in: caseSet and ToAddress in:lpEmail];
                    if(emailMsg.isEmpty() || emailMsg.size()<1) {
                        List<ContentDocumentLink> contentDoc= [SELECT Id,ContentDocument.LastModifiedDate,ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.Title FROM ContentDocumentLink where LinkedEntityId in :caseSet];
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        EmailTemplate eTemplate = CNT_CSM_EmailNotification.sendEmailNotificationForLQ();
                        List<Messaging.RenderEmailTemplateBodyResult> resList = new List<Messaging.RenderEmailTemplateBodyResult>();
                        List<Messaging.RenderEmailTemplateBodyResult> resListSubject = new List<Messaging.RenderEmailTemplateBodyResult>();
                        if(metaCase != null && metaCase.values() != null){
                            List<Case> lpcases = (List<Case>)metaCase.values();
                            CSM_Case_Details_Global_Setting__c orgRep = CSM_Case_Details_Global_Setting__c.getInstance('Org Wide ReplytoCSM');
                            for(Case caseRecord :lpcases){
                                resList = Messaging.renderEmailTemplate(null, caseRecord.id, new List<String> {eTemplate.HTMLValue});
                                resListSubject = Messaging.renderEmailTemplate(null, caseRecord.id, new List<String> {eTemplate.Subject});
                                if(caseRecord.RecordTypeName__c == CON_CSM.S_DATACASE && lpMap.containsKey(caseRecord.Id)){
                                    csLP = (CSMLiquidPlannerIntegration__c)lpMap.get(caseRecord.Id);
                                    if((( caseRecord.OwnerId == csLP.OwnerID__c && caseRecord.Origin !='Customer Portal') || (caseRecord.Origin=='Customer Portal' && caseRecord.InitialQueue__c == csLP.Queue__c )) || (( caseRecord.OwnerId == csLP.OwnerID__c && metaCase != null && caseRecord.Origin !='Customer Portal' )||(caseRecord.Origin=='Customer Portal' && caseRecord.InitialQueue__c == csLP.Queue__c ) ) ){
                                        mail.setTargetObjectId(csLP.ContactId__c);
                                        mail.setCharset('UTF-8');                          
                                        mail.setHtmlBody(resList[0].getMergedBody());
                                        mail.setSaveAsActivity(false);
                                        mail.setReferences(Cases.generateThreadingMessageId(caseRecord.Id));
                                        mail.setSubject(resListSubject[0].getMergedBody());
                                        List<Messaging.EmailFileAttachment> emailAttachmentata = new List<Messaging.EmailFileAttachment>();
                                        for(ContentDocumentLink documentData :contentDoc){
                                            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                            Blob myBlob = documentData.ContentDocument.LatestPublishedVersion.VersionData;
                                            attach.filename = documentData.ContentDocument.Title+'.'+documentData.ContentDocument.FileExtension;
                                            attach.setBody(myBlob); 
                                            emailAttachmentata.add(attach);
                                        }
                                        Messaging.EmailFileAttachment[] array1 = new List<Messaging.EmailFileAttachment>();
                                        for (integer i=0;i<emailAttachmentata.size();i++){
                                            array1.add(emailAttachmentata[i]);
                                        }
                                        mail.setFileAttachments(array1);
                                        if(orgRep != null){
                                            mail.setOrgWideEmailAddressId(orgRep.Component_Id__c);
                                        }
                                        Messaging.sendEmail(new Messaging.Email[] {mail});
                                        messageRecord.ToAddress = csLP.ContactId__c;
                                        messageRecord.FromAddress = CON_CSM.S_DEFAULT_AFU_EMAIL;
                                        messageRecord.ParentId = caseRecord.ID;
                                        messageRecord.CreatedDate = Datetime.now();
                                        messageRecord.Status = '3';
                                        messageRecord.Subject ='From CSM: Account Name: '+caseRecord.Account_Name_Article__c+' '+caseRecord.Subject+' ';
                                        EXT_CSM_Validator_Cls.setAlreadyDone();
                                        
                                    }
                                    
                                }
                                
                                
                            }
                        } 
                        
                    }
                } 
                
                insert messageRecord;
                
            }
        }
        catch(Exception ex){
        }
    }
    
    public without sharing class EntitySubscriptionDeletion{
        public void deleteSubscriptions(List<EntitySubscription> caseSubscriptionsToDelete) {
            delete caseSubscriptionsToDelete;            
        }
    }

    /*public static void uncheckTechAFUOnStatus(List<Case> caseList){
        List<String> statusList = new List<String>{CON_CSM.S_CASE_CLOSED, CON_CSM.S_CASE_ABANDONED, CON_CSM.S_RESOLVED_WITH_C};
        for(Case caseRecord : caseList){
            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && caseRecord.AFU_TECH__c && statusList.contains(caseRecord.Status)){
                caseRecord.AFU_Next_Date__c = NULL;
                caseRecord.AFU_TECH__c = FALSE;
                caseRecord.Count_of_AFU__c = NULL;
            }
        }
    }*/
    public static void checkAccountBasedOnContact(List<Case> caseList,Map<Id, Case> oldMap) {
        List<Id> listContactId = new list<id>();
        Boolean checkCompability = true;
        for(Case caseRecord :caseList ){
            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                if (caseRecord.AccountId != Null && caseRecord.ContactId != null && (Trigger.isInsert || (Trigger.isUpdate && oldMap != null && oldMap.get(caseRecord.Id) != null && (caseRecord.AccountId != oldMap.get(caseRecord.Id).AccountId || caseRecord.ContactId != oldMap.get(caseRecord.Id).ContactId )) ) ) {
                    listContactId.add(caseRecord.ContactId);
                }
            }
        }
        if(listContactId != null && listContactId.size()>0){
            List<Contact> contactRecord =[SELECT Id,Name, (SELECT Contact.Name,Account.Name,ContactId,AccountId FROM AccountContactRelations where ContactId in : listContactId ) FROM Contact where Id in : listContactId];
            for(Case cRecord : caseList){
                for(Contact conValue : contactRecord){
                if(conValue.AccountContactRelations.size()>0){
                    List<Sobject> sObjAccountContact = conValue.AccountContactRelations;
                    for(Sobject objRecord : sObjAccountContact){
                        if(objRecord.get('AccountId') == cRecord.AccountId){
                            checkCompability = false; 
                        }
                    }
                }
                }
                if(hasCustomPermission == false && checkCompability){
                    cRecord.adderror(label.Account_is_not_associated_with_the_contact_selected); 
                }
            }
        }
    }

    /* Working on this 8-Nov-2022*/
    public static void sendNotificationForDispatch(List<Case> caseList,Map<Id, Case> oldMap) {
        id currQueueId = null;
        string ownerId = null,currQueueName = null;
        Set<String> owneridd = new Set<String>();
        Set<String> assignBell = new Set<String>();
        List<id> assignEmailUsers = new List<id>();
        List<id> dispatchEmailUsers = new List<id>();
        List<User> userInfoValue = new List<User>();
        List<Queue_User_Relationship__c> queueUser = null;
        for(Case c : caseList){
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                if(c.OwnerId !=null && oldMap !=null && oldMap.get(c.id).OwnerId != c.OwnerId ){
                    ownerId = c.OwnerId;
                    if(ownerId.startsWith('00G')){
                        currQueueId = c.CurrentQueue__c;
                    }
                }else if(Trigger.isInsert && c.OwnerId !=null && (c.Origin =='Customer Portal'|| c.Origin =='Email' )){ 
                    ownerId = c.OwnerId;
                    if(ownerId.startsWith('00G')){
                        currQueueId = c.CurrentQueue__c;     
                    }else if(c.Origin =='Customer Portal' && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T ){
                        ownerId = null;
                    }
                }
            }
        }
        if(ownerId !=null && !ownerId.startsWith('00G')) {
            userInfoValue   = new SLT_User().getUserDetailByIds(new Set<String>{'Id','Case_Comment_Work_Note__c'},new Set<Id>{ownerId});
        }else if(currQueueId != null){
            //queueUser = [select id,Name,user__c,User_Notification_Setup__c from Queue_User_Relationship__c where Name = :queryName and Type__c = 'User' ];
            queueUser = new SLT_QueueUserRelationshipC().selectByUserFromTECHQueueUser(new Set<Id>{currQueueId}, new Set<String> {'id','Name','user__c','User_Notification_Setup__c'});
        }
        if(userInfoValue.size() > 0 ){
            if(userInfoValue[0].Case_Comment_Work_Note__c !=null && (userInfoValue[0].Case_Comment_Work_Note__c.contains('Assignment - Bell')))
            {
                assignBell.add(userInfoValue[0].id);
            }
                
            if(userInfoValue[0].Case_Comment_Work_Note__c !=null && userInfoValue[0].Case_Comment_Work_Note__c.contains('Assignment - Email')){
                assignEmailUsers.add(userInfoValue[0].id);
            }
        }else if(queueUser != null && !queueUser.isEmpty()){
            for(Queue_User_Relationship__c dd :queueUser){
                if((dd.user__c !=null && dd.User_Notification_Setup__c != null) &&(dd.User_Notification_Setup__c.contains('Dispatch - Bell') )){
                    if(currQueueName == null){
                        currQueueName = dd.Name;  
                    }
                    owneridd.add(dd.user__c);
                }
                if(dd.user__c !=null && dd.User_Notification_Setup__c != null && dd.User_Notification_Setup__c.contains('Dispatch - Email')){
                    dispatchEmailUsers.add(dd.user__c);
                }
            }
        }
        if(owneridd != null && owneridd.size() > 0 && !System.isFuture() && !System.isBatch()){
            CustomNotificationRESTAPI.sendCustomNotificationAfter21Winter('NotificationBellForCaseComment', JSON.serialize(caseList),  JSON.serialize(owneridd),currQueueName ,'By Dispatch');
            //CustomNotificationRESTAPI.sendCustomNotification('NotificationBellForCaseComment', JSON.serialize(caseList),  JSON.serialize(owneridd),'By Dispatch');
        }
        if(assignBell != null && assignBell.size() >0 && !System.isFuture() && !System.isBatch()){
            CustomNotificationRESTAPI.sendCustomNotificationAfter21Winter('NotificationBellForCaseComment', JSON.serialize(caseList),  JSON.serialize(assignBell),null,'By Assign');
            //CustomNotificationRESTAPI.sendCustomNotification('NotificationBellForCaseComment', JSON.serialize(caseList),  JSON.serialize(assignBell),'By Assign');
        }
            
        if(assignEmailUsers != null && assignEmailUsers.size() > 0) {
            CNT_CSM_EmailNotification.sendEmailNotification(caseList,assignEmailUsers, 'Assign to User'); 
        }
        
        if(dispatchEmailUsers !=null && dispatchEmailUsers.size() >0){
            CNT_CSM_EmailNotification.sendEmailNotification(caseList,dispatchEmailUsers,'Dispatch to queue'); 
        }
        
        
    }

    public static boolean isEmailAlertSLAHaveSent = false;
    public static void sendEmailAlertSLA(List<Case> caseList,Map<Id, Case> oldMap) {
        if(!isEmailAlertSLAHaveSent) {
            String notificationBody = null;
            id queueName = null;
            string caseQueueID = null;
            List<User> userInfoValue = new List<User>();
            List<Queue_User_Relationship__c> queueUser = null;
            for(Case c : caseList) {
                if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T) { 
                    if(c.OwnerId !=null && oldMap !=null) {
                        if((oldMap.get(c.Id).NextMilestoneStatus__c == null && c.NextMilestoneStatus__c != null && c.NextMilestoneStatus__c == CON_CSM.S_REMAINING_2_HOURS) || (oldMap.get(c.Id).NextMilestoneStatus__c != null && c.NextMilestoneStatus__c != null && oldMap.get(c.Id).NextMilestoneStatus__c != CON_CSM.S_REMAINING_2_HOURS && c.NextMilestoneStatus__c == CON_CSM.S_REMAINING_2_HOURS)){
                            notificationBody = CON_CSM.S_REMAINING_2_HOURS;
                        }else if((oldMap.get(c.Id).NextMilestoneStatus__c == null && c.NextMilestoneStatus__c != null && c.NextMilestoneStatus__c == CON_CSM.S_REMAINING_8_HOURS) || (oldMap.get(c.Id).NextMilestoneStatus__c != null && c.NextMilestoneStatus__c != null && oldMap.get(c.Id).NextMilestoneStatus__c != CON_CSM.S_REMAINING_8_HOURS && c.NextMilestoneStatus__c == CON_CSM.S_REMAINING_8_HOURS)){
                            notificationBody = CON_CSM.S_REMAINING_8_HOURS;
                        }
                        if(notificationBody != null) {
                            caseQueueID = c.OwnerId;
                            if(caseQueueID.startsWith('00G')) {
                                queueName = c.CurrentQueue__c;
                            }
                        }
                    }
                }
            }
            if(caseQueueID !=null && !caseQueueID.startsWith('00G')) {
                userInfoValue   = new SLT_User().getUserDetailByIds(new Set<String>{'Id','Case_Comment_Work_Note__c'},new Set<Id>{caseQueueID});
            }else if(queueName != null){
                //queueUser = [select id,Name,user__c,User_Notification_Setup__c from Queue_User_Relationship__c where Name = :queryName and Type__c = 'User' ];
                queueUser = new SLT_QueueUserRelationshipC().selectByUserFromTECHQueueUser(new Set<Id>{queueName}, new Set<String> {'id','user__c','User_Notification_Setup__c'});
            }

            List<id> emailUsers = new List<id>();
            if(userInfoValue.size() > 0 ) {
                if(userInfoValue[0].Case_Comment_Work_Note__c !=null && userInfoValue[0].Case_Comment_Work_Note__c.contains('Milestone Alert - Email')) {
                    emailUsers.add(userInfoValue[0].id);
                }
            }else if(queueUser != null) {
                for(Queue_User_Relationship__c dd :queueUser) {
                    if(dd.user__c !=null && dd.User_Notification_Setup__c != null && dd.User_Notification_Setup__c.contains('Milestone Alert - Email')) {
                        emailUsers.add(dd.user__c);
                    }
                }
            }       
            if(emailUsers != null && emailUsers.size() > 0) {
                CNT_CSM_EmailNotification.sendEmailNotification(caseList,emailUsers, notificationBody);
            }
            isEmailAlertSLAHaveSent = true;
        }     
    }
    
    public static void deliverRnDAutomatedFollowUpMail(List<Case> caseList){
        if(caseList !=null && caseList.size()>0){
            List<Messaging.SingleEmailMessage> afuEmailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mailMessage = null;
            Set<Case> caseIdSet = new Set<Case>();
            List<String> toAddresses = null;
            Map<String, String> queueEmailMap = new Map<String, String>();
            Map<String, String> templateIdNameMap = new Map<String, String>();
            Map<String, String> orgWideEmailNameIdMap = new Map<String, String>();
            List<Queue_User_Relationship__c> queueUserList = null;
            List<EmailTemplate> emailTemplateList = null;
            List<OrgWideEmailAddress> orgWideEmailList = null;
            for(Case caseRecord : caseList){
                if((caseRecord.RecordTypeName__c == CON_CSM.S_R_D_V_T || caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE || caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && caseRecord.RnD_Email_Flag__c && caseRecord.LOS__c != null){
                    caseIdSet.add(caseRecord);
                }
            }
            if(caseIdSet != null && !caseIdSet.isEmpty()){
                queueUserList = new SLT_QueueUserRelationshipC().selectAllRnDQueues();
                if(queueUserList != null && !queueUserList.isEmpty()){
                    for(Queue_User_Relationship__c queueUserRecord : queueUserList){
                        queueEmailMap.put(queueUserRecord.Id, queueUserRecord.AFU_Queue_Email__c);
                    }
                    Set<String> templateNameSet = new Set<String>{CON_CSM.S_FIRST_AFU_WAITING_FOR, CON_CSM.S_SECOND_AFU_WAITING_FOR,
                        CON_CSM.S_FIRST_AFU_RESOLVED, CON_CSM.S_SECOND_AFU_RESOLVED, CON_CSM.S_LAB_FIRST_AFU_WAITING_FOR,
                        CON_CSM.S_LAB_SECOND_AFU_WAITING_FOR, CON_CSM.S_LAB_FIRST_AFU_RESOLVED, CON_CSM.S_LAB_SECOND_AFU_RESOLVED, 
                        CON_CSM.S_AM_FIRST_AFU_WAITING_FOR, CON_CSM.S_AM_SECOND_AFU_WAITING_FOR,CON_CSM.S_FIRST_AFU_DOC_QC,CON_CSM.S_SECOND_AFU_DOC_QC,CON_CSM.S_FIRST_AFU_Sandoz_LOS,CON_CSM.S_SECOND_AFU_Sandoz_LOS};
                    emailTemplateList = [SELECT Id, Name FROM EmailTemplate WHERE Name In :templateNameSet];
                    if(emailTemplateList != null && !emailTemplateList.isEmpty()){
                        for(EmailTemplate templateRecord : emailTemplateList){
                            templateIdNameMap.put(templateRecord.Name, templateRecord.Id);
                        }
                        orgWideEmailList = [SELECT Id, Address FROM OrgWideEmailAddress];
                        for(OrgWideEmailAddress orgWideRecord : orgWideEmailList){
                            orgWideEmailNameIdMap.put(orgWideRecord.Address, orgWideRecord.Id);
                        }
                        for(Case caseRecord : caseIdSet){
                            if((caseRecord.RecordTypeName__c == CON_CSM.S_R_D_V_T || caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE || caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && caseRecord.RnD_Email_Flag__c){
                                toAddresses = new List<String>();
                                if(caseRecord.AFU_Email_Addresses__c !=null && caseRecord.AFU_Email_Addresses__c != ''){
                                    for(String mailId : caseRecord.AFU_Email_Addresses__c.split(';')){
                                        toAddresses.add(mailId.trim());
                                    }
                                }
                                mailMessage = new Messaging.SingleEmailMessage();
                                if(caseRecord.Status.equalsIgnoreCase(CON_CSM.S_WAITING_FOR) && 
                                   (caseRecord.SubStatus__c.equalsIgnoreCase(CON_CSM.S_AFU_STANDARD) || caseRecord.SubStatus__c.equalsIgnoreCase(CON_CSM.S_AFU_URGENT))){
                                       if(caseRecord.Count_of_AFU__c != null && caseRecord.Count_of_AFU__c == 1){
                                           if(caseRecord.LOS__c == CON_CSM.S_Q2_Lab || caseRecord.LOS__c == CON_CSM.S_Q2_INV_SITE){
                                               mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_LAB_FIRST_AFU_WAITING_FOR));
                                           }
                                           else if(caseRecord.LOS__c == CON_CSM.S_ACCOUNT_MANAGEMENT){
                                               mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_AM_FIRST_AFU_WAITING_FOR));
                                           }
                                           else if(caseRecord.LOS__c == CON_CSM.S_DOCUMENTQC){
                                                mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_FIRST_AFU_DOC_QC));
                                           }
                                           else if(caseRecord.LOS__c == CON_CSM.S_SandozLab || caseRecord.LOS__c == CON_CSM.S_SandozFeedback){
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_FIRST_AFU_Sandoz_LOS));
                                            }
                                           else{
                                               mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_FIRST_AFU_WAITING_FOR));
                                           }
                                       }
                                       else if(caseRecord.Count_of_AFU__c != null && caseRecord.Count_of_AFU__c == 2){
                                           if(caseRecord.LOS__c == CON_CSM.S_Q2_Lab || caseRecord.LOS__c == CON_CSM.S_Q2_INV_SITE){
                                               mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_LAB_SECOND_AFU_WAITING_FOR));
                                           }
                                           else if(caseRecord.LOS__c == CON_CSM.S_ACCOUNT_MANAGEMENT){
                                               mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_AM_SECOND_AFU_WAITING_FOR));
                                           }
                                           else if(caseRecord.LOS__c == CON_CSM.S_DOCUMENTQC){
                                                mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_SECOND_AFU_DOC_QC));
                                           }
                                           else if(caseRecord.LOS__c == CON_CSM.S_SandozLab || caseRecord.LOS__c == CON_CSM.S_SandozFeedback){
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_SECOND_AFU_Sandoz_LOS));
                                            }
                                           else{
                                               mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_SECOND_AFU_WAITING_FOR));
                                           }
                                       }
                                   }
                                else if(caseRecord.Status.equalsIgnoreCase(CON_CSM.S_RESOLVED) && caseRecord.SubStatus__c.equalsIgnoreCase(CON_CSM.S_AFU)){
                                    if(caseRecord.Count_of_AFU__c != null && caseRecord.Count_of_AFU__c == 1){
                                        if(caseRecord.LOS__c == CON_CSM.S_Q2_Lab || caseRecord.LOS__c == CON_CSM.S_Q2_INV_SITE){
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_LAB_FIRST_AFU_RESOLVED));
                                        }else if(caseRecord.LOS__c == CON_CSM.S_SandozLab || caseRecord.LOS__c == CON_CSM.S_SandozFeedback){
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_FIRST_AFU_Sandoz_LOS));
                                        }else{
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_FIRST_AFU_RESOLVED));
                                        }
                                    }
                                    else if(caseRecord.Count_of_AFU__c != null && caseRecord.Count_of_AFU__c == 2){
                                        if(caseRecord.LOS__c == CON_CSM.S_Q2_Lab || caseRecord.LOS__c == CON_CSM.S_Q2_INV_SITE){
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_LAB_SECOND_AFU_RESOLVED));
                                        }else if(caseRecord.LOS__c == CON_CSM.S_SandozLab || caseRecord.LOS__c == CON_CSM.S_SandozFeedback){
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_SECOND_AFU_Sandoz_LOS));
                                        }else{
                                            mailMessage.setTemplateId(templateIdNameMap.get(CON_CSM.S_SECOND_AFU_RESOLVED));
                                        }
                                    }
                                }
                                if(caseRecord.ContactId != null || toAddresses.size() > 0 ){
                                    if(caseRecord.ContactId != null){
                                        mailMessage.setTargetObjectId(caseRecord.ContactId); 
                                    }else{
                                        mailMessage = Messaging.renderStoredEmailTemplate(mailMessage.getTemplateId(), UserInfo.getUserId(), caseRecord.Id);
                                    }
                                    
                                    if(toAddresses.size() > 0){
                                        mailMessage.setToAddresses(toAddresses);
                                        mailMessage.setTreatTargetObjectAsRecipient(false);
                                    }
                                   
                                    mailMessage.setSaveAsActivity(false);
                                    mailMessage.setWhatId(caseRecord.Id);
                                    mailMessage.setReferences(Cases.generateThreadingMessageId(caseRecord.Id));
                                    mailMessage.setReplyTo(queueEmailMap.get(caseRecord.CurrentQueue__c));
                                    mailMessage.setOrgWideEmailAddressId(orgWideEmailNameIdMap.get(queueEmailMap.get(caseRecord.CurrentQueue__c)));
                                    afuEmailList.add(mailMessage);
                                }
                                caseRecord.RnD_Email_Flag__c = false;
                            }
                        }
                    }
                }
                
                if(afuEmailList != null && afuEmailList.size() > 0) {
                    try{
                        Messaging.sendEmail(afuEmailList);
                        String caseSet = JSON.serialize(caseIdSet);
                        saveActivityOnOutboundMail(caseSet);
                    }
                    catch(Exception ex){
                        ex.getMessage();
                    }
                }
            }
        }
    }
    
    public static void checkAFUNextCloseDate(List<Case> caseList,Map<Id, Case> oldMap) {
        List<String> statusList = new List<String>{CON_CSM.S_CASE_CLOSED, CON_CSM.S_CASE_ABANDONED, CON_CSM.S_RESOLVED_WITH_C, CON_CSM.S_MERGED};
        boolean afuCheck = false;
        for(Case c :caseList ){
            if((c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && c.Status == CON_CSM.S_CLOSED && oldMap != null && oldMap.get(c.Id) != null && oldMap.get(c.Id).SubStatus__c != c.SubStatus__c && (oldMap.get(c.Id).SubStatus__c == 'Automated FU - Standard' || oldMap.get(c.Id).SubStatus__c == 'Automated FU - Urgent' || oldMap.get(c.Id).SubStatus__c == 'Automated FU')){
                   c.AutoClosed__c = true;
            }
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && 'Problem' == c.Case_Type__c && c.SubStatus__c == CON_CSM.S_SS_CI && c.Status == CON_CSM.S_CASE_CLOSED){
                if(c.Count_of_AFU__c == 3){
                    c.AFU_Email_Flag__c = True;
                    c.Status = oldMap.get(c.id).Status;
                }else{
                    c.Status = CON_CSM.S_IN_PROGRESS;
                    c.SubStatus__c = null;
                    c.AFU_Tech__c = False;
                    c.Count_of_AFU__c = null;   
                }
            }else if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.AFU_TECH__c && c.Count_of_AFU__c == 3 && c.Status == CON_CSM.S_CASE_CLOSED){
                c.AFU_Email_Flag__c = True;
                c.Status = oldMap.get(c.id).Status;
            }else if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && 'Problem' == c.Case_Type__c && oldMap.get(c.id).Status == CON_CSM.S_IN_PROGRESS && c.Status == CON_CSM.S_CASE_CLOSED){
                c.Status = oldMap.get(c.id).Status;
            }else if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Count_of_AFU__c == 4 && c.Status == CON_CSM.S_CASE_CLOSED){
                if(!c.AFU_TECH__c){
                    afuCheck = true;
                }
                c.AutoClosed__c = true;
                c.SubStatus__c = 'Closed by Automation';
            }else if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.AFU_TECH__c && statusList.contains(c.Status)){
                afuCheck = true;
            }
            if(oldMap.get(c.id).Count_of_AFU__c == c.Count_of_AFU__c){
                c.AFU_Email_Flag__c = False;   
            }
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.AFU_TECH__c == false){
                //c.Count_of_AFU__c = null;
                afuCheck = true;
            }
            if(afuCheck){
                c.AFU_Next_Date__c = null;
                c.AFU_TECH__c = false;
                c.Count_of_AFU__c = null;
                c.AFU_TimeStamp__c = null;
                c.AFU_Email_Flag__c = false;
                c.AFU_Close_Date__c = null;
            }
        }
    }

    public static void checkAFUOpenChildCase(List<Case> caseList,Map<Id, Case> oldMap,Profile profile) {
        Set<Id> caseIds = new Set<Id>();
        Set<Id> parentcaseIds = new Set<Id>();
        DateTime dT;
        Date created = null;
        Date newDate = Date.newInstance(2020, 06, 01);
        for(Case caseRecord :caseList ){
            if(caseRecord.CreatedDate != null){
                dT = caseRecord.CreatedDate;
                created = Date.newinstance(dT.year(), dT.month(), dT.day());
            }
            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && ( created > newDate || created == null) && (oldMap != null && caseRecord.CSAT_Reviewed__c == oldMap.get(caseRecord.Id).CSAT_Reviewed__c) && (oldMap != null && oldMap.get(caseRecord.Id).AFU_TECH__c != caseRecord.AFU_TECH__c)){
                if(hasCustomPermission == false && caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (caseRecord.ContactEmail == null || String.isBlank(caseRecord.ContactEmail)) && caseRecord.AFU_TECH__c){
                    caseRecord.addError('It is not possible to turn on Automated Follow Up on this case because contact email is empty.');
                }else if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && caseRecord.ParentId != null  && oldMap != null && oldMap.get(caseRecord.Id).Status != CON_CSM.S_RESOLVED_WITH_C){
                    parentcaseIds.add(caseRecord.ParentId);
                }else if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (oldMap != null && caseRecord.AFU_TECH__c != oldMap.get(caseRecord.Id).AFU_TECH__c && caseRecord.AFU_TECH__c)){
                    caseIds.add(caseRecord.Id);   
                }  
              }
            // Set Internal Follow Up based on Priority
            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T ){                             
                    if((caseRecord.Set_Internal_Follow_Up_from_Priority__c && Trigger.IsInsert) || (caseRecord.Set_Internal_Follow_Up_from_Priority__c  && oldMap != null && oldMap.get(caseRecord.Id) != null && (caseRecord.Priority != oldMap.get(caseRecord.Id).Priority ||caseRecord.Set_Internal_Follow_Up_from_Priority__c != oldMap.get(caseRecord.Id).Set_Internal_Follow_Up_from_Priority__c))){
                                caseRecord.Internal_Follow_Up_to_be_Performed_by__c = UserInfo.getUserId();   
                                dt = DateTime.now();
                                String dayOfWeek = dt.format('E');
                                if(caseRecord.Priority == 'Priority 1'){
                                    if(dayOfWeek == 'Mon' || dayOfWeek == 'Tue' || dayOfWeek == 'Wed' || dayOfWeek == 'Thu'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(1);
                                    }else if(dayOfWeek == 'Fri'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(3);
                                    }
                                }else if(caseRecord.Priority == 'Priority 2'){
                                    if(dayOfWeek == 'Mon' || dayOfWeek == 'Tue' || dayOfWeek == 'Wed'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(2);
                                    }else if(dayOfWeek == 'Thu' || dayOfWeek == 'Fri'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(4);
                                    }
                                }else if(caseRecord.Priority == 'Priority 3'){
                                    if(dayOfWeek == 'Mon' || dayOfWeek == 'Tue'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(3);
                                    }else if(dayOfWeek == 'Wed' || dayOfWeek == 'Thu' || dayOfWeek == 'Fri'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(5);
                                    }
                                }else if(caseRecord.Priority == 'Priority 4'){
                                    if(dayOfWeek == 'Mon'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(4);
                                    }else if(dayOfWeek == 'Tue' || dayOfWeek == 'Wed' || dayOfWeek == 'Thu' || dayOfWeek == 'Fri'){
                                        caseRecord.Internal_Follow_Up__c = dt.addDays(6);
                                    }
                                }
                    
                }else if(caseRecord.Internal_Follow_Up__c != null && oldMap != null && oldMap.get(caseRecord.Id) != null && caseRecord.Internal_Follow_Up__c != oldMap.get(caseRecord.Id).Internal_Follow_Up__c){
                    caseRecord.Internal_Follow_Up_to_be_Performed_by__c = UserInfo.getUserId();   
                    caseRecord.Set_Internal_Follow_Up_from_Priority__c = false;
                }else if(!caseRecord.Set_Internal_Follow_Up_from_Priority__c && Trigger.IsInsert && caseRecord.Internal_Follow_Up__c != null){
                    caseRecord.Internal_Follow_Up_to_be_Performed_by__c = UserInfo.getUserId();
                }
                    
            }  
            
            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && caseRecord.Internal_Follow_Up_to_be_Performed_by__c != null && caseRecord.Internal_Follow_Up__c == null){
                caseRecord.Internal_Follow_Up_to_be_Performed_by__c = null;
                caseRecord.Internal_Follow_Up__c = null;
            }
        }
        if((caseIds.size() > 0 || parentcaseIds.size() > 0 ) && profile != null && profile.Name != null && !profile.Name.containsIgnoreCase('admin')){
            List<Case> parentChildCaseList = new SLT_Case().getParentChildCase(caseIds,parentcaseIds);        
            if(parentChildCaseList.size() > 0){
                for(Case caseRecord :caseList ){
                    if(hasCustomPermission == false && caseRecord.Id == parentChildCaseList[0].ParentId){
                        caseRecord.addError('It is not possible to turn on Automated Follow Up on this case because at least one child case remain open.');
                    }
                    if(hasCustomPermission == false && caseRecord.ParentId == parentChildCaseList[0].Id){
                        caseRecord.addError('Parent case Automated Follow Up is turn on or Parent Case is closed or Merged so it is not possible to assign it as Parent case.');
                    }
                }
            }
        }
    }

    public static void restrictQueueForDispatch(List<Case> caseList,Map<Id, Case> oldMap) {
        Set<Id> sorQList = new Set<Id>();
        Set<Id> destQList = new Set<Id>();
        Map<Id,String> allowMap = new Map<Id,String>();
        Map<Id,String> restrictMap = new Map<Id,String>();
        Map<String,String> restrictProdMap = new Map<String,String>();
        Boolean checkAllow = false,checkRestrict = false;
        for(Case c : caseList){
            if(c.RecordTypeName__c != null && oldMap != null && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c){
                sorQList.add(oldMap.get(c.Id).CurrentQueue__c);
                destQList.add(c.CurrentQueue__c);
            }
        }
        if(!sorQList.isEmpty() && !destQList.isEmpty()){
            List<CSM_Queue_Dispatch_Case_Permissions__c> disBlackList = Database.query('select Id, Type__c, Order__c, IsActive__c,Source_Queue__c, Destination_Queue__c, RecordType_Name__c, Products__c from CSM_Queue_Dispatch_Case_Permissions__c WHERE IsActive__c = true AND ((Source_Queue__c in :sorQList AND Destination_Queue__c in :destQList AND Type__c =\'Restrict\') OR (Destination_Queue__c in :destQList AND Type__c =\'Allow\'))');
            if(disBlackList != null && !disBlackList.isEmpty()){
                for(CSM_Queue_Dispatch_Case_Permissions__c d : disBlackList){
                    if(d.Type__c == 'Allow'){
                       allowMap.put(d.Destination_Queue__c,d.RecordType_Name__c+'~'+d.Source_Queue__c+'~'+d.Destination_Queue__c);
                    }else if(d.Type__c == 'Restrict'){
                        restrictMap.put(d.Source_Queue__c,d.RecordType_Name__c+'~'+d.Source_Queue__c+'~'+d.Destination_Queue__c);
                        if(d.Products__c != null){
                            restrictProdMap.put(d.RecordType_Name__c+'~'+d.Source_Queue__c+'~'+d.Destination_Queue__c,d.Products__c);
                        }
                    }
                }
            }
        }
        for(Case c : caseList){
            if(!allowMap.isEmpty() && allowMap.containsKey(c.CurrentQueue__c)){
                checkAllow = true;
                if(allowMap.get(c.CurrentQueue__c) == (c.RecordTypeName__c+'~'+oldMap.get(c.Id).CurrentQueue__c+'~'+ c.CurrentQueue__c)){
                     checkAllow = false;
                }
            }else if(c.ProductName__c != null &&!restrictMap.isEmpty() && restrictMap.containsKey(oldMap.get(c.Id).CurrentQueue__c) && restrictMap.get(oldMap.get(c.Id).CurrentQueue__c) == (c.RecordTypeName__c+'~'+oldMap.get(c.Id).CurrentQueue__c+'~'+ c.CurrentQueue__c) && !restrictProdMap.isEmpty() && restrictProdMap.containsKey(c.RecordTypeName__c+'~'+oldMap.get(c.Id).CurrentQueue__c+'~'+ c.CurrentQueue__c) && restrictProdMap.get(c.RecordTypeName__c+'~'+oldMap.get(c.Id).CurrentQueue__c+'~'+ c.CurrentQueue__c).split(';').contains(c.ProductName__c)){
                checkRestrict = true;
            }else if(!restrictMap.isEmpty() && restrictMap.containsKey(oldMap.get(c.Id).CurrentQueue__c) && restrictMap.get(oldMap.get(c.Id).CurrentQueue__c) == (c.RecordTypeName__c+'~'+oldMap.get(c.Id).CurrentQueue__c+'~'+ c.CurrentQueue__c) && (restrictProdMap.isEmpty() || (!restrictProdMap.isEmpty() && !restrictProdMap.containsKey(c.RecordTypeName__c+'~'+oldMap.get(c.Id).CurrentQueue__c+'~'+ c.CurrentQueue__c)))){
                checkRestrict = true;
            }
            if(hasCustomPermission == false && (checkRestrict || checkAllow)){
                c.addError(label.CSM_Disptach_Black_list_Queue);
            }
        }
            
        /*for(Case c : caseList){
            for(CSM_Dispatch_BlackList_Queue__c cd : csForDispatch ){ 
                if(c.RecordTypeName__c == 'TechnologyCase' && c.CurrentQueue__c != null && ((oldMap == null &&  c.CurrentQueue__c == cd.CurrentQueue_ID__c) || (oldMap != null && oldMap.get(c.Id) != null && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c && oldMap.get(c.Id).CurrentQueue__c == cd.CurrentQueue_ID__c)))
                {
                    if(cd.Product__c != null && c.ProductName__c != null && cd.Product__c.Contains(c.ProductName__c)){
                        idMap.put(c.CurrentQueue__c,c.Id);
                    }
                }
            }
        } 
        Map<Id,Queue_User_Relationship__c> queueMap;
        if(!idMap.isEmpty()){
            queueMap = new SLT_QueueUserRelationshipC().selectByQueueId(idMap.keySet(),new Set<String>{'Id','Name'});
        }
        if(queueMap != null && queueMap.size() > 0){
            for(Case c : caseList){
                checkValidation = false;
                for(CSM_Dispatch_BlackList_Queue__c csv : csForDispatch ){
                    if(c.RecordTypeName__c == 'TechnologyCase' && c.CurrentQueue__c != null && ((oldMap == null &&  c.CurrentQueue__c == csv.CurrentQueue_ID__c) || (oldMap != null && oldMap.get(c.Id) != null && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c && oldMap.get(c.Id).CurrentQueue__c == csv.CurrentQueue_ID__c)))
                    {
                        String[] TierQueue = csv.Tier_Escalation__c.split(',');
                        for(String queueName : TierQueue ){
                            if(queueMap.get(c.CurrentQueue__c).Name.Contains(queueName)){ 
                                checkValidation = true;  
                                break;
                            }
                        }
                        
                    }
                }
                if(hasCustomPermission == false && checkValidation){
                    c.addError(label.CSM_Disptach_Black_list_Queue);
                }
            }
        }*/
    }
    
    public static void stopCaseCreationLoopOnAutoReply(List<Case> caseList) {
        if(Test.isRunningTest() || CON_CSM.S_SYSTEM == userInfo.getName()) {
            List<Case> recentCasesList = new SLT_Case().getCasesEmailtoCase();
            List<Queue_User_Relationship__c> bypassQueue = new SLT_Case().getBypassQueueForEmailToCase(caseList[0].CurrentQueue__c);
            if(recentCasesList.size() > 0){
                for(Case caseRecord : caseList){
                    if(bypassQueue.size() > 0 && bypassQueue[0].Bypass_Duplicate_E2C_VR__c == false && (caseRecord.RecordTypeName__c == CON_CSM.S_R_D_CTP || caseRecord.RecordTypeName__c == CON_CSM.S_R_D_CDP || caseRecord.RecordTypeName__c == CON_CSM.S_R_D_V_T || caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE)){
                        for(Case oldCase : recentCasesList){
                            DateTime current = System.now();
                            Decimal seconds = ((current.getTime())/1000) - ((oldCase.CreatedDate.getTime())/1000);
                            if(hasCustomPermission == false && !Test.isRunningTest() && (seconds <= 60 && CON_CSM.S_EMAIL.equals(oldCase.Origin))){
                                if((((oldCase.Subject == null || oldCase.Subject == '') && (caseRecord.Subject == null || caseRecord.Subject == '')) || (caseRecord.Subject != null && caseRecord.Subject == oldCase.Subject)) && (caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE)  && caseRecord.Origin == CON_CSM.S_EMAIL){
                                    caseRecord.addError('It is not possible to create multiple duplicate Case');
                                }else if(caseRecord.Subject != null && caseRecord.Subject == oldCase.Subject && caseRecord.Description != null && caseRecord.Description == oldCase.Description && caseRecord.Origin == CON_CSM.S_EMAIL){
                                    caseRecord.addError('It is not possible to create multiple duplicate Case');
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void caseRecordReadOnlyforQueueUsers(List<Case> caseList,Map<Id, Case> oldMap) {
        Set<Id> queueIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        List<Queue_User_Relationship__c> quList = new List<Queue_User_Relationship__c>();
        List<String> removeField = new List<String>{'ownerid','currentqueue__c','CaseUpdatedTime__c','caseownermodifieddate__c','taskmilestone__c','assigncasetocurrentuser__c','asemodifiedtime__c', 'current_queue_name__c', 'statuschangedtime__c','previous_queue__c','is_study_attached_first_time__c','randd_location__c'};
        for(Case c :caseList){
            if((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE)){
                 caseIds.add(c.Id);
             }
        }
        if(!caseIds.isEmpty()){
            quList = new SLT_QueueUserRelationshipC().selectByUserCaseReadOnlySet(new Set<Id>{UserInfo.getUserId()});
            for(Queue_User_Relationship__c qur : quList){
                queueIds.add(qur.Id);
                queueIds.add(qur.TECH_QueueUser__c);
                queueIds.add(qur.Group_Id__c);
            }    
        }
        
        for(Case c :caseList){
            List<String> listOfUpdFlds = getUpdatedFieldsName();
            for(Integer index = (listOfUpdFlds.size()-1); index >= 0 ;index--) {               
                if(removeField.contains(listOfUpdFlds.get(index).trim())) {
                    listOfUpdFlds.remove(index);
                }
            }
            if(hasCustomPermission == false && !queueIds.isEmpty() && (c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE)){
                /** if(c.ownerId != null && String.valueOf(c.ownerId).startsWith(CON_CSM.S_QUEUE_ID) && queueIds.contains(c.ownerId) && c.CurrentQueue__c == oldMap.get(c.Id).CurrentQueue__c){
                    c.addError('Please Take Ownership of '+c.CaseNumber+' case before modify.');
                }else */
                if((!queueIds.contains(c.CurrentQueue__c) && listOfUpdFlds.size() >= 1 && c.CurrentQueue__c == oldMap.get(c.Id).CurrentQueue__c) || (!queueIds.contains(oldMap.get(c.Id).CurrentQueue__c) && c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c) ){
                    c.addError('You do not have permission to update '+c.CaseNumber+' case based on your user permission.');
                }
            } 
        }
    }
    
    public static void checkForCRCAlertCaseProtocol(List<Case> newList){
        List<Case> caseList = new List<Case>();
        List<Case> caseList2 = new List<Case>();
        List<Case> caseListStudy = new List<Case>();
        Set<String> protocolSet = new Set<String>();
        Set<String> protocolNameSet = new Set<String>();
        Set<String> siteNumberSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        for(Case caseRecord : newList){
            if((caseRecord.Origin == CON_CSM.S_O_ES && caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T && caseRecord.CRC_Issue_Insert_Date_time__c != null) ||
               (caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE && caseRecord.Owner__c != null && caseRecord.Owner__c== 'LTMS'  )){
                   caseList.add(caseRecord);
                   protocolSet.add(caseRecord.StudyProtocolName__c);
                   if(caseRecord.SuppliedEmail != null && (caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE && caseRecord.Owner__c != null && caseRecord.Owner__c== 'LTMS')){
                       emailSet.add(caseRecord.SuppliedEmail);
                   }
               }
        }
        if(emailSet != null && !emailSet.isEmpty()){
            List<Contact> conList = new SLT_Contact().selectByEmailIdSet(emailSet);
            if(conList != null && conList.size() == 1 ){
                for(Case c : newList){
                    c.ContactId = conList[0].Id;
                }
            }
        }
        if(caseList != null && protocolSet != null && !caseList.isEmpty() && !protocolSet.isEmpty()){
            List<Study__c> studyList = new SLT_StudyC().selectStudyBasedOnProtocol(protocolSet);
            if(studyList != null && !studyList.isEmpty()){
                Map<String, Id> protocolStudyIdMap = new Map<String, Id>();
                for(Study__c studyRecord : studyList){
                    protocolStudyIdMap.put(studyRecord.Protocol__c, studyRecord.Id);
                }
                if(protocolStudyIdMap != null && !protocolStudyIdMap.isEmpty()){
                    for(Case caseRecord : caseList){
                        if(protocolStudyIdMap.containsKey(caseRecord.StudyProtocolName__c)){
                            caseRecord.Study__c = protocolStudyIdMap.get(caseRecord.StudyProtocolName__c);
                        }
                    }
                }
            }
        }
        
        //Populate Study based on Name for LTMS process
        for(Case caseRecord : newList){
            if(caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE && caseRecord.Owner__c != null && caseRecord.Owner__c== 'LTMS'  ){
                caseListStudy.add(caseRecord);
                protocolNameSet.add(caseRecord.StudyProtocolName__c);
            }
        }
        
        if(caseListStudy != null && protocolNameSet != null && !caseListStudy.isEmpty() && !protocolNameSet.isEmpty()){
            List<Study__c> studyList = new SLT_StudyC().selectStudyBasedOnName(protocolNameSet);
            if(studyList != null && !studyList.isEmpty()){
                Map<String, Id> protocolStudyIdMap = new Map<String, Id>();
                for(Study__c studyRecord : studyList){
                    protocolStudyIdMap.put(studyRecord.Name, studyRecord.Id);
                }
                if(protocolStudyIdMap != null && !protocolStudyIdMap.isEmpty()){
                    for(Case caseRecord : caseListStudy){
                        if(protocolStudyIdMap.containsKey(caseRecord.StudyProtocolName__c)){
                            caseRecord.Study__c = protocolStudyIdMap.get(caseRecord.StudyProtocolName__c);
                        }
                    }
                }
            }
        }
        
        
        
        // Populate Site_Related_to_the_Study__c based on SiteNumber and Study(assigned to case.Study__c field above)
        Set<String> studySiteCombinations = new Set<String>();
        CSM_Case_Details_Global_Setting__c setting = CSM_Case_Details_Global_Setting__c.getInstance('LTMS_Special_Char');
        String[] settingTypeArray;
        String settingType;
        if (setting != null) {
            settingType = setting.Setting_Type__c;
            if (settingType != null){
                settingTypeArray = settingType.split(',');
            }
        }
        
        for(Case caseRecord : caseList){
            if(caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE && caseRecord.Owner__c != null && caseRecord.Owner__c== 'LTMS'  ){  
                if (settingTypeArray != null && settingTypeArray.size() > 0){
                    caseRecord.Description = removeSpecialCharFromString(caseRecord.Description,settingTypeArray); // Update the Case record with the modified description
                }
                if (caseRecord.Study__c != null && caseRecord.Site_Number__c != null) {
                    studySiteCombinations.add(caseRecord.Study__c + '_' + caseRecord.Site_Number__c);
                    caseList2.add(caseRecord);
                }
            }
        }
        
        if(caseList2 != null && studySiteCombinations != null && !caseList2.isEmpty() && !studySiteCombinations.isEmpty()){
            Map<String, Id> studySiteRelationshipMap = new Map<String, Id>();
            String query = 'SELECT Id, Study__c, SiteNumber__c FROM StudySiteContactRelationship__c WHERE ';
            for (String combination : studySiteCombinations) {
                List<String> studyAndSite = combination.split('_');
                query += '(Study__c = \'' + studyAndSite[0] + '\' AND SiteNumber__c = \'' + studyAndSite[1] +'\') OR ';
            }
            query = query.subString(0, query.length() - 4); // Remove the last ' OR ' from the query
            List<StudySiteContactRelationship__c> studySiteContactList = Database.query(query); // Execute the dynamic SOQL query          
            for (StudySiteContactRelationship__c relationship : studySiteContactList) {
                studySiteRelationshipMap.put(relationship.Study__c + '_' + relationship.SiteNumber__c, relationship.Id);
            }
            for (Case c : caseList2) {
                String key = c.Study__c + '_' + c.Site_Number__c;
                if (studySiteRelationshipMap.containsKey(key)) {
                    c.Site_Related_to_the_Study__c = studySiteRelationshipMap.get(key);
                }
            }
        }
        
        
    }
    
    
    
    
    public static string removeSpecialCharFromString(string caseDescription,String[] settingTypeArray){
        for(String type : settingTypeArray) {
            List<String> typeParts = type.split(':');
            if(caseDescription != null && typeParts.size() == 2) {
                caseDescription = caseDescription.replace(typeParts[0], typeParts[1]);
            } else if(caseDescription != null && typeParts.size() == 1) {
                caseDescription = caseDescription.replace(typeParts[0], '');
            }
        }
        return caseDescription;
    }
    
    
    public static void setCRCAlertCaseDetails(List<Case> newList){
        List<Case> caseList = new List<Case>();
        for(Case caseRecord : newList){
            if(caseRecord.CRC_Issue_Insert_Date__c != null && caseRecord.CRC_Issue_Insert_Time__c != null){
                caseList.add(caseRecord);
            }
        }
        if(caseList != null && !caseList.isEmpty()){
            Id ActivityPlanRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
            List<Queue_User_Relationship__c> queueList = new SLT_QueueUserRelationshipC().selectByQueueName(new Set<String>{'RnD - Global CRC Alert','RnD - GCC Global CRC Alert'});
            for(Case caseRecord : caseList){
                if(caseRecord.CRC_Issue_Insert_Date__c != null && caseRecord.CRC_Issue_Insert_Time__c != null){
                    caseRecord.LOS__c = 'CRC Lab';
                    caseRecord.RecordTypeId = ActivityPlanRecordTypeId;
                    caseRecord.Origin = CON_CSM.S_O_ES;
                    caseRecord.OwnerId = queueList[0].Group_Id__c;
                    caseRecord.CurrentQueue__c = queueList[0].Id;
                    String subject = caseRecord.CRC_Issue_Insert_Date__c+', '+caseRecord.LabProjectCode__c+', '+caseRecord.StudyProtocolName__c+', '
                        +caseRecord.CRC_Account_Number__c+', '+caseRecord.AccessionNumber__c+', '+caseRecord.CRC_Order_Unit__c+', '
                        +caseRecord.CRC_Item__c+', '+caseRecord.CRC_Alert_Category__c;
                    caseRecord.Subject = subject;
                    try{
                        String[] dateArray = caseRecord.CRC_Issue_Insert_Date__c.split('-');
                        Integer year = Integer.valueOf(dateArray[0]);
                        Integer month = Integer.valueOf(dateArray[1]);
                        Integer day = Integer.valueOf(dateArray[2]);
                        String[] timeArray = caseRecord.CRC_Issue_Insert_Time__c.split(' ');
                        String[] hourMinuteArray = timeArray[0].split(':');
                        Integer hour = Integer.valueOf(hourMinuteArray[0]);
                        Integer minute = Integer.valueOf(hourMinuteArray[1]);
                        if(hour<12 && timeArray[1].toLowerCase() == 'pm'){
                            hour += 12;
                        }else if(hour == 12 && timeArray[1].toLowerCase() == 'am'){
                            hour = 0;
                        }
                        caseRecord.CRC_Issue_Insert_Date_time__c = Datetime.newInstance(year, month, day, hour, minute, 0);
                    }catch(Exception e){  
                    }
                }
            }
        }
    }
    
    public static String replaceNewLine(String str){
        String rNL = str.replace('\r\n', '');
        rNL = rNL.replace('\n', '');
        rNL = rNL.replace('\r','');
        return rNL.escapeUnicode();
    }

    public static void updateCaseMilestoneForClosedCase(List<Case> newList, Map<Id, Case> oldCaseMap){
        Set<Id> caseIds = new Set<Id>();
        for(Case caseRecord : newList){
            if(caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)){
                if(caseRecord.Status == CON_CSM.S_CLOSED && caseRecord.SlaExitDate == NULL){
                    caseIds.add(caseRecord.Id);
                }
            }
        }
        
        if(caseIds != null && !caseIds.isEmpty()){
            List<CaseMilestone> caseMilestoneList = [SELECT Id, CompletionDate FROM CaseMilestone WHERE CaseId IN :caseIds AND MilestoneType.Name = :CON_CSM.S_RESOLUTION_TIME AND CompletionDate = null];
            if(caseMilestoneList != null && !caseMilestoneList.isEmpty()){
                for(CaseMilestone cmRecord : caseMilestoneList){
                    cmRecord.CompletionDate = System.now();
                }
                try{
                    update caseMilestoneList;
                }
                catch(Exception ex){
                    ex.getStackTraceString();
                }
            }
        }
    }
    
    public static void preventCaseCreationFromOOOE2C(List<Case> newList){
        List<CSM_Email_To_Case_Custom_Settings__c> e2cSettings = null;
        boolean e2cExclude = true;
        String queueName = null,recordTypeName = null;
        List<String> e2cMessageList = new List<String>();
        List<String> e2cKAList = new List<String>();
        Map<String,String> e2cPriorityMap = new Map<String,String>();
        List<String> e2cMir3KAList = new List<String>();
        for(Case c : newList){
            if(CON_CSM.S_SYSTEM == Userinfo.getName()){
                queueName = c.InitialQueue__c;
                recordTypeName = c.RecordTypeName__c;
            }
            
        }
        if(queueName != null){
            e2cSettings = DataBase.query('select Id, Priority__c, RecordTypeName__c, Exclude_MessageList__c, Keyword_Assignment__c, E2C_Address__c, Queue_User_Relationship__c, Group_Id__c,Queue_Name__c,Type__c from CSM_Email_To_Case_Custom_Settings__c where Queue_Name__c = :queueName OR (Type__c =\'Prevent Creation\' AND RecordTypeName__c =:recordTypeName)');
            if(e2cSettings != null && !e2cSettings.isEmpty()){
                for(CSM_Email_To_Case_Custom_Settings__c e2c : e2cSettings){
                    if(e2c.Keyword_Assignment__c != null && e2c.Queue_User_Relationship__c != null && e2c.Type__c == 'Mir3 SMS Notification'){
                        e2cMir3KAList = e2c.Keyword_Assignment__c.split(';');
                    }else if(e2c.Priority__c != null && e2c.Keyword_Assignment__c != null && e2c.Queue_User_Relationship__c != null && e2c.Type__c == 'Priority Automation'){
                        e2cPriorityMap.put(e2c.Queue_Name__c, e2c.Priority__c);
                        e2cKAList = e2c.Keyword_Assignment__c.split(';');
                    }else if(e2c.Exclude_MessageList__c && e2c.Keyword_Assignment__c != null && e2c.Type__c != 'Priority Automation' && e2c.Type__c != 'Prevent Creation'){
                        e2cMessageList = e2c.Keyword_Assignment__c.split(';');
                    }else if(e2c.Exclude_MessageList__c && e2c.Queue_User_Relationship__c != null && e2c.Type__c != 'Priority Automation' && e2c.Type__c != 'Prevent Creation'){
                        e2cExclude =  !e2c.Exclude_MessageList__c;
                    }else if(e2c.Type__c == 'Prevent Creation'){
                        e2cMessageList = e2c.Keyword_Assignment__c.split(';');
                    }
                }
            }
        } 
        
        if(e2cExclude){
            for(Case c : newList){
                if(c.Origin == CON_CSM.S_EMAIL && c.Subject != null){
                    if(!e2cMir3KAList.isEmpty()){
                        for(String e : e2cMir3KAList){
                            if(e != null && c.Subject.containsIgnoreCase(e)){
                                c.Owner__c = 'Mir3 SMS Notification';
                                break;
                            }
                        }  
                    }
                    if(e2cPriorityMap.containsKey(c.InitialQueue__c) && !e2cKAList.isEmpty()){
                        for(String e : e2cKAList){
                            if(e != null && hasCustomPermission == false && (c.Subject.containsIgnoreCase(e) || (c.Description != null && c.Description.containsIgnoreCase(e)))){
                                c.Priority = e2cPriorityMap.get(c.InitialQueue__c);
                                break;
                            }
                        }
                    }
                    for(String e2cRecord : e2cMessageList){
                        if(e2cRecord != null){
                            if(e2cRecord.containsIgnoreCase(c.Subject) && e2cRecord.contains('~')){
                                if(c.Description == null || (c.Description != null && c.Description.startsWithIgnoreCase(e2cRecord.split('~')[1]))){
                                    c.addError('Case can\'t be saved due to generated from Delivery Status Notification (Failure)');
                                    break;    
                                }
                            }else if(hasCustomPermission == false && c.Subject.containsIgnoreCase(e2cRecord)){
                                c.addError('Case can\'t be saved due to generated from Out Of Office');
                                break;
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    public static void automateCaseEscalation(List<Case> newList, Map<Id, Case> oldCaseMap){
        Set<Id> queueIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        for(Case c : newList){
            if(UserInfo.getName() != CON_CSM.S_SYSTEM && !UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) && UserInfo.getUserType() != 'AutomatedProcess' && UserInfo.getUserType() != 'PowerPartner' && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.CurrentQueue__c != null && oldCaseMap != null && oldCaseMap.get(c.Id) != null && oldCaseMap.get(c.Id).CurrentQueue__c != null && c.CurrentQueue__c != oldCaseMap.get(c.Id).CurrentQueue__c){
                queueIds.add(c.CurrentQueue__c);
                queueIds.add(oldCaseMap.get(c.Id).CurrentQueue__c);
                caseList.add(c);
            }
        }
        if(queueIds != null && !queueIds.isEmpty()){
            Map<Id, Queue_User_Relationship__c> queueMap = new SLT_QueueUserRelationshipC().selectByQueueId(queueIds, new Set<String> {'Id', 'Name','Tier__c'});
            if(queueMap != null && !queueMap.isEmpty()){
                for(Case c : caseList){
                    if(!c.IsEscalated && queueMap.get(oldCaseMap.get(c.Id).CurrentQueue__c).tier__c !=null && queueMap.get(c.CurrentQueue__c).tier__c != null && c.CurrentQueue__c != oldCaseMap.get(c.Id).CurrentQueue__c  && queueMap.get(oldCaseMap.get(c.Id).CurrentQueue__c).tier__c != queueMap.get(c.CurrentQueue__c).tier__c){
                        c.IsEscalated = TRUE;
                        if(c.FirstEscalationDateTime__c == null){
                            c.FirstEscalationDateTime__c = System.now();
                        }
                        if(c.First_Escalation_Time__c == null){
                            c.First_Escalation_Time__c = (Datetime.now().getTime() - c.CreatedDate.getTime())/(60*1000);
                        }
                        if(c.First_Escalated_By__c == null){
                            c.First_Escalated_By__c = UserInfo.getUserId();
                        }
                    }else if(oldCaseMap != null && oldCaseMap.get(c.Id) != null && oldCaseMap.get(c.Id).IsEscalated == true && c.IsEscalated != oldCaseMap.get(c.Id).IsEscalated){
                        c.IsEscalated = oldCaseMap.get(c.Id).IsEscalated;
                    }
                }
            }
        }
    }

    public static void updateCaseCategorization(List<case> listOfCase, Map<Id, Case> oldMap) {
        Set<id> setAcc = new Set<id>();
        Set<String> setProd = new Set<String>();
        Map<String,Id> mapAset = new Map<String,Id>();
        for(Case c : listOfCase){
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.AccountId != null && c.ProductName__c != null && c.AccountId  != oldMap.get(c.Id).AccountId){
                setAcc.add(c.AccountId);
                setProd.add(c.ProductName__c);
            }
        }
        if(setAcc != null && !setAcc.isEmpty() && !setProd.isEmpty()){
            List<Asset> listAsset = new SLT_Asset().selectByAccountIdAndProductNameList(setAcc, setProd);
            for(Asset a : listAsset){
                mapAset.put(a.AccountId+'~'+a.Product2.Name, a.Id);
            }
        }
        for(Case c : listOfCase){
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && mapAset.containsKey(c.AccountId+'~'+c.ProductName__c)){
                c.AssetId = mapAset.get(c.AccountId+'~'+c.ProductName__c);
            }else if ( c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.AccountId  != oldMap.get(c.Id).AccountId){
                c.AssetId = null;
                c.ProductName__c = null;
                c.SubType1__c = null;
                c.SubType2__c = null;
                c.SubType3__c = null;
            }
        }
    }
    
    /** public static void updateCaseEscalationField(List<Case> newList, Map<Id, Case> oldCaseMap){
        Set<Id> caseIds = new Set<Id>();
        for(Case caseRecord : newList){
            if(caseRecord.Status == CON_CSM.S_CLOSED && caseRecord.IsEscalated == FALSE && oldCaseMap.get(caseRecord.Id).IsEscalated == TRUE){
                caseIds.add(caseRecord.Id);
            }
        }
        if(caseIds != null && !caseIds.isEmpty() && !System.isFuture() && !System.isBatch()){
            setEscalatedToTrue(caseIds);
        }
    }
    
    @future
    private static void setEscalatedToTrue(Set<Id> caseIds){
        List<Case> caseList = new SLT_Case().selectById(caseIds);
        if(caseList != null && !caseList.isEmpty()){
            for(Case caseRecord : caseList){
                if(caseRecord.Status == CON_CSM.S_CLOSED && caseRecord.IsEscalated == FALSE){
                    caseRecord.IsEscalated = TRUE;
                }
            }
            try{
                update caseList;
            }
            catch(Exception ex){
                ex.getStackTraceString();
            }
        }
    }*/

    public static void updateCaseDetailsformEmailMessageOutgoing(List<Case> newList,Map<Id,Case> oldMap){
        List<Id> RDCaseId = new List<Id>();
        List<Id> technoCaseId = new List<Id>();
        boolean InitialResonseProdOpps = false;
        List<Id> technoCaseIdProd = new List<Id>();
        Map<Id,Case> JsonCases = new Map<Id,Case>();
        Map<Id,String> jsonEmail = new Map<Id,String>();
        List<Activity__c> activityList = new List<Activity__c>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id,EmailMessage> emMap = new Map<Id,EmailMessage>();
        Map<Id,boolean> initialMap = new Map<Id,boolean>();
        Map<String,String> milestoneMap = new Map<String,String>();
        String external = null;
        List<String> milestoneList = new List<String>{CON_CSM.S_COMMUNICATION_UPD,CON_CSM.S_FIRST_RESPONSE_T,CON_CSM.S_PRODOPS_INITIAL_RESPONSE};
        for(Case cs : newList){
            if(cs.IsOutboundEmail__c && cs.IsOutboundEmail__c != oldMap.get(cs.Id).IsOutboundEmail__c){
                caseIds.add(cs.Id);
            }
        }
        if(caseIds != null && !caseIds.isEmpty()){
            UTL_CSM_SendMail.updateEmailMessageMail('Outgoing Email',newList,null);
            List<EmailMessage> emList = new SLT_EmailMessage().getEmailTextBodyByParendIds(caseIds);
            for(EmailMessage em : emList){
                emMap.put(em.ParentId,em);
                if(caseIds.contains(em.ParentId) && em.HtmlBody != null && em.HtmlBody.contains('Problem Statement:')){
                    milestoneList.add(CON_CSM.S_RESOLUTION_PLAN);
                }
            }
            
            for(Case cs : newList){
                if((cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || cs.RecordTypeName__c == CON_CSM.S_DATACASE) && cs.IsOutboundEmail__c && cs.IsOutboundEmail__c != oldMap.get(cs.Id).IsOutboundEmail__c){
                    initialMap.put(cs.id, false);
                }
            }
            if(!initialMap.isEmpty()){
                for(CaseMilestone cm : [select Id,caseId,completionDate,MilestoneType.Name from CaseMilestone where caseId in :initialMap.keySet() and MilestoneType.Name in :milestoneList and completionDate = null]){
                    initialMap.put(cm.caseId, true);
                    milestoneMap.put(cm.caseId +'~'+cm.MilestoneType.Name, cm.MilestoneType.Name);
                }    
            }
            for(Case cs : newList){
                if(cs.IsOutboundEmail__c && cs.IsOutboundEmail__c != oldMap.get(cs.Id).IsOutboundEmail__c){
                    external = '';
                    if(CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c && (CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin) && string.valueOf(cs.OwnerId).startsWith(CON_CSM.S_QUEUE_ID) && CON_CSM.S_NEW == cs.Status){
                        cs.Status = CON_CSM.S_IN_PROGRESS;
                    }
                    if(cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T && cs.template__c == CON_CSM.S_R_D_DATABASE_LOCK){
                        if (cs.SlaExitDate == null && cs.Subject.indexOf(CON_CSM.S_R_D_DATABASE_LOCK)!= -1){
                            RDCaseId.add(cs.id);
                        }      
                    }
                    //if(cs.EntitlementId != null && (CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c || CON_CSM.S_DATACASE == cs.RecordTypeName__c ) && ((cs.Entitlement.Type == 'TECH Dashboard & Reports') || cs.ProductName__c  == CON_CSM.S_TDR || CON_CSM.S_O_ES == cs.Origin || CON_CSM.S_EMAIL == cs.Origin || CON_CSM.S_CUSTOMER_PORTAL == cs.Origin)){
                    if(cs.EntitlementId != null && initialMap.containsKey(cs.Id) && (CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c || CON_CSM.S_DATACASE == cs.RecordTypeName__c)){
                        DateTime completionDate = System.now();
                        if (((cs.SlaStartDate <= completionDate) && (cs.SlaExitDate == null))){
                            if((milestoneList.contains(CON_CSM.S_RESOLUTION_PLAN) || milestoneList.contains(CON_CSM.S_COMMUNICATION_UPD)) && (milestoneMap.containsKey(cs.Id +'~'+CON_CSM.S_COMMUNICATION_UPD) || milestoneMap.containsKey(cs.Id +'~'+CON_CSM.S_RESOLUTION_PLAN))){
                                if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_RESOLUTION_PLAN)){
                                    cs.TaskMilestone__c += ';' + CON_CSM.S_RESOLUTION_PLAN;
                                }else if(cs.TaskMilestone__c == null){
                                    cs.TaskMilestone__c = CON_CSM.S_RESOLUTION_PLAN;
                                }
                                if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_COMMUNICATION_UPD)){
                                    cs.TaskMilestone__c += ';' + CON_CSM.S_COMMUNICATION_UPD;
                                }else if(cs.TaskMilestone__c == null){
                                    cs.TaskMilestone__c = CON_CSM.S_COMMUNICATION_UPD;
                                }
                                technoCaseId.add(cs.Id);
                            }
                            if(cs.TaskMilestone__c != null && !cs.TaskMilestone__c.contains(CON_CSM.S_FIRST_RESPONSE_T)){
                                cs.TaskMilestone__c += ';' + CON_CSM.S_FIRST_RESPONSE_T;
                                technoCaseId.add(cs.Id);
                            }else if(cs.TaskMilestone__c == null){
                                cs.TaskMilestone__c = CON_CSM.S_FIRST_RESPONSE_T; 
                                technoCaseId.add(cs.Id);
                            }else{
                                technoCaseId.add(cs.Id);
                            } 
                        }
                    }else if(CON_CSM.S_TECHNOLOGY_R_T == cs.RecordTypeName__c){
                        technoCaseIdProd.add(cs.Id);
                        InitialResonseProdOpps = true;
                    }
                    
                    if(emMap != null && emMap.containsKey(cs.Id) && (cs.RecordTypeName__c == CON_CSM.S_R_D_V_T || cs.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs.RecordTypeName__c == CON_CSM.S_RDCASE)){
                        activityList.add(DAOH_Emailmessage.createRndActivity(cs, false, false,emMap.get(cs.Id)));
                    }
                    /*CSM-1246 Moved updateCaseOnOutboundMail() code here*/
                    if(cs.First_response_email_time__c == null){
                        if(cs.RecordTypeName__c == CON_CSM.S_DATACASE){
                            cs.First_response_email_time__c = Datetime.now();
                        }
                        cs.First_response_sent__c = True;
                    }
                    if(cs.NumberOfNotifications__c == null) {
                        cs.NumberOfNotifications__c = 1;
                    }else{
                        cs.NumberOfNotifications__c += 1;
                    }
                    if(cs.Service_Now_Incident_Number__c != null && (cs.External_System_Type__c == CON_CSM.S_ROCHE_SN || cs.ServiceNowSystemType__c == CON_CSM.S_BISM || cs.ServiceNowSystemType__c == CON_CSM.S_IQVIA)){
                        JsonCases.put(cs.Id, cs);
                        external = cs.External_System_Type__c;
                        if(emMap!= null && emMap.containsKey(cs.Id)){
                            jsonEmail.put(cs.Id,emMap.get(cs.Id).TextBody);
                        }
                    }
                    cs.IsOutboundEmail__c = false;
                }
            }
        }
        if(!technoCaseId.isEmpty()){
            DateTime completionDate = System.now();
            SRV_CSM_AssignPermissionSet.completeMilestone(technoCaseId, milestoneList, completionDate);
        }else if(!technoCaseIdProd.isEmpty() && InitialResonseProdOpps){
            DateTime completionDate = System.now();
            SRV_CSM_AssignPermissionSet.completeMilestone(technoCaseIdProd, new List<String>{CON_CSM.S_PRODOPS_INITIAL_RESPONSE}, completionDate);
        }
        
        if(!RDCaseId.isEmpty()){
            DateTime completionDate = System.now();
            SRV_CSM_AssignPermissionSet.completeMilestone(RDCaseId, new List<String>{CON_CSM.S_R_D_DATABASE_LOCK} , completionDate);
        }
        if(external != null && !JsonCases.isEmpty() && !jsonEmail.isEmpty() && !System.isBatch() && !System.isFuture()){
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(external);
            if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c){
                if(ecc.Name == CON_CSM.S_BISM){
                    WSC_CSM_BISMSOAPCallout.ActivityUpdateCSM2BISMCommentsSendEmail(JSON.serialize(JsonCases) ,JSON.serialize(jsonEmail));    
                }else if(ecc.Name == CON_CSM.S_ROCHE_SN){
                    WSC_CSM_ROCHERestCallout.addIncidentComment(Json.serialize(JsonCases),Json.serialize(jsonEmail),'Email');
                }
                
            }    
        }
        if(!activityList.isEmpty()){
            SRV_CSM_AssignPermissionSet.createActivityFromEmailMessage(JSON.serialize(activityList));   
        }
    }
    
    public static void updateCaseDetailsFromServiceNowValues(List < Case > caseList) {
        if (caseList != null && caseList.size() > 0) {
            for (Case c : caseList) {
                if (c.Status != null && CON_CSM.S_CASE_CLOSED != c.Status && CON_CSM.S_CASE_ABANDONED != c.Status && (c.ServiceNow_Status__c == 'Completed' || c.ServiceNow_Status__c == 'Resolved' || c.ServiceNow_Status__c == 'Cancelled')) {
                    if ((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_RDCASE || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && !c.ReOpened__c) {
                        if(c.ServiceNow_Status__c != 'Cancelled'){
                            c.Status = CON_CSM.S_RESOLVED;
                        }
                    } else if (c.ProductName__c != null && ((c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (c.ProductName__c.startsWith('IVP') || c.ProductName__c.startsWith('Data Status Report') || c.ProductName__c.startsWith('Argus Insight') || c.ProductName__c.startsWith('Argus Safety') || c.ProductName__c.startsWith('PVM') || c.ProductName__c.startsWith('PVQ') || c.ProductName__c.startsWith('OBIEE') || c.ProductName__c.startsWith('H&MS Database') || c.ProductName__c.startsWith('Cognos Reporting'))) || (c.RecordTypeName__c == CON_CSM.S_DATACASE && c.ProductName__c.startsWith('Human Data Science Cloud')))) {
                        if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.ServiceNow_Status__c == 'Cancelled'){
                            c.Status = CON_CSM.S_CASE_ABANDONED;
                        }else{
                            c.Status = CON_CSM.S_CLOSED;
                        }
                    }
                }
                if (c.ProductName__c != null && ((c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (c.ProductName__c.startsWith('IVP') || c.ProductName__c.startsWith('Data Status Report') || c.ProductName__c.startsWith('Argus Insight') || c.ProductName__c.startsWith('Argus Safety') || c.ProductName__c.startsWith('PVM') || c.ProductName__c.startsWith('PVQ') || c.ProductName__c.startsWith('OBIEE') || c.ProductName__c.startsWith('H&MS Database') || c.ProductName__c.startsWith('Cognos Reporting'))) || (c.RecordTypeName__c == CON_CSM.S_DATACASE && c.ProductName__c.startsWith('Human Data Science Cloud'))) && c.CloseNotes__c != null) {
                    c.Resolution__c = c.CloseNotes__c;
                }
            }
        }
    }
    public static void sendMailAfterCaseUpdateForWatchList(List<Case> caseList,Map<Id, Case> oldMap){
        if(!CON_CSM.WATCHIST){
            List<UTL_CSM_SendMail.MessageWrapper> messageList = new List<UTL_CSM_SendMail.MessageWrapper>();
            String[] emails;
            List<String> queue = new List<String>(); 
            EmailTemplate et = Database.query('Select Id, Name, Subject, HtmlValue, Body from EmailTemplate where Name like \'CSM_Case_Update_Watchlist_Mail\'');
            List<Queue_User_Relationship__c> qeueUserList = new List<Queue_User_Relationship__c>();
            for(Case cs : caseList){
                if((cs.Watch_List_User__c != null && cs.Watch_List_User__c != '') && ((cs.Status != oldMap.get(cs.Id).Status) || (cs.OwnerId != oldMap.get(cs.Id).OwnerId) || (cs.CurrentQueue__c != oldMap.get(cs.Id).CurrentQueue__c))){
                    emails = cs.Watch_List_User__c.split(',');
                    if(emails != null && !emails.isEmpty()) { 
                        for(integer i = 0; i < emails.size(); i++) {     
                            if(emails[i].startsWith('00G')){
                                queue.add(emails[i]);
                            }
                        }
                    }
                }
            }

            if (queue != null && queue.size()>0 ) {
                qeueUserList = [select Id, User__c, Group_Id__c from Queue_User_Relationship__c where Group_Id__c in :queue and Type__c = 'User'];
            }

            for(Case cs : caseList){
                if((cs.Watch_List_User__c != null && cs.Watch_List_User__c != '') && ((cs.Status != oldMap.get(cs.Id).Status) || (cs.OwnerId != oldMap.get(cs.Id).OwnerId) || (cs.CurrentQueue__c != oldMap.get(cs.Id).CurrentQueue__c))){
                    UTL_CSM_SendMail.MessageWrapper message = new UTL_CSM_SendMail.MessageWrapper();
                    
                    emails = cs.Watch_List_User__c.split(',');
                    if (qeueUserList != null && qeueUserList.size() > 0 && emails != null && !emails.isEmpty()) {
                        for(Queue_User_Relationship__c u : qeueUserList) {
                            if(emails.contains(u.Group_Id__c)){
                                emails.add(u.User__c);
                            }
                        } 

                        for(integer i = 0; i < emails.size(); i++) {     
                            if(emails[i].startsWith('00G')){
                                emails.remove(i);
                                i--;
                            }
                        }
                    }
                    
                    String emailbody = (et != null) ? et.HtmlValue : '';
                    String test = emailbody.replace('<![CDATA[','');
                    String test1= test.replace(']]>','');
                    message.toEmails = emails;
                    message.targetObjectId = cs.ContactId;
                    message.isTargetObjectAsRecipient = false;
                    message.whatId= cs.Id;
                    message.caseNumber = cs.CaseNumber;
                    message.priority = cs.Priority;
                    message.lastModify = cs.LastModifiedById;
                    message.title = cs.Subject;
                    if(cs.RecordTypeName__c == CON_CSM.S_R_D_CTP || cs.RecordTypeName__c == CON_CSM.S_R_D_CDP || CON_CSM.S_RDCASE == cs.RecordTypeName__c || CON_CSM.S_R_D_V_T == cs.RecordTypeName__c || CON_CSM.S_ACTIVITY_R_T == cs.RecordTypeName__c){
                        if(cs.LOS__c !=null){
                            message.product = cs.LOS__c;
                        }else{
                            message.product = '';
                        }
                    }else{
                        if(cs.ProductName__c !=null){
                            message.product = cs.ProductName__c;
                        }else{
                            message.product = '';
                        }
                    }
                    message.origin = cs.Origin;
                    message.templateId = (et != null) ? et.Id : '';
                    message.subject = (et != null) ? et.Subject: '';
                    message.content = test1;
                    if(cs.Status != oldMap.get(cs.Id).Status){
                        message.changes = 'Status Change';
                        message.changeValue = oldMap.get(cs.Id).Status+' / '+cs.Status;
                    }
                    if((cs.OwnerId != oldMap.get(cs.Id).OwnerId) || oldMap.get(cs.Id).CurrentQueue__c != cs.CurrentQueue__c){
                        message.changes = 'Owner Change';
                        message.changeValue = oldMap.get(cs.Id).OwnerId+' / '+cs.OwnerId+' / '+oldMap.get(cs.Id).CurrentQueue__c+' / '+cs.CurrentQueue__c;
                    }
                    messageList.add(message);
                }
            }
            if(messageList != null && messageList.size()>0){
                UTL_CSM_SendMail.sendMailToWatchListUser(messageList);
                CON_CSM.WATCHIST = true;
            }
        }
    }
    public static void updateCaseLastModifiedDateOnPostInsert(List<Id> listOfCase) {
        List<Case> cases ;
        List<Case> updatedCases = new List<Case>();
        if(listOfCase != null && listOfCase.size() > 0){
            cases = new SLT_Case().getCaseDetailsUpdatePost(listOfCase); 
        }
        if(cases != null && cases.size() > 0){
            for(Case cs : cases){
                cs.UpdatePost__c = 'Post Updated';
                updatedCases.add(cs);
            }
        }
        if(updatedCases != null && updatedCases.size() > 0)
        {
            update updatedCases;
        }
    }

    /** public static void insertRCACaseDocument(List<Case> caseList,Map<Id, Case> oldMap){

        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<Case> cList = new List<Case>();
        for(Case c : caseList){
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Case_Type__c != null && c.Case_Type__c == 'Problem' && (Trigger.IsInsert || (oldMap != null && oldMap.get(c.Id) != null && (c.Case_Type__c != oldMap.get(c.Id).Case_Type__c || c.Status != oldMap.get(c.Id).Status) )) && (c.Status == CON_CSM.S_RESOLVED_WITH_C || c.Status == CON_CSM.S_CLOSED)){
                caseMap.put(c.Id,c);
            }
        }
        CSM_Case_Details_Global_Setting__c gd = CSM_Case_Details_Global_Setting__c.getValues('Tech_RCA_Document');
        if(!caseMap.isEmpty() && gd != null){
            String st = gd.Setting_Type__c;
            Set<Id> cases = caseMap.keySet();
            List<ContentDocumentLink> cdLList = Database.query('select Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title, ShareType, Visibility  from ContentDocumentLink where LinkedEntityId  in:cases and ContentDocument.Title =:st');
            for(ContentDocumentLink cdl : cdLList){
                if(!caseMap.containsKey(cdl.LinkedEntityId)){
                    cList.add(caseMap.get(cdl.LinkedEntityId));
                } 
            }
            for(Case c: cList){
                if(hasCustomPermission == false) c.addError('RCA_Document_Link__c','For Case type Problem, the RCA form need to be attached when status is Resolved with customer or Closed. You can download the RCA form from the MAP website by clicking RCA Document Link field',false);
            }
        }
    }*/

    public static void insertCaseinInternalServiceNow(List<Case> newList,Map<Id, Case> oldMap){
        Set<Case> sNowcaseSet = new Set<Case>();
        for(Case c : newList) {
            if(c.Service_Now_Incident_Number__c == null && c.ServiceNow_Group__c != null && c.ServiceNowSystemType__c == 'Internal' && (oldMap == null || (oldMap != null && !UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)))){
                sNowcaseSet.add(c);
            }
        }
        CSM_ExternalClient_info__c eci = CSM_ExternalClient_info__c.getValues('Internal');
        if(EXT_CSM_Validator_Cls.hasSNowCallFirstTime() & eci != null && eci.Profile_Id__c != UserInfo.getUserId() && !System.isFuture() && !System.isBatch() && sNowcaseSet != null && !sNowcaseSet.isEmpty()){
            insertCaseinInternalServiceNowRESTFull(Json.serialize(sNowcaseSet));
            EXT_CSM_Validator_Cls.setSNowCallFirstTime();
        }
    }
    
    @future(callout=true)
    public static void insertCaseinInternalServiceNowRESTFull(String jscases){
        Set<Id> catSet = new Set<Id>();
        Set<Id> cmdbSet = new Set<Id>();
        Set<Id> sngSet = new Set<Id>();
        Map<Id,CMDB__c> cmdbMap = new Map<Id,CMDB__c>();
        Map<Id,CSM_QI_Case_Categorization__c> ccMap = new Map<Id,CSM_QI_Case_Categorization__c>();
        Map<Id,ServiceNow_Group__c> sngMap = new Map<Id,ServiceNow_Group__c>();
        CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('Internal');
        Set<Case> cSet = (Set<Case>)JSON.deserialize(jscases, Set<Case>.class);
        EXT_CSM_InternalSNow.insertElement insertE = new EXT_CSM_InternalSNow.insertElement();
        EXT_CSM_InternalSNow.insertQ2Details insertQ = new EXT_CSM_InternalSNow.insertQ2Details();
        EXT_CSM_InternalSNow.insertVariables insertV = new EXT_CSM_InternalSNow.insertVariables();
        List<Case> cList = new List<Case>();
        for(Case c : cSet){
            if(c.Case_CategorizationId__c != null){
                catSet.add(c.Case_CategorizationId__c);
            }
            if(c.CMDB__c != null){
                cmdbSet.add(c.CMDB__c);
            }
            if(c.ServiceNow_Group__c != null){
                sngSet.add(c.ServiceNow_Group__c);
            }
        }
        if(!catSet.isEmpty()){
            ccMap = new SLT_CaseCategorization().getById(catSet,new Set<String>{'Id','ServiceNow_GUID__c'});
        }
        if(!sngSet.isEmpty()){
            sngMap = new SLT_ServiceNowGroupC().selectByServiceNowId(sngSet,new Set<String>{'Id','Name','Group_ID__c'});
        }
        if(cmdbSet != null && !cmdbSet.isEmpty()){
            List<CMDB__c> cmdList = Database.query('select Id,SysID__c from CMDB__c where id in :cmdbSet');
            for(CMDB__c cm : cmdList){
                cmdbMap.put(cm.Id, cm);
            }    
        }
        if(ecc != null){
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ecc.Client_Url__c);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setMethod('POST');
            Blob beforeblob = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
            req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(beforeblob));
            String uId = UserInfo.getUserId();
            String sys_user = 'e4b64b8cc0440a00dc9f37570d00edce';
            List<User> empNumber = Database.query('SELECT Id,EmployeeNumber FROM User WHERE Id = :uId and EmployeeNumber != null LIMIT 1');
            for(Case c : cSet){
                try{
                    if(c.LOS__c == CON_CSM.S_Q2_INV_SITE && c.ServiceNow_Group__c == ecc.Infosario_Group_Id__c && c.ServiceNowSystemType__c == 'Internal' && c.Service_Now_Incident_Number__c == null){
                     if(empNumber != null && !empNumber.isEmpty()) {
                         
                        HttpRequest reqUserGet = new HttpRequest();
                        reqUserGet.setEndpoint(ecc.Email_CC__c.replace('EmployeeNumber',empNumber[0].EmployeeNumber));
                        reqUserGet.setMethod('GET');
                        Blob headerValue = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
                        reqUserGet.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(headerValue));
                        Http httpUserGet = new Http();
                        HTTPResponse resUserGet = httpUserGet.send(reqUserGet);
                         System.debug('resUserGet : '+resUserGet.getBody());
                         Map<String, Object> getUserMap1 = (Map<String, Object>) JSON.deserializeUntyped(resUserGet.getBody());
                         List<Object> listU = (List<Object>) getUserMap1.get('result');
                         Map<String, Object> userNum= (Map<String, Object>) listU[0];
                         sys_user = (String)userNum.get('sys_id');
                    }
                        Http httpPost = new Http();
                        HttpRequest reqPost = new HttpRequest();
                        reqPost.setEndpoint(ecc.Q2_POST_URL__c);
                        reqPost.setHeader('Content-Type', 'application/json;charset=UTF-8');
                        reqPost.setMethod('POST');
                        Blob beforeblobPost = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
                        reqPost.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(beforeblobPost));
                        
                        insertV.q_unique_short_description = c.Description;
                        insertV.my_short_description_for_this_ticket = '';
                        insertV.sga_import_conroller = '7459dededb40c300e8ded604ce961976';
                        insertV.q_site = '301dce6f4f0626048bb788fd0210c759';
                        insertV.sga_case_id = c.Id;
                        insertV.attachment = 'true';
                        insertV.caller_id = sys_user;
                        insertV.sga_case_number = c.CaseNumber;
                        insertV.q_contact_information = '';
                        insertV.sga_attachment_review_group = 'ITSM Platform';
                        insertV.q_requested_for_information = 'true';
                        insertV.q_attachment = 'Yes';
                        
                        insertQ.sysparm_quantity = '1';
                        insertQ.variables = insertV;
                        insertQ.sysparm_item_guid = 'e2197bc01b36ce50eec5ddb9ec4bcb05';
                        insertQ.get_portal_messages = 'true';
                        insertQ.sysparm_no_validation = 'true';
                        
                        reqPost.setBody(Json.serialize(insertQ));
                        
                        HTTPResponse res = httpPost.send(reqPost);
                        //Obtain the access token from the Response
                        if (res.getStatusCode() == 200) {
                            Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                            Map<String, Object> resMap2 = (Map<String, Object>) resMap.get('result');
                                String sysId = (String) resMap2.get('sys_id');
                                HttpRequest reqGet = new HttpRequest();
                                reqGet.setEndpoint(ecc.Q2_Get_URL1__c + sysId + ecc.Q2_Get_URL2__c);
                                reqGet.setMethod('GET');
                                Blob headerValue = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
                                reqGet.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(headerValue));
                                Http httpGet = new Http();
                                HTTPResponse resGet = httpGet.send(reqGet);
                                Map<String, Object> getMap1 = (Map<String, Object>) JSON.deserializeUntyped(resGet.getBody());
                                List<Object> lis = (List<Object>) getMap1.get('result');
                                Map<String, Object> ritmNum= (Map<String, Object>) lis[0];
                                String numb = (String)ritmNum.get('number');
                                c.Service_Now_Incident_Number__c = numb;
                                if(numb != null){
                                    cList.add(c);
                                }
                        }
                    }else {
                    insertE.u_sf_to_snc_create = 'CREATE';
                    insertE.records_casenumber = c.CaseNumber;
                    insertE.records_contactid = c.ContactId;
                    insertE.records_description = c.Description;
                    insertE.records_id = c.Id;
                    insertE.records_origin = c.Origin;
                    insertE.records_ownerid = c.OwnerId;
                    insertE.records_priority = c.Priority;
                    insertE.records_status = c.Status;
                    insertE.records_subject = c.Subject;
                    if(ccMap != null && ccMap.containsKey(c.Case_CategorizationId__c)){
                        insertE.u_records_case_categorizationid_r = ccMap.get(c.Case_CategorizationId__c).ServiceNow_GUID__c;
                    }
                    insertE.u_records_category_c = c.SN_Category__c;
                    insertE.u_records_cmdb_c = c.CMDB__c;
                    if(cmdbMap != null && cmdbMap.containsKey(c.CMDB__c)){
                        insertE.u_records_cmdb_r = cmdbMap.get(c.CMDB__c).SysID__c;
                    }
                    insertE.u_records_contact_name = c.Contact_Info__c;
                    insertE.u_records_customer_requested_date_c = String.valueofGmt(c.Customer_Requested_Date__c);
                    insertE.u_records_product_line_c = (c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || c.RecordTypeName__c == CON_CSM.S_DATACASE) ? c.ProductName__c : c.LOS__c;
                    insertE.u_records_product_offering_c = c.SubType1__c;
                    insertE.u_records_sn_category_c = c.SubType2__c;
                    insertE.u_records_productname_c = c.ProductName__c;
                    insertE.u_records_recordtypename_c = c.RecordTypeName__c;
                    insertE.u_records_service_now_type_c = c.Service_Now_Type__c;
                    if((sngMap != null && sngMap.containsKey(c.ServiceNow_Group__c))){
                        insertE.u_records_servicenow_group_c = sngMap.get(c.ServiceNow_Group__c).Group_ID__c;
                    }
                    if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T || (c.RecordTypeName__c == CON_CSM.S_DATACASE && ccMap != null && ccMap.containsKey(c.Case_CategorizationId__c) && ccMap.get(c.Case_CategorizationId__c).ServiceNow_GUID__c != null)){
                        insertE.u_records_sn_prod_line_c = c.ProductName__c;
                        insertE.u_records_sn_product_offering_c = c.SubType1__c;
                        insertE.u_records_sn_sub_categrory_c = c.SubType3__c;
                        insertE.u_records_sub_category_c = c.SubType3__c;
                        insertE.u_records_subtype1_c = c.SubType1__c;
                        insertE.u_records_subtype2_c = c.SubType2__c;
                        insertE.u_records_subtype3_c = c.SubType3__c;
                    }else if(c.RecordTypeName__c == CON_CSM.S_DATACASE){
                        insertE.u_records_sn_prod_line_c = 'Not Applicable';
                        insertE.u_records_sn_product_offering_c = null;
                        insertE.u_records_sn_sub_categrory_c = null;
                        insertE.u_records_sub_category_c = null;
                        insertE.u_records_subtype1_c = null;
                        insertE.u_records_subtype2_c = null;
                        insertE.u_records_subtype3_c = null;
                    }
                    insertE.u_records_suppliedemail = c.SuppliedEmail;
                    insertE.u_records_type = c.Type;
                    req.setBody(Json.serialize(insertE));
                    http.send(req);
                }
                }catch(Exception ex){
                    System.debug('Exception occured at insertCaseinInternalServiceNow for SOAP : '+ex.getMessage());
                }
            }
            if(!cList.isEmpty()){
                update cList;
            }
        }
    }

    public static void getCaseTechAutoTimer(List<Case> newList,Map<Id, Case> oldMap){
        Set<Id> caseIds = new Set<Id>();
        String name = UserInfo.getName();
        String caseid = null;
        String message = null;
        List<String> statusList = CON_CSM.S_C_TECH_STATUS;
        if(!(name == CON_CSM.S_SYSTEM || name == CON_CSM.S_CSM_ADMIN  || UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || name == 'Integration ServiceNow' || name == 'BISM CSM API User' || name == 'ROCHE CSM API User')){
            for(Case c : newList){
                if(CON_CSM.S_ALLOWED_RT_TIMESHEET.contains(c.RecordTypeName__c) && !c.IsClosed && c.getQuickActionName() != 'Case.Macros_Only' && c.getQuickActionName() != 'Case.R_D_AR_Macros_Only' && c.getQuickActionName() != 'Case.R_D_Macros_Only'){
                //if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && !c.IsClosed && c.getQuickActionName() != 'Case.Macros_Only'){
                    caseIds.add(c.Id);
                    message ='Case Updatd';
                    if(c.Status != oldMap.get(c.Id).Status){ message ='Status changed'; }
                    if(c.OwnerId != oldMap.get(c.Id).OwnerId){ message ='Owner changed';}
                    if(c.CurrentQueue__c != oldMap.get(c.Id).CurrentQueue__c){ message ='Queue changed';}
                    if(c.FCR_Review_Escalation__c != oldMap.get(c.Id).FCR_Review_Escalation__c || c.SLA_FCR_Reviewed__c != oldMap.get(c.Id).SLA_FCR_Reviewed__c){
                        message ='SLA FCR changed';
                    }
                    if(c.Watch_List_User__c != oldMap.get(c.Id).Watch_List_User__c){
                        message ='WatchList changed';
                    }
                    if(c.Case_CategorizationId__c != oldMap.get(c.Id).Case_CategorizationId__c){
                        message ='CategorizationId changed';
                    }
                    if(!statusList.contains(c.Status) || c.Status == CON_CSM.S_RESOLVED_WITH_C){
                        caseid = c.Id;
                    }
                }
            }
            if(!caseIds.isEmpty() && !System.isBatch() && !System.isFuture()){
                stopTechAutoTimer(caseIds,caseid,message);
            }
        }
    }
    
    @future
    public static void stopTechAutoTimer(Set<Id> caseIds,String caseid,String message){
        if(caseIds != null){ CNT_CSM_Timer.updateStopTimefromCase(caseIds,message);}
        if(caseid != null){ CNT_CSM_Timer.insertorUpdateTime(caseid,null,null);}
        
    }
    public static void UpdateOnBehalfOfRef(List<Case> newList,Map<Id, Case> oldMap){ 
        Set<Id> case_OnBehalfOf_Ids = new Set<Id>();
        for(Case c : newList){
            if((oldMap == null) || (oldMap != null && oldMap.get(c.Id) != null && c.OnBehalfOf__c !=oldMap.get(c.Id).OnBehalfOf__c)){
                if(c.OnBehalfOf__c != null){
                    case_OnBehalfOf_Ids.add(c.OnBehalfOf__c);
                }else if (c.OnBehalfOf__c == null)
                {
                    c.On_Behalf_Of_Ref__c = null;
                }  
            }
        } 
        if(case_OnBehalfOf_Ids != null && !case_OnBehalfOf_Ids.isEmpty()){
            Map<Id, Contact> case_OnBehalfOf = new Map<Id,Contact>([select Id, FirstName, LastName From CONTACT where Id in :case_OnBehalfOf_Ids]);
        
            for(Case c : newList){
                if(c.OnBehalfOf__c != null && case_OnBehalfOf.containskey(c.OnBehalfOf__c)){
                    c.On_Behalf_Of_Ref__c = case_OnBehalfOf.get(c.OnBehalfOf__c).FirstName + ' ' + case_OnBehalfOf.get(c.OnBehalfOf__c).LastName;  
                }
            }
        }
    }
    /**
* This method is used to store ElapsedtimeAge
*/
    public static void ElapsedtimeAge(List<Case> casList) { 
        for(Case c : casList){
            if(c.ResolvedDatetime__c != null && c.CreatedDate != null){
                Date startDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                Date endDate = Date.newInstance(c.ResolvedDatetime__c.year(), c.ResolvedDatetime__c.month(), c.ResolvedDatetime__c.day());
                Date counterDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                
                Long seconds = 0;
                
                while(counterDate <= endDate){
                    String dayOfWeek = ((DateTime)counterDate).format('u');
                    if(!(dayOfWeek == '6' || dayOfWeek == '7')){
                        if(startDate == endDate){ // same day resolution
                            seconds += ((c.ResolvedDatetime__c.getTime() - c.CreatedDate.getTime())/1000);
                        }else{
                            if(counterDate == startDate){
                                seconds += (24*60*60 - (c.CreatedDate.hour()*60*60 +c.CreatedDate.minute()*60 + c.CreatedDate.second()));
                            }else if(counterDate == endDate){
                                seconds += (c.ResolvedDatetime__c.hour()*60*60 + c.ResolvedDatetime__c.minute()*60 +c.ResolvedDatetime__c.second());
                            }else{
                                seconds += 24*60*60;
                            }
                        }
                    }
                    counterDate = counterDate.addDays(1);
                }
                
                Integer days = (Integer)(seconds/(24*60*60));
                seconds = Math.mod(seconds, 24*60*60L);
                Integer hours = (Integer)(seconds/(60*60));
                seconds = Math.mod(seconds, 60*60L);
                Integer minutes = (Integer)(seconds/60);
                seconds = Math.mod(seconds, 60L);
                String elapsedTime = '';
                if(days>0){
                    elapsedTime += (days+' day'+ (days>1?'s ':' '));
                }
                if(hours>0){
                    elapsedTime += (hours+' hour'+ (hours>1?'s ':' '));
                }
                if(minutes>0){
                    elapsedTime += (minutes+' minute'+ (minutes>1?'s ':' '));
                }
                if(seconds>0){
                    elapsedTime += (seconds+' second'+ (seconds>1?'s ':' '));
                }
                    c.Elapsed_Timeage__c = elapsedTime;
            }
            
        }
    }
    
    /* public static void sendEmailForRecommendedArticles(List<case> records){
        if(records.size() == 1 && !Test.isRunningTest()){
            String error = null;
            Case c = records.get(0);
            if(c.Origin == CON_CSM.S_EMAIL && c.ContactId != null && c.AccountId != null && CON_CSM.S_SYSTEM == userInfo.getName() && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T ){
                List<Asset> assets = [Select Id, Name from Asset where accountId = :c.AccountId];
                List<ConnectApi.ArticleRecommendation> articles = null;
                if(assets != null && !assets.isEmpty()){
                    Map<String, String> params = new Map<String, String>{'RecordId'=>c.Id};
                        Flow.Interview flow = new Flow.Interview.Article_Recommendation_Auto_Launch_Flow(params);
                    try{
                        Flow.Start();
                        articles = (List<ConnectApi.ArticleRecommendation>) flow.getVariableValue('RecommendedArticles');
                    }catch(Exception e){
                        error = 'Exception: '+e.getMessage();  
                    }
                    if(articles != null && !articles.isEmpty()){
                        Set<String> assetNames = new Set<String>();
                        for(Asset asset:assets){
                            assetNames.add(asset.Name);
                        }
                        Set<Id> knowledgeArticleIds = new Set<Id>();
                        for(ConnectApi.ArticleRecommendation article : articles){
                            knowledgeArticleIds.add(article.knowledgeArticleVersionId);
                        }
                        Map<Id, Knowledge__kav> knowledgeArticleMap = new Map<Id, Knowledge__kav>([SELECT Id, ProductName__c, Title,UrlName , Pillar__c,IsVisibleInPkb from Knowledge__kav where Id IN:knowledgeArticleIds AND IsVisibleInPkb = true]);
                        
                        List<Knowledge__kav> filteredKnowledgeArticles = new List<Knowledge__kav>();
                        
                        for(ConnectApi.ArticleRecommendation article : articles){
                            Knowledge__kav knowledgeArticle = knowledgeArticleMap.get(article.knowledgeArticleVersionId);
                            if(knowledgeArticle != null){
                                if(assetNames.contains(knowledgeArticle.ProductName__c)){
                                    if(knowledgeArticle.Pillar__c  == 'Technology Solutions' && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                                        filteredKnowledgeArticles.add(knowledgeArticle);
                                        if(filteredKnowledgeArticles.size() == 3){
                                            break;
                                        }   
                                    }
                                }
                            }
                        }
                        if(!filteredKnowledgeArticles.isEmpty()){
                            String url = '';
                            String cshPortalUrl = label.CSM_Portal_URI+'/s/article/';
                            for(Knowledge__kav knowledgeArticle: filteredKnowledgeArticles){
                                url += '<a href='+cshPortalUrl+knowledgeArticle.UrlName+'>'+ knowledgeArticle.Title +'</a><br>';
                            }
                            
                            EmailTemplate emailTemplate = [Select Id, Subject, HtmlValue, Body from EmailTemplate where developerName = 'CAS_Suggested_Articles_HTML'];
                            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, c.ContactId+'', c.Id+'');
                            String htmlBody = email.getHTMLBody();
                            email.setHtmlBody(htmlBody.replace('!-article-url-!', url));
                            CSM_Case_Details_Global_Setting__C orgE = CSM_Case_Details_Global_Setting__C.getInstance('Org Wide No-Reply');
                            email.setReplyTo('no.reply.support@iqvia.com');
                            if(orgE != null){ email.setOrgWideEmailAddressId(orgE.Component_Id__c);}
                            email.setTreatTargetObjectAsRecipient(false);
                            email.setToAddresses(new List<String>{c.SuppliedEmail});
                            email.setSaveAsActivity(false);
                            
                            try{
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email}); 
                                for(Messaging.SendEmailResult result : results){
                                    if(result.isSuccess()){
                                        System.debug('Mail Sent succesfully');  
                                    }
                                    else {
                                        System.debug('Error in sending Email' +result.getErrors());
                                    }
                                }
                            }
                            catch(Exception e){
                                System.debug('Mail Exception: '+e.getMessage());  
                            }
                        }
                    }
                }               
            }
        }
    }*/

    public static void setCreatedDateInPreferredLanguage(List<Case> newList){
        Set<Id> ids = new Set<Id>();
        DateTime todayDate = System.today();
        String dateWithDefaultFormat = todayDate.format('dd MMMM yyyy');
        for(Case cs:newList){
            cs.Created_Date_In_Preferred_Lng_Format__c = dateWithDefaultFormat;
            if(cs.ContactId !=null){
                ids.add(cs.ContactId);
            }
        }
        
        if(!ids.isEmpty()){
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, PreferredLanguage__c from Contact where ID IN:ids]);
            List<CSM_Date_Format_By_Language__c> lst = CSM_Date_Format_By_Language__c.getall().values();
            for(Case cs:newList){
                for(CSM_Date_Format_By_Language__c setting : lst){
                    if(contactMap.get(cs.ContactId) !=null && contactMap.get(cs.ContactId).PreferredLanguage__c!=null && contactMap.get(cs.ContactId).PreferredLanguage__c.equals(setting.Language_Code__c)){
                        if(setting.Date_Format__c != null && setting.Date_Format__c != ''){
                            DateTime dt = System.today();
                            cs.Created_Date_In_Preferred_Lng_Format__c = dt.format(setting.Date_Format__c);
                            String dateStr = cs.Created_Date_In_Preferred_Lng_Format__c;
                            String month = dt.format('M');
                            switch on month {
                                when '1' {
                                    dateStr = setting.January__c !=null ? dateStr.replace('January', setting.January__c) : dateStr;
                                }when '2' {
                                    dateStr = setting.February__c !=null ? dateStr.replace('February', setting.February__c) : dateStr;
                                }when '3' {
                                    dateStr = setting.March__c !=null ? dateStr.replace('March', setting.March__c) : dateStr;
                                }when '4' {
                                    dateStr = setting.April__c !=null ? dateStr.replace('April', setting.April__c) : dateStr;
                                }when '5' {
                                    dateStr = setting.May__c !=null ? dateStr.replace('May', setting.May__c) : dateStr;
                                }when '6' {
                                    dateStr = setting.June__c !=null ? dateStr.replace('June', setting.June__c) : dateStr;
                                }when '7' {
                                    dateStr = setting.July__c !=null ? dateStr.replace('July', setting.July__c) : dateStr;
                                }when '8' {
                                    dateStr = setting.August__c !=null ? dateStr.replace('August', setting.August__c) : dateStr;
                                }when '9' {
                                    dateStr = setting.September__c !=null ? dateStr.replace('September', setting.September__c) : dateStr;
                                }when '10' {
                                    dateStr = setting.October__c !=null ? dateStr.replace('October', setting.October__c) : dateStr;
                                }when '11' {
                                    dateStr = setting.November__c !=null ? dateStr.replace('November', setting.November__c) : dateStr;
                                }when '12' {
                                    dateStr = setting.December__c !=null ? dateStr.replace('December', setting.December__c) : dateStr;
                                }
                            }
                            cs.Created_Date_In_Preferred_Lng_Format__c = dateStr;
                            break;
                        } 
                    }
                }
            }
        }
    }
    public static void CloseChildCases(List<Case> newList,Map<Id, Case> oldMap){          
        List<Case> lstToUpdate = new List<Case>();    // To hold the eligible child case for update
        Map<Id, Case> parentMap = new Map<Id,Case>();    // Id- Id of record; Case- Record
        Map<Id, List<Case>> childMap = new Map<Id,List<Case>>();    // Id- ParentID, List<Case> - List of child cases        
        Map<Id, List<Case>> littleChildMap = new Map<Id,List<Case>>();    // Id- ParentID, List<Case> - List of child cases 
        
        parentMap = getParentMapFromNewCase(newList,oldMap);        
        if(parentMap.size() > 0 && !EXT_CSM_Validator_Cls.hasCloseChildDone()){
            /* Creating Child/Little Child Maps from the list of child/Little child case */
            List<Case> childCases = getChildCasesForTech(parentMap.KeySet());  
            List<Case> littleChildCases = getChildCasesForTech((new Map<Id,Case>(childCases)).KeySet());  
            childMap = populateParentChildMap(childCases);   
            littleChildMap = populateParentChildMap(littleChildCases);   
            Map<Id, List<Asset>> missingAssetsMap = getAssetsForChild(parentMap, childCases, littleChildCases);
            
            /* Iterating the Maps to update status and related required fields to close status*/
            for(Id parent : childMap.keySet())
                for(Case child : childMap.get(parent)){
                    updateChildFromParent(parentMap.get(parent),child,lstToUpdate,missingAssetsMap, littleChildMap.containsKey(child.Id) ? true:false);
                    if(littleChildMap.containsKey(child.Id)){
                        for(Case littleChild : littleChildMap.get(child.Id)){
                            updateChildFromParent(child,littleChild,lstToUpdate,missingAssetsMap,false); 
                        }
                    }
                }
            if(lstToUpdate != null && !lstToUpdate.isEmpty()){
                try{
                    update lstToUpdate;
                    EXT_CSM_Validator_Cls.setCloseChildDone();
                }catch(Exception e){
                    for(Case c: newList){
                        c.addError(e.getMessage());
                        break;
                    }
                }
            }
        }
    }
    
    public static Map<Id, List<Asset>> populateMissingAssets(List<Asset> missingAssets){
        Map<Id, List<Asset>> mapToReturn = new Map<Id,List<Asset>>();
        for(Asset a : missingAssets){
            if(mapToReturn.containsKey(a.AccountId)){
                mapToReturn.get(a.AccountId).Add(a); 
            }else{
                mapToReturn.put(a.AccountId,new List<Asset>{a});
            }
            
        }
        return mapToReturn; 
    }
    
    public static Map<Id, List<Case>> populateParentChildMap(List<Case> childCases){
        Map<Id, List<Case>> mapToReturn = new Map<Id,List<Case>>();
        for(Case c : childCases){
            if(mapToReturn.containsKey(c.ParentId)){
                mapToReturn.get(c.ParentId).Add(c); 
            }             
            else{
                mapToReturn.put(c.ParentId,new List<Case>{c});
            }
            
        }
        return mapToReturn;        
    }
    
    public static List<Case> getChildCasesForTech(Set<id>  ids){
        List<Case> childCases = [SELECT Id,AccountId, Subject,Status,Case_CategorizationId__c,Close_all_child_case_with_parent__c,CaseNumber,Technical_Resolution_Internal_Use_only__c,Resolution__c,RootCause__c,Root_Cause_Reason__c,CSAT_Reviewed__c,ParentId,Parent.Case_CategorizationId__c,Parent.Subject,Parent.Status,Parent.Close_all_child_case_with_parent__c,Device__c,Parent.CaseNumber,Parent.Technical_Resolution_Internal_Use_only__c,Parent.Resolution__c,Parent.RootCause__c,Parent.Root_Cause_Reason__c,Parent.CSAT_Reviewed__c,Parent.ParentId,AssetId,ProductName__c,SubType1__c,SubType2__c,SubType3__c,Parent.AssetId,Parent.ProductName__c,Parent.SubType1__c,Parent.SubType2__c,Parent.SubType3__c, Parent.Device__c, Parent.AccountId   from Case Where ParentId IN : ids and RecordTypeName__c =: CON_CSM.S_TECHNOLOGY_R_T ];
        return childCases;
    }
    
    public static void updateChildFromParent(Case parent,Case child,List<Case> lstToUpdate, Map<Id, List<Asset>> missingAssetsMap,boolean isChild){
        if(parent.Status != child.Status)
        {
            if(child.Resolution__c  == null && parent.Resolution__c!= null){child.Resolution__c = parent.Resolution__c;}
            if(child.Technical_Resolution_Internal_Use_only__c  == null && parent.Technical_Resolution_Internal_Use_only__c!= null){child.Technical_Resolution_Internal_Use_only__c = parent.Technical_Resolution_Internal_Use_only__c;}
            if(((child.RootCause__c == null && parent.RootCause__c != null) || (child.RootCause__c == 'Other' && child.RootCause__c != null && parent.RootCause__c != null && child.RootCause__c != parent.RootCause__c))) {
                child.RootCause__c = parent.RootCause__c;
            }
            if(child.Root_Cause_Reason__c == null && parent.Root_Cause_Reason__c != null){
                child.Root_Cause_Reason__c = parent.Root_Cause_Reason__c;
            }
            if(child.Device__c ==  null && parent.Device__c != null) {child.Device__c = parent.Device__c;}
            if(isChild) { child.Close_all_child_case_with_parent__c = parent.Close_all_child_case_with_parent__c;}
            child.Owner__c = 'Close all child case with parent';
            if(child.AssetId == null){
                if(child.AccountId != parent.AccountId){
                    try {
                        if(missingAssetsMap.size()>0){
                            for(Asset a : missingAssetsMap.get(child.AccountId)){
                                if(a!= null && a.Name == parent.ProductName__c){
                                    child.AssetId = a.Id;
                                }
                            }
                        }                       
                    } catch(Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }else{
                    child.AssetId = parent.AssetId;
                }
            }
            if(child.AssetId != null){
                if(child.Case_CategorizationId__c == null && parent.Case_CategorizationId__c != null) {
                    child.Case_CategorizationId__c = parent.Case_CategorizationId__c;  
                    child.ProductName__c = parent.ProductName__c;
                    child.SubType1__c = parent.SubType1__c;
                    child.SubType2__c = parent.SubType2__c;
                    child.SubType3__c = parent.SubType3__c;
                }
            }
            child.Status = parent.Status; 
            lstToUpdate.Add(child);
        }
        
        
    }  
    
    public static void CheckTechWithDifferentTypeChildBeforeClosing(List<Case> newList,Map<Id, Case> oldMap){
        List<Case> NonTechChildCases = [SELECT Id, CaseNumber,Status,Subject, RecordTypeName__c,ParentId from CASE where ParentID IN : (new Map<Id,Case>(newList)).KeySet() and RecordTypeName__c != 'TechnologyCase' ];        
        Map<Id, List<Case>>  parentMap = populateParentChildMap(NonTechChildCases);
        
        for(Case c : newList){
            if(oldMap != null && oldMap.get(c.Id)!= null && c.Close_all_child_case_with_parent__c && (c.Status != oldMap.get(c.Id).Status && (c.Status == CON_CSM.S_CLOSED || c.Status == CON_CSM.S_RESOLVED_WITH_C) ) && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && parentMap.get(c.Id) != null){
                string nonTechCase = '';
                for(Case cc : parentMap.get(c.Id)){
                    nonTechCase = nonTechCase + cc.CaseNumber + ',';
                }
                c.Status.addError('It is not possible to complete the process because at least one child case has a different record type than Technology Solution.\n\nPlease remove the child case below from its parent before proceed: '+nonTechCase.Substring(0,nonTechCase.length()-1),true);
            }
        }    
    }
    
    public static void CheckForAssetsForChildsHavingDifferentAccountIDThanParent(List<Case> newList,Map<Id, Case> oldMap){
        Map<Id, Case> parentMap = new Map<Id,Case>();    // Id- Id of record; Case- Record
        Map<Id, List<Case>> childMap = new Map<Id,List<Case>>();    // Id- ParentID, List<Case> - List of child cases        
        Map<Id, List<Case>> littleChildMap = new Map<Id,List<Case>>();    // Id- ParentID, List<Case> - List of child cases
        parentMap = getParentMapFromNewCase(newList,oldMap);

        if(parentMap.size() > 0){
            /* Creating Child/Little Child Maps from the list of child/Little child case */
            List<Case> childCases = getChildCasesForTech(parentMap.KeySet());  
            List<Case> littleChildCases = getChildCasesForTech((new Map<Id,Case>(childCases)).KeySet());  
            childMap = populateParentChildMap(childCases);   
            littleChildMap = populateParentChildMap(littleChildCases); 
            Map<Id, List<Asset>> missingAssetsMap = getAssetsForChild(parentMap, childCases, littleChildCases);
            
            for(Case c : newList){
                if(oldMap != null && oldMap.get(c.Id)!= null && c.Close_all_child_case_with_parent__c && (c.Status != oldMap.get(c.Id).Status && (c.Status == CON_CSM.S_CLOSED || c.Status == CON_CSM.S_RESOLVED_WITH_C) ) && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && parentMap.get(c.Id) != null){
                    Case parent = parentMap.get(c.Id);
                    for(Case child : childMap.get(parent.Id)){
                        if(child.AssetId == null && child.AccountId != parent.AccountId && missingAssetsMap.get(child.AccountId) == null){
                            c.addError('It is not possible to complete the process because at least one child case has an empty Asset which is not in Parent List.\n\nPlease assigned asset and case categorization to the child case below before proceed.');
                        }
                        if(littleChildMap.containsKey(child.Id)){
                            for(Case littleChild : littleChildMap.get(child.Id)){
                                if(littleChild.AssetId == null && littleChild.AccountId != child.AccountId && missingAssetsMap.get(littleChild.AccountId) == null){
                                    c.addError('Its is not possible to complete the process because at least one child case has an empty Asset which is not in Parent List.\n\nPlease assigned asset and case categorization to the child case below before proceed.');
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static Map<Id, Case> getParentMapFromNewCase(List<Case> newList,Map<Id, Case> oldMap){
        Map<Id, Case> parentMap = new Map<Id,Case>();
        for(case c: newList){
            if(oldMap != null && oldMap.get(c.Id)!= null && c.Close_all_child_case_with_parent__c && (c.Status != oldMap.get(c.Id).Status && (c.Status == CON_CSM.S_CLOSED || c.Status == CON_CSM.S_RESOLVED_WITH_C) ) && c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                parentMap.put(c.id,c);
            }
        }
            
        return parentMap;
    }
    
    public static Map<Id, List<Asset>> getAssetsForChild(Map<Id, Case> parentMap,List<Case> childCases,List<Case> littleChildCases){
        List<Id> Case_CategorizationIds = new List<Id>();
        Set<Id> ProductIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Id key : parentMap.keySet()) {
            Case c = parentMap.get(key);
            if(c.Case_CategorizationId__c != null){
                Case_CategorizationIds.add(c.Case_CategorizationId__c);
            }
        }
        
        for(case c: childCases){
            accountIds.add(c.AccountId);
        }
        for(Case c: littleChildCases){
            accountIds.add(c.AccountId);
        }
        List<CSM_QI_Case_Categorization__c> Case_Categorizations = [SELECT ID, Product__c FROM CSM_QI_Case_Categorization__c WHERE Id IN: Case_CategorizationIds];
        if(Case_Categorizations.size() > 0){
            for(CSM_QI_Case_Categorization__c cc : Case_Categorizations){
                ProductIds.add(cc.Product__c);
            }
        }
        
        List<Asset> missingAssets = [SELECT Id,Product2Id, Name, AccountId from Asset Where AccountId  IN: accountIds and Product2Id  IN :ProductIds];
        Map<Id, List<Asset>> missingAssetsMap = populateMissingAssets(missingAssets);
        
        return missingAssetsMap;        
    }

    public static void sendSMSNotificationtoMIR3(List<Case> newList,Map<Id, Case> oldMap){
        Case cs = null;
        boolean is24_7 = false;
        String message;
        integer before = 5,after = 7;
        List<String> prodList = new List<String> {'GTN - Data Hub','GTN - Financial Consolidation & Accruals','GTN - Insight Generation & Analytics','GTN - Forecasting and Planning','GTN - Pricing & Contract Management','GTN - Scenario Modeling & Optimization'};
        CSM_ExternalClient_info__c eci = CSM_ExternalClient_info__c.getValues('Mir3');
        if(eci != null && eci.client_secret__c != null){
            List<String> days = eci.client_secret__c.split('-');
            if(days != null && !days.isEmpty()){
                before = integer.valueOf(days[0]);
                after = integer.valueOf(days[1]);
            }
        }
        for(Case c : newList) {
            Datetime createdDate = c.CreatedDate;
            Date ctdDate = c.CreatedDate.date();
            Integer createdDay = createdDate.day();
            Integer numberDays = date.daysInMonth(ctdDate.year(), ctdDate.month());
            if((numberDays-createdDay) <= before || createdDay <= after){
                is24_7 = true;
            }
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && (c.Owner__c == 'Mir3 SMS Notification' || (c.ProductName__c != null && prodList.contains(c.ProductName__c) && c.AccountCountry__c == CON_CSM.S_USA_CODE)) && c.CaseSource__c == CON_CSM.S_CUSTOMER && (is24_7 || c.Priority == CON_CSM.S_PT1 || c.Priority == CON_CSM.S_PT2) && (c.Origin == CON_CSM.S_EMAIL || c.Origin == CON_CSM.S_CUSTOMER_PORTAL)){
                cs = c;
                message = 'CSM Case Alert \nCase Number: '+c.CaseNumber+'\nCustomer: '+c.Account_Name_Article__c+'\nProduct: '+c.ProductName__c+'\nPriority: '+c.Priority+'\nSubject: '+c.Subject; 
            }
        }
        if(EXT_CSM_Validator_Cls.hasMir3Notification() && cs != null && eci != null && eci.Client_Url__c != null && !System.isFuture() && !System.isBatch() && message != null){
            SRV_CSM_AssignPermissionSet.oneStepNotificationOpMIR3(cs.Id,cs.CaseNumber,cs.Subject,message,is24_7);
            EXT_CSM_Validator_Cls.setMir3Notification();
        }
    }
}
