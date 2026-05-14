uses 'eu.tat.lowlimit.dialog';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mMAction, mMAction2: TMultiAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Hint := 'Změní hodnotu minima dle požadavku, volba 1 je DL a PRV z konkrétního skladu, volba 2 jsou DL ze všech skladů';
  mMAction.Caption := 'Změna minima';
  mMAction.Items.Add('Změna minima');
  mMAction.Items.Add('Změna minima TW');
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @ChangeDeliverDate;
end;


procedure ChangeDeliverDate(Sender: TObject; Index: integer);
var mSite : TSiteForm;
    mGrid : TDBGrid;
    mList : TStringList;
    mBO, mStoreCard, mBOReservation : TNxCustomBusinessObject;
    mStoreCard_ID, mStoreSubCard_ID, mdate, mStore_ID : String;
    mKoef:Extended;
    i, j : integer;
    mQuantity, mDayBefore, mDayAfter: Extended;
    mDialog:Boolean;
begin

mList := TStringList.Create;
j:=0;
mStore_ID:='';
mDayBefore:=365;
mDayAfter:=90;
try
 mSite := TComponent(Sender).BusRollSite;
 if Assigned(mSite) then begin
  TBusRollSiteForm(mSite).FillListWithSelectedRows(mList);
  LowLimitQuantityData(msite,mStore_id,mDayBefore, mDayAfter, mDialog);
  if not(mDialog) then begin
       NxShowSimpleMessage('Ruším výpočet spodních limitů.',msite);
       exit;
    end;
   if (mList.count) > 0 then begin

        for i:=0 to mList.Count - 1 do begin
            mStoreCard_ID := mList.Strings[i];
            mStoreSubCard_ID:=scrGetStoreSubcard_ID(msite.BaseObjectSpace,mStoreCard_ID,mstore_ID);
            //NxShowSimpleMessage(mStoreCard_ID+' '+mStoreSubCard_ID,mSite);
              if not(NxIsEmptyOID(mStoreSubCard_ID)) then begin
                  mbo:=msite.BaseObjectSpace.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC');
                  mbo.load(mStoreSubCard_ID,nil);
                  if not(mbo.GetFieldValueAsBoolean('StoreCard_ID.X_NotCalc')) then begin
                    mdate:=inttostr(trunc(Date-mDayBefore));
                    if Index=0 then mQuantity:=scrGetQuantity(mSite.BaseObjectSpace,mStoreCard_ID, mStore_ID,mdate);
                    if Index=1 then mQuantity:=scrGetQuantity3(mSite.BaseObjectSpace,mStoreCard_ID, mStore_ID,mdate);
                    mQuantity:=mQuantity*(mDayAfter/mDayBefore);
                    mQuantity:=NxRoundByValue(mQuantity,ctArithmetic,1);
                    mbo.SetFieldValueAsFloat('LowLimitQuantity',mQuantity);
                    j:=j+1;
                    end;
                  mbo.Save;
                  mbo.Free;
              end;
        end;
    end
    else
    MessageDlg('Nevybrán žádný záznam', mtError,[mbOk],0);

    end;
    finally
  mList.free;
   TBusRollSiteForm(mSite).RefreshData;
   NxShowSimpleMessage('Opravil jsem minimální množství na '+IntToStr(j)+' kartách',msite);
  end;



end;







function scrGetStoreSubcard_ID(AOS : TNxCustomObjectSpace; var AStoreCard_ID, aStore_ID : string) : string;
const
  cSQL = 'SELECT ID FROM StoreSubcards WHERE StoreCard_ID=''%s'' and store_id=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    //NxShowSimpleMessage(Format(cSQL, [aStoreCard_ID, AStore_ID]),nil);
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, AStore_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


function scrGetQuantity(AOS : TNxCustomObjectSpace;var aStoreCard_ID,aStore_ID, aDateString : string) : double;
const
  cSQL = 'Select sum(sd2.Quantity) from StoreDocuments2 sd2 left join storedocuments sd on sd.id=SD2.parent_id where sd2.storecard_id=''%s'' and sd2.store_id=''%s'' and (sd.documenttype=''21'' or sd.documenttype=''22'') and sd.docdate$date>=%s ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:=0;
    //NxShowSimpleMessage(Format(cSQL, [aStoreCard_ID, aStore_ID, aDateString]),nil);
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID, aDateString]), mList);
    if mList.Count > 0 then
      Result := strtofloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrGetQuantity3(AOS : TNxCustomObjectSpace;var aStoreCard_ID,aStore_ID, aDateString : string) : double;
const
  cSQL = 'Select sum(sd2.Quantity) from StoreDocuments2 sd2 left join storedocuments sd on sd.id=SD2.parent_id where sd2.storecard_id=''%s'' and (sd.documenttype=''21'') and sd.docdate$date>=%s ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:=0;
    //NxShowSimpleMessage(Format(cSQL, [aStoreCard_ID, aStore_ID, aDateString]),nil);
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID, aDateString]), mList);
    if mList.Count > 0 then
      Result := strtofloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrRow_ID(AOS : TNxCustomObjectSpace;var aStoreCard_ID,aStore_ID, aDateString : string) : String;
const
  cSQL = 'Select (sd2.ID) from StoreDocuments2 sd2 left join storedocuments sd on sd.id=SD2.parent_id where sd2.storecard_id=''%s'' and sd2.store_id=''%s'' and (sd.documenttype=''21'') and sd.docdate$date>=%s order by sd2.quantity desc';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID, aDateString]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrRow2_ID(AOS : TNxCustomObjectSpace;var aStoreCard_ID, aDateString : string) : String;
const
  cSQL = 'Select (sd2.ID) from StoreDocuments2 sd2 left join storedocuments sd on sd.id=SD2.parent_id where sd2.storecard_id=''%s'' and (sd.documenttype=''21'') and sd.docdate$date>=%s order by sd2.quantity desc';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aDateString]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrGetQuantity2(AOS : TNxCustomObjectSpace;var aStoreCard_ID, aDateString : string) : double;
const
  cSQL = 'Select sum(sd2.Quantity) from StoreDocuments2 sd2 left join storedocuments sd on sd.id=SD2.parent_id where sd2.storecard_id=''%s'' and (sd.documenttype=''21'') and sd.docdate$date>=%s ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:=0;
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aDateString]), mList);
    if mList.Count > 0 then
      Result := strtofloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;




begin
end.