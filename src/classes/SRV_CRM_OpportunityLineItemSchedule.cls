/*
 * Version       : 1.0
 * Description   : Service Class for OpportunityLineItemSchedule
 */
global class SRV_CRM_OpportunityLineItemSchedule {

    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            OpportunityLineItemSchedule.SObjectType
        }
    );
    
    /**
     * service method to get filter products
     * @params  Set<Id> oliIdSet
     * @params  Set<String> oliFieldSet
     * @params  Set<String> schFieldSet
     * @return  Map<Id, OpportunityLineItem>
     */
    public static Map<Id, OpportunityLineItem> getOpportunityLineItemSchedule(Set<Id> oliIdSet, Set<String> oliFieldSet, Set<String> schFieldSet) {
        List<OpportunityLineItemSchedule> revSchList = new List<OpportunityLineItemSchedule>();
        OpportunityLineItem oli = new OpportunityLineItem();
        Map<Id, OpportunityLineItem> idtoOliMap = new Map<Id, OpportunityLineItem>();
        try {
            idtoOliMap = new SLT_OpportunityLineItems().getOliWithSchedules(oliIdSet, oliFieldSet, schFieldSet);
        } catch(Exception ex) {
            String errMsg = ex.getMessage() + CON_CRM.SINGLE_SPACE + ex.getStackTraceString();
            throw new OpportunityLineItemScheduleServiceException(new List<String>{errMsg});
        }   
        return idtoOliMap;
    }
    
    /**
     * This method used to insert OpportunityLineItemSchedule
     * @params  Id oliId
     * @params  String startDate
     * @params  Decimal revenueAmount
     * @params  String scheduleType
     * @params  String installmentPeriod
     * @params  Integer noOfInstallment
     * @return  Map<Id, OpportunityLineItem>
     */
    public static Map<Id, OpportunityLineItem> insertOLISch(OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper) {
        Map<Id, OpportunityLineItem> idtoOliMap = new Map<Id, OpportunityLineItem>();
        if( validateOLIS(establishWrapper.startDate, establishWrapper.revenue, establishWrapper.scheduleType, establishWrapper.installmentPeriod, establishWrapper.noOfInstallment) ) {
            Set<Id> oliIdSet = new Set<Id>();
            oliIdSet.add(establishWrapper.oliId);
            Set<String> oliFieldSet = new Set<String>{'Id','TotalPrice','Product2.Name','Opportunity.Name'};
            Set<String> schFieldSet = new Set<String>{'Id','OpportunityLineItemId','Type','Revenue','Quantity','Description','ScheduleDate','CurrencyIsoCode'};
            List<OpportunityLineItemSchedule> oliSchList = new List<OpportunityLineItemSchedule> ();
            List<Date> olisDate = setDateOfOLIS(establishWrapper.startDate, establishWrapper.installmentPeriod, establishWrapper.noOfInstallment);
            Double amount;
            Double sumOfAmount;
            if(establishWrapper.scheduleType == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE) {
                amount = Math.floor(establishWrapper.revenue/establishWrapper.noOfInstallment);
            } else if(establishWrapper.scheduleType == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_REPEAT_SCHEDULE) {
                amount = establishWrapper.revenue;
            }
            sumOfAmount = amount * (establishWrapper.noOfInstallment-1);
            for(Integer i = 0; i < establishWrapper.noOfInstallment; i++) {
                OpportunityLineItemSchedule oliSch = new OpportunityLineItemSchedule();
                oliSch.OpportunityLineItemId = establishWrapper.oliId;
                oliSch.Type = establishWrapper.type;
                oliSch.Revenue = amount;
                oliSch.ScheduleDate = olisDate[i];
                oliSchList.add(olisch);
            }
            if(establishWrapper.scheduleType == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE) {
                oliSchList[establishWrapper.noOfInstallment - 1].Revenue = establishWrapper.revenue - sumOfAmount;
            }
            try{
                if(oliSchList.size() > 0) {
                    List<OpportunityLineItemScheduleWrapper> schWrapperList = new List<OpportunityLineItemScheduleWrapper>();
                    for(OpportunityLineItemSchedule olis : oliSchList) {
                            schWrapperList.add(new OpportunityLineItemScheduleWrapper(olis, CON_CRM.CREATE_LABEL));
                    }
                    crudOliSchedule(schWrapperList);
                    idtoOliMap = new SLT_OpportunityLineItems().getOliWithSchedules(oliIdSet, oliFieldSet, schFieldSet);
                } 
            } catch(OpportunityLineItemScheduleServiceException ex) {
                throw new OpportunityLineItemScheduleServiceException(ex.errorList);
            } catch(exception ex) {
                String errMsg = ex.getMessage() + CON_CRM.SINGLE_SPACE + ex.getStackTraceString();
                throw new OpportunityLineItemScheduleServiceException(new List<String>{errMsg});
            }
        }
        
        return idtoOliMap;
    }
    
    /**
     * This method used to create list of schedule dates
     * @params  Date startDate
     * @params  String installmentPeriod
     * @params  Integer noOfInstallment
     * @return  List<Date>
     */
    public Static List<Date> setDateOfOLIS(Date startDate, String installmentPeriod, Integer noOfInstallment) {
        List<Date> olisDate = new List<Date>();
        olisDate.add(startDate);
        Date tempDate = startDate;
        For(Integer i = 1; i < noOfInstallment; i++) {
            if(installmentPeriod == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DAILY) {
                tempDate = tempDate.addDays(1);
            } else if(installmentPeriod == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_WEEKLY) {
                tempDate = tempDate.addDays(7);
            } else if(installmentPeriod == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_MONTHLY) {
                tempDate = tempDate.addMonths(1);
            } else if(installmentPeriod == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_QUARTERLY) {
                tempDate = tempDate.addMonths(3);
            } else if(installmentPeriod == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_YEARLY) {
                tempDate = tempDate.addYears(1);
            } else if(installmentPeriod == CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_SEMESTERLY) {
                tempDate = tempDate.addMonths(6);
            }
            olisDate.add(tempDate);
        }
        return olisDate;
    }
    
    /**
     * This method used to create list of schedule dates
     * @params  Date startDate
     * @params  Decimal revenueAmount
     * @params  String scheduleType
     * @params  String installmentPeriod
     * @params  Integer numberOfInstallment
     * @return  Boolean
     */
    public static Boolean validateOLIS(Date startDate, Decimal revenueAmount, String scheduleType, String installmentPeriod, Integer numberOfInstallment) {
        Boolean isValidated = true;
        List<String> errorsList = new List<String>();
        if(startDate == null) {
            errorsList.add('Please Enter Start Date');
        }
        if(revenueAmount == null /* || revenueAmount <= 0 */) {
            errorsList.add('Please Enter Positive Revenue Amount');
        }
        if(scheduleType == null) {
            errorsList.add('Please Enter Schedule Type');
        }
        if(installmentPeriod == null) {
            errorsList.add('Please Enter Installment Period');
        }
        if(numberOfInstallment == null || numberOfInstallment <= 0 || numberOfInstallment > 156) {
            errorsList.add('Please Enter Number Of Installments Between 0 to 156.');
        }
        if(errorsList.size() > 0) {
            isValidated = false;
            throw new OpportunityLineItemScheduleServiceException(errorsList);
        }
        return isValidated;
    }
    
    /**
     * This method used to update OpportunityLineItemSchedule
     * @params  OpportunityLineItemScheduleWrapper schWrapperList
     */
    public static void crudOliSchedule(List<OpportunityLineItemScheduleWrapper> schWrapperList) {
        Decimal netRevenueAmount = 0;
        if(schWrapperList.size() > 0) {
            try{
                /*uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        OpportunityLineItemSchedule.SObjectType
                    }
                );*/
                List<OpportunityLineItemSchedule> olisInsertList = new List<OpportunityLineItemSchedule>();
                List<OpportunityLineItemSchedule> olisDeleteList = new List<OpportunityLineItemSchedule>();
                Map<Id, OpportunityLineItem> idToOliMap = new Map<Id, OpportunityLineItem>();
                Set<Id> oliIdSet = new Set<Id>();
                // below code only run for single OLI at a time
                Id oliId = schWrapperList[0].schRecord.OpportunityLineItemId;
                oliIdSet.add(oliId);
                Boolean isCommit = false;
                Set<String> oliFieldSet = new Set<String>{'Id','TotalPrice','Product2.Name','Opportunity.Name'};
                Set<String> schFieldSet = new Set<String>{'Id','OpportunityLineItemId','Type','Revenue','Quantity','Description','ScheduleDate','CurrencyIsoCode'};
                idToOliMap = new SLT_OpportunityLineItems().getOliWithSchedules(oliIdSet, oliFieldSet, schFieldSet);
                List<OpportunityLineItemSchedule> oliSchListToDelete = new List<OpportunityLineItemSchedule>();
                if(idToOliMap.containsKey(oliId)) {
                    oliSchListToDelete = idToOliMap.get(oliId).OpportunityLineItemSchedules;  
                }
                if(oliSchListToDelete.size() > 0) {
                    for(OpportunityLineItemSchedule olis : oliSchListToDelete) {
                        netRevenueAmount -= olis.Revenue;
                    }
                    //uow.registerDeleted(oliSchListToDelete);
                    olisDeleteList.addAll(oliSchListToDelete);
                    isCommit = true;
                }
                Map<String, OpportunityLineItemSchedule> oliDateToSchedulteMap = new Map<String, OpportunityLineItemSchedule>();
                for(OpportunityLineItemScheduleWrapper olisWrapper : schWrapperList) {
                    isCommit = true;
                    if(olisWrapper.operationType == CON_CRM.CREATE_LABEL) {
                        String key;
                        if(String.isBlank(olisWrapper.schRecord.Description)){
                            key = olisWrapper.schRecord.ScheduleDate + '';
                        } else{
                            key = olisWrapper.schRecord.ScheduleDate + ':' + olisWrapper.schRecord.Description;
                        }
                         
                        if(oliDateToSchedulteMap.containsKey(key)) {
                            oliDateToSchedulteMap.get(key).Revenue += olisWrapper.schRecord.Revenue;
                        } else {
                            oliDateToSchedulteMap.put(key, olisWrapper.schRecord);
                        }
                        netRevenueAmount += olisWrapper.schRecord.Revenue;
                    } else if(olisWrapper.operationType == CON_CRM.DELETE_LABEL) {
                        //uow.registerDeleted(olisWrapper.schRecord);
                        olisDeleteList.add(olisWrapper.schRecord);
                        netRevenueAmount -= olisWrapper.schRecord.Revenue;
                    }
                }
               
                if(oliDateToSchedulteMap.size() > 0) {
                    isCommit = true;
                    //uow.registerNew(oliDateToSchedulteMap.values());
                    olisinsertList.addAll(oliDateToSchedulteMap.values());
                }
                if(olisInsertList.size() > 0) {
                    if(olisDeleteList.size() > 0) {
                        UTL_ExecutionControl.stopTriggerExecution = true;
                    }
                    //uow.commitWork();
                    insert olisInsertList;
                    if(olisDeleteList.size() > 0) {
                       UTL_ExecutionControl.stopTriggerExecution = false;
                    } 
                }
                if(olisDeleteList.size() > 0) {
                    if(netRevenueAmount == 0) {
                        CON_CRM.IGNORE_PA_VALIDATION = true;
                    }                    
                    CON_CRM.isUpdateFromRevenueSchedule = true;
                    delete olisDeleteList;
                    CON_CRM.isUpdateFromRevenueSchedule = false;
                    if(netRevenueAmount == 0) {
                       CON_CRM.IGNORE_PA_VALIDATION = false; 
                    } 
                }
                
            } catch(Exception ex) {
                Set<String> errorMsgList = new Set<String>();   
                if(ex.getTypeName() == 'System.DmlException') {
                    for(Integer i = 0; i < ex.getNumDml(); i++) {
                       errorMsgList.add(ex.getDmlMessage(i));
                    }
                }
                else {
                    errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
                }
                throw new OpportunityLineItemScheduleServiceException(new List<String>(errorMsgList));
            }
        }
    }
        
    // Exception Class for OpportunityLineItemSchedule Service
    public Class OpportunityLineItemScheduleServiceException extends Exception {
        public List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public OpportunityLineItemScheduleServiceException(List<String> errorList) {
            this.errorList = errorList;
        }
    }
}