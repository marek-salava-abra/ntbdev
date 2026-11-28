procedure InitSite_Hook(Self: TSiteForm);
Var
  o:TComponent;
  mTime:Integer;
begin
   o := Application.FindComponent('SiteDeskForm');
   mTime:=10;

   If Assigned(o) Then Begin
       Application.HintHidePause:=(1000*mTime);
      End;
end;



begin
end.