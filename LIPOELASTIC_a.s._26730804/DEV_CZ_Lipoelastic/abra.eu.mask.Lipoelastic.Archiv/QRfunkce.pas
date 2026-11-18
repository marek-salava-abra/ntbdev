uses 'abra.eu.mask.Lipoelastic.Archiv.lib';


function mBAse64(mCustomBusinessObject:TNxCustomBusinessObject):String;
var
  adir,mfilename:string;
  mOutputList:tstringlist;
begin
  adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                           mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                           mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                           ]);
                          //NxShowSimpleMessage(adir+'\'+mfilename+'.pdf',nil);
                          mOutputList:=tstringlist.create;
                          try
                             if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje
                                mOutputList.Clear;
                                mOutputList.LoadFromFile(mFileName);
                                Result:=EncodeBase64(getfiletobytes(mFileName));
                             end;

                          finally
                              mOutputList.free;
                          end;
end;

function GetFileToBytes(AFileName: String;): TBytes;
var
  mMS: TMemoryStream;
  mStr: string;
begin
  mMS := TMemoryStream.Create();
  try
    mMS.LoadFromFile(AFileName);
    Result := mMS.GetBytes;
  finally
    mMS.Free;
  end;
end;



begin
end.