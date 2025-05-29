/**
 * This trigger is used for Flash_Message object.
 * version : 1.0
 */
trigger Tgr_Flash_Message on Flash_Message__c (after insert,after update) {
	fflib_SObjectDomain.triggerHandler(DAO_Flash_Message.class);
}