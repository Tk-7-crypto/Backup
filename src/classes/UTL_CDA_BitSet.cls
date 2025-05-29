/**
 * @Author: Babita Dadarwal
 * @Description: Apex class for decode the bit set for validFor. 
 */
public class UTL_CDA_BitSet {
	public static List<Integer> B64ToBytes (String inputString) {
        Map<Integer,Integer> base64 = new Map<Integer,Integer> {
            	65=>0, 
                66=>1,
                67=>2,
                68=>3,
                69=>4,
                70=>5,
                71=>6,
                72=>7,
                73=>8,
                74=>9,
                75=>10,
                76=>11,
                77=>12,
                78=>13,
                79=>14,
                80=>15,
                81=>16,
                82=>17,
                83=>18,
                84=>19,
                85=>20,
                86=>21,
                87=>22,
                88=>23,
                89=>24,
                90=>25,
                97=>26,
                98=>27,
                99=>28,
                100=>29,
                101=>30,
                102=>31,
                103=>32,
                104=>33,
                105=>34,
                106=>35,
                107=>36,
                108=>37,
                109=>38,
                110=>39,
                111=>40,
                112=>41,
                113=>42,
                114=>43,
                115=>44,
                116=>45,
                117=>46,
                118=>47,
                119=>48,
                120=>49,
                121=>50,
                122=>51,
                48=>52,
                49=>53,
                50=>54,
                51=>55,
                52=>56,
                53=>57,
                54=>58,
                55=>59,
                56=>60,
                57=>61,
                43=>62,
                47=>63 };

        List<Integer> lstOut = new List<Integer>();
        if(inputString == null || inputString == '') {
            return lstOut;
        } 
        
        inputString += '='.repeat( 4 - Math.mod( inputString.length(), 4) );

        for(Integer idx=0; idx < inputString.length(); idx += 4) {
            if(base64.get(inputString.charAt(idx+1)) != null) {
                lstOut.add( (base64.get(inputString.charAt(idx)) << 2) | (base64.get(inputString.charAt(idx+1)) >>> 4) );
            }
            if(base64.get(inputString.charAt(idx+2)) != null) {
                lstOut.add( ((base64.get(inputString.charAt(idx+1)) & 15)<<4) | (base64.get(inputString.charAt(idx+2)) >>> 2) );
            }
            if(base64.get(inputString.charAt(idx+3)) != null) {
                lstOut.add(((base64.get(inputString.charAt(idx+2)) & 3)<<6) | base64.get(inputString.charAt(idx+3)));
            }
        }
        return lstOut;
    }
    
    public static List<Integer> BlobToBytes (Blob input) {
        return B64ToBytes(EncodingUtil.base64Encode(input));
    }
    
    /**
     * Converts a base64 string into a list of integers indicating at which position the bits are on
     */
    public static List<Integer> cnvBits(String b64Str) {
        List<Integer> lstOut = new List<Integer>();
        if(b64Str == null || b64Str == '') {
            return lstOut;
        }
        
        List<Integer> lstBytes = B64ToBytes(b64Str);

        Integer index1, index2, value;
        for(index1 = 0; index1 < lstBytes.size(); index1++) {
            value = lstBytes[index1];
            for(index2 = 1; index2 <= 8; index2++) {
                if(( value & 128 ) == 128) {
                    lstOut.add( (index1*8) + index2 );
                }
                value <<= 1;
            }
        }		
        return lstOut;
    }
    
    public class PicklistEntry {
        public string active { get;set; }
        public string defaultValue { get;set; }
        public string label { get;set; }
        public string value { get;set; }
        public string validFor { get;set; }
        public PicklistEntry() {}
    }
    
    /**
     * @return : Map<String, List<String>>,  Key: controller Picklist Value, Value: dependent picklist values
     */
    public static Map<String,List<String>> getDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName) {
        Map<String,List<String>> mapResults = new Map<String,List<String>>();
        
        Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
        if(pType == null ) {
            return mapResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

        if(!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) {
            return mapResults;     
        }
        
        //get the controller & dependent picklist values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

        //clear heap
        objFieldMap = null;

        //initialize results mapping
        for(Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++) {           
            mapResults.put( ctrl_ple[pControllingIndex].getLabel(), new List<String>());
        }
        
        //serialize dependent picklist entries        
        List<PicklistEntry> objDS_Entries = (List<PicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<PicklistEntry>.class);

        List<Integer> validIndexes;
        for (PicklistEntry objDepPLE : objDS_Entries) {
            validIndexes = cnvBits(objDepPLE.validFor);
            
            for(Integer validIndex : validIndexes) {
                mapResults.get(ctrl_ple[validIndex-1].getLabel()).add(objDepPLE.label);
            }
        }

        //clear heap
        objDS_Entries = null;

        return mapResults;
    }
}