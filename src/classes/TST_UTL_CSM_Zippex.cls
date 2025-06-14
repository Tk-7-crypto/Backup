//
//Copyright (c) 2015 Pedro Dal Col, Pliny Smith
//
@isTest
private class TST_UTL_CSM_Zippex 
{
    @isTest static void testUTL_CSM_Hex() 
    {

        String testData = 'This is a test';  //test data
        Integer expectedCRC32 = (Integer)(3229261618L);
        System.assertEquals(UTL_CSM_Hex.CRC32Table(Blob.valueOf(testData)) , expectedCRC32);
        System.assertEquals(UTL_CSM_Hex.CRC32Table(EncodingUtil.convertToHex(Blob.valueOf(testData))) , expectedCRC32);

        testData = 'test two';
        expectedCRC32 = 1542186603;
        System.assertEquals(UTL_CSM_Hex.CRC32Table(Blob.valueOf(testData)) , expectedCRC32);
        System.assertEquals(UTL_CSM_Hex.CRC32Table(EncodingUtil.convertToHex(Blob.valueOf(testData))) , expectedCRC32);

        testData = '';
        expectedCRC32 = 0;
        System.assertEquals(UTL_CSM_Hex.CRC32Table(Blob.valueOf(testData)) , expectedCRC32);
        System.assertEquals(UTL_CSM_Hex.CRC32Table(EncodingUtil.convertToHex(Blob.valueOf(testData))) , expectedCRC32);

        // public static Integer hexToIntLE(String hexString)
        System.assertEquals(UTL_CSM_Hex.hexToIntLE('ffffffff'),(Integer)(4294967295L));
        System.assertEquals(UTL_CSM_Hex.hexToIntLE('feffffff'),(Integer)(4294967294L));
        System.assertEquals(UTL_CSM_Hex.hexToIntLE('ffffff7f'),(Integer)(2147483647 ));
        System.assertEquals(UTL_CSM_Hex.hexToIntLE('00000080'),(Integer)(2147483648L));
        System.assertEquals(UTL_CSM_Hex.hexToIntLE('00000000'),0);

        // public static String intToHexLE(Integer decNumber, Integer sizeInBytes)
        System.assertEquals(UTL_CSM_Hex.intToHexLE((Integer)(4294967295L),4),'ffffffff');
        System.assertEquals(UTL_CSM_Hex.intToHexLE((Integer)(4294967294L),4),'feffffff');
        System.assertEquals(UTL_CSM_Hex.intToHexLE((Integer)(2147483647 ),4),'ffffff7f');
        System.assertEquals(UTL_CSM_Hex.intToHexLE((Integer)(2147483648L),4),'00000080');
        System.assertEquals(UTL_CSM_Hex.intToHexLE(0,4),'00000000');
        System.assertEquals(UTL_CSM_Hex.intToHexLE(878678,4),'56680d00');
        System.assertEquals(UTL_CSM_Hex.intToHexLE(878678,2),'5668');
        System.assertEquals(UTL_CSM_Hex.intToHexLE(878678,0),'');

    }
    
