global class SRV_CSM_EntitlementMilestoneCalc implements Support.MilestoneTriggerTimeCalculator{
    private static Integer DEFAULT_TIME = 60;

    /** The base milestone handler class */
    public abstract class CSM_MilestoneHandler {
        private Case c;
        private Id milestoneTypeId;

        /** Empty constructor */
        public CSM_MilestoneHandler() {}

        public void setCase(Case c) {
            this.c = c;
        }

        public void setMilestoneTypeId(Id milestoneTypeId) {
            this.milestoneTypeId = milestoneTypeId;
        }

        /**
         * Returns the number of business minutes needed
         *
         * @return The number of business minutes
         */
        abstract Integer getTriggerTime();
    }

    /*public class CSM_InitialResponseTimeHandler extends CSM_MilestoneHandler {
        public override Integer getTriggerTime() {
            // If we cannot find the first response type or the case's priority in the map
            // then default to the static DEFAULT_TIME
            if (
                !UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.containsKey(UTL_CSM_EntitlementCalc.TYPE_FIRSTRESPONSE) &&
                !UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.get(UTL_CSM_EntitlementCalc.TYPE_FIRSTRESPONSE).containsKey(this.c.Priority.toUpperCase())
            ) {
                return DEFAULT_TIME;
            }

            return UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.get(UTL_CSM_EntitlementCalc.TYPE_FIRSTRESPONSE).get(this.c.Priority.toUpperCase());
        }
    }

    public class CSM_ProblemResolutionHandler extends CSM_MilestoneHandler {
        public override Integer getTriggerTime() {
            // If we cannot find the first response type or the case's priority in the map
            // then default to the static DEFAULT_TIME
            if (
                !UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.containsKey(CON_CSM.S_PROBLEM_RESO) &&
                !UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.get(CON_CSM.S_PROBLEM_RESO).containsKey(this.c.Priority.toUpperCase())
            ) {
                return DEFAULT_TIME;
            }

            return UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.get(CON_CSM.S_PROBLEM_RESO).get(this.c.Priority.toUpperCase());
        }
    }*/

    public class CSM_ResolutionTimeeHandler extends CSM_MilestoneHandler {
        /**
         * Returns the number of business minutes needed
         * @return The number of business minutes
         */
        public override Integer getTriggerTime() {
            // If we have a static amount of time return that
            /*if (this.c != null && this.c.ETA_Date__c != null && UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.containsKey(CON_CSM.S_RESOLUTION_TIME) && UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.get(CON_CSM.S_RESOLUTION_TIME).containsKey(this.c.Urgency__c.toUpperCase())) {
                return UTL_CSM_EntitlementCalc.MILESTONE_MIN_MAP.get(CON_CSM.S_RESOLUTION_TIME).get(this.c.Urgency__c.toUpperCase());
            }*/

            // Otherwise, calculate the amount of business minutes until the ETA_Date__c
            // NOTE: This should never NPE because the milestone criteria will only fire
            //       for when ETA_Date__c is not null
            if (this.c != null && this.c.ETA_Date__c != null){
                return UTL_CSM_EntitlementCalc.getMinutesBetweenStartAndDate(this.c, this.c.ETA_Date__c, this.milestoneTypeId);    
            }
            return 0;
        }
    }

    /** A map of milestone name to handler class name */
    private static Map<String, String> HANDLER_MAP = new Map<String, String> {
        //CON_CSM.S_FIRST_RESPONSE_T => CSM_InitialResponseTimeHandler.class.getName(),
        //CON_CSM.S_PROBLEM_RESO => CSM_ProblemResolutionHandler.class.getName(),
        CON_CSM.S_RESOLUTION_TIME => CSM_ResolutionTimeeHandler.class.getName()
    };

    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        System.debug('milestoneTypeId : '+milestoneTypeId);
        Case c = SLT_Case.fetchCase(caseId);
        String milestoneName = UTL_CSM_EntitlementCalc.MILESTONETYPE_MAP.get(milestoneTypeId).Name;
        System.debug('milestoneName : '+milestoneName);
        // If we can't find a handler for this milestone name, return the default time
        /*if (!HANDLER_MAP.containsKey(milestoneName)) {
            return DEFAULT_TIME;
        }*/

        // Create a new instance of the handler, set the data and return the time
        if (HANDLER_MAP.containsKey(milestoneName)) {
            Type t = Type.forName(HANDLER_MAP.get(milestoneName));
            CSM_MilestoneHandler handler = (CSM_MilestoneHandler) t.newInstance();
            handler.setMilestoneTypeId(milestoneTypeId);
            handler.setCase(c);
            return handler.getTriggerTime();
        }else{
            return 1;
        }
    }
}