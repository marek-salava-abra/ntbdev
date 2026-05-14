uses
  'eu.abra.darova.1.predvyplnovani.knihovna1';

// deklarace promenne na urovni unity
var
  gPocitadlo: integer;
  
// Normalni funkce uvnitr stejne unity
function MujCas: string;
begin
  // Vraci textovou reprezentaci aktualniho data a casu
  Result := TimeToStr(Now);
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
  // Interni funkce deklarovana uvnitr jine funkce
  function MojeFunkce: integer;
  begin
    // inkrementace pocitadle
    Inc(gPocitadlo);
    Result := gPocitadlo;
  end;

begin
  // Nastaveni polozky/fieldu Poznamka na ...
  Self.SetFieldValueAsString('Note', Mujcas + ' ' + IntToStr(MojeFunkce) + ' ' + FunkceZKnihovny);
end;

begin
end.