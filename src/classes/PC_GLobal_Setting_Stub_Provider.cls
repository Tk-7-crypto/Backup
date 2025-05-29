public class PC_GLobal_Setting_Stub_Provider extends SoqlStubProvider{
    private Integer size;
    private String BU;
    
    public PC_GLobal_Setting_Stub_Provider(Integer size, String BU ){
        this.size = size;
        this.BU = BU;
        
    }
    
    public override List<SObject> handleSoqlQuery(SObjectType sObjectType, String rawQuery, Map<String, Object> binds) {
        Map<String, Object> dynamicMap = new Map<String, Object>();
        List<SObject> objs = new List<SObject>();
        for(Integer i=1; i<=size; i++){
            String uuid = UUId.randomUUID().toString();
            dynamicMap.put('Id', uuid);
            dynamicMap.put('Name__c', 'Q_111813');
            dynamicMap.put('Cegedim_BUs_c__c', BU );
            Sobject singleRecord = Test.createStubQueryRow(sObjectType, dynamicMap);
            objs.add(singleRecord);
        }
        return objs;
    }
}