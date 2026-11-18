{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBO:TNxCustomBusinessObject;
 mInvoice_ID, mTrack:string;
begin
  if not(nxisblank(self.GetFieldValueAsString('X_LP_Tracking_URL'))) then begin
    if not(NxIsEmptyOID(self.GetFieldValueAsString('X_LP_Source_ID'))) and
     (self.GetFieldValueAsString('X_LP_SourceCLSID')='050I5SAOS3DL3ACU03KIU0CLP4') then begin
       mInvoice_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select distinct(Parent_ID) from issuedinvoices2 where provide_id='+QuotedStr(self.GetFieldValueAsString('X_LP_Source_ID')),'');
       if not(NxIsEmptyOID(mInvoice_ID)) then begin
         mTrack:=self.ObjectSpace.SQLSelectFirstAsString('Select X_TrackingURL from issuedinvoices where id='+QuotedStr(mInvoice_ID),'');
         if not(mTrack=self.GetFieldValueAsString('X_LP_Tracking_URL')) then begin
           mBO:=self.ObjectSpace.CreateObject(Class_IssuedInvoice);
           mBO.Load(mInvoice_ID,nil);
           mBO.SetFieldValueAsString('X_TrackingURL',self.GetFieldValueAsString('X_LP_Tracking_URL'));
           mBo.Save;
           mbo.free;
         end;
       end;
    end;
  end;
end;

begin
end.