procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;

  i: integer;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Hint := 'Tisk štítků';
  mMAction.Caption := 'Tisk štítků';
  mMAction.Items.Add('Tisk štítků');
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @PrintBarcode;
end;

Procedure PrintBarCode(sender:TComponent;index:integer);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i,j,x:integer;
 mPrintList:TStringList;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if NxMessageBox('Dotaz','Přejete si vytisknout štítky z dodacího listu '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
     for i:=0 to mRows.count-1 do begin
       if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
         mPrintList:=TStringList.create;
         mPrintList.add(mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'));
         j:=Trunc(mrows.BusinessObject[i].GetFieldValueAsFloat('Quantity'));
         //for x:=1 to j do begin
          CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,'EL11000101'),'EL11000101',rtoPrint,pekPDF,'Datamax_E-4205e', '',j);
         //end;
         mPrintList.free;
       end;
     end;
   end;
 end;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.