    @isTest static void zipTest() 
    {
        Blob tinyZip = EncodingUtil.convertFromHex('504B030414000800080096BC7A4700000000000000000000000008001000746578742E74787455580C0055EC5756ECEB5756262ABF22F3C8E40200504B07089A3C22D50500000003000000504B0102150314000800080096BC7A479A3C22D5050000000300000008000C000000000000000040A48100000000746578742E7478745558080055EC5756ECEB5756504B05060000000001000100420000004B0000000000');
        UTL_CSM_Zippex testZippex = new UTL_CSM_Zippex(tinyZip);
        System.assert(testZippex.containsFile('text.txt'));
        System.assertEquals(testZippex.getFileNames(), new Set<String>{'text.txt'});
        System.assertEquals(testZippex.getFile('text.txt').toString(), 'Hi\n');
        
        testZippex.addFile('newDir/added.txt',Blob.valueOf('new data\n'), null);
        System.assertEquals(testZippex.getFileNames(), new Set<String>{'text.txt','newDir/added.txt'});
        System.assertEquals(testZippex.getFile('newDir/added.txt').toString(), 'new data\n');
        
        testZippex.renameFile('text.txt','newDir/changedName.txt');
        System.assertEquals(testZippex.getFileNames(), new Set<String>{'newDir/changedName.txt','newDir/added.txt'});
        
        testZippex.removePrefix('newDir/');
        System.assert(!testZippex.containsFile('text.txt'));
        System.assert(!testZippex.containsFile('newDir/added.txt'));
        System.assert(testZippex.containsFile('changedName.txt'));
        System.assert(testZippex.containsFile('added.txt'));

        testZippex.addFile('added.txt',Blob.valueOf('even newer data\n'), null);
        System.assertEquals(testZippex.getFileNames(), new Set<String>{'changedName.txt','added.txt'});
        System.assertEquals(testZippex.getFile('added.txt').toString(), 'even newer data\n');
        
        testZippex.removeFile('notHere.txt');
        System.assertEquals(testZippex.getFileNames(), new Set<String>{'changedName.txt','added.txt'});

        testZippex.addFile('secondAdd.txt',Blob.valueOf('important\n'), null);
        testZippex.addFile('thirdAdd.txt',Blob.valueOf('less important\n'), null);
        testZippex.removeFile('changedName.txt');
        System.assert(!testZippex.containsFile('changedName.txt'));
        System.assertEquals(testZippex.getFileNames(), new Set<String>{'added.txt','secondAdd.txt', 'thirdAdd.txt'});

        Blob newTinyZip = testZippex.getZipArchive();
        UTL_CSM_Zippex newTestZippex = new UTL_CSM_Zippex(newTinyZip);
        System.assertEquals(newTestZippex.getFileNames(), new Set<String>{'added.txt','secondAdd.txt', 'thirdAdd.txt'});
        System.assertEquals(testZippex.getFile('added.txt').toString(), 'even newer data\n');
        
        newTestZippex.removeFile('added.txt');
        System.assertEquals(newTestZippex.getFileNames(), new Set<String>{'secondAdd.txt', 'thirdAdd.txt'});

        Try {
            Lead l = new Lead(LastName='Test', Company='Test');
            insert l;

            Attachment att = new Attachment(
                Name = 'archive.zip',
                Body = tinyZip,
                ParentId = l.Id);
            insert att;
            
            Test.StartTest();
            UTL_CSM_Zippex.unzipAttachment(att.Id, null, null, true);
            Test.stopTest();
            
            Attachment[] atts = [SELECT Id FROM Attachment];
            
            System.assertEquals(atts.size(), 2);
        }
        catch(Exception e){}
    }

    @isTest static void puffTest() 
    {
        String source='CB48CD29C840C25C00';
        Integer srclen = source.length()/2;
        System.assertEquals('helphelphelphelp\n', EncodingUtil.convertFromHex(new UTL_CSM_Puff(source, srclen, null).inflate()).toString());

        source='F3C8E40200';
        srclen = source.length()/2;
        System.assertEquals('Hi\n', EncodingUtil.convertFromHex(new UTL_CSM_Puff(source, srclen, null).inflate()).toString());

        source='01050099996562616670';
        srclen = source.length()/2;
        System.assertEquals('ebafp', EncodingUtil.convertFromHex(new UTL_CSM_Puff(source, srclen, null).inflate()).toString());

        source='8cd0514bc3301007f077c1ef50f2bea6952152d60e4126be0c61fa01d2f4da06935cc8658bfbf6de3615c497bde5b8dc8fbbff6afde96c718048067d2beab21205788d83f1532bdedf368b075150527e50163db4e20824d6ddedcd2a3719fa1da4c43fa960c553e3742be694422325e9199ca21203786e8e189d4a5cc6493a153ff661a1d105954c6fac4947795755f7e29b89d728388e46c313eabd039fcef3328265113dcd26d08f96afd132c62144d440c4f7387bf19c32fe97a997ff20677444c231957c8cbc6c244f148fd7d5f9e5ac289c6e5e268f51f59613ccf552741c9fb216f3ebf6599e8a01b79876ea008fb4e3052c6c8c05eec83f31775f000000ffff0300';
        srclen = source.length()/2;
        System.assertEquals('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\r\n<w:webSettings xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" mc:Ignorable="w14"><w:allowPNG/><w:doNotSaveAsSingleFile/></w:webSettings>',
            EncodingUtil.convertFromHex(new UTL_CSM_Puff(source, srclen, null).inflate()).toString());

    }
}