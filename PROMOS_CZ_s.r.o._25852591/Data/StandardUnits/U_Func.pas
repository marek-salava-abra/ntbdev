//unita pro male nenarocne funkce
//!!! Nevkladat sem zadne unity

////////////////////////////////////////////////////////////////////////////////
//U rucne vyvolanych vyjimek - uprava hlasky
//U ostatnich vyjimek - pridani ExceptionClassName
function getExceptionMessage: string;
var
  p: integer;
begin
  result:= ExceptionMessage;

  //U rucne vyvolanych vyjimek
  // odstrani z hlasky informace o callstacku a radku kde doslo k chybe.
  if(ExceptionClassName in ['Exception', 'NxError'])then begin
    p:= pos('scripting callstack:', result);
    if(p>0)then
      result:= trim(copy(result, 1, p-1));

  end else begin
    result:= ExceptionClassName + nxcrlf + result;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.