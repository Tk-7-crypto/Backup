/**
* This is Territory2 trigger handler class.
* version : 1.0
*/
public class DAOH_Territory2 {
    
    private static string CON_SHR_TER = 'SHR_TER';
    private static string CON_Territory = 'Territory';
    private static string CON_All = 'ALL';  
    private static string DEFAULT_ACCESS_LEVEL = 'Edit';    
    
    private static List<Territory_Sharing__c> createTerritorySharingList = new List<Territory_Sharing__c>();
    private Static List<Territory_Sharing__c> territorySharingInsertList = new List<Territory_Sharing__c>();
    private static Map<Id,Territory2> territoryDataMap = new Map<Id,Territory2>();
    private static List<Territory2> leafTerritoryToProcessList = new List<Territory2>();
    private static Map<Id,List<Territory2>> parentIdtoChildListMap = new Map<Id,List<Territory2>>();
    private static Map<String,Group> groupMap = new Map<String,Group>();
    private static Map<Id, Id> territoryIdToGroupIdMap = new Map<Id, Id>();
    private static Map<Id,List<GroupMember>> groupIdToGroupMemberListMap = new Map<Id,List<GroupMember>>();
    
    public static void setLeafNode(List<Territory2> newList, Map<Id,Territory2> oldMap){
        
        Set<Id> territoryIdSet = new Set<Id>();
        Set<Id> parentTerritoryIdSet = new Set<Id>();
        List<Territory2> terToUpdateList = new List<Territory2>();
        
        for(Territory2 ter : newList){
            if(trigger.IsInsert){
                if(trigger.IsBefore)
                    ter.Leaf_Node__c = true;
                else{
                    if(ter.ParentTerritory2Id != null)
                        parentTerritoryIdSet.add(ter.ParentTerritory2Id);
                }
            }            
            if(trigger.IsUpdate && ter.ParentTerritory2Id != oldMap.get(ter.Id).ParentTerritory2Id && ter.ParentTerritory2Id != null){
                parentTerritoryIdSet.add(ter.ParentTerritory2Id);
                if(oldMap.get(ter.Id).ParentTerritory2Id != null)
                    parentTerritoryIdSet.add(oldMap.get(ter.Id).ParentTerritory2Id);
            }
            if(trigger.IsDelete && ter.ParentTerritory2Id != null){
                parentTerritoryIdSet.add(ter.ParentTerritory2Id);                
            }
        }
        
        
        if(parentTerritoryIdSet.size() > 0){
            Set<String> fieldSet = new Set<String>{'Id', 'ParentTerritory2Id'};
                List<Territory2> territoryList = new SLT_Territory().getTerritoryByParentId(fieldSet, parentTerritoryIdSet);            
            for(Territory2 ter : territoryList){
                territoryIdSet.add(ter.ParentTerritory2Id);              
            }
            
            for(Id terId : parentTerritoryIdSet){
                if(territoryIdSet.contains(terId)){
                    Territory2 updateTer = new Territory2();
                    updateTer.Id = terId;
                    updateTer.Leaf_Node__c = false;
                    terToUpdateList.add(updateTer);                    
                }
                else{
                    Territory2 updateTer = new Territory2();
                    updateTer.Id = terId;
                    updateTer.Leaf_Node__c = true;
                    terToUpdateList.add(updateTer);                    
                }
                
            }
        }
        try{
            if(terToUpdateList.size() > 0){
                update terToUpdateList;
            }
        }catch(DmLException ex){
            throw ex;            
        }
        if(!trigger.IsBefore)
            createOrDeletePublicGroup(newList, oldMap);
    }
    
