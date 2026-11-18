uses 'eu.cemat.scprice.ParseData', 'eu.cemat.scprice.Progress';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import cen';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv do aktuálního ceníku';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;
end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mFirmBO, mbankBO, mSCBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mUnit, mPriceList:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k, m:integer;
 mID, mIco, mName, mTyp, mStorePrice_ID, mPriceList_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mStoreCardList, mImportedList, mNotImportedList, mSaveList:TStringList;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        j:=mList.Count;
        try
           ProgressInit(mSite, 'Import csv...', j);
           for i := 1 to j - 1 do begin
            //mID:=AnsiRightStr('000000'+NxTrapStr(mlist.strings[i],';'),10);
            mICO:=NxTrapStr(mlist.strings[i],';');
            mName:=NxTrapStr(mlist.strings[i],';');
            mTyp:=trim(NxTrapStr(mlist.strings[i],';'));
            mID:=GetFirm2_ID(mOS,mIco);
            if not(NxIsEmptyOID(mID)) then begin
              try
               mSMBO:=mOS.CreateObject(Class_Firm);
               mSMBO.Load(mID,nil);
               if mTyp='' then mSMBO.SetFieldValueAsInteger('U_Typ_Zak',0);
               if mTyp='Dealer' then mSMBO.SetFieldValueAsInteger('U_Typ_Zak',1);
               if mTyp='Importér' then mSMBO.SetFieldValueAsInteger('U_Typ_Zak',2);
               if mTyp='Koncový zákazník' then mSMBO.SetFieldValueAsInteger('U_Typ_Zak',3);
               if mTyp='OE' then mSMBO.SetFieldValueAsInteger('U_Typ_Zak',4);
               if mTyp='Pneuservis' then mSMBO.SetFieldValueAsInteger('U_Typ_Zak',5);
               msmbo.save;
               msmbo.free;
               except
               end;
            end;
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
        finally


        end;

      finally
      end;
    end;
  finally
  end;
  end;

end;


function GetFirm2_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE Code=''%s'' and firm_id is null and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

begin
end.