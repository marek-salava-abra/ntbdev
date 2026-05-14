
function CreateNxComboEditxx(AName, ACaption: string;
  ALeft, ATop, AWidth, aHeight:integer;
  ALblWidth, AEditwitch,ABevelWidth: Integer;
  AClassID, ATextField, AControlField, AID: string;
  AParent: TWinControl;
  AParam: string = ''; AChange: string =''): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
begin
  if AID = '' then
    AID:= '0000000000';
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;



  Result:= TRollComboEdit.Create(AParent);
  Result.Parent:= AParent;
  Result.ClassID:= AClassID;
  Result.ForcedField:= True;
  Result.Prefilling:= pmNone;
  Result.TextField:= ATextField;
  Result.Parameters.Add(AParam);
  Result.Top:= ATop + 3;
  Result.Left:= ALeft + ALblWidth;

  mLbl1:= TLabel.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.Left:= ALeft+AWidth-ABevelWidth;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
  if AName <> '' then
    mLbl1.Name:= 'lblBev_' + AName;
  mLbl1.Width:= ABevelWidth;
  mLbl1.Visible:= ABevelWidth > 0;

  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= mLbl1;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;


  if (AChange <> '') and (AName <> '') then
  begin
    mLblChange:= TLabel.Create(AParent);
    mLblChange.Parent:= AParent;
    mLblChange.Top:= 0;
    mLblChange.Left:= 0;
    mLblChange.ViSible:= False;
    mLblChange.Name:= 'lblCh_' + AName;
    mLblChange.Caption:= AChange;
    Result.OnChange:= @NxDBComboEditChange;
  end;


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;





function manualcopy_protocol(mbo:TNxCustomBusinessObject):string;
var
   mfilelist,mPAthList:tstringlist;
   i:integer;
   mpath:string;
   mFileName,mfilter,mfile:string;