    public static void createOrDeletePublicGroup(List<Territory2> newList, Map<Id,Territory2> oldMap){
        
        List<Group> createdGroupList = new List<Group>();
        List<Group> deletedGroupList = new List<Group>();
        
        Set<Id> relatedIdSet = new Set<Id>();
        Set<String> grpFieldSet = new Set<String>{'Id', 'Developername'};
            String variable1 =' Developername like \'' + CON_SHR_TER + '_%\' ';
        List<Group> CustomSharingGroupList = new SLT_Groups().getGroupByDevelopername(grpFieldSet, variable1);        
        
        for(Group grp : CustomSharingGroupList){
            groupMap.put(grp.developername,grp);
        }       
        
        for(Territory2 ter : newList){
            if(ter.Included_in_Custom_Sharing__c && ter.Sharing_Pillar__c == CON_SHR_TER){
                if(trigger.IsInsert){
                    if(!groupMap.containsKey(CON_SHR_TER+'_'+ter.Legacy_Id__c)){
                        Group gp = new Group(Name = ter.Name, developername = CON_SHR_TER+'_'+ter.Legacy_id__C);
                        createdGroupList.add(gp);
                    }                                    
                }
                if(trigger.IsUpdate){
                    if(ter.Leaf_Node__c != oldMap.get(ter.Id).Leaf_Node__c || 
                       ter.Included_in_Custom_Sharing__c!= oldMap.get(ter.Id).Included_in_Custom_Sharing__c ||
                       ter.Sharing_Pillar__c!= oldMap.get(ter.Id).Sharing_Pillar__c){
                           if(ter.Leaf_Node__c == false){
                               if(groupMap.containsKey(CON_SHR_TER+'_'+ter.Legacy_Id__c)){
                                   //deletedGroupList.add(groupMap.get(CON_SHR_TER+'_'+ter.Legacy_Id__c));    
                               }
                           }
                           if(ter.Leaf_Node__c == true){
                               if(!groupMap.containsKey(CON_SHR_TER+'_'+ter.Legacy_Id__c)){
                                   Group gp = new Group(Name = ter.Name, developername = CON_SHR_TER+'_'+ter.Legacy_id__C);
                                   createdGroupList.add(gp);                            
                               }
                           }
                       }                
                }
                /*
if(trigger.IsDelete){
if(ter.Leaf_Node__c){
if(groupMap.containsKey(CON_SHR_TER+'_'+ter.Legacy_Id__c)){
deletedGroupList.add(groupMap.get(CON_SHR_TER+'_'+ter.Legacy_Id__c));                            
}              
}
}*/               
            }            
        }
        
        try{
            if(createdGroupList.size() > 0){
                insert createdGroupList;
                addGroupMember(newList, oldMap);
            }
            //if(deletedGroupList.size() > 0)
            //delete deletedGroupList;
        }catch(DmLException ex){
            throw ex;           
        }
    }
    
    
    public static void addGroupMember(List<Territory2> newList, Map<Id,Territory2> oldMap){
        if(trigger.IsInsert || trigger.IsUpdate){
            List<GroupMember> recordInsertList = new List<GroupMember>();
            List<GroupMember> recordDeleteList = new List<GroupMember>();
            Set<Id> terIdSet = new Set<Id>();
            for(Territory2 ter: newList)
                terIdSet.add(ter.ID);
            
            //if(territoryDataMap.size() == 0){
            Set<String> fieldSet = new Set<String>{'Id', 'ParentTerritory2Id', 'Developername','Leaf_Node__c'};
                List<Territory2>territoryList = new SLT_Territory().getTerritory(fieldSet);
                
                for(Territory2 ter : territoryList){
                    territoryDataMap.put(ter.Id, ter);
                    
                    if(ter.ParentTerritory2Id != null){
                        if(!parentIdtoChildListMap.containsKey(ter.ParentTerritory2Id)){
                            List<Territory2> childList = new List<Territory2>();
                            childList.add(ter);
                            parentIdtoChildListMap.put(ter.ParentTerritory2Id,childList);           
                            
                        }else{
                            parentIdtoChildListMap.get(ter.ParentTerritory2Id).add(ter);
                        }                
                    }                     
                    
                }
            //}
            Set<String> grpFieldSet = new Set<String>{'Id', 'Name', 'Developername'};
            List<Group> groupTerritoryList = new SLT_Groups().getGroupByTypeAndRelatedId(grpFieldSet, CON_Territory, terIdSet);
            
            Set<String> developerNameSet = new Set<String>();
            String whereCondtion = 'Leaf_Node__c = true';
            Set<String> fieldSet2 = new set<String>{'Id','Legacy_Id__c'};
                List<Territory2> leafNodeTerList = new SLT_Territory().getTerritoryByWhereCondtion(fieldSet2, whereCondtion);
            
            for(Territory2 ter: leafNodeTerList){
                developerNameSet.add(CON_SHR_TER+'_'+ter.Legacy_Id__c);
            }
            
            Set<String> grpFieldSet2 = new Set<String>{'Id', 'developername', 'type'};
                List<Group> CustomsharingGroupList = new SLT_Groups().getGroupByDevelopernameSet(grpFieldSet2, developerNameSet);
            
            if(CustomsharingGroupList.size() > 0){
                Set<Id> territoryGroupIdSet = new Set<Id>();
                
                for(Group grp :CustomsharingGroupList){
                    territoryGroupIdSet.add(grp.id);
                    groupMap.put(grp.developername,grp);
                }
                
                for(Group grp : groupTerritoryList){
                    territoryIdToGroupIdMap.put(grp.RelatedId, grp.id);
                    //territoryGroupIdSet.add(grp.id);
                }
                List<GroupMember> groupMemberList = new SLT_GroupMember().getGroupMemberByGroupId(territoryGroupIdSet);                
                
                for(Group grp : CustomsharingGroupList){                
                    List<GroupMember> gMList = new List<GroupMember>();
                    for(GroupMember gm : groupMemberList){
                        if(gm.GroupId == grp.Id){
                            gMList.add(gm);                    
                        }
                    }
                    groupIdToGroupMemberListMap.put(grp.Id,gMList);        
                }
            }
            
            //}       
            
            for(Territory2 ter : newList){
                if(trigger.IsInsert){
                    if(ter.Included_in_Custom_Sharing__c && ter.Sharing_Pillar__c == CON_SHR_TER){
                        List<Territory2> terList = getData(ter.Id);
                        if(groupMap.containsKey(CON_SHR_TER+'_'+ter.Legacy_Id__c)){
                            id groupId = groupMap.get(CON_SHR_TER+'_'+ter.Legacy_Id__c).Id;
                            for(Territory2 ter2: terList){
                                GroupMember groupMem = new GroupMember(GroupId = groupId, UserOrGroupId = territoryIdToGroupIdMap.get(ter2.Id));
                                recordInsertList.add(groupMem);
                            }
                        }
                    }
                }            
            }
            
            if(trigger.IsUpdate){
                List<Territory2> getLeafNodeDataTerritoryList = new List<Territory2>();
                for(Territory2 ter : newList){
                    if(ter.Included_in_Custom_Sharing__c && ter.Sharing_Pillar__c == CON_SHR_TER){
                        getLeafNodeDataTerritoryList.add(ter);
                    }                
                }
                getLeafNodeData(getLeafNodeDataTerritoryList);
                if(leafTerritoryToProcessList.size() > 0){
                    for(Territory2 ter : leafTerritoryToProcessList){
                        
                        Set<GroupMember> recordInsertSet = new Set<GroupMember>();
                        Set<GroupMember> recordDeleteSet = new Set<GroupMember>();
                        
                        Set<GroupMember> recordInsertSet2 = new Set<GroupMember>();
                        Set<GroupMember> recordDeleteSet2 = new Set<GroupMember>();
                        
                        
                        if(groupMap.containsKey(CON_SHR_TER+'_'+ter.Legacy_Id__c)){                                              
                            id groupId = groupMap.get(CON_SHR_TER+'_'+ter.Legacy_Id__c).Id;
                            if(groupIdToGroupMemberListMap.containsKey(groupId)){
                                List<Territory2> terList = getData(ter.Id); 
                                List<GroupMember> groupMemberList = groupIdToGroupMemberListMap.get(groupId);
                                // recordDeleteSet
                                for(GroupMember grpMember : groupMemberList){
                                    recordDeleteSet.add(grpMember);
                                }
                                recordDeleteSet2 = recordDeleteSet;
                                if(terList.size() > 0){
                                    for(Territory2 ter2: terList){
                                        GroupMember groupMem = new GroupMember(GroupId = groupId, UserOrGroupId = territoryIdToGroupIdMap.get(ter2.Id));
                                        recordInsertSet.add(groupMem);
                                    }
                                    recordInsertSet2 = recordInsertSet;                                
                                }                          
                                
                                for(GroupMember grpMember1: recordInsertSet2){
                                    // Insert Group Member
                                    for(GroupMember grpMember2 : recordDeleteSet2){
                                        if(grpMember1.UserOrGroupId == grpMember2.UserOrGroupId){
                                            recordInsertSet.remove(grpMember1);
                                            recordDeleteSet.remove(grpMember2);
                                            
                                        }
                                    }                  
                                }
                            }
                            
                        }                    
                        if(recordInsertSet.size() > 0){
                            for(GroupMember grpMember : recordInsertSet){
                                recordInsertList.add(grpMember);                            
                            }
                        }
                        if(recordDeleteSet.size() > 0){
                            for(GroupMember grpMember : recordDeleteSet){
                                recordDeleteList.add(grpMember);                            
                            }
                        }
                    }
                }            
            }
            territorySharingInsertList = createTerritorySharingObj();
            String newRecords = JSON.serialize(territorySharingInsertList);
            try{
                if(recordInsertList.size() > 0)
                    insert recordInsertList;
                if(recordDeleteList.size() > 0)
                    delete recordDeleteList;
            }catch(DmLException ex){
                throw ex;           
            }
            insertTerritorySharingRecord(newRecords);            
        }
        
    }
    
