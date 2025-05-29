/**
* This is pse__Skill_Certification_Rating__c trigger handler class.
* version : 1.0
*/
public class DAOH_OWF_SkillCertificationRating {
    
    public static void checkIfRatingAlreadyExists(List<pse__Skill_Certification_Rating__c> newList) {
        //if(!Test.isRunningTest()){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<Id> resourceIdSet = new Set<Id>();
        Set<Id> skillCertificationIdSet = new Set<Id>();
        Map<Id, pse__Skill_Certification_Rating__c> scrIdToSkillCertiRatingMap = new Map<Id, pse__Skill_Certification_Rating__c>();
        for(pse__Skill_Certification_Rating__c scr : newList) {
            if(scr.pse__Resource__c != null) {
                resourceIdSet.add(scr.pse__Resource__c);
            }
            if(scr.pse__Skill_Certification__c != null) {
                skillCertificationIdSet.add(scr.pse__Skill_Certification__c);
            }
        }            
        String skillCertRatingCondition = ' pse__Resource__c IN :sObjectIdSet ';
        Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c','pse__Skill_Certification__r.pse__Type__c'};
            Map<Id, Map<Id, pse__Skill_Certification_Rating__c>> scrIdToSkillCertRatingWithContactMap = new Map<Id, Map<Id, pse__Skill_Certification_Rating__c>>();
            
            String skillCondition = ' id in: idSet';
            Set<String> skillFieldSet = new Set<String>{'Id', 'pse__Type__c'};
            Map<Id,pse__Skill__c> idToSkillMap = new Map<Id,pse__Skill__c>();
        if(skillCertificationIdSet.size() > 0) {
            idToSkillMap = new SLT_Skill(false,false).getSkillsByCondition(skillCertificationIdSet,skillFieldSet,skillCondition);
        }
        
        if(resourceIdSet.size() > 0) {
            scrIdToSkillCertiRatingMap = new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsByContactIds(resourceIdSet, skillCertRatingCondition, skillCertRatingFieldSet);
            if(!scrIdToSkillCertiRatingMap.IsEmpty()) {
                for(pse__Skill_Certification_Rating__c skillCertRating : scrIdToSkillCertiRatingMap.values()) {
                    if(!scrIdToSkillCertRatingWithContactMap.containsKey(skillCertRating.pse__Resource__c)) {
                        scrIdToSkillCertRatingWithContactMap.put(skillCertRating.pse__Resource__c, new Map<Id, pse__Skill_Certification_Rating__c>());
                    }
                    scrIdToSkillCertRatingWithContactMap.get(skillCertRating.pse__Resource__c).put(skillCertRating.pse__Skill_Certification__c, skillCertRating);
                }
            }
            for(pse__Skill_Certification_Rating__c scr : newList) {
                if(mulesoftSetting != null 
                   && mulesoftSetting.Ignore_Validation_Rules__c == FALSE 
                   && scrIdToSkillCertRatingWithContactMap.containsKey(scr.pse__Resource__c)){
                    if(scrIdToSkillCertRatingWithContactMap.get(scr.pse__Resource__c).containsKey(scr.pse__Skill_Certification__c)) {
                        if(idToSkillMap.containsKey(scr.pse__Skill_Certification__c)
                           && idToSkillMap.get(scr.pse__Skill_Certification__c).pse__Type__c != CON_PSA.SKILL_TYPE_LANGUAGE) {
                               scr.addError('Skill Certification Rating for this combination of Skill/Certification and Resource already exists.');   
                           }
                    	}                       
			 //If Skill Rating already exists for Potential Region type, then throw error.
                        if(idToSkillMap.containsKey(scr.pse__Skill_Certification__c)
                            && idToSkillMap.get(scr.pse__Skill_Certification__c).pse__Type__c == CON_OWF.SKILL_TYPE_POTENTIAL_REGION) {
                                for(Id scrId : scrIdToSkillCertRatingWithContactMap.get(scr.pse__Resource__c).keySet()) {
                                    if(scrIdToSkillCertRatingWithContactMap.get(scr.pse__Resource__c).get(scrID).pse__Skill_Certification__r.pse__Type__c
                                        == CON_OWF.SKILL_TYPE_POTENTIAL_REGION) {
                                            scr.addError('Skill Certification Rating of type \''+CON_OWF.SKILL_TYPE_POTENTIAL_REGION+'\' already exists.');
                                        }
                                }                            
                            }
                    }
                    
                }
            }
        //}
    }
    
