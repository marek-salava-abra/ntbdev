procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpXML';
  mAction.Caption := '##Import XML##';
  mAction.Hint := 'Naimportuje XML data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;
end;

Procedure ImportXML(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j, k, mCount, maxCount: Integer;
 mXML, EntryNode, currNode, mCurrElement: Variant;
 mCode, mName, mfileName, mStreet:string;
 mBO:TNxCustomBusinessObject;
begin
  j:=0;
  maxCount:=2000000;
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z XML';
  mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
  if mOpenDlg.Execute then begin
     mfileName:=mOpenDlg.FileName;
     mXML := CreateOleObject('Msxml2.DOMDocument.6.0');
     try
      mXML.async := false;
      mXML.load(mFileName);
      EntryNode := mXML.getElementsByTagName('PaymentCondition');
      mCount := min(maxCount,EntryNode.Length);
      WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
      for i := 0 to  mCount-1 do begin
        currNode := EntryNode.Item(i);
        mCode:= currNode.attributes.getNamedItem('code').Text;
        mName:= currNode.selectSingleNode('Description').text;
        //mStreet:=mCurrElement.selectSingleNode('AddressLine1').Text;
        mBO:=mOS.CreateObject(Class_PaymentType);
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsString('Code', AnsiLeftStr(mCode,100));
        mBO.SetFieldValueAsString('Name', AnsiLeftStr(mName,100));
        mBO.save;
        mBO.free;
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mCount));
        WaitWin.StepIt;
      end;
      WaitWin.Stop;
     except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
     end;
  end;
end;

begin
end.