procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přidá související služby';
  mAction.Items.Add('Přidá související služby');
  mAction.Items.Add('Přidá více souvisejících služeb');
  mAction.Hint := 'tlačítko doplní pro označené karty související služby';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @AddRelProd;
  mAction2 := Self.GetNewMultiAction;
  mAction2.ShowControl := True;
  mAction2.ShowMenuItem := True;
  mAction2.Caption := 'Přidá typ stroje';
  mAction2.Items.Add('Přidá typ stroje');
  mAction2.Items.Add('Odebere typ stroje');
  mAction2.Hint := 'tlačítko doplní typy strojů';
  mAction2.Category := 'tabList';
  mAction2.OnExecuteItem := @AddMachineType;
end;

Procedure AddMachineType(Sender:tcomponent; Index : integer);
var
 mSite:TSiteForm;
 mList, mList2, mList3:TStringList;
 i,j:integer;
 mOS:TNxCustomObjectSpace;
 mGenOle,mRoll,mSelected: Variant;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 mOS:=msite.BaseObjectSpace;
 if index=0 then begin
   mGenOle := GetAbraOLEApplication;
   mSelected := mGenOle.CreateStrings;
   mRoll := mGenOle.GetRoll(Roll_UserRoll_MWDFAEWHVA445AYKS3XTKBSTZW, 0);
   if mRoll.MultiSelectDialog(True, mSelected) then begin
     mList2:=TStringList.create;
     mList2.Delimiter:=';';
     mlist2.Text:=mSelected.text;
     if mList2.count>0 then begin
        if NxMessageBox('Dotaz','Přjete si přidat '+inttostr(mlist2.Count)+' typy strojů k '+IntToStr(mlist.Count)+' položkám?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
          for i:=0 to mList.count-1 do begin
            mBO:=mOS.CreateObject(Class_StoreCard);
            mBO.Load(mlist.Strings[i],nil);
            mList3:=TStringList.create;
            mList3.Delimiter:=';';
            mList3.DelimitedText:=mbo.GetFieldValueAsString('X_MachineTypeIDs');
            for j:=0 to mList2.count-1 do begin
              if mList3.IndexOf(mList2.Strings[j])=-1 then mList3.Add(mList2.Strings[j]);
            end;
            mBO.SetFieldValueAsString('X_MachineTypeIDs',mList3.DelimitedText);
            mbo.save;
            mList3.free;
            mbo.Free;
          end;
        end;
     end;
   end;
 end;
 if index=1 then begin
   mGenOle := GetAbraOLEApplication;
   mSelected := mGenOle.CreateStrings;
   mRoll := mGenOle.GetRoll(Roll_UserRoll_MWDFAEWHVA445AYKS3XTKBSTZW, 0);
   if mRoll.MultiSelectDialog(True, mSelected) then begin
     mList2:=TStringList.create;
     mList2.Delimiter:=';';
     mlist2.Text:=mSelected.text;
     if mList2.count>0 then begin
        if NxMessageBox('Dotaz','Přjete si odebrat '+inttostr(mlist2.Count)+' typy strojů k '+IntToStr(mlist.Count)+' položkám?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
          for i:=0 to mList.count-1 do begin
            mBO:=mOS.CreateObject(Class_StoreCard);
            mBO.Load(mlist.Strings[i],nil);
            mList3:=TStringList.create;
            mList3.Delimiter:=';';
            mList3.DelimitedText:=mbo.GetFieldValueAsString('X_MachineTypeIDs');
            for j:=0 to mList2.count-1 do begin
              if mList3.IndexOf(mList2.Strings[j])>0 then mList3.delete(mList3.IndexOf(mList2.Strings[j]));
            end;
            mBO.SetFieldValueAsString('X_MachineTypeIDs',mList3.DelimitedText);
            mbo.save;
            mList3.free;
            mbo.Free;
          end;
        end;
     end;
   end;
 end;
end;

Procedure AddRelProd(Sender:tcomponent; Index : integer);
var
 mSite:TSiteForm;
 mList, mList2:tstringlist;
 i,j:integer;
 mOS:TNxCustomObjectSpace;
 mStoreCard_ID, mVazba_ID, mPosIndex:string;
 mNewBO, mBO:TNxCustomBusinessObject;
 mGenOle,mRoll,mSelected: Variant;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 mOS:=msite.BaseObjectSpace;
 if index=0 then begin
  if GetStoreCard_ID(mSite,mStoreCard_ID) then begin
   if not(NxIsEmptyOID(mStoreCard_ID)) then begin
      mBO:=mOS.CreateObject(Class_StoreCard);
      mBO.load(mStoreCard_ID,nil);
      if NxMessageBox('Dotaz','Přjete si přidat '+mBO.DisplayName+#13#10+' jako související službu k '+IntToStr(mlist.Count)+' položkám?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
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
 if index=1 then begin
   mGenOle := GetAbraOLEApplication;
   mSelected := mGenOle.CreateStrings;
   mRoll := mGenOle.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 0);
   if mRoll.MultiSelectDialog(True, mSelected) then begin
     mList2:=TStringList.create;
     mlist2.Text:=mSelected.text;
     if mList2.count>0 then begin
        if NxMessageBox('Dotaz','Přjete si přidat '+inttostr(mlist2.Count)+' produktů jako související službu k '+IntToStr(mlist.Count)+' položkám?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
          if mList.Count>0 then begin
           WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
            for i:=0 to mlist.count-1 do begin
             for j:=0 to mList2.count-1 do begin
             mVazba_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''02'' and X_StoreCard_ID='+QuotedStr(mlist2.Strings[j])+' and X_Value_ID='+QuotedStr(mList.strings[i]));
             if NxIsEmptyOID(mVazba_ID) then begin
              mNewBO:=mos.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
              mNewBO.New;
              mNewBO.Prefill;
              mNewBO.SetFieldValueAsString('X_Value_ID',mlist.Strings[i]);
              mNewBO.SetFieldValueAsString('X_StoreCard_ID',mlist2.Strings[j]);
              mNewBO.SetFieldValueAsString('X_Rel_Def','02');
              mPosIndex:=mOS.SQLSelectFirstAsString('Select max(X_posindex) from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''02'' and X_Value_ID='+QuotedStr(mList.strings[i]));
              if Length(mPosIndex)=0 then mNewBO.SetFieldValueAsString('X_Posindex','01') else
              mNewBO.SetFieldValueAsString('X_Posindex',AnsiRightStr('0'+IntToStr(StrToInt(mPosIndex)+1),2));
              //NxShowSimpleMessage('#'+mPosIndex+'# '+FloatToStr(Length(mPosIndex)),mSite);
              mNewBO.save;
              mNewBO.free;
              end;
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
    mForm.Caption := 'Přidá položku do souvisejících služeb';


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