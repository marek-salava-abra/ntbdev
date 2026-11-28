
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import vsb';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mSM, mFirmBO, mbankBO, mSupplierBO, mSCBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mUnit:TNxCustomBusinessObject;
 mList:TStringList;
 mImageFile:string;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mStoreCard_ID, mParent_ID, mSupplier_ID, mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mXMlHead:TNxScriptingXMLWrapper;
 AStream:TMemoryStream;
 mCode, mSUKL:string;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList:=TStringList.create;
        mList.LoadFromFile(mopenDLG.FileName);
        for i:=0 to mList.Count-1 do begin
          mCode:=NxToken(mlist.strings[i],';');
          mSUKL:=NxToken(mlist.strings[i],';');
          mStoreCard_ID:=GetStoreCard_ID(mOS, mCode);
          if not(NxIsEmptyOID(mStoreCard_ID)) then begin
            mSCBO:=mos.CreateObject(Class_StoreCard);
            mscbo.Load(mStoreCard_ID,nil);
            mscbo.SetFieldValueAsString('U_Specification3',mSUKL);
            mscbo.save;
            mscbo.free;

          end;
        end;

      finally
      end;
    end;
  finally
  end;
  end;

end;

function GetStoreCard_ID(var AOS : TNxCustomObjectSpace;var  AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE Code=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


begin
end.