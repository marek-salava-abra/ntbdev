procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport6';
  mAction.Caption := 'nahrani produkty';
  mAction.Hint := 'Naimportuje ID data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mNewBO, mParamBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 AStream:TMemoryStream;
 mTempStr, mCode, mElineID, mStoreCard_ID, mImageFile, mProdTempstr, mTempCode,mTempID, mPosindex, mVazba_ID:String;
 mid, mvyrobce, mprislusenstvi_id, mabra_id, mnovinka, makce, mdoporucujeme, mdoprodej, mdoprava_zdarma:string;
 mdoprava_a_platba_zdarma, mproductno, mextramessage, mextramessage2, mextramessage3, mheureka_extended_warranty, mextended_warranty, mfree_delivery, mfree_store_pickup, mfree_gift, mnazev_zbozi, mproduct, mna_uvod, myoutube_video :string;
begin

  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter:= 'Import z CSV|*.csv';
  mOpenDlg.FilterIndex:= 0;
  if mOpenDlg.Execute then begin
   mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=1 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
          mid:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mvyrobce:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mprislusenstvi_id:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mabra_id:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mnovinka:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          makce:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mdoporucujeme:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mdoprodej:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mdoprava_zdarma:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mdoprava_a_platba_zdarma:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mproductno:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mextramessage:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mextramessage2:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mextramessage3:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mheureka_extended_warranty:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mextended_warranty:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mfree_delivery:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mfree_store_pickup:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mfree_gift:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mnazev_zbozi:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mproduct:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mna_uvod:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          myoutube_video:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ';')),'"'),'"');
          mElineID:=mID;
         mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where X_ESCard=''A'' and X_elineID='+QuotedStr(mElineID),'');
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           mbo:=mOS.CreateObject(Class_StoreCard);
           mBO.Load(mStoreCard_ID,nil);
           mBO.SetFieldValueAsString('X_Producer_ID',mOS.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden=''N'' and name='+QuotedStr(mvyrobce),''));
           if mnovinka='1' then mbo.SetFieldValueAsBoolean('X_NES_New',True) else mbo.SetFieldValueAsBoolean('X_NES_New',false);
           if makce='1' then mbo.SetFieldValueAsBoolean('X_NES_Action',True) else mbo.SetFieldValueAsBoolean('X_NES_Action',false);
           if mdoporucujeme='1' then mbo.SetFieldValueAsBoolean('X_NES_Recomended',True) else mbo.SetFieldValueAsBoolean('X_NES_Recomended',false);
           if mdoprodej='1' then mbo.SetFieldValueAsBoolean('X_NES_Sale',True) else mbo.SetFieldValueAsBoolean('X_NES_Sale',false);
           if mdoprava_zdarma='1' then mbo.SetFieldValueAsBoolean('X_NES_FreeTransport',True) else mbo.SetFieldValueAsBoolean('X_NES_FreeTransport',false);
           if mdoprava_a_platba_zdarma='1' then mbo.SetFieldValueAsBoolean('X_NES_FreePayTransport',True) else mbo.SetFieldValueAsBoolean('X_NES_FreePayTransport',false);
           mBO.SetFieldValueAsBoolean('X_Free_delivery',false);
           mBO.SetFieldValueAsBoolean('X_Free_store_pickup',false);
           mBO.SetFieldValueAsBoolean('X_Extended_Warranty',false);
           if 'extended_warranty' in [mextramessage,mextramessage2, mextramessage3] then mBO.SetFieldValueAsBoolean('X_Extended_Warranty',true);
           if 'free_store_pickup' in [mextramessage,mextramessage2, mextramessage3] then mBO.SetFieldValueAsBoolean('X_Free_store_pickup',true);
           if 'free_delivery' in [mextramessage,mextramessage2, mextramessage3] then mBO.SetFieldValueAsBoolean('X_Free_delivery',true);
           mbo.SetFieldValueAsString('X_Zbozi_Name',mnazev_zbozi);
           mbo.SetFieldValueAsString('X_Zbozi_product',mproduct);
           mbo.SetFieldValueAsString('X_YouTube',myoutube_video);
           mBO.save;
            if NxCharCount('s',mprislusenstvi_id)>0 then begin
               mOS.SQLExecute('delete from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''02'' and X_Value_ID='+QuotedStr(mbo.OID));
               for j:=0 to nxcharcount('#',mprislusenstvi_id)-1 do begin
                  mProdTempstr:=NxTrapStr(mprislusenstvi_id,'#');
                  if AnsiLeftStr(mProdTempstr,1)='s' then begin
                     mTempCode:=NxTrimR(NxTrimL(copy(mProdTempstr,5,100),'"'),'"');
                     mTempID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and X_elineID='+QuotedStr(mTempCode),'');
                     if not(NxIsEmptyOID(mTempID)) then begin
                     mVazba_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''02'' and X_StoreCard_ID='+QuotedStr(mTempID)+' and X_Value_ID='+QuotedStr(mbo.OID));
                     if NxIsEmptyOID(mVazba_ID) then begin
                      mNewBO:=mos.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
                      mNewBO.New;
                      mNewBO.Prefill;
                      mNewBO.SetFieldValueAsString('X_Value_ID',mBO.OID);
                      mNewBO.SetFieldValueAsString('X_StoreCard_ID',mTempID);
                      mNewBO.SetFieldValueAsString('X_Rel_Def','02');
                      mPosIndex:=mOS.SQLSelectFirstAsString('Select max(X_posindex) from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''02'' and X_Value_ID='+QuotedStr(mBO.OID));
                      if Length(mPosIndex)=0 then mNewBO.SetFieldValueAsString('X_Posindex','01') else
                      mNewBO.SetFieldValueAsString('X_Posindex',AnsiRightStr('0'+IntToStr(StrToInt(mPosIndex)+1),2));
                      //NxShowSimpleMessage('#'+mPosIndex+'# '+FloatToStr(Length(mPosIndex)),mSite);
                      mNewBO.save;
                      mNewBO.free;
                     end;
                     end;
                  end;
               end;
            end;

           mbo.free;
         end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' karet.',mSite);
    end;
   end;
end;



begin
end.