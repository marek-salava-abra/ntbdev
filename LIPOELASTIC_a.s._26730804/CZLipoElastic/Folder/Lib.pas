uses '_Knihovny_ALL.Progress';
function GetOrCreativeDirAndFilles(mConstDir:string;mNewDir:string;mDirVzor:string):boolean;
var
mResult:boolean;
mFileList:TStringList;
i:integer;
mFile,mFileName:string;
mBoolean:boolean;
begin

if mNewDir<>'' then begin
    if DirectoryExists(mConstDir)  then begin   // uloziste je pristupne
                  mResult:=DirectoryExists(Format('%s\%s', [mConstDir, mNewDir]));
              if  not mresult then begin    // servisovaný objekt
                    mResult:=NxCreateDir(Format('%s\%s', [mConstDir, mNewDir]));
              end else begin
              end;
    end;

    if not (mDirVzor='') then begin
        mFileList:=TStringList.create;
        //NxShowSimpleMessage('AAA',nil);
        try
                NxGetFileList(mDirVzor,mfilelist,'*.*',false);
                                //NxShowSimpleMessage('BBB',nil);
                                for i:=0 to mFileList.count-1 do begin
                                //NxShowSimpleMessage('CCC',nil);
                                     mfile:='';
                                     mFile:=copy(mFileList.Strings[i],1+NxCharPosR('\',mFileList.Strings[i]),Length(mFileList.Strings[i]));
                                     if (Trim(mfile)<>'') and (trim(mfile)<>'.') and (trim(mfile)<>'..')then  begin
                                     mfilename:=mDirVzor+'\' + mfile;
                                           if not FileExists(Format('%s\%s\', [mConstDir,mNewDir])+mfile) then begin
                                              mresult:= NxCopyFile(mfilename, Format('%s\%s\', [mConstDir,mNewDir])+mfile);
                                              mBoolean:=InputQuery('','', Format('%s\%s\', [mConstDir,mNewDir])+mfile);
                                           end;
                                      end;
                                end;
        finally
            mFileList.free;

        end;









    end;

end;

result:=true;
end;


begin
end.