  public static void setDefaultFields(List<pse__Skill_Certification_Rating__c> newList)
  {
      Date today = System.today();
      for(pse__Skill_Certification_Rating__c currentRecord: newList)
      {
          currentRecord.pse__Evaluation_Date__c = today;
          currentRecord.Active__c = True;
      }
  }
    
    
    
    /*
    public static void setSelfIsDuplicateFlag(List<pse__Skill_Certification_Rating__c> newList) {
        
        if(UTL_OWF.ratingUpdateViaTrigger){
            return;
        }
        
        Set<Id> skillRatingIdUpdateSet = new Set<Id>();
        Set<Id> resourceIdSet = new Set<Id>();
        Set<Id> skillIdSet = new Set<Id>();
        Map<Id, pse__Skill_Certification_Rating__c> scrIdToSkillCertiRatingMap = new Map<Id, pse__Skill_Certification_Rating__c>();
        for(pse__Skill_Certification_Rating__c scr : newList) {
            if(scr.pse__Resource__c != null) {
                resourceIdSet.add(scr.pse__Resource__c);
                skillIdSet.add(scr.pse__Skill_Certification__c);
            }
        }
        String skillCertRatingCondition = ' pse__Resource__c IN :resourceIdSet AND pse__Skill_Certification__c IN : skillIdSet AND pse__Resource__r.pse__Is_Resource__c = True';
        Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Numerical_Rating__c'};
        if(resourceIdSet.size() > 0) {
            scrIdToSkillCertiRatingMap = new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsBySkillsContact(resourceIdSet, skillIdSet, skillCertRatingCondition, skillCertRatingFieldSet);
        }
        for(pse__Skill_Certification_Rating__c updateScr : newList) {
            if(!scrIdToSkillCertiRatingMap.IsEmpty()) {
                for(pse__Skill_Certification_Rating__c scr : scrIdToSkillCertiRatingMap.values()) {
                    if(updateScr.id != scr.id && updateScr.pse__Rating__c <= scr.pse__Rating__c) {
                        updateScr.Is_Duplicate__c = true;
                        break;
                    }
                    else if(updateScr.id != scr.id && updateScr.pse__Rating__c > scr.pse__Rating__c) {
                        updateScr.Is_Duplicate__c = false;
                        break;
                    }

                }
            }
        }
    }
    
    public static void setIsDuplicateFlag(List<pse__Skill_Certification_Rating__c> newList){
        if(UTL_OWF.ratingUpdateViaTrigger){
            return;
        }
        UTL_OWF.ratingUpdateViaTrigger = true;
        Set<Id> resourceIdSet = new Set<Id>();
        Set<Id>  recordIDSet = new Set<Id>();
        Map<Id, pse__Skill_Certification_Rating__c> scrIdToSkillCertiRatingMap = new Map<Id, pse__Skill_Certification_Rating__c>();
        for(pse__Skill_Certification_Rating__c scr : newList) {
            if(scr.pse__Resource__c != null) {
                resourceIdSet.add(scr.pse__Resource__c);
                recordIDSet.add(scr.id);
            }
        }
        
        String skillCertRatingCondition = ' Id NOT IN : ratingIdSet AND pse__Resource__c IN :resourceIdSet AND pse__Resource__r.pse__Is_Resource__c = True';
        Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Numerical_Rating__c'};
        if(resourceIdSet.size() > 0) {
            scrIdToSkillCertiRatingMap = new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsByContactIdsOrdering(resourceIdSet, recordIDSet, skillCertRatingCondition, skillCertRatingFieldSet);
            updateIsDuplicateFlag(scrIdToSkillCertiRatingMap.values());
            //system.assert(false,scrIdToSkillCertiRatingMap);
            System.debug('scrIdToSkillCertiRatingMap.values() ' + scrIdToSkillCertiRatingMap.values());
        }
    }
    
    public static void updateIsDuplicateFlag(List<pse__Skill_Certification_Rating__c> processList){
        System.debug('processList' + processList);
        List<pse__Skill_Certification_Rating__c> toupdateList = new List<pse__Skill_Certification_Rating__c>();
        Set<String> uniqueKey = new Set<String>();
        for(pse__Skill_Certification_Rating__c rating : processList) {
            String uniqueKeyString = String.valueOf(rating.pse__Resource__c) + String.valueOf(rating.pse__Skill_Certification__c);
            if(!uniqueKey.contains(uniqueKeyString)) {
                uniqueKey.add(uniqueKeyString);
                rating.is_Duplicate__c = false;
                toupdateList.add(rating);
            }
            else 
            {
                rating.is_Duplicate__c = true;
                toupdateList.add(rating);
            }
        }
        //system.assert(false,toupdateList);
        if(toupdateList.size() > 0) {
            update toupdateList;
        }

    }
    */
    
