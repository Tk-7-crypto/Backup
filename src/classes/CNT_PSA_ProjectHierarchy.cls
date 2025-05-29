/*
 * @author Shilpa Gattewar <sgattewar@cldpartners.com>
 * Apex support methods for Project Hierarchy Lightning Web Component
 */
public with sharing class CNT_PSA_ProjectHierarchy {
    public CNT_PSA_ProjectHierarchy() {
    }

    @AuraEnabled(cacheable=true)
    public static List<ProgramWrapper> getProgramTree(String recordId, String objectApiName ){
        Id programId;
        if(objectApiName == 'Program__c') {
            programId = recordId;

        } else if(objectApiName == 'pse__Proj__c') {
            pse__Proj__c currentprogram = new SLT_Project().selectByProjectId(new Set<ID> {recordId},new Set<String> {'pse__Parent_Project__r.Program__c','Program__c'});
            if (currentprogram.Program__c != null){
                    programId = currentprogram.Program__c;
            } else  {
                programId = currentprogram.pse__Parent_Project__r.Program__c;
            }

        } else if(objectApiName =='pse__Milestone__c') {
             pse__Milestone__c currentmilestone = new SLT_Milestone().selectByMilestoneId(new Set<ID> {recordId},new Set<String> {'pse__Project__r.pse__Parent_Project__r.Program__c'});
            if (currentmilestone.pse__Project__r.pse__Parent_Project__r.Program__c != null){
                programId = currentmilestone.pse__Project__r.pse__Parent_Project__r.Program__c;
            } else  {
                programId = '';
            }
        }

        List<ProgramWrapper>  programwrapperlist = new List<ProgramWrapper>();
        if (String.isNotEmpty(programId)) {
            try {
                Program__c  program = new SLT_Program().selectByProgramId(new Set<ID> {programId},new Set<String> {'Id','Name'});

                List<ProjectWrapper> projectWrapperList = new List<ProjectWrapper>();
                Set<String> projFields = new Set<String> {'Id','Name','pse__Billings__c', 'pse__Bookings__c'};
                List<pse__Proj__c> projectList = new SLT_Project().selectByProgramId(new Set<ID> {programId}, projFields);

                // grab ids to load serviceaccs
                Map<Id, pse__Proj__c[]> serviceaccsMap = new Map<Id, pse__Proj__c[]>();
                for(pse__Proj__c a : projectList) {
                    serviceaccsMap.put(a.Id, new pse__Proj__c[]{});
                }
                // now grab servicessaccs mapped by project ids (collect for grabbing milestones)
                Map<Id, pse__Milestone__c[]> svcidToMilestones = new Map<Id, pse__Milestone__c[]>();
                Set<String> svcFields = new Set<String> {'Id','Name', 'pse__Parent_Project__c'};
                List<pse__Proj__c> serviceaccsSLT = new SLT_Project().selectByParentProjectId(serviceaccsMap.keySet(),svcFields);
                for (pse__Proj__c serviceaccsProj : serviceaccsSLT) {
                    pse__Proj__c[] projs = serviceaccsMap.get(serviceaccsProj.pse__Parent_Project__c);
                    projs = projs != null ? projs : new pse__Proj__c[]{};
                    projs.add(serviceaccsProj);
                    serviceaccsMap.put(serviceaccsProj.pse__Parent_Project__c, projs);
                    svcidToMilestones.put(serviceaccsProj.id, new pse__Milestone__c[]{});
                }
                // now map milestones to the svc id
                Set<String> mstoneFields = new Set<String> {'Id','Name', 'pse__Project__c', 'Actual_Quantity__c', 'Budget_Quantity__c', 'Actual_Amount__c', 'Budget_Amount__c', 'Closed_for_Unit_Entry__c'};
                List<pse__Milestone__c> milestoneserviceSLT = new SLT_Milestone().selectMilestoneByRDSServiceProjectId(svcidToMilestones.keySet(),mstoneFields);
                for (pse__Milestone__c milestone : milestoneserviceSLT) {
                    pse__Milestone__c[] mstones = svcidToMilestones.get(milestone.pse__Project__c);
                    mstones = mstones != null ? mstones : new pse__Milestone__c[]{};
                    mstones.add(milestone);
                    svcidToMilestones.put(milestone.pse__Project__c, mstones);
                }

                // build items
                ProgramWrapper p = new ProgramWrapper();
                p.name = 'Program: '+ program.Name;
                p.label = program.Name;
                p.recordId = program.Id;
                p.href= '/lightning/r/'+ program.Id +'/view';
                p.expanded =true;
                p.currentState = 'current';

                for(pse__Proj__c a : projectList) {
                    ProjectWrapper prWrapper = new ProjectWrapper() ;
                    prWrapper.name ='Project:'+ a.Name ;
                    // prWrapper.label ='Project: '+a.Name ;
                    prWrapper.label = a.Name;
                    prWrapper.recordId =a.Id ;
                    prWrapper.href= '/lightning/r/'+ a.Id +'/view';
                    prWrapper.expanded =false ;
                    if(prWrapper.recordId == recordId){
                        prWrapper.expanded =true ;
                        prWrapper.currentState = 'current';
                    }
                    // %Complete on project?
                    // Build percent complete for projects to render
                    Integer projPercentComplete = 0;
                    Decimal projBillings =  a.pse__Billings__c;
                    Decimal projBookings =  a.pse__Bookings__c;
                    if (projBillings != null && projBookings != null && projBookings > 0) {
                        // Subtract Amount Completed From Total Amount
                        Decimal remaining = projBookings - projBillings;
                        // divide by total
                        Decimal totalDivided = remaining / projBookings;
                        // multiple by 100 to get remaining amount, subtract from 100 to get complete
                        projPercentComplete = 100 - Integer.valueOf(totalDivided * 100);
                    }
                    prWrapper.percentComplete = projPercentComplete;



                    List<ServiceLineWrapper> serviceWrapperList = new List<ServiceLineWrapper>();
                    //List<pse__Proj__c> serviceaccs = new SLT_Project().selectByParentProjectId(new Set<ID> {a.Id},new Set<String> {'Id','Name'});
                    pse__Proj__c[] serviceaccs = serviceaccsMap.get(a.Id);
                    for(pse__Proj__c  c : serviceaccs) {
                        ServiceLineWrapper serviceWrapper = new ServiceLineWrapper();
                        serviceWrapper.name =c.Name ;
                        // serviceWrapper.label ='Project Service Line: '+c.Name ;
                        serviceWrapper.label =c.Name ;
                        serviceWrapper.href= '/lightning/r/'+ c.Id +'/view';
                        serviceWrapper.recordId = c.Id;
                        serviceWrapper.expanded =false ;
                        if(serviceWrapper.recordId == recordId){
                            serviceWrapper.expanded = true;
                            prWrapper.expanded = true ;
                            serviceWrapper.currentState='current';
                        }

                        List<MilestonesWrapper> milestonesWrapper = new List<MilestonesWrapper>();
                        // List<pse__Milestone__c> milestoneservice = new SLT_Milestone().selectMilestoneByRDSServiceProjectId(new Set<ID> {c.Id},new Set<String> {'Id','Name'});
                        pse__Milestone__c[] milestoneservice = svcidToMilestones.get(c.Id);

                        for(pse__Milestone__c m : milestoneservice) {
                            // Build percent complete for milestones to render
                            Integer percentComplete = 0;
                            Decimal budgetedQty =  m.Budget_Quantity__c;
                            Decimal actualQty =  m.Actual_Quantity__c;
                            if (budgetedQty != null && actualQty != null && budgetedQty != 0) {
                                // Subtract Amount Completed From Total Amount
                                Decimal remaining = budgetedQty - actualQty;
                                // divide by total
                                Decimal totalDivided = remaining / budgetedQty;
                                // multiple by 100 to get remaining amount, subtract from 100 to get complete percent
                                percentComplete = 100 - Integer.valueOf(totalDivided * 100);
                            }

                            MilestonesWrapper milestoneWrapp = new MilestonesWrapper();
                            milestoneWrapp.name =m.Name ;
                            milestoneWrapp.label = m.Name ;
                            // milestoneWrapp.metatext = percentComplete + '% Complete' ;

                            milestoneWrapp.percentComplete = percentComplete;
                            milestoneWrapp.href= '/lightning/r/'+ m.Id +'/view';
                            milestoneWrapp.expanded =true;
                            milestoneWrapp.recordId = m.Id;
                            milestoneWrapp.closedForUnitEntry = m.Closed_for_Unit_Entry__c;
                            if(milestoneWrapp.recordId == recordId){
                                milestoneWrapp.expanded = true;
                                serviceWrapper.expanded = true;
                                prWrapper.expanded = true;
                                milestoneWrapp.currentState ='current';
                            }
                            milestonesWrapper.add(milestoneWrapp);

                        } // end milestone svc loop
                        serviceWrapper.items = milestonesWrapper;
                        serviceWrapperList.add(serviceWrapper);
                    } // end svcaccs loop
                    prWrapper.items = serviceWrapperList;
                    projectWrapperList.add(prWrapper);
                } // end for loop!
                p.items= projectWrapperList;
                programwrapperlist.add(p);
            } catch (Exception e) {
                AuraHandledException ae = new AuraHandledException(e.getMessage());
                ae.setMessage(e.getMessage());
                throw ae;
                // throw new AuraHandledException(e.getMessage());
            }
        }
       return programwrapperlist;
    }

    public class ProgramWrapper{
        @AuraEnabled public String                      name{get;set;}
        @AuraEnabled public String                      label{get;set;}
        @AuraEnabled public String                      metatext{get;set;}
        @AuraEnabled public String                      recordId{get;set;}
        @AuraEnabled public Boolean                     expanded{get;set;}
        @AuraEnabled public List<ProjectWrapper>        items{get;set;}
        @AuraEnabled public String                      href{get;set;}
        @AuraEnabled public String                      currentState{get;set;}
        @AuraEnabled public String                      icon{get;set;}
        @AuraEnabled public String                      objectApiName{get;set;}

        public ProgramWrapper () {
            this.icon = 'custom:custom68';
            this.objectApiName = 'Program__c';
        }

    }
    public class ProjectWrapper{
        @AuraEnabled public String                      name{get;set;}
        @AuraEnabled public String                      label{get;set;}
        @AuraEnabled public String                      metatext{get;set;}
        @AuraEnabled public String                      recordId{get;set;}
        @AuraEnabled public Boolean                     expanded{get;set;}
        @AuraEnabled public List<ServiceLineWrapper>    items{get;set;}
        @AuraEnabled public String                      href{get;set;}
        @AuraEnabled public String                      currentState{get;set;}
        @AuraEnabled public String                      icon{get;set;}
        @AuraEnabled public String                      objectApiName{get;set;}
        @AuraEnabled public Integer                     percentComplete{get;set;}

        public ProjectWrapper () {
            this.icon = 'custom:custom44';
            this.objectApiName = 'pse__Proj__c';
        }
    }

    public class ServiceLineWrapper{
        @AuraEnabled public String                      name{get;set;}
        @AuraEnabled public String                      label{get;set;}
        @AuraEnabled public String                      metatext{get;set;}
        @AuraEnabled public String                      recordId{get;set;}
        @AuraEnabled public Boolean                     expanded{get;set;}
        @AuraEnabled public List<MilestonesWrapper>     items{get;set;}
        @AuraEnabled public String                      href{get;set;}
        @AuraEnabled public String                      currentState{get;set;}
        @AuraEnabled public String                      icon{get;set;}
        @AuraEnabled public String                      objectApiName{get;set;}
        @AuraEnabled public Integer                     percentComplete{get;set;}

        public ServiceLineWrapper () {
            this.icon = 'custom:custom44';
            this.objectApiName = 'pse__Proj__c';
        }
    }

    public class MilestonesWrapper{
        @AuraEnabled public String          name{get;set;}
        @AuraEnabled public String          label{get;set;}
        @AuraEnabled public String          metatext{get;set;}
        @AuraEnabled public Integer         percentComplete{get;set;}
        @AuraEnabled public Boolean         expanded{get;set;}
        @AuraEnabled public String          href{get;set;}
        @AuraEnabled public String          recordId{get;set;}
        @AuraEnabled public String          currentState{get;set;}
        @AuraEnabled public String          icon{get;set;}
        @AuraEnabled public String          objectApiName{get;set;}
        @AuraEnabled public Boolean         closedForUnitEntry{get;set;}

        public MilestonesWrapper () {
            this.icon = 'custom:custom79';
            this.objectApiName = 'pse__Milestone__c';
        }

    }

}