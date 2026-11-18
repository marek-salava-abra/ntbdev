uses '_Knihovny_ALL.SQL';





// převod data v formátu YYYYMMDD na typ TDate
// ----------------------------------------------------------------------

function StringDateToDate(AISODate: string): TDate;
var
  mY, mM, mD: Integer;
begin
  mY := StrToInt(Copy(AISODate, 1, 4));
  mM := StrToInt(Copy(AISODate, 5, 2));
  mD := StrToInt(Copy(AISODate, 7, 2));
  Result := EncodeDate(mY, mM, mD);
end;




// převod data v ISO formátu YYYY-MM-DD na typ TDate
// ----------------------------------------------------------------------

function ISODateToDate(AISODate: string): TDate;
var
  mY, mM, mD: Integer;
begin
  mY := StrToInt(Copy(AISODate, 1, 4));
  mM := StrToInt(Copy(AISODate, 6, 2));
  mD := StrToInt(Copy(AISODate, 9, 2));
  Result := EncodeDate(mY, mM, mD);
end;


// převod data a času v ISO formátu YYYY-MM-DD HH:MM:SS na typ TDate
// ----------------------------------------------------------------------

function ISODateTimeToDateTime(AISODateTime: string): TDateTime;
var
  mY, mM, mD, mHH, mMM, mSS: Integer;
begin
  mY := StrToInt(Copy(AISODateTime, 1, 4));
  mM := StrToInt(Copy(AISODateTime, 6, 2));
  mD := StrToInt(Copy(AISODateTime, 9, 2));
  mHH := StrToInt(Copy(AISODateTime, 12, 2));
  mMM := StrToInt(Copy(AISODateTime, 15, 2));
  mSS := StrToInt(Copy(AISODateTime, 18, 2));
  Result := EncodeDateTime(mY, mM, mD, mHH, mMM, mSS, 0);
end;



// převod data v TDateTime do ISO formátu YYYY-MM-DDxHH:MM:DD kde x je libovolný znak
// ----------------------------------------------------------------------

function DateTimeToISODateTime(ADateTime: TDateTime; ATimeSeparator: string): string;
var
  mY, mM, mD, mH, mMi, mS, mMS: Integer;
begin
  DecodeDateTime(ADateTime, mY, mM, mD, mH, mMi, mS, mMS);
  Result := IntToStr(mY)+'-'+
            NxPadL(IntToStr(mM), 2, '0')+'-'+
            NxPadL(IntToStr(mD), 2, '0')+ATimeSeparator+
            NxPadL(IntToStr(mH), 2, '0')+':'+
            NxPadL(IntToStr(mMi), 2, '0')+':'+
            NxPadL(IntToStr(mS), 2, '0');
end;

// Získání časového razítka v podobě yyyy-mm-dd hh.mm.ss.ms
// nepovinný parametr - datum a čas, výchozí je aktuální
// ----------------------------------------------------------------------

function GetFilenameTimestamp(ADateTime: TDateTime = Now): string;
var
  mResult: string;
begin
  DateTimeToString(mResult, 'yyyy-mm-dd hh.nn.ss.zzz', ADateTime);
  Result := mResult;
end;

// Zjištění počtu měsíců, do kterých zasahuje počáteční a kncové datum
// ----------------------------------------------------------------------

function GetNumberOfMonths(ADateTimeFrom, ADateTimeTo: TDateTime;): integer;
var
  mMFrom, mMTo, mYFrom, mYTo: Integer;
begin
  mMFrom := MonthOf(ADateTimeFrom);
  mMTo := MonthOf(ADateTimeTo);
  mYFrom := YearOf(ADateTimeFrom);
  mYTo := YearOf(ADateTimeTo);
  mMTo := mMTo + ((mYTo - mYFrom) * 12);
  Result := mMTo - mMFrom + 1;
end;

// Zjištění ID období podle data
// ----------------------------------------------------------------------

function GetPeriodIDByDate(OS: TNxCustomObjectSpace; ADate: TDateTime): string;
begin
  Result := SQLSelectValue(OS, 'SELECT ID FROM Periods WHERE DateFrom$DATE <= '+NxFloatToIBStr(ADate)+' AND DateTo$DATE > '+NxFloatToIBStr(ADate));
end;


// Zjištění počtu pracovních dnů mezi dvěma daty
// Mezi pracovní dny se nepočítají víkendy a svátky
//--------------------------------------------------------------------------------

function GetWorkingDays(AObj: TNxCustomBusinessObject; ADateFrom, ADateTo: TDateTime): integer;
var
  mDateFrom, mDateTo: integer;
begin
  mDateFrom := Floor(ADateFrom);
  mDateTo := Floor(ADateTo);
  Result := mDateTo - mDateFrom - NxEvalObjectExprAsIntegerDef(AObj, 'NxFreeTimeBetween('+IntToStr(mDateFrom)+', '+IntToStr(mDateTo)+')', 0);
end;

// Zjištění, zda je předané datum pracovním dnem, tj. není to víkend ani svátek
//--------------------------------------------------------------------------------

function IsWorkingDay(AObj: TNxCustomBusinessObject; ADate: TDateTime): boolean;
begin
  Result := (NxEvalObjectExprAsIntegerDef(AObj, 'NxFreeTimeBetween('+IntToStr(Floor(ADate))+', '+IntToStr(Floor(ADate))+')', 0) = 0);
end;


begin
end.