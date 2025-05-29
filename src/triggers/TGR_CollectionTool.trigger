trigger TGR_CollectionTool on CollectionTool__c (before insert, before update, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_CollectionTool.class);
}