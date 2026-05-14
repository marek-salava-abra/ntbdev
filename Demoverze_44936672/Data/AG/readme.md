# Popis skriptu AG

Tento skript slouží k získávání aktuálních cen mědi (LME Copper Cash) z webové stránky Westmetall (https://www.westmetall.com/en/markdaten.php).

## Funkce

- **GetData**: Hlavní procedura, která stahuje data z webu, parsuje HTML odpověď a extrahuje aktuální cenu mědi.
- **API_GET**: Pomocná funkce pro provedení HTTP GET požadavku.
- **ConvertToText** a **ConvertUTF8toString**: Funkce pro konverzi kódování textu.

## Výstup

Skript vrací cenu mědi jako řetězec ve formátu '#cena# pozice index číslo float', kde je cena zpracovaná hodnota z webu.

## Poznámky

- Skript používá WinHttp pro HTTP komunikaci.
- Parsování HTML je založeno na specifických znacích a pozicích v odpovědi, což může být náchylné na změny v struktuře webu.