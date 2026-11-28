uses
  'eu.abra.mire.EkoKom.Report',
  'eu.abra.mire.EkoKom.Convert',
  'eu.abra.mire.EkoKom.Settings',
  'eu.abra.mire.EkoKom.Lib',
  'eu.abra.mire.EkoKom.uLicence';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin
  CreateAction(Self, 'Převod nastavení', 'Převést nastavení obalů ze starších verzí', @OnConvertSettings, ['Převod nastavení 2021', 'Převod nastavení']);
  CreateAction(Self, 'Vyplnit výkaz', 'Vyplnit výkaz za poslední čtvrtletí', @OnFill, ['']);
  InitSettings(Self.SiteContext.GetObjectSpace());
end;


{
  Převod nastavení
}
procedure OnConvertSettings(sender : TComponent; Index: integer);
var
  mSite : TSiteForm;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  if(Index = 0) then
    DataConversion(mSite, mSite.BaseObjectSpace)
  else
    ConvertSettings(mSite, mSite.BaseObjectSpace);
end;

{
  Vyplnění výkazu
}
procedure OnFill(sender : TComponent);
var
  mExcel: Variant;
  mOpenDialog: TOpenDialog;
  mExcelFileName: String;
  mSite : TSiteForm;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
  try
    mOpenDialog.Filter := 'Soubor výzkazu (*.xlsx;*.xls)|*.XLSX;*.XLS';
    mOpenDialog.Options := [ofFileMustExist];

    if mOpenDialog.Execute then
      mExcelFileName := mOpenDialog.FileName
    else
      Exit;

    NxShowSimpleMessage(
      'Proběhne vyplnění vybraného výkazu pro EKO-KOM. ' + #13#10 +
      'Tato operace může trvat několik minut.' + #13#10 + #13#10 +
      'Po dokončení bude výkaz uložen a následně otevřen ke kontrole.' + #13#10 + #13#10 +
      'Ujistěte se, že vybraný výkaz není otevřen v žádném programu a stikněte OK. '+ #13#10
      , mSite);

    try
      mExcel := CreateOleObject('Excel.Application');
    except
      NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
      exit;
    end;
    mExcel.WorkBooks.Open(mExcelFileName);

    try
      FillQReport(mSite, mSite.BaseObjectSpace, mExcel);
      mExcel.ActiveWorkbook.CheckCompatibility := False; // Vypnutí kontroly kompatability, která není vypnutá ve výkazu 2.51
      mExcel.ActiveWorkbook.Save;
    finally
      mExcel.Quit;
    end;

    ShellAPI.Execute('open', mExcelFileName, '', '');

    NxShowSimpleMessage('Vyplnění výkazu dokončeno.', mSite);

    mExcel := nil;
  finally
    mOpenDialog.Free;
  end;
end;

begin
end.


