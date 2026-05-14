const

      cDivision_ID='C000000101';
      cStore_id='5000000101';
      cStoreCard_ID='RJL4000101';
      cDocqueue_ID='9200000101';
      cDocqueue2_ID='1A10000101';

 Var
mTyp_obchodu:string;
  mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
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
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
    mBookmark : TBookmarkList;
    mOLE, mRoll, mOResult: Variant;
    mids:tstringlist;




function GetBT_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM BusTransactions WHERE Code=''%s'' and hidden=''N'' and closed=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

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



begin
end.