/**
 * This is (pse__Skill_Certification_Rating__c) trigger handler class.
 * version : 1.0
 */
public class DAO_SkillCertificationRating extends fflib_SObjectDomain {
      
    /**
     * Constructor of this class
     * @params sObjectList List<pse__Proj__c>
     */
    public DAO_SkillCertificationRating(List<pse__Skill_Certification_Rating__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_SkillCertificationRating(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Project (pse__Skill_Certification_Rating__c) trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_OWF_SkillCertificationRating.setDefaultFields((List<pse__Skill_Certification_Rating__c>)records);
        DAOH_OWF_SkillCertificationRating.checkIfRatingAlreadyExists((List<pse__Skill_Certification_Rating__c>)records);
        //DAOH_OWF_SkillCertificationRating.bindRFPRankingWithRating((List<pse__Skill_Certification_Rating__c>)records);
        DAOH_OWF_SkillCertificationRating.avoidDuplicateLanguage((List<pse__Skill_Certification_Rating__c>)records,null);
    }
    
     /**
     * This method is used for before update of the Project (pse__Skill_Certification_Rating__c) trigger.
     * @return void */
     public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //DAOH_OWF_SkillCertificationRating.setSelfIsDuplicateFlag((List<pse__Skill_Certification_Rating__c>)records);
        DAOH_OWF_SkillCertificationRating.bindRFPRankingWithRating((List<pse__Skill_Certification_Rating__c>)records);
        DAOH_OWF_SkillCertificationRating.avoidDuplicateLanguage((List<pse__Skill_Certification_Rating__c>)records,(Map<Id,pse__Skill_Certification_Rating__c>) existingRecords);
    }
     
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        //DAOH_OWF_SkillCertificationRating.setIsDuplicateFlag((List<pse__Skill_Certification_Rating__c>)records);
        DAOH_OWF_SkillCertificationRating.updateDuplicateFlag((List<pse__Skill_Certification_Rating__c>)records);
        
    }
    
    public override void onAfterDelete() {
         //DAOH_OWF_SkillCertificationRating.setIsDuplicateFlag((List<pse__Skill_Certification_Rating__c>)records);
         DAOH_OWF_SkillCertificationRating.updateDuplicateFlag((List<pse__Skill_Certification_Rating__c>)records);
     }
}
