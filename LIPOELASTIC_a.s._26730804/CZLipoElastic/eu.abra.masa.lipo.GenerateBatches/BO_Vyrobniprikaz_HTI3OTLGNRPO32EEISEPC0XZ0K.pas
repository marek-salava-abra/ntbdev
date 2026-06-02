
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mStorebatches, mOutputs:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOutputBO, mStoreBatchBO:TNxCustomBusinessObject;
 mDavka, mRestQuantity, mDiv, mMod:Extended;
 mCount:integer;
 mLastBatch:integer;
 mBody, mMax, mSpecification:string;
begin
  if (osNew in Self.State) then begin
      if  not(self.GetFieldValueAsString('DocQueue_ID.Code')='VYPK')  then self.SetFieldValueAsString('X_StoreAssortmentGroup_ID',self.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID'));
     mDavka:=self.GetFieldValueAsFloat('StoreCard_ID.X_davka_sici');
     if (mDavka>0) and (self.GetFieldValueAsInteger('StoreCard_ID.Category')=2) then begin
         mBody:='';
         mSpecification:='';
         if nxisblank(self.getFieldValueAsstring('Storecard_ID.StoreCardCategory_ID.X_PerefixBatch')) then
          mSpecification:=mSpecification+'' else mSpecification:=mSpecification+self.getFieldValueAsstring('Storecard_ID.StoreCardCategory_ID.X_PerefixBatch');
          mSpecification:=mSpecification+copy(self.getFieldValueAsstring('Storecard_ID.EAN'),8,5)+
                FormatDateTime('YY',self.GetFieldValueAsDateTime('DocDate$Date'))+
                FormatDateTime('MM',self.GetFieldValueAsDateTime('DocDate$Date'));
          mBody:='1'+     // POZOR ČÍSLO 2 znamená Slovensko, pro ČR je stringově 1
                FormatDateTime('YY',self.GetFieldValueAsDateTime('DocDate$Date'))+
                FormatDateTime('MM',self.GetFieldValueAsDateTime('DocDate$Date'))+
                FormatDateTime('DD',self.GetFieldValueAsDateTime('DocDate$Date'));
         //NxShowSimpleMessage(mBody,nil);
         mMax:=self.ObjectSpace.SQLSelectFirstAsString('Select max(name) from storebatches where name like '+QuotedStr(mBody+'_____'),'');
         if NxIsBlank(mMax) then mMax:=mBody+'00000';
         //NxShowSimpleMessage(mMax,nil);
         mOutputs:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('OutPuts'));
         for i:=0 to mOutputs.CountOfNotDeleted-1 do begin
            mOutputBO:=mOutputs.BusinessObject[i];
            mStoreBatches:=mOutputBO.GetLoadedCollectionMonikerForFieldCode(mOutputBO.GetFieldCode('PLMJobOrdersSN'));
            mRestQuantity:=self.GetFieldValueAsFloat('Quantity');
            mDiv:=self.GetFieldValueAsFloat('Quantity') div mDavka;
            mMod:=self.GetFieldValueAsFloat('Quantity') mod mDavka;
            if mMod>0 then mCount:=trunc(mDiv)+1 else mCount:=trunc(mDiv);
            for j:=1 to mCount do begin
              mStoreBatchBO:=mStorebatches.AddNewObject;
              mStoreBAtchBO.SetFieldValueAsBoolean('NewBatch',true);
              if AnsiLeftStr(mBody,3)='000' then mStoreBatchBO.SetFieldValueAsString('NewBatchName', '000'+IntToStr(StrToInt(mMax)+j)) else
              if AnsiLeftStr(mBody,2)='00' then mStoreBatchBO.SetFieldValueAsString('NewBatchName', '00'+IntToStr(StrToInt(mMax)+j)) else
              if AnsiLeftStr(mBody,1)='0' then mStoreBatchBO.SetFieldValueAsString('NewBatchName', '0'+IntToStr(StrToInt(mMax)+j)) else
               mStoreBatchBO.SetFieldValueAsString('NewBatchName', IntToStr(StrToInt(mMax)+j));
              mStoreBatchBO.SetFieldValueAsString('NewBatchSpecification',mSpecification);
              mStoreBatchBO.SetFieldValueAsDateTime('StoreBatch_ID.ProductionDate$DATE',Now);
              mStoreBatchBO.SetFieldValueAsString('StoreBatch_ID.X_Verze',self.GetFieldValueAsString('Storecard_ID.X_parent_ID.X_verze'));
              if mRestQuantity>=mDavka then
              mStoreBatchbo.SetFieldValueAsFloat('Quantity',mDavka) else
              mStoreBatchBO.SetFieldValueAsFloat('Quantity',mRestQuantity);
              mRestQuantity:=mRestQuantity-mDavka;
            end;
         end;
     end;
  end;
end;

begin
end.

begin
end.