    public static void updateDuplicateFlag(List<pse__Skill_Certification_Rating__c> processList){
        if(UTL_OWF.ratingUpdateViaTrigger){
            return;
        }
        UTL_OWF.ratingUpdateViaTrigger = true;
        Set<Id> resourceIdSet = new Set<Id>();
        Map<Id,Id> mapResourceBySkill = new Map<Id,Id>();
        Map<Id, pse__Skill_Certification_Rating__c> scrIdToSkillCertiRatingMap = new Map<Id, pse__Skill_Certification_Rating__c>();
        for(pse__Skill_Certification_Rating__c scr : processList) {
            if(scr.pse__Resource__c != null) {
                resourceIdSet.add(scr.pse__Resource__c);
                mapResourceBySkill.put(scr.pse__Skill_Certification__c,scr.pse__Resource__c);
            }
        }
        String skillCertRatingCondition = ' pse__Resource__c IN : resourceIdSet AND pse__Skill_Certification__c IN : skillIdSet AND Active__c = TRUE';
        Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c','pse__Numerical_Rating__c','pse__Skill_Certification__r.pse__Type__c', 'Active__c'};
        Set<String> uniqueKey = new Set<String>();
        if(resourceIdSet.size() > 0) {
            scrIdToSkillCertiRatingMap = new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsBySkillsContact(resourceIdSet, mapResourceBySkill.keySet(), skillCertRatingCondition, skillCertRatingFieldSet);
            List<pse__Skill_Certification_Rating__c> toupdateList = new List<pse__Skill_Certification_Rating__c>();
            for(pse__Skill_Certification_Rating__c rating : scrIdToSkillCertiRatingMap.values()) {
                String uniqueKeyString = String.valueOf(rating.pse__Resource__c) + String.valueOf(rating.pse__Skill_Certification__c);
                if(rating.pse__Skill_Certification__r.pse__Type__c!= CON_PSA.SKILL_TYPE_LANGUAGE){
                    if(!uniqueKey.contains(uniqueKeyString)) {
                        uniqueKey.add(uniqueKeyString);
                        rating.is_Duplicate__c = false;
                        toupdateList.add(rating);
                    }else {
                        rating.is_Duplicate__c = true;
                        toupdateList.add(rating);
                    }  
                }
            }
            if(toupdateList.size() > 0) {
                update toupdateList;
            }
        }   
    }

