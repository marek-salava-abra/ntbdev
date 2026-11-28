

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mEETTurnover:TNxCustomBusinessObject;
 mMessage:string;

begin
   {if Self.GetFieldValueAsBoolean('EET') then begin
    if not(NxIsEmptyOID(self.GetFieldValueAsString('EETTurnover_ID'))) then begin
       mEETTurnover:=self.ObjectSpace.CreateObject(Class_EETTurnover);
       mEETTurnover.load(self.GetFieldValueAsString('EETTurnover_ID'),nil);
       if  TNxEETTurnover(mEETTurnover).Process(mMessage) then begin
                OutputDebugString('Zaevidováno');
              end
              else begin
                RaiseException(Format('Během evidence tržby nastala chyba (%s)', [mMessage]));
              end;
       //mEETTurnover.free;
    end;
   end; }
end;


begin
end.
