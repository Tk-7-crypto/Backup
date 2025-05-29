trigger TGR_FeedItem on FeedItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_FeedItem.class);
}