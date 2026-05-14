procedure InsertPicture(Sender: TObject);
var
mSite: TSiteForm;
mPath:String;
mList:TStringList;
mBO, mtempBO: TNxCustomBusinessObject;
mOS:TNxCustomObjectSpace;
mCol:TNxCustomBusinessMonikerCollection;
i:integer;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
      mOS:=TBusRollSiteForm(mSite).CurrentObject.ObjectSpace;
      mList:=TStringList.create;
      msite.FillListWithSelectedRows(mList);
      mpath:=GetPath(msite);
      for i:=0 to mList.count-1 do begin
        mbo:= mos.CreateObject(Class_StoreCard);
        mbo.Load(mlist.Strings[i],nil);
        mCol:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
        mtempBO:=mCol.AddNewObject;
        mtempBO.SetFieldValueAsString('Picture_ID',mPath);

        mbo.save;
        mbo.free;

      end;
    end;
  end;

end;


function GetPath(ASite : TSiteform) : string;
var mForm : TForm;
    mcb:TRollComboEdit;
    mCbCc,mLabel1, mLabel2, mLabel3 : TLabel;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin
  if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 509;
    mForm.Height:= 108;
    mForm.Caption := 'Obrázek';

     mCbCc:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered; není v XE
    mCbCc.Left:= 128;
    mCbCc.Top:= 8;
    mCbCc.Width:= 255;

    mCb:= TRollComboEdit.Create(mForm);
    mCb.Parent:= mForm;

    mCb.ClassID:= '2ZIPZFWK5TJ4V5CLRSISRGTV44';
    mCb.Complete:= True;
    mCb.ForcedField:= True;
    mCb.Prefilling:= pmNone;
    mCb.TextField:= 'DisplayName';  // položka podle které se bude vyhledávat
    mCb.Top:= 8;
    mCb.Left:= 17;
    mCb.Width:= 108;
    mCb.ConnectedControl:= mCbCc;
    mCb.ConnectedControlField:= 'DisplayName';  //položka která bude zobrazena v containeru

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 39;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 39;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
   // if mButCancel.OnC
    if mResult = 1 then
        Result := mcb.DataText
    else Result := '';
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.