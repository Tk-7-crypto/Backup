trigger TGR_Topic on Topic (before insert, before update, before delete, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_Topic.class);
}