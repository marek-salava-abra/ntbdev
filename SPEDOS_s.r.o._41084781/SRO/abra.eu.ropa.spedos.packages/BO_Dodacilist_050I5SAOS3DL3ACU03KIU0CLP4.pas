uses 'abra.eu.ropa.spedos.packages.lib';



{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package1_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package2_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package3_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package4_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package5_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package6_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package7_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package8_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package9_ID')) ;
  UpdatePatches(Self.ObjectSpace, Self.GetFieldValueAsString('X_Package10_ID')) ;
end;

begin
end.