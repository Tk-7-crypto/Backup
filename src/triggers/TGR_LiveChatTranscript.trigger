/**
 * This trigger is used for Account object.
 * version : 1.0
 */
trigger TGR_LiveChatTranscript on LiveChatTranscript (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_LiveChatTranscript.class);
}