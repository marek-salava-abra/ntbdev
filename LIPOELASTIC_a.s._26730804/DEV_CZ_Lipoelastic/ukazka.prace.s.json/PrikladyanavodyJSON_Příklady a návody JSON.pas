// 1. zpracování dat dodaných zvenčí
// *********************************
// data mohou být a) ve streamu b) v externím soubotu c) ve stringové proměnné
// (typicky při spolupráci s webovými aplikacemi vám http klient vrátí po GET data ve streamu)
// použijte odpovídající class metodu na TJSONSuperObject:

procedure Example_LoadAndParseEternalData;
var
  mData: TJSONSuperObject;
  mStream: TStream;
  mStringWithJsonData: string;
begin
  mData := TJSONSuperObject.ParseStream(mStream, True);
  // nebo
  mData := TJSONSuperObject.ParseFile('C:\DATA.json', True);
  // nebo
  mData := TJSONSuperObject.ParseString(mStringWithJsonData, True);
  try
    // .....
  finally
    mData.Free;   // vsechny parsovaci funkce vytvori novy objekt TJSONSuperObject, jeho uvolneni je ale vzdy na nas !
  end;
end;

// 2. Jak číst data načtené v TJSONSuperObject proměnné
// *****************************************
// Objekt TJSONSuperObject poskytuje dvě sady funkcí pro čtení hodnot.
// První sada obsahuje funkce .AsString, .AsInteger, .AsDouble,...
// Druhá sada obsahuje jednopísmenné indexové property S[cesta], I[cesta], D[cesta]...
// Pro čtení hodnot z exitujícího json lze použít oboje.
// Prvni sada funkci je pouzitelna pro koncovy par obsahujici nazev a hodnotu k precteni hodnoty (nazev uz netreba udavat)
// Druhá sada je chtřejší v tom, že index <cesta> může obsahovat buď jednoduše název hodnoty, ale také názvy vnořených
// objektů s použitím tečkové notace. Snadněji se tak dostanete k hodnotám ve složitější struktuře.
// Příklad:

procedure Example_ReadingJSONValues;
var
  mExmp: string;
  mData, mOsoba: TJSONSuperObject;
  mPole: TJSONSuperObjectArray;
begin
  mExmp := '{"Mesto":"Praha",' +     // hodnota typu string
            '"JeHlavni":true,' +     // hodnota typu boolean
            '"PocetObyvatel":1250000,' +   // hodnota typu integer
            '"TeplotaDnes":19.7,' +        // hodnota typu double
            '"Cena":150.25,' +             // hodnota typu currency
            '"NullValue":null,' +          // nezadana hodnota
            '"Osoba":{"Prijmeni":"Vopička","Jmeno":"Franta"},' +  // vnorena struktura s dvema dalsimi prvky typu string
            '"JmenaDeti":["Petr","Martin","Monika"]}}';     // pole se tremi hodnotami typu string
  mData := TJSONSuperObject.ParseString(mExmp, True);
  try
    mData.AsString;   // -> vrati cely obsah dat v citelne forme jako jeden retezec
    mData.S['Mesto'];     // -> vrati retezec 'Praha'
    mData.B['JeHlavni'];  // -> vrati boolean hodnotu True
    mData.I['PocetObyvatel']; // -> vrati integer 1250000
    mData.D['Cena'];      // -> vrati float 19.7
    mData.N['NullValue'].AsString;  // -> vrati retezec 'null'
    // vnorena struktura
    mOsoba := mData.O['Osoba']; // -> vrati novy JSON s vnorenou casti Osoba
    mOsoba.AsString;     // -> vrati retezec '{"Osoba":{"Prijmeni":"Vopička","Jmeno":"Franta"}'
    mOsoba.S['Prijmeni'];  // -> vrati retezec 'Vopička'
    mData.S['Osoba.Prijmeni'];  // -> vrati retezec 'Vopička' (použití tečkové notace pro přístup k vnořenému objektu)
    mData.S['Osoba.Jmeno'];  // -> vrati retezec 'Franta' (dtto)
    // pole
    mPole := mData.A['Pole'];  // -> vrati novy JSONArray s polem 'Pole'
    mPole.S[0];     // -> vrati retezec 'Petr'
    mData.A['Pole'].S[0];  // -> take vrati retezec 'Petr'
    mPole.S[1];     // -> vrati retezec 'Martin'
  // vsimnete si, ze u pole TJSONSuperObjectArray je indexem property integer (0,1,2...) nikoliv retezec <cesta>
  finally
    mData.Free;
  end;
  //
  // shrnuti:
  // TJSONSuperObject.S[cesta] ... vraci String
  // TJSONSuperObject.B[cesta] ... vraci Boolean
  // TJSONSuperObject.I[cesta] ... vraci Integer
  // TJSONSuperObject.D[cesta] ... vraci Double (float/extended)
  // TJSONSuperObject.C[cesta] ... vraci Currency
  // TJSONSuperObject.O[cesta] ... vraci Object tj. TJSONSuperObject
  // TJSONSuperObject.A[cesta] ... vraci Array tj. TJSONSuperObjectArray
  // TJSONSuperObject.N[cesta] ... slouzi k manipulaci s Null hodnotami - presny zpusob prace mi neni znam, treba experimantovat
  // TJSONSuperObject.DTJSONSuperObject[cesta] ... vraci TDateTime (viz dále);
  // TJSONSuperObject.DT8601[cesta] ... vraci TDateTime (viz dále);
  //
  // TJSONSuperObjectArray.S[i] ... vraci i-ty prvek pole jako String
  // atd... obdobne jako TJSONSuperObject (pouze nema pochopitelne propertu A[])
