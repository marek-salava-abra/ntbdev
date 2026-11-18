var
  fSite: TSiteForm;

//ve vizuálnu vytvoříme proceduru pro zpracování události změny na řadě dokladu

procedure InitSite_Hook(Self: TSiteForm);
var
  mpnDocQueue_ID: TNxGeneralRollMovablePanel;
begin
  mpnDocQueue_ID := TNxGeneralRollMovablePanel(Self.FindComponent('mpnDocQueue_ID'));
  mpnDocQueue_ID.onInEditAdmit := @DQEditAdmit; //Vytvoření procedury pro zpracování události zadání té řady dokladů
  fSite := Self;
end;

//a v rámci té události si ve vizuálnu nastavíme, co potřebujeme - tady to je zobrazení popř. skrytí sloupců v gridu řádků

procedure DQEditAdmit;
var
  mpnIsRowDiscount: TNxCheckBoxMovablePanel;
  colRowDiscount1: TNxMultiGridColumn;
  colRowDiscount2: TNxMultiGridColumn;
  colRowDiscount3: TNxMultiGridColumn;
begin
 try
  mpnIsRowDiscount := TNxCheckBoxMovablePanel(fSite.FindComponent('mpnIsRowDiscount'));
  colRowDiscount1 := TNxMultiGridColumn(fSite.FindComponent('colRowDiscount1'));
  colRowDiscount2 := TNxMultiGridColumn(fSite.FindComponent('colRowDiscount2'));
  colRowDiscount3 := TNxMultiGridColumn(fSite.FindComponent('colRowDiscount3'));
  colRowDiscount1.Visible := mpnIsRowDiscount.InCheckBox_Checked;
  colRowDiscount2.Visible := mpnIsRowDiscount.InCheckBox_Checked;
  colRowDiscount3.Visible := mpnIsRowDiscount.InCheckBox_Checked;
 except
  //klient nechtěl být informován o výjimce
 end;
end;

begin
end.