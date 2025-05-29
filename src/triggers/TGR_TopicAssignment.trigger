trigger TGR_TopicAssignment on TopicAssignment (before insert, before update, before delete, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_TopicAssignment.class);
}