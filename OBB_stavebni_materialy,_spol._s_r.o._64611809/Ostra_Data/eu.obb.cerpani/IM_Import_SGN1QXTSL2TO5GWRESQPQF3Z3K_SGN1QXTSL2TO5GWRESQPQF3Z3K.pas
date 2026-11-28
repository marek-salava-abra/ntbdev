{
Vyvolává se před spuštěním průvodce pro zadání základních hodnot.
}
procedure BeforeRunWizard_Hook(Self: TNxDocumentImportManager);
var
 mSQL:string;
 mList:TStringList;
begin
  mList:=TStringList.Create;
  mSQL:='SELECT ID FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=''%s''  '+
        'WHERE ((((Select Coalesce(CAST(SUM(Rel.NumValue) AS NUMERIC (15, 2)),0)    from Relations Rel '+
        'where Rel.Rel_def+0 in (1011, 1012, 1013, 1014, 1021, 2011, 2012, 2013, 2014, 2021) '+
        'and Rel.RightSide_ID = A.ID) + 100   >= ( '+
        '(SELECT SSD.LOCALAMOUNT  FROM SYS$STOREDOCUMENTS3 SSD  WHERE SSD.STOREDOCUMENT_ID = A.ID) ) '+
        'and (exists (select 1 from Relations Rel '+
        'where Rel.Rel_def+0 in (1011, 1012, 1013, 1014, 1021, 2011, 2012, 2013, 2014, 2021) '+
        'and Rel.RightSide_id = A.ID)) ) '+
        ')) and a.id=''%s'' ';
  self.InputHeaders[0].ObjectSpace.SQLSelect(Format(mSQL,[self.InputHeaders[0].OID,self.InputHeaders[0].OID]),mList);
  if mList.Count>0 then NxShowSimpleMessage('Pozor, příjemka je pravděpodobně čerpána.',nil);
end;

begin
end.