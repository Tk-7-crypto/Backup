/*
 * Version       : 1.0
 * Description   : Apex Controller for LXC_CSM_WorkNote Lightning component 
 */ 
public class CNT_CSM_WorkNote {
    /**
     * This method used to return List<CaseComment> for parentId
     * @params  String parentId
     * @return  List<CaseComment>
     */
    @AuraEnabled
    public static List<CaseComment> getCaseCommentByParentId(String parentId){
        List<CaseComment> caseComments = new List<CaseComment>();
        caseComments  = new SLT_CaseComment().selectByParentId(new Set<ID> {parentId});
        return CaseComments;
    }
    
    
    /**
     * This method used to insert a CaseComment
     * @params  CaseComment caseComment
     */
    @AuraEnabled
    public static void insertCaseComment(CaseComment caseComment){
        insert caseComment;
    }
    
    /**
     * This method used to update case
     * @params  Case case
     */
    @AuraEnabled
    public static Case updateCase(Case c){
        update c;
        return c;
    }
}