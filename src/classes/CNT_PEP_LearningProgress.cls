/*
 * Version       : 1.0
 * Description   : Apex Controller for Learning Progress component
 */
public with sharing class CNT_PEP_LearningProgress {
	@AuraEnabled
	public static List<Learning_Path__c> getLearn(){
	    String uid = UserInfo.getUserId();
	    return [SELECT Id,name,Learning_Path_Label__c,Salesforce_User_ID__c
	            	,LMS_learning_path_URL__c,Progress__c,Product2ID__r.Name 
	            FROM Learning_Path__c 
	            WHERE Salesforce_User_ID__c =: uid];
	}
}