begin


                   mPAthList:=TStringList.create;
                   try
                      mbo.ObjectSpace.SQLSelect('select max(SR.X_path_protokol) from ServiceAssemblyForms2 SA2 left join SecurityRoles SR on sr.id=Sa2.X_WorkerRole_ID where (SR.X_path_protokol is not null) and SA2.Parent_ID=' + quotedstr(mbo.oid) + ' group by SR.X_path_protokol',mPAthList);
                        if trim(mPAthList.Strings[0])<>'' then begin
                            mpath:='\\192.168.0.3\disk_r\servis_foto\'+mPAthList.Strings[0];
                        end else begin
                            mpath:='\\192.168.0.3\disk_r\servis_foto\';
                        end;

                   finally

                   end;


         if PromptForFileName(mFileName, '', '', 'Dohledejte protokol', mpath, False) then begin
                if mFileName<>'' then begin
                    mpath:=copy(mfilename,0,NxCharPosR('\',mfilename));
                    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
                    if NxCopyFile(mFileName, (Format('%s\%s\%s\%s\%s\%s', ['\\192.168.0.36\abra\Servis', mbo.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),
                        'Servisni listy',mbo.GetFieldValueAsString('ServiceDocument_ID'),'ML',mbo.oid])) +'\'+ mfile)
                        then begin
                            if not DeleteFile(mFileName) then NxShowSimpleMessage('nepodařilo se přesunout protokol, prosím smažte',nil)  ;
                            result:=mFile;
                    end else begin
                            NxShowSimpleMessage('Nepodařilo se překopírovat soubor: ' + mfile,nil);
                    end;
                            //Import_SP_V(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
                            result:=mFileName;
                end;
         end;

end;



function autocopy_protocol(mbo:TNxCustomBusinessObject):string;
var
   mfilelist:tstringlist;
   mPAthList:TStringList;
   i,ii:integer;
   mpath:string;
   mFileName,mfilter:string;
begin
    result:='';
                   mpath:='\\192.168.0.3\disk_r\servis_foto\';
                   mPAthList:=TStringList.create;
                   try
                      mbo.ObjectSpace.SQLSelect('select SR.X_path_protokol from ServiceAssemblyForms2 SA2 left join SecurityRoles SR on sr.id=Sa2.X_WorkerRole_ID where (SR.X_path_protokol is not null) and SA2.Parent_ID=' + quotedstr(mbo.oid) + ' group by SR.X_path_protokol',mPAthList);
                      for ii:=0 to mPAthList.count-1 do begin
                          mfilelist:=TStringList.create;
                            try
                                 NxGetFileList(mpath+mPAthList.Strings[ii],mFileList,'*.*');
                                 for i:=0 to mFileList.count-1 do begin

                                     if pos((mbo.GetFieldValueAsString('X_Protokol_prefix') + mbo.GetFieldValueAsString('X_Protokol')), mfilelist.Strings[i])>0 then begin

                                          if NxCopyFile(mpath+mPAthList.Strings[ii]+'\'+mfilelist.Strings[i], (Format('%s\%s\%s\%s\%s\%s', ['\\192.168.0.36\abra\Servis', mbo.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),
                                          'Servisni listy',mbo.GetFieldValueAsString('ServiceDocument_ID'),'ML',mbo.oid])) +'\'+ mfilelist.Strings[i])
                                          then begin
                                               //NxShowSimpleMessage('Přiložen formulář: ' + mfilelist.Strings[i],nil);
                                               result:=mfilelist.Strings[i];
                                               if not DeleteFile(mpath+mPAthList.Strings[ii]+'\' +mfilelist.Strings[i]) then NxShowSimpleMessage('nepodařilo se přesunout protokol, prosím smažte',nil)  ;
                                          end else begin
                                              NxShowSimpleMessage('Nepodařilo se překopírovat soubor: ' + mfilelist.Strings[i],nil);
                                          end;
                                     end;
                                 end;
                             finally
                                mfilelist.free;
                             end;
                       end;
                   finally
                      mPAthList.free;
                   end;

end;




procedure iFillUnits(ASC : TNxCustomBusinessObject; AList : TStrings);
  var
    i : integer;
    mColl : TNxCustomBusinessMonikerCollection;
  begin
    mColl := ASC.GetLoadedCollectionMonikerForFieldCode(ASC.GetFieldCode('StoreUnits'));
    for i := 0 to mColl.Count - 1 do
      Alist.Add(mColl.BusinessObject[i].GetFieldValueAsString('Code'));
  end;

  procedure iFillStores(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Code FROM Stores WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;

    procedure iFillStorecards(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Code FROM Storecards WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;


procedure New_rekl(AOS: TNxCustomObjectSpace; ASite: TDynSiteForm; mDataset: TNxRowsObjectDataSet);
 var
   self:TNxCustomBusinessObject;
  mHeaderBO: TNxHeaderBusinessObject;
  mResult:string;
adate:Date;
  mMon : TNxCustomBusinessMonikerCollection;
  mNewRow:TNxCustomBusinessObject;

begin


      mHeaderBO := TNxHeaderBusinessObject(aos.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0'));
        try
          mHeaderBO.New;
          mHeaderBO.Prefill;
          mHeaderBO.SetFieldValueAsString('Docqueue_ID', '4I10000101');
          mHeaderBO.SetFieldValueAsString('Description','Reklamace' +
            mDataset.CurrentObject.GetFieldValueAsString('parent_ID.ServiceDocument_ID.Docqueue_ID.Code')+ '-'+
            inttostr(mDataset.CurrentObject.GetFieldValueAsinteger('parent_ID.ServiceDocument_ID.ordnumber')) +'/'+
            mDataset.CurrentObject.GetFieldValueAsString('parent_ID.ServiceDocument_ID.Period_ID.Code')+'-'+
            inttostr(mDataset.CurrentObject.GetFieldValueAsinteger('parent_ID.ordnumber')))

    ;
          mHeaderBO.SetFieldValueAsString('U_Service_object_ID',mDataset.CurrentObject.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServicedObject_ID'));
          //mHeaderBO.SetFieldValueAsString('Description', 'Reklamace_dokladu:');
          mHeaderBO.SetFieldValueAsString('Firm_ID', mDataset.CurrentObject.GetFieldValueAsString('parent_ID.ServiceDocument_ID.PayerFirm_ID'));
          mHeaderBO.SetFieldValueAsString('FirmOffice_ID', mDataset.CurrentObject.GetFieldValueAsString('parent_id.ServiceDocument_ID.PayerFirmOffice_ID'));
          mHeaderBO.SetFieldValueAsString('Person_ID', mDataset.CurrentObject.GetFieldValueAsString('parent_id.ServiceDocument_ID.PayerPerson_ID'));

          mMon := mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('ROWS'));
                                mNewRow := mMon.AddNewObject;
                                mNewRow.SetFieldValueAsInteger('Rowtype', 3);
                                mNewRow.SetFieldValueAsString('Store_ID', '9400000101');
                                mNewRow.SetFieldValueAsString('StoreCard_ID', mDataset.FieldByName('Storecard_ID').Asstring);
                                mNewRow.SetFieldValueAsString('QUnit', mDataset.FieldByName('QUnit').Asstring);
                                mNewRow.SetFieldValueAsFLoat('UnitRate',1 );
                                mNewRow.SetFieldValueAsFLoat('Quantity', mDataset.FieldByName('quantity').AsFloat);
                                mNewRow.SetFieldValueAsString('Division_ID','L000000101');
                                mNewRow.SetFieldValueAsString('BusOrder_ID', mDataset.CurrentObject.GetFieldValueAsString('parent_id.ServiceDocument_ID.BusOrder_ID'));
                                mNewRow.SetFieldValueAsString('BusTransaction_ID', mDataset.CurrentObject.GetFieldValueAsString('parent_id.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                mNewRow.SetFieldValueAsString('X_parent_ID', mDataset.CurrentObject.OID);
                                //mNewRow.SetFieldValueAsBoolean('CompletePrices', False);
                                mNewRow.SetFieldValueAsString('U_Store_ID', mDataset.FieldByName('Store_ID').Asstring);
                                mNewRow.SetFieldValueAsString('X_Store_ID', mDataset.FieldByName('Store_ID').Asstring);


           TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', asite.SiteContext, mHeaderBO);
        finally

        end;
//      mForm.free;
//        mHeaderBO.Free;
end;





function GetBusTransaction_ID(mBO_ML: TNxCustomBusinessObject) : TNxOID;
var
 mOLE_Zarizeni, mRoll_Zarizeni, mOResult_Zarizeni: Variant;
 mOLE_Vyrobce, mRoll_Vyrobce, mOResult_Vyrobce: Variant;
 mOLE_Typ_zarizeni, mRoll_Typ_zarizeni, mOResult_Typ_zarizeni: Variant;
 mOLE_BusOrder, mRoll_BusOrder, mOResult_BusOrder: Variant;
 mids_Zarizeni,mids_Vyrobce,mids_Typ_zarizeni,mids_BusOrder:TStrings;
 mid_Zarizeni,mid_Vyrobce,mid_Typ_zarizeni,mid_BusOrder,mid_busTransaction:String;
 mbo_SP,mbo_SL:TNxCustomBusinessObject;
 begin
     if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin     // obchodní případ
                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Zarizeni_ID')) then begin  // Zarizeni
                            mIDs_Zarizeni:=TStringList.create;
                            mOLE_Zarizeni:= GetAbraOLEApplication;
                            mOResult_Zarizeni:= mOLE_Zarizeni.CreateStrings;
                            mRoll_Zarizeni:= mOLE_Zarizeni.GetRoll('44XM2OZD0UA4PEPGQ5KLM5EH30', 0);
                            if mRoll_Zarizeni.MultiSelectDialog(True, mOResult_Zarizeni) then begin
                                mIDs_Zarizeni.Text:= mOResult_Zarizeni.Text;
                                mID_Zarizeni:= mIDs_Zarizeni.Strings[0];

                            end;

                            mids_Zarizeni.free;
                      end;
                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Vyrobce_ID')) then begin  // Vyrobce
                            mIDs_Vyrobce:=TStringList.create;
                            mOLE_Vyrobce:= GetAbraOLEApplication;
                            mOResult_Vyrobce:= mOLE_Vyrobce.CreateStrings;
                            mRoll_Vyrobce:= mOLE_Vyrobce.GetRoll('JQFREQ2PSRR4JCMPNFHSFR4CUW', 0);
                            if mRoll_Vyrobce.MultiSelectDialog(True, mOResult_Vyrobce) then begin
                               mIDs_Vyrobce.Text:= mOResult_Vyrobce.Text;
                               mID_Vyrobce:= mIDs_Vyrobce.Strings[0];
                            end;
                            mids_Vyrobce.free;
                      end;
                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Typ_zarizeni_ID')) then begin  // Typ_zarizeni
                            mIDs_Typ_zarizeni:=TStringList.create;
                            mOLE_Typ_zarizeni:= GetAbraOLEApplication;
                            mOResult_Typ_zarizeni:= mOLE_Typ_zarizeni.CreateStrings;
                            mRoll_Typ_zarizeni:= mOLE_Typ_zarizeni.GetRoll('LXSSZYZN4ZIO5D10RO0VEVY2NO', 0);
                            if mRoll_Typ_zarizeni.MultiSelectDialog(True, mOResult_Typ_zarizeni) then begin
                               mIDs_Typ_zarizeni.Text:= mOResult_Typ_zarizeni.Text;
                              mID_Typ_zarizeni:= mIDs_Typ_zarizeni.Strings[0];
                            end;
                            mids_Typ_zarizeni.free;
                      end;
  end else begin
     result:=mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID');

  end;

                  if (mid_busTransaction<>'') or (mid_Zarizeni<>'')  then begin
                         mbo_SP:=mBO_ML.ObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                            try
                               mbo_SP.Load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),nil);
                                    if mid_Zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Zarizeni_ID',mid_Zarizeni);
                                    if mid_Vyrobce<>'' then mBO_SP.SetFieldValueAsString('X_Vyrobce_ID',mid_Vyrobce);
                                    if mid_Typ_zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Typ_zarizeni_ID',mid_Typ_zarizeni);
                               mbo_SP.save;
                               mbo_SP.Refresh;
                               result:=mBO_SP.getFieldValueAsString('Bustransaction_ID');

                            finally
                               mbo_SP.free;
                            end;
                  end;





end;





function GetBusOrder_ID(mbo: TNxCustomBusinessObject) : TNxOID;
var
 mbo_busOrder:TNxCustomBusinessObject;
 mUser:TNxCustomBusinessObject;
  mr:TStringList;
   mprefix:string;
   mDivision_Code,mPersNumber,mPeriod:string;
   mID:string;
begin
    result:='';
    mDivision_Code:=copy(mbo.GetFieldValueAsString('CorrectedBy_ID.X_Division_ID.Code'),1,3);
    mPersNumber:=copy(mbo.GetFieldValueAsString('CorrectedBy_ID.ShortName'),1,3);
    mPeriod:=copy(inttostr(NxGetYear(now)),2,3);
    mprefix:='S'+mPeriod + mDivision_Code+mPersNumber+'S' ;
       mr:=tstringlist.create;
           try
             mbo.ObjectSpace.SQLSelect('select max(substring(code from 12 for 4)) from BusOrders where substring(code from 1 for 11)='+quotedstr(mprefix),mr);
             if (mr.Strings[0]<>'') and (mr.Strings[0]<>'0') and (mr.Strings[0]<>'""') then begin
                mid:=mprefix+NxPadL(inttostr(strtoint(mr.Strings[0])+1),4,'0');
             end else begin
                mid:=mprefix+'0001';
             end;


             mbo_busOrder:=mbo.ObjectSpace.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                    try
                        mbo_busOrder.new;
                        mbo_busOrder.Prefill;
                        mbo_busOrder.SetFieldValueAsString('Code',mid);
                        mbo_busOrder.SetFieldValueAsString('Name',mbo.GetFieldValueAsString('Name'));

                        mbo_busOrder.Save;
                        result:= mbo_busOrder.oid;
                    finally
                        mbo_busOrder.free;
                    end;


           finally
              mr.free;
           end;

end;









  function iSelectServiceDocqueue(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('W2XNBCJK3ZD13ACL03KIU0CLP4', 0);
  mRoll.Params.Add('FilterDocumentType=SL');
  Result := mRoll.SelectDialog2(true, mXX);
end;

  function iSelectSP(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);
  Result := mRoll.SelectDialog2(true, mXX);
end;




function Vyskladneni_zasob(xSite:TSiteForm;mBO_ML:TNxCustomBusinessObject;mdate:date):string;
Var
mBO_target: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon,mMonBatch: TNxCustomBusinessMonikerCollection;
  mRow,mRowBatch, mNewRow,mNewRowBatch: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr2:TStringList;
  mpocet:double;
  mpokracovat:Boolean;
  mFalseStore:Boolean;
   mOLE, mRoll, mOResult: Variant;
  mid:string;
begin
  result := '';
  mFalseStore:=false;
  mBO_target := mBO_ML.ObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');
  try

  if not nxisblank(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.Bustransaction_ID')) then begin
  // vyskladnění jen při vyplněnén obchodním případě.

                            mpokracovat:=true;
                            mBO_target.New;
                            mBO_target.Prefill;


                        mBO_target.SetFieldValueAsString('DocQueue_ID', 'ME00000101');

                        mBO_target.SetFieldValueAsDateTime('DocDate$Date',mdate);
                        mBO_target.SetFieldValueAsString('Firm_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.PayerFirm_ID'));
                        mBO_target.SetFieldValueAsString('Person_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.PayerPerson_ID'));
                        mBO_target.SetFieldValueAsString('FirmOffice_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.PayerFirmOffice_ID'));
                        mBO_target.SetFieldValueAsString('Description',copy(
                                    mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
                                    inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
                                    mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')+'-'+
                                    inttostr(mBO_ML.GetFieldValueAsInteger('ordnumber')),1,149));

                            mMon := mBO_ML.GetLoadedCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('ROWS'));
                            mList := TStringList.Create;
                            try
                              for i := 0 to mMon.Count-1 do begin
                                mRow := mMon.BusinessObject[i];
                                mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                        //        if mRow.GetFieldValueAsString('Store_ID')='M000000101' then begin ;
                        //            mFalseStore:=true;
                        //        end;
                               mpocet:=mRow.GetFieldValueAsFLoat('Quantity') - mRow.GetFieldValueAsFLoat('QuantityDelivered');

                                if mpocet>0 then begin
                                    if mRow.GetFieldValueAsBoolean('X_storno')= false then begin

                                        mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
                                    end;
                                    {try
                                    mr2:=TStringList.create;
                                    mBO_target.ObjectSpace.SQLSelect('select sum(quantity) from StoreSubCards where StoreCard_ID=' + quotedstr(mRow.GetFieldValueAsstring('StoreCard_ID')) + ' AND Store_ID=' + quotedstr(mRow.GetFieldValueAsstring('Store_ID')),mr2);
                                    if mr2.count>0 then  begin
                                          if NxIBStrToFloat(mr2.Strings[0])>=mpocet then begin
                                             mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
                                          end else begin
                                              mpokracovat:=false;

                                          end;
                                          mr2.free;
                                    end ;
                                    finally
                                    end;  }
                                end ;

                              end;
                            finally
                            end;


                                if (mlist.Count>0) then begin

                                          mList.Sort;
                                          mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
                                          for i := 0 to mList.Count-1 do begin
                                            mRow := TNxCustomBusinessObject(mList.Objects[i]);
                                            if mRow.GetFieldValueAsInteger('ItemType')=1 then begin
                                              mNewRow := mMon.AddNewObject;
                                              mNewRow.SetFieldValueAsInteger('RowType', 3);
                                              mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
                                              mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));


                                              mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                              mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                                              mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity')-mRow.GetFieldValueAsFloat('QuantityDelivered'));
                                              //mRow.SetFieldValueAsFLoat('QuantityDelivered', mNewRow.getFieldValueAsFLoat('Quantity'));
                                              mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                                              mNewRow.SetFieldValueAsString('Division_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Division_ID'));
                                              mNewRow.SetFieldValueAsString('BusOrder_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusOrder_ID'));
                                              mNewRow.SetFieldValueAsString('BusTransaction_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                              mNewRow.SetFieldValueAsString('X_parent_ID', mRow.OID);
                                        {      if mNewRow.getFieldValueAsinteger('StoreCard_ID.Category')=1 then begin  // sériové číslo
                                                mMonBatch:= mNewRow.GetLoadedCollectionMonikerForFieldCode(mNewRow.GetFieldCode('DocRowBatches'));
                                                for II:=0 to Trunc(mNewRow.getFieldValueAsFLoat('Quantity')) do begin
                                                       mOLE:= GetAbraOLEApplication;
                                                        mOResult:= mOLE.CreateStrings;
                                                        mRoll:=mOLE.GetRoll('C2BQY04KTVDL342W01C0CX3FCC', 0);
                                                            if not mRoll.multiSelectDialog(true,mOResult) then Exit;
                                                                  mid:=copy(mOResult.Text,1,10);
                                                                  //'K3TH0HR5TZDL342W01C0CX3FCC'
                                                                  mNewRowBatch:= mMonBatch.AddNewObject;
                                                                  mNewRowBatch.SetFieldValueAsBoolean('NewBatch',false);
                                                                  mNewRowBatch.SetFieldValueAsString('StoreBatch_ID ',mid);
                                                                  mNewRowBatch.SetFieldValueAsFloat('Quantity',1);
                                                            end;
                                                end; }
                                              //mNewRow.Save;
                                            end;
                                          end;
                                     tDynSiteForm.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', xsite.SiteContext, mBO_target);

                                     {
                                      if mList.count>0 then begin
                                      mList.free;
                                            if Not mBO_target.Validate() then begin
                                              mList := TStringList.Create;
                                              try
                                                    mBO_target.GetValidateErrors(mList);
                                                    mText := mList.Text;
                                                    NxToken(mText, '=');
                                                    MessageDlg('Automaticky vytvořený DL nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                      mtWarning, [mbOK], 0);
                                                      mList.Free;
                                              finally

                                              end;
                                            end else begin
                                                    mBO_target.Save;
                                                    result := mBO_target.OID;    }
                                                   //    mBO_target.Load(mBO_target.oid,nil);
                                                   //    mBO_target.SetFieldValueAsString('MasterDocCLSID','BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                   //    mBO_target.SetFieldValueAsString('MasterDocument_ID',mBO_ML.GetFieldValueAsString('ServiceDocument_ID'));
                                                   //    mBO_target.Save;


                                            //end;
                                     //end;

                        //       end else begin
                        //                 if (mpokracovat=true) then NxShowSimpleMessage('Některé zboží není skladem, není možné pokračovat',nil)   ;
                        //                 if (mlist.Count>0) then  NxShowSimpleMessage('Není co vyskladňovat',nil)   ;
                        //                 if (mFalseStore=true) then NxShowSimpleMessage('Nemáte oprávnění vyskladňovat ze skladu 212, před vyskladněním prosím opravte',nil)   ;
                               end;

  end else begin
      NxShowSimpleMessage('Na servisovaném předmětu není vyplněn obchodní případ, není možné odepsat zboží. Nejprve doplňte.',nil);
  end;
  finally
    mBO_target.Free;
  end;
end;

function zajisteni_zasob(xSite:TSiteForm;mBO_ML:TNxCustomBusinessObject;aDate:Date):string;
Var
mBO_target: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mfind:boolean;
  mr,mr1:tstringlist;
  m_pocet:integer;
  mi:integer;
begin
  m_pocet:=0;
  result := '';
  mBO_target := mBO_ML.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
  mfind:=false;
  try
    mBO_target.New;
    mBO_target.Prefill;
    mBO_target.SetFieldValueAsString('Firm_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.PayerFirm_ID'));
    if NxIsEmptyOID(mBO_target.getFieldValueAsString('Firm_ID')) then begin
       mBO_target.SetFieldValueAsString('Firm_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Firm_ID'));
    end;
    mBO_target.SetFieldValueAsString('U_Provozovatel_id', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.X_id_zakaznika_id'));
    mBO_target.SetFieldValueAsString('Description',copy(
            mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
            inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
            mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')+'-'+
            inttostr(mBO_ML.GetFieldValueAsInteger('ordnumber')),1,149))

    ;
    mBO_target.SetFieldValueAsString('ExternalNumber',copy(
            mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
            inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
            mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')+'-'+
            inttostr(mBO_ML.GetFieldValueAsInteger('ordnumber')),1,30))

    ;


    mBO_target.SetFieldValueAsString('DocQueue_ID', '1Q10000101');
    mMon := mBO_ML.GetLoadedCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('ROWS'));
    mList := TStringList.Create;
    try
          for i := 0 to mMon.Count-1 do begin
            mRow := mMon.BusinessObject[i];
            if NxIsEmptyOID(mrow.GetFieldValueAsString('X_firm_ID')) then begin
                    if (mrow.GetFieldValueAsInteger('ItemType')=1) and (mrow.GetFieldValueAsBoolean('X_storno1')=false) then begin
                            mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                            mr:=tstringlist.create;
                            mBO_target.ObjectSpace.SQLSelect('Select io2.quantity from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where io.DocQueue_ID=' + quotedstr('1Q10000101') +
                             ' and io2.X_parent_id=' + quotedstr(mrow.GetFieldValueAsString('ID')),mr);
                               if mr.count>0 then begin
                                      mfind:=true;
                               end else begin
                                      mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
                                      if mrow.GetFieldValueAsInteger('ItemType')=1 then begin
                                          mrow.SetFieldValueAsString('X_Stav_sklad_technika','5VH1000101');
                                          mrow.SetFieldValueAsString('U_Stav_sklad_technika','Poptáváno');
                                      end;
                               end;
                    end;
             end;
          end;
      mList.Sort;
      if mfind then NxShowSimpleMessage('Pozor, operace již byly provedena dříve, nová objednávka pouze doplní neobjednané zboží',nil);
      mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
            for i := 0 to mList.Count-1 do begin
              mRow := TNxCustomBusinessObject(mList.Objects[i]);
                  if mRow.GetFieldValueAsInteger('ItemType')=1 then begin
                  m_pocet:=m_pocet+1;
                    mNewRow := mMon.AddNewObject;
                    mNewRow.SetFieldValueAsInteger('RowType', 3);
                    mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
                    mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                    mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                    mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                    mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                    mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                    mNewRow.SetFieldValueAsString('X_description', copy(mRow.GetFieldValueAsString('X_description'),1,149));
                    mNewRow.SetFieldValueAsString('Division_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Division_ID'));
                    mNewRow.SetFieldValueAsDateTime('DeliveryDate$Date',aDate);
                    mNewRow.SetFieldValueAsString('BusOrder_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusOrder_ID'));
                    mNewRow.SetFieldValueAsString('BusTransaction_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                    mNewRow.SetFieldValueAsString('X_parent_ID', mRow.OID);
                    mNewRow.SetFieldValueAsString('X_HeadParent_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
                        inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
                        mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')+'-'+
                        inttostr(mBO_ML.GetFieldValueAsInteger('ordnumber'))) ;
                  end;
            end;
    finally
    end;
    TDynSiteForm.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', xsite.SiteContext, mBO_target);

 { if mList.Count>0 then  begin
    mList.Free;
    mBO_target.ClearValidateErrors;
    if Not mBO_target.Validate() then begin
      mList := TStringList.Create;
      try
        mBO_target.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Automaticky vytvořenou OV nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
    end else begin
      if m_pocet=0 then begin
          NxShowSimpleMessage('Doklad neobsahuje žádné řádky, nebude uložen',nil);
      end else begin
            mBO_target.Save;
            result := mBO_target.OID;
            mfind:=false;

      end;
    end;

   end;  }


   mr:=tstringlist.create;
   try
   mBO_ML.ObjectSpace.SQLSelect('select io2.parent_id from ServiceAssemblyForms2 SA2 left join IssuedOffers2 IO2 on io2.X_parent_ID=sa2.id where sa2.parent_id=' + quotedstr(mbo_ml.oid) + ' and not(io2.parent_id is null) group by io2.parent_id',mr);
   if mr.count>0 then begin
       for i := 0 to mr.Count - 1 do   begin
            mi:=mBO_ML.ObjectSpace.SQLExecute('update IssuedOffers set OfferState_ID=' + quotedstr('3100000101') + ' where id='+quotedstr(mr.Strings[i]));
       end;
   end;
   finally
     mr.free;
   end;
      xsite.Refresh;
  finally
      mBO_target.Free;
  end;

end;


function zajisteni_subdodavky(xSite:TSiteForm;mBO_ML:TNxCustomBusinessObject;aDate:Date):string;
Var
mBO_target,mBO_source: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mfind:boolean;
  mr,mr1:tstringlist;
  m_pocet:integer;
  mfirm_ID:String;
begin
  mr1:=tstringlist.Create;
  try
      mfirm_id:='';
      xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms2 where X_firm_id is not null and parent_ID=' + QuotedStr(mBO_ML.oid) + ' order by X_Firm_ID',mr1);
      if mr1.count>0 then begin
          for i := 0 to mr1.Count-1 do begin
            mbo_source:=xsite.BaseObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
              try
              mBO_source.load(mr1.Strings[i],nil);


                if (mfirm_ID<>mBO_source.GetFieldValueAsString('X_firm_ID')) and (i<>0) then begin
                         TDynSiteForm.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', xsite.SiteContext, mBO_target);
                                                   mBO_target.free;
                                        end;  // uložení dokladu

                if i=0 then begin

                     mBO_target := mBO_ML.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                      mBO_target.New;
                          mBO_target.Prefill;
                          mBO_target.SetFieldValueAsString('Firm_ID', mBO_source.GetFieldValueAsString('X_Firm_ID'));
                          mBO_target.SetFieldValueAsString('U_Provozovatel_id', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.X_id_zakaznika_id'));
                          mBO_target.SetFieldValueAsString('Description',copy(
                                  mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
                                  inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
                                  mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')+'-'+
                                  inttostr(mBO_ML.GetFieldValueAsInteger('ordnumber')),1,149))

                          ;
                          mBO_target.SetFieldValueAsString('DocQueue_ID', '2G20000101');
                          mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));

                  end else begin
                      if mBO_source.getFieldValueAsString('X_Firm_ID')<>mBO_target.getFieldValueAsString('Firm_ID') then begin
                          mBO_target := mBO_ML.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');

                          mBO_target.New;
                          mBO_target.Prefill;
                          mBO_target.SetFieldValueAsString('Firm_ID', mBO_source.GetFieldValueAsString('X_Firm_ID'));
                          mBO_target.SetFieldValueAsString('U_Provozovatel_id', mBO_ml.GetFieldValueAsString('ServiceDocument_ID.X_id_zakaznika_id'));
                          mBO_target.SetFieldValueAsString('Description',copy(
                                  mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
                                  inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
                                  mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')+'-'+
                                  inttostr(mBO_ML.GetFieldValueAsInteger('ordnumber')),1,149));
                          mBO_target.SetFieldValueAsString('DocQueue_ID', '7J00000101');
                          mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));

                      end;
                  end;  // hlavička dokladu



                  if (mBO_source.GetFieldValueAsInteger('ItemType')=4) and not NxIsEmptyOID(mBO_source.GetFieldValueAsstring('X_firm_ID'))
                  and (mBO_source.GetFieldValueAsBoolean('X_storno1')=false) then begin
                            mPosIndex := mBO_source.GetFieldValueAsInteger('PosIndex');
                            mr:=tstringlist.create;
                            mBO_target.ObjectSpace.SQLSelect('Select io2.quantity from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where io.DocQueue_ID=' + quotedstr('7J00000101') +
                             ' and io2.X_parent_id=' + quotedstr(mBO_source.oid),mr);
                               if mr.count>0 then begin
                                      NxShowSimpleMessage('Pozor, operace již byly provedena dříve, nová objednávka pouze doplní neobjednané dodávky',nil);
                               end else begin
                                          m_pocet:=m_pocet+1;
                                          mNewRow := mMon.AddNewObject;
                                          mNewRow.SetFieldValueAsInteger('RowType', 2);
                                          //mNewRow.SetFieldValueAsString('Text', mBO_source.GetFieldValueAsString('Text'));
                                          //mNewRow.SetFieldValueAsString('StoreCard_ID', mBO_source.GetFieldValueAsString('StoreCard_ID'));
                                          mNewRow.SetFieldValueAsString('Text', mBO_source.GetFieldValueAsString('Text'));
                                          mNewRow.SetFieldValueAsFLoat('Quantity', mBO_source.GetFieldValueAsFloat('Quantity'));
                                          mNewRow.SetFieldValueAsString('QUnit', mBO_source.GetFieldValueAsString('QUnit'));
                                          //mNewRow.SetFieldValueAsFLoat('UnitRate', mBO_source.GetFieldValueAsFloat('UnitRate'));


                                          mNewRow.SetFieldValueAsString('X_description', copy(mBO_source.GetFieldValueAsString('X_description'),1,149));
                                          mNewRow.SetFieldValueAsString('Division_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Division_ID'));
                                          mNewRow.SetFieldValueAsDateTime('DeliveryDate$Date',aDate);
                                          mNewRow.SetFieldValueAsString('BusOrder_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusOrder_ID'));
                                          mNewRow.SetFieldValueAsString('BusTransaction_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                          mNewRow.SetFieldValueAsString('X_parent_ID', mBO_source.OID);
                                          mNewRow.SetFieldValueAsString('X_HeadParent_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
                                                inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
                                                mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')+'-'+
                                                inttostr(mBO_ML.GetFieldValueAsInteger('ordnumber'))) ;
                                          //mNewRow.Save;
                               end;
                    end;

                 if (i=mr.count-1)  then begin
                         TDynSiteForm.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', xsite.SiteContext, mBO_target);
                         //mBO_target.free;

                 end;  // uložení dokladu

                  mfirm_ID:=mBO_source.GetFieldValueAsString('X_Firm_ID');
                finally
                    mBO_source.free;
                end;


              end;

              //if (i=mr.count-1)  then begin
                         TDynSiteForm.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', xsite.SiteContext, mBO_target);
                         //mBO_target.free;

          //       end;  // uložení dokladu


      end else begin
          NxShowSimpleMessage('Není možné vytvořit objednávku',nil);
      end;





  finally
     mr1.free;
  end;

end;


function  Mformx(xSite:TSiteForm;mLabel:string;mDescription:string;mbuton1:string;mbuton2:string;mbuton3:string;mbuton4:string):Variant;
var
mform:tform;
mBtn : TButton;
mlabel2:TLabel;
begin
            mForm := TForm.Create(xsite);
                                  mForm.Caption := mLabel;
                                  mForm.FormStyle := fsStayOnTop;
                                  mForm.BorderStyle := bsDialog;
                                  mForm.Width := 400;
                                  mForm.Height := 100;
                                  mForm.Scaled := False;
                                  mform.Position := poScreenCenter;

                                  mLabel2 := TLabel.Create(mForm);
                                              mLabel2.Parent := mForm;
                                              mLabel2.Caption := mDescription;
                                              mLabel2.Top := 10;
                                              mLabel2.Left := 10;
                                              mLabel2.Height := 13;


                                if not NxIsBlank(mbuton1) then begin
                                      mBtn := TButton.Create(mForm);
                                      mBtn.Width := 90;
                                      mBtn.Height := 25;
                                      mBtn.Caption := mbuton1;
                                      mBtn.ModalResult := mrOk;
                                      mBtn.Cancel := False;
                                      mBtn.Default := True;
                                      mBtn.Left :=  mForm.Width - 4*(mBtn.Width+2) - 20;
                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                      mBtn.Name := 'btnOK';
                                      mForm.InsertControl(mBtn);
                                end;

                                if not NxIsBlank(mbuton2) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton2;
                                    mBtn.ModalResult := mrYes;
                                    mBtn.Cancel := False;
                                    mBtn.Default := True;
                                    mBtn.Left :=  mForm.Width - 3*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnyes';
                                    mForm.InsertControl(mBtn);
                                end;

                                if not NxIsBlank(mbuton3) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton3;
                                    mBtn.ModalResult := mrCancel;
                                    mBtn.Cancel := False;
                                    mBtn.Default := True;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnCancel';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton4) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton4;
                                    mBtn.ModalResult := mrIgnore;
                                    mBtn.Cancel := True;
                                    mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnIgnore';
                                    mForm.InsertControl(mBtn);

                                end;

                                result:=mForm.ShowModal(xSite)



end;


function CNExecuteItem(mBO_ML:TNxCustomBusinessObject;xSite:TDynSiteForm;mRows_ml:TNxCustomBusinessMonikerCollection;mids_mlRow:TStringList):string;
var
 mresult:Boolean;
 mtext:string;
 mbo_CN:TNxCustomBusinessObject;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mrxx:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
 mbookmark:TBookmarkList;
begin
     result:='';
                    {     mIDs_MLRow:=TStringList.create;
                         mrxx:=TStringList.create;
                         try
                                mBO_ML.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.id=' + quotedstr(mBO_ML.OID)+' order by PosIndex',mrxx);
                                for ii := 0 to mrxx.Count-1 do begin // projdu vsechny oznacene zaznamy
                                     mIDs_MLRow.Add(mrxx.Strings[ii]);
                                end;
                         finally
                             //mbo1.free;   nesmi byt jedna se o CurrentObject~~
                             mrxx.free;
                         end;
                               }

                try
                mbo_CN:= mbo_ML.ObjectSpace.CreateObject('LN2RG42OWZVODHSAIXNA5PY1PS');
                mBO_CN.New;
                mbo_CN.Prefill;
                mbo_CN.SetFieldValueAsString('IssuedOfferType_ID','1000000101');
                mbo_CN.SetFieldValueAsString('Docqueue_ID', '1E10000101');
                mbo_CN.SetFieldValueAsString('Firm_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.PayerFirm_ID'));

                mbo_CN.SetFieldValueAsString('Description',
                  mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
                  inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
                  mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')) ;
                mbo_CN.SetFieldValueAsString('ExternalNumber',
                  mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID.Code') + '-'+
                  inttostr(mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ordnumber')) +'/'+
                  mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.Period_ID.Code')) ;



                mbo_CN.SetFieldValueAsString('FirmOffice_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.PayerFirmOffice_ID'));
                mbo_CN.SetFieldValueAsString('Person_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.payerPerson_ID'));
                mbo_CN.SetFieldValueAsString('PaymentType_ID', mBO_ML.GetFieldValueAsString('ServiceDocument_ID.X_PaymenType_ID'));
                mbo_CN.SetFieldValueAsBoolean('IsRowDiscount',true);
                mbo_CN.SetFieldValueAsDateTime('DeadLineToSend$DATE',now+7);

                mbo_CN.SetFieldValueAsDateTime('ValidTill$DATE',now+90);

                mbo_CN.SetFieldValueAsString('ActualSolverRole_ID','4200000101');
                              try
                              mMon := mbo_CN.GetLoadedCollectionMonikerForFieldCode(mbo_CN.GetFieldCode('ROWS'));

                                  mRow:= mbo_CN.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                                  for i := 0 to mIDs_MLRow.Count-1 do begin
                                                try
                                                  mRow.Load(mIDs_MLRow.Strings[i],nil);
                                                  if mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT')>0 then begin
                                                          mNewRow := mMon.AddNewObject;

                                                              if mRow.GetFieldValueAsDateTime('X_konec_prace')>mdate then  mdate:=mRow.GetFieldValueAsDateTime('X_konec_prace');

                                                              if mRow.GetFieldValueAsInteger('ItemType')=0 then begin
                                                                     mNewRow.SetFieldValueAsInteger('RowType', 2);
                                                                     mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                                     mNewRow.SetFieldValueAsString('VATRate_ID', mRow.GetFieldValueAsString('VATRate_ID'));
                                                                     mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('WorkHoursReal'));
                                                                     if (mRow.GetFieldValueAsstring('Text')= 'Paušál doprava') or (mRow.GetFieldValueAsstring('Text')= 'Doprava km') then begin
                                                                            mNewRow.SetFieldValueAsString('BusTransaction_ID','4870000101')
                                                                      end else begin
                                                                           mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                                                      end;
                                                              end;


                                                              if mRow.GetFieldValueAsInteger('ItemType')=1 then begin
                                                                      mNewRow.SetFieldValueAsInteger('RowType', 3);
                                                                      mNewRow.SetFieldValueAsString('Store_ID',mRow.GetFieldValueAsString('Store_ID'));
                                                                      mNewRow.SetFieldValueAsString('StoreCard_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                      mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                                      mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                                      if NxIsEmptyOID(mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID')) then begin
                                                                         mNewRow.SetFieldValueAsString('BusTransaction_ID','');
                                                                      end else begin
                                                                         mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                                                      end;
                                                              end;
                                                              if mRow.GetFieldValueAsInteger('ItemType')>1 then begin
                                                                      mNewRow.SetFieldValueAsInteger('RowType', 2);
                                                                      mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                                      mNewRow.SetFieldValueAsString('VATRate_ID', mRow.GetFieldValueAsString('VATRate_ID'));
                                                                      mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                                                      if mRow.GetFieldValueAsFloat('Quantity')=0 then begin
                                                                          mNewRow.SetFieldValueAsInteger('Quantity',1);
                                                                      end else begin
                                                                          mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                                      end;
                                                                      if mRow.GetFieldValueAsString('QUnit')='' then begin
                                                                          mNewRow.SetFieldValueAsString('QUnit', 'ks');
                                                                      end else begin
                                                                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                                      end;



                                                              end;



                                                          mNewRow.SetFieldValueAsString('Division_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.Division_ID'));
                                                          mNewRow.SetFieldValueAsString('BusOrder_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.BusOrder_ID'));
                                                          mNewRow.SetFieldValueAsFLoat('UnitPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                          mNewRow.SetFieldValueAsFLoat('RowDiscount', mRow.GetFieldValueAsFloat('X_radkova_sleva'));
                                                          mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('ID'));
                                                           mNewRow.SetFieldValueAsString('X_Description', mRow.GetFieldValueAsString('X_Description'));
                                                       mNewRow.free;




                                                  end;







                                                  finally
                                                  end;
                                  end;

                             finally
                                  mrow.free;

                              end;

                 result:=mbo_CN.oid;
              finally

              end;
                 xSite.ShowDynFormWithNewDocument('O1C4ERBIVNIOT4WASH5MYY14CK', xSite.SiteContext, mBO_CN);
                 mbo_CN.Free;
          //  mIDs_MLRow.free;
