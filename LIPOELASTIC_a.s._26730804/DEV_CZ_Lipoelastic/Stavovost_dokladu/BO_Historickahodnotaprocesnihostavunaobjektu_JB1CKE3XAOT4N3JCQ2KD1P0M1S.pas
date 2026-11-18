uses 'Stavovost_dokladu.lib';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mBO:TNxCustomBusinessObject;
mstring:string;
begin
 if NxCheckBit(Self.State, osNew) then begin
    if not nxisemptyoid(self.GetFieldValueAsString('Object_ID')) then begin
        if self.GetFieldValueAsString('Object_CLSID')='CDMK5QAWZZDL342X01C0CX3FCC' then begin        // objednávky vydané
              mbo:=self.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
              try
                  mbo.load(self.GetFieldValueAsString('Object_ID'),nil);


                          case mbo.GetFieldValueAsString('PMState_ID') of

                                'IODEF00000': begin          //  0   "Ke schválení "
                                     NxShowSimpleMessage('Ke schválení',nil);
                                end;
                                '3050000101': begin          // 20	"Schváleno "
                                     //NxShowSimpleMessage('Schváleno',nil);
                                     mbo.SetFieldValueAsBoolean('Confirmed',True);
                                     mbo.save;
                                     //mbo.Refresh;

                                end;
                                '~000000001': begin          //50	"K výrobě"
                                     NxShowSimpleMessage('K výrobě',nil);
                                     mstring:= GenerateOVBatches(mBO,False);
                                end;
                                '4050000101': begin          //60	"Odeslána na jinou společnost (SK) "
                                     NxShowSimpleMessage('Odeslána na jinou společnost (SK) ',nil);
                                      mstring:= SendDocAPI(mbo,0,True,False);
                                end;
                                '1010000101': begin          //100	"Vyrobeno"
                                    NxShowSimpleMessage('Vyrobeno',nil);
                                end;
                                '': begin
                                    NxShowSimpleMessage('',nil);
                                end;
                          end;
              finally
                  mbo.free;
              end;
      end;
   end;
  End;
end;


begin
end.