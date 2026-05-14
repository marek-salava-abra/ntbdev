function GetDate(Sender: TComponent;msite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(Sender);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Zadej datum servisu';
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := 'Zadej datum:';
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDocQueues';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mEdtSrc.Date:= date;
                        mForm.InsertControl(mEdtSrc);
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'OK';
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'Storno';
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(msite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;


procedure Exec(Sender: TAction;index:integer);
var mSite: TDynSiteForm;
    mOLE, mRoll, mOResult: Variant;
    mStoreCards, mBikes: TStringList;
    i, j,k: Integer;
    mBO,mbo_target,mBO_ML,mBO_ML_target,mbo_ml_target_row: TNxCustomBusinessObject;
    mError: string;
    mids,mr:TStringList;
    mMonList:boolean;
    mMon:TNxCustomBusinessMonikerCollection;
    mdate:Double;
    mID:string;
    mID_SL:string;
    mr2:tstringlist;
begin
  mSite:= TDynSiteForm(NxFindSiteForm(Sender));
  if mSite = nil then Exit;
  mbo:= TDynSiteForm(mSite).CurrentObject;


            mdate:=getdate(sender,msite);
            if true then begin

                          mOLE:= GetAbraOLEApplication;
                          mOResult:= mOLE.CreateStrings;
                          mRoll:= mOLE.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);
                          if index=1 then begin
                              mMonList:=false;
                          end else begin
                              mMonList:=true;
                          end;

                          if not mRoll.MultiSelectDialog(True, mOResult) then Exit;
                                mids:= TStringList.Create;
                                try
                                  mids.Text:= mOResult.Text;
                                  for i:=0 to mids.count-1 do begin

                                      try
                                          mbo_target:=TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                          try
                                            //mbo_target:=mbo.Clone;
                                            mbo_target.new;
                                            mbo_target.Prefill;
                                            mbo_target.SetFieldValueAsString('Docqueue_ID', mbo.GetFieldValueAsString('Docqueue_ID'));
                                            mbo_target.SetFieldValueAsDateTime('Docdate$date', mdate);

                                            mbo_target.SetFieldValueAsstring('ServicedObjectIDCode','');
                                            mbo_target.SetFieldValueAsstring('ServicedObjectText','');
                                            mbo_target.SetFieldValueAsString('ServiceType_ID','2300000101');
                                            mbo_target.SetFieldValueAsstring('ServicedObject_ID',mids[i]);
                                            mbo_target.SetFieldValueAsString('Division_ID', mbo.GetFieldValueAsString('Division_ID'));
                                            mbo_target.SetFieldValueAsString('BusOrder_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID'));
                                            mbo_target.SetFieldValueAsString('BusTransaction_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID'));
                                            mbo_target.SetFieldValueAsString('BusProject_ID', mbo_target.GetFieldValueAsString('ServicedObject_ID.BusProject_ID'));
                                            mbo_target.SetFieldValueAsString('AcceptedByUser_ID', mbo_target.GetFieldValueAsString('AcceptedByUser_ID'));
                                            mbo_target.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mdate);
                                            if mbo_target.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky')<>'' then begin
                                               mbo_target.SetFieldValueAsstring('X_objednani', mbo_target.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky'));
                                            end else begin
                                               //mbo_target.SetFieldValueAsstring('X_objednani', mbo.GetFieldValueAsstring('X_objednani'));
                                            end;
                                            mbo_target.SetFieldValueAsstring('ServiceDocState_ID','2000000101');
                                              // řádky montážního listu

                                            mbo_target.Save ;
                                            mID_SL:=mbo_target.oid;



                                                  mBO_ml:=mbo_target.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                  try
                                                      mBO_ml.new;
                                                      mbo_ml.Prefill;
                                                      mBO_ml.SetFieldValueAsString('ServiceDocument_ID',mID_SL);
                                                      //mBO_ml.SetFieldValueAsInteger('OrdNumber',mr.count+1);
                                                      mr2:=TStringList.Create;
                                                      try
                                                          mbo_target.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo_target.GetFieldValueAsString('Division_ID.code')),mr2);
                                                          if mr2.count>0 then begin
                                                             mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                                          end;
                                                      finally
                                                         mr2.free;
                                                      end;
                                                      mBO_ml.SetFieldValueAsinteger('AssemblyState',0);
                                                      mBO_ml.SetFieldValueAsstring('X_State','3XQ1000101');
                                                      mBO_ml.SetFieldValueAsstring('X_id_zakaznika_id',mbo_target.GetFieldValueAsString('X_id_zakaznika_id'));
                                                      mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',mbo_target.GetFieldValueAsString('ServicedObject_ID'));
                                                      mBO_ml.SetFieldValueAsDateTime('StartDate$DATE',mbo_target.GetFieldValueAsDateTime('docdate$date'));
                                                      mBO_ml.SetFieldValueAsDateTime('EndDate$DATE',mbo_target.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                                      mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mbo_target.GetFieldValueAsString('Docqueue_ID'));
                                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mbo_target.GetFieldValueAsInteger('Ordnumber'));
                                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',mbo_target.GetFieldValueAsString('Period_ID'));
                                                      mr2:=TStringList.Create;
                                                      try
                                                          mbo_target.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo_target.GetFieldValueAsString('Division_ID.code')),mr2);
                                                          if mr2.count>0 then begin
                                                             mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                                          end;
                                                      finally
                                                         mr2.free;
                                                      end;
                                                      mBO_ml.save;
                                                  finally
                                                     mBO_ml.free;
                                                  end;






                                          finally
                                            mbo_target.free;
                                          end;
                                     finally

                                      end;
                                  end;

                                finally
                                  mids.free;
                                end ;

                          TDynSiteForm(mSite).RefreshData;
               end else begin
                   NxShowSimpleMessage('Nebyl korektně zadán termín servisu, kopie nebyla provedena',nil);
               end;
       if mID_SL<>'' then begin
          TDynSiteForm(mSite).RefreshData;
          msite.RefreshData;
          msite.ActiveDataSet.seekid(mID_SL);
       end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Kopie SL';
  mMAction.Hint := 'Kopie SL';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @Exec;
  mMAction.Items.Add('Přímá kopie SL s aktuálním datem');

end;

begin
end.



