/*
 * Version       : 1.0
 * Description   : Apex Controller for PortalTopic component.
 */
public with sharing class CNT_CSM_PortalTopic {
    
    /*
     * Return List of Topic for current user
     */
    @AuraEnabled
    public static List<Topic> getTopicsByName(List<String> topicsList){
        Set<String> topicsName = new Set<String>();
        for (Integer i=0; i<topicsList.size();i++){
            topicsName.add(topicsList[i]);
        }
        return new SLT_Topic().selectByName(topicsName);
    }
    
    /*
     * Return List of Topic for current user
     */
    @AuraEnabled
    public static List<Topic> getTopics(){
        List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        Set<String> fieldSet = new Set<String>();
        fieldSet.add('Name');
        fieldSet.add('Id');
        String filterCondition ='';
        filterCondition = 'Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true)';
        List<Product2> products =  new SLT_Product2().getProductWithFilter(fieldSet,filterCondition);
      //  List<Product2> products = new SLT_Product2().selectByAccountId(new Set<Id> {users[0].AccountId});
        Set<String> productsName = new Set<String>();
        for (Integer i=0; i<products.size();i++){
            if (products[i].Community_Topics__c != null){
                productsName.add(products[i].Community_Topics__c);
            }
        }
        return new SLT_Topic().selectByName(productsName);
    }

    /*
     * Return List of Topic for current user by product Community doc category
     */
    @AuraEnabled
    public static List<Topic> getTopicsByDocCategory(String category){
        List<User> users = new List<User>();
        //List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id> {userInfo.getUserId()},new Set<String>{'Id','AccountId','ContactId'});
        if(userMap != null && !userMap.isEmpty()){
            users = userMap.values();
        }
        Set<String> fieldSet = new Set<String>{'Id','Name','Community_Topics__c'};
            if(users != null && !users.isEmpty()){
                String filterCondition ='';
                String prodIds = '';
                List<Id> removeProd = new List<Id>();
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()){
                    for (Integer i=0; i<dataList.size(); i++) {
                        if(dataList[i].ProductId__c != null ){
                            prodIds += '\''+ dataList[i].ProductId__c+'\'';
                            if(i < dataList.size()-1){
                                prodIds += ',';
                            }
                        }
                    }
                    filterCondition = 'Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id in ('+ prodIds +'))';
                    
                }else{
                    filterCondition = 'Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\')';
                    List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                    for(CSM_QI_Case_Categorization__c p : prodDataList){
                        removeProd.add(p.Product__c);
                    }
                }
                filterCondition += ' AND Community_Doc_Category__c INCLUDES (\''+category +'\') ';
                List<Product2> products =  new SLT_Product2().getProductWithFilter(fieldSet,filterCondition);
                Set<String> productsName = new Set<String>();
                
                for (Integer i=0; i<products.size();i++){
                    if (removeProd.isEmpty() &&  products[i].Community_Topics__c != null){
                        productsName.add(products[i].Community_Topics__c);
                    }else if(!removeProd.isEmpty() && !removeProd.contains(products[i].id) && products[i].Community_Topics__c != null){
                        productsName.add(products[i].Community_Topics__c);
                    }
                }
                return new SLT_Topic().selectByName(productsName);    
            }else{
                return null;
            }
    }
}