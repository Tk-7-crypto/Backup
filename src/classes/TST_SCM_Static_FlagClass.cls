@isTest
private class TST_SCM_Static_FlagClass {
    @isTest
    private static void testSCM_Static_FlagClassShouldSetStaticFlag(){
        System.assertEquals(true,SCM_Static_FlagClass.AllowTriggerTOsetDefaultName, 'AllowTriggerTOsetDefaultName is false');
        System.assertEquals(true,SCM_Static_FlagClass.AllowTriggerToExecute, 'AllowTriggerToExecute is false');
        System.assertEquals(false,SCM_Static_FlagClass.AllowTriggerOnAGLIToExecute, 'AllowTriggerOnAGLIToExecute is true');
        System.assertEquals(true,SCM_Static_FlagClass.toAllowAGLICyclicTriggerWithOLI, 
            'toAllowAGLICyclicTriggerWithOLI is false');
    }
}