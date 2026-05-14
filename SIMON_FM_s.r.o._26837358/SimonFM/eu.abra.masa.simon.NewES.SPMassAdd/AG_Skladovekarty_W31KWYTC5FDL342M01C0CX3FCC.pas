procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actAddRelProd';
  mAction.Caption := 'Přidá související produkty';
  mAction.Hint := 'tlačítko doplní pro označené karty související produkt';
  mAction.Category := 'tabList';
  mAction.OnExecute := @AddRelProd;
end;


Procedure AddRelProd(Sender:tcomponent);
var
 mSite:TSiteForm;
 mList:tstringlist;
 i:integer;
 mOS:TNxCustomObjectSpace;
 mStoreCard_ID, mVazba_ID, mPosIndex:string;
 mNewBO, mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 mOS:=msite.BaseObjectSpace;
 if GetStoreCard_ID(mSite,mStoreCard_ID) then begin
   if not(NxIsEmptyOID(mStoreCard_ID)) then begin
      mBO:=mOS.CreateObject(Class_StoreCard);
      mBO.load(mStoreCard_ID,nil);
      if NxMessageBox('Dotaz','Přjete si přidat '+mBO.DisplayName+#13#10+' jako související produkt k '+IntToStr(mlist.Count)+' položkám?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
        if mList.Count>0 then begin
         WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
          for i:=0 to mlist.count-1 do begin
           mVazba_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''02'' and X_StoreCard_ID='+QuotedStr(mStoreCard_ID)+' and X_Value_ID='+QuotedStr(mList.strings[i]));
           if NxIsEmptyOID(mVazba_ID) then begin
            mNewBO:=mos.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
            mNewBO.New;
            mNewBO.Prefill;
            mNewBO.SetFieldValueAsString('X_Value_ID',mlist.Strings[i]);
            mNewBO.SetFieldValueAsString('X_StoreCard_ID',mStoreCard_ID);
            mNewBO.SetFieldValueAsString('X_Rel_Def','02');
            mPosIndex:=mOS.SQLSelectFirstAsString('Select max(X_posindex) from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''02'' and X_Value_ID='+QuotedStr(mList.strings[i]));
            if Length(mPosIndex)=0 then mNewBO.SetFieldValueAsString('X_Posindex','01') else
            mNewBO.SetFieldValueAsString('X_Posindex',AnsiRightStr('0'+IntToStr(StrToInt(mPosIndex)+1),2));
            //NxShowSimpleMessage('#'+mPosIndex+'# '+FloatToStr(Length(mPosIndex)),mSite);
            mNewBO.save;
            mNewBO.free;
           end;
           WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
           WaitWin.StepIt;
          end;
         WaitWin.Stop;
         NxShowSimpleMessage('Doplněno.',mSite);
        end;
      end;
   end;
 end;
end;


Function GetStoreCard_ID(var ASite : TSiteform; var aStoreCard_ID : string):Boolean;
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
    mForm.Caption := 'Přidá položku do souvisejících produktů';


    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Skladová karta:';
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

    mCbMaterialComposition.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbMaterialComposition.Complete:= True;
    mCbMaterialComposition.Prefilling:= pmNone;
    mCbMaterialComposition.TextField:= 'CODE';  // položka podle které se bude vyhledávat středisko
    mCbMaterialComposition.Top:= 10;
    mCbMaterialComposition.Left:= 125;
    mCbMaterialComposition.Width:= 108;
    mCbMaterialComposition.DataText:=aStoreCard_ID;
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

         aStoreCard_ID:=mCbMaterialComposition.DataText;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.