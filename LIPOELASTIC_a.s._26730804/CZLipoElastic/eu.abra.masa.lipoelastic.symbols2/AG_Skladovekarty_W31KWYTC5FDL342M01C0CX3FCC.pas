procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actAddSymbols';
  mAction.Caption := 'Hromadné přidání';
  mAction.Items.Add('Přidá symboly');
  mAction.Hint := 'Přidá data';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @AddSymbols;
end;


Procedure AddSymbols(Sender:tcomponent; index:integer);
var
 mSite:TSiteForm;
 mList:tstringlist;
 i,j:integer;
 mOS:TNxCustomObjectSpace;
 mPicture_ID, mVazba_ID, mPosIndex:string;
 mNewBO, mBO:TNxCustomBusinessObject;
 mAllowedIDs, mOLE, mOLEStrings, mRoll: Variant;
begin
if index=0 then begin
 mSite:=TComponent(Sender).BusRollSite;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 mOS:=msite.BaseObjectSpace;
 mOLE:= GetAbraOLEApplication;
 mOLEStrings:= GetAbraOLEStrings;
 mAllowedIDs:= GetAbraOLEStrings;
 mRoll:= mOLE.GetRoll(Roll_Pictures, 2);
 if mRoll.MultiSelectDialog(False, mOLEStrings) then begin
 //if GetPaymentType_ID(mSite,mPaymentType_ID) then begin
   if mOLEStrings.count>0  then begin
      //mBO:=mOS.CreateObject(Class_PaymentType);
      //mBO.load(mPaymentType_ID,nil);
      if NxMessageBox('Dotaz','Přejete si přidat '+IntToStr(mOLEStrings.count)+' obrázků'+#13#10+' jako udržovací symboly k '+IntToStr(mlist.Count)+' položkám?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
        if mList.Count>0 then begin
         WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
          for i:=0 to mlist.count-1 do begin
           for j:=0 to mOLEStrings.count-1 do begin
             mPicture_ID:=mOLEStrings.strings[j];
             mVazba_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''05'' and X_Picture_ID='+QuotedStr(mPicture_ID)+' and X_Value_ID='+QuotedStr(mList.strings[i]));
             if NxIsEmptyOID(mVazba_ID) then begin
              mNewBO:=mos.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
              mNewBO.New;
              mNewBO.Prefill;
              mNewBO.SetFieldValueAsString('X_Value_ID',mlist.Strings[i]);
              mNewBO.SetFieldValueAsString('X_Picture_ID',mPicture_ID);
              mNewBO.SetFieldValueAsString('X_Rel_Def','05');
              mPosIndex:=mOS.SQLSelectFirstAsString('Select max(X_posindex) from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''05'' and X_Value_ID='+QuotedStr(mList.strings[i]));
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


begin
end.