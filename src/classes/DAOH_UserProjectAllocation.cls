/**
 * @author Vlad Tyazhov
 * Apex helper for Copado sharing triggers.
 * Methods to perform validation, share Copado Project-related records.
 */
public without sharing class DAOH_UserProjectAllocation {
    private static final Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();

    /**
     * On Allocation insert - validate that there is no other Allocation with this Project-User pair
     * @param  newAllocations List<User_Project_Allocation__c> - trigger.new
     */
    public static void validateInsert(List<User_Project_Allocation__c> newAllocations) {
        Set<Id> userIds = getIdValues(newAllocations, 'TECH_UserID__c');
        Set<Id> projectIds = getIdValues(newAllocations, 'TECH_ProjectID__c');

        // find existing allocations and group by combination of User and Project Id (dash-separated)
        // example: {"0011X00000hn1DdQAI-0011X00000hn1DdQAI" : [...list of allocations for this project and user]}
        Set<String> combinationsToDelete = groupRecordsByFields([
                SELECT Id, Name, TECH_UserID__c, TECH_ProjectID__c
                FROM User_Project_Allocation__c
                WHERE TECH_UserID__c IN :userIds AND TECH_ProjectID__c IN :projectIds
        ], 'TECH_ProjectID__c,TECH_UserID__c').keySet();

        // validate trigger records
        for (User_Project_Allocation__c a : newAllocations) {
            String combination = a.TECH_ProjectID__c + '-' + a.TECH_UserID__c;
            if (combinationsToDelete.contains(combination)) {
                a.addError('This combination of user and project already exists');
            }
        }
    }


    /**
     * On Allocation update - validate that User or Project fields were not changed
     * @param  newAllocations List<User_Project_Allocation__c> - trigger.new
     * @param  oldAllocationsMap Map<Id, User_Project_Allocation__c> - trigger.oldMap
     */
    public static void validateUpdate(
            List<User_Project_Allocation__c> newAllocations,
            Map<Id, User_Project_Allocation__c> oldAllocationsMap
    ) {
        // validate trigger records
        for (User_Project_Allocation__c a : newAllocations) {
            User_Project_Allocation__c oldAllocation = oldAllocationsMap.get(a.Id);

            if (a.TECH_ProjectID__c != oldAllocation.TECH_ProjectID__c) {
                a.addError('Project field is non-editable');
            } else if (a.TECH_UserID__c != oldAllocation.TECH_UserID__c) {
                a.addError('User field is non-editable');
            }
        }
    }


    /**
     * On Allocation insert/update/delete - process sharing for Project-related records.
     * Group records by their Status and pass to different methods to add/remove sharing.
     * @param  allocations List<User_Project_Allocation__c> - trigger.New
     * @param  oldAllocationsMap Map<Id, User_Project_Allocation__c> oldAllocationsMap - trigger.oldMap
     */
    public static void processSharing(
            List<User_Project_Allocation__c> allocations,
            Map<Id, User_Project_Allocation__c> oldAllocationsMap
    ) {
        // group records by status
        List<User_Project_Allocation__c> activeAllocations = new List<User_Project_Allocation__c>();
        List<User_Project_Allocation__c> inactiveAllocations = new List<User_Project_Allocation__c>();

        for (User_Project_Allocation__c a : allocations) {
            User_Project_Allocation__c old = oldAllocationsMap?.get(a.Id);  // old record on update, null on insert
            Boolean isStatusChanged = old != null && old.TECH_Status__c != a.TECH_Status__c;

            if (a.TECH_Status__c == 'Active' && (old == null || isStatusChanged)) {
                activeAllocations.add(a);
            } else if (a.TECH_Status__c != 'Active' && isStatusChanged) {
                inactiveAllocations.add(a);
            }
        }

        // pass filtered records to helper
        if (!activeAllocations.isEmpty()) {
            addSharing(activeAllocations);
        }
        if (!inactiveAllocations.isEmpty()) {
            removeSharing(inactiveAllocations);
        }
    }


    /**
     * On Allocation update - process sharing for Project-related records.
     * If RecalculateSharing field was checked - calculate sharing once again.
     * @param  allocations List<User_Project_Allocation__c> - trigger.New
     * @param  oldAllocationsMap Map<Id, User_Project_Allocation__c> oldAllocationsMap - trigger.oldMap
     */
    public static void processRecalculationField(
            List<User_Project_Allocation__c> allocations,
            Map<Id, User_Project_Allocation__c> oldAllocationsMap
    ) {
        // group records by status
        List<User_Project_Allocation__c> activeAllocations = new List<User_Project_Allocation__c>();
        List<User_Project_Allocation__c> inactiveAllocations = new List<User_Project_Allocation__c>();

        Set<Id> allocationsToRecalculateIds = new Set<Id>();
        for (User_Project_Allocation__c a : allocations) {
            User_Project_Allocation__c old = oldAllocationsMap?.get(a.Id);  // old record on update, null on insert
            Boolean isRecalculate = old != null && a.TECH_Recalculate_Sharing__c && old.TECH_Recalculate_Sharing__c != true;
            if (!isRecalculate) continue;

            if (a.TECH_Status__c == 'Active') {
                activeAllocations.add(a);
            } else {
                inactiveAllocations.add(a);
            }
            allocationsToRecalculateIds.add(a.Id);
        }

        // pass filtered records to helper
        if (!activeAllocations.isEmpty()) {
            addSharing(activeAllocations);
        }
        if (!inactiveAllocations.isEmpty()) {
            removeSharing(inactiveAllocations);
        }

        // uncheck recalculation checkbox
        if (!allocationsToRecalculateIds.isEmpty()) {
            List<User_Project_Allocation__c> allocationsToUpdate = [
                    SELECT Id FROM User_Project_Allocation__c WHERE Id IN :allocationsToRecalculateIds
            ];
            for (User_Project_Allocation__c a : allocationsToUpdate) {
                a.TECH_Recalculate_Sharing__c = false;
            }
            update allocationsToUpdate;
        }
    }


    /**
     * Helper method to insert Project, Sprint, Promotion and UserStory Share records. Used in processSharing.
     * Grant access to User Stories, Promotions and Sprints for allocated users on insert/update.
     * @param  newAllocations - allocations to process (new or changed to Active)
     */
    public static void addSharing(List<User_Project_Allocation__c> newAllocations) {
        Map<Id, copado__Project__c> projectsMap = new Map<Id, copado__Project__c>([
                SELECT Id,
                (SELECT Id, copado__Project__c FROM copado__User_Stories__r),
                (SELECT Id, copado__Project__c FROM copado__Sprints__r),
                (SELECT Id, copado__Project__c FROM copado__Promotions__r)
                FROM copado__Project__c
                WHERE Id IN :getIdValues(newAllocations, 'TECH_ProjectID__c')
        ]);
        Map<Id, Set<Id>> newAllocatedUsersByProjectId = groupAllocatedUsersByProject(newAllocations);

        insertUserStoryShares(projectsMap, newAllocatedUsersByProjectId);
        insertSprintShares(projectsMap, newAllocatedUsersByProjectId);
        insertPromotionShares(projectsMap, newAllocatedUsersByProjectId);
        insertProjectShares(projectsMap, newAllocatedUsersByProjectId);
    }

    /**
     * Helper method to insert UserStory shares. Used in addSharing.
     * @param projectsMap - map of projects to process
     * @param allocatedUsersByProjectId - map of projectIds and allocated user ids to share
     */
    private static void insertUserStoryShares(Map<Id, copado__Project__c> projectsMap, Map<Id, Set<Id>> allocatedUsersByProjectId) {
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__User_Story__Share
                WHERE Parent.copado__Project__c IN :projectsMap.keySet()
        ]);

        List<copado__User_Story__Share> userStorySharesToInsert = new List<copado__User_Story__Share>();
        for (Id projectId : projectsMap.keySet()) {
            for (copado__User_Story__c userStory : projectsMap.get(projectId).copado__User_Stories__r) {
                Set<Id> userIdsToShare = setExclude(
                        allocatedUsersByProjectId.get(projectId),
                        sharedUsersByRecordId.get(userStory.Id)
                );
                userStorySharesToInsert.addAll((List<copado__User_Story__Share>) generateShares(
                        'copado__User_Story__Share', userStory.Id, userIdsToShare
                ));
            }
        }
        insert userStorySharesToInsert;
    }


    /**
     * Helper method to insert Sprint shares. Used in addSharing.
     * @param projectsMap - map of projects to process
     * @param allocatedUsersByProjectId - map of projectIds and allocated user ids to share
     */
    private static void insertSprintShares(Map<Id, copado__Project__c> projectsMap, Map<Id, Set<Id>> allocatedUsersByProjectId) {
        List<copado__Sprint__Share> sprintSharesToInsert = new List<copado__Sprint__Share>();
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__Sprint__Share
                WHERE Parent.copado__Project__c IN :projectsMap.keySet()
        ]);

        for (Id projectId : projectsMap.keySet()) {
            for (copado__Sprint__c sprint : projectsMap.get(projectId).copado__Sprints__r) {
                Set<Id> userIdsToShare = setExclude(
                        allocatedUsersByProjectId.get(projectId),
                        sharedUsersByRecordId.get(sprint.Id)
                );
                sprintSharesToInsert.addAll((List<copado__Sprint__Share>) generateShares(
                        'copado__Sprint__Share', sprint.Id, userIdsToShare)
                );
            }
        }
        insert sprintSharesToInsert;
    }

    /**
     * Helper method to insert Promotion shares. Used in addSharing.
     * @param projectsMap - map of projects to process
     * @param allocatedUsersByProjectId - map of projectIds and allocated user ids to share
     */
    private static void insertPromotionShares(Map<Id, copado__Project__c> projectsMap, Map<Id, Set<Id>> allocatedUsersByProjectId) {
        List<copado__Promotion__Share> promotionSharesToInsert = new List<copado__Promotion__Share>();
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__Promotion__Share
                WHERE Parent.copado__Project__c IN :projectsMap.keySet()
        ]);

        for (Id projectId : projectsMap.keySet()) {
            for (copado__Promotion__c promotion : projectsMap.get(projectId).copado__Promotions__r) {
                Set<Id> userIdsToShare = setExclude(
                        allocatedUsersByProjectId.get(projectId),
                        sharedUsersByRecordId.get(promotion.Id)
                );
                promotionSharesToInsert.addAll((List<copado__Promotion__Share>) generateShares(
                        'copado__Promotion__Share', promotion.Id, userIdsToShare)
                );
            }
        }
        insert promotionSharesToInsert;
    }


    /**
     * Helper method to insert Project shares. Used in addSharing.
     * @param projectsMap - map of projects to process
     * @param allocatedUsersByProjectId - map of projectIds and allocated user ids to share
     */
    private static void insertProjectShares(Map<Id, copado__Project__c> projectsMap, Map<Id, Set<Id>> allocatedUsersByProjectId) {
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__Project__Share
                WHERE ParentId IN :projectsMap.keySet()
        ]);

        List<copado__Project__Share> projectSharesToInsert = new List<copado__Project__Share>();
        for (Id projectId : projectsMap.keySet()) {
            copado__Project__c project = projectsMap.get(projectId);

            Set<Id> userIdsToShare = setExclude(allocatedUsersByProjectId.get(projectId), sharedUsersByRecordId.get(projectId));
            projectSharesToInsert.addAll((List<copado__Project__Share>) generateShares(
                    'copado__Project__Share', project.Id, userIdsToShare
            ));
        }
        insert projectSharesToInsert;

    }

    /**
     * Helper method to delete Project, Sprint, Promotion and UserStory Share records, and change Owners (if needed).
     * Used in processSharing and in DAO_UserProjectAllocationHandler.onAfterDelete.
     * @param  inactiveAllocations - allocations to process (inactive or deleted)
     */
    public static void removeSharing(List<User_Project_Allocation__c> inactiveAllocations) {
        Set<Id> userIds = getIdValues(inactiveAllocations, 'TECH_UserID__c');
        Set<String> combinationsToDelete = groupRecordsByFields(inactiveAllocations, 'TECH_ProjectID__c,TECH_UserID__c').keySet();

        Map<Id, copado__Project__c> projectsMap = new Map<Id, copado__Project__c>([
                SELECT Id,
                (SELECT Id, OwnerId, copado__Project__c FROM copado__User_Stories__r WHERE OwnerId IN :userIds),
                (SELECT Id, OwnerId, copado__Project__c FROM copado__Sprints__r WHERE OwnerId IN :userIds),
                (SELECT Id, OwnerId, copado__Project__c FROM copado__Promotions__r WHERE OwnerId IN :userIds),
                (
                        SELECT Id, TECH_ProjectID__c, TECH_UserID__c
                        FROM User_Project_Allocations__r
                        WHERE TECH_Status__c = 'Active' AND TECH_Role__c IN ('Release Manager', 'Developer')
                        ORDER BY TECH_Role__c DESC, CreatedDate ASC
                )
                FROM copado__Project__c
                WHERE Id IN :getIdValues(inactiveAllocations, 'TECH_ProjectID__c')
        ]);

        Map<Id, Id> newDefaultOwnerByProjectId = new Map<Id, Id>();
        for (User_Project_Allocation__c a : inactiveAllocations) {
            copado__Project__c project = projectsMap.get(a.TECH_ProjectID__c);
            if (project.User_Project_Allocations__r.isEmpty()) {
                a.addError('Can\'t delete allocation because there are no other allocations for the project');
                continue;
            }
            newDefaultOwnerByProjectId.put(project.Id, project.User_Project_Allocations__r[0].TECH_UserID__c);
        }

        changeUserStoryOwners(projectsMap, combinationsToDelete, newDefaultOwnerByProjectId);
        changeSprintOwners(projectsMap, combinationsToDelete, newDefaultOwnerByProjectId);
        changePromotionOwners(projectsMap, combinationsToDelete, newDefaultOwnerByProjectId);

        deleteUserStoryShares(projectsMap, combinationsToDelete);
        deleteSprintShares(projectsMap, combinationsToDelete);
        deletePromotionShares(projectsMap, combinationsToDelete);
        deleteProjectShares(projectsMap, combinationsToDelete);
    }


    /**
     * Helper method to change UserStory owners (to avoid error when deleting owner share)
     * @param projectsMap - map of projects to process
     * @param  combinationsToDelete - list of Project-User pairs (dash-separated) to change owner
     * @param  newOwnerByProjectId - map of project Id and it's default owner user Id
     */
    private static void changeUserStoryOwners(Map<Id, copado__Project__c> projectsMap, Set<String> combinationsToDelete, Map<Id, Id> newOwnerByProjectId) {
        // update user stories for valid projects
        Map<Id, copado__User_Story__c> userStoriesToUpdate = new Map<Id, copado__User_Story__c>();
        for (Id projectId : newOwnerByProjectId.keySet()) {
            copado__Project__c project = projectsMap.get(projectId);

            for (copado__User_Story__c userStory : project.copado__User_Stories__r) {
                if (combinationsToDelete.contains(projectId + '-' + userStory.OwnerId)) {
                    userStory.OwnerId = newOwnerByProjectId.get(projectId);
                    userStoriesToUpdate.put(userStory.Id, userStory);
                }
            }
        }

        // extract all manual shares and insert them again after record update
        // https://help.salesforce.com/s/articleView?id=000328866&type=1
        List<copado__User_Story__Share> sharesToRestore = (List<copado__User_Story__Share>) cloneShares([
                SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                FROM copado__User_Story__Share
                WHERE ParentId IN :userStoriesToUpdate.keySet() AND RowCause = 'Manual'
        ], userStoriesToUpdate);

        // update records
        update userStoriesToUpdate.values();
        insert sharesToRestore;
    }

    /**
     * Helper method to change Sprint owners (to avoid error when deleting owner share)
     * @param projectsMap - map of projects to process
     * @param  combinationsToDelete - list of Project-User pairs (dash-separated) to change owner
     * @param  newOwnerByProjectId - map of project Id and it's default owner user Id
     */
    private static void changeSprintOwners(Map<Id, copado__Project__c> projectsMap, Set<String> combinationsToDelete, Map<Id, Id> newOwnerByProjectId) {
        // update sprints for valid projects
        Map<Id, copado__Sprint__c> sprintsToUpdate = new Map<Id, copado__Sprint__c>();
        for (Id projectId : newOwnerByProjectId.keySet()) {
            copado__Project__c project = projectsMap.get(projectId);
            for (copado__Sprint__c sprint : project.copado__Sprints__r) {
                if (combinationsToDelete.contains(projectId + '-' + sprint.OwnerId)) {
                    sprint.OwnerId = newOwnerByProjectId.get(projectId);
                    sprintsToUpdate.put(sprint.Id, sprint);
                }
            }
        }

        // extract all manual shares and insert them again after record update
        // https://help.salesforce.com/s/articleView?id=000328866&type=1
        List<copado__Sprint__Share> sharesToRestore = (List<copado__Sprint__Share>) cloneShares([
                SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                FROM copado__Sprint__Share
                WHERE ParentId IN :sprintsToUpdate.keySet() AND RowCause = 'Manual'
        ], sprintsToUpdate);

        // update records
        update sprintsToUpdate.values();
        insert sharesToRestore;
    }

    /**
     * Helper method to change Promotion owners (to avoid error when deleting owner share)
     * @param projectsMap - map of projects to process
     * @param  combinationsToDelete - list of Project-User pairs (dash-separated) to change owner
     * @param  newOwnerByProjectId - map of project Id and it's default owner user Id
     */
    private static void changePromotionOwners(Map<Id, copado__Project__c> projectsMap, Set<String> combinationsToDelete, Map<Id, Id> newOwnerByProjectId) {
        // update promotions for valid projects
        Map<Id, copado__Promotion__c> promotionsToUpdate = new Map<Id, copado__Promotion__c>();
        for (Id projectId : newOwnerByProjectId.keySet()) {
            copado__Project__c project = projectsMap.get(projectId);

            for (copado__Promotion__c promotion : project.copado__Promotions__r) {
                if (combinationsToDelete.contains(projectId + '-' + promotion.OwnerId)) {
                    promotion.OwnerId = newOwnerByProjectId.get(projectId);
                    promotionsToUpdate.put(promotion.Id, promotion);
                }
            }
        }

        // extract all manual shares and insert them again after record update
        // https://help.salesforce.com/s/articleView?id=000328866&type=1
        List<copado__Promotion__Share> sharesToRestore = (List<copado__Promotion__Share>) cloneShares([
                SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                FROM copado__Promotion__Share
                WHERE ParentId IN :promotionsToUpdate.keySet() AND RowCause = 'Manual'
        ], promotionsToUpdate);

        // update records
        update promotionsToUpdate.values();
        insert sharesToRestore;
    }


    public static List<SObject> cloneShares(List<SObject> oldShares, Map<Id, SObject> recordsMap) {
        List<SObject> sharesToInsert = (List<SObject>) JSON.deserialize(
                JSON.serialize(oldShares), List<SObject>.class
        );
        for (Integer i = sharesToInsert.size() - 1; i >= 0 ; i--) {  // iterate over manual shares and remove new owner
            SObject share = sharesToInsert[i];
            SObject record =  recordsMap.get((Id) share.get('ParentId'));
            if (share.get('UserOrGroupId') == record.get('OwnerId')) {  // don't share with new owner
                sharesToInsert.remove(i);
            }
            share.put('Id', null);  // reset Id for insert operation
        }
        return sharesToInsert;
    }


    /**
     * Helper method to delete UserStory shares. Used in removeSharing.
     * @param projectsMap - map of projects to process
     * @param  combinationsToDelete - list of Project-User pairs (dash-separated) to delete share
     */
    private static void deleteUserStoryShares(Map<Id, copado__Project__c> projectsMap, Set<String> combinationsToDelete) {
        System.debug('vl: projectsMap: ' + projectsMap);
        System.debug('vl: combinationsToDelete: ' + combinationsToDelete);
        // delete user stories shares
        List<copado__User_Story__Share> userStorySharesToDelete = new List<copado__User_Story__Share>();
        List<copado__User_Story__Share> userStoryShares = [
                SELECT Id, ParentId, UserOrGroupId, Parent.copado__Project__c
                FROM copado__User_Story__Share
                WHERE Parent.copado__Project__c IN :projectsMap.keySet()
                AND UserOrGroupId IN :extractUsersFromCombinations(combinationsToDelete)
                AND RowCause = 'Manual'
        ];
        System.debug('vl: extractUsersFromCombinations(combinationsToDelete): ' + extractUsersFromCombinations(combinationsToDelete));
        for (copado__User_Story__Share share : userStoryShares) {
            if (combinationsToDelete.contains(share.Parent.copado__Project__c + '-' + share.UserOrGroupId)) {
                userStorySharesToDelete.add(share);
            }
        }
        System.debug('vl: userStorySharesToDelete: ' + JSON.serializePretty(userStorySharesToDelete));
        delete userStorySharesToDelete;
    }

    /**
     * Helper method to delete Sprint shares. Used in removeSharing.
     * @param projectsMap - map of projects to process
     * @param  combinationsToDelete - list of Project-User pairs (dash-separated) to delete share
     */
    private static void deleteSprintShares(Map<Id, copado__Project__c> projectsMap, Set<String> combinationsToDelete) {
        // delete sprint shares
        List<copado__Sprint__Share> sprintSharesToDelete = new List<copado__Sprint__Share>();
        List<copado__Sprint__Share> sprintShares = [
                SELECT Id, ParentId, UserOrGroupId, Parent.copado__Project__c
                FROM copado__Sprint__Share
                WHERE Parent.copado__Project__c IN :projectsMap.keySet()
                AND UserOrGroupId IN :extractUsersFromCombinations(combinationsToDelete)
                AND RowCause = 'Manual'
        ];
        for (copado__Sprint__Share share : sprintShares) {
            if (combinationsToDelete.contains(share.Parent.copado__Project__c + '-' + share.UserOrGroupId)) {
                sprintSharesToDelete.add(share);
            }
        }
        delete sprintSharesToDelete;
    }

    /**
     * Helper method to delete Promotion shares. Used in removeSharing.
     * @param projectsMap - map of projects to process
     * @param  combinationsToDelete - list of Project-User pairs (dash-separated) to delete share
     */
    private static void deletePromotionShares(Map<Id, copado__Project__c> projectsMap, Set<String> combinationsToDelete) {
        // delete promotion shares
        List<copado__Promotion__Share> promotionSharesToDelete = new List<copado__Promotion__Share>();
        List<copado__Promotion__Share> promotionShares = [
                SELECT Id, ParentId, UserOrGroupId, Parent.copado__Project__c
                FROM copado__Promotion__Share
                WHERE Parent.copado__Project__c IN :projectsMap.keySet()
                AND UserOrGroupId IN :extractUsersFromCombinations(combinationsToDelete)
                AND RowCause = 'Manual'
        ];
        for (copado__Promotion__Share share : promotionShares) {
            if (combinationsToDelete.contains(share.Parent.copado__Project__c + '-' + share.UserOrGroupId)) {
                promotionSharesToDelete.add(share);
            }
        }
        delete promotionSharesToDelete;
    }

    /**
     * Helper method to delete Project shares. Used in removeSharing.
     * @param projectsMap - map of projects to process
     * @param  combinationsToDelete - list of Project-User pairs (dash-separated) to delete share
     */
    private static void deleteProjectShares(Map<Id, copado__Project__c> projectsMap, Set<String> combinationsToDelete) {
        // prepare promotion shares
        List<copado__Project__Share> projectSharesToDelete = new List<copado__Project__Share>();
        List<copado__Project__Share> projectShares = [
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__Project__Share
                WHERE ParentId IN :projectsMap.keySet()
                AND UserOrGroupId IN :extractUsersFromCombinations(combinationsToDelete)
                AND RowCause = 'Manual'
        ];
        for (copado__Project__Share share : projectShares) {
            if (combinationsToDelete.contains(share.ParentId + '-' + share.UserOrGroupId)) {
                projectSharesToDelete.add(share);
            }
        }
        delete projectSharesToDelete;
    }


    /**
     * On UserStory insert - share with project allocated users
     * @param userStories - trigger.new
     */
    public static void shareToAllocatedUsers(List<copado__User_Story__c> userStories) {
        Set<Id> projectIds = getIdValues(userStories, 'copado__Project__c');
        Set<Id> userStoryIds = getIdValues(userStories, 'Id');

        // find related records
        Map<Id, Set<Id>> allocatedUsersByProjectId = getAllocatedUsersByProjectId(projectIds);
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__User_Story__Share
                WHERE ParentId IN :userStoryIds
        ]);

        // prepare share records
        List<copado__User_Story__Share> sharesToInsert = new List<copado__User_Story__Share>();
        for (copado__User_Story__c userStory : userStories) {
            if (userStory.copado__Project__c == null) continue;
            Set<Id> userIdsToShare = setExclude(
                    allocatedUsersByProjectId.get(userStory.copado__Project__c),
                    sharedUsersByRecordId.get(userStory.Id)
            );
            sharesToInsert.addAll(
                    (List<copado__User_Story__Share>) generateShares('copado__User_Story__Share', userStory.Id, userIdsToShare)
            );
        }

        // perform DML operations
        insert sharesToInsert;
    }


    /**
     * On UserStory update, if Project changed - remove sharing from old project users and create sharing for new.
     * @param userStories - trigger.new
     * @param oldMap - trigger.oldMap
     */
    public static void updateSharingOnProjectChange(List<copado__User_Story__c> userStories, Map<Id, copado__User_Story__c> oldMap) {
        Map<Id, Id> projectToRemoveByUserStoryId = new Map<Id, Id>();
        Map<Id, Id> projectToAddByUserStoryId = new Map<Id, Id>();
        for (copado__User_Story__c userStory : userStories) {
            copado__User_Story__c oldUserStory = oldMap.get(userStory.Id);
            if (userStory.copado__Project__c != oldUserStory.copado__Project__c) {
                if (oldUserStory.copado__Project__c != null) {
                    projectToRemoveByUserStoryId.put(userStory.Id, oldUserStory.copado__Project__c);
                }
                if (userStory.copado__Project__c != null) {
                    projectToAddByUserStoryId.put(userStory.Id, userStory.copado__Project__c);
                }
            }
        }
        if (!projectToRemoveByUserStoryId.isEmpty()) {
            removeUserStorySharesForProject(projectToRemoveByUserStoryId);
        }
        if (!projectToAddByUserStoryId.isEmpty()) {
            addUserStorySharesForProject(projectToAddByUserStoryId);
        }
    }


    /**
     * Helper method to delete UserStory shares. Used in updateSharingOnProjectChange.
     * @param projectByUserStoryId - map of UserStory and Project to delete share
     */
    public static void removeUserStorySharesForProject(Map<Id, Id> projectByUserStoryId) {
        List<copado__User_Story__Share> sharesToDelete = new List<copado__User_Story__Share>();

        Set<Id> userStoryIds = projectByUserStoryId.keySet();
        Set<Id> projectIds = new Set<Id>(projectByUserStoryId.values());  // old project here

        Map<Id, Set<Id>> allocatedUsersByProjectId = getAllocatedUsersByProjectId(projectIds);

        Set<String> combinationsToDelete = new Set<String>();
        for (Id userStoryId : userStoryIds) {
            Id oldProjectId = projectByUserStoryId.get(userStoryId);
            Set<Id> oldAllocatedUsers = allocatedUsersByProjectId.get(oldProjectId);
            for (Id userId : oldAllocatedUsers) {
                combinationsToDelete.add(userStoryId + '-' + userId);
            }
        }

        List<copado__User_Story__Share> userStoryShares = [
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__User_Story__Share
                WHERE ParentId IN :userStoryIds
                AND UserOrGroupId IN :extractUsersFromCombinations(combinationsToDelete)
                AND RowCause = 'Manual'
        ];

        for (copado__User_Story__Share share : userStoryShares) {
            if (combinationsToDelete.contains(share.ParentId + '-' + share.UserOrGroupId)) {
                sharesToDelete.add(share);
            }
        }
        delete sharesToDelete;
    }


    /**
     * Helper method to create UserStory shares. Used in updateSharingOnProjectChange.
     * @param projectByUserStoryId - map of UserStory and Project to create share
     */
    public static void addUserStorySharesForProject(Map<Id, Id> projectByUserStoryId) {
        List<copado__User_Story__Share> sharesToInsert = new List<copado__User_Story__Share>();

        Set<Id> userStoryIds = projectByUserStoryId.keySet();
        Set<Id> projectIds = new Set<Id>(projectByUserStoryId.values());

        Map<Id, Set<Id>> allocatedUsersByProjectId = getAllocatedUsersByProjectId(projectIds);
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__User_Story__Share
                WHERE ParentId IN :userStoryIds
        ]);
        for (Id userStoryId : userStoryIds) {
            Id projectId = projectByUserStoryId.get(userStoryId);
            Set<Id> userIdsToShare = setExclude(
                    allocatedUsersByProjectId.get(projectId),
                    sharedUsersByRecordId.get(userStoryId)
            );
            sharesToInsert.addAll(
                    (List<copado__User_Story__Share>) generateShares('copado__User_Story__Share', userStoryId, userIdsToShare)
            );
        }
        insert sharesToInsert;
    }


    /**
     * On Sprint insert - share with project allocated users
     * @param sprints - trigger.new
     */
    public static void shareToAllocatedUsers(List<copado__Sprint__c> sprints) {
        Set<Id> projectIds = getIdValues(sprints, 'copado__Project__c');
        Set<Id> sprintIds = getIdValues(sprints, 'Id');

        // find related records
        Map<Id, Set<Id>> allocatedUsersByProjectId = getAllocatedUsersByProjectId(projectIds);
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__Sprint__Share
                WHERE ParentId IN :sprintIds
        ]);

        // prepare share records
        List<copado__Sprint__Share> sharesToInsert = new List<copado__Sprint__Share>();
        for (copado__Sprint__c sprint : sprints) {
            if (sprint.copado__Project__c == null) continue;
            Set<Id> userIdsToShare = setExclude(
                    allocatedUsersByProjectId.get(sprint.copado__Project__c),
                    sharedUsersByRecordId.get(sprint.Id)
            );
            sharesToInsert.addAll(
                    (List<copado__Sprint__Share>) generateShares('copado__Sprint__Share', sprint.Id, userIdsToShare)
            );
        }

        // perform DML operations
        insert sharesToInsert;
    }


    /**
     * On Promotion insert - share with project allocated users
     * @param promotions - trigger.new
     */
    public static void shareToAllocatedUsers(List<copado__Promotion__c> promotions) {
        Set<Id> projectIds = getIdValues(promotions, 'copado__Project__c');
        Set<Id> promotionIds = getIdValues(promotions, 'Id');

        // find related records
        Map<Id, Set<Id>> allocatedUsersByProjectId = getAllocatedUsersByProjectId(projectIds);
        Map<Id, Set<Id>> sharedUsersByRecordId = groupSharedUsersByParentId([
                SELECT Id, ParentId, UserOrGroupId
                FROM copado__Promotion__Share
                WHERE ParentId IN :promotionIds
        ]);

        // prepare share records
        List<copado__Promotion__Share> sharesToInsert = new List<copado__Promotion__Share>();
        for (copado__Promotion__c promotion : promotions) {
            if (promotion.copado__Project__c == null) continue;
            Set<Id> userIdsToShare = setExclude(
                    allocatedUsersByProjectId.get(promotion.copado__Project__c),
                    sharedUsersByRecordId.get(promotion.Id)
            );
            sharesToInsert.addAll(
                    (List<copado__Promotion__Share>) generateShares('copado__Promotion__Share', promotion.Id, userIdsToShare)
            );
        }

        // perform DML operations
        insert sharesToInsert;
    }


    // HELPERS
    /**
     * Group shares. Return map of recordId and shared userIds.
     * @param shares - list of shares
     * @return - result map of recordId and shared userIds
     */
    public static Map<Id, Set<Id>> groupSharedUsersByParentId(List<SObject> shares) {
        Map<Id, Set<Id>> sharedUsersByParentId = new Map<Id, Set<Id>>();
        for (SObject share : shares) {
            Id parentId = (Id) share.get('ParentId');
            Id userId = (Id) share.get('UserOrGroupId');
            if (!sharedUsersByParentId.containsKey(parentId)) {
                sharedUsersByParentId.put(parentId, new Set<Id>());
            }
            sharedUsersByParentId.get(parentId).add(userId);
        }
        return sharedUsersByParentId;
    }


    /**
     * Helper method to group allocations. Return map of projectId and allocated userIds.
     * @param allocations - list of allocations
     * @return - result map of projectId and allocated userIds
     */
    public static Map<Id, Set<Id>> groupAllocatedUsersByProject(List<User_Project_Allocation__c> allocations) {
        Map<Id, Set<Id>> allocatedUsersByProject = new Map<Id, Set<Id>>();
        for (User_Project_Allocation__c a : allocations) {
            if (!allocatedUsersByProject.containsKey(a.TECH_ProjectID__c)) {
                allocatedUsersByProject.put(a.TECH_ProjectID__c, new Set<Id>());
            }
            allocatedUsersByProject.get(a.TECH_ProjectID__c).add(a.TECH_UserID__c);
        }
        return allocatedUsersByProject;
    }


    /**
     * Helper method to return set of userIds from list of Project-User combinations.
     * Example: ["a-Id1", "b-Id2"] => ["Id1", "Id2"]
     * @param combinationsToDelete - list of combinations
     * @return - set of userIds
     */
    private static Set<Id> extractUsersFromCombinations(Set<String> combinationsToDelete) {
        Set<Id> userIds = new Set<Id>();
        for (String combination : combinationsToDelete) {
            userIds.add((Id) combination.split('-')[1]);
        }
        return userIds;
    }

    /**
     * Helper method to retrieve projects and allocated users by list of projectIds
     * @param projectIds - list of projectIds
     * @return - result map of projectId and allocated userIds
     */
    static Map<Id, Set<Id>> getAllocatedUsersByProjectId(Set<Id> projectIds) {
        Map<Id, Set<Id>> allocatedUsersByProjectId = new Map<Id, Set<Id>>();
        Map<Id, copado__Project__c> projectsMap = new Map<Id, copado__Project__c>([
                SELECT Id,
                (SELECT Id, TECH_UserID__c, TECH_Role__c FROM User_Project_Allocations__r WHERE TECH_Status__c = 'Active')
                FROM copado__Project__c
                WHERE Id IN :projectIds
        ]);
        for (Id projectId : projectsMap.keySet()) {
            copado__Project__c p = projectsMap.get(projectId);
            allocatedUsersByProjectId.put(p.Id, getIdValues(p.User_Project_Allocations__r, 'TECH_UserID__c'));
        }
        return allocatedUsersByProjectId;
    }


    /**
     * Universal method to generate share record
     * @param shareObjectName - share object name. example: copado__User_Story__Share
     * @param parentId - record to share
     * @param userId - user to share
     * @return - share record
     */
    static SObject generateShare(String shareObjectName, Id parentId, Id userId) {
        Schema.SObjectType shareType = globalDescribeMap.get(shareObjectName);
        SObject share = shareType.newSObject();
        share.put('ParentId', parentId);
        share.put('UserOrGroupId', userId);
        share.put('AccessLevel', 'Edit');
        share.put('RowCause', 'Manual');
        return share;
    }

    /**
     * Universal method to generate share records
     * @param shareObjectName - share object name. example: copado__User_Story__Share
     * @param parentId - record to share
     * @param userIds - list of users to share
     * @return - share record
     */
    static List<SObject> generateShares(String shareObjectName, Id parentId, Set<Id> userIds) {
        List<SObject> shares = new List<SObject>();
        for (Id userId : userIds) {
            shares.add(generateShare(shareObjectName, parentId, userId));
        }
        return shares;
    }


    // UTILS
    /** Helper to extract field values (Id) from list of records
     * @param records - list of SObject records
     * @param fieldName - fields to extract
     *
     * @return set of field values (in Id type)
     */
    public static Set<Id> getIdValues(List<SObject> records, String fieldName) {
        Set<Id> values = new Set<Id>();
        for (Object objectValue : getFieldValues(records, fieldName)) {
            if (objectValue != null) {
                values.add((Id) objectValue);
            }
        }
        return values;
    }

    /** Helper to extract field values (Objects) from list of records
    * @param records - list of SObject records
    * @param fieldName - fields to extract
    *
    * @return set of field values (in Object type)
    */
    private static Set<Object> getFieldValues(List<SObject> records, String fieldName) {
        Set<Object> values = new Set<Object>();
        if (records != null) {
            for (SObject record : records) {
                values.add(record.get(fieldName));
            }
        }
        return values;
    }

    /**
     * @param records - list of SObjects
     * @param keyFields - comma-separated list of fields to group
     *
     * @return - map of keys (either Id or dash-separated list of strings) and related SObjects
     *
     * @examples:
     * input: groupRecordsByField([SELECT OCE__Account__c FROM OCE__Call__c] 'OCE__Account__c,OCE__Territory__c');
     * output: {"0011X00000hn1DdQAI" : [...calls for account]}
     *
     * input: groupRecordsByField(
     *     [SELECT OCE__Account__c, OCE__Territory__c FROM OCE__Call__c], 'OCE__Account__c,OCE__Territory__c'
     * );
     * output: {"0011X00000hn1DdQAI-ES_CM_0002" : [...calls for account and territory]}
     */
    public static Map<String, List<SObject>> groupRecordsByFields(List<SObject> records, String keyFields) {
        Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
        for (SObject r : records) {
            // generate key for record (either one Id or separated)
            List<String> keyParts = new List<String>();
            for (String keyField : keyFields.split(',')) {
                keyParts.add((String) r.get(keyField.trim()));
            }
            String key = String.join(keyParts, '-');

            // group records by key
            if (!resultMap.containsKey(key)) {
                resultMap.put(key, new List<SObject>());
            }
            resultMap.get(key).add(r);
        }
        return resultMap;
    }

    /**
     * Method to perform "s1 minus s2" operation. Take s1 and remove from it all elements that are in s2.
     * @param s1 - source set of ids
     * @param s2 - ids to exclude
     *
     * @return - result set
     */
    public static Set<Id> setExclude(Set<Id> s1, Set<Id> s2) {
        if (s1 != null && s2 != null) {
            Set<Id> result = s1.clone();
            result.removeAll(s2);
            return result;
        } else {
            return new Set<Id>();
        }
    }
}