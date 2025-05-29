/*
 * Version       : 1.0
 * Description   : Apex Controller for LXC_PEP_Announcement
 */
public with sharing class CNT_PEP_Announcements {
	@AuraEnabled
  	public static List<Announcement__c> getAnnouncement(){
    	return [SELECT Id,Name,Description__c,Partner_roles__c,Partner_type__c,Product2ID__c
    			,Published_date__c,Status__c,Subject__c 
    			FROM Announcement__c 
    			WHERE (Published_date__c = LAST_N_MONTHS:4 OR Published_date__c = THIS_MONTH)
    				AND Status__c = 'Online'
            ORDER BY Published_date__c DESC];
  	}

  	@AuraEnabled
  	public static List<Announcement__c> getAnnouncementForHome(){
    	return [SELECT Id,Name,Description__c,Partner_roles__c,Partner_type__c,Product2ID__c
    			,Published_date__c,Status__c,Subject__c 
    			FROM Announcement__c 
    			WHERE Expiry_date__c >= TODAY
          AND Status__c = 'Online'
    				ORDER BY Published_date__c DESC
            ];
  	}
}