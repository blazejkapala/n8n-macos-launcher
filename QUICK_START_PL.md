# Szybki Start - n8n Launcher

## 📦 Masz 5 plików (wszystko po angielsku):

1. **n8n-launcher.sh** - główny skrypt (angielski)
2. **README.md** - kompletna dokumentacja z instrukcjami testowania i publikacji (angielski)
3. **install.sh** - opcjonalny jednolinijkowy instalator
4. **LICENSE** - licencja MIT
5. **.gitignore** - konfiguracja Git

## ✅ Krok 1: Testowanie

```bash
# Nadaj uprawnienia
chmod +x n8n-launcher.sh

# Uruchom i przetestuj
./n8n-launcher.sh
```

**Sprawdź:**
- Kolory działają?
- Wykrywa Maca (M1/M2/M3)?
- Instaluje n8n?
- Uruchamia się?

**Przetestuj:**
- Ponowne uruchomienie
- Ctrl+C w różnych momentach  
- Różne porty (8080, etc.)

## 🌐 Krok 2: GitHub

**W README.md znajdziesz szczegółową sekcję "Publishing to GitHub"** która pokazuje:

1. Jak stworzyć repo na GitHubie
2. Komendy git do wrzucenia kodu
3. Co zaktualizować (YOUR_USERNAME → twój username)
4. Opcjonalne ulepszenia (screenshot, release)

**Krótka wersja:**
```bash
# Lokalnie
git init
git add .
git commit -m "Initial commit: n8n macOS launcher"

# GitHub (ZMIEŃ YOUR_USERNAME!)
git remote add origin https://github.com/YOUR_USERNAME/n8n-macos-launcher.git
git branch -M main
git push -u origin main
```

**WAŻNE:** Po wrzuceniu na GitHub, zaktualizuj w plikach `YOUR_USERNAME` na swój GitHub username!

## 📚 Wszystko jest w README.md

README zawiera wszystko czego potrzebujesz:
- ✅ Jak działa skrypt
- ✅ Jak testować (różne scenariusze)
- ✅ Jak wrzucić na GitHub (krok po kroku)
- ✅ Rozwiązywanie problemów
- ✅ Opcjonalne ulepszenia

## 💡 Szybkie komendy

```bash
# Testuj
./n8n-launcher.sh

# Zapisz logi
./n8n-launcher.sh 2>&1 | tee test.log

# Git
git init
git add .
git commit -m "Initial commit"
git push
```

## 🎯 Minimalny checklist

- [ ] Przetestuj skrypt na swoim Macu
- [ ] Sprawdź czy wszystko działa
- [ ] Stwórz repo na GitHubie  
- [ ] Wrzuć kod (`git push`)
- [ ] Zaktualizuj YOUR_USERNAME w plikach
- [ ] Commit i push zmian
- [ ] Gotowe! 🎉

Powodzenia! 🚀
