public with sharing class CNT_CPQ_ApprovalItemsPage {
    
    @AuraEnabled(cacheable=true)
    public static List<WPR_CPQ_ApprovalItemData> getApprovalData() {
        Set<Id> memberOfQueue = new Set<Id>();
        memberOfQueue.add(UserInfo.getUserId());
        for (GroupMember groupMember : [Select Group.Id From GroupMember where UserOrGroupId = :UserInfo.getUserId() and Group.Type = 'Queue'] ) {
            memberOfQueue.add(groupMember.Group.Id);
        }
        
        Map<Id,WPR_CPQ_ApprovalItemData> wcaidMap = new Map<Id,WPR_CPQ_ApprovalItemData>();
        Set<String> targetObjectType = new Set<String>();
        Map<String, String> objectAPINameToLabelMap = new Map<String, String>();
        Map<String, CPQ_Approval_Item_Data__mdt> approvalItemData = new Map<String, CPQ_Approval_Item_Data__mdt>();
        for (CPQ_Approval_Item_Data__mdt mappings : [SELECT API_Name__c, Opportunity_Number__c, Opportunity_Relationship__c, Pricing_Tool__c FROM CPQ_Approval_Item_Data__mdt] ) {
            approvalItemData.put(mappings.API_Name__c, mappings);
            targetObjectType.add(mappings.API_Name__c);
            objectAPINameToLabelMap.put(mappings.API_Name__c, Schema.getGlobalDescribe().get(mappings.API_Name__c).getDescribe().getLabel());
        }
        List<ProcessInstanceWorkitem> apprInsWorkItem = [SELECT Id, ActorId, Actor.Name, Actor.Email, 
                                                                CreatedDate, CreatedBy.Name,CreatedById,
                                                                ProcessInstance.Status, ProcessInstance.TargetObjectId,
                                                                ProcessInstance.TargetObject.Name,ProcessInstance.TargetObject.Type 
                                                            FROM ProcessInstanceWorkitem 
                                                            WHERE ActorId in :memberOfQueue AND 
                                                                    ProcessInstance.Status = 'Pending' AND 
                                                                    ProcessInstance.TargetObject.Type IN : targetObjectType 
                                                            ORDER BY CreatedDate DESC];
        Map<String,Set<Id>> mapSobjectIds = new Map<String,Set<Id>>();
        for (ProcessInstanceWorkitem piwi : apprInsWorkItem) {
            WPR_CPQ_ApprovalItemData wcaid = new WPR_CPQ_ApprovalItemData();
            wcaid.pwiId = piwi.Id;
            wcaid.quotelink = piwi.ProcessInstance.TargetObjectId;
            wcaid.actionLink = piwi.ProcessInstance.TargetObjectId;
            wcaid.objLabel = objectAPINameToLabelMap.get(piwi.ProcessInstance.TargetObject.Type);
            wcaid.type = piwi.ProcessInstance.TargetObject.Type;
            wcaid.recentapproverName = piwi.Actor.Name;
            wcaid.recentapproverlink = piwi.ActorId;
            wcaid.approvaldate = piwi.CreatedDate.format();
            wcaid.quoteName = piwi.ProcessInstance.TargetObject.Name;
            wcaidMap.put(piwi.Id, wcaid);
            if (mapSobjectIds.containsKey(wcaid.type)) {
                mapSobjectIds.get(wcaid.type).add(piwi.Id);
            } else {
                mapSobjectIds.put(wcaid.type, new Set<Id>{piwi.Id});
            }
        }
        if (mapSobjectIds.size()>0) {
            List<String> fieldList;
            for (String sObjectName : mapSobjectIds.keySet()) {
                String opportunityName = '';
                String opportunityNumber = '';
                String opportunityId = '';
                String selectedPricingTool = '';
                String fieldStr = '';
                if (approvalItemData.containsKey(sObjectName)) {
                    CPQ_Approval_Item_Data__mdt approvalData = approvalItemData.get(sObjectName);
                    if (approvalData.Opportunity_Relationship__c != null) {
                        opportunityNumber = approvalData.Opportunity_Number__c; 
                        fieldStr = approvalData.Opportunity_Relationship__c + '.' + opportunityNumber;
                        opportunityName = approvalData.Opportunity_Relationship__c; 
                        fieldStr = String.isBlank(fieldStr) ? (opportunityName + '.Name') : (fieldStr + ',' + opportunityName + '.Name');
                        opportunityId = approvalData.Opportunity_Relationship__c;
                        fieldStr = String.isBlank(fieldStr) ? (opportunityId + '.Id') : (fieldStr + ',' + opportunityId + '.Id');
                    }
                    if (approvalData.Pricing_Tool__c != null) {
                        selectedPricingTool = approvalData.Pricing_Tool__c;
             	        fieldStr = String.isBlank(fieldStr) ? (selectedPricingTool) : (fieldStr + ',' + selectedPricingTool); 
                    }
                }
				
                Map<Id, List<WPR_CPQ_ApprovalItemData>> mapwcaid = new Map<Id, List<WPR_CPQ_ApprovalItemData>>();
                for (Id piwi : mapSobjectIds.get(sObjectName)) {
                    WPR_CPQ_ApprovalItemData wcaid = wcaidMap.get(piwi);
                    if (!mapwcaid.containsKey(wcaid.quotelink)) {
                        mapwcaid.put(wcaid.quotelink, new List<WPR_CPQ_ApprovalItemData>());
                    } 
                    List<WPR_CPQ_ApprovalItemData> wcaidList = mapwcaid.get(wcaid.quotelink);
                    wcaidList.add(wcaid);
                    mapwcaid.put(wcaid.quotelink, wcaidList);
                } 
                Set<Id> tempRecId = mapwcaid.keySet(); 
                                
                String query = 'SELECT ' + fieldStr + ' FROM ' + sObjectName +' WHERE Id IN :tempRecId';
                List<SObject> objectList = Database.query(query);
                
                for (SObject sObj : objectList) {
                    String key = String.valueOf(sObj.get('Id'));
                    List<WPR_CPQ_ApprovalItemData> wcaidList = mapwcaid.get(key);
                    for (WPR_CPQ_ApprovalItemData wcaid: wcaidList) {
                        wcaid.hasEditAccess = true;
                        if (!String.isBlank(opportunityNumber) || !String.isBlank(opportunityId)) {
                            sobject oppObject = sObj.getSObject(opportunityName);
                            wcaid.OpportunityNumber = (!String.isBlank(opportunityNumber) ? String.valueOf(oppObject.get(opportunityNumber)) : '');
                            wcaid.OpportunityName = (!String.isBlank(opportunityNumber) ? String.valueOf(oppObject.get('Name')) : '');
                            wcaid.OpportunityLink = (!String.isBlank(opportunityId) ? String.valueOf(oppObject.get('Id')) : '');
                        }                
                        if (!String.isBlank(selectedPricingTool)) {
                            wcaid.pricingTool = String.valueOf(sObj.get(selectedPricingTool));
                        }
                    }
                }
            }
        }
        return wcaidMap.values();
    }

    @AuraEnabled
    public static Boolean checkForBNF(Id bnfId) {
        boolean isOwnerQueue = false;
        List<BNF2__c> bnfList = [SELECT Id, Name, Revenue_Analyst__r.Owner.Type FROM BNF2__c where id =: bnfId];
        if(bnfList.size() > 0 && bnfList[0].Revenue_Analyst__r.Owner.Type == 'Queue') {
            isOwnerQueue = true;
        } 
        return isOwnerQueue;
    }
	
    @AuraEnabled
    public static string updateApprover(Id piwId, Id newActorId){
        try {
            if(piwId != null && newActorId != null) {
                update new ProcessInstanceWorkitem(Id = piwId, ActorId = newActorId);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'Success';
    }
	
    public class WPR_CPQ_ApprovalItemData {
        @AuraEnabled
        public String pwiId{get; set;}
        @AuraEnabled
        public String quotelink{get; set;}
        @AuraEnabled
        public String type{get; set;}
        @AuraEnabled
        public String OpportunityNumber{get; set;}
        @AuraEnabled
        public String OpportunityName{get; set;}
        @AuraEnabled
        public String OpportunityLink{get; set;}
        @AuraEnabled
        public String recentapproverName{get; set;}
        @AuraEnabled
        public String recentapproverlink{get; set;}
        @AuraEnabled
        public String approvaldate{get; set;}
        @AuraEnabled
        public String quoteName{get; set;}
        @AuraEnabled
        public String actionLink{get; set;}
        @AuraEnabled
        public String pricingTool{get; set;}
        @AuraEnabled
        public String objLabel{get; set;}
        @AuraEnabled
        public Boolean hasEditAccess{get; set;}

        public WPR_CPQ_ApprovalItemData() {
            hasEditAccess = false;
        }
    }
}