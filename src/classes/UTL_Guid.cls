/*
 * Version       : 1.0
 * Description   : Apex class class for get Global unique id. 
 */ 
public class UTL_Guid { 

    private static String kHexChars = '0123456789abcdef';
    
    /**
     * This method used for generation of Global unique id.
     */ 
    public static String newGuid(){
        String returnValue = '';
        Integer nextByte = 0;
        for(Integer i=0; i<16; i++){
            if(i==4 || i==6 || i==8 || i==10){
              returnValue += '-';
            }
            nextByte = (Math.round(Math.random() * 255)-128) & 255;
            if(i==6){
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            } 
            if(i==8){
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }
        return returnValue;
    }
    
    /**
     * This method used for get character from any String at particular index.
     */ 
    public static String getCharAtIndex(String str, Integer index){
        if(str == null) return null;
        if(str.length() <= 0) return str;    
        if(index == str.length()) return null;    
        return str.substring(index, index+1);
    }
    
    public static string Guid {
        get {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            return h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        }
    }
}