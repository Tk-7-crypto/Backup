public class Cal_BNF_Metric_ProcessingTime {
    
    public static Integer daysOff(Datetime sdate, Datetime edate,integer GMTTimeShift)
    {
        Integer iCount = 0;
        
        while (sdate <= edate) 
        {
            if (sdate.addSeconds(GMTTimeShift).formatGMT('E') == 'Sat' || sdate.addSeconds(GMTTimeShift).formatGMT('E') == 'Sun')
            {
                iCount = iCount + 1;
            }
            sdate = sdate.addDays(1);
        }
        return iCount;
    }

    public static double getDifferenceInSeconds(datetime firstDT, datetime secondDT){  
       long dt1 = firstDT.getTime() / 1000;  //getTime gives us milliseconds, so divide by 1000 for seconds  
       long dt2 = secondDT.getTime() / 1000;
       double d = dt1 - dt2;
       return d;
    }
    
    public static Double CalculateWorkingHoursBetween(Datetime EndDateGMT,Datetime StartDateGMT,Integer GMTTimeShift_Milliseconds)
    {
        Double processingtime=0.0;
        
        if(EndDateGMT!=null && StartDateGMT!=null)
        {
           
            
            Integer GMTTimeShift=GMTTimeShift_Milliseconds/1000;
                      
            If  (StartDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sat' || StartDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sun')
            {
            
                if(StartDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sat')
                    StartDateGMT= StartDateGMT.addSeconds(GMTTimeShift).adddays(2);
                
                if(StartDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sun')
                    StartDateGMT= StartDateGMT.addSeconds(GMTTimeShift).adddays(1);
                    
                StartDateGMT=Datetime.newInstanceGMT(StartDateGMT.yearGmt(),StartDateGMT.monthGmt(),StartDateGMT.dayGmt(),0,0,0);
                
                StartDateGMT=StartDateGMT.addSeconds(-GMTTimeShift); 
            }
         
            if  (EndDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sat' || EndDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sun')
            {
                if(EndDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sat')
                    EndDateGMT= EndDateGMT.addSeconds(GMTTimeShift).adddays(2);
                
                if(EndDateGMT.addSeconds(GMTTimeShift).formatGMT('E') == 'Sun')
                    EndDateGMT= EndDateGMT.addSeconds(GMTTimeShift).adddays(1);

               EndDateGMT=Datetime.newInstanceGMT(EndDateGMT.yearGmt(),EndDateGMT.monthGmt(),EndDateGMT.dayGmt(),0,0,0);
               
               EndDateGMT=EndDateGMT.addSeconds(-GMTTimeShift); 
            }
            
            system.debug('********adjusted dates*******************'+EndDateGMT + '*******************'+StartDateGMT);
            integer totaldaysoff = daysOff(StartDateGMT,EndDateGMT,GMTTimeShift);
            
           system.debug('*********days off*********************'+ totaldaysoff);
            
            Double TimeDiff=getDifferenceInSeconds(EndDateGMT,StartDateGMT);
            if(totaldaysoff>0 && TimeDiff>0)
            {
                processingtime=((TimeDiff - (totaldaysoff*86400)) / 3600);
            }
            else
                processingtime=(TimeDiff / 3600);
     
            system.debug('*********processing time**********************'+ Decimal.valueof(processingtime).setScale(2));
            return Decimal.valueof(processingtime).setScale(2); 
        
        
        }
        else
        {
            return processingtime;
        
        }
        
        
    }
    
    
    

}