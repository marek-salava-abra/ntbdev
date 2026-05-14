//uses 'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.const',
//       'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.funkce';
var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
      mEdtSrc:TEdit;

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
                mForm.Caption := 'Vstupní obrazovka';
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



      function iGetIDByName(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Name=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;


{
Vyvolává se před fyzickým zrušením instance.
}


function iGetIDByCode(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Code=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;


procedure iFillStoreCards(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Name FROM Storecards WHERE Hidden=''N'' ORDER BY Name';
  begin
//    NxShowSimpleMessage(cSQL,nil);
    AOS.SQLSelect(cSQL, AList);
  end;


function iSelectZavada(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('2HS2SGQFQKJ4T5A3L5WHHXTWXS', 0);
  Result := mRoll.SelectDialog2(True, mXX);
end;

function iSelectStore(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('O3ZO2K155FDL3CL100C4RHECN0', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;

function iSelectWorkerRole(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;


procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mbo_zavada,mbo_operace,mBO_new:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mSite1 : TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii,j:integer;
  mr,mr1,mr2:TStringList;
   mForm: TForm;
    mMon_Row,mMon_Operace,mMon_Operace_row: TNxCustomBusinessMonikerCollection;
   mRow, mRow_Row,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mi:integer;
   adate:Double;
   mWorkerrole_ID,mStore_ID:string;
   mStorecard_ID:string;
   mquantity:double;
  mBtn : TButton;
  mLblm,mLbl2,mLbl3,mLabel3 : TLabel;
  cbStoreCards : TComboBox;
  mCbCc:TComboBevel;
  mCb_SC_O_code:TRollComboEdit;
  mL_SC_O_code,mL_SC_O_name,mL_SC_O_quantity,mL_SC_o,mL_SC_O_qunit:TLabel ;
  mED_SC_O_quantity :TEdit;
  mCb_CC_O_code : TComboBevel;
  mCb_CC_O_name : TComboBevel;
  mCb_CC_O_id : TComboBevel;
  mcena:double;
begin
    mSite := TComponent(Sender).DynSite;
    mSite1 := TComponent(Sender).Site;;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    try
mtext:=iSelectZavada(mSite.GetAbraOLEApplication);
mStore_ID:='';
mWorkerrole_ID:='';



            if mtext<>'' then begin
                    if mBookmark.count=0 then begin
                                mBO := TDynSiteForm(mSite).CurrentObject;                                        // doklad ML
                                if not nxisemptyoid(mbo.GetFieldValueAsString('X_monter1_ID')) then begin
                                     mWorkerrole_ID:=mbo.GetFieldValueAsString('X_monter1_ID');
                                        if not nxisemptyoid(mbo.GetFieldValueAsString('X_monter1_ID.X_store_ID')) then begin      // doplnění skladu z role
                                           mStore_ID:=mbo.GetFieldValueAsString('X_monter1_ID.X_store_ID');
                                        end else begin
                                           mStore_ID:=iSelectStore(mSite.GetAbraOLEApplication);
                                        end;;
                                end else begin
                                    mWorkerrole_ID:=iSelectWorkerRole(mSite.GetAbraOLEApplication);
;                               end;

mcena:=0;


                                mMon_Row:= mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')); // Řádky ML

                                              mbo_zavada:=mbo.ObjectSpace.CreateObject('ICCXDIBSOG24P035ZTCVVQ5XZK');
                                              try
                                                 mbo_zavada.Load(mtext,nil);    // servisní závada
                                                  mMon_operace := mbo_zavada.GetLoadedCollectionMonikerForFieldCode(mbo_zavada.GetFieldCode('Operations')); // sezna operací
                                                  for i := 0 to mMon_operace.Count-1 do begin
                                                        try
                                                            mRow := mMon_operace.BusinessObject[i];
                                                                mbo_operace:= mbo_zavada.ObjectSpace.CreateObject('KT2VYJLN4J4OLG1CMIEZACQRVC');
                                                                    try
                                                                       mbo_operace.load(mrow.GetFieldValueAsString('ServiceOperation_id'),nil);
                                                                            mMon_Operace_row:= mbo_operace.GetLoadedCollectionMonikerForFieldCode(mbo_operace.GetFieldCode('Rows')); // sezna operací
                                                                            for ii := 0 to mMon_Operace_row.Count-1 do begin
                                                                                  try
                                                                                      mRow_Row:= mMon_Operace_row.BusinessObject[ii];



                                                                                         if mRow_Row.GetFieldValueAsBoolean('X_volba') or mRow_Row.GetFieldValueAsBoolean('X_Volitelna') then begin   // změna skladové karty

                                                                                             mForm:= TForm.Create(mSite1);
                                                                                             if mRow_Row.GetFieldValueAsBoolean('X_volba') then begin
                                                                                                   mForm.Caption := 'Specifikkujte položku. Pokud ji nechcete použít zadejte v množství 0';
                                                                                             end;
                                                                                             if mRow_Row.GetFieldValueAsBoolean('X_Volitelna') then begin
                                                                                                   mForm.Caption := 'Volba příslušenství. Pokud ho nechcete použít zadejte v množství 0';
                                                                                             end;
                                                                                              //mForm.FormStyle := fsStayOnTop;
                                                                                              //mForm.BorderStyle := bsDialog;
                                                                                              mForm.Width := 800;
                                                                                              mForm.Height := 170;
                                                                                              mForm.Scaled := False;
                                                                                              mform.Position := poScreenCenter;

                                                                                              if mRow_Row.GetFieldValueAsBoolean('X_volba') then begin
                                                                                                          mL_SC_O:= TLabel.Create(mForm);
                                                                                                          mL_SC_O.Parent := mForm;
                                                                                                          mL_SC_O.Caption := 'Skladová karta:';
                                                                                                          mL_SC_O.Top := 20;
                                                                                                          mL_SC_O.Left := 20 ;
                                                                                                          mL_SC_O.Width:= 120;

                                                                                                          mL_SC_O_code:= TLabel.Create(mForm);
                                                                                                          mL_SC_O_code.Parent := mForm;
                                                                                                          mL_SC_O_code.Caption := mRow_Row.GetFieldValueAsstring('Storecard_ID.code');
                                                                                                          mL_SC_O_code.Top := 20;
                                                                                                          mL_SC_O_code.Left := 150 ;
                                                                                                          mL_SC_O_code.Width:= 120;

                                                                                                          mL_SC_O_Name:= TLabel.Create(mForm);
                                                                                                          mL_SC_O_Name.Parent := mForm;
                                                                                                          mL_SC_O_Name.Caption := mRow_Row.GetFieldValueAsstring('Storecard_ID.Name');
                                                                                                          mL_SC_O_Name.Top := 20;
                                                                                                          mL_SC_O_Name.Left := 280 ;
                                                                                                          mL_SC_O_Name.Width:= 200;

                                                                                                          mL_SC_O_Quantity:= TLabel.Create(mForm);
                                                                                                          mL_SC_O_Quantity.Parent := mForm;
                                                                                                          mL_SC_O_Quantity.Caption := FloatToStr(mRow_Row.GetFieldValueAsFloat('Quantity'));
                                                                                                          mL_SC_O_Quantity.Top := 20;
                                                                                                          mL_SC_O_Quantity.Left := 490 ;
                                                                                                          mL_SC_O_Quantity.Width:= 100;

                                                                                                          mL_SC_O_Qunit:= TLabel.Create(mForm);
                                                                                                          mL_SC_O_Qunit.Parent := mForm;
                                                                                                          mL_SC_O_Qunit.Caption := mRow_Row.GetFieldValueAsstring('Storecard_ID.MainUnitCode');;
                                                                                                          mL_SC_O_Qunit.Top := 20;
                                                                                                          mL_SC_O_Qunit.Left := 600;
                                                                                                          mL_SC_O_Qunit.Width:= 100;
                                                                                              end;

                                                                                              mL_SC_O:= TLabel.Create(mForm);
                                                                                              mL_SC_O.Parent := mForm;
                                                                                              mL_SC_O.Caption := 'Nová karta:';
                                                                                              mL_SC_O.Top := 50;
                                                                                              mL_SC_O.Left := 20 ;
                                                                                              mL_SC_O.Width:= 120;


                                                                                              mCb_CC_O_id:= TComboBevel.Create(mForm);  //VytvoÓenÝ containeru pro zobrazenÝ vřbýru&#xD;
                                                                                              mCb_CC_O_id.Parent:= mForm;
                                                                                              mCb_CC_O_id.Left:= 280;
                                                                                              mCb_CC_O_id.Top:= 48;
                                                                                              mCb_CC_O_id.Width:= 200;


                                                                                              mCb_CC_O_code:= TComboBevel.Create(mForm);  //VytvoÓenÝ containeru pro zobrazenÝ vřbýru&#xD;
                                                                                              mCb_CC_O_code.Parent:= mForm;
                                                                                              mCb_CC_O_code.Left:= 280;
                                                                                              mCb_CC_O_code.Top:= 48;
                                                                                              mCb_CC_O_code.Width:= 200;





                                                                                              mCb_SC_O_code := TRollComboEdit.Create(mForm);
                                                                                              mCb_SC_O_code.Parent := mForm;

                                                                                              mCb_SC_O_code.ClassID := 'S3WZQKDB5FDL342M01C0CX3FCC';
                                                                                              mCb_SC_O_code.Complete:= True;
                                                                                              mCb_SC_O_code.ForcedField:= True;
                                                                                              mCb_SC_O_code.Prefilling:= pmNone;
                                                                                              mCb_SC_O_code.TextField:= 'CODE';  // položka podle které se bude vyhledávat
                                                                                              mCb_SC_O_code.Top:= 50;
                                                                                              mCb_SC_O_code.Left:= 150;
                                                                                              mCb_SC_O_code.Width:= 120;
                                                                                              mCb_SC_O_code.ConnectedControl:= mCbCc;
                                                                                              mCb_SC_O_code.Text:=mRow_Row.GetFieldValueAsstring('Storecard_ID.code') ;
                                                                                              if mRow_Row.GetFieldValueAsBoolean('X_Volitelna') then begin
                                                                                                 mCb_SC_O_code.Enabled:=false;
                                                                                                 end else begin
                                                                                                 mCb_SC_O_code.Enabled:=true;
                                                                                              end;


                                                                                              mCb_SC_O_code.ConnectedControl:= mCb_CC_O_ID;
                                                                                              mCb_SC_O_code.ConnectedControlField:= 'ID';  //polo

                                                                                              mCb_SC_O_code.ConnectedControl:= mCb_CC_O_code;
                                                                                              mCb_SC_O_code.ConnectedControlField:= 'Name';  //polo×ka kterß bude zobrazena v containeru&;


                                                                                              mEd_SC_O_Quantity:= TEdit.Create(mForm);
                                                                                              mEd_SC_O_Quantity.Left := 490;
                                                                                              mEd_SC_O_Quantity.Top := 50;
                                                                                              mEd_SC_O_Quantity.Width := 80;
                                                                                              mEd_SC_O_Quantity.Name := 'mEd_SC_O_Quantity';
                                                                                              mEd_SC_O_Quantity.Text:=FloatToStr(mRow_Row.GetFieldValueAsFloat('Quantity'));
                                                                                              mForm.InsertControl(mEd_SC_O_Quantity);



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


                                                                                              if mForm.ShowModal(mSite1) = mrOK then begin
                                                                                                    if mCb_SC_O_code.DataText='' then begin
                                                                                                        mStorecard_ID:=mRow_Row.GetFieldValueAsstring('Storecard_ID');
                                                                                                    end else begin
                                                                                                        mStorecard_ID:=mCb_SC_O_code.DataText;
                                                                                                    end;
                                                                                                    mQuantity:=NxIBStrToFloat(mEd_SC_O_Quantity.Text);
                                                                                                    if mQuantity>0 then begin
                                                                                                            mBO_new:= mMon_Row.AddNewObject;

                                                                                                            mBO_new.SetFieldValueAsinteger('itemtype',mRow_Row.GetFieldValueAsinteger('itemtype'));
                                                                                                            mBO_new.SetFieldValueAsinteger('PosIndex',100+ strtoint(inttostr(I+1) +inttostr(II+1)));
                                                                                                            mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                            mBO_new.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                                                                            if mStore_ID='' then begin
                                                                                                                mBO_new.SetFieldValueAsString('Store_ID',mBO_new.GetFieldValueAsString('WorkerRole_ID.X_Store_ID'));
                                                                                                            end else begin
                                                                                                                mBO_new.SetFieldValueAsString('Store_ID',mStore_ID);
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsString('Storecard_ID',mstorecard_ID);
                                                                                                            mBO_new.SetFieldValueAsString('Text',mRow_Row.GetFieldValueAsString('TextDescription'));
                                                                                                            mBO_new.SetFieldValueAsFloat('quantity',mQuantity);
                                                                                                             if mBO_new.getFieldValueAsString('Storecard_ID')= mRow_Row.GetFieldValueAsString('Storecard_ID') then begin
                                                                                                                mBO_new.SetFieldValueAsFloat('UnitPriceWithoutVAT',mRow_Row.getFieldValueAsFloat('AmountWithoutVAT'));
                                                                                                                mBO_new.SetFieldValueAsString('VATRate_ID',mRow_Row.getFieldValueAsString('VATRate_ID'));
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsfloat('WorkHoursPlanned',mRow_Row.getFieldValueAsfloat('WorkHoursPlanned'));
                                                                                                            if index=0 then begin
                                                                                                               mcena:=mcena+(mBO_new.getFieldValueAsFloat('quantity')*mBO_new.getFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                                                                               mBO_new.SetFieldValueAsInteger('ToInvoiceType',1);
                                                                                                            end else begin
                                                                                                               mBO_new.SetFieldValueAsInteger('ToInvoiceType',0);
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                      end;
                                                                                               end else begin
                                                                                                      if true then begin
                                                                                                            mBO_new:= mMon_Row.AddNewObject;
                                                                                                            mBO_new.SetFieldValueAsinteger('itemtype',mRow_Row.GetFieldValueAsinteger('itemtype'));
                                                                                                            mBO_new.SetFieldValueAsinteger('PosIndex',strtoint(inttostr(I+1) +inttostr(II+1)));
                                                                                                            mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                            mBO_new.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                                                                            if mStore_ID='' then begin
                                                                                                                mBO_new.SetFieldValueAsString('Store_ID',mBO_new.GetFieldValueAsString('WorkerRole_ID.X_Store_ID'));
                                                                                                            end else begin
                                                                                                                mBO_new.SetFieldValueAsString('Store_ID',mStore_ID);
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsString('Storecard_ID',mstorecard_ID);
                                                                                                            mBO_new.SetFieldValueAsString('Text',mRow_Row.GetFieldValueAsString('TextDescription'));
                                                                                                            mBO_new.SetFieldValueAsFloat('quantity',mQuantity);
                                                                                                            if mBO_new.getFieldValueAsString('Storecard_ID')= mRow_Row.GetFieldValueAsString('Storecard_ID') then begin
                                                                                                                mBO_new.SetFieldValueAsFloat('UnitPriceWithoutVAT',mRow_Row.getFieldValueAsFloat('AmountWithoutVAT'));
                                                                                                                mBO_new.SetFieldValueAsString('VATRate_ID',mRow_Row.getFieldValueAsString('VATRate_ID'));
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsfloat('WorkHoursPlanned',mRow_Row.getFieldValueAsfloat('WorkHoursPlanned'));
                                                                                                            if index=0 then begin
                                                                                                               mcena:=mcena+(mBO_new.getFieldValueAsFloat('quantity')*mBO_new.getFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                                                                               mBO_new.SetFieldValueAsInteger('ToInvoiceType',1);
                                                                                                            end else begin
                                                                                                               mBO_new.SetFieldValueAsInteger('ToInvoiceType',0);
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                      end else begin

                                                                                                      end;
                                                                                               end;
                                                                                         end else begin
                                                                                                    mBO_new:= mMon_Row.AddNewObject;
                                                                                                            mBO_new.SetFieldValueAsinteger('PosIndex',strtoint(inttostr(I+1) +inttostr(II+1)));
                                                                                                            mBO_new.SetFieldValueAsinteger('itemtype',mRow_Row.GetFieldValueAsinteger('itemtype'));
                                                                                                            mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                            mBO_new.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                                                                            if mStore_ID='' then begin
                                                                                                                mBO_new.SetFieldValueAsString('Store_ID',mBO_new.GetFieldValueAsString('WorkerRole_ID.X_Store_ID'));
                                                                                                            end else begin
                                                                                                                mBO_new.SetFieldValueAsString('Store_ID',mStore_ID);
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsString('Storecard_ID',mRow_Row.getFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_new.SetFieldValueAsString('Text',mRow_Row.GetFieldValueAsString('TextDescription'));
                                                                                                            mBO_new.SetFieldValueAsFloat('quantity', mBO_new.getFieldValueAsFloat('quantity'));
                                                                                                            mBO_new.SetFieldValueAsFloat('UnitPriceWithoutVAT',mRow_Row.getFieldValueAsFloat('AmountWithoutVAT'));
                                                                                                            mBO_new.SetFieldValueAsString('VATRate_ID',mRow_Row.getFieldValueAsString('VATRate_ID'));
                                                                                                            mBO_new.SetFieldValueAsfloat('WorkHoursPlanned',mRow_Row.getFieldValueAsfloat('WorkHoursPlanned'));
                                                                                                            if index=0 then begin
                                                                                                               mcena:=mcena+(mBO_new.getFieldValueAsFloat('quantity')*mBO_new.getFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                                                                               mBO_new.SetFieldValueAsInteger('ToInvoiceType',1);
                                                                                                            end else begin
                                                                                                               mBO_new.SetFieldValueAsInteger('ToInvoiceType',0);
                                                                                                            end;
                                                                                                            mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                         end;



                                                                                  finally
                                                                                      mRow_Row.free;
                                                                                  end;
                                                                             end;
                                                                    finally
                                                                       mbo_operace.free;
                                                                    end;




                                                        finally
                                                             mrow.free;
                                                        end;

                                                  end;



                                              if index=0 then begin
                                                    mBO_new:= mMon_Row.AddNewObject;
                                                      mBO_new.SetFieldValueAsinteger('itemtype',4);
                                                      //mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                      //mBO_new.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                      //if mStore_ID='' then begin
                                                      //    mBO_new.SetFieldValueAsString('Store_ID',mBO_new.GetFieldValueAsString('WorkerRole_ID.X_Store_ID'));
                                                      //end else begin
                                                      //    mBO_new.SetFieldValueAsString('Store_ID',mStore_ID);
                                                      //end;
                                                      mBO_new.SetFieldValueAsString('Text',mbo_zavada.GetFieldValueAsString('Name'));
                                                      mBO_new.SetFieldValueAsFloat('quantity', 1);
                                                      mBO_new.SetFieldValueAsFloat('UnitPriceWithoutVAT',mcena);
                                                      mBO_new.SetFieldValueAsString('VATRate_ID','02100X0000');
                                                      mBO_new.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                      mBO_new.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                              end;



                                              finally
                                                  mbo_zavada.free;
                                              end;











        //                         if index=0 then mbo.SetFieldValueAsstring('X_Objednani',mtext);
                                mbo.Save;
        //                        TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.Refresh;
                    end else begin
                       for j := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(j));
                                mBO := TDynSiteForm(mSite).CurrentObject;
                                //if index=0 then mbo.SetFieldValueAsstring('X_Objednani',mtext);
                                mbo.Save;
        //                        TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.Refresh;
                        end;
                    end;
              end;
   finally
   end;
 TDynSiteForm(mSite).RefreshData;
end;



procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Import závady';
  mMAction.Hint := 'Import závady';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Import závady - souhrně');
  mMAction.Items.Add('Položkově - souhrně');



end;



begin
end.