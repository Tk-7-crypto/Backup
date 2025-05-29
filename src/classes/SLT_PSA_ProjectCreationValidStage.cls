public class SLT_PSA_ProjectCreationValidStage extends fflib_SObjectSelector {

    public SLT_PSA_ProjectCreationValidStage() {
        super(false, true, true);
    }

    public SLT_PSA_ProjectCreationValidStage(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    public Schema.SObjectType getSObjectType(){
        return PSA_ProjectCreationValidStage__mdt.sObjectType;
    }

    /**
     * This method will return the complete listing with all entries and fields
     */
    public List<PSA_ProjectCreationValidStage__mdt> selectAllStages(){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(getFields()).toSOQL();
        List<PSA_ProjectCreationValidStage__mdt> listing = (List<PSA_ProjectCreationValidStage__mdt>) Database.query(queryString);
        return listing;
    }

    /**
     * Get a list of all the Stages in the metadata listing
     */
    public List<String> selectValidStages(){
        List<String> stages = new List<String>();
        for(PSA_ProjectCreationValidStage__mdt stage : selectAllStages()){
            stages.add(stage.Stage__c);
        }
        return stages;
    }

    public Set<String> getFields(){
        return new Set<String>{'Stage__c'};
    }
}