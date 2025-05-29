/**
 * Description: Utility class to define lead sharing rule within partner account users.
                'without sharing' keywords is used to allow creating leadshare records as a partner user
 * version : 1.0
 */
public without sharing class UTL_PEP_LeadSharing {
     /**
    * PEP-ACN Lead Sharing logic
    * 
    * @Desc   define visibility and access rights of lead within partner account users 
    * @params List<Lead> newList , Map<Id,Lead> oldMap
    * @return void
    */
     public static void shareLeadWithPartner(List<Lead> newList , Map<Id, Lead> oldMap){
         
        List<Lead> eligibleLeadList = new List<Lead>();
        Set<Id> leadIdSet = new set<Id>();
        List<LeadShare> leadShareList = new List<LeadShare>();
        set<Id> ledShareToDeleteSet = new set<Id>();
        Id prmLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_LED_RECORDTYPE).getRecordTypeId();

        for (Lead leadRec : newList){
            
            // verify lead recordtype and if partner contact is not null
             //Verify if the owner of lead has changed, new owner is a queue and partner account id is not null
             if(leadRec.recordTypeID == prmLeadRecTypeId && 
                leadRec.TECH_Partner_Account__c != null  && 
               (oldMap.size()> 0 
                && (leadRec.OwnerId != oldMap.get(leadRec.Id).OwnerId
                || leadRec.TECH_Partner_Account__c != oldMap.get(leadRec.Id).TECH_Partner_Account__c))){
                    if(leadRec.TECH_Partner_Account__c != oldMap.get(leadRec.Id).TECH_Partner_Account__c){
                        ledShareToDeleteSet.add(leadRec.Id);
                    }
                   
                 leadIdSet.add(leadRec.TECH_Partner_Account__c);
                 eligibleLeadList.add(leadRec);
             }
         }
         
         if (leadIdSet.size() >0 && eligibleLeadList.size() >0){
             if(ledShareToDeleteSet.size() > 0){
                 List<LeadShare> leadShareToDelLst = [SELECT Id, LeadId, RowCause FROM LeadShare WHERE LeadId IN :leadIdSet and RowCause = 'Manual'];
                 if (leadShareToDelLst.size() > 0){
                     database.delete(leadShareToDelLst);
                 }
             }
             
             for(Lead leadRec : eligibleLeadList){
                 //Iterate over userslist and insert a new record in leadshare for each user
                 for(User userRec : new SLT_User().selectUserByAccountId(leadIdSet)){
                     LeadShare leadShareRec = new LeadShare();
                     leadShareRec.LeadId = leadRec.Id;
                     leadShareRec.UserOrGroupId= userRec.Id;
                     //Assign Edit access to lead originator and PIM
                     if (leadRec.createdById == userRec.Id || userRec.userRole.PortalRole == CON_PEP.S_PEP_MANAGER){
                         leadShareRec.LeadAccessLevel = CON_PEP.S_PEP_ACCESS_EDIT;
                     }
                     else{
                         //Assign Read access to other partner users 
                         leadShareRec.LeadAccessLevel = CON_PEP.S_PEP_ACCESS_READ;
                     }
                     leadShareList.add(leadShareRec);
                 }
             }
             List<Database.SaveResult> resultList= Database.insert(leadShareList,false);
             
             for(integer i=0; i<resultList.size();i++){
                 if(!resultList[i].isSuccess()){
                     leadShareList[i].addError(leadShareList[i].Id+'Error in inserting lead share : '
                                                 + resultList[i].getErrors()[0].getMessage());
                 }
             }
         }
     }//end method shareLeadWithPartner 
}