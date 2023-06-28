# Verilog Kernel Module

## Moduł Verilog
Moduł sprzętowy w języku Verilog realizujący operację mnożenia dwóch 24-bitowych liczb (zawartych w rejestracg A1 oraz A2) bez znaku metodą "bit po bicie".
Dane na temat operacji są przechowywane w 3 rejestrach:
- W (32-bitowy wynik operacji)
- L (liczba jedynek wyniku)
- B (rejestr flag statusu)

### Rejestr flag

Numer bitu | Znaczenie
-----------|----------
0 | Flaga przepełnienia
1 | Flaga gotowości do wykonania operacji
2 | Flaga niepoprawnych danych rejestru A1
3 | Flaga niepoprawnych danych rejestru A2
4 | Flaga poprawnego zakończenia operacji mnożenia

## Testowanie
W repozytorium zawarte są również testy:
- Testy jednostkowe modułu Verilog (gpioemu_tb.v)
- Testy integracyjne (app.c)

Znajduje się tam 6 prostych testów napisanych manualnie oraz 10K testów losowych.

## Moduł jądra Linux
Moduł ten odpowiada za utworzenie plików SYS-FS oraz przekazywanie danych z tych plików do odpowiednich komórek pamięci.

