/**
 * This trigger is used for Account object.
 * version : 1.0
 */
trigger TGR_EmailMessage on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(userinfo.getName() != 'tpa Site Guest User') {
        fflib_SObjectDomain.triggerHandler(DAO_EmailMessage.class);
    }
}