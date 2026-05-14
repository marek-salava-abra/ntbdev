//Vytvoreno 20.9.2011 - Kuba
//Unita pro otevyrani agend, cisleniku, vybery z ciselniku

/////////////////////////////////////////////////////////////
function ShowDynFormWithSelected_MultiSelect(ASiteForm: TSiteForm; FormID, aNameSelected: string;
  aSelected: TStringList; var aSelect: TStringList): boolean;
var
  mOLE     : Variant;
  mAgenda  : Variant;
  mSelected: Variant;
  mSelect  : Variant;
begin
  mOLE     := ASiteForm.GetAbraOLEApplication;
  mAgenda  := mOLE.GetAgenda(FormID);
  mSelect  := mOLE.CreateStrings;
  mSelected:= mOLE.CreateStrings;
  mSelected.CommaText:= aSelected.DelimitedText;
  result:= mAgenda.MultiSelectFromSelected(mSelected, aNameSelected, mSelect);
  if(result)then
    aSelect.DelimitedText:= mSelect.CommaText;
end;//ShowDynFormWithSelected_MultiSelect
/////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni agendy s vybranejma zaznamama (seznam ID)
procedure ShowDynFormWithSelected(ASiteForm: TSiteForm; FormID: string; aSelected: TStrings;
  aTitle: string; aSiteCaption: string = '');
var
  mParams: TNxParameters;
  mPar   : TNxParameter;
begin
  mParams := TNxParameters.Create;
  try
    mParams.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := aTitle;
    if(aSiteCaption <> '')then
      mParams.NewFromDataType(dtString, '_SiteCaption').AsString := aSiteCaption;
    mPar := mParams.NewFromDataType(dtList, '_DefaultSelection', pkUnknown);
    mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown);
    mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown);
    mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList
    mPar.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(ASelected);
    ASiteForm.ShowDynForm(FormID, mParams, nil, true, '');
  finally
    mParams.free;
  end;
end;//ShowFormWithSelected
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni agendy s vybranym omezenim - Multiselect
function ShowDynFormWithQueryDefinition_MultiSelect(ASiteForm: TSiteForm; FormID: string;
  aQueryDefinition: string; var aSelect: TStringList): boolean;
var
  mOLE   : Variant;
  mAgenda: Variant;
  mSelect: Variant;
begin
  mOLE    := ASiteForm.GetAbraOLEApplication;
  mAgenda := mOLE.GetAgenda(FormID);
  mSelect := mOLE.CreateStrings;
  result:= mAgenda.MultiSelect('QueryDefinition;'+aQueryDefinition, mSelect);
  if(result)then
    aSelect.DelimitedText:= mSelect.CommaText;
end;//ShowDynFormWithQueryDefinition_MultiSelect
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni agendy s vybranym omezenim - Select
function ShowDynFormWithQueryDefinition_Select(ASiteForm: TSiteForm; FormID: string;
  aQueryDefinition: string; var aSelect: string): boolean;
var
  mOLE   : Variant;
  mAgenda: Variant;
  mSelect: string;
begin
  mOLE    := ASiteForm.GetAbraOLEApplication;
  mAgenda := mOLE.GetAgenda(FormID);
  mSelect := '';
  mSelect := mAgenda.SingleSelect2('QueryDefinition;'+aQueryDefinition, aSelect);
  if(mSelect <> '')then begin
    aSelect:= mSelect;
    result:= true;
  end else
    result:= false;
end;//ShowDynFormWithQueryDefinition_MultiSelect
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni ciselniku pro vyber - OLE
// Allowed - omezeni - ID oddelene carkou
function getIDFromRoll(Roll_ID: string; var ID: string; Allowed: string = ''; Excluded: string = ''):boolean;
var
  App  : variant;
  mRoll: Variant;
begin
  App  := GetAbraOLEApplication;
  mRoll:= App.GetRoll(Roll_ID, 0);

  //omezeni zaznamu - povolene
  if(Allowed <> '')then
    mRoll.Params.Add('_Allowed='+Allowed);

  //omezeni zaznamu - zakazane
  if(Excluded <> '')then
    mRoll.Params.Add('_Excluded='+Excluded);

  ID:= mRoll.SelectDialog2(true, ID);
  result:= ID <> '';
end;//getIDFromRoll
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni ciselniku pro multivyber - OLE
// Allowed - omezeni - ID oddelene carkou
function getIDFromRollMulti(Roll_ID: string; var slID: TStringList; Allowed: string = ''; Excluded: string = ''):boolean;
var
  App  : variant;
  mRoll: Variant;
  s    : Variant;
  i    : integer;
begin
  App  := GetAbraOLEApplication;
  s    := App.CreateStrings;
  mRoll:= App.GetRoll(Roll_ID, 0);

  s.Text:= slID.text;

  //omezeni zaznamu - povolene
  if(Allowed <> '')then
    mRoll.Params.Add('_Allowed='+Allowed);

  //omezeni zaznamu - zakazane
  if(Excluded <> '')then
    mRoll.Params.Add('_Excluded='+Excluded);

  if(mRoll.MultiSelectDialog(true, s))then begin
    slID.Clear;
    result:= true;
    for i:= 0 to s.Count-1 do
      slID.Add(s.Strings(i));
  end else
    result:= false;
end;//getIDFromRollMulti
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//otevreni ciselniku s vybranym omezenim - MultiSelect
function getIDFromRollMulti_WithQueryDefinition(
  AParentForm: TSiteForm; AContext: TNxContext;
  Roll_ID: string; var aSelect: TStringList;
  aQueryDefinition: string
): boolean;
var
  mPars : TNxParameters;
  mTools_ID : string;
begin
  mPars := TNxParameters.Create;
  try
    mPars.GetOrCreateParam(dtBoolean, '_MultiChoice', pkInput).AsBoolean := true; //DoNotLocalize
    mPars.GetOrCreateParam(dtString, '_ID', pkInput).AsString := ''; //DoNotLocalize
    if NxShowRoll(AContext, Roll_ID, mPars, 0,'QueryDefinition;'+aQueryDefinition, AParentForm) then
    begin
      mTools_ID:= mPars.ParamAsString('_ID', '');
      aSelect.DelimitedText:= mTools_ID;
    end;
  finally
    mPars.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.