end;

// 3. Jak měnit data načtené v TJSONSuperObject proměnné
// ******************************************
// Indexové property (S[], I[], D[]...) jsou read/write, takže s jejich pomocí lze hodnoty do json dat i zapisovat.

procedure Example_WritingJSONValues;
var
  mExmp: string;
  mData: TJSONSuperObject;
begin
  mExmp := '{"Mesto":"Praha",' +     // hodnota typu string
            '"JeHlavni":true,' +     // hodnota typu boolean
            '"PocetObyvatel":1250000,' +   // hodnota typu integer
            '"TeplotaDnes":19.7,' +        // hodnota typu double
            '"Cena":150.25,' +             // hodnota typu currency
            '"NullValue":null,' +          // nezadana hodnota
            '"Osoba":{"Prijmeni":"Vopička","Jmeno":"Franta"},' +  // vnorena struktura s dvema dalsimi prvky typu string
            '"JmenaDeti":["Petr","Martin","Monika"]}}';     // pole se tremi hodnotami typu string
  mData := TJSONSuperObject.ParseString(mExmp, True);
  try
    mData.S['Mesto'] := 'Brno';
    mData.B['JeHlavni'] := False;
    mData.O['Osoba'].S['Prijmeni'] := 'Novák';
    mData.A['Pole'].S[0] := 'Pavel';
    // atd...
    // Pozor: Při zapisování hodnot nelze použít tečkovou notaci.
    // mData.S['Osoba.Jmeno'] := 'Roman'   neprojde.

  finally
    mData.Free;
  end;
end;

// 4. Práce s datumy
// *****************
// JSON je textový formát a proto se datumy v něm uvádějí vždy v textové reprezentaci. Pro převod TDateTime do textové podoby
// existuje mnoho různých formátů. Nejčastěji používaným je formát pocházející z Java Scriptu tzv. Microsoft AJAX alike format for JSON,
// který vypadá asi takto: "/Date(1198908717056)/", kde číslo je čas v millisekundách od 1. ledna 1970 (nazývejme ho JsonDate).
// Druhým námi podporovaným formátem je ISO8601 (často používaný v XML), vypadá asi takto: "2014-12-14T23:55:30.000Z".
// Datum se vždy uvádí v UTC (tedy pro časovou zónu 0) a vždy s ignorací posunu letního času.
// Na TJSONSuperObject je implementována konverze pro oba tyto formáty, musíte zvolit odpovídající propertu DTJSONSuperObject nebo DT8601 podle toho,
// v jakém formátu je datum v json datech očekáváno.
// Použití indexových propert je shodné jako u ostatních (S, I, D...) a jsou taktéž read/write, tedy zajišťují obousměrnou konverzi datumu.

procedure Example_JSONAndDateTime;
var
  mExmp: string;
  mData: TJSONSuperObject;
