//  Class to calculate the production reference for each line item
//  The reference is created by taking the total number of elapsed minutes
//  in the current year and converting this to a base-34 radix using the numbers
//  1-9 (excluding 0) and letters A-Z (excluding O)
public class CLS_ProductionReference {

public String ConvertToRadix34(Integer iDecimalInput)
{
    if (iDecimalInput >= 1336336)
    {
        Exception E;
        E.setMessage('Input number too large to be converted to 4 character base 34 representation');
        throw E;
    }
    List<String> Symbol_Array = new List<String>{'1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z'};
    String sReturn = '';
    Integer iRemainder; 
    Integer iQuotient = iDecimalInput;
    for (Integer i=0;i<4;i++)
    { 
        iRemainder = math.mod(iQuotient,34);
        iQuotient = (math.floor(iQuotient/34)).intValue();
        sReturn = Symbol_Array.get(iRemainder) + sReturn;
    }
    return sReturn;
} 

public Integer CalculateElapsedMinsThisYear() 
{
    datetime CurrentDateTime = datetime.now();
    Long lMilliSeconds = CurrentDateTime.getTime();
    Integer iMinutesElapsedThisYear = (CurrentDateTime.dayOfYearGmt()-1)*24*60 + (CurrentDateTime.hourGmt()-1)*60 + CurrentDateTime.minuteGmt();
    return iMinutesElapsedThisYear;
}

}