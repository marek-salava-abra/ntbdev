{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
{procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
Var
mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  i: integer;
  mNewBO, mSourceBO:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mPocetZmen:integer;
  mHodnotyParam,mr:TStringList;
  mNewValue,mValue:string;
  mNovyZapis:string;
begin
if self.GetFieldValueAsBoolean('IsProduct') then begin
    mSourceBO:=SELF.ObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');
                               mSourceBO.load('5A61000101',nil);

                               mNewBO:=self.ObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');
                                      mr:=TStringList.create;
                                      try
                                            self.ObjectSpace.SQLSelect('Select id from PLMRoutines where Storecard_ID=' + quotedstr(self.oid),mr);
                                            if mr.count=0 then begin
                                                     mNewBO.New;
                                                     mNewBO.Prefill;
                                                     mNewBO:=mSourceBO.clone;
                                                     mNewBO.SetFieldValueAsString('Storecard_ID',self.oid);
                                                     mNewBO.SetFieldValueAsString('Name',self.GetFieldValueAsString('code'));
                                                     mNewBO.save;
                                                     //NxShowSimpleMessage('AAA',nil);
                                            end;
                                      finally
                                          mr.free;
                                      end;
End;


end; }

begin
end.