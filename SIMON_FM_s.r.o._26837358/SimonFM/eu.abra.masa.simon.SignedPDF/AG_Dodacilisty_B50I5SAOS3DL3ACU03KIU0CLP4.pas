uses '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := '##Podepsané PDF##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @ShowPDF;
end;

Procedure ShowPDF(Sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mFileName,mPeriodCode,mCode, mOrdnumber:string;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mCode:=mBO.GetFieldValueAsString('DocQueue_ID.code');
   mOrdnumber:=IntToStr(mbo.GetFieldValueAsInteger('OrdNumber'));
   mPeriodCode:=mbo.GetFieldValueAsString('Period_ID.Code');
   mFileName:=mCode+'-'+mOrdnumber+'-'+mPeriodCode+'.pdf';
   if FileExists(cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+mFileName) then
    NxShellOpenFile(cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+mFileName);
 end;
end;

function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
end;

//barva řádku
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mGrid: TDBGrid;
begin
  mGrid := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdList'));
  if Assigned(mGrid) then begin
    mGrid.OnGetCellParams := @OnGetCellParams;
  end;
end;

procedure OnGetCellParams(Sender: TObject; Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
var
  mGrid: TDBGrid;
  mSite: TDynSiteForm;
  mBO: TNxCustomBusinessObject;
begin
  if Highlight then exit;
  mGrid := TDBGrid(Sender);
  mSite := TDynSiteForm(mGrid.Owner);
  mbo:=TDynSiteForm(msite).CurrentObject;
  if Assigned(mBO) then begin
    if mbo.GetFieldValueAsBoolean('U_PDFSigned')  then Background:= RGBToColor(51, 255, 212);
  end;
end;



begin
end.