    @future
    private static void insertTerritorySharingRecord(String newRecords){
        try{
            List<Territory_Sharing__c> newRecordsList = (List<Territory_Sharing__c>)JSON.deserialize(newRecords,List<Territory_Sharing__c>.class);
            if(newRecordsList.size() > 0)
                insert newRecordsList;
            
        }catch(DmLException ex){
            throw ex;            
        }        
    }
    
    public static List<Territory2> getData(Id childId){
        
        List<Territory2> hierarchyList = new List<Territory2>();
        if(territoryDataMap.containsKey(childId)){
            if(territoryDataMap.get(childId).ParentTerritory2Id == null){
                hierarchyList.add(territoryDataMap.get(childId));
                return hierarchyList;
            }else{
                hierarchyList = getData(territoryDataMap.get(childId).ParentTerritory2Id);
                hierarchyList.add(territoryDataMap.get(childId));
                return hierarchyList;
            }            
        }
        return hierarchyList;      
    }
    
    public static void getLeafNodeData(List<Territory2> childTerritoryList){
        
        for(Territory2 ter : childTerritoryList){
            if(parentIdtoChildListMap.containsKey(ter.Id)){                    
                getLeafNodeData(parentIdtoChildListMap.get(ter.Id));
            }else{
                leafTerritoryToProcessList.add(ter);                
            }
        }        
    }
    
