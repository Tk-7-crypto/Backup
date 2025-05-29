public without sharing class CPQ_RMUtility {
    public static final Set<String> timelineSet = new Set<String> {CON_CPQ.RECRUITMENT_FPI_TO_LPI, CON_CPQ.RUN_IN_SCREENING_LPI, CON_CPQ.TREATMENT_LPI_LPO, CON_CPQ.IN_TREATMENT_FOLLOWUP_BASED_ON_LPO};
    public static final Set<String> timelineSetAdmin = new Set<String> {CON_CPQ.RECRUITMENT_FPI_TO_LPI, CON_CPQ.RUN_IN_SCREENING_LPI, CON_CPQ.TREATMENT_LPI_LPO, CON_CPQ.PROJECT_START_UP, CON_CPQ.IN_TREATMENT_FOLLOWUP_BASED_ON_LPO};																																								 
    public static final Set<String> remoteUnitCodes = new Set<String> {CON_CPQ.CLIN_A11, CON_CPQ.CLIN_A50, CON_CPQ.CLIN_A51, CON_CPQ.CLIN_A52, CON_CPQ.CLIN_A53};
    public static final Set<String> pharmacyUnitCodes = new Set<String> {CON_CPQ.CLIN_A23,CON_CPQ.CLIN_A24,CON_CPQ.CLIN_A25,CON_CPQ.CLIN_A26};
    public static final Set<String> onsiteUnitCodes = new Set<String> {CON_CPQ.CLIN_A5, CON_CPQ.CLIN_A6, CON_CPQ.CLIN_A7, CON_CPQ.CLIN_A21, CON_CPQ.CLIN_A31, CON_CPQ.CLIN_A32, CON_CPQ.CLIN_A36};
    public static final Set<String> adminTimeEntryUnitCodes = new Set<String> {CON_CPQ.CLIN_A13, CON_CPQ.CLIN_A14, CON_CPQ.CLIN_A18, CON_CPQ.CLIN_A19, CON_CPQ.CLIN_A20, CON_CPQ.CLIN_A44, CON_CPQ.CLIN_A42};
    
    @future	   
    public static void createAdminTimeEntryDataFuture(Set<Id> parentIdsSet) 
    {
        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new SLT_Proposal().selectByProposalIds(parentIdsSet, new Set<String> {CON_CPQ.ID, CON_CPQ.DTE_STUDY});
        createAdminTimeEntryQuoteData(proposalMap);
    }
    
    @future
    public static void createTimelineDataFuture(Set<Id> parentIdsSet) {
        createTimelineAndPhaseQuoteData(parentIdsSet, true, true);
    }
    
    @future
    public static void createClinicalVisitFrequencyDataFuture(Set<Id> parentIdsSet) 
    {
    	createClinicalVisitFrequencyQuoteData(parentIdsSet);
    }
    
    public static void createClinicalVisitFrequencyQuoteData(Set<Id> parentIdsSet) 
    {
        try 	 
        {                          				  
            Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> lineItemMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
            Map<Id, List<Country_Input__c>> countryInputMap = new Map<Id, List<Country_Input__c>>();
            Map<Id, List<Timeline__c>> timelineMap = new Map<Id, List<Timeline__c>>();
            
            Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.UNIT_CODE_WITHOUT_COUNTRY_CODE, CON_CPQ.NUMBER_OF_UNITS, CON_CPQ.QUOTE_LINE_ITEM_DESCRIPTION, CON_CPQ.BIDGRID_COUNTRY, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.ROLE_FIELD};
            Set<String> unitCodes = new Set<String>();
            unitCodes.addAll(onsiteUnitCodes);
            unitCodes.addAll(remoteUnitCodes);
            unitCodes.addAll(pharmacyUnitCodes);
            String condition = ' Unit_Code_Without_Country_Code__c IN : unitCodes AND ( Role__c =  '+ '\'' + CON_CPQ.CRA + '\'' + ' OR Role__c = '+ '\'' + CON_CPQ.IQB_CRA + '\') AND Apttus_Proposal__Proposal__c IN :parentIdsSet ';
            lineItemMap = getMapOfSobjectListWithAgreementId(new SLT_ProposalLineItems().selectByProposalIdsAndUnitCodes(parentIdsSet, fieldSet, unitCodes, condition), CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
            
            condition = ' Proposal__c IN :parentIdsSet ';
            countryInputMap = getMapOfSobjectListWithAgreementId(new SLT_Country_Input().selectByAgreementIds(parentIdsSet, new Set<String> {CON_CPQ.ID, CON_CPQ.NUM_OF_ACTIVE_SITES, CON_CPQ.COUNTRY, CON_CPQ.PROPOSAL}, condition), CON_CPQ.PROPOSAL);
            
            condition = ' Name IN :timelineSet AND Proposal__c IN :parentIdsSet';
            timelineMap = getMapOfSobjectListWithAgreementId(new SLT_Timeline().selectByAgreementIdAndTimelineNames(parentIdsSet, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.WEEKS, CON_CPQ.PROPOSAL}, timelineSet, condition), CON_CPQ.PROPOSAL);
            
            createClinicalVisitFreq(parentIdsSet, lineItemMap, countryInputMap, timelineMap);
        } 
        catch(Exception ex) 
        {
            String errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
																	  
//            CPQ_Utility.createApexErrorLogRecord(parentIdsSet, errorMessage, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
        }
    }
    
    private static void createClinicalVisitFreq(Set<Id> parentIds, Map<Id, List<sObject>> lineItemMap, Map<Id, List<Country_Input__c>> countryInputMap, Map<Id, List<Timeline__c>> timelineMap) {
        
        List<Clinical_Visit_Frequency_Data__c> clinicalVisitFreqList = new List<Clinical_Visit_Frequency_Data__c>();
        
        for (Id recordId : parentIds) {
            if (countryInputMap.containsKey(recordId) && timelineMap.containsKey(recordId) && lineItemMap.containsKey(recordId)) {
                List<sobject> lineItemList = lineItemMap.get(recordId);
                List<Country_Input__c> countryInputs = countryInputMap.get(recordId);
                Decimal totalWeeks = 0;
                
                for (Timeline__c timeline : timelineMap.get(recordId)) {
                    totalWeeks = totalWeeks + timeline.Weeks__c;            
                }
                
                Map<String, Integer> countrySiteMap = new Map<String, Integer>();
                Map<String, Integer> countryUnitsMap = new Map<String, Integer>();
                
                Decimal visits = 0;
                Decimal visitFreq = 0;
                
                if (countryInputs.size() > 0) {
                    for (Country_Input__c countryInput : countryInputs) {
                        if (countrySiteMap != null && !countrySiteMap.containsKey(countryInput.COUNTRY__C)) {
                            countrySiteMap.put(countryInput.COUNTRY__C, (Integer)countryInput.Num_of_Active_Sites__c);
                        } else {
                            Integer sites = countrySiteMap.get(countryInput.COUNTRY__C);
                            countrySiteMap.put(countryInput.COUNTRY__C, sites + (Integer)countryInput.Num_of_Active_Sites__c);
                        }
                    }
                    
                    for (sobject lineItem : lineItemList) {
                        String unitCode = (String)lineItem.get(CON_CPQ.UNIT_CODE_WITHOUT_COUNTRY_CODE);
                        String taskName = (String)lineItem.get(CON_CPQ.QUOTE_LINE_ITEM_DESCRIPTION);
                        String country = (String)lineItem.get(CON_CPQ.BIDGRID_COUNTRY);
                        Integer units = (Integer)(Decimal)lineItem.get(CON_CPQ.NUMBER_OF_UNITS);
                        String role = (String)lineItem.get(CON_CPQ.ROLE_FIELD);
                        
                        if (onsiteUnitCodes.contains(unitCode) && taskName == CON_CPQ.ON_SITE) {
                            if (countryUnitsMap != null && !countryUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + CON_CPQ.ONSITE + CON_CPQ.SEPARATOR + role)) {
                                countryUnitsMap.put(country + CON_CPQ.SEPARATOR + CON_CPQ.ONSITE + CON_CPQ.SEPARATOR + role, units);
                            } else {
                                Integer sites = countryUnitsMap.get(country + CON_CPQ.SEPARATOR + CON_CPQ.ONSITE + CON_CPQ.SEPARATOR + role);
                                countryUnitsMap.put(country + CON_CPQ.SEPARATOR + CON_CPQ.ONSITE + CON_CPQ.SEPARATOR + role, sites + units);
                            }
                        } else if (remoteUnitCodes.contains(unitCode) && taskName == CON_CPQ.CALL) {
                            if (countryUnitsMap != null && !countryUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + CON_CPQ.REMOTE + CON_CPQ.SEPARATOR + role)) {
                                countryUnitsMap.put(country + CON_CPQ.SEPARATOR + CON_CPQ.REMOTE + CON_CPQ.SEPARATOR + role, units);
                            } else {
                                Integer sites = countryUnitsMap.get(country + CON_CPQ.SEPARATOR + CON_CPQ.REMOTE + CON_CPQ.SEPARATOR + role);
                                countryUnitsMap.put(country + CON_CPQ.SEPARATOR + CON_CPQ.REMOTE + CON_CPQ.SEPARATOR + role, sites + units);
                            }
                        } else if (pharmacyUnitCodes.contains(unitCode) && taskName == CON_CPQ.ON_SITE) {
                            if (countryUnitsMap != null && !countryUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + CON_CPQ.PHARMACY + CON_CPQ.SEPARATOR + role)) {
                                countryUnitsMap.put(country + CON_CPQ.SEPARATOR + CON_CPQ.PHARMACY + CON_CPQ.SEPARATOR + role, units);
                            } else {
                                Integer sites = countryUnitsMap.get(country + CON_CPQ.SEPARATOR + CON_CPQ.PHARMACY + CON_CPQ.SEPARATOR + role);
                                countryUnitsMap.put(country + CON_CPQ.SEPARATOR + CON_CPQ.PHARMACY + CON_CPQ.SEPARATOR + role, sites + units);
                            }
                        }
                    }
                    
                    for (String country : countryUnitsMap.keySet()) {
                        List<String> countryVisit = country.split(CON_CPQ.SEPARATOR);
                        
                        if (countrySiteMap.containsKey(countryVisit[0])) {
                            Integer sites = countrySiteMap.get(countryVisit[0]);
                            Decimal siteResult = (Decimal)countryUnitsMap.get(country) / (Decimal)sites;
                            Decimal result = ((totalWeeks / siteResult) != 0 ? (totalWeeks / siteResult).setScale(2) : 0);
                            Clinical_Visit_Frequency_Data__c CVFDObj = null;
                            String role = countryVisit[2];
                            
                            if (countryVisit[1] == CON_CPQ.ONSITE) {
                                CVFDObj = new Clinical_Visit_Frequency_Data__c(Country__c = countryVisit[0], Visit_Type__c = CON_CPQ.QRPM_ONSITE_MONITORING_VISIT_FREQUENCY, Visit_Frequency__c = result.setScale(2), Role__c = role);
                            } else if (countryVisit[1] == CON_CPQ.REMOTE) {
                                CVFDObj = new Clinical_Visit_Frequency_Data__c(Country__c = countryVisit[0], Visit_Type__c = CON_CPQ.QRPM_REMOTE_MONITORING_VISIT_FREQUENCY, Visit_Frequency__c = result.setScale(2), Role__c = role);
                            } else if (countryVisit[1] == CON_CPQ.PHARMACY) {
                                CVFDObj = new Clinical_Visit_Frequency_Data__c(Country__c = countryVisit[0], Visit_Type__c = CON_CPQ.QRPM_ONSITE_PHARMACY_MONITORING_VISIT_FREQUENCY, Visit_Frequency__c = result.setScale(2), Role__c = role);
                            }
                            CVFDObj.Proposal__c = recordId;					 
                            clinicalVisitFreqList.add(CVFDObj);
                        }
                    }
                }
            }
        }
        
        if (clinicalVisitFreqList.size() > 0) {
            insert clinicalVisitFreqList;
        }
    }
    
    public static void createAdminTimeEntryQuoteData(Map<Id, Apttus_Proposal__Proposal__c> proposalMap) {
        try { 
            Set<Id> parentIdsSet = proposalMap.keySet();
            Map<Id, List<Country_Input__c>> countryInputMap = new Map<Id, List<Country_Input__c>>();
            Map<Id, List<Timeline__c>> timelineMap = new Map<Id, List<Timeline__c>>();
            
            String condition = ' Proposal__c IN :parentIdsSet ';
            countryInputMap = getMapOfSobjectListWithAgreementId(new SLT_Country_Input().selectByAgreementIds(parentIdsSet, new Set<String> {CON_CPQ.ID, CON_CPQ.NUM_OF_ACTIVE_SITES, CON_CPQ.COUNTRY, CON_CPQ.PROPOSAL}, condition), CON_CPQ.PROPOSAL);
            condition = ' Name IN :timelineSet AND Proposal__c IN :parentIdsSet';
            timelineMap = getMapOfSobjectListWithAgreementId(new SLT_Timeline().selectByAgreementIdAndTimelineNames(parentIdsSet, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.MONTHS, CON_CPQ.PROPOSAL}, timelineSetAdmin, condition), CON_CPQ.PROPOSAL);
            
            List<Admin_Time_Entry_Data__c> adminTimeEntries = new List<Admin_Time_Entry_Data__c>();
            
            Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> lineItemMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
            Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.UNIT_CODE_WITHOUT_COUNTRY_CODE, CON_CPQ.HOURS_PER_UNIT, CON_CPQ.QUOTE_LINE_ITEM_DESCRIPTION, CON_CPQ.BIDGRID_COUNTRY, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.TOTAL_HOURS, CON_CPQ.ROLE_FIELD, CON_CPQ.TOTAL_BUDGET_HOURS, CON_CPQ.BUDGETED_UNITS};
            Set<String> unitCodes = new Set<String>();
            unitCodes.addAll(adminTimeEntryUnitCodes);
            condition = ' Unit_Code_Without_Country_Code__c IN : unitCodes AND Apttus_Proposal__Proposal__c IN :parentIdsSet ';
            lineItemMap = getMapOfSobjectListWithAgreementId(new SLT_ProposalLineItems().selectByProposalIdsAndUnitCodes(proposalMap.keySet(), fieldSet, unitCodes, condition), CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
            
            createAdminTimeEntry(proposalMap, lineItemMap, countryInputMap, timelineMap);
        } catch(Exception ex) {
            String errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
            System.debug('errorMessage================'+errorMessage);
//            CPQ_Utility.createApexErrorLogRecord(proposalMap, errorMessage, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
        }
    }
    public static void createAdminTimeEntry(Map<Id, sobject> parentRecordsMap, Map<Id, List<sobject>> lineItemMap, Map<Id, List<Country_Input__c>> countryInputMap, Map<Id, List<Timeline__c>> timelineMap) {
        
        List<Admin_Time_Entry_Data__c> allAdminTimeEntries = new List<Admin_Time_Entry_Data__c>();
        CPQ_Settings__c cpqSettings = CPQ_Settings__c.getValues('CPQ Setting');
        Decimal timelineMonthRemoteEDC = cpqSettings.Timeline_Month_For_Remote_EDC__c != null ? cpqSettings.Timeline_Month_For_Remote_EDC__c : 0;
        
        for (sobject parentRecord : parentRecordsMap.values()) {
            
            String parentId = (Id)parentRecord.get(CON_CPQ.Id);
            List<Admin_Time_Entry_Data__c> adminTimeEntries = new List<Admin_Time_Entry_Data__c>();
            Map<String, Admin_Time_Entry_Data__c> mapOfLSO_COVData = new Map<String, Admin_Time_Entry_Data__c>();
            
            if (lineItemMap.containsKey(parentId)) {
                
                List<Country_Input__c> countryInputs = (countryInputMap.containsKey(parentId) ? countryInputMap.get(parentId) : new List<Country_Input__c>());
                Decimal totalMonths = 0;
                Decimal FSI_LSI = 0;
                Decimal LSI_LSO = 0;
                Decimal LSO_DBL = 0;
                Decimal SIV_FSI = 0;
                
                if (timelineMap.containsKey(parentId)) {
                    for (Timeline__c timeline : timelineMap.get(parentId)) {
                        if (timeline.name == CON_CPQ.PROJECT_START_UP) {
                            SIV_FSI += timeline.Months__c;
                        } else {
                            totalMonths += timeline.Months__c;
                            if (timeline.name == CON_CPQ.RECRUITMENT_FPI_TO_LPI || timeline.name == CON_CPQ.RUN_IN_SCREENING_LPI) {
                                FSI_LSI += timeline.Months__c;
                            } else if (timeline.name == CON_CPQ.TREATMENT_LPI_LPO) {
                                LSI_LSO += timeline.Months__c;
                            } else if (timeline.name == CON_CPQ.IN_TREATMENT_FOLLOWUP_BASED_ON_LPO) {
                                LSO_DBL += timeline.Months__c;
                            }
                        }          
                    }
                }
                
                Map<String, Integer> countrySiteMap = new Map<String, Integer>();
                
                if (countryInputs.size() > 0) {
                    for (Country_Input__c countryInput : countryInputs) {
                        if (countrySiteMap != null && !countrySiteMap.containsKey(countryInput.COUNTRY__C)) {
                            countrySiteMap.put(countryInput.COUNTRY__C, (Integer)countryInput.Num_of_Active_Sites__c);
                        } else {
                            Integer sites = countrySiteMap.get(countryInput.COUNTRY__C);
                            countrySiteMap.put(countryInput.COUNTRY__C, sites + (Integer)countryInput.Num_of_Active_Sites__c);
                        }
                    }
                }
                List<sobject> lineItemList = lineItemMap.get(parentId);
                Decimal enrollmentHours = 0;
                Decimal treatmentHours = 0;
                Decimal followupHours = 0;
                Map<String, Decimal> countryUnitHoursMap = new Map<String, Decimal>();
                Map<String, Decimal> totalBudgetHoursMap = new Map<String, Decimal>();
                Map<String, Decimal> totalBudgetUnitsMap = new Map<String, Decimal>();
                
                for (sobject lineItem : lineItemList) {
                    String unitCode = (String)lineItem.get(CON_CPQ.UNIT_CODE_WITHOUT_COUNTRY_CODE);
                    String taskName = (String)lineItem.get(CON_CPQ.QUOTE_LINE_ITEM_DESCRIPTION);
                    String country = (String)lineItem.get(CON_CPQ.BIDGRID_COUNTRY);
                    Decimal hoursPerUnit = (Decimal)lineItem.get(CON_CPQ.HOURS_PER_UNIT);
                    Decimal totalHours = (Decimal)lineItem.get(CON_CPQ.TOTAL_HOURS);
                    String role = (String)lineItem.get(CON_CPQ.ROLE_FIELD);
                    Decimal budgetHours = (Decimal)lineItem.get(CON_CPQ.TOTAL_BUDGET_HOURS);
                    Decimal budgetUnit = (Decimal)lineItem.get(CON_CPQ.BUDGETED_UNITS);
                    if (unitCode == CON_CPQ.CLIN_A14) {
                        if (taskName == CON_CPQ.SITE_CONTACT) {
                            if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                            } else {
                                Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + hoursPerUnit);
                            }

                            if (budgetHours != 0 && budgetHours != null) {
                                if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetHours);
                                } else {
                                    Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                                }
                            }

                            if (budgetUnit != 0 && budgetUnit != null) {
                                if (!totalBudgetUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetUnit);
                                } else {
                                    Decimal units = totalBudgetUnitsMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, units + budgetUnit);
                                }
                            }
                        } else if (taskName == CON_CPQ.REMOTE_EDC_REVIEW) {
                            if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                            } else {
                                Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + hoursPerUnit);
                            }

                            if (budgetHours != 0 && budgetHours != null) {
                                if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetHours);
                                } else {
                                    Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                                }
                            }
                        }
                    } else if (unitCode == CON_CPQ.CLIN_A18) {
                        if (taskName == CON_CPQ.SITE_CONTACT) {
                            if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                            } else {
                                Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + hoursPerUnit);
                            }

                            if (budgetHours != 0 && budgetHours != null) {
                                if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetHours);
                                } else {
                                    Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                                }
                            }

                            if (budgetUnit != 0 && budgetUnit != null) {
                                if (!totalBudgetUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetUnit);
                                } else {
                                    Decimal units = totalBudgetUnitsMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, units + budgetUnit);
                                }
                            }
                        } else if (taskName == CON_CPQ.REMOTE_EDC_REVIEW) {
                            if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                            } else {
                                Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + hoursPerUnit);
                            }

                            if (budgetHours != 0 && budgetHours != null) {
                                if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetHours);
                                } else {
                                    Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                                }
                            }
                        }
                    } else if (unitCode == CON_CPQ.CLIN_A19) {
                        if (taskName == CON_CPQ.SITE_CONTACT) {
                            if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                            } else {
                                Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + hoursPerUnit);
                            }

                            if (budgetHours != 0 && budgetHours != null) {
                                if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetHours);
                                } else {
                                    Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                                }
                            }

                            if (budgetUnit != 0 && budgetUnit != null) {
                                if (!totalBudgetUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetUnit);
                                } else {
                                    Decimal units = totalBudgetUnitsMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, units + budgetUnit);
                                }
                            }
                        } else if (taskName == CON_CPQ.REMOTE_EDC_REVIEW) {
                            if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                            } else {
                                Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + hoursPerUnit);
                            }

                            if (budgetHours != 0 && budgetHours != null) {
                                if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                                } else {
                                    Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                    totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                                }
                            }
                        }
                    } else if (unitCode == CON_CPQ.CLIN_A20 && taskName == CON_CPQ.SITE_CONTACT) {
                        if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                            countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hoursPerUnit);
                        } else {
                            Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                            countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + hoursPerUnit);
                        }
                        if (budgetHours != 0 && budgetHours != null) {
                            if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetHours);
                            } else {
                                Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                            }
                        }
                        if (budgetUnit != 0 && budgetUnit != null) {
                            if (!totalBudgetUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetUnit);
                            } else {
                                Decimal units = totalBudgetUnitsMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, units + budgetUnit);
                            }
                        }

                        adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = country, Admin_Time__c = hoursPerUnit, 
                                                                          Role__c = role, Visit_Type__c = CON_CPQ.NON_RBM_ADMIN_DBL_COV, TotalAdminBudgetHours__c = budgetHours));
                    } else if (unitCode == CON_CPQ.CLIN_A44 && taskName == CON_CPQ.SITE_CONTACT) {
                        adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = country, Admin_Time__c = hoursPerUnit, 
                                                                          Role__c = role, Visit_Type__c = CON_CPQ.RBM_ADMIN_PHARMACY));
                        adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = country, Admin_Time__c = hoursPerUnit, 
                                                                          Role__c = role, Visit_Type__c = CON_CPQ.NON_RBM_ADMIN_PHARMACY));
                    } else if (unitCode == CON_CPQ.CLIN_A42 && taskName == CON_CPQ.REMOTE_EDC_REVIEW) {
                        if (!countryUnitHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                            countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, totalHours);
                        } else {
                            Decimal hours = countryUnitHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                            countryUnitHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, hours + totalHours);
                        }

                        if (budgetHours != 0 && budgetHours != null) {
                            if (!totalBudgetHoursMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetHours);
                            } else {
                                Decimal bdgHours = totalBudgetHoursMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                totalBudgetHoursMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, bdgHours + budgetHours);
                            }
                        }

                        if (budgetUnit != 0 && budgetUnit != null) {
                            if (!totalBudgetUnitsMap.containsKey(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role)) {
                                totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, budgetUnit);
                            } else {
                                Decimal units = totalBudgetUnitsMap.get(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role);
                                totalBudgetUnitsMap.put(country + CON_CPQ.SEPARATOR + unitCode + CON_CPQ.SEPARATOR + role, units + budgetUnit);
                            }
                        }
                    } else if (unitCode == CON_CPQ.CLIN_A13) {
                        if (taskName == CON_CPQ.SITE_READINESS) {
                            adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = country, Admin_Time__c = (hoursPerUnit / SIV_FSI), 
                                                                              Role__c = role, Visit_Type__c = CON_CPQ.RBM_ADMIN_SIV_FSI, TotalAdminBudgetHours__c = budgetHours));
                            adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = country, Admin_Time__c = (hoursPerUnit / SIV_FSI), 
                                                                              Role__c = role, Visit_Type__c = CON_CPQ.NON + CON_CPQ.RBM_ADMIN_SIV_FSI, TotalAdminBudgetHours__c = budgetHours));
                        }
                    }
                }
                
                system.debug('countryUnitHoursMap==='+countryUnitHoursMap);
                for (String key : countryUnitHoursMap.keySet()) {
                    
                    List<String> countryUnitList = key.split(CON_CPQ.SEPARATOR);
                    Decimal hours = countryUnitHoursMap.get(key);
                    Decimal totalH = totalBudgetHoursMap.get(key);
                    Decimal totalUnits = totalBudgetUnitsMap.get(key);

                    system.debug('countryUnitList==================='+ countryUnitList);
                    if (countryUnitList.size() > 1) {
                        if (countryUnitList[1] == CON_CPQ.CLIN_A14) {
                            
                            Decimal sumOfUnits = 0; 
                            Decimal adminTime = 0;
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetHoursMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                Decimal totalBudgetHours = (Decimal)totalBudgetHoursMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                                adminTime = FSI_LSI > timelineMonthRemoteEDC ? (totalBudgetHours / sumOfUnits) : 0;
                            }
                            if (totalBudgetHoursMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                totalH = totalBudgetHoursMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                                totalH = (totalH/totalMonths) * FSI_LSI;
                                totalH +=  totalBudgetHoursMap.get(key);
                                totalH = Math.floor(totalH * 100) / 100;
                            }
                            adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = countryUnitList[0], Admin_Time__c = adminTime + hours, 
                                                                              Role__c = countryUnitList[2], Visit_Type__c = CON_CPQ.RBM_ADMIN_FSI_LSI, TotalAdminBudgetHours__c = totalH));
                            adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = countryUnitList[0], Admin_Time__c = adminTime + hours, 
                                                                              Role__c = countryUnitList[2], Visit_Type__c = CON_CPQ.NON + CON_CPQ.RBM_ADMIN_FSI_LSI, TotalAdminBudgetHours__c = totalH));
                        } else if (countryUnitList[1] == CON_CPQ.CLIN_A18) {
                            
                            Decimal sumOfUnits = 0; 
                            Decimal adminTime = 0;
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetHoursMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                Decimal totalBudgetHours = (Decimal)totalBudgetHoursMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                                adminTime = LSI_LSO > timelineMonthRemoteEDC ? (totalBudgetHours / sumOfUnits) : 0;
                            }
                            if (totalBudgetHoursMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                totalH = totalBudgetHoursMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                                totalH = (totalH/totalMonths) * LSI_LSO;
                                totalH +=  totalBudgetHoursMap.get(key);
                                totalH = Math.floor(totalH * 100) / 100; 
                            }

                            adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = countryUnitList[0], Admin_Time__c = adminTime + hours, 
                                                                              Role__c = countryUnitList[2], Visit_Type__c = CON_CPQ.RBM_ADMIN_LSI_LSO, TotalAdminBudgetHours__c = totalH));
                            adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = countryUnitList[0], Admin_Time__c = adminTime + hours, 
                                                                              Role__c = countryUnitList[2], Visit_Type__c = CON_CPQ.NON + CON_CPQ.RBM_ADMIN_LSI_LSO, TotalAdminBudgetHours__c = totalH));
                        } else if (countryUnitList[1] == CON_CPQ.CLIN_A19) {
                            Decimal sumOfUnits = 0; 
                            Decimal adminTime = 0;
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetHoursMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                Decimal totalBudgetHours = (Decimal)totalBudgetHoursMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                                adminTime = LSO_DBL > timelineMonthRemoteEDC ? (totalBudgetHours / sumOfUnits) : 0;
                            }
                            
                            if (totalBudgetHoursMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                totalH = totalBudgetHoursMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                                totalH = (totalH/totalMonths) * LSO_DBL;
                                totalH +=  totalBudgetHoursMap.get(key);
                                totalH = Math.floor(totalH * 100) / 100;  
                            }
                            adminTimeEntries.add(new Admin_Time_Entry_Data__c(Country__c = countryUnitList[0], Admin_Time__c = adminTime + hours, 
                                                                              Role__c = countryUnitList[2], Visit_Type__c = CON_CPQ.NON_RBM_ADMIN_LSO_DBL, TotalAdminBudgetHours__c = totalH));
                            if (mapOfLSO_COVData.containsKey(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0])) {
                                Admin_Time_Entry_Data__c adt = mapOfLSO_COVData.get(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0]);
                                adt.Admin_Time__c += hours;
                                adt.TotalAdminBudgetHours__c += totalH;
                                mapOfLSO_COVData.put(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0], adt);
                            } else {
                                mapOfLSO_COVData.put(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0], new Admin_Time_Entry_Data__c(Country__c = countryUnitList[0], Admin_Time__c = adminTime + hours, Role__c = countryUnitList[2], Visit_Type__c = CON_CPQ.RBM_ADMIN_LSO_COV, TotalAdminBudgetHours__c = totalH));
                            }
                        } else if (countryUnitList[1] == CON_CPQ.CLIN_A20) {
                            Decimal sumOfUnits = 0; 
                            Decimal adminTime = 0;
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A14 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A18 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetUnitsMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                sumOfUnits += (Decimal)totalBudgetUnitsMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A19 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                            }
                            if (totalBudgetHoursMap.containsKey(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]) && countrySiteMap.containsKey(countryUnitList[0])) {
                                Decimal totalBudgetHours = (Decimal)totalBudgetHoursMap.get(countryUnitList[0] + CON_CPQ.SEPARATOR + CON_CPQ.CLIN_A42 + CON_CPQ.SEPARATOR + countryUnitList[2]);
                                adminTime = LSO_DBL > timelineMonthRemoteEDC ? (totalBudgetHours / sumOfUnits) : 0;
                            }

                            if (mapOfLSO_COVData.containsKey(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0])) {
                                Admin_Time_Entry_Data__c adt = mapOfLSO_COVData.get(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0]);
                                adt.Admin_Time__c += hours;
                                adt.TotalAdminBudgetHours__c += totalH;
                                mapOfLSO_COVData.put(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0], adt);
                            } else {
                                mapOfLSO_COVData.put(CON_CPQ.RBM_ADMIN_LSO_COV + countryUnitList[0], new Admin_Time_Entry_Data__c(Country__c = countryUnitList[0], Admin_Time__c = adminTime + hours, Role__c = countryUnitList[2], Visit_Type__c = CON_CPQ.RBM_ADMIN_LSO_COV, TotalAdminBudgetHours__c = totalH));
                            }                           
                        }
                    }
                }
            }
            
            adminTimeEntries.addAll(mapOfLSO_COVData.values());
            for (Admin_Time_Entry_Data__c ATED : adminTimeEntries) {
                ATED.Proposal__c = parentId;			 
            }
            allAdminTimeEntries.addAll(adminTimeEntries);
        }
        if (allAdminTimeEntries.size() > 0) {
            insert allAdminTimeEntries;
        }
    }
	
    public static void createTimelineAndPhaseQuoteData(Set<Id> parentIdsSet, Boolean createTimeline, Boolean updateALIPhases) {
        try {
            List<Timeline__c> newTimelineList = new List<Timeline__c>();
            List<Apttus_Proposal__Proposal_Line_Item__c> updateLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            
            Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> lineItemMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
            Map<Id, List<Country_Input__c>> countryInputMap = new Map<Id, List<Country_Input__c>>();
            Map<Id, List<Timeline__c>> timelineMap = new Map<Id, List<Timeline__c>>();
            
            if (updateALIPhases) {
                Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.TOTAL_HOURS, CON_CPQ.CLOSEOUT_PHASE, CON_CPQ.CONDUCT_PHASE, CON_CPQ.STARTUP_PHASE, CON_CPQ.CLOSEOUT_HOURS, CON_CPQ.CONDUCT_HOURS, CON_CPQ.STARTUP_HOURS, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL};
                lineItemMap = getMapOfSobjectListWithAgreementId(new SLT_ProposalLineItems().selectByProposalIdsAndPhases(parentIdsSet, fieldSet), CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
            }
            if (createTimeline) {
                String condition = ' Proposal__c IN :parentIdsSet ';
                timelineMap = getMapOfSobjectListWithAgreementId(new SLT_Timeline().selectByAgreementIds(parentIdsSet, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.WEEKS, CON_CPQ.START, CON_CPQ.MONTHS, CON_CPQ.END_FIELD, CON_CPQ.PROPOSAL}, condition), CON_CPQ.PROPOSAL);
                countryInputMap = getMapOfSobjectListWithAgreementId(new SLT_Country_Input().selectByAgreementIds(parentIdsSet, new Set<String> {CON_CPQ.ID, CON_CPQ.NUM_OF_ACTIVE_SITES, CON_CPQ.SUBJECTS_RANDOMIZED_RECEIVING_TREAT, CON_CPQ.ENROLLMENT_SITE_MONTHS, CON_CPQ.PROPOSAL}, condition), CON_CPQ.PROPOSAL);
            }
            
            if (updateALIPhases) {
                for (Id parentId : parentIdsSet) {
                    
                    if (lineItemMap.containsKey(parentId)) {
                        List<Apttus_Proposal__Proposal_Line_Item__c> lineItemList = lineItemMap.get(parentId);
                        for (Apttus_Proposal__Proposal_Line_Item__c ali : lineItemList) {
                            Integer numberofPhase = 0;
                            numberofPhase += (ali.Closeout_Phase__c ? 1 : 0);
                            numberofPhase += (ali.Conduct_Phase__c ? 1 : 0);
                            numberofPhase += (ali.Startup_Phase__c ? 1 : 0);
                            
                            Decimal dividedHours = ali.Total_Hours__c / numberofPhase;
                            dividedHours = dividedHours.setScale(2);
                            if (ali.Closeout_Phase__c) {
                                ali.Closeout_Hours__c = dividedHours;
                            }
                            if (ali.Conduct_Phase__c) {
                                ali.Conduct_Hours__c = dividedHours;
                            }
                            if (ali.Startup_Phase__c) {
                                ali.Startup_Hours__c = dividedHours;
                            }
                            updateLineItemList.add(ali);
                        }
                    }
                }
                if (updateLineItemList.size() > 0) {
                    update updateLineItemList;
                }
            }
            
            if (createTimeline) {
                createTimelineData(parentIdsSet, countryInputMap, timelineMap);
            }
        } catch(Exception ex) {
            String errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
            System.debug('errorMessage================'+errorMessage);
//            CPQ_Utility.createApexErrorLogRecord(parentIdsSet, errorMessage, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
        }
    }
    public static void createTimelineData(Set<Id> parentIdsSet, Map<Id, List<Country_Input__c>> countryInputMap, Map<Id, List<Timeline__c>> timelineMap) {
        
        Decimal studyStartupMonth = 0;
        Decimal totalSites = 0;
        Decimal totalRandomPatients = 0;
        Decimal totalEnrollMonths = 0;
        Decimal treatMonth = 0;
        Date recruitEnd, recruitStart, screenEnd, treatFUEnd, treatEnd;
        List<Timeline__c> allNewTimelineList = new List<Timeline__c>();
        
        for (Id parentId : parentIdsSet) {
            
            if (countryInputMap.containsKey(parentId) && timelineMap.containsKey(parentId)) {
                List<Country_Input__c> countryInputList = countryInputMap.get(parentId);
				List<Timeline__c> newTimelineList = new List<Timeline__c>();
                List<Timeline__c> timelineList = timelineMap.get(parentId);
                
                if (timelineList.size() > 0) {
                    for (Country_Input__c countryInput : countryInputList) {
                        totalSites = totalSites + countryInput.Num_of_Active_Sites__c;
                        totalRandomPatients = countryInput.Subjects_Randomized_or_Receiving_Treatme__c + totalRandomPatients;
                        totalEnrollMonths = countryInput.Enrollment_Site_Months__c + totalEnrollMonths;
                    }
                    Integer index = 15;
                    for (Timeline__c timeline : timelineList) {
                        timeline.Months__c = (timeline.Weeks__c/4.33).setScale(2);
                        newTimelineList.add(timeline);
                        if (timeline.Name == CON_CPQ.RECRUITMENT_FPI_TO_LPI) {
                            recruitEnd = timeline.End__c;
                            recruitStart = timeline.Start__c;
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.RECRUITMENT_PERIOD, Months__c = timeline.Months__c, Order__c = index+2));
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.FIRST_PATIENT_RECRUITED_FPI, Start__c = timeline.Start__c, Order__c = index+8));
                            
                            if (timeline.Months__c != null && timeline.Months__c != 0) {
                                Decimal result = (totalSites > 0 ? totalRandomPatients/totalSites : 0);
                                result = (result > 0 ? result/timeline.Months__c : 0);
                                newTimelineList.add(new Timeline__c(Name = CON_CPQ.EXPECTED_RECRUITMENT_RATE, Months__c = result.setScale(2), Order__c = index+4));
                            } else {
                                newTimelineList.add(new Timeline__c(Name = CON_CPQ.EXPECTED_RECRUITMENT_RATE, Months__c = 0, Order__c = index+4));
                            }
                        } else if (timeline.Name == CON_CPQ.TREATMENT_LPI_LPO) {
                            treatEnd = timeline.End__c;
                            treatMonth = timeline.Months__c;
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.TREATMENT_PERIOD_MONTHS, Months__c = timeline.Months__c, Order__c = index+6));
                        } else if (timeline.Name == CON_CPQ.RUN_IN_SCREENING_LPI) {
                            screenEnd = timeline.End__c;
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.SCREENING_PERIOD_MONTHS, Months__c = timeline.Months__c, Order__c = index+5));
                        } else if (timeline.Name == CON_CPQ.PRE_PROJECT_ACTIVITIES) {
                            studyStartupMonth += timeline.Months__c;
                        } else if (timeline.Name == CON_CPQ.PROJECT_START_UP) {
                            studyStartupMonth += timeline.Months__c;
                        } else if (timeline.Name == CON_CPQ.DURATION_OF_ACTIVE_PROJECT) {
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.IQVIA_INVOLVEMENT_BEGINS, Start__c = timeline.Start__c, Order__c = index+7));
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.TOTAL_STUDY_TIMELINE, Months__c = timeline.Months__c, Order__c = index+19));
                        } else if (timeline.Name == CON_CPQ.LOCKED_DATABASE) {
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.LOCKED_DATABASE, End__c = timeline.End__c, Order__c = index+12));
                        } else if (timeline.Name == CON_CPQ.CLOSE_OUT) {
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.CLOSE_OUT, End__c = timeline.End__c, Order__c = index+13));
                        } else if (timeline.Name == CON_CPQ.STAT_ANALYSIS_FINAL_TLF) {
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.DATE_TABLES_LISTINGS_COMPLETE, End__c = timeline.End__c, Order__c = index+14));
                        } else if (timeline.Name == CON_CPQ.SUBSEQUENT_DRAFTS_TO_FINAL_REPORT) {
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.DATE_FOR_REPORT_FIRST_DARFT, Start__c = timeline.Start__c, Order__c = index+15));
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.DATE_FOR_FINAL_REPORT, End__c = timeline.End__c, Order__c = index+16));
                        } else if (timeline.Name == CON_CPQ.POST_TREATMENT_FOLLOW_UP) {
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.POST_TREATMENT_FOLLOW_UP, Start__c = timeline.Start__c, Order__c = index+17));
                        } else if (timeline.Name == CON_CPQ.OTHER_POST_PROJECT_ACTIVITIES_IN) {
                            newTimelineList.add(new Timeline__c(Name = CON_CPQ.OTHER_POST_PROJECT_ACTIVITIES, Start__c = timeline.Start__c, Order__c = index+18));
                        } else if(timeline.Name == CON_CPQ.IN_TREATMENT_FOLLOWUP_BASED_ON_LPO) {
                            treatFUEnd = timeline.End__c;
                        }
                    }
                    newTimelineList.add(new Timeline__c(Name = CON_CPQ.LAST_PATIENT_RECRUITED_LPI, End__c = (recruitEnd > screenEnd ? recruitEnd : screenEnd), Order__c = index+9));
                    newTimelineList.add(new Timeline__c(Name = CON_CPQ.LAST_PATIENT_COMPLETING_TREATMENT_LPO, End__c = (treatEnd > treatFUEnd ? treatEnd : treatFUEnd), Order__c = index+11));
                    newTimelineList.add(new Timeline__c(Name = CON_CPQ.STUDY_START_UP_PERIOD, Months__c = studyStartupMonth, Order__c = index+1));
                    
                    if (recruitStart != null && treatMonth != null) {
                        Date firstPCT = recruitStart.addDays(Integer.valueOf(treatMonth*4.33*7));
                        newTimelineList.add(new Timeline__c(Name = CON_CPQ.FIRST_PATIENT_COMPLETING_TREATMENT_FPO, End__c = firstPCT, Order__c = index+10));
                    }
                    
                    if (totalSites > 0) {
                        Decimal result = totalEnrollMonths/totalSites;
                        newTimelineList.add(new Timeline__c(Name = CON_CPQ.AVG_SITE_RECRUITMENT_PERIOD, Months__c = result.setScale(2), Order__c = index+3));
                    } else {
                        newTimelineList.add(new Timeline__c(Name = CON_CPQ.AVG_SITE_RECRUITMENT_PERIOD, Months__c = 0, Order__c = index+3));
                    }
                }
                for (Timeline__c timeline : newTimelineList) {
                    timeline.Proposal__c = parentId;
                }
				
				allNewTimelineList.addAll(newTimelineList);
            }            
        }
        if (allNewTimelineList.size() > 0) {
            upsert allNewTimelineList;
        }
    }
    
    public static Map<Id, List<sobject>> getMapOfSobjectListWithAgreementId(List<sobject> sObjectList, String parentIdField) {
        Map<Id, List<sobject>> sobjectMap = new Map<Id, List<sobject>>();
        
        for (sobject record : sObjectList) {
            Id parentId = (Id)record.get(parentIdField);
            if (sobjectMap != null && !sobjectMap.containsKey(parentId)) {
                sobjectMap.put(parentId, new List<sobject>());
            }
            sobjectMap.get(parentId).add(record);
        }
        return sobjectMap;
    }
    
    public static void deleteCountryInput(Id parentId) 
    {
        Set<Id> parentIdsSet =  new Set<Id> {parentId};
        String condition = '';	
        condition = ' Proposal__c IN :parentIdsSet ';
        delete new SLT_Country_Input().selectByAgreementIds(parentIdsSet,new Set<String> {CON_CPQ.ID},condition);
    }
    
    public static void deleteTimeline(Id parentId) 
    {
        Set<Id> parentIdsSet =  new Set<Id> {parentId};
        String condition = '';
        condition = ' Proposal__c IN :parentIdsSet ';
        delete new SLT_Timeline().selectByAgreementIds(parentIdsSet,new Set<String> {CON_CPQ.ID},condition);
    }
    
    public static void deleteTimelineByOrder(Set<Id> parentIdsSet) 
    {
        String condition = '';	
        condition = ' Proposal__c IN :parentIdsSet AND Order__c > 15 ';
        delete new SLT_Timeline().selectByAgreementIds(parentIdsSet,new Set<String> {CON_CPQ.ID},condition);
    }                                                                                       
    public static void deleteAdminTimeEntryData(Set<Id> parentIdsSet) 
    {
        String condition = '';	
        condition = ' Proposal__c IN :parentIdsSet ';
        delete new SLT_Admin_Time_Entry_Data().selectByCondition(parentIdsSet,new Set<String> {CON_CPQ.ID},condition);
    }
    
    public static void deleteClinicalVisitFrequencyData(Set<Id> parentIdsSet) 
    {
        String condition = '';	
        condition = ' Proposal__c IN :parentIdsSet ';
        delete new SLT_Clinical_Visit_Frequency_Data().selectByCondition(parentIdsSet,new Set<String> {CON_CPQ.ID},condition);
    }
    
    public static void unlockApprovalProcess(List<Apttus_Proposal__Proposal__c> proposalList) {        
        List<Approval.UnlockResult> ulrList = Approval.unlock(proposalList, false);
        for (Approval.UnlockResult  ulr : ulrList) {
            if (ulr.isSuccess()) {
                System.debug('Successfully unlocked Proposal with ID: ' + ulr.getId());
            } else {            
                for (Database.Error err : ulr.getErrors()) {                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }

    @future
    public static void unlockDynamicApprovalProcess(List<Id> recordIdList) {        
        List<Approval.UnlockResult> ulrList = Approval.unlock(recordIdList, false);
        for (Approval.UnlockResult  ulr : ulrList) {
            if (ulr.isSuccess()) {
                System.debug('Successfully unlocked Proposal with ID: ' + ulr.getId());
            } else {            
                for (Database.Error err : ulr.getErrors()) {                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    
    public static void deleteAttachment(Id recordId) {
        List<Attachment> files;
        Apttus_Proposal__Proposal_Line_Item__c pli = new SLT_ProposalLineItems().getPLIByCreatedDateDescending(new Set<String>{CON_CPQ.ID, CON_CPQ.CREATED_DATE}, recordId);
        
        if (pli != null && pli.CreatedDate != null) {
            String condition = 'Name LIKE \'FINAL%.xlsb\' AND CreatedDate >=: refDate AND ParentId =: recordId';
            files = new SLT_Attachment().selectAttachmentsByCondition(new Set<String>{CON_CPQ.ID}, recordId, condition, pli.CreatedDate);
        }
        if (files.size() > 0) {
            delete files;
        }
    }
    
    public static void updateHeaderData(Id recordId) {
        List<Apttus_Proposal__Proposal__c> proposal = (new SLT_Proposal().getProposalFieldsById(new Set<ID>{recordId}, new Set<String>{CON_CPQ.FIELD_FINALIZE_DATE, CON_CPQ.NUMBER_OF_LINEITEMS}));
        if (proposal.size() > 0) {
            proposal[0].Apttus_QPConfig__ConfigurationFinalizedDate__c = null;
            proposal[0].Number_of_Line_Items__c = null;
            update proposal[0];
        }
    }
}
