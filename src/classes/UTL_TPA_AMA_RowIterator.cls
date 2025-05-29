/**
 * Author: Sunny Bansal
 * Since: December 17, 2015
 * Name: AMA_Utility_RowIterator
 * Description: Class to iterate csv file data and split each row by any given delimiter
**/
public with sharing class UTL_TPA_AMA_RowIterator implements Iterator<String>, Iterable<String> {

    private String fileData;
    private Integer index = 0;
    private String rowDelimiter = '\n';
  
    public UTL_TPA_AMA_RowIterator(String givenFileData, String givenRowDelimiter, String alternateRowDelimiter) {
        fileData = givenFileData;
        rowDelimiter = givenRowDelimiter;
        Integer rowDelimiterIndex = fileData.indexOf(rowDelimiter, index);
        if (rowDelimiterIndex == -1) {
            Integer alternateDelimiterIndex = fileData.indexOf(alternateRowDelimiter, index);
            if(alternateDelimiterIndex != -1) {
                rowDelimiter = alternateRowDelimiter;
            }
        }
    }

    public Boolean hasNext() {
        return index < fileData.length() ? true : false;
    }

    public String next() {
        Integer rowDelimiterIndex = fileData.indexOf(rowDelimiter, index);

        if (rowDelimiterIndex == -1)
            rowDelimiterIndex = fileData.length();

        String row = fileData.subString(index, rowDelimiterIndex);
        //Code to check if this is the row containing LEGEND data that is not required by system starts
        Integer tempRowDelimiterIndex = rowDelimiterIndex;
        Integer tempIndex = index;
        if(row.contains('LEGEND')) {
            tempIndex = tempRowDelimiterIndex + 1;
            while(tempIndex < fileData.length() ? true : false) {
                tempRowDelimiterIndex = fileData.indexOf(rowDelimiter, tempIndex);
                if (tempRowDelimiterIndex == -1) {
                    tempRowDelimiterIndex = fileData.length();
                }
                String tempRow = fileData.subString(tempIndex, tempRowDelimiterIndex);
                tempIndex = tempRowDelimiterIndex + 1;
                tempRow = tempRow.trim();
                if(String.isBlank(tempRow) || tempRow.split(',').size() == 0) {
                    continue;
                } else if(tempRow.contains('DATABASE LICENSEES')) {
                    return 'File Ended';
                } else {
                    break;
                }
            }
        }
        //ends
        index = rowDelimiterIndex + 1;
        return row;
    }

    public Iterator<String> Iterator() {
        return this;
    }
}