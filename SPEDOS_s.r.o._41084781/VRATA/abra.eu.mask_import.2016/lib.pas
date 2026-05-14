 Var
mTyp_obchodu:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mSite : TDynSiteForm;
  mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  mrow: TNxCustomBusinessObject;
  mbusorder,mbustransaction,mbusproject,mbankacount: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mhead: TNxHeaderBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder,mID_Division, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mID_kost_symbol,mID_payment,mID_delivery:string;
  mCountryName:string;
  mtoESL:boolean;


 Function ErrtElementString(mXMLHead : TNxScriptingXMLWrapper;mElement:string):boolean;
var
mstring:string;
begin
result:=true;
    try
          mstring:=mXMLHead.getElementAsString(mElement);
          result:=false;
    except
          result:=true;
    end;

end;


function getIDfromfield(os:TNxCustomObjectSpace;R_polozka:string;table:string;Polozka1:string;value1: String;Polozka2:string;value2:String):String;
var
    mR : TStrings;
const
    cSQL2 = 'SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
       if nxisblank(Polozka2) then begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s''', [r_polozka,table,polozka1,value1]), mR);
       end else begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''', [r_polozka,table,polozka1,value1,polozka2,value2]), mR);
       end;
        if mR.Count > 0 then begin
            Result := mR.Strings[0];
        end else begin
            Result:='';
        end;
    finally
        mR.Free;
    end;
end;


function getIDsfromfield(os:TNxCustomObjectSpace;R_polozka:string;table:string;Polozka1:string;value1: String;Polozka2:string;value2:String):TStringList;
var
    mR : TStringList;
const
    cSQL2 = 'SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''';
begin
    mR := TStringList.Create;
    try
       if nxisblank(Polozka2) then begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s''', [r_polozka,table,polozka1,value1]), mR);
       end else begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''', [r_polozka,table,polozka1,value1,polozka2,value2]), mR);
       end;
        if mR.Count > 0 then begin
            Result := mR;
        end;
    finally
        mR.Free;
    end;
end;




begin
end.