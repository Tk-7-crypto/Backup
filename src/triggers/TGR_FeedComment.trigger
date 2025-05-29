trigger TGR_FeedComment on FeedComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_FeedComment.class);
}