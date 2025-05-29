public class UTL_CSM_EntitlementCalc {

    public static Map<String, Map<String, Integer>> MILESTONE_MIN_MAP = new Map<String, Map<String, Integer>> {
        /*TYPE_FIRSTRESPONSE => new Map<String, Integer> {
            CON_CSM.URG_HIGH => 60,
			CON_CSM.URG_MEDIUM => 120,
            CON_CSM.URG_LOW => 480
        },
        TYPE_ONGOINGRESPONSE => new Map<String, Integer> {
            CON_CSM.URG_HIGH => 60,
            CON_CSM.URG_MEDIUM => 60,
            CON_CSM.URG_LOW => 120
        },*/
        CON_CSM.S_RESOLUTION_TIME => new Map<String, Integer> {
            CON_CSM.URG_LOW => 10080
        }
    };

    /** The default business hour */
    public static BusinessHours DEFAULT_BUSINESSHOUR = [select Id from BusinessHours where IsDefault = true limit 1];
    /*{
        get {
            if (DEFAULT_BUSINESSHOUR == null) {
                DEFAULT_BUSINESSHOUR = [select Id from BusinessHours where IsDefault = true limit 1];
            }
            return DEFAULT_BUSINESSHOUR;
        }
    }*/

    /** A map of milestone type id to milestone type */
    public static Map<Id, MilestoneType> MILESTONETYPE_MAP = new Map<Id, MilestoneType>([select Name from MilestoneType]);
    /*{
        get {
            if (MILESTONETYPE_MAP == null) {
                //MILESTONETYPE_MAP = new Map<Id, MilestoneType>([select Name from MilestoneType]);
            }

            return MILESTONETYPE_MAP;
        }
    }*/

    /**
     * Gets the number of business minutes between the cases' SLA start date
     * and a given date.
     *
     * @param c The case
     * @param d The target date
     * @param milestoneTypeId The milestone type that is being calculated for
     * @return The number of business minutes
     */
    public static Integer getMinutesBetweenStartAndDate(Case c, Date d, Id milestoneTypeId) {
        Datetime slaStart = c.SlaStartDate != null ? c.SlaStartDate : c.createdDate;
        Datetime dt = Datetime.newInstanceGMT(d.year(), d.month(), d.day(),slaStart.hourGmt(), slaStart.minuteGmt(), slaStart.secondGmt());

        Id businessHourId = getBusinessHourId(c, milestoneTypeId);
        Long remainingTime = BusinessHours.diff(businessHourId, slaStart, dt) / 1000 / 60;
        return remainingTime.intValue();
    }
    
    public static Id getBusinessHourId(Case c, Id milestoneTypeId) {
        Map<Id, Id> milestoneToBHMap = new Map<Id, Id>();

        for (CaseMilestone cm : c.CaseMilestones) {
            milestoneToBHMap.put(cm.MilestoneTypeId, cm.BusinessHoursId);
        }

        if (milestoneToBHMap.containsKey(milestoneTypeId) && milestoneToBHMap.get(milestoneTypeId) != null) {
            return milestoneToBHMap.get(milestoneTypeId);
        }

        /*if (c.Entitlement.SlaProcess.BusinessHoursId != null) {
            return c.Entitlement.SlaProcess.BusinessHoursId;
        }*/

        if (c.Entitlement.BusinessHoursId != null) {
            return c.Entitlement.BusinessHoursId;
        }

        if (c.BusinessHoursId != null) {
            return c.BusinessHoursId;
        }

        return DEFAULT_BUSINESSHOUR.Id;
    }
}