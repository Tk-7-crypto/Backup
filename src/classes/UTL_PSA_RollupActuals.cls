global without sharing class UTL_PSA_RollupActuals {

	public static void refreshMilestoneActuals(Set<Id> idSet) {

		Map<Id, pse__Milestone__c> milestoneMap = new SLT_Milestone().getMilestoneById(idSet, new Set<String> {'Id', 'Actual_Quantity__c', 'Actual_Amount__c','Billed_Quantity__c','Billed_Amount__c'});
		Map<Id, pse__Milestone__c> dirtyMilestoneMap = new Map<Id, pse__Milestone__c>();

		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new
																Schema.SObjectType[] {pse__Milestone__c.SObjectType});

		//get recordtype
		Id recordtypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable').getRecordTypeId();
		Set<Id> nonZeroMilestoneIds = new Set<Id>();
		Set<Id> hasProjectTasksMilestoneIds = new Set<Id>();

		for (pse__Milestone__c ms : milestoneMap.values()) {

			//Detect milestones with non-zero actuals -- if it turns out they no longer have deliverables, they'll need to be updated as well
			if (ms.Actual_Quantity__c > 0 || ms.Billed_Quantity__c > 0 || ms.Actual_Amount__c > 0 || ms.Billed_Amount__c > 0) {
				nonZeroMilestoneIds.add(ms.Id);
			}

			ms.Actual_Quantity__c = 0;
			ms.Billed_Quantity__c = 0;
			ms.Actual_Amount__c = 0;
			ms.Billed_Amount__c = 0;
			milestoneMap.put(ms.id, ms);
		}

		for (AggregateResult ar :   [SELECT
									pse__Milestone__c msId,
									sum(Quantity__c) Quantity,
									sum(Total_Billable_Amount_Number__c) Amount
									FROM pse__Project_Task__c
									WHERE pse__Milestone__c in :idSet and recordTypeId = :recordtypeId and Include_in_Financials__c = true
																																	GROUP BY pse__Milestone__c])
		{
			Id milestoneId = (Id)ar.get('msID');
			pse__Milestone__c tempMilestone = milestoneMap.get(milestoneId);
			tempMilestone.Actual_Quantity__c = (Decimal)ar.get('Quantity');
			tempMilestone.Actual_Amount__c = (Decimal)ar.get('Amount');
			milestoneMap.put(tempMilestone.id, tempMilestone);
			hasProjectTasksMilestoneIds.add(milestoneId);
			uow.registerDirty(tempMilestone);
		}

		for (AggregateResult ar :   [SELECT pse__Milestone__c msId, sum(Quantity__c) Quantity, sum(Total_Billable_Amount_Number__c) Amount
									FROM pse__Project_Task__c
									WHERE pse__Milestone__c in :idSet and recordTypeId = :recordtypeId and Billed_f__c = true
																														GROUP BY pse__Milestone__c])
		{
			Id milestoneId = (Id)ar.get('msID');
			pse__Milestone__c tempMilestone = milestoneMap.get(milestoneId);
			tempMilestone.Billed_Quantity__c = (Decimal)ar.get('Quantity');
			tempMilestone.Billed_Amount__c = (Decimal)ar.get('Amount');
			milestoneMap.put(tempMilestone.id, tempMilestone);
			hasProjectTasksMilestoneIds.add(milestoneId);
			uow.registerDirty(tempMilestone);
		}

		//If there were any non-zero milestones that don't have Project Tasks, they need to also get updated with zeroes
		for(Id milestoneId : nonZeroMilestoneIds){
			if( !hasProjectTasksMilestoneIds.contains(milestoneId) ) {
				pse__Milestone__c tempMilestone = milestoneMap.get(milestoneId);
				uow.registerDirty(tempMilestone);
			}
		}

		uow.commitWork();
	}

	public static void refreshSLProjectActuals(Set<Id> idSet) {
        CON_PSA.isSkipValidationFieldValidationsRDS = true;
		Map<Id, pse__Proj__c> projectMap = new SLT_Project().getProjectById(idSet, new Set<String> {'Id', 'Budget_Amount__c', 'Budget_Hours__c'});

		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new
																Schema.SObjectType[] {pse__Proj__c.SObjectType});

		//get recordtype
		Id recordtypeId = Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosByDeveloperName().get('RDS_Service').getRecordTypeId();

		for (pse__Proj__c proj : projectMap.values()) {
			proj.Budget_Hours__c = 0;
			proj.Budget_Amount__c = 0;
			projectMap.put(proj.id, proj);
		}

		for (AggregateResult ar :   [SELECT pse__Project__c projId, sum(Budget_Hours__c) Hours,sum(Budget_Amount_Number__c) Amount
									FROM pse__Milestone__c
									WHERE pse__Project__c in :idSet and recordTypeId = :recordtypeId
																						GROUP BY pse__Project__c])
		{
			Id projectId = (Id)ar.get('projID');
			pse__Proj__c tempProj = projectMap.get(projectId);
			tempProj.Budget_Hours__c = (Decimal)ar.get('Hours');
			tempProj.Budget_Amount__c = (Decimal)ar.get('Amount');
			projectMap.put(tempProj.id, tempProj);
			uow.registerDirty(tempProj);
		}

		uow.commitWork();
	}

	public static void refreshRDSProjectActuals(Set<Id> idSet) {
        CON_PSA.isSkipValidationFieldValidationsRDS = true;
		Map<Id, pse__Proj__c> projectMap = new SLT_Project().getProjectById(idSet, new Set<String> {'Id', 'Budget_Hours__c', 'pse__Total_Assigned_Hours__c'});

		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new
																Schema.SObjectType[] {pse__Proj__c.SObjectType});

		//get recordtype
		Id recordtypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('RDS_Service_Line').getRecordTypeId();

		for (pse__Proj__c proj : projectMap.values()) {
			proj.Budget_Hours__c = 0;
			proj.pse__Total_Assigned_Hours__c = 0;
			projectMap.put(proj.id, proj);
		}

		for (AggregateResult ar :   [SELECT pse__Parent_Project__c projId, sum(Budget_Hours__c) Hours,sum(pse__Total_Assigned_Hours__c) AssignedHours
									FROM pse__Proj__c
									WHERE pse__Parent_Project__c in :idSet and recordTypeId = :recordtypeId
																							GROUP BY pse__Parent_Project__c])
		{
			Id projectId = (Id)ar.get('projID');
			pse__Proj__c tempProj = projectMap.get(projectId);
			tempProj.Budget_Hours__c = (Decimal)ar.get('Hours');
			tempProj.pse__Total_Assigned_Hours__c = (Decimal)ar.get('AssignedHours');
			projectMap.put(tempProj.id, tempProj);
			uow.registerDirty(tempProj);
		}

		uow.commitWork();
	}


	@future
	public static void refreshMilestoneActuals_Future(Set<Id> idSet) {
		refreshMilestoneActuals(idSet);
	}

	@future
	public static void refreshSLProjectActuals_Future(Set<Id> idSet){
		refreshSLProjectActuals(idSet);
	}

	@future
	public static void refreshRDSProjectActuals_Future(Set<Id> idSet){
		refreshRDSProjectActuals(idSet);
	}
}
