 uses  '_Knihovny_ALL.Progress',
       '_Knihovny_ALL.XML',
        'abra.eu.Hromadny_dobropisPR.Libs',
      '_Knihovny_ALL.Parse';



procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
Var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
 mtext:string;
 mpocet:double;
 mTMPBO:TNxCustomBusinessObject;
 mr:tstringlist;
 mstring:string;
  mStorecard_ID,mBatch_ID,mFirm_ID:string;
  mQuantity:double;
  mRSql:tstringlist;
  mfieldValue:tstringlist;
  mstringline:string;
  mvalue:TStringList;
begin
  {
 if Self.getFieldValueAsString('X_CreatedBy_ID') = '2PK0000101' then begin
     if Self.getFieldValueAsString('X_DE_NAZEV')='' then begin


                  mpocet:=self.getFieldValueAsFloat('X_Quantity') ;
                          if not nxisemptyoid(self.getFieldValueAsstring('X_batches')) then begin

                                     if mpocet>0 then begin
                                          mpocet:=FindStoreBatchFV(msite.BaseObjectSpace,self,mpocet,0);
                                     end;

                                  //   if mpocet>0 then begin
                                  //        mpocet:=FindStoreBatchDL(msite,mTMPBO,mpocet,index);
                                  //        if mShowDebug then NxShowSimpleMessage('po vratkách zvývá ' + NxFloatToIBStr(mpocet),nil);
                                  //   end;

                                     if mpocet>0 then begin
                                            if self.getfieldvalueasstring('X_Parent_ID')<>'' then begin
                                              //  novyzaznam(msite,mTMPBO,mpocet);
                                            end;
                                      end;

                                  self.save;
                  end;














     end;
 end;
     }
end;





begin
end.