begin
  mExmp := '{"Datum1":"\/Date(1408053600000)\/"},' +
            '"Datum2":"2014-12-14T23:00:00.000Z")';
  mData := TJSONSuperObject.ParseString(mExmp, True);
  try
    mData.DTJson['Datum1'];    // -> vrati TDateTime s hodnotou 15.8.2014
    mData.DT8601['Datum2'];    // -> vrati TDateTime s hodnotou 15.12.2014
    // podobne pro zápis:
    mData.DTJSON['Datum1'] := Now;

  finally
    mData.Free;
  end;
end;

// 5. Jak vytvořit nový JSON od začátku?
// *************************************
// Vytvoříme si novou instanci prázdného JSON konstruktorem a pak do něj zapisujeme
// hodnoty stejným způsobem, jako jsme měnili hodnoty už existující.
// Pokud hodnota s daným názvem neexistuje, vytvoří se jako nová...

procedure Example_CreatingNewJSON;
var
  mData, mManzelka: TJSONSuperObject;
begin
  mData := TJSONSuperObject.Create;  // vytvoříme novou instanci JSON konstruktorem
  try
    mData.S['Jmeno'] := 'Josef Novák';
    mData.B['JeMuz'] := True;
    mData.I['PocetDeti'] := 2;
    // vytvorime vnoreny objekt ...
    mManzelka := mData.CreateJSON; // Pozor, CreateJSON není konstruktor ani class-metoda!
    mManzelka.S['Jmeno'] := 'Zdena Nováková';
    mManzelka.B['JeMuz'] := False;
    mData.O['Manzelka'] := mManzelka; // ... a pripojime jej jako hodnotu

    mData.AsString; // vypise: {"Manzelka":{"Jmeno":"Zdena Nováková","JeMuz":false},"PocetDeti":2,"Jmeno":"Josef Novák","JeMuz":true}

  finally
    mData.Free;
  end;
end;

// 6. Jak vytvořit nové pole a naplnit ho hodnotami, pracovat s prvky pole
// ***********************************************************************
// Vytvoříme si novou instanci prázdného JSON konstruktorem a jeho metodou
// TJSONSuperObject.CreateJSONArray vytvoříme prázdné pole, které do JSON vložíme
// jako vnořený objekt přes .O[].
// Do pole pak můžeme přidávat jednotlivé prvky.
// Zde je příklad:

procedure Example_CreatingNewJsonArray;
var
  mData: TJSONSuperObject;
  i: integer;
begin
  mData := TJSONSuperObject.Create;
  try
    mData.O['Pole'] := mData.CreateJSONArray;
    mData.A['Pole'].S[0] := 'První prvek';
    mData.A['Pole'].S[1] := 'Druhy prvek';
    mData.A['Pole'].S[2] := 'Treti prvek';
    // počet prvků v poli lze zjistit z property .Length
    // lze tedy např. iterovat přes všechny prvky
    for i := 0 to mData.A['Pole'].Length - 1 do begin
      mData.A['Pole'].S[i]; // vrací postupně jednotlivé prvky jako retězce
    end;
    // vymazani i-tého prvku z pole
    mData.A['Pole'].Delete(1);

  finally
    mData.Free;
  end;
end;


// 7. Jak někam uložit JSON
//*************************
// Vytvoříme si novou instanci prázdného JSON konstruktorem.
// Pro uložení dat z TJSONSuperObject objektu slouží metody SaveToStream a SaveToFile.
// Jedna je uložení do TStream a druhá do souboru zadaného jména.

procedure Example_SaveJsonData;
var
  mExmp: string;
  mData: TJSONSuperObject;
begin
  mData := TJSONSuperObject.Create;
  try
    mExmp := '{"Mesto":"Praha",' +
              '"JeHlavni":true,' +
              '"PocetObyvatel":1250000}';
    mData := TJSONSuperObject.ParseString(mExmp, True);
    mData.SaveToFile('C:\DATA.json');

  finally
    mData.Free;
  end;
end;


// TJSONSuperObject je obalkou obektu SuperObject (komponenta treti strany), dalsi ukazky pouziti najdete na:
// http://superobject.googlecode.com/git/readme.html


begin
end.