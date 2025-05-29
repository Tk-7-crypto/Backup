/**
* This is Project Metric Actual handler class.
* version : 1.0
*/
public class DAOH_PSA_Project_Metric_Actual {
/**
* This method is used to validate Project Metric Actuals as per their respective Service Line Start and End Date before saving.
*/
    public static void validateProjectMetricActualByServiceLine(List<Project_Metric_Actual__c> newList){
        Set<Id> rdsProjectIdSet = new Set<Id>();
        Set<Id> psaMetricIds = new Set<Id>();
        Map<Id, List<pse__Proj__c>> rdsToServiceLineMap = new Map<Id, List<pse__Proj__c>>();
        Map<Id, PSA_Metric__c> psaMetricMap = new Map<Id, PSA_Metric__c>();
        List<pse__Proj__c> allSLProjects = new List<pse__Proj__c>();
        //storing RDS project IDs
        for(Project_Metric_Actual__c pma : newList) {
            if(pma.Project__c != null){
                rdsProjectIdSet.add(pma.Project__c);
            }
        }
        //mapping RDS Project with its Service Line Projects
        if(rdsProjectIdSet.size() > 0){
            allSLProjects = new SLT_Project().selectServiceLineByParentProject(rdsProjectIdSet, new Set<String>{'Id','Name', 'pse__Parent_Project__c', 'Service_Line__c','Service_Line__r.Name', 'pse__Start_Date__c', 'pse__End_Date__c'});
        }
        if( allSLProjects.size() > 0 ){
            for (pse__Proj__c subProj : allSLProjects) {
                List<pse__Proj__c> tempSubProjList = rdsToServiceLineMap.get(subProj.pse__Parent_Project__c);
                if (tempSubProjList != null) {
                    tempSubProjList.add(subProj);
                    rdsToServiceLineMap.put(subProj.pse__Parent_Project__c,tempSubProjList);
                } else {
                    rdsToServiceLineMap.put(subProj.pse__Parent_Project__c, new List<pse__Proj__c>{subProj});
                }
            }
        }
        
        //storing PSA Metric IDs
        for(Project_Metric_Actual__c pma : newList) {
            if(pma.Project_Metric__c != null){
                psaMetricIds.add(pma.PSA_Metric__c);
            }
        }
        List<PSA_Metric__c> psaMetricsList = new SLT_PSA_Metric().getPSA_MetricsFromIds( psaMetricIds, new Set<String>{'Id','Frequency__c','Service_Line__c','Service_Line__r.Name'} );
        if( psaMetricsList.size() > 0 ){
            for( PSA_Metric__c pm : psaMetricsList ){
                psaMetricMap.put( pm.Id, pm );
            }
        }
        
        if(rdsProjectIdSet.size() > 0){
            for(Project_Metric_Actual__c pma : newList){
                List<pse__Proj__c> slProjects = rdsToServiceLineMap.get(pma.Project__c);
                //iterate through all service line projects
                for(pse__Proj__c slp : slProjects){
                    if(psaMetricMap.size() > 0){
                        if(psaMetricMap.get(pma.PSA_Metric__c).Service_Line__r.Name == null || slp.Service_Line__r.Name == null){
                            pma.addError('There is no service line on this metrics, please link with a service line.');
                            continue;
                        }
                        if((slp.Service_Line__r.Name).containsIgnoreCase(psaMetricMap.get(pma.PSA_Metric__c).Service_Line__r.Name)){
                            if(psaMetricMap.get(pma.PSA_Metric__c).Frequency__c == CON_PSA.PSA_METRIC_Frequency_Monthly){
                                //Frequency__c is Monthly
                                if(!(pma.Date__c.Year() < slp.pse__End_Date__c.Year() || ((pma.Date__c.Year() == slp.pse__End_Date__c.Year()) && (pma.Date__c.Month() <= slp.pse__End_Date__c.Month())))){
                                    pma.addError('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.');
                                }else if(!(pma.Date__c.Year() > slp.pse__Start_Date__c.Year() || ((pma.Date__c.Year() == slp.pse__Start_Date__c.Year()) && (pma.Date__c.Month() >= slp.pse__Start_Date__c.Month())))){
                                    pma.addError('Service line project \'Start Date\' is in the future. Please update the service line project \'Start Date\' and try again.');
                                }
                            }
                            else if(psaMetricMap.get(pma.PSA_Metric__c).Frequency__c == CON_PSA.PSA_METRIC_Frequency_Quarterly){
                                //Frequency__c is Quarterly
                                if(!(pma.Date__c.Year() < slp.pse__End_Date__c.Year() || ((pma.Date__c.Year() == slp.pse__End_Date__c.Year()) && ( math.round((pma.Date__c.Month() + 1) / 3.0) <= math.round((slp.pse__End_Date__c.Month() + 1) / 3.0))))){
                                    pma.addError('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.');
                                }else if(!(pma.Date__c.Year() > slp.pse__Start_Date__c.Year() || ((pma.Date__c.Year() == slp.pse__Start_Date__c.Year()) && (math.round((pma.Date__c.Month() + 1) / 3.0) >= math.round((slp.pse__Start_Date__c.Month() + 1 ) / 3.0))))){
                                    pma.addError('Service line project \'Start Date\' is in the future. Please update the service line project \'Start Date\' and try again.');
                                }
                            }
                            else if(psaMetricMap.get(pma.PSA_Metric__c).Frequency__c == CON_PSA.PSA_METRIC_Frequency_Semi_Annual){
                                //Frequency__c is Semi_Annual
                                if(!(pma.Date__c.Year() < slp.pse__End_Date__c.Year() || ( (pma.Date__c.Year() == slp.pse__End_Date__c.Year()) && (((pma.Date__c.Month() > 0 &&  pma.Date__c.Month() < 7) ? 1 : 2) <= ((slp.pse__End_Date__c.Month() > 0 && slp.pse__End_Date__c.Month() < 7) ? 1 : 2))))){
                                    pma.addError('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.');
                                }else if(!(pma.Date__c.Year() > slp.pse__Start_Date__c.Year() || ((pma.Date__c.Year() == slp.pse__Start_Date__c.Year()) && (((pma.Date__c.Month() > 0 &&  pma.Date__c.Month() < 7 ) ? 1 : 2) >= ((slp.pse__Start_Date__c.Month() > 0 && slp.pse__Start_Date__c.Month() < 7) ? 1 : 2))))){
                                    pma.addError('Service line project \'Start Date\' is in the future. Please update the service line project \'Start Date\' and try again.');
                                }
                            }else if(psaMetricMap.get(pma.PSA_Metric__c).Frequency__c == CON_PSA.PSA_METRIC_Frequency_Rolling_12){
                                //Frequency__c is Rolling_12
                                if(!(pma.Date__c.Year() <= slp.pse__End_Date__c.Year())){
                                    pma.addError('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.');
                                }else if(!(pma.Date__c.Year() >= slp.pse__Start_Date__c.Year())){
                                    pma.addError('Service line project \'Start Date\' is in the future. Please update the service line project \'Start Date\' and try again.');
                                }
                            }
                        }
                    }
                }
            }
        }
        /*end of method validateProjectMetricActualByServceLine*/
    }
    
