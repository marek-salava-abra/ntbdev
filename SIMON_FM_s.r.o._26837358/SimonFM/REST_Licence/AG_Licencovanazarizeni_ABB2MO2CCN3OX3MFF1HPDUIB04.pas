(*
* Formular na zpravu poctu licenci
*)

uses
  'REST_Licence.libSecurity',
  'REST_Licence.libConst';
     
procedure License(ASelf: TObject);
var
  mOS: TNxCustomObjectSpace;
  mForm: TBusRollSiteForm;
  mCurr: TNxCustomBusinessObject;
begin
  if not (ASelf is TComponent) then exit;
  mForm := TBusRollSiteForm(NxFindSiteForm(TComponent(ASelf)));
  if not Assigned(mForm) then exit;
  
  //mOS := mForm.BaseObjectSpace;
  //mCurr := mForm.CurrentObject;

  //if not NxIsEmptyOID(mCurr.OID) then begin
    NxShowSimpleMessage('Počet licencí: ' + IntToStr(GetLicenceCount(mOS)), mForm);
  //end;
end;

{
Vyvolává se při vytvoření instance objektu.
}
procedure _CanEdit_Hook(Self: TRollSiteForm; var ACanEdit: Boolean);
begin

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mAction1: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl  := True;
  mAction.ShowMenuItem := True;
  mAction.Category     := 'tabList';
  mAction.Caption      := 'Počet licencí';
  mAction.Name         := 'btnLicense';
  mAction.OnExecute    := @License;
end;

begin
end.