uses 'eu.promos.sc.ParseData', 'eu.promos.sc.Progress';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změnit obch. případ';
  mAction.ShortCut := TextToShortCut('Ctrl+D'); //16450;
  mAction.Hint := 'Změní obchodní případ na označených řádcích';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ChangeDiscount;
    //mAction.OnUpdate := @ImportOnUpdate;

end;


Procedure ChangeDiscount(sender:Tcomponent);
var
 msite:TSiteForm;
 mGRows:TMultiGrid;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i, j:integer;
 mDiscount:Extended;
 mStockType_ID:String;
begin

     mList:=TStringList.create;
     msite:=TComponent(sender).DynSite;
     TDynSiteForm(msite).List.GetSelectedId(mlist);
     if NxMessageBox('Dotaz','Přejete si změnit obchodní případ na '+inttostr(mlist.count)+' fakturách?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     GetStockType(msite,mStockType_ID);
     ProgressInit(mSite, 'Aktualizace faktur...', mList.Count);
      for i:=0 to mlist.count-1 do begin
       mBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedInvoice);
       mbo.load(mlist.strings[i],nil);
       mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
        for j:=0 to mrows.count-1 do begin
          mrows.BusinessObject[j].SetFieldValueAsString('BusTransaction_ID',mStockType_ID);


        end;
        mbo.save;
        mbo.free;
      ProgressSetPos(i+1);
        end;

          ProgressDispose();
          TDynSiteForm(msite).RefreshData;
     end;
end;



Function GetStockType(var ASite : TSiteform; var aStockType_ID : string):Boolean;
var
    mLabel1,mCbCCMaterialComposition: TLabel;
    mEd1, mEd2, mEd3, mEd4, mEd5, mEd6:TEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mCbSupplier: TRollComboEdit;
    mCbCcSupplier: TLabel;
    mCbMaterialComposition: TRollComboEdit;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 180;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Změní obchodní případ na označených řádích';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Obchodní případ:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mCbCCMaterialComposition:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCCMaterialComposition.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;              FIRMA
    mCbCCMaterialComposition.Left:= 236;
    mCbCCMaterialComposition.Top:= 10;
    mCbCCMaterialComposition.Width:= 255;

    mCbMaterialComposition:= TRollComboEdit.Create(mForm);
    mCbMaterialComposition.Parent:= mForm;

    mCbMaterialComposition.ClassID:= '0BOXHKRF4VD13ACL03KIU0CLP4';
    mCbMaterialComposition.Complete:= True;
    mCbMaterialComposition.Prefilling:= pmNone;
    mCbMaterialComposition.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbMaterialComposition.Top:= 10;
    mCbMaterialComposition.Left:= 125;
    mCbMaterialComposition.Width:= 108;
    mCbMaterialComposition.DataText:=aStockType_ID;
    mCbMaterialComposition.ConnectedControl:= mCbCCMaterialComposition;
    mCbMaterialComposition.ConnectedControlField:= 'Name';



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 45;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 45;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if mResult = 1 then

         aStockType_ID:=mCbMaterialComposition.DataText;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;


begin
end.