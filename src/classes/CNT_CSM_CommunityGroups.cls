public without sharing class CNT_CSM_CommunityGroups {
    @AuraEnabled(cacheable=true)
    public static String getGroupsRelatedToUser() {
        String nwid = Network.getNetworkId();
        Set<Id> groupIds = new Set<Id>();
        List<User> users = new List<User>();
        List<Product2> communityTopics;
        List<Id> removeProd = new List<Id>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || UserInfo.getUserType().contains(CON_PEP.S_PEP_POWERPARTNER)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Account.AccountCountry__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].Contact.Account != null) {
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()){
                    List<Id> prodList = new List<Id>();
                    for(CSM_QI_Data_Portal_Queue_User_details__c s : dataList){
                        prodList.add(s.ProductId__c);
                    }
                    communityTopics = Database.query('SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id IN(SELECT Product2Id FROM Asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true and Product2Id in :prodList) order by Community_Topic__r.Name  ASC');
                }else{
                    List<CSM_QI_Data_Portal_Queue_User_details__c> prodDataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\'');
                    for(CSM_QI_Data_Portal_Queue_User_details__c s : prodDataList){
                        if(s.ProductId__c != null){
                            removeProd.add(s.ProductId__c);
                        }
                    }    
                    if(removeProd.size()>1){
                        communityTopics = Database.query('SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id IN(SELECT Product2Id FROM Asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true and Product2Id not in :removeProd) order by Community_Topic__r.Name  ASC');
                    }else{
                        List<Asset> Ass = [SELECT Product2Id, status, Topic_Visible_in_CSH_Homepage__c FROM Asset WHERE AccountId=:users[0].AccountId];
                        if(Ass!= null){
                            List<Product2> testP = [SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id=:Ass[0].Product2Id];
                            communityTopics = Database.query('SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id IN(SELECT Product2Id FROM Asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true) order by Community_Topic__r.Name  ASC');    
                        }
                    }
                    
                }
                
            }
        }
        String productId ='';
        if(communityTopics != null && communityTopics.size() > 0) {
            //productId = communityTopics[0].Id;
            for(Product2 prod : communityTopics){
                productId += '\'' +prod.Id +'\',';
            }
        }
        if(productId != null || true) {
            List<ProductGroupWrapper> productGroupWrapperList = new List<ProductGroupWrapper>();
            Map<String, String> groupIdVsProductName = new Map<String, String>();
            Map<String, Decimal> groupOrderMap = new Map<String, Decimal>();
            //String condition = 'Product__c != null';
            String condition = 'Product__c in (' + productId.removeEnd(',') + ')';
            List<Product_Group_Relationship__c> productGroups = new SLT_ProductGroupRelationship().getProductRelationships(new Set<String> {'Id', 'Collaboration_Group_Id__c', 'Product__r.name', 'Group_Order__c'}, condition);
            for(Product_Group_Relationship__c productGroup: productGroups) {
                if(productGroup.Collaboration_Group_Id__c != null) {
                    groupIds.add(productGroup.Collaboration_Group_Id__c);
                    groupIdVsProductName.put(productGroup.Collaboration_Group_Id__c, productGroup.Product__r.name);
                    groupOrderMap.put(productGroup.Collaboration_Group_Id__c, productGroup.Group_Order__c);
                }
            }
            if(groupIds.size() > 0) {
                List<CollaborationGroup> relatedGroups = new SLT_CollaborationGroup().getChatterGroupsById(new Set<String>{'Id', 'Name', 'MemberCount', 'LastFeedModifiedDate', 'LastModifiedDate', 'OwnerId','Owner.Name', 'CollaborationType', 'MediumPhotoUrl', 'Description', 'NetworkId'},groupIds);
                for(CollaborationGroup relatedGroup: relatedGroups) {
                    if(relatedGroup.NetworkId == nwid){
                        ProductGroupWrapper productGroupWrapper = new ProductGroupWrapper();
                    productGroupWrapper.relatedGroup = relatedGroup;
                    productGroupWrapper.testData = condition + removeProd;
                    productGroupWrapper.productName = groupIdVsProductName.containsKey(relatedGroup.Id) ? groupIdVsProductName.get(relatedGroup.Id) : 'All';
                    if (groupOrderMap.containsKey(relatedGroup.Id) && groupOrderMap.get(relatedGroup.Id) != null ) {
                        productGroupWrapper.groupOrder = groupOrderMap.get(relatedGroup.Id);
                    } else {
                        productGroupWrapper.groupOrder = 999;
                    }
                    productGroupWrapperList.add(productGroupWrapper);
                    }
                    
                }
            }
            if(productGroupWrapperList.size() > 0) {
                return JSON.serialize(productGroupWrapperList);
            }
        }
        return null;
    }
    @AuraEnabled
    public static String getGroupsRelatedToProduct(String productName) {
        String nwid = Network.getNetworkId();
        Set<Id> groupIds = new Set<Id>();
        List<User> users = new List<User>();
        List<Product2> communityTopics;
        List<Id> removeProd = new List<Id>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || UserInfo.getUserType().contains(CON_PEP.S_PEP_POWERPARTNER)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Account.AccountCountry__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].Contact.Account != null) {
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()){
                    List<Id> prodList = new List<Id>();
                    for(CSM_QI_Data_Portal_Queue_User_details__c s : dataList){
                        prodList.add(s.ProductId__c);
                    }
                    communityTopics = Database.query('SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id IN(SELECT Product2Id FROM Asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true and Product2Id in :prodList) and Community_Topic__r.Name =\''+ productName +'\' order by Community_Topic__r.Name  ASC');
                }else{
                    List<CSM_QI_Data_Portal_Queue_User_details__c> prodDataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\'');
                    for(CSM_QI_Data_Portal_Queue_User_details__c s : prodDataList){
                        if(s.ProductId__c != null){
                            removeProd.add(s.ProductId__c);
                        }
                    }    
                    if(removeProd.size()>1){
                        communityTopics = Database.query('SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id IN(SELECT Product2Id FROM Asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true and Product2Id not in :removeProd) and Community_Topic__r.Name =\''+ productName +'\' order by Community_Topic__r.Name  ASC');
                    }else{
                        List<Asset> Ass = [SELECT Product2Id, status, Topic_Visible_in_CSH_Homepage__c FROM Asset WHERE AccountId=:users[0].AccountId];
                        if(Ass!= null){
                            List<Product2> testP = [SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id=:Ass[0].Product2Id AND Community_Topic__r.Name=:ProductName];
                            communityTopics = Database.query('SELECT Id, Community_Topic__r.Name FROM Product2 WHERE Id IN(SELECT Product2Id FROM Asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true) and Community_Topic__r.Name =\''+ productName +'\' order by Community_Topic__r.Name  ASC');    
                        }
                    }
                    
                }
                
            }
        }
        String productId;
        if(communityTopics != null && communityTopics.size() > 0) {
            productId = communityTopics[0].Id;
        }
        if(productId != null) {
            List<ProductGroupWrapper> productGroupWrapperList = new List<ProductGroupWrapper>();
            String condition = 'Product__c = \'' +productId + '\'';
            List<Product_Group_Relationship__c> productGroups = new SLT_ProductGroupRelationship().getProductRelationships(new Set<String> {'Id', 'Collaboration_Group_Id__c'}, condition);
            for(Product_Group_Relationship__c productGroup: productGroups) {
                if(productGroup.Collaboration_Group_Id__c != null) {
                    groupIds.add(productGroup.Collaboration_Group_Id__c);
                }
            }
            if(groupIds.size() > 0) {
                List<CollaborationGroup> relatedGroups = new SLT_CollaborationGroup().getChatterGroupsById(new Set<String>{'Id', 'Name', 'MemberCount', 'LastFeedModifiedDate', 'LastModifiedDate', 'OwnerId','Owner.Name', 'CollaborationType', 'MediumPhotoUrl', 'Description', 'NetworkId'},groupIds);
                for(CollaborationGroup relatedGroup: relatedGroups) {
                    if(relatedGroup.NetworkId == nwid){
                        ProductGroupWrapper productGroupWrapper = new ProductGroupWrapper();
                    productGroupWrapper.relatedGroup = relatedGroup;
                    productGroupWrapper.productName = productName;
                    productGroupWrapperList.add(productGroupWrapper);
                    }
                    
                }
            }
            if(productGroupWrapperList.size() > 0) {
                return JSON.serialize(productGroupWrapperList);
            }
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static CollaborationGroup getGroupDetails(String groupId) {
        CollaborationGroup chatterGroup;
        if(groupId != null && groupId != '') {
            String groupCondition = 'Id = \'' +groupId + '\'';
            List<CollaborationGroup> chatterGroupList = new SLT_CollaborationGroup().getChatterGroups(new Set<String>{'Id', 'Name', 'MemberCount', 'LastFeedModifiedDate', 'LastModifiedDate', 'OwnerId','Owner.Name', 'CollaborationType', 'MediumPhotoUrl', 'InformationTitle', 'InformationBody'},groupCondition);
            chatterGroup = (chatterGroupList != null && chatterGroupList.size() > 0) ? chatterGroupList[0] : null;
        }
        return chatterGroup;
    }


    @AuraEnabled(cacheable=true)
    public static List<CollaborationGroupMember> getCollaborationGroupMemberId(Id groupId) {
        List<CollaborationGroupMember> groupMembers = new List<CollaborationGroupMember>();
        try {
             groupMembers = [
                SELECT MemberId, Member.FullPhotoUrl, Member.Name, Member.Title
                FROM CollaborationGroupMember
                WHERE CollaborationGroupId = :groupId
            ];
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }

        return groupMembers;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductGroupWrapper> getProductGroupList() {
        List<ProductGroupWrapper> productGroupWrapperList = new List<ProductGroupWrapper>();
        
        List<Product_Group_Relationship__c> productGroups = [SELECT Id, Collaboration_Group_Id__c, Product__r.Name, Group_Order__c 
                                                            FROM Product_Group_Relationship__c 
                                                            ORDER BY Group_Order__c ASC];

        Set<Id> collaborationGroupIds = new Set<Id>();
        for (Product_Group_Relationship__c productGroup : productGroups) {
            if (productGroup.Collaboration_Group_Id__c != null) {
                collaborationGroupIds.add(productGroup.Collaboration_Group_Id__c);
            }
        }

        Map<Id, CollaborationGroup> collaborationGroupMap = new Map<Id, CollaborationGroup>();
        if (!collaborationGroupIds.isEmpty()) {
            collaborationGroupMap = new Map<Id, CollaborationGroup>([
                SELECT Id, Name, MemberCount, LastFeedModifiedDate, LastModifiedDate, OwnerId, Owner.Name, CollaborationType, FullPhotoUrl, InformationTitle, InformationBody, Description 
                FROM CollaborationGroup 
                WHERE Id IN :collaborationGroupIds
            ]);
        }

        for (Product_Group_Relationship__c productGroup : productGroups) {
            if (productGroup.Collaboration_Group_Id__c != null && collaborationGroupMap.containsKey(productGroup.Collaboration_Group_Id__c)) {
                CollaborationGroup relatedGroup = collaborationGroupMap.get(productGroup.Collaboration_Group_Id__c);

                ProductGroupWrapper productGroupWrapper = new ProductGroupWrapper();
                productGroupWrapper.relatedGroup = relatedGroup;
                productGroupWrapper.productGroupId = productGroup.Id;
                productGroupWrapper.productName = productGroup.Product__r.Name;
                productGroupWrapper.groupOrder = productGroup.Group_Order__c;
                productGroupWrapperList.add(productGroupWrapper);
            }
        }

        return productGroupWrapperList;
    }


    public class ProductGroupWrapper {
        @AuraEnabled
        public CollaborationGroup relatedGroup {get; set;}
        @AuraEnabled
        public String productName {get; set;}
        @AuraEnabled
        public String testData{get;set;}
        @AuraEnabled
        public Decimal groupOrder {get; set;}
        @AuraEnabled
        public Id productGroupId {get; set;}
    }
}
