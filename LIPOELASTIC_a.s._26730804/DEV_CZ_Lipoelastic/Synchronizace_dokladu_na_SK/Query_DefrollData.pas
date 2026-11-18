function GetQueryDefroll(self:TNxCustomBusinessObject;Itarget:integer;mquery:string): string;
var
I:integer;
begin

                  mquery:='{'   ;
                  mquery:=mquery + '"id": "' +  Self.OID +'"'  ;
                  mquery:=mquery + ', "Code":"' +  Self.GetFieldValueAsString('Code') +'" ';
                  mquery:=mquery + ', "Name":"' +  Self.GetFieldValueAsString('Name') +'" ';
                  mquery:=mquery + ', "Hidden": '  +  BoolToStr(Self.GetFieldValueAsBoolean('Hidden')) +' ' ;

                  mquery:=mquery + ', "X_synchronizace_ID":"'  +  Self.GetFieldValueAsString('X_synchronizace_ID') +'" ' ;
                  mquery:=mquery + ', "X_EN_NAZEV":"'  +  Self.GetFieldValueAsString('X_EN_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_DE_NAZEV":"'  +  Self.GetFieldValueAsString('X_DE_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_MX_NAZEV":"'  +  Self.GetFieldValueAsString('X_MX_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_ES_NAZEV":"'  +  Self.GetFieldValueAsString('X_ES_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_IT_Nazev":"'  +  Self.GetFieldValueAsString('X_IT_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_FR_Nazev":"'  +  Self.GetFieldValueAsString('X_FR_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_NL_Nazev":"'  +  Self.GetFieldValueAsString('X_NL_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_US_Nazev":"'  +  Self.GetFieldValueAsString('X_US_Nazev') +'" ' ;
                  mquery:=mquery + ', "X_UK_NAZEV":"'  +  Self.GetFieldValueAsString('X_UK_NAZEV') +'" ' ;
                  mquery:=mquery + ', "X_amoena":"'  +  Self.GetFieldValueAsString('X_amoena') +'" ' ;
                  mquery:=mquery + ', "X_MEX_Nazev":"'  +  Self.GetFieldValueAsString('X_MEX_Nazev') +'" ' ;
//                  mquery:=mquery + ', "X_CZ_Nazev":"'  +  Self.GetFieldValueAsString('X_CZ_Nazev') +'" ' ;
//                  mquery:=mquery + ', "X_SK_Nazev":"'  +  Self.GetFieldValueAsString('X_SK_Nazev') +'" ' ;



         result:=mQuery;

end;


function GetNewQuery(self:TNxCustomBusinessObject;iTarget:integer;mTable:string;): string;
var
I:integer;
mMon:TNxCustomBusinessMonikerCollection;
mNewQueryID:string;
begin
    mNewQueryID:='{"info_type": "New_value" '
                                     +','+' "mSQL": INSERT INTO ' + mtable + ' (Code,Name,ID,Hidden,CLSID) VALUES (' +
                                            quotedstr(Self.GetFieldValueAsString('Code'))
                                            + ','+ quotedstr(Self.GetFieldValueAsString('Name'))
                                            + ','+ quotedstr(Self.OID)
                                            + ','+ quotedstr('N')
                                            + ','+ quotedstr(Self.GetFieldValueAsString('CLSID'))
                                            + ')"}';
   result:=mNewQueryID;
end;


begin
end.