    public static List<Territory_Sharing__c> createTerritorySharingObj(){
        
        
        Set<String> toCheckterritorySharingSet = new Set<String>();
        
        Set<String> terSharingFieldSet = new Set<String>{'Id','Account_Country__c','Record_Type__c', 'Business_Unit__c', 'Parent_Customer_Code__c', 'Access_Level__c', 'Parent_Sobject_Name__c', 'Group_Id__c'};
            List<Territory_Sharing__c> territorySharingDataList = new SLT_TerritorySharing().getTerritorySharing(terSharingFieldSet);        
        
        for(Territory_Sharing__c terSharingList: territorySharingDataList){
            toCheckterritorySharingSet.add(terSharingList.Account_Country__c+','+terSharingList.Record_Type__c+','+terSharingList.Business_Unit__c+','+terSharingList.Parent_Customer_Code__c+','+terSharingList.Parent_Sobject_Name__c+','+terSharingList.Group_Id__c);
        }
        
        Set<String> grpFieldSet = new Set<String>{'Id', 'Developername'};
            String variable1 =' Developername like \'' + CON_SHR_TER + '_%\' ';
        List<Group> CustomsharingGroupList = new SLT_Groups().getGroupByDevelopername(grpFieldSet, variable1);
        
        Set<String> sObjectSharingFieldSet = new Set<String>{'Id', 'Enable_Sharing_Calculation__c', 'Parent_Sobject__c', 'Sharing_Territory_Label__c'};
            List<SObject_Sharing__c> sObjectSharingList = new SLT_sObjectSharing().getSObjectSharing(sObjectSharingFieldSet);        
        
        for(SObject_Sharing__c sos : sObjectSharingList){
            if(sos.Enable_Sharing_Calculation__c && sos.Parent_Sobject__c != null && sos.Sharing_Territory_Label__c != null){
                
                if((trigger.IsInsert) || (trigger.IsUpdate)){
                    for(Group grp : CustomsharingGroupList){
                        String name = CON_SHR_TER+'_';
                        String accCountry = name.difference(grp.Developername);
                        Territory_Sharing__c terrSharing = new Territory_Sharing__c(Account_Country__c = accCountry, Record_Type__c = CON_All, 
                                                                                    Business_Unit__c = CON_All, Parent_Customer_Code__c = CON_All, Parent_Sobject_Name__c = sos.Parent_Sobject__c,
                                                                                    Group_Id__c = grp.Id, isActive__c = true, Access_Level__c = DEFAULT_ACCESS_LEVEL);
                        string checkTerritorySharing = terrSharing.Account_Country__c+','+terrSharing.Record_Type__c+','+terrSharing.Business_Unit__c+','+terrSharing.Parent_Customer_Code__c+','+terrSharing.Parent_Sobject_Name__c+','+terrSharing.Group_Id__c;
                        if(!toCheckterritorySharingSet.contains(checkTerritorySharing))
                            if(!createTerritorySharingList.contains(terrSharing))
                            createTerritorySharingList.add(terrSharing);
                    }
                }
            }
        }
        return createTerritorySharingList;
    }
}