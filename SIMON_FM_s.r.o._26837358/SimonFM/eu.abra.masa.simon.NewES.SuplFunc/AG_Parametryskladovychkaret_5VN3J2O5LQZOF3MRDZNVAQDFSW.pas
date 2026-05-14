procedure _AfterNewRec_Hook(Self: TRollSiteForm);
var
 mCode:string;
begin
  mCode:=self.BaseObjectSpace.SQLSelectFirstAsString('Select max(code) from defrolldata where code like ''P___'' and clsid=''KCAWICC3H2O4DG0YEDMLO4X0PK'' ');
  TBusRollSiteForm(self).CurrentObject.SetFieldValueAsString('Code', 'P'+AnsiRightStr('000'+(IntToStr(StrToInt(AnsiRightStr(mCode,3))+1)),3));
  TBusRollSiteForm(Self).DataSet.RefreshCurrentItem;
end;

begin
end.
