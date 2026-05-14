uses 'eu.simon.eshop.mail';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mFileName, mBody:String;
 mList:TStringList;
begin
 if false then begin
 // if osNew in self.state then begin
     if self.GetFieldValueAsString('DocQueue_ID')='2920000101X' then begin
        mList:=TStringList.Create;
        mlist.add(self.OID);
        mBody:='<html><head><meta http-equiv=Content-Type content="text/html; charset=windows-1250"><style>'+
        '<!--'+
        ' /* Font Definitions */'+
        ' @font-face'+
        '{font-family:"Cambria Math";'+
        'panose-1:2 4 5 3 5 4 6 3 2 4;}'+
        '@font-face'+
        '	{font-family:Calibri;'+
        'panose-1:2 15 5 2 2 2 4 3 2 4;}'+
        '/* Style Definitions */'+
        'p.MsoNormal, li.MsoNormal, div.MsoNormal'+
        '{margin:0cm;'+
        'margin-bottom:.0001pt;'+
        'font-size:12.0pt;'+
        'font-family:"Times New Roman","serif";}'+
        '.MsoPapDefault'+
        '	{margin-bottom:8.0pt;'+
        '	line-height:107%;}'+
        '@page WordSection1'+
        '{size:595.3pt 841.9pt;'+
        '	margin:70.85pt 70.85pt 70.85pt 70.85pt;}'+
        'div.WordSection1'+
        '	{page:WordSection1;}'+
        '-->'+
        '</style>'+
        '</head>'+
        '<body lang=CS>'+
        '<div class=WordSection1>'+
        '<p class=MsoNormal>Vážený zákazníku,<br>v příloze Vám zasíláme zálohovou fakturu na Vámi objednané zboží. Prosíme o '+
        'následnou úhradu na níže uvedený bankovní účet. Po přijetí platby na náš účet Vám bude zboží obratem expedováno. O předání zboží dopravci Vás budeme '+
        'informovat.<br><br>'+
        'Účet.: 3639619369/0800<br><br>'+
        'Variabilní symbol: '+self.GetFieldValueAsString('VarSymbol')+' <br>'+
        '<br>'+
        'Celková částka: '+NxFormatNumeric('0.00',self.GetFieldValueAsFloat('Amount'))+'<br>'+
        '<br>Děkujeme Vám za Váš nákup na našem internetovém obchodě Nářadí SIMON a věříme,že se k nám brzy vrátíte.<br>'+
        '<br><a name="_GoBack"></a>S přátelským pozdravem,</p><p class=MsoNormal>Zákaznický servis Nářadí SIMON</p>'+
        '<p class=MsoNormal>&nbsp;</p>'+
        '<p class=MsoNormal>SIMON FM s.r.o.</p>'+
        '<p class=MsoNormal>Slezská 761</p>'+
        '<p class=MsoNormal>Frýdek - Místek 738 01</p>'+
        '<p class=MsoNormal>tel.: 558 441 342</p>'+
        '<p class=MsoNormal>e-mail: e-shop@simonfm.cz</p>'+
        '<p class=MsoNormal>&nbsp;</p>'+
        '<p class=MsoNormal>Tento e-mail je generován automaticky, prosíme, neodpovídejte na něj.</p>'+
        '<p class=MsoNormal>&nbsp;</p>'+
        '</div>'+
        '</body></html>';







        mFileName:=NxSearchReplace(self.DisplayName,'/','-',[srAll])+'.pdf';
        CFxReportManager.PrintByIDs(NxCreateContext_1(self),mList,'S4STXJVRM3DL35J301C0CX3F40','3O70000101',rtoFile,pekPDF,NxGetTempDir,mFileName);
        SendInternalMail2(self.ObjectSpace,self.GetFieldValueAsString('ReceivedOrder_ID.X_AES_Email'),
        self.GetFieldValueAsString('Firm_id.U_bustransaction_ID.U_emailOP'),'', 'Zálohový list '+self.DisplayName,
        mBody,NxGetTempDir+mFileName, self.GetFieldValueAsString('Firm_ID'),
                   '1400000101','1000000101',self.GetFieldValueAsString('ReceivedOrder_ID'));
        DeleteFile(NxGetTempDir+mFileName);
       end;
     end;
end;

begin
end.