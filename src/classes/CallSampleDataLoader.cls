/**
 * This Class is Run when Sandox is refreshed or created. 
 */ 
global class CallSampleDataLoader implements SandboxPostCopy {
	global void runApexClass(SandboxContext context) {
    LoadCRMSampleData.createSampleData(20);
	BCH_Devops_PostSandboxCreation bcn = new BCH_Devops_PostSandboxCreation();
    Database.executeBatch(bcn, 200);
    }
}