end;





function Fakturacni_ceny(mBO_ML:TNxCustomBusinessObject;xSite:TSiteForm;mRows_ML:TNxCustomBusinessMonikerCollection;mstav:string):boolean;
var
  mxpomoc:double;
   mi:integer;
   mBO_BusProject,mRow,mNewRow, mbo1,mbo_ml_target_row: TNxCustomBusinessObject;
   mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
   mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
   // doby + termíny
   mF_doba:double;
   mF_Prace_od,mF_Prace_do:double;                  // jen časová část
   mF_Prac_doba_zac,mF_Prac_doba_kon:double;        // jen časová část
   // sazby
   mFSazba_Prace_pausal:double;
   mFSazba_Prace:double;
   mFSazba_Mimo:double;
   mFSazba_Vikend:double;
   mFSazba_Svatek:double;
   mFSazba_Doprava_km:double;
   mFSazba_Doprava_pausal:double;
   mFPriplatek3H:double;
   // počty (množství)
   mF_Mnozstvi_Prace_pausal:double;
   mF_Mnozstvi_Prace:double;
   mF_Mnozstvi_mimo:double;
   mF_Mnozstvi_vikend:double;
   mF_Mnozstvi_svatek:double;
   mF_Mnozstvi_Doprava_km:double;
   mF_Mnozstvi_Doprava_pausal:double;
  mstore_id:string;
  mMon : TNxCustomBusinessMonikerCollection;
    mresult:boolean;

  mOrderRow,mNewRows: TNxCustomBusinessObject;
  mPosIndex:integer;
  mDateFrom,mDateto:Double;
  mDatezac,mDatekon:Double;
  mPRzac,mPRkon:Double;
  msleva:integer;
 mF_svatek:double;
 mF_vikend:double;
 mF_mimo:double;
 mFS_svatek:double;
 mFS_vikend:double;
 mFS_mimo:double;
 mFS_prace:double;
  mrole_id:string;
 mDnu:integer;
 mOpakovani:integer;
 mrta: tstringlist ;
 mStore:string;
  mForm1 : TForm;
  mBtn : TButton;
  mKonecDAte:TDateTimeEdit;
  mKonecTime:TTimeEdit;
  mL_Technik,mL1_C_Protokol,mL1_pohotovost,mL1_C_Chyby,mL_technik_value,mL_technik1_value:TLabel;
  mL_operation,mL1_operation:TLabel ;
  mEd1_pohotovost:TCheckBox;
  mEd1_C_chyby,mEd1_C_protokol:tedit;
  mEd1_quantity,mEd_quantity,mEd_Unitprice:TEdit;
  mEd_quantity1,mEd_Unitprice1:TEdit;
  mEd_quantity2,mEd_Unitprice2:TEdit;
  mEd_quantity3,mEd_Unitprice3:TEdit;
  mEd_quantity4,mEd_Unitprice4:TEdit;
  mEd_quantity5,mEd_Unitprice5:TEdit;
  mEd_quantity6,mEd_Unitprice6:TEdit;
  mEd_quantity7,mEd_Unitprice7:TEdit;
  mEd_quantity8,mEd_Unitprice8:TEdit;
  mEd_quantity9,mEd_Unitprice9:TEdit;
  mEd_quantity10,mEd_Unitprice10,mED1_P_Cyklu:TEdit;
  mquantity:double;
  mWorkHoursReal:Double;
  mkorekce:Double;
  mpocet_km:Double;
