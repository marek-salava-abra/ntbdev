uses 'RUPL_BARTON_001.Functions';

procedure Execute(Sender: TBasicAction);
var
   mList: TStringList;
   mLog: TStringList;
   i: Integer;
begin
   mLog:= TStringList.Create;
   mList:= TStringList.Create;
   try
      Sender.Site.List.GetSelectedId(mList);
      For i:= 0 to mList.Count - 1 do
      begin
         Create_DL_From_OP(Sender.Site.BaseObjectSpace,mLog,mList[i]);
      end;

      NxShowEditorSite(Sender.Site.SiteContext,mLog.Text,True);
   finally
      mList.Free;
      mLog.Free;
   end;
end;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
Var
   mAction: TMultiAction;
begin
   mAction := Self.GetNewMultiAction;
   mAction.ShowControl := True; //Zobraz jako tlačítko
   mAction.ShowMenuItem := True;
   mAction.Name := 'JIFR_Create_DLs';
   mAction.Caption := 'DL dle Exp. sk.';
   mAction.Items.Add('DL dle Exp. sk.');
   mAction.Hint := 'Vytvoří DL z označených OP';
   mAction.Category := 'tabList'; // kde se má tlačítko zobrazit
   mAction.OnExecuteItem := @Execute;  //OPocedura obsluhující tlačítko
   mAction.Enabled := True;
end;

begin
end.