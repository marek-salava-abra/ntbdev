 function correctquantity(self:TNxCustomBusinessObject):string;
 var
mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  i,ii:integer;
  mpocet,mpocetP,mpocetM:double;
  mr,mx:tstringlist;
  mi:integer;
begin
      if (self.GetFieldValueAsString('CreatedBy_ID')='3PH1000101') or (self.GetFieldValueAsString('CreatedBy_ID')='SUPER00000') then begin
            mMonInput := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                  for i := 0 to mMoninput.Count-1 do begin
                    mRow := mMonInput.BusinessObject[i];
                       if (mMonInput.BusinessObject[i].GetFieldValueAsstring('Storecard_ID.StoreCardCategory_ID')='8000000101') and
                           ((mMonInput.BusinessObject[i].GetFieldValueAsstring('Store_ID')='3000000101') or (mMonInput.BusinessObject[i].GetFieldValueAsstring('Store_ID')='51H1000101'))

                             then begin
                                  mpocet:=0;
                                  if mRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin






                                      mBO_MonikerInput:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                     for ii:=0 to mBO_MonikerInput.Count-1 do begin

                                                           if (UpperCase(COPY(mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID.NAme'),1,3))='MAT')
                                                               then begin
                                                                 mpocet:=0;
                                                                 mr:=tstringlist.create;
                                                                     try
                                                                     self.ObjectSpace.SQLSelect('SELECT sum(a.Quantity) FROM   DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID WHERE ' +
                                                                           ' (SD2.Store_ID = '+quotedstr(mMonInput.BusinessObject[i].GetFieldValueAsstring('Store_ID')) +' ) AND (A.StoreBatch_ID = ' + quotedstr(mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID')) + ' ) ' +
                                                                        ' AND (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (' + quotedstr('20') + ','+ quotedstr('23') + ','+ quotedstr('24') + ','+ quotedstr('xx') + ',' + quotedstr('28') + ','+ quotedstr('29') + ','+ quotedstr('39')  + ')))' +
                                                                        ,mr);
                                                                        mpocetp:= NxIBStrToFloat(mr.Strings[0]);
                                                                        self.ObjectSpace.SQLSelect(' SELECT sum(a.Quantity) FROM   DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID WHERE ' +
                                                                           ' (SD2.Store_ID = '+quotedstr(mMonInput.BusinessObject[i].GetFieldValueAsstring('Store_ID')) +' ) AND (A.StoreBatch_ID = ' + quotedstr(mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID')) + ' ) ' +
                                                                        ' AND ((SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (' + quotedstr('21') + ','+ quotedstr('22') + ','+ quotedstr('26') + ','+ quotedstr('27') + ',' + quotedstr('30') + ','+ quotedstr('36') + ','+ quotedstr('38') +   '))))'
                                                                       ,mr);



                                                                            mpocetm:=NxIBStrToFloat(mr.Strings[0]) ;
                                                                            mpocet:=mpocetp- mpocetm;
                                                                            mx:=tstringlist.create;
                                                                            try
                                                                                  self.ObjectSpace.SQLSelect('SELECT a.id FROM STORESUBBATCHES A WHERE (A.StoreBatch_ID = ' + quotedstr(mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID')) +' ) AND (A.Store_ID = '+ quotedstr(mMonInput.BusinessObject[i].GetFieldValueAsstring('Store_ID'))  + ')',mx);
                                                                                  if mx.count>0 then begin
                                                                                      //if NxIBStrToFloat(mx.Strings[0])<> mpocet then begin
                                                                                          mi:=self.ObjectSpace.SQLExecute('Update STORESUBBATCHES set quantity=' + NxFloatToIBStr(mpocet) + ' where id=' + quotedstr(copy(mx.Strings[0],1,10)));
                                                                                      //end;
                                                                                  end;
                                                                            finally
                                                                                mx.free;
                                                                            end;
                                                                           // NxShowSimpleMessage(NxFloatToIBStr(mpocetp) + ' - ' +NxFloatToIBStr(mpocetm),nil);
                                                                      finally
                                                                            mr.free;
                                                                      end;

                                                           end;
                                                     end;
                                  end;


                       end;
      end;
  end;


 end;


procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mstring:string;
begin
   if osNew in self.state then begin
      if (self.GetFieldValueAsString('CreatedBy_ID')='3PH1000101') or (self.GetFieldValueAsString('CreatedBy_ID')='SUPER00000') then begin
            mstring:=  correctquantity(self)          ;
      end;
   end;
end;











procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
mMonInput,mMonOutput,mBO_MonikerInput,mBO_MonikerOutput: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mdocrowbatches: TNxCustomBusinessObject;
  i,ii:integer;
  mpocet:double;
  mr:tstringlist;
begin
  if osNew in self.state then begin
      if (self.GetFieldValueAsString('CreatedBy_ID')='3PH1000101') or (self.GetFieldValueAsString('CreatedBy_ID')='SUPER00000') then begin
            mMonInput := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                  for i := 0 to mMoninput.Count-1 do begin
                    mRow := mMonInput.BusinessObject[i];
                       if (mMonInput.BusinessObject[i].GetFieldValueAsstring('Storecard_ID.StoreCardCategory_ID')='8000000101') and
                           ((mMonInput.BusinessObject[i].GetFieldValueAsstring('Store_ID')='3000000101') or (mMonInput.BusinessObject[i].GetFieldValueAsstring('Store_ID')='51H1000101'))

                             then begin
                                  mpocet:=0;
                                  if mRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
                                      mBO_MonikerInput:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                     for ii:=0 to mBO_MonikerInput.Count-1 do begin

                                                           if (UpperCase(COPY(mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID.NAme'),1,3))='MAT') and
                                                              (mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('Quantity')=1) and

                                                               then begin
                                                                   mr:=tstringlist.create;
                                                                   try
                                                                        self.ObjectSpace.SQLSelect('select sum(quantity) from StoreSubBatches where StoreBatch_ID=' + QuotedStr(mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsstring('StoreBatch_ID')) + ' and Store_ID='+ QuotedStr(mRow.GetFieldValueAsString('Store_ID')),mr);
                                                                      if mr.count>0 then begin
                                                                          mBO_MonikerInput.BusinessObject[ii].setFieldValueAsFloat('Quantity',(NxIBStrToFloat(mr.Strings[0]) ));
                                                                          mpocet:=mpocet + mBO_MonikerInput.BusinessObject[ii].GetFieldValueAsFloat('Quantity');
                                                                      end;
                                                                   finally
                                                                       mr.free;
                                                                   end;
                                                           end;
                                                     end;
                                  end;
                                  mrow.SetFieldValueAsFloat('Quantity', mpocet);
                                  mpocet:=0;
                                end;
                       end;
      end;
  end;

end;






begin
end.