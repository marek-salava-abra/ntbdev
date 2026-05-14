const
  //pokud chci vice volem, tak sectu konstanty a oddelim znakem "|"
  OpenDialog_MASK_AllFiles = 'Všechny soubory (*.*)|*.*';
  OpenDialog_MASK_Excel    = 'Soubory aplikace Excel (*.xls, *.xlsx)|*.xls; *.xlsx';
  OpenDialog_MASK_Word     = 'Soubory aplikace Word (*.doc, *.xdoc)|*.doc; *.xdoc';
  OpenDialog_MASK_Csv      = 'Soubory CSV (*.csv)|*.csv';
  OpenDialog_MASK_Txt      = 'Textové soubory (*.txt)|*.txt';
  OpenDialog_MASK_Xml      = 'XML soubory (*.xml)|*.xml';

////////////////////////////////////////////////////////////////////////////////
// Mask = 'Soubory aplikace Excel (*.xls, *.xlsx)|*.xls; *.xlsx|Všechny soubory (*.*)|*.*'
function OpenDialog(aParentForm: TForm; var OpenFile: string; Mask: string = 'Všechny soubory (*.*)|*.*'; aStartDir: string =''): boolean;
var
  od: TOpenDialog;
  mParentForm: TForm;
begin
  if(aParentForm is TSiteForm)then
    mParentForm:= TSiteForm(aParentForm).GetSiteAppForm
  else
    mParentForm:= aParentForm;

  od := TOpenDialog.Create(mParentForm);
  try
    od.Filter      := Mask;
    od.FilterIndex := 0;
    if aStartDir<>'' then
      od.InitialDir :=aStartDir;
    if od.Execute() then begin
      OpenFile:= od.FileName;
      result  := true;
    end else begin
      OpenFile:= '';
      result  := false;
    end;
  finally
    od.free;
  end;
end;//OpenDialog
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Mask = 'Soubory aplikace Excel (*.xls, *.xlsx)|*.xls; *.xlsx|Všechny soubory (*.*)|*.*'
function SaveDialog(aParentForm: TForm; var SaveFile: string; Mask: string = 'Všechny soubory (*.*)|*.*'; aStartDir: string =''; aPripona: string = ''): boolean;
var
  od: TSaveDialog;
  mParentForm: TForm;
begin
  if(aParentForm is TSiteForm)then
    mParentForm:= TSiteForm(aParentForm).GetSiteAppForm
  else
    mParentForm:= aParentForm;

  od := TSaveDialog.Create(mParentForm);
  try
    od.Filter      := Mask;
    od.FilterIndex := 0;
    if SaveFile<>'' then od.FileName:= SaveFile;
    if aStartDir<>'' then od.InitialDir :=aStartDir;
    if od.Execute() then begin
      SaveFile:= od.FileName;
      if(aPripona <> '')then begin
        if(pos(UpperCase('.'+aPripona), UpperCase(SaveFile)) <> Length(SaveFile) - Length(aPripona))then
          SaveFile:= SaveFile + '.' + aPripona;
      end;
      result  := true;
    end else begin
      SaveFile:= '';
      result  := false;
    end;
  finally
    od.free;
  end;
end;//OpenDialog
////////////////////////////////////////////////////////////////////////////////

begin
end.