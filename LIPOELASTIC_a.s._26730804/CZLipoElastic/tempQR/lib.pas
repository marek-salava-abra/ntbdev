
{PDDocumentExists}

function PDDocumentExists(AReportHelper:TNxQRScriptHelper;mDocument_ID:String;mDocumentType:String):Boolean;
var
 mDocumentCount:integer;
 mSQL:string;
begin
  Result:=false;
  mSQL:='';
  case mDocumentType of
   '03': begin
          mSQL:='select count(distinct po.ID) ' +
                'from PDMIssuedDocs po ' +
                'join PDMPostProviders pp on pp.ID = po.PostProvider_ID ' +
                'where pp.X_PD_Driver = 7 and (' +
                'exists (select 1 from Relations r ' +
                'where r.Rel_Def = 1400 and r.LeftSide_ID = po.ID ' +
                'and r.RightSide_ID = ' + QuotedStr(mDocument_ID) + ') ' +
                'or exists (select 1 from Relations r ' +
                'join IssuedInvoices2 ii2 on ii2.Parent_ID = ' + QuotedStr(mDocument_ID) + ' ' +
                'join StoreDocuments2 sd2 on sd2.ID = ii2.ProvideRow_ID ' +
                'where r.Rel_Def = 1438 and r.LeftSide_ID = po.ID ' +
                'and r.RightSide_ID = sd2.Parent_ID))';
         end;
   '21': begin
          mSQL:='select count(distinct po.ID) ' +
                'from PDMIssuedDocs po ' +
                'join PDMPostProviders pp on pp.ID = po.PostProvider_ID ' +
                'where pp.X_PD_Driver = 7 and (' +
                'exists (select 1 from Relations r ' +
                'where r.Rel_Def = 1438 and r.LeftSide_ID = po.ID ' +
                'and r.RightSide_ID = ' + QuotedStr(mDocument_ID) + ') ' +
                'or exists (select 1 from Relations r ' +
                'join IssuedInvoices ii on ii.ID = r.RightSide_ID ' +
                'join IssuedInvoices2 ii2 on ii2.Parent_ID = ii.ID ' +
                'join StoreDocuments2 sd2 on sd2.ID = ii2.ProvideRow_ID ' +
                'where r.Rel_Def = 1400 and r.LeftSide_ID = po.ID ' +
                'and sd2.Parent_ID = ' + QuotedStr(mDocument_ID) + '))';
         end;
   'RO': begin
          mSQL:='select count(distinct po.ID) ' +
                'from PDMIssuedDocs po ' +
                'join PDMPostProviders pp on pp.ID = po.PostProvider_ID ' +
                'where pp.X_PD_Driver = 7 and (' +
                'exists (select 1 from Relations r ' +
                'join StoreDocuments sd on sd.ID = r.RightSide_ID ' +
                'join StoreDocuments2 sd2 on sd2.Parent_ID = sd.ID ' +
                'join ReceivedOrders2 ro2 on ro2.ID = sd2.ProvideRow_ID ' +
                'where r.Rel_Def = 1438 and r.LeftSide_ID = po.ID ' +
                'and sd.DocumentType = ''21'' ' +
                'and ro2.Parent_ID = ' + QuotedStr(mDocument_ID) + ') ' +
                'or exists (select 1 from Relations r ' +
                'join IssuedInvoices2 ii2 on ii2.Parent_ID = r.RightSide_ID ' +
                'join StoreDocuments2 sd2 on sd2.ID = ii2.ProvideRow_ID ' +
                'join StoreDocuments sd on sd.ID = sd2.Parent_ID ' +
                'join ReceivedOrders2 ro2 on ro2.ID = sd2.ProvideRow_ID ' +
                'where r.Rel_Def = 1400 and r.LeftSide_ID = po.ID ' +
                'and sd.DocumentType = ''21'' ' +
                'and ro2.Parent_ID = ' + QuotedStr(mDocument_ID) + '))';
         end;
  end;
  if mSQL<>'' then
  begin
    mDocumentCount:=AReportHelper.ObjectSpace.SQLSelectFirstAsInteger(mSQL,0);
    if mDocumentCount>0 then Result:=true;
  end;
end;

begin
end.
