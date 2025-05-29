//Created by: Sneha -- Helper class to fetch the PC Hierarch JSON string. Used for SalesTeam_Dashboard functionality

public class SalesTeamDashboard_PCHierarchyHelper {

    private static JSONGenerator gen; // instance of JSON generator class
    private Map<string, string> mapProfitCenters; //map holds the PC code as key and its parent region id as value
    private Map<String, List<Profit_Centre__c>> mapParentChildPC; // map holds the PC code as key and all its child PC's as child
    private Map<string, string> mapPCNameMap; // map holds the region code as key and name as value
    
    //initailise all map and data
    public SalesTeamDashboard_PCHierarchyHelper() 
    {  
        Map<Id, Profit_Centre__c> temp = new Map<Id, Profit_Centre__c>([Select id, Name, Parent_Profit_Centre__c, profitCenterCode__c, (Select id, profitCenterCode__c from Profit_Centres__r order by Sales_Dashboard_Sort_Order__c asc NULLS LAST, profitCenterCode__c asc) from Profit_Centre__c order by Sales_Dashboard_Sort_Order__c asc, profitCenterCode__c asc]);
        mapProfitCenters = new Map<String, String>();
        mapPCNameMap = new Map<String, String>();
        mapParentChildPC = new Map<String, List<Profit_Centre__c>>();
        for(Profit_Centre__c reg: temp.values())
        {
            mapProfitCenters.put(reg.profitCenterCode__c, reg.Parent_Profit_Centre__c);
            if(reg.Name != null)
                mapPCNameMap.put(reg.profitCenterCode__c, reg.Name);
            List<Profit_Centre__c> tmp = new List<Profit_Centre__c>();
            tmp.addAll(reg.Profit_Centres__r);
            if(tmp.size() > 0)
                mapParentChildPC.put(reg.profitCenterCode__c, tmp);
        }
        temp.clear();
    }  
    
    //function to create JSON from the data
    public string getHierarchyJSON(string rtPC)
    {
        gen = JSON.createGenerator(false); 
        convertNodeToJSON(createPCNode(rtPC));
        string outputJson = gen.getAsString();
        mapProfitCenters.clear();
        mapParentChildPC.clear();
        mapPCNameMap.clear();
        gen = JSON.createGenerator(false);
        return outputJson;
    }
    
    //function to create a node for the tree
    private pcNodeWrapper createPCNode(String Code) {  
        
        pcNodeWrapper node = new pcNodeWrapper();
        node.pcCode = code;
        node.pcParentCOde = mapProfitCenters.get(Code);
        node.pcName = mapPCNameMap.get(Code);
        if(mapParentChildPC.get(Code) != null)
        {
            node.hasChildPC = true;
            List<pcNodeWrapper> childNodeslst = new List<pcNodeWrapper>();
            for(Profit_Centre__c reg: mapParentChildPC.get(Code))
            {
                childNodeslst.add(createPCNode(reg.profitCenterCode__c));
            }
            node.childPCNodes = childNodeslst;
        }
        return node;
    }
  
  //converts a node to JSON string
    public void convertNodeToJSON(pcNodeWrapper objPCNodeWr){  
        gen.writeStartObject();  
        gen.writeStringField('title',objPCNodeWr.pcName);
        gen.writeStringField('key', objPCNodeWr.pcCode);  
        gen.writeBooleanField('unselectable', false);  
        gen.writeBooleanField('expand', false); 
        gen.writeBooleanField('icon', false);
        gen.writeBooleanField('noLink', true);
        if (objPCNodeWr.hasChildPC)  
        {  
            gen.writeFieldName('children');  
            gen.writeStartArray();    
                    for (pcNodeWrapper r : objPCNodeWr.childPCNodes)  
                    {  
                        convertNodeToJSON(r);  
                    }  
            gen.writeEndArray();  
        }  
        gen.writeEndObject();  
    }
    
    
    //wapper class - represents a node in the tree
    public class pcNodeWrapper
    {
        public String pcCode;  // PC code
        public String pcName;  // PC Name
        public String pcParentCOde; // pc Parent Code
        public boolean hasChildPC; //boolean set to true, if PC have child PC's else not
        public List<pcNodeWrapper> childPCNodes; // child nodes
        public pcNodeWrapper()
        {
            hasChildPC = false;
        }
    }
    

}