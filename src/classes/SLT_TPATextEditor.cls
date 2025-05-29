public with sharing class SLT_TPATextEditor extends fflib_SObjectSelector {
	public Schema.SObjectType getSObjectType() {
		return TPA_Text_Editor__c.sObjectType;
	}

	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			TPA_Text_Editor__c.Content__c,
			TPA_Text_Editor__c.Page_Name__c,
			TPA_Text_Editor__c.Name,
			TPA_Text_Editor__c.Page_Title__c,
			TPA_Text_Editor__c.Is_Active__c,
			TPA_Text_Editor__c.Page_Url__c,
			TPA_Text_Editor__c.Page_Type__c,
			TPA_Text_Editor__c.English_Translation__c,
			TPA_Text_Editor__c.Japanese_Translation__c,
			TPA_Text_Editor__c.Id
		};
	}

	public List<TPA_Text_Editor__c> getTPATextEditorData(Set<String> fieldSet){
		return (List<TPA_Text_Editor__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
	}

	public List<TPA_Text_Editor__c> getTPATextEditorDataById(Id id, Set<String> fieldSet){
		return (List<TPA_Text_Editor__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id = :id AND Is_Active__c = true').toSOQL());
	}

	public List<TPA_Text_Editor__c> getTPATextEditorDataByCondition(String condition, Set<String> fieldSet){
		return (List<TPA_Text_Editor__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
	}

	public List<TPA_Text_Editor__c> getTPATextEditorDataByListOfId(Set<String> fieldSet, List<String> recordIds){
		return (List<TPA_Text_Editor__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :recordIds').toSOQL());
  }


	public static SLT_TPATextEditor instance {
			get {
					if(instance == null) {
							instance = new SLT_TPATextEditor();
					}
					return instance;
			}
			set;
	}

	public List<TPA_Text_Editor__c> getTPATextEditorDataById(Id id){
		return (List<TPA_Text_Editor__c>)Database.query(newQueryFactory(true).setCondition('Id = :id').toSOQL());
	}
}