    public static void bindRFPRankingWithRating(List<pse__Skill_Certification_Rating__c> newList)
    {
        for(pse__Skill_Certification_Rating__c scr : newList) {
            if(scr.RFP_Ranking__c!=null)
            {
               if(scr.RFP_Ranking__c == 'RFP Ranking 1')
                   scr.pse__Rating__c = '1 - Limited Exposure';
                if(scr.RFP_Ranking__c == 'RFP Ranking 2')
                   scr.pse__Rating__c = '2 - Some Familiarity';
                if(scr.RFP_Ranking__c == 'RFP Ranking 3')
                   scr.pse__Rating__c = '3 - Comfortable';
                if(scr.RFP_Ranking__c == 'RFP Ranking 4')
                   scr.pse__Rating__c = '4 - Strong';
                if(scr.RFP_Ranking__c == 'RFP Ranking 5')
                   scr.pse__Rating__c = '5 - Expert';
            }
        }
        
    }
    /**
    * Story IQVIAPSA-5815
    * @params  List<pse__Skill_Certification_Rating__c> newList
    * @params   Map<Id, pse__Skill_Certification_Rating__c> oldMap
    */
    public static void avoidDuplicateLanguage(List<pse__Skill_Certification_Rating__c> newList, Map<Id, pse__Skill_Certification_Rating__c> oldMap)
    {
        Set<Id> resourceIdSet = new Set<Id>();
        Set<String> langaugeSkillSet = new Set<String>();
        Map<Id, String> resourceIdToResourceNameMap = new Map<Id, String>();
        Map<String, Set<String>> resourceIdToLanguageSetMap = new Map<String, Set<String>>();
        Set<String> skillCertificationRatingFieldsSet = new Set<String>{'Id','pse__Resource__c','pse__Rating__c','pse__Resource__r.Name','Language__c','pse__Skill_Certification__r.pse__Type__c'}; 
        String conditionString = 'pse__Resource__c IN : resourceIdSet AND pse__Skill_Certification__r.pse__Type__c = \'Language\' AND Language__c != null AND pse__Resource__c != null'; 
        
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        for(pse__Skill_Certification_Rating__c scr : newList){
            if(mulesoftSetting != null 
               && mulesoftSetting.Ignore_Validation_Rules__c == FALSE 
               && scr.pse__Resource__c != null 
               && scr.Language__c != null 
               && (Trigger.isInsert 
                   || ( Trigger.isUpdate && scr.Language__c != oldMap.get(scr.Id).Language__c)))
            {
                resourceIdSet.add(scr.pse__Resource__c);
            }
        }
        if(resourceIdSet.size() > 0){
            List<pse__Skill_Certification_Rating__c> getExistingSkillCertificationRatingList = new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsByResourceIds(resourceIdSet,conditionString,skillCertificationRatingFieldsSet, false);
            for(pse__Skill_Certification_Rating__c skillSet : getExistingSkillCertificationRatingList){
                resourceIdToResourceNameMap.put(skillSet.pse__Resource__c, skillSet.pse__Resource__r.Name);
                if(resourceIdToLanguageSetMap.containsKey(skillSet.pse__Resource__c)){
                    resourceIdToLanguageSetMap.get(skillSet.pse__Resource__c).add(skillSet.Language__c);
                }else{
                    resourceIdToLanguageSetMap.put(skillSet.pse__Resource__c, new Set<String>{skillSet.Language__c});
                }
            }
            for(pse__Skill_Certification_Rating__c scr : newList){
                if(scr.pse__Resource__c != null && resourceIdToLanguageSetMap.containsKey(scr.pse__Resource__c)){
                    langaugeSkillSet = resourceIdToLanguageSetMap.get(scr.pse__Resource__c);
                    if(langaugeSkillSet.contains(scr.Language__c) && resourceIdToResourceNameMap.containsKey(scr.pse__Resource__c)){
                        scr.addError('You cannot create duplicate Language skills for '+resourceIdToResourceNameMap.get(scr.pse__Resource__c) +' Resource.');
                    }
                }
            }
        }
    }
    
}
