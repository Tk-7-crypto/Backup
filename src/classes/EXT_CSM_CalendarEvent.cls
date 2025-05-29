public class EXT_CSM_CalendarEvent {
    
    public static Blob ext_GenerateEvent(String recepient, String summary, String description, Datetime startDate, Datetime endDate, String uniqueId, Integer seqNr) {
    // Build date strings
        String startDateString = '';
        String midData = '';
        startDateString += startDate.yearGmt();
        String sMonth = String.valueOf(startDate.monthGmt());
        Integer lenMonth = sMonth.length();
        if (lenMonth == 1) {
            startDateString += ('0' + sMonth);
        }
        else {
            startDateString += (sMonth);
        }
        String sDate = String.valueOf(startDate.dayGmt());
        if (sDate.length()==1) {
            startDateString += ('0' + sDate);
        }
        else {
            startDateString += (sDate);
        }
        startDateString += 'T';
        midData = midData + startDateString;
        String sHour = String.valueOf(startDate.hourGmt());
        if (sHour.length()==1) {
            startDateString += ('0' + sHour);
        }
        else {
            startDateString += (sHour);
        }
    
        String sMin = String.valueOf(startDate.minuteGmt());
        if (sMin.length()==1) {
            startDateString += ('0' + sMin);
        }
        else {
            startDateString += (sMin);
        }
    
        String sSec = String.valueOf(startDate.secondGmt());
        if (sSec.length()==1) {
            startDateString += ('0' + sSec);
        }
        else {
            startDateString += (sSec);
        }
        startDateString += 'Z';
        String endDateString = '';
        endDateString = endDateString + midData;
        String eHour = String.valueOf(endDate.hourGmt());
        if (eHour.length()==1) {
            endDateString += ('0' + eHour);
        }
        else {
            endDateString += (eHour);
        }  
        String eMin = String.valueOf(endDate.minuteGmt());
        if (eMin.length()==1) {
            endDateString += ('0' + eMin);
        }
        else {
            endDateString += (eMin);
        }
        String eSec = String.valueOf(endDate.secondGmt());
        if (eSec.length()==1) {
            endDateString += ('0' + eSec);
        }
        else {
            endDateString += (eSec);
        }
        endDateString += 'Z'; 
        String nowString = '';
        Datetime nowDT = Datetime.now();
        nowString += nowDT.year();
        nowString += ('0' + nowDT.month()).right(2);
        nowString += ('0' + nowDT.day()).right(2);
        nowString += 'T';
        nowString += ('0' + nowDT.hour()).right(2);
        nowString += ('0' + nowDT.minute()).right(2);
        nowString += ('0' + nowDT.second()).right(2);
        nowString += 'Z';

    // Generate actual body
        String txtInvite = '';
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Google Inc//Google Calendar 70.9054//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'CALSCALE:GREGORIAN\n';
        txtInvite += 'METHOD:REQUEST\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'DTSTART:'+startDateString+'\n';
        txtInvite += 'DTEND:'+endDateString+'\n';
        txtInvite += 'DTSTAMP:20180925T092609Z\n';
        txtInvite += 'ORGANIZER;CN=' + UserInfo.getUserName() + ':MAILTO:' + UserInfo.getUserEmail() + '\n';
        txtInvite += 'UID:' + uniqueId + '\n';
        txtInvite += 'ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=\n';
        txtInvite += ' TRUE;X-NUM-GUESTS=0:mailto:' + recepient + '\n';
        txtInvite += 'CREATED:' + nowString + '\n';
        txtInvite += 'DESCRIPTION:' + description + '\n';
        txtInvite += 'LAST-MODIFIED:' + nowString + '\n';
        txtInvite += 'LOCATION:Online\n';
        if (seqNr != null) {
            txtInvite += 'SEQUENCE:' + seqNr + '\n';
        }
        txtInvite += 'STATUS:CONFIRMED\n';
        txtInvite += 'SUMMARY:' + summary + '\n';
        txtInvite += 'TRANSP:transparent\n';
        txtInvite += 'BEGIN:VALARM\n';
        //txtInvite += 'TRIGGER:PT1D\n';
        txtInvite += 'TRIGGER:-PT15M\n';
        txtInvite += 'ACTION:DISPLAY\n';
        txtInvite += 'DESCRIPTION:Reminder\n';
        txtInvite += 'END:VALARM\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR\n';

        return Blob.valueOf(txtInvite);
    }
}