mLabel1,mLblm,mLbl1,mLbl2,mLbl0,mLbl3,mLabel3 ,mL1_P_Cyklu: TLabel;
mpausal,mpausal_oprava:double;
mpocet:integer;
mr:TStringList;
mpocet1:integer;
mI_MLRow:Integer;
md_ML_start,mD_ML_END:double;
mRow_Pomoc:TNxCustomBusinessObject;
mList_pomoc:tstringlist;
i,i01,ii:integer;
mWorkerRole_id:string;
mbo_SecurityRole:TNxCustomBusinessObject;
mpokracovat:boolean;
begin
   // rozpočet fakturace
   mpokracovat:=true;
   result:=false;
   mpocet1:=0;


                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='1A20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='5B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='7B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                 if true then begin  // není fakturován
                                                          mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_prace:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mFPriplatek3H:=0;mPRzac:=0;mPRkon:=0;


                                                              // ceny z projektu

                                                                 if not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                        mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                       try
                                                                         mBO_BusProject.load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID'),nil);
                                                                          if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='4B20000101') Or
                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='6B20000101') Or
                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') or
                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='8B20000101') or
                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='9B20000101') or
                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='AB20000101')
                                                                          then begin
                                                                                  if(mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal')>0) then mF_pausal_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal');
                                                                          end;
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then  mFSazba_Doprava_pausal:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                          mFSazba_Doprava_km:=0;
                                                                          if mF_pausal_Vyjezd=0 then begin
                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                          end;
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod')>0) then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');
                                                                    finally
                                                                      mBO_BusProject.free;
                                                                    end;

                                                               end ;
                                                               //if NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                      try
                                                                        // ceny z fakturační oblasti
                                                                        mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                        if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                            NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                            mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                                        end;
                                                                        if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                            mBO_BusProject.load('2130000101',nil);
                                                                        end;
                                                                        if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                            mBO_BusProject.load('3130000101',nil);
                                                                        end;

                                                                        if mFSazba_prace=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                        if mFSazba_mimo=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                        if mFSazba_vikend=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                        if mFSazba_svatek=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');

                                                                        if mFSazba_Doprava_pausal=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then mFSazba_Doprava_pausal:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                        if mFSazba_Doprava_pausal=0 then begin
                                                                            if mFSazba_Doprava_km=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                        end;



                                                                        if mPRzac=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                        if mPRkon=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                        if mFPriplatek3H=0 then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');

                                                                     finally
                                                                          mBO_BusProject.free;
                                                                     end;
                                                              //end;
                          if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101')  or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') then begin
                                                                     mrta:=tstringlist.create;
                                                                     try
                                                                                mBO_ML.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms2 where ItemType=0 and ((storecard_ID='+ QuotedStr('2ZI1000101')+
                                                                                ') or (storecard_ID='+ QuotedStr('11J1000101')+')) and (parent_id=' + quotedstr(mBO_ML.oid)+ ')',mrta);
                                                                             if mrta.count>0 then mpocet1:=mrta.count;
                                                                     finally
                                                                          mrta.free;
                                                                     end;

                                                                     if (mpocet1>0) and mpokracovat then begin
                                                                          mList_pomoc:= TStringList.Create;
                                                                                         try
                                                                                                 for mI_MLRow := 0 to mRows_ML.Count - 1 do begin
                                                                                                      if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 )then begin
                                                                                                            mWorkerRole_ID:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('X_WorkerRole_ID');

                                                                                                          if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                                                (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101') then begin
                                                                                                                mForm1 := TForm.Create(xSite);mForm1.Caption := 'Rozpočtení paušálu';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;
                                                                                                                      mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                      mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Počet tech.:';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                      mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := inttostr(mpocet1);mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                      mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                      mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 250;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                      mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecTime.Enabled:= True;
                                                                                                                      mForm1.InsertControl(mKonecTime);
                                                                                                                      mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Cena :';mL_operation.Top := 10;mL_operation.Left := 450;mL_operation.Height := 150;mL_operation.Width := 80;
                                                                                                                      mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 510;mEd_quantity.Top := 10;mEd_quantity.Width := 100;mEd_quantity.Name := 'mEd_quantity';mEd_quantity.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_quantity);
                                                                                                                      mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 10; mL1_operation.Left := 520;mL1_operation.Height := 13;mL1_operation.Width := 150;
                                                                                                                      mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 660;mEd1_quantity.Top := 10;mEd1_quantity.Width := 100;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:='0';mForm1.InsertControl(mEd1_quantity);
                                                                                                                      mL1_C_protokol:= TLabel.Create(mForm1);
                                                                                                                      mL1_C_protokol.Parent := mForm1; mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 800;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                      mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 880;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                      mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1000;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                      mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10; mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                      mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                      mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250; mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                                      mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                      mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                         if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                   mpokracovat:=true;
                                                                                                                                   mpausal:=trunc(100/mpocet1)*0.01;
                                                                                                                                   mpausal_oprava:=1-(mpocet1*mpausal);
                                                                                                                                   mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                                       mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                                       mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));
                                                                                                                                       mF_pausal_prace:=NxIBStrToFloat(mEd_quantity.text);


                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',mF_pausal_prace);
                                                                                                                                                    mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                                                                    mWorkHoursReal:=mpausal + mpausal_oprava;
                                                                                                                                                    mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                                                    mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                                                    mstore:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Store_id');
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal) ;

                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                    mPosIndex := mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsInteger('PosIndex');
                                                                                                                                                    mquantity:=mWorkHoursReal;

                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);

                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('X_osoba', mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsString('X_WorkerRole_ID.Name'));
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                    //mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',0);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal) ;
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','ks');
                                                                                                                                                    //mRows_ML.BusinessObject[i].SetFieldValueAsinteger('IsInvoiced',1);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);


                                                                                                                                                     mpausal_oprava:=0
                                                                                                                            end else begin
                                                                                                                            mpokracovat:=false;
                                                                                                                            end;
                                                                                                          end;

                                                                                                      end;
                                                                                                 end;
                                                                                                 for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                                      mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                                      mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID');
                                                                                                                        mNewRow := mRows_ML.AddNewObject;
                                                                                                                        mNewRow.SetFieldValueAsInteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                                                                                        //mNewRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                                                                                        mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                                                                                        mNewRow.SetFieldValueAsString('X_Osoba',mNewRow.GetFieldValueAsString('X_WorkerRole_ID.Name'));
                                                                                                                        mNewRow.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                        mNewRow.SetFieldValueAsString('Text','Paušál práce');
                                                                                                                        mNewRow.SetFieldValueAsString('Store_id',mStore);
                                                                                                                        mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');
                                                                                                                        mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mRow_Pomoc.GetFieldValueAsFloat('Quantity'));
                                                                                                                        mNewRow.SetFieldValueAsfloat('WorkHoursReal',mRow_Pomoc.GetFieldValueAsFloat('Quantity'));
                                                                                                                        mNewRow.SetFieldValueAsfloat('Quantity',mRow_Pomoc.GetFieldValueAsFloat('Quantity'));
                                                                                                                        mNewRow.SetFieldValueAsfloat('QuantityDelivered',mRow_Pomoc.GetFieldValueAsFloat('Quantity'));


                                                                                                                        mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',mF_pausal_prace);
                                                                                                                        mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                        mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                        mpausal_oprava:=0;


                                                                                                 End;
                                                                                           finally
                                                                                               mList_pomoc.free;
                                                                                           end;
                                                                                     //end;
                                                                            end;
                                                                     //end;  //počet


                                                                   //paušál

                                                              end else begin
                                                                         // jednotlivý výjezd
                                                                          mList_pomoc:= TStringList.Create;
                                                                          mpocet1:=0;
                                                                          try
                                                                              for mI_MLRow:=0 to mRows_ML.count-1 do begin

                                                                                   if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 ) and ((mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                          (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101')) and mpokracovat then begin
                                                                                           mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                 mquantity:=mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsFloat('WorkHoursReal');
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);


                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('X_workerRole_id',mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsString('WorkerRole_id'));
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                 //mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',mquantity);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','hod');

                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                 mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                                                                                     mpocet1:=mpocet1+1;
                                                                                 end;

                                                                              end;
                                                                              for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                  mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                  mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('WorkerRole_ID');
                                                                                  mBO_SecurityRole:=xSite.BaseObjectSpace.CreateObject('QRDGQ1DV2CU4D3TOUMORZ0LWIW');

                                                                                  if mPRzac=0 then mPRzac:=mBO_SecurityRole.GetFieldValueAsDateTime('X_zac_prac_doby');
                                                                                  if mPRkon=0 then mPRkon:=mBO_SecurityRole.GetFieldValueAsDateTime('X_kon_prac_doby');



                                                                                                        mForm1 := TForm.Create(xSite);
                                                                                                        try

                                                                                                            mForm1.Caption := 'Evidence pro mzdy';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 14;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 14;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 120;
                                                                                                                mL_technik1_value:= TLabel.Create(mForm1);mL_technik1_value.Parent := mForm1;mL_technik1_value.Caption := ('Konec práce');mL_technik1_value.Top := 14;mL_technik1_value.Left := 200;mL_technik1_value.Height := 13;mL_technik1_value.Width := 200;
                                                                                                                mKonecDAte := TDatetimeEdit.Create(mForm1);mKonecDAte.Left := 300;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= trunc(mRow_Pomoc.GetFieldValueAsDateTime('X_Konec_prace')); mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 380;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= frac(mRow_Pomoc.GetFieldValueAsDateTime('X_Konec_prace')); mKonecTime.Enabled:= True;mForm1.InsertControl(mKonecTime);
                                                                                                                mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doba práce :';mL_operation.Top := 14;mL_operation.Left := 480;mL_operation.Height := 13;mL_operation.Width := 120;
                                                                                                                mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 570;mEd_quantity.Top := 10;mEd_quantity.Width := 30;mEd_quantity.Name := 'mEd_quantity'; mEd_quantity.Text:=NxFloatToIBStr(mRow_Pomoc.GetFieldValueAsFloat('WorkHoursPlanned'));mForm1.InsertControl(mEd_quantity);
                                                                                                                mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 14;mL1_operation.Left := 630;mL1_operation.Height := 13;mL1_operation.Width := 80;
                                                                                                                mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 680;mEd1_quantity.Top := 10;mEd1_quantity.Width := 50;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:='0';mForm1.InsertControl(mEd1_quantity);
                                                                                                                mEd1_Pohotovost := TCheckBox.Create(mForm1);mEd1_Pohotovost.Left := 750;mEd1_Pohotovost.Top := 12;mEd1_Pohotovost.Width := 100;mEd1_Pohotovost.Name := 'mEd1_Pohotovost';mEd1_pohotovost.Caption:='Pohotovost';if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= true then mEd1_Pohotovost.State:=1;if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= false then mEd1_Pohotovost.State:=0;mForm1.InsertControl(mEd1_Pohotovost);
                                                                                                                mL1_C_protokol:= TLabel.Create(mForm1);mL1_C_protokol.Parent := mForm1;mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 840;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 900;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1020;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10;mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250;mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                            mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                            mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel; mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20; mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                            if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                     mpokracovat:=true;
                                                                                                                     mF_doba:=NxIBStrToFloat(mEd_quantity.text) ;
                                                                                                                     mD_ML_End:=trunc(mKonecDAte.DateTime)+frac(mKonectime.Time);
                                                                                                                     mDateto:=mD_ML_End;
                                                                                                                     mDatefrom:=mD_ML_End-(EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0)) ;

                                                                                                                   //   if xsite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('DO: ' + FormatDateTime('DD.MM.YYYY HH:NN',mdateto),nil);

                                                                                                                   //   if xsite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('posun ' + NxFloatToIBStr(EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0)),nil);


                                                                                                                   //   if xsite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('OD: ' + FormatDateTime('DD.MM.YYYY HH:NN',mdatefrom),nil);




                                                                                                                     if mEd1_Pohotovost.State=0 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',false);
                                                                                                                     if mEd1_Pohotovost.State=1 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',True);
                                                                                                                     mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                     mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                     mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));


                                                                                                                     mWorkHoursReal:=NxIBStrToFloat(mEd_quantity.text) ;

                                                                                                                     mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                     //mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                     mRow_Pomoc.SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                     mRow_Pomoc.SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                     mRow_Pomoc.SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                     mRow_Pomoc.SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal);


                                                                                                                     mRow_Pomoc.SetFieldValueAsDateTime('X_konec_prace',mD_ML_End);

                                                                                                             end else begin
                                                                                                                  mpokracovat:=false;
                                                                                                                 // NxShowSimpleMessage('Operace byla přerušena',xsite);
                                                                                                             end;

                                                                                                        msleva:=mRow_Pomoc.getFieldValueAsinteger('X_radkova_sleva');
                                                                                                        if ((mRow_Pomoc.getFieldValueAsFloat('WorkHoursReal')<=0) and (mWorkHoursReal<>0)) and (not mpokracovat) then begin
                                                                                                             if not mpokracovat then NxShowSimpleMessage('Operace byla přerušena uživatelem',nil) else nxShowSimpleMessage('Není zadaná reálně odpracovaná doba, nelze pokračovat',nil);
                                                                                                        end else begin
                                                                                                              mstore:=mRow_Pomoc.getFieldValueAsString('Store_id');




                                                                                                                    if mpokracovat then begin // není záruka
                                                                                                                                mF_svatek:=0;mF_vikend:=0;mF_mimo:=0;mF_prace:=0;mFS_svatek:=0;mFS_vikend:=0;mFS_mimo:=0;mFS_prace:=0;mDateZac:=frac(mPRzac);mDateKon:=frac(mPRkon);
                                                                                                                             if mDateZac=0 then mDateZac:=EncodeTime(7,0,0,0);
                                                                                                                             if mDateKon=0 then mDateKon:=EncodeTime(15,40,0,0);

                                                                                                                             if trunc(mDateto)=trunc(mDatefrom) then begin          // jednodenní operace
                                                                                                                                                                                                 mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                      if mF_svatek=0 then begin
                                                                                                                                                                                                          mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                             if mF_vikend=0 then begin
                                                                                                                                                                                                               mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                               mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                             end;
                                                                                                                                                                                                      end;
                                                                                                                                                                                                  mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                  mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                  mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                  mFS_Prace:=mFS_Prace+mF_Prace;// jednodenní práce
                                                                                                                                                                                            end else begin
                                                                                                                                                                                                mDnu:=trunc(mDateto)-trunc(mDatefrom) ;
                                                                                                                                                                                                for II:=0 to mDnu do begin
                                                                                                                                                                                                   if (trunc(mDateFrom)+ii=trunc(mDatefrom)) or (trunc(mDateFrom)+ii=trunc(mDateto)) then begin       // necelý den
                                                                                                                                                                                                       if (trunc(mDateFrom)+ii=trunc(mDatefrom)) then begin  // první den
                                                                                                                                                                                                            //if ladit then NxShowSimpleMessage('První den',nil);
                                                                                                                                                                                                            mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,trunc(mdatefrom)+1);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                       end;
                                                                                                                                                                                                       if (trunc(mDateFrom)+ii=trunc(mDateto)) then begin    // poslední den
                                                                                                                                                                                                            mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                            //if ladit then NxShowSimpleMessage('Poslední den',nil);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                       end;
                                                                                                                                                                                                   end else begin    // celý den
                                                                                                                                                                                                      mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                       // if ladit then NxShowSimpleMessage('Celý den',nil);
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                      end;
                                                                                                                                                                                                  mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                  mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                  mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                  mFS_Prace:=mFS_Prace+mF_Prace;


                                                                                                                                                                                                end;
                                                                                                                                                                                            end;
                                                                                                                                                                                            mkorekce:=0;
                                                                                                                                                                                            mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                            mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                            if mfs_mimo<0 then begin
                                                                                                                                                                                               mFS_Prace:=mFS_Prace+mFS_Mimo;
                                                                                                                                                                                               mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                               mFS_Mimo:=0;
                                                                                                                                                                                               end else begin
                                                                                                                                                                                               mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                            end;
                                                                                                                                                                                            mFS_svatek:=NxIBStrToFloat(FormatDateTime('H',mFS_svatek))+ (NxIBStrToFloat(FormatDateTime('N',mFS_svatek))*(100/60));
                                                                                                                                                                                            mFS_vikend:=NxIBStrToFloat(FormatDateTime('H',mF_vikend))+ (NxIBStrToFloat(FormatDateTime('N',mF_vikend))*(100/60));



                                                                                                                                                                                            if mWorkHoursReal<>(mFS_svatek+mFS_vikend +mFS_Mimo+mFS_Prace) then begin
                                                                                                                                                                                                    mkorekce:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo+mFS_Prace) ;
                                                                                                                                                                                                    if mFS_vikend+mFS_svatek>0 then begin
                                                                                                                                                                                                       mFS_vikend:=(mFS_vikend+mkorekce);
                                                                                                                                                                                                       mkorekce:=0;
                                                                                                                                                                                                    end;
                                                                                                                                                                                                    if mFS_Mimo>0 then begin
                                                                                                                                                                                                       mFS_Mimo:=(mFS_Mimo+mkorekce);
                                                                                                                                                                                                       mkorekce:=0;
                                                                                                                                                                                                    end else begin
                                                                                                                                                                                                           mFS_Prace:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo)
                                                                                                                                                                                                    end;
                                                                                                                                                                                            end;


                                                                                                                              mFS_svatek:=NxIBStrToFloat(FormatDateTime('H',mFS_svatek))+ (NxIBStrToFloat(FormatDateTime('N',mFS_svatek))*(100/60));
                                                                                                                              mFS_vikend:=NxIBStrToFloat(FormatDateTime('H',mF_vikend))+ (NxIBStrToFloat(FormatDateTime('N',mF_vikend))*(100/60));
                                                                                                                              mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                              mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));

                                                                                                                            if mWorkHoursReal<>(mFS_svatek+mFS_vikend +mFS_Mimo+mFS_Prace) then begin
                                                                                                                                      mkorekce:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo+mFS_Prace) ;
                                                                                                                                      if mFS_vikend+mFS_svatek>0 then begin
                                                                                                                                         mFS_vikend:=(mFS_vikend+mkorekce);
                                                                                                                                         mkorekce:=0;
                                                                                                                                      end;
                                                                                                                                      if mFS_Mimo>0 then begin
                                                                                                                                         mFS_Mimo:=(mFS_Mimo+mkorekce);
                                                                                                                                         mkorekce:=0;
                                                                                                                                      end else begin
                                                                                                                                             mFS_Prace:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo)
                                                                                                                                      end;
                                                                                                                            end;


                                                                                                                              mForm1 := TForm.Create(xSite);
                                                                                                                            try
                                                                                                                                    mForm1.Caption := 'Rozpočtení práce pro fakturaci';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 450; mForm1.Height := 450;mForm1.Scaled := False;mForm1.Position := poScreenCenter;
                                                                                                                                    mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                    mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                    mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1; mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                    mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 230;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mDateto;mKonecDAte.Enabled:=false;mForm1.InsertControl(mKonecDAte);
                                                                                                                                    mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mDateto;mKonecTime.Enabled:= False;mForm1.InsertControl(mKonecTime);

                                                                                                                                     if true then begin
                                                                                                                                         mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 42;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                         mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 150;mEd_quantity.Top := 42;mEd_quantity.Width := 80;mEd_quantity.Name := 'mEd_quantity'; mEd_quantity.Text:=nxfloattoibstr(0);mForm1.InsertControl(mEd_quantity);
                                                                                                                                         mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1; mL_Technik.Caption := 'ks';mL_Technik.Top := 42;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                         mEd_Unitprice:= TEdit.Create(mForm1);mEd_Unitprice.Left := 280;mEd_Unitprice.Top := 40;mEd_Unitprice.Width := 80;mEd_Unitprice.Name := 'mEd_Unitprice';mEd_Unitprice.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_Unitprice);
                                                                                                                                         mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 42;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;
                                                                                                                                     mxpomoc:=0;
                                                                                                                                     if mF_pausal_Vyjezd=0 then mxpomoc:=0 else mxpomoc:=1;
                                                                                                                                     if true then begin
                                                                                                                                         mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava paušál :';mL_operation.Top := 72;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                         mEd_quantity1 := TEdit.Create(mForm1);mEd_quantity1.Left := 150;mEd_quantity1.Top := 70;mEd_quantity1.Width := 80;mEd_quantity1.Name := 'mEd_quantity1';mEd_quantity1.Text:=NxFloatToIBStr(mxpomoc);mForm1.InsertControl(mEd_quantity1);mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 72; mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                         mEd_Unitprice1:= TEdit.Create(mForm1);mEd_Unitprice1.Left := 280;mEd_Unitprice1.Top := 70;mEd_Unitprice1.Width := 80;mEd_Unitprice1.Name := 'mEd_Unitprice1';mEd_Unitprice1.Text:=NxFloatToIBStr(mF_pausal_Vyjezd);mForm1.InsertControl(mEd_Unitprice1);
                                                                                                                                         mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 72;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if false then begin
                                                                                                                                         mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 102;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                         mEd_quantity2 := TEdit.Create(mForm1);mEd_quantity2.Left := 150; mEd_quantity2.Top := 100;mEd_quantity2.Width := 80;mEd_quantity2.Name := 'mEd_quantity2';mEd_quantity2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity2);
                                                                                                                                         mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 102;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                         mEd_Unitprice2:= TEdit.Create(mForm1);mEd_Unitprice2.Left := 280;mEd_Unitprice2.Top := 100;mEd_Unitprice2.Width := 80;mEd_Unitprice2.Name := 'mEd_Unitprice2';mEd_Unitprice2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice2);
                                                                                                                                         mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 102;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if true then begin
                                                                                                                                         mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 132;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                         mEd_quantity3 := TEdit.Create(mForm1);mEd_quantity3.Left := 150;mEd_quantity3.Top := 130;mEd_quantity3.Width := 80; mEd_quantity3.Name := 'mFS_prace';mEd_quantity3.Text:=NxFloatToIBStr(mFS_Prace);
                                                                                                                                         mForm1.InsertControl(mEd_quantity3);mL_Technik:= TLabel.Create(mForm1); mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 132;mL_Technik.Left := 240 ; mL_Technik.Height := 13;
                                                                                                                                         mEd_Unitprice3:= TEdit.Create(mForm1);mEd_Unitprice3.Left := 280;mEd_Unitprice3.Top := 130;mEd_Unitprice3.Width := 80; mEd_Unitprice3.Name := 'mEd_Unitprice3';mEd_Unitprice3.Text:=NxFloatToIBStr(mFSazba_Prace);mForm1.InsertControl(mEd_Unitprice3);
                                                                                                                                         mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 132;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if true then begin
                                                                                                                                          mL_operation:= TLabel.Create(mForm1); mL_operation.Parent := mForm1;mL_operation.Caption := 'Mimo pracovní dobu :'; mL_operation.Top := 162;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                          mEd_quantity4 := TEdit.Create(mForm1);mEd_quantity4.Left := 150;mEd_quantity4.Top := 160;mEd_quantity4.Width := 80;mEd_quantity4.Name := 'mEd_quantity4'; mEd_quantity4.Text:=NxFloatToIBStr(mFS_mimo);mForm1.InsertControl(mEd_quantity4);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 162;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                          mEd_Unitprice4:= TEdit.Create(mForm1);mEd_Unitprice4.Left := 280;mEd_Unitprice4.Top := 160;mEd_Unitprice4.Width := 80;mEd_Unitprice4.Name := 'mEd_Unitprice4';mEd_Unitprice4.Text:=NxFloatToIBStr(mFSazba_Mimo);mForm1.InsertControl(mEd_Unitprice4);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 162;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if true then begin
                                                                                                                                          mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Víkend + Svátek :';mL_operation.Top := 192;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                          mEd_quantity5 := TEdit.Create(mForm1);mEd_quantity5.Left := 150;mEd_quantity5.Top := 190;mEd_quantity5.Width := 80;mEd_quantity5.Name := 'mEd_quantity5';mEd_quantity5.Text:=NxFloatToIBStr(mFS_Vikend);mForm1.InsertControl(mEd_quantity5);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 192;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                          mEd_Unitprice5:= TEdit.Create(mForm1);mEd_Unitprice5.Left := 280;mEd_Unitprice5.Top := 190;mEd_Unitprice5.Width := 80;mEd_Unitprice5.Name := 'mEd_Unitprice5';mEd_Unitprice5.Text:=NxFloatToIBStr(mFSazba_Vikend);mForm1.InsertControl(mEd_Unitprice5);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 192;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if false then begin
                                                                                                                                          mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 222;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                          mEd_quantity6 := TEdit.Create(mForm1);mEd_quantity6.Left := 150;mEd_quantity6.Top := 220;mEd_quantity6.Width := 80;mEd_quantity6.Name := 'mEd_quantity6';mEd_quantity6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity6);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 222;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                          mEd_Unitprice6:= TEdit.Create(mForm1);mEd_Unitprice6.Left := 280;mEd_Unitprice6.Top := 220;mEd_Unitprice6.Width := 80;mEd_Unitprice6.Name := 'mEd_Unitprice6';mEd_Unitprice6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice6);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 222;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if true then begin
                                                                                                                                          mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava km :';mL_operation.Top := 252;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                          mEd_quantity7 := TEdit.Create(mForm1);mEd_quantity7.Left := 150;mEd_quantity7.Top := 250;mEd_quantity7.Width := 80;mEd_quantity7.Name := 'mEd_quantity7';mEd_quantity7.Text:=NxFloatToIBStr(mpocet_km);mForm1.InsertControl(mEd_quantity7);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'km';mL_Technik.Top := 252;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                          mEd_Unitprice7:= TEdit.Create(mForm1);mEd_Unitprice7.Left := 280;mEd_Unitprice7.Top := 250;mEd_Unitprice7.Width := 80;mEd_Unitprice7.Name := 'mEd_Unitprice7';
                                                                                                                                          mEd_Unitprice7.Text:=NxFloatToIBStr(mFSazba_Doprava_km);mForm1.InsertControl(mEd_Unitprice7);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/km';mL_Technik.Top := 252;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if false then begin
                                                                                                                                          mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 282;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                          mEd_quantity8 := TEdit.Create(mForm1);mEd_quantity8.Left := 150;mEd_quantity8.Top := 280;mEd_quantity8.Width := 80;mEd_quantity8.Name := 'mEd_quantity8';mEd_quantity8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity8);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 282;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                          mEd_Unitprice8:= TEdit.Create(mForm1);mEd_Unitprice8.Left := 280;mEd_Unitprice8.Top := 280;mEd_Unitprice8.Width := 80;mEd_Unitprice8.Name := 'mEd_Unitprice8';mEd_Unitprice8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice8);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 282;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;

                                                                                                                                     if true then begin
                                                                                                                                          mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Výjezd do 3 hodin :';mL_operation.Top := 312;mL_operation.Left := 10;mL_operation.Height := 13; mL_operation.Width := 320;
                                                                                                                                          mEd_quantity9 := TEdit.Create(mForm1);mEd_quantity9.Left := 150;mEd_quantity9.Top := 310;mEd_quantity9.Width := 80;mEd_quantity9.Name := 'mEd_quantity9';mEd_quantity9.Text:=NxFloatToIBStr(0);mForm1.InsertControl(mEd_quantity9);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 312;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                          mEd_Unitprice9:= TEdit.Create(mForm1);mEd_Unitprice9.Left := 280;mEd_Unitprice9.Top := 310;mEd_Unitprice9.Width := 80;mEd_Unitprice9.Name := 'mEd_Unitprice9';mEd_Unitprice9.Text:=NxFloatToIBStr(mFPriplatek3H);mForm1.InsertControl(mEd_Unitprice9);
                                                                                                                                          mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 312;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                     end;
                                                                                                                                    mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                    mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);
                                                                                                                                    mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Nefakturovat';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnIgnore';mForm1.InsertControl(mBtn);



                                                                                                                                    if (mForm1.ShowModal(xSite) = mrOK) or (mForm1.ShowModal(xSite) = mrIgnore) then begin
                                                                                                                                          mpokracovat:=true;
                                                                                                                                          if (mForm1.ShowModal(xSite) = mrOK) then begin
                                                                                                                                                  if NxIBStrToFloat(mEd_quantity.text)>0 then begin
                                                                                                                                                      mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+55);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál práce');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                      mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));//mNewRow.Save;mNewRow.free;
                                                                                                                                                  end;
                                                                                                                                                  if NxIBStrToFloat(mEd_quantity1.text)>0 then begin
                                                                                                                                                      mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+60);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál doprava');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsString('StoreCard_id','1FD1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice1.Text));
                                                                                                                                                      mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                                                      mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                  end;

                                                                                                                                                  if NxIBStrToFloat(mEd_quantity.Text)=0 then begin
                                                                                                                                                            if NxIBStrToFloat(mEd_quantity3.text)>0 then begin
                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject; mNewRow.SetFieldValueAsInteger('Posindex',i+65);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce Pracovní doba');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice3.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                    mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                end;
                                                                                                                                                                if NxIBStrToFloat(mEd_quantity4.text)>0 then begin
                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+70);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce mimo pracovní dobu');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice4.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                    mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                end;
                                                                                                                                                                if NxIBStrToFloat(mEd_quantity5.text)>0 then begin
                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0);  mNewRow.SetFieldValueAsInteger('Posindex',i+75);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce o víkendu+ svátek');mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice5.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva); mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));
                                                                                                                                                                    mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                end;
                                                                                                                                                  end;
                                                                                                                                                  if NxIBStrToFloat(mEd_quantity7.text)>0 then begin
                                                                                                                                                      mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsInteger('Posindex',i+80);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));if NxIBStrToFloat(mEd_quantity1.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Doprava km');
                                                                                                                                                      mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice7.Text));end else begin mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                      //mNewRow.Save;mNewRow.free;
                                                                                                                                                  end;
                                                                                                                                                  if NxIBStrToFloat(mEd_quantity9.text)>0 then begin
                                                                                                                                                      mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+85);mNewRow.SetFieldValueAsInteger('itemtype',4); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mEd_quantity9.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);if NxIBStrToFloat(mEd_quantity9.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end else begin mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');
                                                                                                                                                      mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));mNewRow.SetFieldValueAsfloat('ToInvoiceType',0);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                      //mNewRow.Save;mNewRow.free;
                                                                                                                                                  end;

                                                                                                                                             end;
                                                                                                                                    end else begin
                                                                                                                                            mpokracovat:=false;
                                                                                                                                    end; // tlačítko ok
                                                                                                                            finally
                                                                                                                                mForm1.free;
                                                                                                                            end;
                                                                                                             end else begin         // záruka
                                                                                                             {mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsFloat('WorkHoursReal',0);mNewRow.SetFieldValueAsinteger('itemtype',4);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsinteger('ToInvoiceType',1);mNewRow.SetFieldValueAsString('Text','Práce - evidenční pro mzdy');mNewRow.SetFieldValueAsFloat('Quantity',mquantity);mNewRow.SetFieldValueAsString('Qunit','hod');mNewRow.SetFieldValueAsFloat('QuantityDelivered',mquantity);mNewRow.SetFieldValueAsBoolean('X_storno',true);mNewRow.SetFieldValueAsFloat('UnitPriceWithVAT',0);mNewRow.SetFieldValueAsFloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Store_id',mRow_Pomoc.GetFieldValueAsString('Store_id'));mNewRow.SetFieldValueAsString('StoreCard_id',mRow_Pomoc.GetFieldValueAsString('StoreCard_id'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.Save;mNewRow.free;


                                                                                                                                                  if (mpocet_km)>0 then begin
                                                                                                                                                      mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('WorkHoursReal',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.free;
                                                                                                                                                  end; }
                                                                                                             end;                   // záruka


                                                                                                             ////////
                                                                                                        end;   // zadání odpracované doby


                                                                                                        finally
                                                                                                            //mForm1.Free;
                                                                                                        end;



                                                                              end;  // end for list

                                                                          finally
                                                                              mList_pomoc.free;
                                                                          end;
                                                            mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mDateFrom);
                                                            mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mDateto);
                                                         end;   //paušál

                                                         if mpokracovat then begin

                                                            mBO_ML.SetFieldValueAsstring('X_State','3Q22000101');
                                                            mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                            mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                            result:=true;
                                                         end else begin
                                                            result:=true;
                                                         end;
                                                         if mpocet1=0 then begin
                                                            result:=false;
                                                            NxShowSimpleMessage('Není žádná položka k rozpočtu',nil);
                                                         end;

                                                   end ;  // není fakturován


