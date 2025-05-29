public class DAOH_Campaign {
    public static void checkCampaignOwner(List<Campaign> newList){
        Map<Id, User> currentUserMap = new SLT_User().selectByUserId(new Set<Id>{UserInfo.getUserId()},new Set<String>{'Profile.Name','ProfileId'}); 
        for(Campaign cmp : newList){
            if((currentUserMap.get(UserInfo.getUserId()).Profile.Name != CON_CRM.SYSTEM_ADMIN_PROFILE && currentUserMap.get(UserInfo.getUserId()).Profile.Name != CON_CRM.MARKETING_INTEGRATION_USER_PROFILE && cmp.OwnerId != UserInfo.getUserId()) || (cmp.OwnerId == UserInfo.getUserId() && cmp.Status != CON_CRM.CAMPAIGN_STATUS_PLANNED)){
                cmp.addError(System.label.Campaign_CRM_Campaign_Not_Delete);
            }
        }
    }
    
    /**
     * This Method is used to campaign deletion, update Hierarchy from child campaign and update hierarchy count from Parent campaign.
     * @params  List<Campaign> newList
     * @return void
     */
    public static void updateHierarchyInCampaign(List<Campaign> newList){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> { Campaign.SObjectType }
        );
        
        Map<Id,Campaign> campaignMap = new Map<Id,Campaign>();
        Map<Id, Campaign> parentCampaignMap = new Map<Id, Campaign>();
        Map<Id, Campaign> childCampaignMap;
        Set<String> childCampaignIdSet = new Set<String>();
        Set<Id> parentCampaignIdSet = new Set<Id>();
        List<Id> parentHierarchyList = new List<Id>();
        List<Campaign> updateCampaignList = new List<Campaign>();
        String hierarchyToReplace;
        
        for(Campaign campaign : newList){
            campaignMap.put(campaign.Id, new Campaign(Id = campaign.Id, Name = campaign.Name, ParentId = campaign.ParentId, MQLS_in_Hierarchy__c = campaign.MQLS_in_Hierarchy__c, Parents_Hierarchy__c = campaign.Parents_Hierarchy__c));
            childCampaignIdSet.add('%'+campaign.Id+'%');
            if(campaign.ParentId !=  Null){
                parentHierarchyList = campaign.Parents_Hierarchy__c.split(';');
                parentCampaignIdSet.addAll(parentHierarchyList);
            }
        }
        
        if(parentCampaignIdSet.size() > 0){
            parentCampaignMap = new SLT_Campaign().selectById(parentCampaignIdSet);
        }
        if(childCampaignIdSet.size() > 0){
            childCampaignMap = new SLT_Campaign().getchildCampaignsByparentHierarchy(childCampaignIdSet);
        }
   
        for(Campaign campaign : campaignMap.values()){
            if(campaign.MQLS_in_Hierarchy__c == Null){
                campaign.MQLS_in_Hierarchy__c = 0;
            }
            
            if(campaign.Parents_Hierarchy__c != Null){
                if(campaign.Parents_Hierarchy__c !=''){
                    hierarchyToReplace = campaign.Parents_Hierarchy__c + ';' + campaign.Id; 
                }
                else{
                    hierarchyToReplace = campaign.Id;
                }
            }
            else{
                hierarchyToReplace = campaign.Id;
            }
            
            //--------- Child Campaign Traverse start---------------//
            // This is update the Parent Hierarchy Field in child campaign.
            if(childCampaignMap != Null){
                String tempHierarchyToReplace;
                for(Campaign childCampaign : childCampaignMap.values()){
                    if(campaignMap.containsKey(childCampaign.Id)){
                        childCampaign = campaignMap.get(childCampaign.Id);
                    }
                    else if(parentCampaignMap.containsKey(childCampaign.Id)){
                        childCampaign = parentCampaignMap.get(childCampaign.Id);
                    }
                    
                    if(childCampaign.Parents_Hierarchy__c.contains(campaign.Id)){
                        if(childCampaign.ParentId != campaign.Id){
                            tempHierarchyToReplace = hierarchyToReplace + ';';
                        }
                        else{
                            tempHierarchyToReplace =  hierarchyToReplace;
                        }
                        
                        childCampaign.Parents_Hierarchy__c = childCampaign.Parents_Hierarchy__c.replaceFirst(tempHierarchyToReplace, '');

                        if(!updateCampaignList.contains(childCampaign) && !campaignMap.containsKey(childCampaign.Id)){
                            updateCampaignList.add(childCampaign);
                        }
                    }
                } 
            }
            //---------------Child Campaign Traverse End--------------------------------//
            
            //---------------Parent Campaign Traverse start-----------------------------//
            if(campaign.Parents_Hierarchy__c != Null  ){
                if(campaign.Parents_Hierarchy__c != '' && campaign.MQLS_in_Hierarchy__c > 0){
                    updateCampaignList.addAll(updateParentHirearchyCount(campaign.Parents_Hierarchy__c.split(';'), parentCampaignMap, campaignMap, updateCampaignList, campaign.MQLS_in_Hierarchy__c, false));
                }
            }
            //---------------Parent Campaign Traverse start-----------------------------//
            
            campaign.ParentId = Null;
            campaign.Parents_Hierarchy__c = '';
        }
        
        if(updateCampaignList.size() > 0){
            UTL_ExecutionControl.stopTriggerExecution = true;
            uow.registerDirty(updateCampaignList);
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
    
    /**
    * This Method is used to update Hierarch from child campaign and update hierarchy count from Parent campaign when parent Campaign is changed.
    * @params  List<Campaign> newList
    * @params  Map<Id, Campaign> oldMap
    * @return  void
    */
    public static void updateHierarchyField(List<Campaign> newList, Map<Id, Campaign> oldMap){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> { Campaign.SObjectType }
        );
        
        Id oldParentId;
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        Map<Id, Campaign> triggerCampaignListToMap = new Map<Id, Campaign>();
        Map<Id, Campaign> parentCampaignMap;
        Map<Id, Campaign> childCampaignMap;
        Set<String> childCampaignIdSet = new Set<String>();
        Set<Id> parentCampaignIdSet = new Set<Id>();
        Set<Id> updateCampaignIdSet;
        Set<Id> parentHierarchyIdSet = new Set<Id>();
        List<Campaign> finalUpdateCampaignList;
        List<Id> parentHierarchyIdList = new List<Id>();
        List<Campaign> insertCampaignList = new List<Campaign>();
        List<Campaign> campaignList = new List<Campaign>();
        
        for(Campaign campaign : newList){
            triggerCampaignListToMap.put(campaign.Id, campaign);

            if(oldMap != Null){
                oldParentId = oldMap.get(campaign.Id).ParentId;
            }
            else{
                oldParentId = Null;
            }
            
            if(campaign.ParentId != oldParentId){
                if(campaign.ParentId != Null){
                    parentCampaignIdSet.add(campaign.ParentId);
                }
                
                if(campaign.MQLS_in_Hierarchy__c == Null){
                    campaign.MQLS_in_Hierarchy__c = 0;
                }
                
                if(Trigger.isUpdate){
                    campaignMap.put(campaign.Id, campaign);
                    childCampaignIdSet.add('%'+campaign.Id+'%');
                    if(campaign.Parents_Hierarchy__c !=  Null){
                        parentHierarchyIdList = campaign.Parents_Hierarchy__c.split(';');
                        parentHierarchyIdSet.addAll(parentHierarchyIdList);
                    }
                }
                else{
                     insertCampaignList.add(campaign);
                }      
            }
        }
        
        if(Trigger.isInsert){
            campaignList.addAll(insertCampaignList);
        }
        else{
            campaignList.addAll(campaignMap.values());
        }
        
        if(campaignList.size() > 0 ){
            String tempHoldNewHierarchy = '';
            String tempHoldParentHierarchy;
            updateCampaignIdSet = new set<Id>();
            finalUpdateCampaignList = new List<Campaign>();
            parentCampaignMap = new Map<Id, Campaign>();

            if(parentCampaignIdSet.size() > 0){
                parentCampaignMap = new SLT_Campaign().selectById(parentCampaignIdSet);
            }
            if(childCampaignIdSet.size() > 0){
                childCampaignMap = new SLT_Campaign().getchildCampaignsByparentHierarchy(childCampaignIdSet);
            }
            
            if(parentCampaignMap.size() > 0){
                for(Campaign parentCampaign : parentCampaignMap.values()){
                    if(parentCampaign.Parents_Hierarchy__c !=  Null){
                        parentHierarchyIdList = parentCampaign.Parents_Hierarchy__c.split(';');
                        parentHierarchyIdSet.addAll(parentHierarchyIdList);
                    }
                }
            }
            
            if(parentHierarchyIdSet.size() > 0){
                parentCampaignMap.putAll(new SLT_Campaign().selectById(parentHierarchyIdSet));
            }
            
            for(Campaign campaign : campaignList){
                if(campaign.ParentId != Null){
                    if(updateCampaignIdSet.contains(campaign.ParentId) ){
                        tempHoldParentHierarchy = campaignMap.get(campaign.ParentId).Parents_Hierarchy__c;
                    }
                    else{
                        tempHoldParentHierarchy = parentCampaignMap.get(campaign.ParentId).Parents_Hierarchy__c;
                    }
                    
                    if(tempHoldParentHierarchy == Null){
                        tempHoldParentHierarchy = '';
                    }
                    
                    if(campaignMap.containsKey(campaign.ParentId)){
                        childCampaignMap.put(Campaign.Id, campaign);
                    }
                    
                    if(tempHoldParentHierarchy != ''){
                        tempHoldNewHierarchy = tempHoldParentHierarchy + ';' + campaign.ParentId;
                    }
                    else{
                        tempHoldNewHierarchy = campaign.ParentId;
                    } 
                }
                
                //-------------------- Child Campaign Traverse start ---------------------------//
                if(childCampaignMap != Null){
                    finalUpdateCampaignList.addAll(updateChildCampaignHirearchy(campaign, childCampaignMap, triggerCampaignListToMap, parentCampaignMap, tempHoldNewHierarchy, finalUpdateCampaignList));
                }
                //-------------------- Child Campaign Traverse End ---------------------------//
                
                //-------------------- Parent Campaign Traverse start for increase count ---------------------------//
                if(tempHoldNewHierarchy != '' && campaign.MQLS_in_Hierarchy__c > 0){
                    finalUpdateCampaignList.addAll(updateParentHirearchyCount(tempHoldNewHierarchy.split(';'), parentCampaignMap, triggerCampaignListToMap, finalUpdateCampaignList, campaign.MQLS_in_Hierarchy__c, true));
                }
                //-------------------- Parent Campaign Traverse End for increase count ---------------------------//
                
                //-------------------- Parent Campaign Traverse start for decrease count ---------------------------//
                if(campaign.Parents_Hierarchy__c != Null  ){
                    if(campaign.Parents_Hierarchy__c != '' && campaign.MQLS_in_Hierarchy__c > 0){
                        finalUpdateCampaignList.addAll(updateParentHirearchyCount(campaign.Parents_Hierarchy__c.split(';'), parentCampaignMap, triggerCampaignListToMap, finalUpdateCampaignList, campaign.MQLS_in_Hierarchy__c, false));
                    }
                }
                //-------------------- Parent Campaign Traverse End for decrease count ---------------------------//
                
                campaign.Parents_Hierarchy__c =  tempHoldNewHierarchy;
                updateCampaignIdSet.add(campaign.Id);
            }
            
            if(finalUpdateCampaignList.size() > 0){
                UTL_ExecutionControl.stopTriggerExecution = true;
                uow.registerDirty(finalUpdateCampaignList);
                uow.commitWork();
                UTL_ExecutionControl.stopTriggerExecution = false;
            }
        }
    }

    /**
     * This Method to use Update parent hierarchy field for child campaign.
     * @params Campaign campaign
     * @params Map<Id,Campaign> childCampaignMap
     * @params Map<Id,Campaign> triggerCampaignListToMap
     * @params Map<Id,Campaign> parentCampaignMap
     * @params String tempHoldNewHierarchy
     * @params List<Campaign> finalUpdateCampaignList
     * @return List<Campaign> - update child campaign list
     */ 
    private static List<Campaign> updateChildCampaignHirearchy(Campaign campaign, Map<Id,Campaign> childCampaignMap,Map<Id,Campaign> triggerCampaignListToMap, Map<Id,Campaign> parentCampaignMap, String tempHoldNewHierarchy, List<Campaign> finalUpdateCampaignList){
        String tempParentHierarchy;
        List<Campaign> updateCampaignList = new List<Campaign>();
        for(Campaign childCampaign : childCampaignMap.values()){
            if(triggerCampaignListToMap.containsKey(childCampaign.Id)){
                childCampaign = triggerCampaignListToMap.get(childCampaign.Id);
            }
            else if(parentCampaignMap.containsKey(childCampaign.Id)){
                childCampaign = parentCampaignMap.get(childCampaign.Id);
            }
            
            if(childCampaign.Id != campaign.Id && childCampaign.Parents_Hierarchy__c.contains(campaign.Id)){
                if(campaign.Parents_Hierarchy__c == Null || campaign.Parents_Hierarchy__c == ''){
                    childCampaign.Parents_Hierarchy__c = tempHoldNewHierarchy + ';' + childCampaign.Parents_Hierarchy__c;
                }
                else{
                    if(tempHoldNewHierarchy != ''){
                        tempParentHierarchy = campaign.Parents_Hierarchy__c;
                    }
                    else{
                        tempParentHierarchy = campaign.Parents_Hierarchy__c + ';';
                    }
                    
                    childCampaign.Parents_Hierarchy__c = childCampaign.Parents_Hierarchy__c.replaceFirst(tempParentHierarchy, tempHoldNewHierarchy);
                }
                
                if(!finalUpdateCampaignList.contains(childCampaign) && !triggerCampaignListToMap.containsKey(childCampaign.Id) ){
                    updateCampaignList.add(childCampaign);
                }
            }
        }
        
        return updateCampaignList;
    }
    
    /**
     * This Method to use Update  hierarchy count for Parent campaign.
     * @params List<Id> parentIdList
     * @params Map<Id, Campaign> parentCampaignMap
     * @params Map<Id, Campaign> triggerCampaignListToMap
     * @params List<Campaign> finalUpdateCampaigList
     * @params Decimal MQLSInHierarchy
     * @params Boolean isAdd
     * @return List<Campaign> - update parent campaign list
     */
    private static List<Campaign> updateParentHirearchyCount(List<Id> parentIdList, Map<Id, Campaign> parentCampaignMap, Map<Id, Campaign> triggerCampaignListToMap, List<Campaign> finalUpdateCampaignList, Decimal MQLSInHierarchy, Boolean isAdd){
        Campaign parentCampaign;
        List<Campaign> updateCampaignList = new List<Campaign>();
        for(Id parentId : parentIdList){
            if(triggerCampaignListToMap.containsKey(parentId)){
                parentCampaign = triggerCampaignListToMap.get(parentId);
            }
            else{
                parentCampaign = parentCampaignMap.get(parentId);
                if(!finalUpdateCampaignList.contains(parentCampaign))
                    updateCampaignList.add(parentCampaign);
            }
            
            if(parentCampaign.MQLS_in_Hierarchy__c == Null){
                parentCampaign.MQLS_in_Hierarchy__c = 0;
            }

            if(isAdd){
                parentCampaign.MQLS_in_Hierarchy__c += MQLSInHierarchy; 
            }
            else{
                parentCampaign.MQLS_in_Hierarchy__c -= MQLSInHierarchy;
            }
        }
        
        return updateCampaignList;
    }
    
    /**
    * This Methos to use MQl Hierarchy count when 'Mql In Campaign' is update.
    * @params  List<Campaign> newList
    * @params  Map<Id, Campaign> oldMap
    * @return  void
    */ 
    public static void countMQlInHirearchy(List<Campaign> newList, Map<Id, Campaign> oldMap){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> { Campaign.SObjectType }
        );
        
        Set<Id> campaignIdSet = new Set<Id>();
        List<Id> tempParentIdList = new List<Id>();
        List<Campaign> updateCampaignList;
        Map<Id, List<Id>> parentCampaignIdMAp = new Map<Id, List<Id>>();
        Map<Id, Campaign> parentCampaignMap;
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        Map<Id, Campaign> triggerCampaignListToMap = new Map<Id, Campaign>();
        Map<Id, Decimal> oldCampaignNoOfMql = new Map<Id,Decimal>();
        
        for(Campaign campaign : newList){
            triggerCampaignListToMap.put(campaign.Id, campaign);
            
            if(campaign.NoOfMQLs__c != oldMap.get(campaign.Id).NoOfMQLs__c){
                if(campaign.Parents_Hierarchy__c != Null){
                    if(campaign.Parents_Hierarchy__c != ''){
                        tempParentIdList = campaign.Parents_Hierarchy__c.Split(';');
                        campaignIdSet.addAll(tempParentIdList);
                        parentCampaignIdMAp.put(campaign.Id, tempParentIdList);
                    }
                }
                if(campaign.NoOfMQLs__c == Null){
                    campaign.NoOfMQLs__c = 0;
                }
                
                if(oldMap.get(campaign.Id).NoOfMQLs__c == Null){
                    oldCampaignNoOfMql.put(campaign.Id, 0);
                }
                else{
                    oldCampaignNoOfMql.put(campaign.Id, oldMap.get(campaign.Id).NoOfMQLs__c);
                }
                
                campaignMap.put(campaign.Id, campaign);
            }
        }
        
        if(campaignMap.size() > 0){
            if(campaignIdSet.size() > 0){
                parentCampaignMap = new SLT_Campaign().selectById(campaignIdSet);
            }
            
            Decimal diffOfHierarchy;
            updateCampaignList = new List<Campaign>();
            for(Campaign campaign : campaignMap.values()){
                diffOfHierarchy =  campaign.NoOfMQLs__c - oldCampaignNoOfMql.get(campaign.Id);
                campaign.MQLS_in_Hierarchy__c += diffOfHierarchy;
                if(parentCampaignIdMAp != Null){
                    if(parentCampaignIdMAp.containsKey(campaign.Id))
                        updateCampaignList.addAll(updateParentHirearchyCount(parentCampaignIdMAp.get(campaign.Id), parentCampaignMap, triggerCampaignListToMap, updateCampaignList, diffOfHierarchy, true));
                }
            }
            
            if(updateCampaignList.size() > 0){
                UTL_ExecutionControl.stopTriggerExecution = true;
                uow.registerDirty(updateCampaignList);
                uow.commitWork();
                UTL_ExecutionControl.stopTriggerExecution = false;
            } 
        }
    }
}