    public static void preventDuplicateRecords(List<Project_Metric_Actual__c> newList){
        Set<Id> projectIds = new Set<Id>();
        Map<String, Project_Metric_Actual__c > mapOfRecords = new  Map<String, Project_Metric_Actual__c >();
        for( Project_Metric_Actual__c currRec : newList ){
            if( currRec.Project__c != null ){
                projectIds.add( currRec.Project__c);
                mapOfRecords.put( currRec.Project_Metric__c +'*'+ currRec.Date__c ,currRec  );
            }
        }
        for( Project_Metric_Actual__c currRec : [ SELECT Id, Project__c, Name, Date__c , Project_Metric__c 
                             FROM Project_Metric_Actual__c
                             WHERE Project__c IN : projectIds
                             ] )
        {
            if( mapOfRecords.containsKey( currRec.Project_Metric__c +'*'+ currRec.Date__c ) && mapOfRecords.get( currRec.Project_Metric__c +'*'+ currRec.Date__c ) != null ){
                if( currRec.Project_Metric__c == mapOfRecords.get( currRec.Project_Metric__c +'*'+ currRec.Date__c ).Project_Metric__c && currRec.Date__c == mapOfRecords.get( currRec.Project_Metric__c +'*'+ currRec.Date__c ).Date__c ){
                    mapOfRecords.get( currRec.Project_Metric__c +'*'+ currRec.Date__c ).addError( 'The Project Metric and month combination already exists on the Project' );
                    break;
                }
            }            
        }
    }
    /*end of class DAOH_PSA_Project_Metric_Actual*/
}