end;





function GetTechnik(xSite:TSiteForm;mbo_ml:TNxCustomBusinessObject;mRows_ML:TNxCustomBusinessMonikerCollection;mIDs_WorkerRole:TStringList;mDateinput:boolean) : Boolean;
var
mOLE_WR, mRoll_WR, mOResult_WR: Variant;
mD_ML_start,mD_ML_End,mD_SL_start,mD_SL_End,mD_CRM_start,mD_CRM_End:double;
mForm: TForm;
mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
   // doby + termíny
   mF_doba:double;
   mF_Prace_od,mF_Prace_do:double;                  // jen časová část
   mF_Prac_doba_zac,mF_Prac_doba_kon:double;        // jen časová část
   // sazby
   mFSazba_Prace_pausal,mFSazba_Prace,mFSazba_Mimo,mFSazba_Vikend,mFSazba_Svatek,mFSazba_Doprava_km,mFSazba_Doprava_pausal,mFPriplatek3H:double;
   // počty (množství)
   mF_Mnozstvi_Prace_pausal,F_Mnozstvi_Prace,mF_Mnozstvi_mimo,mF_Mnozstvi_vikend,mF_Mnozstvi_svatek,mF_Mnozstvi_Doprava_km,mF_Mnozstvi_Doprava_pausal:double;
  mstore_id:string;
   mDateFrom,mDateto,mDatezac,mDatekon,mPRzac,mPRkon:Double;
  msleva:double;
 mF_svatek,mF_vikend,mF_mimo,mFS_svatek,mFS_vikend,mFS_mimo,mFS_prace:double;
  mrole_id:string;
 mDnu:integer;
 mOpakovani:integer;
 mBO_ML_ROW:TNxCustomBusinessObject;
 mStore:string;
  mForm1 : TForm;
  mBtn : TButton;
  mKonecDAte:TDateTimeEdit;
  mKonecTime:TTimeEdit;
  mL_Technik,mL1_C_Protokol,mL1_pohotovost,mL1_C_Chyby,mL_technik_value:TLabel;
  mL_operation,mL1_operation:TLabel ;
  mEd1_pohotovost:TCheckBox;
  mEd1_C_chyby,mEd1_C_protokol:tedit;
  mEd1_quantity,mEd_quantity,mEd_Unitprice,mEd_quantity1,mEd_Unitprice1,mEd_quantity2,mEd_Unitprice2,mEd_quantity3,mEd_Unitprice3,mEd_quantity4,mEd_Unitprice4,mEd_quantity5,mEd_Unitprice5,mEd_quantity6,mEd_Unitprice6,mEd_quantity7,mEd_Unitprice7,mEd_quantity8,mEd_Unitprice8,mEd_quantity9,mEd_Unitprice9,mEd_quantity10,mEd_Unitprice10,mED1_P_Cyklu:TEdit;
  mquantity:double;
  mWorkHoursReal:Double;
  mkorekce:Double;
  mpocet_km:Double;
  mLabel1,mLblm,mLbl1,mLbl2,mLbl0,mLbl3,mLabel3 ,mL1_P_Cyklu: TLabel;
  mEdtDAte:TDateEdit;
    mEdtDAte1:TTimeEdit;
    mID_WorkerRole:string;
    mEdtSrc:TEdit;
    mBO_BusProject:TNxCustomBusinessObject;
    mI_WorkerRole:integer;
    ID_result:string;
    mkoeficient,mkoeficient_korekce:Double;
    mrGT:TStringList;
    xresult:boolean;
    mstav:string;
    mcrmresult:Boolean;
