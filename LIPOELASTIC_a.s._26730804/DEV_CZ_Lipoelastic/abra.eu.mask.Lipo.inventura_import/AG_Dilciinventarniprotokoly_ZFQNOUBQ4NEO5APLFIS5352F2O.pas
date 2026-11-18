uses 'abra.eu.mask.Lipo.inventura_import.Rows_RO',
     'abra.eu.mask.Lipo.inventura_import.fce'
;

const
    mFilter='*.xml';





procedure FormCreate_Hook(Self: TSiteForm);
var
mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  mAct: TBasicAction;
  i:integer;
begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import z XML';
          mMAction.Caption := 'Import z XML ';
          mMAction.Items.Add('Import z XML bez šarží');
          mMAction.Items.Add('Import z XML s šaržemi');
          mMAction.Category := 'tabRows';
          mMAction.OnExecuteItem := @OnExec;


end;



procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile,mpathTarget:string;
  mr:TStringList;
  mresult:boolean;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
   if index=0 then  begin



        if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', '', False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
          mresult:=Import_Rows_RO(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false,index);
          if mresult then begin
             //mresult:=nxcopyfile(mFileName,mdir + '\Zpracovane\' + mFileName);
                                                if mresult then begin
                                                    //DeleteFile(mFileName);

                                                end;
          end;
        end;
   end;

end;












begin
end.
