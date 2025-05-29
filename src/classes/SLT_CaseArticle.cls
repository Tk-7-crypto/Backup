/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for CaseArticle
 */
public class SLT_CaseArticle extends fflib_SObjectSelector {
	/**
     * This method used to get field list of sobject
     */
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField>{
			CaseArticle.Id,
			CaseArticle.CaseId,
			CaseArticle.KnowledgeArticleId,
			CaseArticle.KnowledgeArticleVersionId,
			CaseArticle.CreatedDate
		};
	}
	
	/**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
	public Schema.SObjectType getSObjectType() {
		return CaseArticle.sObjectType;
	}
	
	/**
     * This method used to get CaseArticle by Id
     * @return  List<CaseArticle>
     */
	public List<CaseArticle> selectById(Set<ID> idSet) {
		return (List<CaseArticle>) selectSObjectsById(idSet);
	}
	
	/**
     * This method used to get CaseArticle by CaseId
     * @return  List<CaseArticle>
     */
	public List<CaseArticle> selectByCaseId(Set<ID> caseIdSet) {
		 return [SELECT Id, CaseId, KnowledgeArticleId,KnowledgeArticleVersionId, CreatedDate FROM CaseArticle WHERE caseId=:caseIdSet order by CreatedDate desc];
	}
	
    
}