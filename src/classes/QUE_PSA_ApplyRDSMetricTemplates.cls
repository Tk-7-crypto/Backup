/**
 * @Author  : CLD Partners
 * @Purpose : Apply tasks from project task templates for RDS Projects
 */
public class QUE_PSA_ApplyRDSMetricTemplates implements Queueable {
	private List<pse__MIlestone__c> milestoneList = new List<pse__MIlestone__c>();
    private Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();
    private List<Project_Metric__c> insertMetricList = new List<Project_Metric__c>();
    private Map<Id, pse__Proj__c> projectIdMap = new Map<Id, pse__Proj__c>();

	public QUE_PSA_ApplyRDSMetricTemplates(List<pse__MIlestone__c> services) {
		this.milestoneList = services;
	}

    public void execute(QueueableContext context) {

        Set<Id> projectIdSet = new Set<Id>();
        Set<String> milestoneKeySet = new Set<String>();
        Set<String> existingMetricsKeySet = new Set<String>();
        Set<Id> parentProjectIdSet = new Set<Id>();
        Set<Id> serviceLineIdSet = new Set<Id>();
        List<pse__MIlestone__c> inScopeMilestoneList = new List<pse__MIlestone__c>();

        for(pse__Milestone__c mstone : milestoneList) {

            string serviceLine = string.isblank(string.valueOf(mstone.Service_Line__c)) ? '*' : string.valueOf(mstone.Service_Line__c);
            string service = string.isblank(string.valueOf(mstone.Service__c)) ? '*' : string.valueOf(mstone.Service__c);
            milestoneKeySet.add(serviceLine + '-' + service);
            milestoneKeySet.add(serviceLine + '-' + '*');

            inScopeMilestoneList.add(mstone);
            projectIdSet.add(mstone.pse__Project__c);
            serviceLineIdSet.add(mstone.Service_Line__c);
        }
        
        if (inScopeMilestoneList.size() > 0 ) {
            projectIdMap = new SLT_Project().getProjectById(projectIdSet, new Set<String>{'Id', 'pse__Parent_Project__c'});
            
            for (pse__Proj__c proj : projectIdMap.values()) {
                parentProjectIdSet.add(proj.pse__Parent_Project__c);
            }

            Map<Id, pse__Proj__c> rdsProjectMap = new SLT_Project().getProjectById(parentProjectIdSet, new Set<String>{'Id', 'CurrencyIsoCode'});

            //get exiting keys
            for (Project_Metric__c pmetric : [SELECT Id, PSA_Metric__r.External_ID__c FROM Project_Metric__c WHERE Project__c in :parentProjectIdSet]) {
                existingMetricsKeySet.add(pmetric.PSA_Metric__r.External_ID__c);
            }

            // if metric has key and not existing, then clone and add to insert list
            for (PSA_Metric__c metric : [SELECT Active__c, Amber_Threshold__c, Automated__c, Category__c, Client_Facing__c, Description__c, 
                                                Effective_Date__c, External_ID__c, Frequency__c, Green_Threshold__c, Group__c, Location__c, Non_Standard__c, Order__c, 
                                                Output_Data_Type__c, Name, Red_Threshold__c, Retired_Date__c, Service__c, Service_Line__c, Type__c, Source_System__c,GRA_Requirements__c
                                            FROM PSA_Metric__c 
                                            WHERE Active__c = true and Non_Standard__c = false and Service_Line__c in: serviceLineIdSet]) 
            {
                string serviceLine = string.isblank(string.valueOf(metric.Service_Line__c)) ? '*' : string.valueOf(metric.Service_Line__c);
                string service = string.isblank(string.valueOf(metric.Service__c)) ? '*' : string.valueOf(metric.Service__c);
                string key = serviceLine + '-' + service;
                string existingKey = metric.External_ID__c;
                
                for (pse__Proj__c proj : rdsProjectMap.values()) {
                    for (pse__Milestone__c mstone : inScopeMilestoneList) {
                        if ( milestoneKeySet.contains(key) && !existingMetricsKeySet.contains(existingKey)) {
                            Project_Metric__c tempMetric = cloneMetric(metric, proj);
                            insertMetricList.add(tempMetric);
                            
                            if (existingKey != null && existingKey != '') {
                                existingMetricsKeySet.add(existingKey);
                            }
                            break;
                        }
                    }
                }
            }

            if (insertMetricList.size() > 0 ) {
                insert insertMetricList;
            }
        }
    }

    Project_Metric__c cloneMetric(PSA_Metric__c origMetric, pse__Proj__c origProj) {
        Project_Metric__c newMetric = new Project_Metric__c();

        newMetric.Amber_Threshold__c = origMetric.Amber_Threshold__c;
        newMetric.CurrencyIsoCode = origProj.CurrencyIsoCode;
        newMetric.Green_Threshold__c = origMetric.Green_Threshold__c;
        newMetric.Location__c = origMetric.Location__c;
        newMetric.Project__c = origProj.id;
        newMetric.Metric_Name__c = origMetric.Name;
        newMetric.PSA_Metric__c = origMetric.id;
        newMetric.Red_Threshold__c = origMetric.Red_Threshold__c;
        newMetric.Automated__c = origMetric.Automated__c;
        newMetric.Source_System__c = origMetric.Source_System__c;
        newMetric.Order__c = origMetric.Order__c;
        newMetric.Effective_Date__c = origMetric.Effective_Date__c;
        newMetric.GRA_Requirements__c = origMetric.GRA_Requirements__c;

        return newMetric;
    }
}
