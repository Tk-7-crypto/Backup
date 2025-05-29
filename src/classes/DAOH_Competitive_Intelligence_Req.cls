/**
 * This is Competitive Intelligence Request trigger handler class.
 * version : 1.0
 */
public class DAOH_Competitive_Intelligence_Req {
   
    /**
     * Method to set the Competiiton Date when status is completed.
     * @params newCompetitiveRequest
     * @params oldMap
     * @return  none
     */
    public static void  updatedFieldValue(List<Competitive_Intelligence_Request__c> newCompetitiveRequest, Map<Id, Competitive_Intelligence_Request__c> oldMap){
        for(Competitive_Intelligence_Request__c com_req : newCompetitiveRequest){
            if(oldMap.get(com_req.Id).Competition_Date__c == Null && com_req.Status__c == 'Completed' && com_req.Status__c != oldMap.get(com_req.Id).Status__c ){
                com_req.Competition_Date__c = System.today();
            }
        }
    }
}