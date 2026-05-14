{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mBO_target,mBO_target1: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
  mr:TStringList;
    mfind:boolean ;
    mstring, mString_pomoc,mString_pomoc1:string;
begin
           if self.GetFieldValueAsString('OfferState_ID')<>'5000000101' then begin
                   mstring:='';
                     mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
                    for i := 0 to mMon.Count-1 do begin
                          try

                              mRow := mMon.BusinessObject[i];
                              if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin


                                      try
                                      mr:= tstringlist.create;
                                        try
                                           self.ObjectSpace.SQLSelect('select parent_ID from ServiceAssemblyForms2 where id=' + quotedstr(mrow.GetFieldValueAsString('X_Parent_ID') ),mr);
                                           if mr.count>0 then begin
                                             mBO_target := self.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');   // ml
                                             try
                                             mBO_target.Load(mr.Strings[0],nil);
                                                if StrToInt(mBO_target.getFieldValueAsstring('X_State.code'))<=12 then begin

                                                              mString_pomoc:='9000000101';
                                                              if mstring<>mr.Strings[0] then begin
                                                                  mBO_target.SetFieldValueAsFLoat('AssemblyState', 2);
                                                                  mBO_target.SetFieldValueAsstring('X_State', '4XQ1000101');
                                                                  mstring:=mr.Strings[0];
                                                                  mString_pomoc1:=mBO_target.getFieldValueAsstring('ServiceDocument_ID');
                                                                  mBO_target.save;
                                                                end;

                                                          mBO_target1 := self.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');   // sl
                                                             try
                                                             mBO_target1.Load(mString_pomoc1,nil);

                                                                    mBO_target1.SetFieldValueAsstring('ServiceDocState_ID','9000000101');
                                                                    mBO_target1.Save;
                                                             finally
                                                                mBO_target1.free;
                                                             end;
                                               end;
                                               finally
                                                   mBO_target.free;
                                               end;

                                           end;
                                        finally
                                           mr.free;
                                        end;



                                      finally
                                          mBO_target.free;
                                       end;
                              end;
                          finally
                          end;


                    end;
          end;

end;

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
      if false then begin
           mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
          for i := 0 to mMon.Count-1 do begin
                try
                    mRow := mMon.BusinessObject[i];
                    if not nxisemptyoid(mrow.GetFieldValueAsString('X_Parent_ID')) then begin
                            mBO_target := self.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
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




begin
end.