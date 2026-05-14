{
Vyvolává se po uložení vlastních dat objektu do databáze.
 }
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
Const
mRadaPrijemek='1000000101';
mDelkaSN=8;
mStoreCardCategory='1100000101';
mStoreCardCategory2='2600000101';  // ID kategorie slevových kuponu
mStoreCardCategory3='3720000101';
mKarta500='2W82000101';
mKarta500sleva='3X82000101';
mNKarta500='1L6M100101';
mNKarta500sleva='2L6M100101';
mKartaZ500='8U9A000101';
mKartaZ500sleva='9U9A000101';
mKarta1000='3W82000101';
mKarta1000sleva='1X82000101';
mKarta2000='4W82000101';
mKarta2000sleva='5X82000101';
mKarta5000='5W82000101';
mKarta5000sleva='4X82000101';
mKarta10000='6W82000101';
mKarta10000sleva='2X82000101';
mKarta500V='G5PQ100101';
mKarta500Vsleva='K5PQ100101';
mKarta1000V='F5PQ100101';
mKarta1000Vsleva='J5PQ100101';

var
mCurrentRowBO, mCurrentDocRowBO, mSerNumber, mPrijemka: TNxCustomBusinessObject;

mhead2: TNxCustomHeaderBusinessObject;
mPrijemkaradek, mprijemkaSN: TNxCustomBusinessObject;
mrows, mprijemkarows, mprijemkarowsSN: TNxCustomBusinessMonikerCollection;
i,j: integer;
Store_id, BusOrder_id, BusTransaction_ID, Division_id, mHead_id: string;
mBatchName:String;
begin
   try

                mHead2 := TNxHeaderBusinessObject(self);
                if (not(mHead_id=mhead2.oid)) then begin
                mHead_id:=mhead2.oid;

                for i := 0 to (mhead2.GetLoadedCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).Count - 1) do begin

                        mCurrentRowBO := mhead2.GetLoadedCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).BusinessObject(i);
                        if mCurrentRowBO.GetFieldValueAsInteger('RowType')=3 then begin
                        if (mCurrentRowBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')=mStoreCardCategory) or
                            (mCurrentRowBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')=mStoreCardCategory2) or
                            (mCurrentRowBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')=mStoreCardCategory3)
                         then begin

                        store_id:= mCurrentRowBO.GetfieldValueAsString('Store_ID');
                        BusOrder_id:= mCurrentRowBO.GetFieldValueAsString('BusOrder_ID');
                        BusTransaction_ID:=mCurrentRowBo.GetFieldValueAsString('BusTransaction_ID');
                        Division_id:=mCurrentRowBO.GetFieldValueAsString('Division_ID');

                        mPrijemka:=mhead2.ObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
                        mPrijemka.New;
                        mPrijemka.Prefill;
                        mPrijemka.SetFieldValueAsString('Docqueue_id',mRadaPrijemek);
                        mprijemkarows:=mPrijemka.GetCollectionMonikerForFieldCode(mprijemka.GetFieldCode('rows'));
                        for j :=0 to (mCurrentRowBO.GetLoadedCollectionMonikerForFieldCode(mCurrentRowBO.GetFieldCode('DocRowBatches')).CountOfNotDeleted-1) do begin
                           mCurrentDocRowBO := mCurrentRowBO.GetLoadedCollectionMonikerForFieldCode(mCurrentRowBO.GetFieldCode('DocRowBatches')).BusinessObject(j);
                                mBatchName:=mCurrentDocRowBO.GetMonikerForFieldCode(mCurrentDocRowBO.GetFieldCode('StoreBatch_ID')).BusinessObject.GetFieldValueAsString('NAme');
                               if not(AnsiRightStr(mBatchName,1)='#') then begin
                                mSerNumber:=mCurrentDocRowBO.ObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                mSerNumber.Load(mCurrentDocRowBO.GetFieldValueAsString('Storebatch_id'),nil);
                                mSerNumber.SetFieldValueAsString('Name',mSerNumber.GetFieldValueAsString('Name')+'#');
                                mSerNumber.save;
                               mPrijemkaradek:=mprijemkarows.AddNewObject;
                               mprijemkaradek.Prefill;
                               mprijemkaradek.setfieldvalueasstring('Store_ID',store_id);
                               // zde doplnit tolikrat radek, kolik je slevových kuponů, ID skladových karet doplnit nahoru do sekce CONST
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta500 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta500sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta500V then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta500Vsleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mNKarta500 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mNKarta500sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKartaZ500 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKartaZ500sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta1000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta1000sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta1000V then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta1000Vsleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta2000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta2000sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta5000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta5000sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta10000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta10000sleva);
                                // konec porovnavani IDcek skladových karet
                               mprijemkaradek.SetFieldValueAsFloat('Quantity',1);
                               mprijemkaradek.setfieldvalueasstring('Division_ID',Division_id);
                               mprijemkaradek.setfieldvalueasstring('BusOrder_ID',BusOrder_id);
                               mprijemkaradek.setfieldvalueasstring('BusTransaction_ID',BusTransaction_ID);
                               mprijemkarowsSN:=mPrijemkaradek.GetCollectionMonikerForFieldCode(mPrijemkaradek.GetFieldCode('DocRowBatches'));
                               mprijemkaSN:=mprijemkarowsSN.AddNewObject;
                               mprijemkaSN.Prefill;
                               mprijemkasn.SetFieldValueAsBoolean('NewBatch',true);
                               mprijemkaSN.SetFieldValueAsString('NewBatchName',mBatchName);
                               mprijemkaSN.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',date+365);
                               mprijemkaradek.SetFieldValueAsBoolean('CompletePrices',true);
                              // NxShowSimpleMessage(mCurrentDocRowBO.GetMonikerForFieldCode(mCurrentDocRowBO.GetFieldCode('StoreBatch_ID')).BusinessObject.GetFieldValueAsString('NAme'),nil);

                              end;
                          end;
                          if mprijemkarows.Count>0 then begin
                          mprijemka.save;
                          end;
                          mprijemka.Free;
                        end;

                    end;
                        //showmessage(mCurrentRowBO.GetFieldValueAsString('id'));
                  end;
               end;
        finally

        end;

end;
{
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
Const
mRadaPrijemek='1000000101';
mDelkaSN=8;
mStoreCardCategory='1100000101';
mStoreCardCategory2='1100000101'; // ID kategorie slevových kuponu
mKarta500='2W82000101';
mKarta500sleva='3X82000101';
mKartaZ500='8U9A000101';
mKartaZ500sleva='9U9A000101';
mKarta1000='3W82000101';
mKarta1000sleva='1X82000101';
mKarta2000='4W82000101';
mKarta2000sleva='5X82000101';
mKarta5000='5W82000101';
mKarta5000sleva='4X82000101';
mKarta10000='6W82000101';
mKarta10000sleva='2X82000101';


var
mCurrentRowBO, mCurrentDocRowBO, mSerNumber, mPrijemka: TNxCustomBusinessObject;

mhead2: TNxCustomHeaderBusinessObject;
mPrijemkaradek, mprijemkaSN: TNxCustomBusinessObject;
mrows, mprijemkarows, mprijemkarowsSN: TNxCustomBusinessMonikerCollection;
i,j: integer;
Store_id, BusOrder_id, BusTransaction_ID, Division_id, mHead_id: string;
mBatchName:String;
begin
   try
       mHead_id:='';
                mHead2 := TNxHeaderBusinessObject(self);
                if (not(mHead_id=mhead2.oid)) then begin
                mHead_id:=mhead2.oid;

                for i := 0 to (mhead2.GetLoadedCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).Count - 1) do begin
                        mCurrentRowBO := mhead2.GetLoadedCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).BusinessObject(i);
                        if mCurrentRowBO.GetFieldValueAsInteger('RowType')=3 then begin
                        if (mCurrentRowBO.GetMonikerForFieldCode(mCurrentRowBO.GetFieldCode('StoreCard_ID')).BusinessObject.GetFieldValueAsString('StoreCardCategory_ID')=mStoreCardCategory) or
                         (mCurrentRowBO.GetMonikerForFieldCode(mCurrentRowBO.GetFieldCode('StoreCard_ID')).BusinessObject.GetFieldValueAsString('StoreCardCategory_ID')=mStoreCardCategory2) then begin
                        store_id:= mCurrentRowBO.GetfieldValueAsString('Store_ID');
                        BusOrder_id:= mCurrentRowBO.GetFieldValueAsString('BusOrder_ID');
                        BusTransaction_ID:=mCurrentRowBo.GetFieldValueAsString('BusTransaction_ID');
                        Division_id:=mCurrentRowBO.GetFieldValueAsString('Division_ID');

                        
                        mPrijemka:=mhead2.ObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
                        mPrijemka.New;
                        mPrijemka.Prefill;
                        mPrijemka.SetFieldValueAsString('Docqueue_id',mRadaPrijemek);
                        mprijemkarows:=mPrijemka.GetCollectionMonikerForFieldCode(mprijemka.GetFieldCode('rows'));
                        for j :=0 to (mCurrentRowBO.GetLoadedCollectionMonikerForFieldCode(mCurrentRowBO.GetFieldCode('DocRowBatches')).CountOfNotDeleted-1) do begin
                           mCurrentDocRowBO := mCurrentRowBO.GetLoadedCollectionMonikerForFieldCode(mCurrentRowBO.GetFieldCode('DocRowBatches')).BusinessObject(j);
                               if((Length(mCurrentDocRowBO.GetMonikerForFieldCode(mCurrentDocRowBO.GetFieldCode('StoreBatch_ID')).BusinessObject.GetFieldValueAsString('Name'))=mDelkaSN) and not
                               (NxRight(mCurrentDocRowBO.GetMonikerForFieldCode(mCurrentDocRowBO.GetFieldCode('StoreBatch_ID')).BusinessObject.GetFieldValueAsString('Name'),1)='X')) then begin
                                mBatchName:=mCurrentDocRowBO.GetMonikerForFieldCode(mCurrentDocRowBO.GetFieldCode('StoreBatch_ID')).BusinessObject.GetFieldValueAsString('NAme');
                                mSerNumber:=mCurrentDocRowBO.ObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                mSerNumber.Load(mCurrentDocRowBO.GetFieldValueAsString('Storebatch_id'),nil);
                                mSerNumber.SetFieldValueAsString('Name',mSerNumber.GetFieldValueAsString('Name')+'X');
                                mSerNumber.save;
                                //mSerNumber.Refresh;
                                mSerNumber.Free;
                               mPrijemkaradek:=mprijemkarows.AddNewObject;
                               mprijemkaradek.Prefill;
                               mprijemkaradek.setfieldvalueasstring('Store_ID',store_id);
                               // zde doplnit tolikrat radek, kolik je slevových kuponů, ID skladových karet doplnit nahoru do sekce CONST
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta500 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta500sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKartaZ500 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKartaZ500sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta1000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta1000sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta2000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta2000sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta5000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta5000sleva);
                               if mCurrentRowBO.GetFieldValueAsString('StoreCard_ID')= mKarta10000 then mprijemkaradek.setfieldvalueasstring('StoreCard_ID',mKarta10000sleva);
                                // konec porovnavani IDcek skladových karet
                               mprijemkaradek.SetFieldValueAsFloat('Quantity',1);
                               mprijemkaradek.setfieldvalueasstring('Division_ID',Division_id);
                               mprijemkaradek.setfieldvalueasstring('BusOrder_ID',BusOrder_id);
                               mprijemkaradek.setfieldvalueasstring('BusTransaction_ID',BusTransaction_ID);
                               mprijemkarowsSN:=mPrijemkaradek.GetCollectionMonikerForFieldCode(mPrijemkaradek.GetFieldCode('DocRowBatches'));
                               mprijemkaSN:=mprijemkarowsSN.AddNewObject;
                               mprijemkaSN.Prefill;
                               mprijemkasn.SetFieldValueAsBoolean('NewBatch',true);
                               mprijemkaSN.SetFieldValueAsString('NewBatchName',mBatchName);
                               mprijemkaSN.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',date+180);
                               mprijemkaradek.SetFieldValueAsBoolean('CompletePrices',true);
                               //showmessage(mCurrentDocRowBO.GetMonikerForFieldCode(mCurrentDocRowBO.GetFieldCode('StoreBatch_ID')).BusinessObject.GetFieldValueAsString('NAme'));

                               end
                          end;
                          if mprijemkarows.Count>0 then begin
                          mprijemka.save;
                          end;
                          mprijemka.Free;
                        end;

                    end;
                        //showmessage(mCurrentRowBO.GetFieldValueAsString('id'));
                  end;
               end;
        finally

        end;

end;                                  }

begin
end.