begin

     if mIDs_WorkerRole.Count>0 then begin

                   if mDateinput then begin         // opakující se doba
                              mDateinput:=false;
                              mD_ML_start:=mbo_ml.GetFieldValueAsDateTime('StartDate$DATE');
                              mD_ML_End:=mbo_ml.GetFieldValueAsDateTime('EndDate$DATE');
                              mf_doba:=1;
                              mForm := TForm.Create(xSite);
                              mForm.Caption := 'Zadejte údaje';mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;mForm.Width := 550;mForm.Scaled := False;mform.Position := poScreenCenter;
                              mLbl2 := TLabel.Create(mForm);  mLbl2.Caption := 'Konec :';mLbl2.Left := 10;mLbl2.Top := 40;mLbl2.Name := 'lbldate';mForm.InsertControl(mLbl2);mEdtDAte := TDateEdit.Create(mForm);mEdtDAte.Left := 100;mEdtDAte.Top := 40;mEdtDAte.Width := 100;mEdtDAte.Name := 'edtDate';mEdtDAte.Date:=trunc(mD_ML_End);mForm.InsertControl(mEdtDAte);
                              mEdtDAte1 := TTimeEdit.Create(mForm);mEdtDAte1.Left := 210;mEdtDAte1.Top := 40;mEdtDAte1.Width := 100;mEdtDAte1.Name := 'edtDate1';mEdtDAte1.Time:=frac(mD_ML_End);mForm.InsertControl(mEdtDAte1);
                              mLbl3 := TLabel.Create(mForm); mLbl3.Caption := 'Doba :';mLbl3.Left := 10;mLbl3.Top := 70;mLbl3.Name := 'lblDoba';mForm.InsertControl(mLbl3);mEdtSrc := TEdit.Create(mForm);mEdtSrc.Left := 100;mEdtSrc.Top := 70;mEdtSrc.Width := 100;mEdtSrc.Name := 'edtdoba';mEdtSrc.Text:=NxFloatToIBStr(mf_doba);mForm.InsertControl(mEdtSrc);
                              mBtn := TButton.Create(mForm);mBtn.Width := 75; mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                              mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                              if mForm.ShowModal(xSite) = mrOK then begin
                                              mF_doba:=NxIBStrToFloat(mEdtSrc.Text);
                                              mD_ML_End:=mEdtDAte.Date+ mEdtDAte1.Time;
                                              mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                              mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mD_ML_start);
                                              mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mD_ML_End);
                                              if  not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                      mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mF_Prac_doba_zac:=0;mF_Prac_doba_kon:=0;
                                                      // ceny z projektu
                                                      try
                                                              mBO_BusProject:=xsite.BaseObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                              if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                  NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                  mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                              end;
                                                              if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                    mBO_BusProject.load('2130000101',nil);
                                                              end;
                                                              if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                    mBO_BusProject.load('3130000101',nil);
                                                              end;
                                                              mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');

                                                      finally
                                                      mBO_BusProject.free;
                                                      end;

                                              end;
                             end;
                             mDateinput:=false;
                   end;   //opakující se doba;
                   msleva:= mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.X_Discount_sluzby');

                     if mIDs_workerRole.count>0 then begin
                          for mI_WorkerRole:=0 to mIDs_workerRole.count-1 do begin
                                mID_WorkerRole:=mIDs_WorkerRole.Strings[mI_WorkerRole];
                                     mBO_ML_ROW := mRows_ml.AddNewObject;
                                                    mBO_ML_ROW.SetFieldValueAsString('X_Osoba',mBO_ML_ROW.GetFieldValueAsstring('X_WorkerRole_ID.Name'));
                                                    mBO_ML_ROW.SetFieldValueAsinteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                    //mOrderRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                    mBO_ML_ROW.SetFieldValueAsString('WorkerRole_ID',mID_WorkerRole);
                                                    mBO_ML_ROW.SetFieldValueAsString('X_WorkerRole_ID',mID_WorkerRole);

                                                    mBO_ML_ROW.SetFieldValueAsString('Text','Práce');
                                                    mBO_ML_ROW.SetFieldValueAsString('Store_id','2000000101');
                                                    mBO_ML_ROW.SetFieldValueAsString('StoreCard_id','2ZI1000101');
                                                    mBO_ML_ROW.SetFieldValueAsfloat('WorkHoursPlanned',mF_doba);
                                                    mBO_ML_ROW.SetFieldValueAsfloat('X_konec_prace',mD_ML_End);
                                                    mBO_ML_ROW.SetFieldValueAsfloat('X_Radkova_sleva',msleva);
                                                           mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                                           mCRMresult:=NxCRM(0,mBO_ML_ROW,mID_WorkerRole,mD_ML_start,mD_ML_End,'','');
                                                           if not mcrmresult then NxShowSimpleMessage('Při vytváření aktivity došlo k chybě',nil);
                                                    mBO_ML_ROW.SetFieldValueAsfloat('X_Koeficient',0);
                                                    if mFSazba_hod<>0 then mBO_ML_ROW.SetFieldValueAsfloat('UnitPriceWithoutVAT',mFSazba_hod);
                                                    mBO_ML_ROW.SetFieldValueAsinteger('ToInvoiceType',0);

                                if mI_WorkerRole=0 then mkoeficient_korekce:=0
                          end;
                     mBO_ML.SetFieldValueAsstring('X_State','4U12000101');
                     mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                     mBO_ML.SetFieldValueAsstring('X_Monter1_ID',mID_WorkerRole);
                     //if trunc(mD_ML_End)<trunc(date) then begin
                     //     xresult:=Fakturacni_ceny(mBO_ML,xSite,mRows_ML,mstav);
                     //       if not xresult then NxShowSimpleMessage('Při rozpočtu fakturace došlo k chybě',nil);
                     //end;
                  end;
                     result:=true;
     end else begin
        NxShowSimpleMessage('Není zadán žádný technik',nil);
        result:=true;
     end;
end;










function GetCheck(Sender: TComponent;xSite:TSiteForm;mLabel:string;mLabelOK:string;mLabelStorno:string) : Boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 200;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := mlabel;
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 80;
                        mBtn.Height := 25;
                        mBtn.Caption := mLabelOK;
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 80;
                        mBtn.Height := 25;
                        mBtn.Caption := mLabelStorno;
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=true;
           end else begin
                result:=false;
           end;
        finally;
          mForm.Free;
        end;
end;










