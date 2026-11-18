procedure OSStartTransaction(var AInTransaction: boolean; var AOS: TNxCustomObjectSpace);
begin
  //je zapnuta transakce
  AInTransaction := AOS.InTransaction;
  //pokud neni zapnu
  if not AInTransaction then
    AOS.StartTransaction(taReadCommited);
end;

procedure OSCommit(const AInTransaction: boolean; var AOS: TNxCustomObjectSpace);
begin
  if not AInTransaction then
    AOS.Commit;
end;

procedure OSRollBack(const AInTransaction: boolean; var AOS: TNxCustomObjectSpace);
begin
  if not AInTransaction then
    AOS.RollBack;
end;

begin
end.