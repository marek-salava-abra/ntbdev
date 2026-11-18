
{GetParamValue}


{GetOVMP}

function GetOVMP(AReportHelper:TNxQRScriptHelper;Doc_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(Doc_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedOrder);
    mBO.load(Doc_ID,nil);
    Result:=mbo.DisplayName;
    mbo.free;
  end;
end;

function GetParamValue(AReportHelper:TNxQRScriptHelper; AStoreCard_ID, AParamCode: string; var AField: string=''):String;
var
  mType: Integer;
  mBoolStr, mSQLSegment: string;
begin
  mType:= AReportHelper.ObjectSpace.SQLSelectFirstAsInteger(
    ' SELECT X_TypeOfValue FROM DefRollData '+
    ' WHERE CLSID ='+QuotedStr(Class_BOSCParameters)+
    ' AND Code='+QuotedStr(AParamCode));
  case mType of
    0:  begin
          Result:= AReportHelper.ObjectSpace.SQLSelectFirstAsString(
            ' SELECT DRD1.X_ParamValue FROM DefRollData DRD1 '+
            ' JOIN DefRollData DRD2 ON DRD2.ID = DRD1.X_Parameter_ID '+
            ' WHERE DRD1.CLSID = '+QuotedStr(Class_BO_Relations)+
            ' AND DRD1.X_Value_ID = '+QuotedStr(AStoreCard_ID)+
            ' AND DRD2.Code = '+QuotedStr(AParamCode),'');
        end;
    1:  begin
          if not(NxIsBlank(AField)) then
          Result:= AReportHelper.ObjectSpace.SQLSelectFirstAsString(
            ' SELECT DRD1.X_RollValueName FROM DefRollData DRD1 '+
            ' JOIN DefRollData DRD2 ON DRD2.ID = DRD1.X_Parameter_ID '+
            ' WHERE DRD1.CLSID = '+QuotedStr(Class_BO_Relations)+
            ' AND DRD1.X_Value_ID = '+QuotedStr(AStoreCard_ID)+
            ' AND DRD2.Code = '+QuotedStr(AParamCode),'');

        end;
    2:  begin
          Result:= FloatToStr(AReportHelper.ObjectSpace.SQLSelectFirstAsExtended(
            ' SELECT DRD1.X_NumericValue FROM DefRollData DRD1 '+
            ' JOIN DefRollData DRD2 ON DRD2.ID = DRD1.X_Parameter_ID '+
            ' WHERE DRD1.CLSID = '+QuotedStr(Class_BO_Relations)+
            ' AND DRD1.X_Value_ID = '+QuotedStr(AStoreCard_ID)+
            ' AND DRD2.Code = '+QuotedStr(AParamCode),0));
        end;
    3:  begin
          mBoolStr:= AReportHelper.ObjectSpace.SQLSelectFirstAsString(
            ' SELECT DRD1.X_BooleanValue FROM DefRollData DRD1 '+
            ' JOIN DefRollData DRD2 ON DRD2.ID = DRD1.X_Parameter_ID '+
            ' WHERE DRD1.CLSID = '+QuotedStr(Class_BO_Relations)+
            ' AND DRD1.X_Value_ID = '+QuotedStr(AStoreCard_ID)+
            ' AND DRD2.Code = '+QuotedStr(AParamCode),'');
          if mBoolStr = '' then
            Result:= ''
          else begin
            if mBoolStr = 'A' then
              Result:= 'Ano'
            else
              Result:= 'Ne';
          end;
        end;
  end;
end;



begin
end.