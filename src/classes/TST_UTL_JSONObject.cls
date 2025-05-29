/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TST_UTL_JSONObject {

     /* **************************
     * TEST Methods to achieve required code coverage
     *   many of these could be improved by using assert() instead of debug()
     */
   public static  testmethod void test_tokener_nl() {
       Test.startTest(); 
       //add a new line by inserting /n 
        UTL_JSONObject.JsonTokener tkr = new  UTL_JSONObject.JsonTokener(
        'quoted string foo"');
        system.debug( 'next string is >'+tkr.nextString('"') );
       Test.stopTest();
    }
    public static  testmethod void test_tokener() { 
        Test.startTest();
        UTL_JSONObject.JsonTokener tkr = new  UTL_JSONObject.JsonTokener('//ff \n{}');
        tkr.nextClean();
        tkr = new  UTL_JSONObject.JsonTokener('/*fff*/\n{}');
        tkr.nextClean(); 
       tkr = new  UTL_JSONObject.JsonTokener('#ff*\n{}');
        tkr.nextClean(); 
        tkr = new  UTL_JSONObject.JsonTokener('/**ff \n{}');
        try { tkr.nextClean(); } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Unclosed comment');
        } 
        test.stopTest();
    }
    
    public static  testmethod void test_parsing() {     
        Test.startTest();
        UTL_JSONObject jj; UTL_JSONObject.JsonTokener tkr;
        string simple = '{"translatedText":  "Ciao mondo"  }';
        string bool_simple = '{"responseBoolean"  :   true }';
        string nsimple = '{"responseData"  :   {"translatedText":  "Ciao mondo"  }, "responseDetails": null, "responseStatus": 200 }';
    
        // three methods of constructing an object
        system.debug( UTL_JSONObject.instance( bool_simple   ) );
        system.debug( new UTL_JSONObject(   bool_simple ) );    
        system.debug( new UTL_JSONObject( new  UTL_JSONObject.JsonTokener(simple) ) ); 
        
        tkr = new  UTL_JSONObject.JsonTokener(nsimple);
        system.debug( tkr.more() ); 
        system.debug( tkr.next(1) );    
        system.assert( tkr.next(0) == '' ); 
        
        try { tkr.next(10000);  } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Ending position out of bounds: 10002');
        } 
        
        system.debug( tkr.next('r') );  
        
        try { tkr.next('z'); } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Expected z and instead saw e');
        } 
            
        system.debug( tkr.nextTo('e') );
        system.debug( tkr.skipTo('p') );
        system.debug( tkr.skipTo('z') );
            
        tkr = new  UTL_JSONObject.JsonTokener(nsimple);
        jj = new UTL_JSONObject( tkr);
         
        system.debug( jj.data );
        system.debug( jj.data.keySet() );
        
        system.debug( 'response status ' + jj.data.get('responseStatus') );
        system.debug( 'response status ' + jj.get('responseStatus') );
        system.debug( 'response details ' + jj.get('responseDetails') );
        
        system.debug( jj.getString('responseDetails') );
        system.assert( jj.getString('responseDetails') == null ,'expected null ');
        
        system.debug('value '+ jj.getValue('responseData') );
        
        UTL_JSONObject.value v = jj.data.get('responseData');
        system.debug( jj.getString('responseDetails') );
        system.debug( 'response data is '+ v.obj);
         
        //system.assert( v.obj.valu != null);
        system.debug( jj.data.keySet() );
         
        
        nsimple = '{"responseString"  :   "foo" }';
        tkr = new  UTL_JSONObject.JsonTokener(nsimple);
        jj = new UTL_JSONObject( tkr);
        system.debug( jj.get('responseString') );
         
        nsimple = '{"responseBoolean"  :   true }';
        tkr = new  UTL_JSONObject.JsonTokener(nsimple);
        jj = new UTL_JSONObject( tkr);
        system.debug( jj.getValue('responseBoolean') );
        system.debug( jj.optBoolean('responseBoolean') );
        
        
        try { 
        system.debug ( new UTL_JSONObject ( new UTL_JSONObject.JSONTokener( 'sdfsdf' ) ) ); 
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'A JSONObject text must begin with {');
        } 
        
        try { 
        system.debug ( new UTL_JSONObject ( new UTL_JSONObject.JSONTokener( '{"sdfsdf": true' ) ) ); 
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Expected a , or }');
        } 
        
        try { 
        system.debug ( new UTL_JSONObject ( new UTL_JSONObject.JSONTokener( '{"sdfsdf' ) ) ); 
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Unterminated string');
        } 
    
        try { 
        system.debug ( new UTL_JSONObject ( new UTL_JSONObject.JSONTokener( '{"sdfsdf": 0x009.9 }' ) ) ); 
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Invalid integer: 009.9');
        } 
    
        
        system.assert ( new UTL_JSONObject ( new UTL_JSONObject.JSONTokener( '{"sdfsdf": 009 }' ) ).getValue('sdfsdf').num == 9 ); 
         
        system.debug ( new UTL_JSONObject ( new UTL_JSONObject.JSONTokener( '{"foo": 009 }' ) ).get('foo') == 9 ); 
        
        // array testing
        system.debug ( UTL_JSONObject.jsonarray ( new UTL_JSONObject.JSONTokener( '[1,2,3]' ) )  );
        system.debug ( UTL_JSONObject.jsonarray ( new UTL_JSONObject.JSONTokener( '[1,2,3,]' ) )  );
        system.debug ( UTL_JSONObject.jsonarray ( new UTL_JSONObject.JSONTokener( '[]' ) )  );
        system.debug ( UTL_JSONObject.jsonarray ( new UTL_JSONObject.JSONTokener( '(1,2,3 )' ) )  );
        
        try { 
        system.debug ( UTL_JSONObject.jsonarray ( new UTL_JSONObject.JSONTokener( '(1,2,3 ]' ) )  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Expected a >)<');
        } 
        
        try { 
        system.debug ( UTL_JSONObject.jsonarray ( new UTL_JSONObject.JSONTokener( '1,2,3 ]' ) )  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'A JSONArray text must start with [');
        } 
    
        try { 
            system.debug ( jj.get('notfound')  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'JSONObject[notfound] not found.');
        } 
        
        system.assert( jj.keys() != null );
        system.assert( jj.length() > 0 ); 
        system.assert( jj.opt('responseBoolean') != null );
        system.assert( jj.has( 'responseBoolean') );
        try { 
            system.debug ( jj.getBoolean('notfound')  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'JSONObject[notfound] not found.');
        } 
        Test.stopTest();
    }
    
    public static  testmethod void test_valueToString() {
        Test.startTest();
        UTL_JSONObject json = new UTL_JSONObject();
        json.putOpt('foo', new UTL_JSONObject.value('bar'));
        
       /* Make sure that the JSON rendered by this class passes validation by parsers
        from http://json.org/json2.js and http://www.jsonlint.com.
        For example:    {foo: "bar"} is invalid
                        {"foo": "bar"} is valid*/
        
        system.assertEquals( '{"foo": "bar"}', json.ValuetoString());
        Test.stopTest();
    }
    
    // test that we can parse json containing a dobule 
    public static  testmethod void test_geocode() {
        Test.startTest();
        string simple = '{ "Point": { "coordinates": [ -122.0841430, 37.4219720, 0 ] } }';
        UTL_JSONObject jj =  new UTL_JSONObject( new  UTL_JSONObject.JsonTokener(simple) ) ;   
        UTL_JSONObject.value p = jj.getValue('Point');
        system.debug (p.obj.data.get('coordinates'));
        UTL_JSONObject.value[] vals = p.obj.data.get('coordinates').values;
        system.debug( vals[0].dnum);
        system.assertEquals(3,vals.size());
        system.assertEquals(-122.0841430,   vals[0].dnum);
        system.assertEquals(37.4219720,     vals[1].dnum);
        system.assertEquals('0',            vals[2].valueToString());
        Test.stopTest();
    } 
    public static  testmethod void test_g(){
        Test.startTest();
        string googlejson = '{  "name": "1600 Amphitheatre Parkway, Mountain View, CA",  "Status": {    "code": 200,    "request": "geocode"  },  "Placemark": [ {    "id": "p1",    "address": "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",    "AddressDetails": {   "Accuracy" : 8,   "Country" : {      "AdministrativeArea" : {         "AdministrativeAreaName" : "CA",         "SubAdministrativeArea" : {            "Locality" : {               "LocalityName" : "Mountain View",               "PostalCode" : {                  "PostalCodeNumber" : "94043"               },               "Thoroughfare" : {                  "ThoroughfareName" : "1600 Amphitheatre Pkwy"               }            },         '+
        '   "SubAdministrativeAreaName" : "Santa Clara"         }      },      "CountryName" : "USA",      "CountryNameCode" : "US"   }},    "ExtendedData": {      "LatLonBox": {        "north": 37.4251466,        "south": 37.4188514,        "east": -122.0811574,        "west": -122.0874526      }    },    "Point": {      "coordinates": [ -122.0843700, 37.4217590, 0 ]    }  } ]}   ';
        UTL_JSONObject jj = new UTL_JSONObject( new  UTL_JSONObject.JsonTokener(googlejson)  );    
        system.assertNotEquals(null,jj);
        Test.stopTest();
    }
    
    public static testmethod void testJson3(){
        Test.startTest();
        /*string simple = '{ outerRecords : { outerRec : [ {'+
                            'id : a1CQ0000000oyFIMAY'+
                            'oppNum : 386231'+
                            'accName : Anjali Test Acct'+
                            'acc_Id : 001Q000000DfKTpIAN'+
                            'innerRecords : ['+
                            '{Id : kkssks'+
                            'Total : 675 },'+
                            '{Id : kkssksweree'+
                            'Total : 675232 }'+
                            ']'+
                        '}]}}';*/
        string simple = '{ outerRec :  [{'+
                            'id : "a1CQ0000000oyFIMAY",'+
                            'oppNum : 386231,'+
                            'accName : "Anjali Test Acct",'+
                            'acc_Id : "001Q000000DfKTpIAN",'+
                            'innerRecords : ['+
                            '{Id : "kkssks",'+
                            'Total : 675 }'+
                            ']}, {'+
                            'id : "a1",'+
                            'oppNum : 386231,'+
                            'accName : "Anjali Test Acct",'+
                            'acc_Id : "001Q000000DfKTpIAN",'+
                            'innerRecords : []'+
                            '}]}';              
        UTL_JSONObject jj =  new UTL_JSONObject( new  UTL_JSONObject.JsonTokener(simple) ) ;   
        UTL_JSONObject.value[] p = jj.getValue('outerRec').values;
        for(Integer i =0;  i<p.size(); i++)
        {
            system.debug ('Id###'+p[i].obj.data.get('id').valueToString());
            system.debug ('oppNum###'+p[i].obj.data.get('oppNum').valueToString());
            system.debug ('accName###'+p[i].obj.data.get('accName').valueToString());
            system.debug ('acc_Id###'+p[i].obj.data.get('acc_Id').valueToString());
            UTL_JSONObject.value[] innerRecords = p[i].obj.data.get('innerRecords').values;
            System.debug ('Count###'+innerRecords.size());
            for(Integer innerCount = 0;  innerCount<innerRecords.size(); innerCount++)
            {
                system.debug ('Id###'+innerRecords[innerCount].obj.data.get('Id').valueToString());
                system.debug ('Total###'+innerRecords[innerCount].obj.data.get('Total').valueToString());
            }
        }
        //system.debug ('Id###'+p[0].obj.data.get('innerRecords').Values[0].obj.data.get('Total').valueToString());
    	Test.stopTest();       
    }
    
}