uses 'eu.abra.roeh.SunnexSklOpt.Requests';

procedure actRequestsClickSunnex(Self: TBasicAction);
begin
    CreateRequestsSannex(TSiteForm(Self.Owner));
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mActLis : TActionList;
  N : Integer;
  Korekce : Boolean;
  mAct: TBasicAction;
begin
  Korekce := false;
  mActLis := Self.GetMainActionList;
  for N := 0 to  mActLis.ActionCount-1 do
    if mActLis.Actions[N].Name = 'actImportRequests' then begin
{      mActLis.Actions[N].OnExecute := @actRequestsClickSunnex;}
      mActLis.Actions[N].Free;
      Korekce := true;
      Break;
    end;
  if not Korekce then begin
    ShowMessage('Musí být určeno pořadí skriptů a před touto knohovnou musí být načten skript eu.abra.roeh.Logio!');
   RaiseException('Musí být určeno pořadí skriptů a před touto knohovnou musí být načten skript eu.abra.roeh.Logio!');
   end;

  mAct:= Self.GetNewAction;
  mAct.Name:= 'actImpReqSannex';
  mAct.Caption:= 'Gen. požad.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actRequestsClickSunnex;
end;

begin
end.