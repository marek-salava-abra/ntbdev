procedure InitSite_Hook(Self: TSiteForm);
var
 muser:TNxCustomBusinessObject;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
begin

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Zdrojový doklad';
  mMAction.Hint := 'Zdrojový doklad';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowDocExecuteItem;
  mMAction.Items.Add('Konkrétní doklad');
  mMAction.Items.Add('Všechny doklady');

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Výstupní pohyb';
  mMAction.Hint := 'Výstupní pohyb';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowSDDocExecuteItem;
  mMAction.Items.Add('Konkrétní pohyb');
  mMAction.Items.Add('Všechny pohyby');
  mMAction.Items.Add('Příjemky');

end;


 procedure ShowDocExecuteItem(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 msite:TBusRollSiteForm;
 mr2:TStringList;
 mStrings:string;
 i:integer;
 mOLE, mRoll,mAgenda, mOResult: Variant;
 mSelected ,_ss:Variant;
 mstring:string;
begin
  mSite := TComponent(sender).BusRollSite;
  mbo:=TBusRollSiteForm(mSite).CurrentObject;
  mOLE := GetAbraOLEApplication;
      mroll := mOLE.GetAgenda('GF53HAH3WBDL3C5P00CA141B44');
      mSelected := mOLE.CreateStrings;
      mr2:=TStringList.create;
            try
               if index=0 then begin
                  mbo.ObjectSpace.SQLSelect('SELECT IO.id FROM IssuedOrders IO where IO.ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code')),mr2);
                end;
                if index=1 then begin
                  mbo.ObjectSpace.SQLSelect('SELECT distinct IO.id FROM IssuedOrders IO left join DefRollData A on ((A.Code=io.id) AND (A.Hidden = ''N'' ) AND (A.CLSID = ''EC2R2HSFK5UOZ5MYVJWJOHUC4S'' )) where (a.X_batches=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_batches'))+')',mr2);
                end;
                   if mr2.count=0 then begin
                       NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);
                       exit;
                   end;
                   for i := 0 to mr2.Count - 1 do begin
                       mSelected.Add(mr2.Strings[i]);
                   end;
            finally
                mr2.free;
            end;
         mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Šarže: ' + mbo.GetFieldValueAsString('X_batches.name')  +' v množství: ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')) + ', Skladová karta: ' + mbo.GetFieldValueAsString('X_batches.Storecard_ID.DisplayName'), '');
end;



 procedure ShowSDDocExecuteItem(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 msite:TBusRollSiteForm;
 mr2:TStringList;
 mStrings:string;
 i:integer;
 mOLE, mRoll,mAgenda, mOResult: Variant;
 mSelected ,_ss:Variant;
 mstring:string;
begin
  mSite := TComponent(sender).BusRollSite;
  mbo:=TBusRollSiteForm(mSite).CurrentObject;
  mOLE := GetAbraOLEApplication;
      if index=2 then begin
          mroll := mOLE.GetAgenda('B10I5SAOS3DL3ACU03KIU0CLP4');
      end else begin
         mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
      end;
      mSelected := mOLE.CreateStrings;
      mr2:=TStringList.create;
            try
               if index=0 then begin
                  mbo.ObjectSpace.SQLSelect('SELECT drb.id FROM Storedocuments2 SD2 left join DocRowBatches DRB on drb.Parent_ID=sd2.id where SD2.ProvideRow_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_parent_ID')) + ' and (drb.StoreBatch_ID='+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_batches')) + ')'   ,mr2);
                end;
                if index=1 then begin
                  mbo.ObjectSpace.SQLSelect('SELECT distinct drb.id FROM Storedocuments2 SD2 join storedocuments sd on sd.id=sd2.parent_ID join DocRowBatches DRB on drb.parent_id=sd2.id left join DefRollData A on ((A.X_parent_ID=sd2.Providerow_id) AND (A.Hidden = ''N'' ) AND (A.CLSID = ''EC2R2HSFK5UOZ5MYVJWJOHUC4S'' )) where (drb.StoreBatch_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_batches'))+')' + ' and (SD.Documenttype=''20'')',mr2);
                end;
                if index=2 then begin
                  mbo.ObjectSpace.SQLSelect('SELECT distinct sd.id FROM Storedocuments2 SD2 join storedocuments sd on sd.id=sd2.parent_ID join DocRowBatches DRB on drb.parent_id=sd2.id left join DefRollData A on ((A.X_parent_ID=sd2.Providerow_id) AND (A.Hidden = ''N'' ) AND (A.CLSID = ''EC2R2HSFK5UOZ5MYVJWJOHUC4S'' )) where (drb.StoreBatch_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_batches'))+')' + ' and (SD.Documenttype=''20'')',mr2);
                end;
                   if mr2.count=0 then begin
                       NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);
                       exit;
                   end;
                   for i := 0 to mr2.Count - 1 do begin
                       mSelected.Add(mr2.Strings[i]);
                   end;
            finally
                mr2.free;
            end;
         if index=1 then begin
             mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Šarže: ' + mbo.GetFieldValueAsString('X_batches.name')  +' v množství: ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')) + ', Skladová karta: ' + mbo.GetFieldValueAsString('X_batches.Storecard_ID.DisplayName'), '');
         end else begin
             mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Šarže: ' + mbo.GetFieldValueAsString('X_batches.name')  +' v množství: ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')) + ', Skladová karta: ' + mbo.GetFieldValueAsString('X_batches.Storecard_ID.DisplayName'), '');
         end;
end;





begin
end.
