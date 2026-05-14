procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
Var
  mOS:TNxCustomObjectSpace;
  mBO, mBatchMovementBO:TNxCustomBusinessObject;
  mRows,mDRowBatches:TNxCustomBusinessMonikerCollection;
  mReceivedCard_ID, mBatchName, mBatches,mSKBatchName, mIORow_ID, mComponentCard_ID, mProductCard_ID:string;
  i,j,k, m:integer;
  mBatchQuantity:Extended;
  mBatchMovement_ID_List:TStringList;
  mBatchMovement_ID:string;
  mMessage:string;
  mLog:TNxCustomBusinessObject;
begin
 if self.GetFieldValueAsBoolean('X_ZAPI') and (osnew in self.State) then begin
 // if NxGetActualUserID_1(self)='~000000703' then begin
    mOS:=Self.ObjectSpace;
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    mMessage:='';
    for i := 0 to mRows.count -1 do begin
      mBO:=mRows.BusinessObject[i];
      mComponentCard_ID:=mBO.GetFieldValueAsString('StoreCard_ID');
      if not (NxIsEmptyOID(mComponentCard_ID)) then begin
        mProductCard_ID:= mOS.SQLSelectFirstAsString(
          ' SELECT PL.StoreCard_ID FROM PLMPieceLists PL '+
          ' JOIN PLMPieceLists2 PL2 ON PL.ID = PL2.Parent_ID '+
          ' WHERE PL2.StoreCard_ID = '+QuotedStr(mComponentCard_ID));

        mDRowBatches:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('DocRowBatches'));

        if not (NxIsEmptyOID(mProductCard_ID)) then begin
          for k:= 0 to mDRowBatches.Count -1 do begin
            mSKBatchName:= mDRowBatches.BusinessObject[k].GetFieldValueAsString('StoreBatch_ID.Name');
            mBatchQuantity:= mDRowBatches.BusinessObject[k].GetFieldValueAsFloat('Quantity');
            mBatchMovement_ID:= mOS.SQLSelectFirstAsString(
              ' SELECT DRD.ID FROM IssuedOrders IO '+
              ' JOIN IssuedOrders2 IO2 ON IO2.Parent_ID = IO.ID '+
              ' JOIN DefRollData DRD ON DRD.X_Parent_ID = IO2.ID '+
              ' WHERE drd.x_SK_Batch='''' and IO.Closed = ''N'' '+
              ' AND (DRD.CLSID=''EC2R2HSFK5UOZ5MYVJWJOHUC4S'') '+
              ' AND ((IO2.Quantity - IO2.DeliveredQuantity) >= '+NxFloatToIBStr(mBatchQuantity)+')'+    //má být množství na příjemce
              ' AND (IO.DocDate$DATE >= 45566) '+                       //datum dočasně
              ' AND IO2.StoreCard_ID = '+QuotedStr(mProductCard_ID));
              {IO.Firm_ID = '+QuotedStr('IHFJ800101')+            //Firma fixně
              ' AND }
            {if not(NxIsEmptyOID(mBatchMovement_ID)) then begin
              mBatchMovementBO:= mOS.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S'); //POHYBY ŠARŽÍ NA OV
              try
                mBatchMovementBO.Load(mBatchMovement_ID, nil);
                mBatchMovementBO.SetFieldValueAsString('X_SK_Batch', mSKBatchName);
                OutputDebugString('Tu '+mBatchMovement_ID+' bych doplnil šarži ze SK do X_Ponožky: '+mSKBatchName);
                mBatchMovementBO.Save;
              finally
                mBatchMovementBO.Free;
              end;
            end else begin
              mMessage:=mMessage+#13#10+'Nenalezená OV pro šarži '+mSKBatchName;
            end;  }
          end;
        end
        else begin
          mIORow_ID:=mBO.GetFieldValueAsString('ProvideRow_ID');
          mBatchMovement_ID_List:=TStringList.Create;
          try
            mOS.SQLSelect(
              ' select ID from defrolldata '+
              ' where X_Parent_ID='+QuotedStr(mIORow_ID)+
              ' and X_SK_Batch='+QuotedStr('')+
              ' and clsid='+QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S'),
              mBatchMovement_ID_List);

            for j := 0 to mDRowBatches.Count - 1 do begin
              mBatchName:=mOS.SQLSelectFirstAsString(
                ' SELECT Name from defrolldata '+
                ' where CLSID='+QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+
                ' AND X_Parent_ID='+QuotedStr(mIORow_ID),'');

              mBatchQuantity:=mDRowBatches.BusinessObject[j].GetFieldValueAsFloat('Quantity');
              mBatches:=mDRowBatches.BusinessObject[j].GetFieldValueAsString('Storebatch_ID.name');
              mSKBatchName:=mDRowBatches.BusinessObject[j].GetFieldValueAsString('StoreBatch_ID.displayname');
              //NxShowSimpleMessage(mBatchName+'  '+mSKBatchName+'  '+mBatchMove_ID_List[j]+'  '+IntToStr(mBatchMove_ID_List.Count),nil);

              {for m := mBatchMovement_ID_List.Count - 1 downto 0 do
              begin
                mBatchMovementBO:=mOS.CreateObject(Class_Pohyby_sarzi_OV_SLARSB0H4CK4T32XPZTP33J3XS);
                try
                  mBatchMovementBO.Load(mBatchMovement_ID_List[m], nil);
                  //mBatchMovementBO.SetFieldValueAsString('Name',mBatchName);
                  mBatchMovementBO.SetFieldValueAsString('X_SK_Batch',mSKBatchName);
                  //mBatchMovementBO.SetFieldValueAsFloat('X_Quantity',mBatchQuantity);
                  mBatchMovementBO.Save;
                finally
                  mBatchMovementBO.Free;
                end;
                mBatchMovement_ID_List.Delete(m);
              end;  }
            end;
          finally
            mBatchMovement_ID_List.Free;
          end;
        end;
      end;
    end;
    if not(NxIsBlank(mMessage)) then begin
       mLog:=mOS.CreateObject(Class_PRFLog);
       mLog.new;
       mlog.prefill;
       mLog.SetFieldValueAsString('DocQueue_ID','~000000B02');
       mLog.SetFieldValueAsString('Code', 'BatchCZ2SK');
       mLog.SetFieldValueAsString('Note',mMessage);
       mLog.SetFieldValueAsDateTime('Created$DATE',Now);
       mlog.save;

    end;
  end;
end;

begin
end.