uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uLicence';

function CreateTempXMLFile(var AXMLFileName: String): Boolean;
begin
  Result := NxCreateTempFile(AXMLFileName);
  if Result then begin
    RenameFile(AXMLFileName, AXMLFileName + '.xml');
    AXMLFileName := AXMLFileName + '.xml';
  end;
end;

procedure CreateXMLFile(const AFileName: String; var AXML: Variant);
begin
  AXML := CreateOLEObject('Msxml2.DOMDocument');
  AXML.load(AFileName);
end;

function OpenXMLFile(var AXML: Variant): Boolean;
var
  mFileName: String;
begin
  if PromptForFileName(mFileName, 'Soubory XML|*.xml|Vsechny soubory|*.*', 'XML') then begin
    CreateXMLFile(mFileName, AXML);
    Result := True;
  end else
    Result := False;
end;

procedure NewFromXML(Sender: TControl);
var
  mSite: TSiteForm;
  mObjectSpace: TNxCustomObjectSpace;
  mContext: TNxContext;
  mBO: TNxCustomBusinessObject;
  mCLSID: String;
  i: Integer;
  s: string;
  //XML
  mXML: Variant;
  mXMLNode, mXMLNodeList: Variant;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mObjectSpace := mSite.BaseObjectSpace;
  mContext := mSite.SiteContext;
  if OpenXMLFile(mXML) then begin
    mXMLNodeList := mXML.selectNodes('//objects/object[@import="A"]');
    for i := 0 to mXMLNodeList.length - 1 do begin
      mContext.DropRoll(Roll_PDMServiceTypes, 0);
      mContext.DropRoll(Roll_PDMPostProviders, 0);
      mContext.DropRoll(Roll_PDMPriceLists, 0);
      mContext.DropRoll(Roll_PDMIssuedContentTypes, 0);
      mXMLNode := mXMLNodeList.item[i];
      if VarIsType(mXMLNode, varDispatch) then begin //varDispatch
        mCLSID := mXMLNode.attributes.getNamedItem('class').nodeValue;
        mBO := mObjectSpace.CreateObject(mCLSID);
        try
          mBO.New;
          mBO.Prefill;
          NxFillBOFromXML(mBO, mXMLNode, mContext, True);
          mBO.Save;
        finally
          mBO.Free;
        end;
      end;
    end;
    if mSite is TBusRollSiteForm then begin
      TBusRollSiteForm(mSite).Roll.Reload;
    end;
    if mSite is TDynSiteForm then begin
      TDynSiteForm(mSite).RefreshData;
    end;
  end;
end;

procedure ShowXML(Sender: TControl);
var
  mSite: TSiteForm;
  mBO: TNxCustomBusinessObject;
  mXML, mXMLRootNode, mXMLBONode: Variant;
  mXMLFileName, s: String;
  mStrs, mIDs: TStringList;
  i: Integer;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  if GetCurrentObject(mSite, mBO) then begin
    mXML := CreateOLEObject('Msxml2.DOMDocument');
    mXMLRootNode := mXML.createElement('objects');
    mXML.appendChild(mXMLRootNode);
    mBO := mBO.ObjectSpace.CreateObject(mBO.GetFieldValueAsString('ClassID'));
    try
      mIDs := TStringList.Create;
      try
        mSite.List.GetSelectedID(mIDs);
        for i := 0 to mIDs.Count - 1 do begin
          mBO.Load(mIDs.Strings[i], nil);
          NxAppendXMLNodeWithBO(mBO, mXMLRootNode, true, true);
        end;
        if CreateTempXMLFile(mXMLFileName) then begin
          mStrs := TStringList.Create;
          try
            mStrs.Text := '<?xml version="1.0" encoding="Windows-1250" ?>'#13+mXML.xml;
            mStrs.SaveToFile(mXMLFileName, TEncoding.ANSI);
          finally
            mStrs.Free;
          end;
          ShellAPI.OpenFile(mXMLFileName);
        end;
      finally
        mIDs.Free;
      end;
    finally
      mBO.Free;
    end;
  end;
end;

function GetCurrentObject(ASite: TSiteForm; var ACurrentObject: TNxCustomBusinessObject): Boolean;
begin
  Result := true;
  ACurrentObject := nil;
  if ASite is TBusRollSiteForm then
    ACurrentObject := TBusRollSiteForm(ASite).CurrentObject
  else
    if ASite is TDynSiteForm then
      ACurrentObject := TDynSiteForm(ASite).CurrentObject
    else
      Result := False;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure ExInitSiteImport_Hook(Self: TSiteForm; AShow: integer);
var
  mShowXML, mNewFromXML: Boolean;
begin
  mShowXML := (AShow in [cOnlyShowXML, cAllXML]);
  mNewFromXML := (AShow in [cOnlyCreateFromXML, cAllXML]);
  if mShowXML then
    AddAction(Self, true, true, 'ShowXML', 'Zobraz XML', '', 'tabList', @ShowXML);
  if mNewFromXML then
    AddAction(Self, true, true, 'NewFromXML', 'Načti XML', '', 'tabList', @NewFromXML);
end;

function AddAction(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; AName, ACaption, AHint, ACategory: String; AOnExecute: Pointer): TAction;
var
  mAction: TAction;
begin
  Result := nil;
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.Name := 'act'+NxSearchReplace(AName, ' ', '', [srAll]);
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecute := AOnExecute;
    end;
    Result := mAction;
  end;
end;

begin
end.