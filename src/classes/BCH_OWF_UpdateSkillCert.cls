/*
 * Version       : 1.0
 * Description   : This Batch Class for updating skill certification
 * */
public class BCH_OWF_UpdateSkillCert  implements Database.Batchable<Sobject>, Database.Stateful {

    Set<String> uniqueKey;
    
    /**
     * Constructor
     */
    public BCH_OWF_UpdateSkillCert() {
      uniqueKey = new Set<String>();
    }
    
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([select pse__Resource__c, pse__Skill_Certification__c, pse__Rating__c from pse__Skill_Certification_Rating__c where pse__Resource__r.pse__Is_Resource__c = true order by pse__Resource__c, pse__Skill_Certification__c, pse__Numerical_Rating__c desc]);
    }
    
    /**
     * execute method 
     * @params  Database.BatchableContext context
     * @params  List<pse__Skill_Certification_Rating__c> records
     * @return  void
     */
    public void execute(Database.BatchableContext context, List<pse__Skill_Certification_Rating__c> records) {
        List<pse__Skill_Certification_Rating__c> toupdateList = new List<pse__Skill_Certification_Rating__c>();
        for(pse__Skill_Certification_Rating__c rating : records) {
            String uniqueKeyString = String.valueOf(rating.pse__Resource__c) + String.valueOf(rating.pse__Skill_Certification__c);
            if(!uniqueKey.contains(uniqueKeyString)) {
                uniqueKey.add(uniqueKeyString);
                rating.is_Duplicate__c = false;
                toupdateList.add(rating);
            }
            else {
                rating.is_Duplicate__c = true;
                toupdateList.add(rating);
            }
        }
        if(toupdateList.size() > 0) {
            update toupdateList;
        }
        
    }
    
    /**
     * finish method 
     * @params  Database.BatchableContext context
     * @return  void
     */
    public void finish(Database.BatchableContext context) {
        System.debug(uniqueKey);
    }
}