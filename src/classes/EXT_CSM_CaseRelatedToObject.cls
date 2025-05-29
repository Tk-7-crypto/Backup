public class EXT_CSM_CaseRelatedToObject {
    public EXT_CSM_CaseRelatedToObject(String action,String objRelName,String objName,String fieldName,Id oldId,Id newId,Id objectId){
        
        if(objRelName != null && (objName.equals(CON_CSM.S_CASE) || objName.equals(CON_CSM.S_ACTIVITYC) ) && (objRelName.equals(CON_CSM.S_PARENT) || objRelName.equals(CON_CSM.S_CASER) ) ){
            objRelName = CON_CSM.S_CASE;            
        }else if(objRelName != null && objName.equals(CON_CSM.S_ACCOUNT) && objRelName.equals(CON_CSM.S_PARENT)){
            objRelName = CON_CSM.S_ACCOUNT;            
        }else if(objRelName != null && ( (objName.equals(CON_CSM.S_CASE) && objRelName.equals(CON_CSM.S_ONBEHALFOFR)) || (objName.equals(CON_CSM.S_CONTACT) && objRelName.equals(CON_CSM.S_REPORTSTO)) ) ){
            objRelName=CON_CSM.S_CONTACT;
        }else if(objRelName != null && (objName.equals(CON_CSM.S_CASE) || objName.equals(CON_CSM.S_ACTIVITYC) || objName.equals(CON_CSM.S_STUDYC) || objName.equals(CON_CSM.S_STUDY_SITE_RELATIONSHIP) || objName.equals(CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP)) && ( objRelName.equals(CON_CSM.S_SPONSORR) || objRelName.equals(CON_CSM.S_SITE_NAMER) || objRelName.equals(CON_CSM.S_SUPPLIERNAMER)  || objRelName.equals(CON_CSM.S_SITER) )){
            objRelName = CON_CSM.S_ACCOUNT;
        }else if(objRelName != null && (objName.equals(CON_CSM.S_CASE) || objName.equals(CON_CSM.S_ACCOUNT) || objName.equals(CON_CSM.S_CONTACT) || objName.equals(CON_CSM.S_STUDYC) || objName.equals(CON_CSM.S_ACTIVITYC)) && (objRelName.equals(CON_CSM.S_PROJECTCOORDINATORR) || objRelName.equals(CON_CSM.S_ACTIVITYOWNERR) || objRelName.equals(CON_CSM.S_CLOSEDBYR) || objRelName.equals(CON_CSM.S_OWNER) || objRelName.equals(CON_CSM.S_RESOLVEDBYR))){
            objRelName = CON_CSM.S_USER;
        }else if(objRelName != null && (objName.equals(CON_CSM.S_ACTIVITYC) || objName.equals(CON_CSM.S_STUDY_CONTACT_RELATIONSHIP) || objName.equals(CON_CSM.S_STUDY_SITE_RELATIONSHIP) || objName.equals(CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP) ) && (objRelName.equals(CON_CSM.S_CONTACT_R) || objRelName.equals(CON_CSM.S_INVESTIGATOR_NAMER) || objRelName.equals(CON_CSM.S_KEYCONTACTSR))){
            objRelName = CON_CSM.S_CONTACT;
        }else if(objRelName != null && (objName.equals(CON_CSM.S_CASE)) && (objRelName.equals(CON_CSM.S_CURRENTQUEUER))){
            objRelName = CON_CSM.S_QUSERRELC;
        }else if(objRelName!=null && (objName.equals(CON_CSM.S_CASE)) && (objRelName.equals(CON_CSM.S_BUSINESSHOURSR))){
            objRelName = CON_CSM.S_BHOUR;
        }else if(objRelName != null && (objName.equals(CON_CSM.S_CASE)) && (objRelName.equals(CON_CSM.S_STUDY_SITE_RELATED_TO_THE_STUDY_R))){
            objRelName = CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP;
        }else if(objRelName != null && objRelName.contains(CON_CSM.S_R)){
            objRelName = objRelName.replace(CON_CSM.S_R, CON_CSM.S_C);            
        }
        
        this.objRelName=objRelName;
        this.objName=objName;
        this.fieldName=fieldName;
        this.oldId=oldId;
        this.newId=newId;
        this.objectId=objectId;
        this.action=action;
    }
    
    public String objRelName {set;get;}
    public String fieldName {set;get;}
    public Id oldId {set;get;}
    public Id newId {set;get;}
    public Id objectId {set;get;}
    public String action {set;get;}
    public String objName {set;get;}
}