function GetDate(Sender: TComponent;xSite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
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

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;

function GetDate2(xSite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
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

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;

function Novy_ML(mbo_sl:TNxCustomBusinessObject;mid_workSpace:string;mid_workerRole:string;mD_ML_start:double;mD_ML_end:double):string;
var
mBO_MLNew:TNxCustomBusinessObject;
begin
    mBO_MLNew:=mbo_sl.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
    try
       mBO_MLNew.new;
       mBO_MLNew.Prefill;
       mBO_MLNew.SetFieldValueAsDateTime('StartDate$DATE',mBO_SL.GetFieldValueAsDateTime('DocDate$Date'));
       mBO_MLNew.SetFieldValueAsDateTime('EndDate$DATE',mBO_SL.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
       mBO_MLNew.SetFieldValueAsDateTime('X_CreatedDate$DATE',date);
       mBO_MLNew.SetFieldValueAsString('ServiceDocument_ID',mBO_SL.oid);
       mBO_MLNew.SetFieldValueAsstring('X_State','35W1000101');
       mBO_MLNew.SetFieldValueAsstring('X_ServicedObject_ID',mBO_SL.GetFieldValueAsString('ServicedObject_ID'));
       mBO_MLNew.SetFieldValueAsstring('X_id_zakaznika_id',mBO_SL.GetFieldValueAsString('X_id_zakaznika_id'));
       mBO_MLNew.SetFieldValueAsInteger('AssemblyState',1);
       mBO_MLNew.SetFieldValueAsString('ServiceWorkSpace_ID',mid_workSpace);
       mBO_MLNew.SetFieldValueAsString('ResponsibleRole_ID',mid_workerRole);
      mBO_MLNew.SetFieldValueAsstring('X_State','35W1000101');
      mBO_MLNew.SetFieldValueAsinteger('AssemblyState',0);
      mBO_MLNew.SetFieldValueAsstring('X_Docqueue_ID',mBO_MLNew.getFieldValueAsstring('ServiceDocument_ID.Docqueue_ID'));
      mBO_MLNew.SetFieldValueAsinteger('X_Ordnumber',mBO_MLNew.getFieldValueAsInteger('ServiceDocument_ID.ordnumber'));
      mBO_MLNew.SetFieldValueAsstring('X_Period_ID',mBO_MLNew.getFieldValueAsstring('ServiceDocument_ID.Period_ID'));
      mBO_MLNew.save;
      result:=mBO_MLNew.oid;
     finally
        mBO_MLNew.free;
     end;



end;

function Novy_SL(xsite:tsiteform;mID_SP:String;mD_SL_start:Date;mD_SL_end:date;mID_DQ:string;mID_DV:string;mDamageDescription:string;mServiceType_ID:string;):string;
var
mboNew_SL:TNxCustomBusinessObject;
mresult:boolean;
mobjednavka:string;
begin
      mboNew_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
          try
            mboNew_SL.new;
            mboNew_SL.Prefill;
            mboNew_SL.SetFieldValueAsString('Docqueue_ID', mID_DQ);
            mboNew_SL.SetFieldValueAsDateTime('DocDate$DATE',mD_SL_start);
            mboNew_SL.SetFieldValueAsDateTime('X_CreatedDate$DATE',date);
            mboNew_SL.SetFieldValueAsString('ServiceType_ID',mServiceType_ID);
            mboNew_SL.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mD_SL_end);
            mboNew_SL.SetFieldValueAsstring('ServicedObjectIDCode','');
            mboNew_SL.SetFieldValueAsstring('ServicedObjectText','');
            mboNew_SL.SetFieldValueAsstring('ServicedObject_ID',mID_SP);
            mboNew_SL.SetFieldValueAsstring('Firm_id',mboNew_SL.getFieldValueAsstring('ServicedObject_ID.firm_id'));
            mboNew_SL.SetFieldValueAsstring('PayerFirm_id',mboNew_SL.getFieldValueAsstring('ServicedObject_ID.Payerfirm_id'));
            mboNew_SL.SetFieldValueAsstring('X_id_zakaznika_id',mboNew_SL.getFieldValueAsstring('ServicedObject_ID.X_id_zakaznika_id'));
            mboNew_SL.SetFieldValueAsString('Division_ID',mID_DV);
            mboNew_SL.SetFieldValueAsString('BusOrder_ID', mboNew_SL.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID'));
            mboNew_SL.SetFieldValueAsString('BusTransaction_ID', mboNew_SL.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID'));
            mboNew_SL.SetFieldValueAsString('BusProject_ID', mboNew_SL.GetFieldValueAsString('ServicedObject_ID.BusProject_ID'));
            mboNew_SL.SetFieldValueAsString('AcceptedByUser_ID', xsite.SiteContext.GetCompanyCache.GetUserID);
            mboNew_SL.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mD_SL_end+1);
            if mDamageDescription<>'' then mboNew_SL.SetFieldValueAsString('DamageDescription', mDamageDescription);

            if mboNew_SL.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky')<>'' then begin
               mboNew_SL.SetFieldValueAsstring('X_objednani', mboNew_SL.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky'));
            end;
            mboNew_SL.SetFieldValueAsstring('ServiceDocState_ID','2000000101');
            if NxIsBlank(mboNew_SL.GetFieldValueAsString('X_objednani')) then begin
            end else begin
                mobjednavka:=mboNew_SL.GetFieldValueAsString('X_objednani')
            end;

            mresult:=InputQuery('Zadej,nebo oprav objednávku','Objednávka',mobjednavka);
            if mresult then begin

                mboNew_SL.SetFieldValueAsString('X_objednani',mobjednavka);
            end;
            mboNew_SL.Save ;
            result:=mboNew_SL.oid;
    finally
        mboNew_SL.free;
    end;
end;


function NxAddRow_ML(mBO_ML:TNxCustomBusinessObject;mRows_ml:TNxCustomBusinessMonikerCollection;mItemtype : integer; mWorkerRole_ID : string; mText : string; mStore_id : string; mStoreCard_id : string; mWorkHoursPlanned : double; mUnitPriceWithoutVAT : Double; mToInvoiceType : integer;Mf_start:Double;mf_konec:Double;mkoeficient:Double;msleva:double) : string;
var
mOrderRow:TNxCustomBusinessObject;
mresult:Boolean;
mtime:double;
begin
  mOrderRow := mRows_ml.AddNewObject;
      mOrderRow.SetFieldValueAsinteger('itemtype',mItemtype);          // 0 práce , 1 skladová karta
      //mOrderRow.SetFieldValueAsString('serviceworkcategory_id','');
      mOrderRow.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
      mOrderRow.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
      mOrderRow.SetFieldValueAsString('X_Osoba',mOrderRow.GetFieldValueAsstring('WorkerRole_ID.Name'));
      mOrderRow.SetFieldValueAsString('Text',mText);
      mOrderRow.SetFieldValueAsString('Store_id',mStore_id);
      mOrderRow.SetFieldValueAsString('StoreCard_id',mStoreCard_id);
      mOrderRow.SetFieldValueAsfloat('WorkHoursPlanned',mWorkHoursPlanned);
      mOrderRow.SetFieldValueAsfloat('X_konec_prace',mf_konec);
      if mItemtype=0 then begin
          mOrderRow.SetFieldValueAsfloat('X_Radkova_sleva',msleva);
          if (mStoreCard_id='11J1000101') or (mStoreCard_id='2ZI1000101') then begin
             //mresult:=NxCRM(0,mOrderRow,mWorkerRole_ID,(mf_konec-EncodeTime(trunc(mWorkHoursPlanned),0,0,0)),mf_konec,'','');
             mOrderRow.SetFieldValueAsfloat('X_Koeficient',mkoeficient);
          end;
      end else begin
      end;


      if mUnitPriceWithoutVAT<>0 then mOrderRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',mUnitPriceWithoutVAT);
      mOrderRow.SetFieldValueAsinteger('ToInvoiceType',mToInvoiceType);
      //result:=mOrderRow.OID;
      //mOrderRow.Save;



end;




{Svatek}
function Svatek(mOS:TNxCustomObjectSpace;mDateForm:Extended;mDateTo:Extended):Extended;
Var
  mr:TStringList;
begin
  mr:=tstringlist.create;
  mOS.SQLSelect(format('SELECT a.id FROM GeneralCalendar A WHERE ' +
     ' ((%s BETWEEN CAST(A.validfromyear AS char(4)) and CAST(A.ValidToYear  AS char(4))) ' +   // platné v roce
     ' OR (A.ValidToYear=0 AND %s >= CAST(A.validfromyear AS char(4))))' +
     ' and (A.HolidayMonthDay=%s)',
     [quotedstr(FormatDateTime('YYYY',mDateTo)),
     quotedstr(FormatDateTime('YYYY',mDateTo)),
     inttostr((StrToInt(FormatDateTime('MM',mDateTo))*256+StrToInt(FormatDateTime('DD',mDateTo))))       // seskládáni dne
     ]),mr);

  if mr.count>0 then begin
    result:=mDateTo-mDateForm;
//if ladit then NxShowSimpleMessage('Je svátek ' + FormatDateTime('HH:mm',Result),nil) ;
  end;
mr.free;
end;

{Víkend}
function Vikend(mOS:TNxCustomObjectSpace;mDateForm:Extended;mDateTo:Extended):Extended;
Var
  mr:TStringList;
begin
  if (DayOfWeek(mDateTo)=1) or (DayOfWeek(mDateTo)=7) then begin
    result:=mDateTo-mDateForm;
 // if ladit then NxShowSimpleMessage('Je víkend ' + FormatDateTime('HH:mm',Result),nil) ;
  end;
mr.free;
end;

{Mimo pracovní dobu}
function Mimo(mOS:TNxCustomObjectSpace;mDateFrom:Extended;mDateTo:Extended;mPrdobaZac:Extended;mPrDobaKon:Extended):Extended;
var
  mDoba:Double;
begin
      //NxShowSimpleMessage('mDateFrom 1 :' + FormatDateTime('HH:mm',mDateFrom),nil);
      //NxShowSimpleMessage('mDateTo 1 :' + FormatDateTime('HH:mm',mDateTo),nil);
      //NxShowSimpleMessage('mPrdobaZac 1 :' + FormatDateTime('HH:mm',mPrdobaZac),nil);
      //NxShowSimpleMessage('mPrDobaKon 1 :' + FormatDateTime('HH:mm',mPrDobaKon),nil);


      mdoba:=mDateTo-mDateFrom;
       if mDateFrom<mPrdobaZac then begin
           mDoba:=(mDateFrom-mPrdobaZac);
            //NxShowSimpleMessage('Korekce 1 :' + FormatDateTime('HH:mm',mDateFrom-mPrdobaZac),nil);
       end;
       if mDateTo>mPrDobaKon then begin
           mDoba:=(mPrDobaKon-mDateTo);
           //NxShowSimpleMessage('Korekce 2 :' + FormatDateTime('HH:mm',mPrDobaKon-mDateTo),nil);
       end ;
       result:=mDoba;

    //NxShowSimpleMessage('Mimo ' + FormatDateTime('HH:mm',Result),nil) ;
end;

{Pracovní doba}
function Pracovni_doba(mOS:TNxCustomObjectSpace;mDateFrom:Extended;mDateTo:Extended;mPrdobaZac:Extended;mPrDobaKon:Extended):Extended;
Var
  mDoba:Double;
begin
      mdoba:=mDateTo-mDateFrom;
       if mDateFrom<mPrdobaZac then begin
           mDoba:=mdoba+(mDateFrom-mPrdobaZac);
           //NxShowSimpleMessage('Korekce 1 :' + FormatDateTime('HH:mm',mDateFrom-mPrdobaZac),nil);
       end;
       if mPrDobaKon<mDateTo then begin
           mDoba:=mdoba+(mPrDobaKon-mDateTo);
           //NxShowSimpleMessage('Korekce 2 :' + FormatDateTime('HH:mm',mPrDobaKon-mDateTo),nil);
       end ;

      result:=mDoba;
      //NxShowSimpleMessage('OK ' + NxFloatToIBStr(mDoba),nil);
    //NxShowSimpleMessage('Pracovní doba ' + FormatDateTime('HH:mm',Result),nil) ;
end;




function NEWMaterial(mBO_ml:TNxCustomBusinessObject;xsite: TSiteForm;mRows_ml:TNxCustomBusinessMonikerCollection):Boolean;
var
  ii:integer;
   mOLEStore, mRollStore, mOResultStore,mOResult1: Variant;
   mOLEStorecard, mRollStorecard, mOResultStorecard: Variant;
   midsStore,midsStorecard:TStringList;
   mStore_id,mStorecard_ID:string;
   mNewRow:TNxCustomBusinessObject;
   mPocet:string;
  mForm1 : TForm;
  mBtn : TButton;
  mEd1_pohotovost:TCheckBox;
  mEd1_C_chyby,m1Ed1_C_chyby,mEd1_C_protokol:tedit;

  mCb_SC_O_code:TRollComboEdit;
  mCb_CC_O_id,mCb_CC_O_code,mCbCc:TComboBevel;

  mCb_SC_s_code,mCb_ST_s_code:TRollComboEdit;
  mCb_CC_s_id,mCb_CC_s_code:TComboBevel;

  mCb_ST_O_code:TRollComboEdit;
  mCb_CT_O_id,mCb_CT_O_code,mCbCT:TComboBevel;
  mCb_CT_S_id,mCb_CT_S_code,mCbCS:TComboBevel;

  mL_Store_value,mL_StoreCard_value,mEd_unit: TComboEdit;
  mEd_Fakt :TComboBox;
  mL_Store,mL_StoreCard,mL_Quantity,mL_Unit,mL_Price,mL_Sleva,mL_FAkt,mL_Desc :TLabel;
  mEd_quantity,mEd_Price,mEd_Sleva,mEd_Desc:tedit;
  mCedAccountingType,mCedAccountingType2:TRollComboEdit ;
begin
      if NxIsEmptyOID(mbo_ml.GetFieldValueAsString('X_Monter1_ID.X_store_ID')) then begin
       mOLEStore:= GetAbraOLEApplication;
        mOResultStore:= mOLEStore.CreateStrings;
        mRollStore:= mOLEStore.GetRoll('O3ZO2K155FDL3CL100C4RHECN0', 0);   // sklad
                          if not mRollStore.MultiSelectDialog(true, mOResultStore) then Exit;
                                midsStore:= TStringList.Create;
                                midsStore.Text:= mOResultStore.Text;
                                mStore_id:=midsStore.Strings[0];
        end else begin
            mStore_id:=mbo_ml.GetFieldValueAsString('X_Monter1_ID.X_store_ID');
        end;;

        mOLEStorecard:= GetAbraOLEApplication;
        mOResultStorecard:= mOLEStorecard.CreateStrings;
        mRollStorecard:= mOLEStorecard.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 0);   // materiál
                          if not mRollStorecard.MultiSelectDialog(true, mOResultStorecard) then Exit;
                                midsStorecard:= TStringList.Create;
                                midsStorecard.Text:= mOResultStorecard.Text;
                                  for ii:=0 to midsStorecard.count-1 do begin
                                      mNewRow := mRows_ml.AddNewObject;
                                          mNewRow.SetFieldValueAsInteger('itemtype',1);          // 0 práce , 1 skladová karta
                                          //mNewRow.SetFieldValueAsString('serviceworkcategory_id','');
                                          mNewRow.SetFieldValueAsString('WorkerRole_ID',mbo_ml.GetFieldValueAsString('X_Monter1_ID'));
                                          mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mbo_ml.GetFieldValueAsString('X_Monter1_ID'));
                                          mNewRow.SetFieldValueAsString('Store_id',mStore_ID);
                                          mNewRow.SetFieldValueAsString('StoreCard_id',midsStorecard.Strings[ii]);
                                         mPocet:='1';

                                          try
                                                mForm1 := TForm.Create(xSite);mForm1.Caption := 'Zadání materiálu';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;
                                                    mForm1.Width := 1450;mForm1.Height := 125;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                            mCedAccountingType2 :=// CreateNxComboEdit('Store_ID', 'Sklad:', 10, 10, 150, 70, 0, 'O3ZO2K155FDL3CL100C4RHECN0', 'Code', 'Name', mStore_id, mForm1) ;
                                                                                   CreateNxComboEditxx('Store_ID', 'Sklad',  10, 5, 150,0,50,70,30,'O3ZO2K155FDL3CL100C4RHECN0', 'Code', 'Name', mStore_id, mForm1) ;

                                                            mCedAccountingType := //CreateNxComboEdit('Storecard_ID', 'Skladová karta:', 240, 10, 300, 100, 100, 'S3WZQKDB5FDL342M01C0CX3FCC', 'Code', 'Name', midsStorecard.Strings[ii], mForm1) ;
                                                                                  CreateNxComboEditxx('Storecard_ID', 'Skladová karta:', 240, 5, 350,120,150,120,150,'S3WZQKDB5FDL342M01C0CX3FCC', 'Code', 'Name', midsStorecard.Strings[ii], mForm1) ;
                                                    mL_Quantity:= TLabel.Create(mForm1);mL_Quantity.Parent := mForm1;mL_Quantity.Caption := 'Množství :';mL_Quantity.Top := 10;mL_Quantity.Left := 600;mL_Quantity.Height := 13;mL_Quantity.Width := 90;
                                                    mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 700;mEd_quantity.Top := 10;mEd_quantity.Width := 40;mEd_quantity.Name := 'mEd_quantity';mEd_quantity.Text:='1';mForm1.InsertControl(mEd_quantity);


                                                    mL_Unit:= TLabel.Create(mForm1); mL_Unit.Parent := mForm1;mL_Unit.Caption := 'Jednotka :';mL_Unit.Top := 10; mL_Unit.Left := 750;mL_Unit.Height := 13;mL_Unit.Width := 90;
                                                    mEd_unit := TComboEdit.Create(mForm1);mEd_unit.Left := 850;mEd_unit.Top := 10;mEd_unit.Width := 40;mEd_unit.Name := 'mEd_unit';mEd_unit.Text:= mNewRow.getFieldValueAsString('QUnit');

                                                  mForm1.InsertControl(mEd_unit);
                                                    mL_Price:= TLabel.Create(mForm1);mL_Price.Parent := mForm1; mL_Price.Caption := 'Cena/j :';mL_Price.Top := 10;mL_Price.Left := 900;mL_Price.Height := 13;mL_Price.Width := 90;
                                                    mEd_Price := TEdit.Create(mForm1);mEd_Price.Left := 1000;mEd_Price.Top := 10;mEd_Price.Width := 90;mEd_Price.Name := 'mEd_Price';mEd_Price.Text:=NxFloatToIBStr(mNewRow.getFieldValueAsFloat('UnitPriceWithoutVAT'));mForm1.InsertControl(mEd_Price);


                                                    mL_Sleva:= TLabel.Create(mForm1);mL_Sleva.Parent := mForm1;mL_Sleva.Caption := 'Sleva :';mL_Sleva.Top := 10;mL_Sleva.Left := 1110;mL_Sleva.Height := 13;mL_Sleva.Width := 40;
                                                    mEd_Sleva := TEdit.Create(mForm1);mEd_Sleva.Left := 1150;mEd_Sleva.Top := 10; mEd_Sleva.Width := 40;mEd_Sleva.Name := 'mEd_Sleva';mEd_Sleva.Text:=mBO_ml.GetFieldValueAsString('ServiceDocument_ID.X_discount');mForm1.InsertControl(mEd_Sleva);

                                                    mL_FAkt:= TLabel.Create(mForm1);mL_FAkt.Parent := mForm1;mL_FAkt.Caption := 'Fakturovat :';mL_FAkt.Top := 10;mL_FAkt.Left := 1200;mL_FAkt.Height := 13;mL_FAkt.Width := 90;
                                                    mEd_Fakt:= TComboBox.Create(mForm1);mEd_Fakt.Parent := mForm1;mEd_Fakt.Top := 10;mEd_Fakt.Left := 1300; mEd_Fakt.Name := 'mEd_Fakt';

                                                    mEd_Fakt.Text:= 'K fakturaci';
                                                    mEd_Fakt.Items.Clear;
                                                    mEd_Fakt.Items.Add('K fakturaci');
                                                    mEd_Fakt.Items.Add('Nefakturovat');
                                                    mL_FAkt.Height := 13;mL_FAkt.Width := 100;



                                                    mL_Desc:= TLabel.Create(mForm1);mL_Desc.Parent := mForm1;mL_Desc.Caption := 'Popis :';mL_Desc.Top := 40;mL_Desc.Left := 10;mL_Desc.Height := 13;mL_Desc.Width := 1000;
                                                    mEd_Desc := TEdit.Create(mForm1);mEd_Desc.Left := 10;mEd_Desc.Top := 40; mEd_Desc.Width := 1000;mEd_Desc.Name := 'mEd_Desc';mEd_Desc.Text:='    ';mForm1.InsertControl(mEd_Desc);

                                                    mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                    mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);



                                             if mForm1.ShowModal(xSite) = mrOK then begin
                                                  mStore_id:=mCedAccountingType2.DataText ;

                                                  mNewRow.SetFieldValueAsString('Store_id',mStore_id);
                                                  mNewRow.SetFieldValueAsString('Storecard_ID',mCedAccountingType.DataText);
                                                  mNewRow.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mEd_quantity.Text));
                                                   mNewRow.SetFieldValueAsstring('Qunit',mEd_unit.Text);
                                                   mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Price.Text));
                                                   mNewRow.SetFieldValueAsfloat('X_radkova_sleva',NxIBStrToFloat(mEd_Sleva.Text));
                                                   mNewRow.SetFieldValueAsstring('X_Description',mEd_Desc.Text);
                                                   if mEd_Fakt.Text='K fakturaci' then begin
                                                        mNewRow.SetFieldValueAsinteger('ToInvoiceType',0);
                                                   end else begin
                                                        mNewRow.SetFieldValueAsinteger('ToInvoiceType',1);
                                                   end;
                                             end;
                                          finally;
                                            mForm1.Free;
                                          end;







                                        // mPocet:=inputbox('Zadej množství', 'Na skladové kartě: ' + mNewRow.getFieldValueAsString('StoreCard_id.name'),mPocet);
                                        // if NxIsValidFloat(mpocet) then begin
                                        //      m
                                        // end else begin
                                        //     NxShowSimpleMessage('ZAdaná položka není číselného tvaru', nil);
                                        // end;
                                          //mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);;
                                          //mNewRow.Save;
                                          //mNewRow.free;

                                end;
                                result:=true;

end;

function CreateNxComboEdit(AName, ACaption: string;
  ALeft, ATop, AWidth, ALblWidth, ABevelWidth: Integer;
  AClassID, ATextField, AControlField, AID: string;
  AParent: TWinControl;
  AParam: string = ''; AChange: string =''): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
begin
  if AID = '' then
    AID:= '0000000000';
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  mLbl1:= TLabel.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
  if AName <> '' then
    mLbl1.Name:= 'lblBev_' + AName;
  mLbl1.Width:= ABevelWidth;
  mLbl1.Visible:= ABevelWidth > 0;

  Result:= TRollComboEdit.Create(AParent);
  Result.Parent:= AParent;
  Result.ClassID:= AClassID;
  Result.ForcedField:= True;
  Result.Prefilling:= pmNone;
  Result.TextField:= ATextField;
  Result.Parameters.Add(AParam);
  Result.Top:= ATop + 3;
  Result.Left:= ALeft + ALblWidth;
  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= mLbl1;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;


  if (AChange <> '') and (AName <> '') then
  begin
    mLblChange:= TLabel.Create(AParent);
    mLblChange.Parent:= AParent;
    mLblChange.Top:= 0;
    mLblChange.Left:= 0;
    mLblChange.ViSible:= False;
    mLblChange.Name:= 'lblCh_' + AName;
    mLblChange.Caption:= AChange;
    Result.OnChange:= @NxDBComboEditChange;
  end;


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;




function NEWText(mBO_ml:TNxCustomBusinessObject;xsite: TSiteForm;mRows_ml:TNxCustomBusinessMonikerCollection):Boolean;
var
  ii:integer;
   mOLEStore, mRollStore, mOResultStore,mOResult1: Variant;
   mOLEStorecard, mRollStorecard, mOResultStorecard: Variant;
   midsStore,midsStorecard:TStringList;
   mStore_id,mStorecard_ID:string;
   mNewRow:TNxCustomBusinessObject;
   mPocet:string;
  mForm1 : TForm;
  mBtn : TButton;
  mEd1_pohotovost:TCheckBox;
  mEd1_C_chyby,m1Ed1_C_chyby,mEd1_C_protokol:tedit;

  mL_Store_value,mEd_Fakt,mEd_Sum:TComboBox;

  mL_StoreCard_value,mEd_unit : TComboedit;
  mEd_Dod:TComboEdit;
  mL_Store,mL_StoreCard,mL_Quantity,mL_Unit,mL_Price,mL_Sleva,mL_FAkt,mL_Desc,mL_Dod :TLabel;
  mEd_quantity,mEd_Price,mEd_Sleva,mEd_Desc:tedit;
  mCb_SC_O_code:TRollComboEdit;
  mCb_CC_O_id,mCb_CC_O_code,mCbCc:TComboBevel;
