# Abra Repository - Development Scripts

Toto repozitář obsahuje vývojové skripty a moduly pro různé instance ABRA systému.

## Struktura adresářů

### Hlavní složky podle instance

- **Demoverze_44936672/**: Skripty pro demo verzi systému ABRA.
  - **Data/**: Obsahuje různé moduly a skripty, např.:
    - `eu.abra.zde/`: Moduly pro základní funkcionality.
    - `eu.abra.masa.API/`: API moduly.
    - `eu.abra.masa.kesselgruber.feed/`: Feed moduly pro Kesselgruber.
    - `eu.abra.roeh.Logio/`: Logistické moduly.
    - `REST_SkladTerm/`: REST API pro skladové terminály.
    - A mnoho dalších modulů pro import, export, API integrace atd.

- **PROMOS_CZ_s.r.o._25852591/**: Skripty pro společnost PROMOS CZ s.r.o.
  - **Data/**: Moduly specifické pro tuto instanci, např.:
    - `eu.abra.masa.promos.GetQ/`: Modul pro získávání množství.
    - `eu.abra.masa.API_OUT/`: API výstupní moduly.
    - `eu.abra.masa.promos.checkmail/`: Modul pro kontrolu emailů.
    - `eu.abra.imports/`: Import moduly.
    - `REST_SkladTerm/`: REST API pro skladové terminály.
    - Další moduly pro různé funkcionality jako inventura, exporty atd.

- **SIMON_FM_s.r.o._26837358/**: Skripty pro společnost SIMON FM s.r.o.
  - **SimonFM/**: Hlavní složka s moduly, např.:
    - `eu.abra.masa.simon.APISync/`: Synchronizace API.
    - `eu.abra.masa.API_IN/`: Vstupní API moduly.
    - `eu.abra.masa.simon.GenerateOV/`: Generování objednávek.
    - `REST_SkladTerm/`: REST API pro skladové terminály.
    - Různé další moduly pro import, export, e-shop integrace atd.

- **BARTON_Market_servis,_s.r.o._25133691/**: Skripty pro společnost BARTON Market servis.
  - **Barton/**: Moduly a nástroje pro BARTON.
  - **Srouby_Matice/**: Obsahuje specializované ABRA moduly jako `eu.abra.masa.Barton_SM.API/`.

- **LIPOELASTIC_a.s._26730804/** a **LIPOELASTIC_s.r.o._53578341/**: Skripty pro společnost LIPOELASTIC, rozdělené podle instance.

### Další soubory v kořeni

- **GPATH, GRTAGS, GTAGS**: Soubory pro GNU Global - nástroj pro rychlé vyhledávání v kódu.
- **README.md**: Tento soubor s popisem struktury.

## Poznámky

- Každá hlavní složka odpovídá jedné instanci ABRA systému.
- Moduly jsou organizovány podle funkcionality a zdroje (např. eu.abra.masa pro ABRA moduly).
- Skripty obsahují integrace s externími API (např. api.kingtony.cz) a různé automatizované procesy.
