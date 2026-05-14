uses 'abra.eu.mask_import.2016.Objednavka_prijata';

const
    mFilter='*.xml';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Hromadný dobropis ';
          mMAction.Caption := 'Vytvoření hromadného dobropisu ';
          mMAction.Items.Add('Finance (FV)');
          mMAction.Items.Add('Zboží (příjemky) ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;



procedure OnExec(Sender: TComponent;index:integer);
var
msite:TDynSiteForm;
mbo_source, mBO_target,mBO_targetPR,mRow_targetPR,mBO_dohledano,mRow_target:TNxCustomBusinessObject;
mMon_Rows_source,mMon_Rows_targetPR,mMon_Rows_target,mMon_Rows_new:TNxCustomBusinessMonikerCollection;
mr:TStringList;
i,ii:integer;
mPocet:double;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
    mbo_source:=TDynSiteForm(msite).CurrentObject ;
    mMon_Rows_source:= mbo_source.GetLoadedCollectionMonikerForFieldCode(mbo_source.GetFieldCode('ROWS'));

    if index=0 then begin
        mBO_target:=msite.BaseObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');     // faktura
    end;
    if index=1 then begin
        mBO_targetPR:=msite.BaseObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');     // příjemka
    end;


      try

         if index=0 then begin
            mBO_target.new;
            mBO_target.Prefill;
            mBO_target.SetFieldValueAsString('DocQueue_ID','2F10000101');
            mMon_Rows_target:=mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS')) ;
            mBO_target.SetFieldValueAsString('Currency_ID',mbo_source.GetFieldValueAsString('Currency_ID'));
            mBO_target.SetFieldValueAsString('firm_id',mbo_source.GetFieldValueAsString('firm_ID'));
         end;
         if index=1 then begin
            mBO_targetPR.new;
            mBO_targetPR.Prefill;
            mBO_targetPR.SetFieldValueAsString('DocQueue_ID','1320000101');
            mBO_targetPR.SetFieldValueAsString('firm_id',mbo_source.GetFieldValueAsString('firm_ID'));
            mMon_Rows_targetPR:=mBO_targetPR.GetLoadedCollectionMonikerForFieldCode(mBO_targetPR.GetFieldCode('ROWS')) ;
            mBO_targetPR.SetFieldValueAsString('Currency_ID','0000CZK000');

         end;





        for i := 0 to mMon_Rows_source.Count - 1 do begin
          mpocet:= (mMon_Rows_source.BusinessObject[i].GetFieldValueAsFloat('Quantity') ) *mMon_Rows_source.BusinessObject[i].GetFieldValueAsFloat('unitrate');
              if mpocet>0 then begin
                  if index=0 then begin

                              mr:=TStringList.create;
                        try
                            msite.BaseObjectSpace.SQLSelect('select SD2.id from IssuedInvoices SD left join IssuedInvoices2 SD2 on sd2.parent_id=sd.id where '
                            + '(( sd.firm_id=' +
                            quotedstr(mbo_source.GetFieldValueAsString('Firm_ID')) +
                            ') or (sd.firm_id=' + quotedstr('17E3000101') +')' +
                            ' or (sd.firm_id=' + quotedstr('22H4000101') +')'


                            + ') and sd2.storecard_id=' + quotedstr(mMon_Rows_source.BusinessObject[i].GetFieldValueAsstring('StoreCard_ID')) +
                            ' order by sd.docdate$date desc',mr)  ;
                            if mr.count>0 then begin
                                    //NxShowSimpleMessage('dohledáno ' + inttostr(mr.count) + ' záznamů',nil);
                                    for ii := 0 to mr.Count - 1 do begin
                                       mBO_dohledano:=msite.BaseObjectSpace.CreateObject('OBBDOKTWEFD13ACM03KIU0CLP4');
                                       try
                                            if mpocet>0 then begin
                                                      mBO_dohledano.Load(mr.Strings[ii],nil);

                                                      mRow_target:= mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS')).AddNewObject;
                                                          //mNewRow.Assign(mRow);
                                                          mRow_target.Prefill;
                                                          mRow_target.SetFieldValueAsInteger('Rowtype',2);
                                                          mRow_target.SetFieldValueAsString('Text',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('StoreCard_ID.Code') +
                                                                                                   mMon_Rows_source.BusinessObject[i].getFieldValueAsString('StoreCard_ID.Name'));
                                                          mRow_target.SetFieldValueAsString('Vatrate_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('Vatrate_ID'));
                                                          mRow_target.SetFieldValueAsString('Qunit',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('Qunit'));
                                                          //mRow_target.SetFieldValueAsString('Store_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('Store_ID')); //text bude  ...
                                                          //mRow_target.SetFieldValueAsString('Storecard_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('Storecard_ID'));
                                                          mRow_target.SetFieldValueAsString('BusOrder_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('BusOrder_ID')); //text bude  ...
                                                          mRow_target.SetFieldValueAsString('Division_ID',mMon_Rows_source.BusinessObject[i].GetFieldValueAsString('Division_ID'));
                                                          mRow_target.SetFieldValueAsString('BusTransaction_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')); //text bude  ...

                                                          if mpocet>=(mBO_dohledano.GetFieldValueAsFloat('quantity')) then begin
                                                              mRow_target.SetFieldValueAsFloat('Quantity',(-1) * mBO_dohledano.GetFieldValueAsFloat('quantity'));
                                                              mRow_target.SetFieldValueAsFloat('Unitprice',mBO_dohledano.GetFieldValueAsFloat('Unitprice'));
                                                              mpocet:=mpocet-(mBO_dohledano.GetFieldValueAsFloat('quantity')*mBO_dohledano.GetFieldValueAsFloat('unitrate')) ;
                                                          end else begin
                                                              mRow_target.SetFieldValueAsFloat('Quantity',(-1) * mPocet);
                                                              //mRow_target.SetFieldValueAsFloat('Unitprice',mBO_dohledano.GetFieldValueAsFloat('Unitprice'));
                                                              mRow_target.SetFieldValueAsFloat('Unitprice',mBO_dohledano.GetFieldValueAsFloat('Unitprice'));
                                                              mpocet:=0;
                                                          end;

                                                          //mRow_target.a;
                                             end;
                                       finally
                                           mBO_dohledano.free;
                                       end;
                                    end;
                            end;
                        finally
                            mr.free;
                        end;
                  end;
                  if index=1 then begin
                        mr:=TStringList.create;
                        try
                            msite.BaseObjectSpace.SQLSelect('select SD2.id from storedocuments SD left join storedocuments2 SD2 on sd2.parent_id=sd.id where sd.DocumentType=' + quotedstr('21') +
                            ' AND (( sd.firm_id=' +
                            quotedstr(mbo_source.GetFieldValueAsString('Firm_ID')) +
                            ') or (sd.firm_id=' + quotedstr('17E3000101') +')' +
                            ' or (sd.firm_id=' + quotedstr('22H4000101') +')'


                            + ') and sd2.storecard_id=' + quotedstr(mMon_Rows_source.BusinessObject[i].GetFieldValueAsstring('StoreCard_ID'))  +
                            ' order by sd.docdate$date desc',mr)  ;
                            if mr.count>0 then begin
                                    //NxShowSimpleMessage('dohledáno ' + inttostr(mr.count) + ' záznamů',nil);
                                    for ii := 0 to mr.Count - 1 do begin
                                       mBO_dohledano:=msite.BaseObjectSpace.CreateObject('FLQIA44IVWM4B20GYRHC42BHGW');
                                       try
                                            if mpocet>0 then begin
                                                      mBO_dohledano.Load(mr.Strings[ii],nil);

                                                      mRow_targetPR:= mBO_targetPR.GetLoadedCollectionMonikerForFieldCode(mBO_targetPR.GetFieldCode('ROWS')).AddNewObject;
                                                          //mNewRow.Assign(mRow);
                                                          mRow_targetPR.Prefill;
                                                          mRow_targetPR.SetFieldValueAsString('Store_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('Store_ID')); //text bude  ...
                                                          mRow_targetPR.SetFieldValueAsString('Storecard_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('Storecard_ID'));
                                                          mRow_targetPR.SetFieldValueAsString('BusOrder_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('BusOrder_ID')); //text bude  ...
                                                          mRow_targetPR.SetFieldValueAsString('Division_ID',mMon_Rows_source.BusinessObject[i].GetFieldValueAsString('Division_ID'));
                                                          mRow_targetPR.SetFieldValueAsString('BusTransaction_ID',mMon_Rows_source.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')); //text bude  ...

                                                          if mpocet>=(mBO_dohledano.GetFieldValueAsFloat('quantity')) then begin
                                                              mRow_targetPR.SetFieldValueAsFloat('Quantity',mBO_dohledano.GetFieldValueAsFloat('quantity'));
                                                              mRow_targetPR.SetFieldValueAsFloat('Unitprice',(mBO_dohledano.GetFieldValueAsFloat('TAMOUNT')/mBO_dohledano.GetFieldValueAsFloat('quantity')));mpocet:=mpocet-(mBO_dohledano.GetFieldValueAsFloat('quantity')*mBO_dohledano.GetFieldValueAsFloat('unitrate')) ;
                                                          end else begin
                                                              mRow_targetPR.SetFieldValueAsFloat('Quantity',mPocet);
                                                             mRow_targetPR.SetFieldValueAsFloat('Unitprice',(mBO_dohledano.GetFieldValueAsFloat('TAMOUNT')/mBO_dohledano.GetFieldValueAsFloat('quantity')));

                                                              mpocet:=0;
                                                          end;
                                                          //mRow_target.Save;
                                             end;
                                       finally
                                           mBO_dohledano.free;
                                       end;
                                    end;
                            end;
                        finally
                            mr.free;
                        end;
                  end;

              end;
        end;
         if index=0 then begin
            mBO_target.save;     // faktura
        end;
          if index=1 then begin
          mBO_targetPR.save;     // příjemka
        end;
      finally

       if index=0 then begin
         mBO_target.free;
         //mMon_Rows_source.free;
    end;
    if index=1 then begin
         mBO_targetPR.free;
         //mMon_Rows_source.free;
         //mMon_Rows_targetPR.free;
    end;


        // mBO_target.free;
        // mMon_Rows_source.free;
         //mMon_Rows_targetPR.free;
      end;
end;




begin
end.
