/**
* This is SObject Sharing trigger handler class.
* version : 1.0
*/
public class DAOH_SObject_Sharing {
    
    private static string CON_SHR_TER = 'SHR_TER';
    private static string CON_Territory = 'Territory';
    private static string CON_All = 'ALL';  
    private static string DEFAULT_ACCESS_LEVEL = 'Edit';
    
    public static void createTerritorySharingObj(List<SObject_Sharing__c> newList, Map<Id,SObject_Sharing__c> oldMap){
        List<Territory_Sharing__c> createTerritorySharingList = new List<Territory_Sharing__c>();
        Set<String> toCheckterritorySharingSet = new Set<String>();
        
        Set<String> terSharingFieldSet = new Set<String>{'Id','Account_Country__c','Record_Type__c', 'Business_Unit__c', 'Parent_Customer_Code__c', 'Access_Level__c', 'Parent_Sobject_Name__c', 'Group_Id__c'};
            List<Territory_Sharing__c> territorySharingDataList = new SLT_TerritorySharing().getTerritorySharing(terSharingFieldSet);        
        System.debug('territorySharingDataList : '+territorySharingDataList);
        
        for(Territory_Sharing__c terSharingList: territorySharingDataList){
            toCheckterritorySharingSet.add(terSharingList.Account_Country__c+','+terSharingList.Record_Type__c+','+terSharingList.Business_Unit__c+','+terSharingList.Parent_Customer_Code__c+','+terSharingList.Parent_Sobject_Name__c+','+terSharingList.Group_Id__c);
        }
        
        String whereCondtion = 'Leaf_Node__c = true';
        Set<String> fieldSet2 = new set<String>{'Id','Legacy_Id__c'};
            List<Territory2> territory2List = new SLT_Territory().getTerritoryByWhereCondtion(fieldSet2, whereCondtion);
        
        Set<String> developerNameSet = new Set<String>();
        for(Territory2 ter: territory2List){
            developerNameSet.add(CON_SHR_TER+'_'+ter.Legacy_Id__c);
        }
        Set<String> grpFieldSet2 = new Set<String>{'Id', 'developername', 'type'};
            List<Group> CustomsharingGroupList = new SLT_Groups().getGroupByDevelopernameSet(grpFieldSet2, developerNameSet);        
        //List<Group> CustomsharingGroupList = [select Id,name,developername,type from group where developername in :developerNameSet];
        
        for(SObject_Sharing__c sos : newList){
            if(sos.Parent_Sobject__c != 'Opportunity' && sos.Enable_Sharing_Calculation__c && sos.Parent_Sobject__c != null && sos.Sharing_Territory_Label__c != null){                
                if((trigger.IsInsert) || (trigger.IsUpdate && (sos.Enable_Sharing_Calculation__c != oldMap.get(sos.Id).Enable_Sharing_Calculation__c || 
                                                               sos.Parent_Sobject__c != oldMap.get(sos.Id).Parent_Sobject__c || sos.Sharing_Territory_Label__c != oldMap.get(sos.Id).Sharing_Territory_Label__c))){
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
        System.debug('createTerritorySharingList : '+createTerritorySharingList);
        try{
            if(createTerritorySharingList.size() > 0)
                insert createTerritorySharingList;
        }catch(DmLException ex){
            throw ex;            
        }
    }
    
}