begin
mNewRow := mRows_ml.AddNewObject;
                                          mNewRow.SetFieldValueAsInteger('itemtype',4);
                                         // mNewRow.SetFieldValueAsString('WorkerRole_ID',mbo_ml.GetFieldValueAsString('X_Monter1_ID'));
                                         // mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mbo_ml.GetFieldValueAsString('X_Monter1_ID'));
                                         // mNewRow.SetFieldValueAsString('Store_id',mStore_ID);
                                         // mNewRow.SetFieldValueAsString('StoreCard_id',midsStorecard.Strings[ii]);
                                         mPocet:='1';





                                                mForm1 := TForm.Create(xSite);mForm1.Caption := 'Zadání textu';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;
                                                    mForm1.Width := 1450;mForm1.Height := 125;mForm1.Scaled := False;mform1.Position := poScreenCenter;

                                                    mL_Store:= TLabel.Create(mForm1);mL_Store.Parent := mForm1;mL_Store.Caption := 'Text:';mL_Store.Top := 10;mL_Store.Left := 10;mL_Store.Height := 13;
                                                    mL_Store_value:= TComboBox.Create(mForm1);mL_Store_value.Parent := mForm1;mL_Store_value.Top := 10;mL_Store_value.Left := 120;

                                                    mL_Store_value.Text:= 'Servisní práce včetně dopravy';
                                                    mL_Store_value.Items.Clear;
                                                    mL_Store_value.Items.Add('Servisní práce včetně dopravy');
                                                    mL_Store_value.Items.Add('Elektroinstalační materiál');
                                                    mL_Store_value.Items.Add('Subdodávka');


                                                    mL_Store_value.Height := 13;mL_Store_value.Width := 400;

                                                    mL_Quantity:= TLabel.Create(mForm1);mL_Quantity.Parent := mForm1;mL_Quantity.Caption := 'Množství :';mL_Quantity.Top := 10;mL_Quantity.Left := 600;mL_Quantity.Height := 13;mL_Quantity.Width := 90;
                                                    mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 700;mEd_quantity.Top := 10;mEd_quantity.Width := 40;mEd_quantity.Name := 'mEd_quantity';mEd_quantity.Text:='1';mForm1.InsertControl(mEd_quantity);

                                                    mL_Unit:= TLabel.Create(mForm1); mL_Unit.Parent := mForm1;mL_Unit.Caption := 'Jednotka :';mL_Unit.Top := 10; mL_Unit.Left := 750;mL_Unit.Height := 13;mL_Unit.Width := 90;
                                                    mEd_unit := TComboedit.Create(mForm1);mEd_unit.Left := 850;mEd_unit.Top := 10;mEd_unit.Width := 40;mEd_unit.Name := 'mEd_unit';mEd_unit.Text:= mNewRow.getFieldValueAsString('QUnit');


                                                    mL_Price:= TLabel.Create(mForm1);mL_Price.Parent := mForm1; mL_Price.Caption := 'Cena/j :';mL_Price.Top := 10;mL_Price.Left := 900;mL_Price.Height := 13;mL_Price.Width := 90;
                                                    mEd_Price := TEdit.Create(mForm1);mEd_Price.Left := 1000;mEd_Price.Top := 10;mEd_Price.Width := 90;mEd_Price.Name := 'mEd_Price';mEd_Price.Text:=NxFloatToIBStr(mNewRow.getFieldValueAsFloat('UnitPriceWithoutVAT'));mForm1.InsertControl(mEd_Price);


                                                    mL_Sleva:= TLabel.Create(mForm1);mL_Sleva.Parent := mForm1;mL_Sleva.Caption := 'Sleva :';mL_Sleva.Top := 10;mL_Sleva.Left := 1110;mL_Sleva.Height := 13;mL_Sleva.Width := 40;
                                                    mEd_Sleva := TEdit.Create(mForm1);mEd_Sleva.Left := 1150;mEd_Sleva.Top := 10; mEd_Sleva.Width := 40;mEd_Sleva.Name := 'mEd_Sleva';mEd_Sleva.Text:=mBO_ml.GetFieldValueAsString('ServiceDocument_ID.X_discount');mForm1.InsertControl(mEd_Sleva);

                                                    mL_FAkt:= TLabel.Create(mForm1);mL_FAkt.Parent := mForm1;mL_FAkt.Caption := 'Fakturovat :';mL_FAkt.Top := 10;mL_FAkt.Left := 1200;mL_FAkt.Height := 13;mL_FAkt.Width := 90;
                                                    //mEd_Fakt := TComboEdit.Create(mForm1);mEd_Fakt.Left := 1300;mEd_Fakt.Top := 10; mEd_Fakt.Width := 100;mEd_Fakt.Name := 'mEd_Fakt';mEd_Fakt.Text:= 'ANO';mForm1.InsertControl(mEd_Fakt);

                                                    mEd_Fakt:= TComboBox.Create(mForm1);mEd_Fakt.Parent := mForm1;mEd_Fakt.Top := 10;mEd_Fakt.Left := 1250;

                                                    mEd_Fakt.Text:= 'Ano';
                                                    mEd_Fakt.Items.Clear;
                                                    mEd_Fakt.Items.Add('Ano');
                                                    mEd_Fakt.Items.Add('Ne');
                                                   mEd_Fakt.Height := 13;mEd_Fakt.Width := 50;



                                                    mEd_Sum:= TComboBox.Create(mForm1);mEd_Sum.Parent := mForm1;mEd_Sum.Top := 10;mEd_Sum.Left := 1320;

                                                    mEd_Sum.Text:= 'Ano';
                                                    mEd_Sum.Items.Clear;
                                                    mEd_Sum.Items.Add('Ano');
                                                    mEd_Sum.Items.Add('Ne');
                                                   mEd_Sum.Height := 13;mEd_Fakt.Width := 60;




                                                    mL_Desc:= TLabel.Create(mForm1);mL_Desc.Parent := mForm1;mL_Desc.Caption := 'Popis :';mL_Desc.Top := 40;mL_Desc.Left := 10;mL_Desc.Height := 13;mL_Desc.Width := 1000;
                                                    mEd_Desc := TEdit.Create(mForm1);mEd_Desc.Left := 150 ;mEd_Desc.Top := 40; mEd_Desc.Width := 850;mEd_Desc.Name := 'mEd_Desc';mEd_Desc.Text:='    ';mForm1.InsertControl(mEd_Desc);


                                                    mL_Dod:= TLabel.Create(mForm1);mL_Store.Parent := mForm1;mL_Store.Caption := 'Subdodávka:';mL_Store.Top := 40;mL_Store.Left := 1010;mL_Store.Height := 13;mL_Store.Width := 40;



                                                                                              mCb_CC_O_code:= TComboBevel.Create(mForm1);  //VytvoÓenÝ containeru pro zobrazenÝ vřbýru&#xD;
                                                                                              mCb_CC_O_code.Parent:= mForm1;
                                                                                              mCb_CC_O_code.Left:= 1200;
                                                                                              mCb_CC_O_code.Top:= 40;
                                                                                              mCb_CC_O_code.Width:= 500;

                                                                                              mCb_SC_O_code := TRollComboEdit.Create(mForm1);
                                                                                              mCb_SC_O_code.Parent := mForm1;

                                                                                              mCb_SC_O_code.ClassID := 'O3OWQQYWYJCL3J0B01K0LEIOE0';
                                                                                              mCb_SC_O_code.Complete:= True;
                                                                                              mCb_SC_O_code.ForcedField:= True;
                                                                                              mCb_SC_O_code.Prefilling:= pmNone;
                                                                                              mCb_SC_O_code.TextField:= 'Name';  // položka podle které se bude vyhledávat
                                                                                              //mCb_SC_O_code.Text:= 'Subdodávka';
                                                                                              mCb_SC_O_code.Top:= 40;
                                                                                              mCb_SC_O_code.Left:= 1200;
                                                                                              mCb_SC_O_code.Width:= 150;
                                                                                              mCb_SC_O_code.ConnectedControl:= mCbCc;
                                                                                              //mCb_SC_O_code.Text:=mRow_Row.GetFieldValueAsstring('Storecard_ID.code') ;
                                                                                              mCb_SC_O_code.Enabled:=true;


                                                                                              mCb_SC_O_code.ConnectedControl:= mCb_CC_O_ID;
                                                                                              mCb_SC_O_code.ConnectedControlField:= 'ID';  //polo

                                                                                              mCb_SC_O_code.ConnectedControl:= mCb_CC_O_code;
                                                                                              mCb_SC_O_code.ConnectedControlField:= 'Name';  //polo×ka kterß bude zobrazena v containeru&;






                                                    //mEd_Dod:= TnxbComboEdit.Create(mForm1);mEd_Dod.Parent := mForm1;mEd_Dod.Top := 40;mEd_Dod.Left := 1220;






                                                    mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                    mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);




                                             if mForm1.ShowModal(xSite) = mrOK then begin
                                                   mNewRow.SetFieldValueAsString('Text',mL_Store_value.Text);
                                                   mNewRow.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mEd_quantity.Text));
                                                   mNewRow.SetFieldValueAsstring('Qunit','ks');
                                                   mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Price.Text));
                                                   mNewRow.SetFieldValueAsfloat('X_radkova_sleva',NxIBStrToFloat(mEd_Sleva.Text));
                                                   mNewRow.SetFieldValueAsstring('X_Description',mEd_Desc.Text);
                                                   if mEd_Fakt.text='Ano' then begin
                                                        mNewRow.SetFieldValueAsInteger('ToInvoiceType',0);
                                                   end else begin
                                                        mNewRow.SetFieldValueAsInteger('ToInvoiceType',1);
                                                   end;
                                                   if not(NxIsEmptyOID(mCb_SC_O_code.DataText)) then begin
                                                      mNewRow.SetFieldValueAsstring('X_Firm_ID',mCb_SC_O_code.DataText);
                                                   end;



                                             end;

                                            mForm1.Free;


                                result:=true;

end;

function iGetState(xSite:TSiteForm):TNxOID;
var
   mOLE_SSP, mRoll_SSP, mOResult_SSP: Variant;
   morigstate:string;
   mids:tstringlist;
   mids_Stav:String;
begin
          mOLE_SSP:= GetAbraOLEApplication;
          mOResult_SSP:= mOLE_SSP.CreateStrings;
              mRoll_SSP:=mOLE_SSP.GetRoll('E3F32SDRXAI4TBOXRMKHHRI1TS', 0);
              mRoll_SSP.Params.Add('FilterX_field3=Ano');
              if not mRoll_SSP.multiSelectDialog(true,mOResult_SSP) then Exit;
                   mids:=TStringList.create;
                   try
                       mids.text:=mOResult_SSP.text;
                       result:=mids.Strings[0];
               finally
                   mids.free;
               end;
end;

function iGetPayment_ID(xSite:TSiteForm):TNxOID;
var
   mOLE_SSP, mRoll_SSP, mOResult_SSP: Variant;
   morigstate:string;
   mids:tstringlist;
   mids_Stav:String;
begin
          mOLE_SSP:= GetAbraOLEApplication;
          mOResult_SSP:= mOLE_SSP.CreateStrings;
              mRoll_SSP:=mOLE_SSP.GetRoll('K24KIBA3Y3CL33N2010DELDFKK', 0);
              if not mRoll_SSP.multiSelectDialog(true,mOResult_SSP) then Exit;
                   mids:=TStringList.create;
                   try
                       mids.text:=mOResult_SSP.text;
                       result:=mids.Strings[0];
               finally
                   mids.free;
               end;
end;


function NxCRM(State:integer;mBO_ML_Row: TNxCustomBusinessObject;mTechnik_ID:string;mF_start:Date;mF_konec:Date;mdruh:string;mpopis:string ): boolean;
var
  MSum:integer;
  mhodnota:double;
  mr:tstringlist;
  mheaderBO:TNxCustomBusinessObject;
  zapis:Boolean;
  I:integer;
  mtime:double;
  mstav:boolean;
  mstring:string;
begin
 mstav:=false;
 zapis:=false;
 mr:=TStringList.Create;
     try
               mheaderBO:= mBO_ML_Row.ObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
               try
                   mBO_ML_Row.ObjectSpace.SQLSelect(Format('select id from CRMActivities where x_Parent_id= %s',[quotedstr(mBO_ML_Row.GetFieldValueAsString('ID'))]),mr);
                  {  if mr.count>1 then begin
                       for i := 0 to mR.Count - 1 do begin
                            mheaderBO.load(mr.Strings[0],nil);
                            mHeaderBO.Delete;
                            mstav:=false;
                       end;
                    end; }
                    if (mr.count=0) then begin
                        mHeaderBO.New;
                        mHeaderBO.Prefill;
                        zapis:=true;
                        mHeaderBO.SetFieldValueAsString('ActivityArea_ID', '2000000101');
                        mHeaderBO.SetFieldValueAsString('ActivityType_ID', '1100000101');
                        mHeaderBO.SetFieldValueAsString('ActQueue_ID', mBO_ML_Row.GetFieldValueAsString('Parent_id.ServiceDocument_ID.DocQueue_id.X_ActDocQueue_ID'));
                        mHeaderBO.SetFieldValueAsString('Firm_ID', mBO_ML_Row.GetFieldValueAsString('Parent_id.ServiceDocument_ID.PayerFirm_ID'));
                        mHeaderBO.SetFieldValueAsString('Person_ID', mBO_ML_Row.GetFieldValueAsString('Parent_id.ServiceDocument_ID.PayerPerson_ID'));
                        mHeaderBO.SetFieldValueAsString('Division_ID', mBO_ML_Row.GetFieldValueAsString('Parent_id.ServiceDocument_ID.Division_ID'));
                        mHeaderBO.SetFieldValueAsDateTime('SheduledStart$Date',mF_start);
                        mHeaderBO.SetFieldValueAsDateTime('SheduledEnd$Date', mF_konec);
                        mHeaderBO.SetFieldValueAsString('U_ServicedObject_ID',mBO_ML_Row.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServicedObject_ID'));
                        mHeaderBO.SetFieldValueAsString('X_Parent_id', mBO_ML_Row.OID);
                        mHeaderBO.SetFieldValueAsString('X_Parent_head', mBO_ML_Row.GetFieldValueAsString('Parent_id'));
                        mHeaderBO.SetFieldValueAsString('SolverRole_ID', mTechnik_ID);
                        mstring:= copy(mBO_ML_Row.GetFieldValueAsString('parent_ID.ServiceDocument_ID.docqueue_ID.code') + '-' +inttostr(mBO_ML_Row.GetFieldValueAsinteger('parent_ID.ServiceDocument_ID.ordnumber')) +'/'+ mBO_ML_Row.GetFieldValueAsString('parent_ID.ServiceDocument_ID.Period_ID.code')
                              +', '+mHeaderBO.getFieldValueAsString('U_ServicedObject_ID.code') + ' - '+
                                                                        mHeaderBO.getFieldValueAsString('U_ServicedObject_ID.X_id_zakaznika_id.name') + ', '+
                                                                        mHeaderBO.getFieldValueAsString('U_ServicedObject_ID.X_id_zakaznika_id.U_ulice1') + ', '+
                                                                        mHeaderBO.getFieldValueAsString('U_ServicedObject_ID.X_id_zakaznika_id.U_mesto') + ', '+
                                                                        mHeaderBO.getFieldValueAsString('U_ServicedObject_ID.OutdoorPlaceDescription'),1,99);
                        mHeaderBO.SetFieldValueAsString('Subject',mstring);


                        mHeaderBO.SetFieldValueAsDateTime('RealStart$Date',mF_start);
                        mHeaderBO.SetFieldValueAsDateTime('RealEnd$Date', mF_konec);






                     mheaderBO.Save;
                     result:=true;
                     end;


                    if mr.count=1 then begin
                      mheaderBO.load(mr.Strings[0],nil);
                    end;

              finally
                  mheaderBO.free;

              end ;
       finally
           mr.free;
       end;

end;


begin
end.