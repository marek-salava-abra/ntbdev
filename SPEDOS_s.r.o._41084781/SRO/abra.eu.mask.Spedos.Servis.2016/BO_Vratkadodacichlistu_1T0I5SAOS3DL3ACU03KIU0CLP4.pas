{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
    mQuantity:double;
begin
             mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
            for i := 0 to mMon.Count-1 do begin
                  mQuantity:=0;
                  try

                      mRow := mMon.BusinessObject[i];
                      if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                           mr:=TStringList.create;   // VRDL
                               try
                                  self.ObjectSpace.SQLSelect('Select sum(SD2.Quantity) from storedocuments2 SD2 left join storedocuments SD on sd.id=sd2.parent_ID where sd.DocumentType=' + quotedstr('23') + ' and SD2.X_parent_ID='+quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                  if NxIBStrToFloat(mr.Strings[0])>0 then begin
                                     mQuantity:=mQuantity+strtofloat(mr.Strings[0]);
                                  end;
                               finally
                                  mr.free;
                               end;

                           mr:=TStringList.create;        // DL
                               try
                                  self.ObjectSpace.SQLSelect('Select sum(SD2.Quantity) from storedocuments2 SD2 left join storedocuments SD on sd.id=sd2.parent_ID where sd.DocumentType=' + quotedstr('21') + ' and SD2.X_parent_ID='+quotedstr(mrow.GetFieldValueAsString('X_parent_ID')),mr);
                                  if NxIBStrToFloat(mr.Strings[0])>0 then begin
                                     mQuantity:=mQuantity-strtofloat(mr.Strings[0]);
                                  end;
                               finally
                                  mr.free;
                               end;






                              mBO_target := self.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                              mBO_target.Load(mrow.GetFieldValueAsString('X_Parent_ID'),nil);
                                  mBO_target.SetFieldValueAsFLoat('QuantityDelivered', mQuantity);
                              mBO_target.save;
                          mBO_target.free;
                      end;
                  finally
                  end;


 end;

end;
 {
procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
begin
 if self.getFieldValueAsString('Docqueue_ID')='ME00000101' then begin ;
           mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
          for i := 0 to mMon.Count-1 do begin
                try
                    mRow := mMon.BusinessObject[i];
                    if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                            mBO_target := self.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                            mBO_target.Load(mrow.GetFieldValueAsString('X_Parent_ID'),nil);
                               mBO_target.SetFieldValueAsFLoat('QuantityDelivered', 0);
                            mBO_target.save;

                        mBO_target.free;
                    end;

                finally
                end;


          end;


     end;
end;

   }


begin
end.