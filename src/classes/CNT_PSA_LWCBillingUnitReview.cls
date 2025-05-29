/**
 * @author	: Shilpa Gattewar <sgattewar@cldpartners.com>
 * Service class for Billing Unit Review in PSA
 */

public with sharing class CNT_PSA_LWCBillingUnitReview {
    @AuraEnabled(cacheable=true)
    public static List<ServiceLineWrapper> getServiceLineList(String projectID,String parentProjectID) {
        List<ServiceLineWrapper> serviceLineList = new List<ServiceLineWrapper>();
         List<pse__Proj__c> servicelinequeryresult;
            if (projectID != parentProjectID) {
                  servicelinequeryresult = new SLT_Project().selectServiceLineByProject(new Set<ID> {projectID},new Set<String> {'Id','Name','Service_Line__r.Name'});
            } else {
                 servicelinequeryresult = new SLT_Project().selectServiceLineByParentProject(new Set<ID> {parentProjectID},new Set<String> {'Id','Name','Service_Line__r.Name'});
            }
        for(pse__Proj__c s: servicelinequeryresult){
            ServiceLineWrapper servicewrapper = new ServiceLineWrapper();
            servicewrapper.label = s.Name;
            servicewrapper.value = s.Name;
            servicewrapper.id= s.id;
            servicewrapper.serviceLineName = s.Service_Line__r.Name;
            serviceLineList.add(servicewrapper);
        }
        return serviceLineList;
    }

    @AuraEnabled(cacheable=true)
    public static List<MilestoneWrapper> getAllMilestonesNoFilters(String projectID, String parentProjectID){
        List<MilestoneWrapper> milestoneList = new List<MilestoneWrapper>();
        List<pse__Milestone__c> milestonequeryresult;

        if (projectID != parentProjectID) {
            milestonequeryresult = new SLT_Milestone().selectAllMilestonesByProject(projectID,milestoneFields);

        } else {
            milestonequeryresult = new SLT_Milestone().selectAllMilestonesByParentProject(parentProjectID,milestoneFields);

        }
        Map<Id,MilestoneWrapper> idMilestoneMap = new Map<Id,MilestoneWrapper>();
        for(pse__Milestone__c m : milestonequeryresult){
            MilestoneWrapper milestonewrapper = new MilestoneWrapper(m);
            milestoneList.add(milestonewrapper);
            idMilestoneMap.put(milestonewrapper.id, milestonewrapper);
        }

        List<pse__Project_Task__c> deliverablequeryresult;
        deliverablequeryresult = new SLT_Project_Task().getProjectTasksByMilestone(idMilestoneMap.keySet(), projectTaskDeliverableFields);

        for(pse__Project_Task__c d : deliverablequeryresult){
            DeliverableWrapper deliverablewrapper = new DeliverableWrapper(d);
            MilestoneWrapper mwrapper = idMilestoneMap.get(d.pse__Milestone__c);
            if (d.Billing_Hold__c == true) {
                mwrapper.holdDeliverables.add(deliverablewrapper);
            }
            else if (d.Billing_Hold__c  != true && d.Eligible_for_Billing__c == 'Yes' ) {
                mwrapper.eligibleDeliverables.add(deliverablewrapper);
                mwrapper.eligibleForBilling += d.Quantity__c;
            }
        }
        return milestoneList;
    }

    /*
     * fields to query from milestones
     */
    private static Set<String> milestoneFields = new Set<String> {
        'Id', 'Name', 'Service__c','Service_Line__c','Service_Line__r.Name',
        'Service__r.Name','pse__Project__r.Id',
        'pse__Project__r.pse__Parent_Project__r.Project_Code__c',
        'Rate__c','Budget_Quantity__c','Actual_Quantity__c',
        'Service__r.Service_Code__c','Billed_Quantity__c','pse__Milestone_Amount__c'
    };

    /*
     * fields to query from project task to use when building deliverables
     */
    private static Set<String> projectTaskDeliverableFields = new Set<String> {
        'Id', 'pse__Milestone__c', 'pse__Milestone__r.Name', 'Service__r.Name',
        'pse__Actual_End_Date_Time__c', 'Target__r.Name', 'Drug__r.Name',
        'Billing_Milestone__r.Id', 'Quantity__c',
        'Service__r.Service_Code__c', 'Resource__r.name',
        'Total_Billable_Amount__c', 'Eligible_for_Billing__c',
        'Billing_Hold__c', 'Not_Billed_Reason__c', 'Tracking_Number__c'
    };


    @AuraEnabled(cacheable=false)
    public static List<MilestoneWrapper> getAllMilestones(String projectId,List<String> serviceline, Date startDate , Date endDate) {
        List<MilestoneWrapper> milestoneList = new List<MilestoneWrapper>();
        List<pse__Milestone__c> milestonequeryresult = new SLT_Milestone().selectAllMilestonesByServicelines(projectId,new Set<String> (serviceline),startDate,endDate,milestoneFields);
        Map<Id,MilestoneWrapper> idMilestoneMap = new Map<Id,MilestoneWrapper>();

        for(pse__Milestone__c m : milestonequeryresult){
            MilestoneWrapper milestonewrapper = new MilestoneWrapper(m);
            milestoneList.add(milestonewrapper);
            idMilestoneMap.put(milestonewrapper.id, milestonewrapper);
        }
        List<pse__Project_Task__c> deliverablequeryresult;
        deliverablequeryresult = new SLT_Project_Task().getProjectTasksByMilestone(idMilestoneMap.keySet(), projectTaskDeliverableFields);

        for(pse__Project_Task__c d : deliverablequeryresult){
            DeliverableWrapper deliverablewrapper = new DeliverableWrapper(d);
            MilestoneWrapper mwrapper = idMilestoneMap.get(d.pse__Milestone__c);
            if (d.Billing_Hold__c == true) {
                mwrapper.holdDeliverables.add(deliverablewrapper);
            }
            else if (d.Billing_Hold__c  != true && d.Eligible_for_Billing__c == 'Yes') {
                mwrapper.eligibleDeliverables.add(deliverablewrapper);
                mwrapper.eligibleForBilling += d.Quantity__c;
            }
        }

        return milestoneList;
    }

    @AuraEnabled(cacheable=false)
    public static String makeHold(List<Map<String,String>> updateSelectedRecords, String notBilledReason){
        String result = '';
        try {
            List<pse__Project_Task__c> tasksToUpdate = new List<pse__Project_Task__c>();
            for (Map<String,String> d : updateSelectedRecords) {
                pse__Project_Task__c task = new pse__Project_Task__c();
                task.id = d.get('Id');
                task.Billing_Hold__c = true;
                task.Not_Billed_Reason__c = notBilledReason;

                tasksToUpdate.add(task);
            }
            updateSelected(tasksToUpdate);
            result= 'Success';

        } catch (Exception e) {
            throw  new AuraHandledException(e.getMessage());
        }
        return result;
    }

    /*
     * sets Billing Hold to false for the specific task ids
     */
    @AuraEnabled(cacheable=false)
    public static String removeHold(List<Map<String,String>> updateSelectedRecords) {
        String result = '';
        try {
            List<pse__Project_Task__c> tasksToUpdate = new List<pse__Project_Task__c>();
            for (Map<String,String> d : updateSelectedRecords) {
                pse__Project_Task__c task = new pse__Project_Task__c();
                task.id = d.get('Id');
                task.Billing_Hold__c = false;
                tasksToUpdate.add(task);
            }
            updateSelected(tasksToUpdate);
            result= 'Success';

        } catch (Exception e) {
            throw  new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled(cacheable=false)
    public static String excludeDeliverable(List<Map<String,String>> updateSelectedRecords, String notBilledReason) {
        String result= '';
        try {
            List<pse__Project_Task__c> tasksToUpdate = new List<pse__Project_Task__c>();
            for (Map<String,String> d : updateSelectedRecords) {
                pse__Project_Task__c task = new pse__Project_Task__c();
                task.id = d.get('Id');
                task.Exclude_from_Billing__c = true;
                task.Not_Billed_Reason__c = notBilledReason;

                tasksToUpdate.add(task);
            }
            updateSelected(tasksToUpdate);
            result= 'Success';
        } catch (Exception e) {
            throw  new AuraHandledException(e.getMessage());
        }
        return result;
    }

    // assists with approveForBilling maintains milestone to create to existing deliverable ids to associate
    public class MilestoneDeliverableWrapper {
        pse__Milestone__c milestone {get; set;}
        Set<Id> deliverableIds {get; set;}
        public MilestoneDeliverableWrapper() {
            deliverableIds = new Set<Id>();
        }
    }

    /*
     * Removes a billing milestone
    */
    @AuraEnabled(cacheable=false)
    public static String removeBillingMilestone(String milestoneId){
        try {
            pse__Milestone__c billingMilestone = new pse__Milestone__c(Id=milestoneId);
            delete billingMilestone;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
        return 'Success';
    }

    /*
     * Standalone method to create a Billing Milestone for a Service Milestone
     */
    @AuraEnabled(cacheable=false)
    public static pse__Milestone__c createBillingMilestone (MilestoneWrapper milestoneWrapper) {
        Map<String, Schema.RecordTypeInfo> rectypeInfo = pse__Milestone__c.getSobjectType().getDescribe().getRecordTypeInfosByName();
        Id rdsBillingRecordTypeId = rectypeInfo.get('RDS Billing').recordTypeId;

        Date actualDate = Date.today();
        String milestonNameAppend = '-Billing';
        String mstoneName = milestoneWrapper.projectCode + ' ' + milestoneWrapper.serviceName + ' ' + actualDate;
        mstoneName = mstoneName.left(80 - milestonNameAppend.length()) + milestonNameAppend;

        pse__Milestone__c newRecord = new pse__Milestone__c(
            Name = mstoneName.left(80),
            pse__Project__c = milestoneWrapper.serviceLineProjectId,
            Quantity__c = milestoneWrapper.newUnits,
            Rate__c = milestoneWrapper.totalBillableAmount,
            pse__Milestone_Amount__c = milestoneWrapper.totalBillableAmount,
            pse__Actual_Date__c = actualDate,
            pse__Status__c = 'Approved',
            pse__Approved__c = true,
            pse__Include_In_Financials__c = true,
            pse__Target_Date__c = actualDate,
            RecordTypeId = rdsBillingRecordTypeId,
            Service__c = milestoneWrapper.service,
            Service_Line__c = milestoneWrapper.serviceLine,
            Service_Milestone__c = milestoneWrapper.id
        );
        insert newRecord;
        return newRecord;
    }

    /*
     * Applies billing milestone to deliverables
     */
    @AuraEnabled(cacheable=false)
    public static String applyBillingMilestone (String milestoneId, DeliverableWrapper[] deliverables ) {
        List<Id> deliverableIds = new List<Id>();
        for (DeliverableWrapper delivery : deliverables) {
            deliverableIds.add(delivery.id);
        }
        try {
            pse__Project_Task__c[] tasks = new pse__Project_Task__c[]{};
            if (deliverableIds.size() > 0) {
                for(Id delivId : deliverableIds) {
                    pse__Project_Task__c taskRecord = new pse__Project_Task__c(
                        Id = delivId,
                        Billing_Milestone__c = milestoneId
                    );
                    tasks.add(taskRecord);
                }
            }

            if (tasks.size() > 0) {
                fflib_SObjectUnitOfWork projTaskUow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {pse__Project_Task__c.SObjectType});
                projTaskUow.registerDirty(tasks);
                projTaskUow.commitWork();
            }

            return 'Success';
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /*
    * creates new milestone records and updates the project task deliverables
    * Deprecated - in favor of client-side batchable methods 'createBillingMilestone' and 'applyBillingMilestone'
    */
    @AuraEnabled(cacheable=false)
    public static String approveForBilling (MilestoneWrapper[] milestoneWrappers) {
        Date actualDate = Date.today();

        // grab RDS Billing record type
        Map<String, Schema.RecordTypeInfo> rectypeInfo = pse__Milestone__c.getSobjectType().getDescribe().getRecordTypeInfosByName();
        Id rdsBillingRecordTypeId = rectypeInfo.get('RDS Billing').recordTypeId;

        // collect milestones to create, and deliverables to move
        MilestoneDeliverableWrapper[] mdwrappers = new MilestoneDeliverableWrapper[]{};
        fflib_SObjectUnitOfWork milestoneUow = new fflib_SObjectUnitOfWork(new List<SObjectType> { pse__Milestone__c.SObjectType });
        String milestonNameAppend = '-Billing';
        for (MilestoneWrapper mwrapper : milestoneWrappers) {
            String mstoneName = mwrapper.projectCode + ' ' + mwrapper.serviceName + ' ' + actualDate;
            // append '-Billing' to milestone  name!
            mstoneName = mstoneName.left(80 - milestonNameAppend.length()) + milestonNameAppend;
            pse__Milestone__c newRecord = new pse__Milestone__c(
                Name = mstoneName.left(80),
                pse__Project__c = mwrapper.serviceLineProjectId,
                Quantity__c = mwrapper.newUnits,
                Rate__c = mwrapper.totalBillableAmount,
                pse__Milestone_Amount__c = mwrapper.totalBillableAmount,
                pse__Actual_Date__c = actualDate,
                pse__Status__c = 'Approved',
                pse__Approved__c = true,
                pse__Include_In_Financials__c = true,
                pse__Target_Date__c = actualDate,
                RecordTypeId = rdsBillingRecordTypeId,
                Service__c = mwrapper.service,
                Service_Line__c = mwrapper.serviceLine,
                Service_Milestone__c = mwrapper.id
            );
            // maintain milestone to deliverables, for assigning after milestone is created
            MilestoneDeliverableWrapper mdw = new MilestoneDeliverableWrapper();
            mdw.milestone = newRecord;
            if (mwrapper.deliverables != null && mwrapper.deliverables.size() > 0) {
                for (DeliverableWrapper delivery : mwrapper.deliverables) {
                    mdw.deliverableIds.add(delivery.id);
                }
            }
            mdwrappers.add(mdw);
            milestoneUow.registerNew(mdw.milestone);
        }
        try {
            // Now save new milestones
            if (mdwrappers != null && mdwrappers.size() > 0) {
                milestoneUow.commitWork();
            }
            // And update deliverables
            if (mdwrappers.size() > 0) {
                pse__Project_Task__c[] tasks = new pse__Project_Task__c[]{};
                for (MilestoneDeliverableWrapper mdw : mdwrappers) {
                    Id milestoneId = mdw.milestone.id;
                    if (mdw.deliverableIds != null && mdw.deliverableIds.size() > 0) {
                        for(Id delivId : new List<Id>(mdw.deliverableIds)) {
                            if (delivId != null) {
                                pse__Project_Task__c taskRecord = new pse__Project_Task__c(
                                    Id = delivId,
                                    Billing_Milestone__c = milestoneId
                                );
                                tasks.add(taskRecord);
                            }
                        }
                    }
                }

                if (tasks != null && tasks.size() > 0) {
                    fflib_SObjectUnitOfWork projTaskUow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {pse__Project_Task__c.SObjectType});
                    projTaskUow.registerDirty(tasks);
                    projTaskUow.commitWork();
                }
            }

            return 'Success';
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /*
     * helper to update project tasks
     */
    private static void updateSelected (List<pse__Project_Task__c> tasks) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                pse__Project_Task__c.SObjectType
            }
        );
        uow.registerDirty(tasks);
        uow.commitWork();
    }

    public class ServiceLineWrapper {
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String serviceLineName{get;set;}
        @AuraEnabled public String serviceLineUrl { get { return this.id != null ? '/lightning/r/' + this.id + '/view' : ''; } }
    }

    public class MilestoneWrapper {
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String milestoneUrl { get { return '/lightning/r/' + this.id + '/view'; } }
        @AuraEnabled public String serviceLineName{get;set;}
        @AuraEnabled public Id billingMilestoneId{get;set;}
        @AuraEnabled public Id serviceLineId{get;set;}
        @AuraEnabled public String serviceLineUrl { get { return this.serviceLineId != null ? '/lightning/r/' + this.serviceLineId + '/view' : ''; } }
        @AuraEnabled public String serviceName{get;set;}
        @AuraEnabled public Id serviceId{get;set;}
        @AuraEnabled public String serviceUrl { get { return this.serviceId != null ? '/lightning/r/' + this.serviceId + '/view' : ''; } }
        @AuraEnabled public Decimal budgetQuantity{get;set;}
        @AuraEnabled public Decimal actualQuantity{get;set;}
        @AuraEnabled public Decimal billedQuantity{get { return this.billedQuantity != null ? billedQuantity : 0;} set;}
        @AuraEnabled public Decimal remainingQuantity{get {
            Decimal remaining = (budgetQuantity != null ? budgetQuantity : 0) - (billedQuantity != null ? billedQuantity : 0);
            return remaining != null ? remaining : 0;
        } }
        @AuraEnabled public Decimal eligibleForBilling{get;set;}
        @AuraEnabled public Decimal newUnits{get;set;}
        @AuraEnabled public String newUnitBackground{get;set;}
        @AuraEnabled public String newUnitIconName {get; set;}
        @AuraEnabled public String clearIconClass {get; set;}
        @AuraEnabled public String projectCode{get;set;}
        @AuraEnabled public String serviceLineProjectId{get;set;}
        @AuraEnabled public Decimal rate{get;set;}
        @AuraEnabled public String serviceCode{get;set;}
        @AuraEnabled public Decimal totalBillableAmount{get;set;}
        @AuraEnabled public String service{get;set;}
        @AuraEnabled public String serviceLine{get;set;}
        @AuraEnabled public List<DeliverableWrapper> deliverables {get { if (this.deliverables == null) { this.deliverables = new List<DeliverableWrapper>(); } return this.deliverables;  }set;}
        @AuraEnabled public List<DeliverableWrapper> eligibleDeliverables {get { if (this.eligibleDeliverables == null) { this.eligibleDeliverables = new List<DeliverableWrapper>(); } return this.eligibleDeliverables;  }set;}
        @AuraEnabled public List<DeliverableWrapper> holdDeliverables{get { if (this.holdDeliverables == null) { this.holdDeliverables = new List<DeliverableWrapper>(); } return this.holdDeliverables;  }set;}

        public MilestoneWrapper () {
        }
        public MilestoneWrapper (pse__Milestone__c milestoneSobj) {
            this.id = milestoneSobj.id;
            this.name = milestoneSobj.Name;
            this.serviceLineId = milestoneSobj.Service_Line__c;
            this.serviceLineName = milestoneSobj.Service_Line__r.Name;
            this.serviceId = milestoneSobj.Service__c;
            this.serviceName = milestoneSobj.Service__r.Name;
            this.rate = milestoneSobj.Rate__c;
            this.budgetQuantity=milestoneSobj.Budget_Quantity__c;
            this.actualQuantity=milestoneSobj.Actual_Quantity__c;
            this.serviceCode = milestoneSobj.Service__r.Service_Code__c;
            this.service = milestoneSobj.Service__c;
            this.serviceLine = milestoneSobj.Service_Line__c;
            this.newUnits = 0;
            this.billedQuantity = milestoneSobj.Billed_Quantity__c;
            this.eligibleForBilling = 0;
            this.serviceLineProjectId = milestoneSobj.pse__Project__r.Id;
            this.projectCode = milestoneSobj.pse__Project__r.pse__Parent_Project__r.Project_Code__c;
            this.serviceCode = milestoneSobj.Service__r.Service_Code__c;
            this.totalBillableAmount = 0;
            this.newUnitBackground = '';
            this.newUnitIconName = '';
            this.clearIconClass = '';
        }
    }

    public class DeliverableWrapper {
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String serviceName{get;set;}
        @AuraEnabled public String linkName{get;set;}
        @AuraEnabled public Datetime dateActual{get;set;}
        @AuraEnabled public Decimal quantity{get;set;}
        @AuraEnabled public String targetName{get;set;}
        @AuraEnabled public String drugName{get;set;}
        @AuraEnabled public String billingMilestoneId{get;set;}
        @AuraEnabled public String serviceCode{get;set;}
        @AuraEnabled public String resource{get;set;}
        @AuraEnabled public Decimal totalBillableAmount{get;set;}
        @AuraEnabled public String eligibleForBilling{get;set;}
        @AuraEnabled public Boolean billingHold {get; set;}
        @AuraEnabled public String notBilledReason {get; set;}
        @AuraEnabled public String trackingNumber {get; set;}
        public DeliverableWrapper() {
        }
        public DeliverableWrapper (pse__Project_Task__c projTask) {
            this.id = projTask.Id;
            this.billingHold = projTask.Billing_Hold__c;
            this.notBilledReason = projTask.Not_Billed_Reason__c;
            this.serviceName = projTask.Service__r.Name;
            this.dateActual=projTask.pse__Actual_End_Date_Time__c;
            this.quantity=projTask.Quantity__c;
            this.targetName=projTask.Target__r.Name;
            this.drugName=projTask.Drug__r.Name;
            this.billingMilestoneId = '';
            this.serviceCode = projTask.Service__r.Service_Code__c;
            this.resource = projTask.Resource__r.name;
            this.totalBillableAmount = projTask.Total_Billable_Amount__c;
            this.eligibleForBilling = projTask.Eligible_for_Billing__c;
            this.trackingNumber = projTask.Tracking_Number__c;
            this.linkName = '/'+projTask.Id;
        }
    }
}