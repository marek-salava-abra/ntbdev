const
    //číselník licencí
    Class_REST_License = 'RV5F5HCAZ41OD0QWKMGRZI0VD0';

    //heslo pro generovani
    cGenPassword = 'GenFlo898';

    //nazev souboru s licenci
    cLicenceFileName = 'licence.key';

    // oddelovac
    cSeparator = ';';
    
    //typy licencí
    cLicenseType = [
      '0 - FLORES on-line sklad'
    ];

    //U-pole
    cRESTLicense_GUID = 2000002;
    cRESTLicense_HASH = 2000003;
    cRESTLicense_LicenceType = 2000001;

    cRESTLicenseCheck  = 'select '+
                         '  u1.stringfieldvalue "GUID", ' +
                         '	u2.STRINGFIELDVALUE "HASH"  ' +
                         'from DefRollData D ' +
                         'join UserData U1 on U1.CLSID = D.CLSID and U1.ID = D.ID and U1.FieldCode = ' + IntToStr(cRESTLicense_GUID) +
                         'join UserData U2 on U2.CLSID = D.CLSID and U2.ID = D.ID and U2.FieldCode = ' +  IntToStr(cRESTLicense_HASH) +
                         'where ' +
                         '  D.CLSID = ' + QuotedStr(Class_REST_License) +
                         '  and U1.StringFieldValue = ''%s'' '+
                         ' Group by ' +
                         '   U1.StringFieldValue, U2.StringFieldValue '
                         ;
    cRESTLicenseCount ='select count(*) ' +
                        ' from UserData UD ' +
                        ' where ' +
                        '   UD.CLSID = ' + QuotedStr(Class_REST_License) +
                        '   and UD.FieldCode = ' + IntToStr(cRESTLicense_HASH)
                        ;

begin
end.