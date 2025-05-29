/**
 * @author Vlad Tyazhov
 * Apex test for: DAOH_UserProjectAllocation, DAO_UserProjectAllocationHandler,
 * DAO_CopadoPromotionHandler, DAO_CopadoSprintHandler, DAO_CopadoUserStoryHandler.
 */
@IsTest
private class TST_UserProjectAllocation {
    public static final String EDIT = 'Edit';
    public static final String OWNER = 'All';
    public static final Id ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = :'System Administrator'].Id;

    @TestSetup
    static void setup() {
        // create users
        List<User> users = new List<User>{
                generateUser('admin1'), generateUser('admin2'), generateUser('admin3'), generateUser('admin4')
        };
        insert users;

        // create copado projects
        copadoccmint__Copado_Integration_Setting__c integrationSetting = new copadoccmint__Copado_Integration_Setting__c(
                copadoccmint__External_System__c = 'JIRA',
                copadoccmint__Named_Credential__c = 'test'
        );
        insert integrationSetting;

        copado__Project__c project1 = new copado__Project__c(
                Name = 'project1',
                copadoccmint__Copado_Integration_Setting__c = integrationSetting.Id
        );
        copado__Project__c project2 = new copado__Project__c(
                Name = 'project2',
                copadoccmint__Copado_Integration_Setting__c = integrationSetting.Id
        );
        insert new List<copado__Project__c>{project1, project2};
    }

    @IsTest
    static void testValidateInsert() {
        // given
        copado__Project__c project = getProject('project1');
        User u = getUser('admin1');

        // when - insert first allocation
        insert generateAllocation(project.Id, u.Id);

        // then - record saved successfully
        System.assertEquals(1, [SELECT Id FROM User_Project_Allocation__c].size());

        // when - insert second allocation for the same project and user
        String errMsg;
        try {
            insert generateAllocation(project.Id, u.Id);
        } catch(Exception e) {
            errMsg = e.getMessage();
        }

        // then - validation error
        System.assert(errMsg.contains('This combination of user and project already exists'));
    }


    @IsTest
    static void testValidateUpdate() {
        // given
        copado__Project__c project = getProject('project1');
        copado__Project__c project2 = getProject('project2');
        User u1 = getUser('admin1');
        User u2 = getUser('admin2');

        User_Project_Allocation__c allocation = generateAllocation(project.Id, u1.Id);
        insert allocation;

        // when - update project
        String errMsg = '';
        try {
            allocation.TECH_ProjectID__c = project2.Id;
            update allocation;
        } catch(Exception e) {
            errMsg = e.getMessage();
        }

        // then - validation error
        System.assert(errMsg.contains('Project field is non-editable'));

        // when - update user
        errMsg = '';
        try {
            allocation.TECH_UserID__c = null;           // change user
            allocation.TECH_ProjectID__c = project.Id;  // revert project from previous test
            update allocation;
        } catch(Exception e) {
            errMsg = e.getMessage();
        }

        // then - validation error
        System.assert(errMsg.contains('User field is non-editable'));

        // when - update role
        allocation.TECH_Role__c = 'Release Manager';
        allocation.TECH_UserID__c = u1.Id;  // revert user from previous test
        update allocation;

        // then - record updated successfully
        System.assertEquals('Release Manager', [SELECT TECH_Role__c FROM User_Project_Allocation__c WHERE Id = :allocation.Id].TECH_Role__c);

        // when - try to inactivate the only allocation on the project
        errMsg = '';
        try {
            allocation.TECH_Status__c = 'Inactive';
            update allocation;
        } catch(Exception e) {
            errMsg = e.getMessage();
        }

        // then - validation error
        System.assert(errMsg.contains('Can\'t delete allocation because there are no other allocations for the project'));

        // when - insert 2nd allocation and inactivate 1st
        insert generateAllocation(project.Id, u2.Id);

        allocation.TECH_Status__c = 'Inactive';
        update allocation;

        // then - record updated successfully
        System.assertEquals('Inactive', [SELECT TECH_Status__c FROM User_Project_Allocation__c WHERE Id = :allocation.Id].TECH_Status__c);

        // when - activate 1st allocation again
        allocation.TECH_Status__c = 'Active';
        update allocation;

        // then - record updated successfully
        System.assertEquals('Active', [SELECT TECH_Status__c FROM User_Project_Allocation__c WHERE Id = :allocation.Id].TECH_Status__c);
    }


    @IsTest
    static void testSharingPositive() {
        // given
        copado__Project__c project = getProject('project1');
        User u1 = getUser('admin1');
        User u2 = getUser('admin2');
        User u3 = getUser('admin3');
        User u4 = getUser('admin4');

        System.runAs(u1) {
            copado__User_Story__c userStory = new copado__User_Story__c(copado__Project__c = project.Id, OwnerId = u1.Id);
            insert userStory;

            copado__Sprint__c sprint = new copado__Sprint__c(copado__Project__c = project.Id, OwnerId = u1.Id);
            insert sprint;

//            copado__Promotion__c promotion = new copado__Promotion__c(copado__Project__c = project.Id, OwnerId = u1.Id);
//            insert promotion;  // todo: fix. currently failing because of Copado License error.
        }

        // when - generate allocations for project
        User_Project_Allocation__c allocation1 = generateAllocation(project.Id, u1.Id);
        User_Project_Allocation__c allocation2 = generateAllocation(project.Id, u2.Id);
        User_Project_Allocation__c allocation3 = generateAllocation(project.Id, u3.Id);
        insert new List<User_Project_Allocation__c>{allocation1, allocation2, allocation3};

        // then - access granted for existing Project-related records
        assertSharingForCopadoRecords(project.Id, new Map<Id, String>{
                u1.Id => OWNER,
                u2.Id => EDIT,
                u3.Id => EDIT,
                u4.Id => null
        });

        // when - insert new UserStory
        copado__User_Story__c newUserStory = new copado__User_Story__c(copado__Project__c = project.Id);
        System.runAs(u1) {
            insert newUserStory;
        }

        // then - access granted according to allocations
        Map<Id, String> accessLevelByUserId = getAccessLevelByUserId([
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :newUserStory.Id
        ]);
        //System.assertEquals(OWNER, accessLevelByUserId.get(u1.Id));
        //System.assertEquals(EDIT, accessLevelByUserId.get(u2.Id));
        //System.assertEquals(EDIT, accessLevelByUserId.get(u3.Id));
        //System.assertEquals(null, accessLevelByUserId.get(u4.Id));

        // when
        allocation1.TECH_Status__c = 'Inactive';
        update allocation1;

        delete allocation2;

        User_Project_Allocation__c allocation4 = generateAllocation(project.Id, u4.Id);
        insert allocation4;

        // then
        accessLevelByUserId = getAccessLevelByUserId([  // check for created UserStory
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :newUserStory.Id
        ]);
        System.assertEquals(null, accessLevelByUserId.get(u1.Id));
        System.assertEquals(null, accessLevelByUserId.get(u2.Id));
        //System.assertEquals(OWNER, accessLevelByUserId.get(u3.Id));
        //System.assertEquals(EDIT, accessLevelByUserId.get(u4.Id));

        assertSharingForCopadoRecords(project.Id, new Map<Id, String>{  // check for all user stories, sprints and promotions
                u1.Id => null,
                u2.Id => null,
                u3.Id => OWNER,
                u4.Id => EDIT
        });

        // when
        allocation1.TECH_Status__c = 'Active';
        update allocation1;

        // then
        assertSharingForCopadoRecords(project.Id, new Map<Id, String>{  // check for all user stories, sprints and promotions
                u1.Id => EDIT,
                u2.Id => null,
                u3.Id => OWNER,
                u4.Id => EDIT
        });

        // when
        delete new List<User_Project_Allocation__c>{allocation3, allocation4};

        // then
        assertSharingForCopadoRecords(project.Id, new Map<Id, String>{  // check for all user stories, sprints and promotions
                u1.Id => OWNER,
                u2.Id => null,
                u3.Id => null,
                u4.Id => null
        });
    }


    @IsTest
    static void testChangeProjectForUserStory() {
        // given
        copado__Project__c project1 = getProject('project1');
        copado__Project__c project2 = getProject('project2');
        User u1 = getUser('admin1');
        User u2 = getUser('admin2');
        User u3 = getUser('admin3');

        insert new List<User_Project_Allocation__c>{
                generateAllocation(project1.Id, u1.Id),
                generateAllocation(project2.Id, u2.Id),
                generateAllocation(project1.Id, u3.Id),
                generateAllocation(project2.Id, u3.Id)
        };

        // when
        copado__User_Story__c userStory;
        System.runAs(u3) {
            userStory = new copado__User_Story__c(copado__Project__c = project1.Id);
            insert userStory;
        }

        Map<Id, String> accessLevelByUserId = getAccessLevelByUserId([
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :userStory.Id
        ]);
        //System.assertEquals(EDIT, accessLevelByUserId.get(u1.Id));
        //System.assertEquals(null, accessLevelByUserId.get(u2.Id));
        //System.assertEquals(OWNER, accessLevelByUserId.get(u3.Id));

        // when
        userStory.copado__Project__c = project2.Id;
        update userStory;

        // then
        accessLevelByUserId = getAccessLevelByUserId([
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :userStory.Id
        ]);
        System.assertEquals(null, accessLevelByUserId.get(u1.Id));
        //System.assertEquals(EDIT, accessLevelByUserId.get(u2.Id));
        //System.assertEquals(OWNER, accessLevelByUserId.get(u3.Id));
    }

    @IsTest
    static void testSharingRecalculation() {
        // given
        copado__Project__c project1 = getProject('project1');
        User u1 = getUser('admin1');
        User u2 = getUser('admin2');

        User_Project_Allocation__c allocation1 = generateAllocation(project1.Id, u1.Id);
        User_Project_Allocation__c allocation2 = generateAllocation(project1.Id, u2.Id);
        insert new List<User_Project_Allocation__c>{allocation1, allocation2};

        // when - insert UserStory
        copado__User_Story__c userStory = new copado__User_Story__c(copado__Project__c = project1.Id);
        System.runAs(u1) {
            insert userStory;
        }

        // then - access granted for both users
        Map<Id, String> accessLevelByUserId = getAccessLevelByUserId([
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :userStory.Id
        ]);
        //System.assertEquals(OWNER, accessLevelByUserId.get(u1.Id));
        //System.assertEquals(EDIT, accessLevelByUserId.get(u2.Id));

        // when - delete share for second user
        delete [SELECT Id FROM copado__User_Story__Share WHERE ParentId = :userStory.Id AND UserOrGroupId = :u2.Id];

        // then - access left only for 1st user
        accessLevelByUserId = getAccessLevelByUserId([
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :userStory.Id
        ]);
        //System.assertEquals(OWNER, accessLevelByUserId.get(u1.Id));
        System.assertEquals(null, accessLevelByUserId.get(u2.Id));

        // when - check "recalculate sharing" for 2nd user
        allocation2.TECH_Recalculate_Sharing__c = true;
        update allocation2;

        // then - access restored for 2nd user and "recalculate sharing" unchecked
        accessLevelByUserId = getAccessLevelByUserId([
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :userStory.Id
        ]);
        //System.assertEquals(OWNER, accessLevelByUserId.get(u1.Id));
        //System.assertEquals(EDIT, accessLevelByUserId.get(u2.Id));

        allocation2 = [SELECT Id, TECH_Recalculate_Sharing__c FROM User_Project_Allocation__c WHERE Id = :allocation2.Id];
        System.assertEquals(false, allocation2.TECH_Recalculate_Sharing__c);

        // when - check "recalculate sharing" for 1st user
        allocation1.TECH_Recalculate_Sharing__c = true;
        update allocation1;

        // then - update successful, owner access not modified
        accessLevelByUserId = getAccessLevelByUserId([
                SELECT Id, UserOrGroupId, AccessLevel FROM copado__User_Story__Share WHERE ParentId = :userStory.Id
        ]);
        //System.assertEquals(OWNER, accessLevelByUserId.get(u1.Id));
        //System.assertEquals(EDIT, accessLevelByUserId.get(u2.Id));

        allocation1 = [SELECT Id, TECH_Recalculate_Sharing__c FROM User_Project_Allocation__c WHERE Id = :allocation1.Id];
        //System.assertEquals(false, allocation1.TECH_Recalculate_Sharing__c);
    }

    @IsTest
    static void testPromotionHandler() {
        DAO_TriggerHandler handler = new DAO_CopadoPromotionHandler.SharingHandler();
        copado__Promotion__c p = new copado__Promotion__c();
        handler.afterInsert(new List<copado__Promotion__c>{p});
    }
    
    // HELPERS
    /** Generic helper to transform a List of Shares to a Map of userId and accessLevel
     * @param shareRecords - list of Shares for some record
     * @return - map of userId and AccessLevel for this record
     */
    private static Map<Id, String> getAccessLevelByUserId(List<SObject> shareRecords) {
        Map<Id, String> accessLevelByUserId = new Map<Id, String>();
        for (SObject r : shareRecords) {
            accessLevelByUserId.put((Id) r.get('UserOrGroupId'), (String) r.get('AccessLevel'));
        }
        return accessLevelByUserId;
    }


    /** Helper to generate Allocation record
     * @param projectId - allocated Project
     * @param userId - allocated User
     * @return - UserProjectAllocation record
     */
    private static User_Project_Allocation__c generateAllocation(Id projectId, Id userId) {
        return new User_Project_Allocation__c(
                TECH_UserID__c = userId,
                TECH_ProjectID__c = projectId,
                TECH_Role__c = 'Developer',
                TECH_Status__c = 'Active'
        );
    }

    /** Helper to generate User record (used in testSetup)
     * @param key - unique key of User (used as a part of email) to create
     * @return - User record
     */
    private static User generateUser(String key) {
        return new User(
                ProfileId = ADMIN_PROFILE_ID,
                LastName = key,
                Email = emailPrefix + key + '@iqvia.com',
                Username = emailPrefix + key + '@iqvia.com.' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alia3133',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Q1_Target__c = 1.0,
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description',
                EmployeeNumber = String.valueOf(System.currentTimeMillis())
        );
    }
    private static final String emailPrefix = 'tst_copadouserprojectallocation';


    /** Helper to find user created in TestSetup
     * @param key - unique key of User (used as a part of email) to find
     * @return - User record
     */
    private static User getUser(String key) {
        if (userByEmail == null) {
            userByEmail = new Map<String, User>();
            for (User u : [SELECT Id, Email FROM User WHERE Email LIKE :emailPrefix +'%']) {
                userByEmail.put(u.Email, u);
            }
        }
        String email = emailPrefix + key + '@iqvia.com';
        return userByEmail.get(email);
    }
    private static Map<String, User> userByEmail;


    /** Helper to find Project created in TestSetup
     * @param projectName - name of Project to find
     * @return - Project record
     */
    private static copado__Project__c getProject(String projectName) {
        if (projectByName == null) {
            projectByName = new Map<String, copado__Project__c>();
            for (copado__Project__c p : [SELECT Id, Name FROM copado__Project__c]) {
                projectByName.put(p.Name, p);
            }
        }
        return projectByName.get(projectName);
    }
    private static Map<String, copado__Project__c> projectByName;


    // helper to assert shares for all project-related records (user stories, promotions, sprints)
    private static void assertSharingForCopadoRecords(Id projectId, Map<Id, String> expectedAccessLevelByUserId) {
        compareShares([
                SELECT Id, ParentId, AccessLevel, UserOrGroupId FROM copado__User_Story__Share WHERE Parent.copado__Project__c = :projectId
        ], expectedAccessLevelByUserId);
        compareShares([
                SELECT Id, ParentId, AccessLevel, UserOrGroupId FROM copado__Sprint__Share WHERE Parent.copado__Project__c = :projectId
        ], expectedAccessLevelByUserId);
        compareShares([
                SELECT Id, ParentId, AccessLevel, UserOrGroupId FROM copado__Promotion__Share WHERE Parent.copado__Project__c = :projectId
        ], expectedAccessLevelByUserId);
    }


    // generic helper to assert shares with expected values
    private static void compareShares(List<SObject> actualShares, Map<Id, String> expectedAccessLevelByUserId) {
        Map<String, List<SObject>> sharesByRecordId = DAOH_UserProjectAllocation.groupRecordsByFields(actualShares, 'ParentId');

        for (String recordId : sharesByRecordId.keySet()) {
            List<SObject> shares = sharesByRecordId.get(recordId);
            Map<Id, String> actualAccessLevelByUserId = getAccessLevelByUserId(shares);

            for (Id expectedUserId : expectedAccessLevelByUserId.keySet()) {
                String expectedAccessLevel = expectedAccessLevelByUserId.get(expectedUserId);
                String actualAccessLevel = actualAccessLevelByUserId.get(expectedUserId);
                System.assertEquals(expectedAccessLevel, actualAccessLevel);
            }
        }
    }
}