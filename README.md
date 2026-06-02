# Expense App

Σύγχρονη εφαρμογή για κινητές συσκευές αναπτυγμένη σε **Flutter**, η οποία επιτρέπει την καταγραφή, οργάνωση και ανάλυση καθημερινών εξόδων. Όλα τα δεδομένα αποθηκεύονται τοπικά στη συσκευή μέσω **SQLite**, χωρίς να απαιτείται σύνδεση στο διαδίκτυο.

---

## Δυνατότητες

Η εφαρμογή υλοποιεί τέσσερις βασικές περιπτώσεις χρήσης μέσω τεσσάρων καρτελών πλοήγησης.

**Έξοδα.** Κεντρική οθόνη με hero gradient card που εμφανίζει το συνολικό ποσό, τον αριθμό εξόδων και τον αριθμό κατηγοριών. Διαδραστικά chips κατηγοριών στην κορυφή επιτρέπουν άμεσο φιλτράρισμα της λίστας. Κάθε έξοδο εμφανίζεται με χρωματιστό εικονίδιο της κατηγορίας του, ποσό, ημερομηνία και προαιρετική τοποθεσία. Πλήρης υποστήριξη pull-to-refresh και staggered animations κατά τη φόρτωση.

**Κατηγορίες.** Δημιουργία, επεξεργασία και διαγραφή προσαρμοσμένων κατηγοριών εξόδων. Κάθε κατηγορία αποκτά αυτόματα μοναδικό εικονίδιο και χρωματική ταυτότητα βάσει του ονόματός της (π.χ. καφές → καφέ μπρίκι, αθλητικά → ροζ μπλούζα).

**Ανάλυση.** Επιλογή χρονικής περιόδου μέσω date pickers ή προεπιλεγμένων διαστημάτων (7, 30, 90 ημέρες). Παρουσιάζονται: συνολικό ποσό περιόδου, pie chart με ποσοστιαία κατανομή ανά κατηγορία, και ταξινομημένη λίστα σε φθίνουσα σειρά κατά συνολική αξία με animated progress bars.

**Σχετικά.** Πληροφορίες δημιουργού, toggle για **Dark Mode**, τεχνολογίες που χρησιμοποιήθηκαν, λίστα λειτουργιών και πληροφορίες του project.

Επιπλέον περιλαμβάνεται καταγραφή τοποθεσίας μέσω GPS με αυτόματη μετατροπή των συντεταγμένων σε ανθρώπινη διεύθυνση (reverse geocoding) σε όλα τα έξοδα.

---

## Τεχνολογικό stack

- **Framework**: Flutter 3.41.2 (Dart)
- **Βάση δεδομένων**: SQLite μέσω `sqflite`
- **State management**: `provider` (ChangeNotifier pattern)
- **Γεωτοποθεσία**: `geolocator` + `geocoding`
- **Γραφήματα**: `fl_chart`
- **Εξωτερικά links**: `url_launcher`
- **Μορφοποίηση**: `intl` (ελληνικό locale)
- **Πλατφόρμα**: Android

---

## Δομή project

```
lib/
├── main.dart                          # Entry point + theme switching
├── models/
│   ├── category.dart                  # Model κατηγορίας
│   └── expense.dart                   # Model εξόδου
├── services/
│   ├── database_service.dart          # SQLite singleton + seed data
│   ├── app_provider.dart              # State management + dark mode
│   └── location_service.dart          # GPS + reverse geocoding
├── screens/
│   ├── splash_screen.dart             # Animated splash με payments icon
│   ├── home_screen.dart               # NavigationBar 4 καρτελών
│   ├── expenses_list_screen.dart      # Hero card + filter chips + λίστα
│   ├── categories_screen.dart         # Διαχείριση κατηγοριών
│   ├── add_expense_screen.dart        # Φόρμα προσθήκης/επεξεργασίας
│   ├── expense_detail_screen.dart     # Λεπτομέρειες εξόδου
│   ├── analysis_screen.dart           # Pie chart + κατάταξη
│   └── about_screen.dart              # Δημιουργός + Dark Mode toggle
└── utils/
    ├── app_theme.dart                 # Theme + light/dark colors
    ├── category_style.dart            # Mapping κατηγορίας σε εικονίδιο/χρώμα
    └── formatters.dart                # Νόμισμα και ημερομηνίες
```

---

## Βάση δεδομένων

Τοπική SQLite βάση με δύο πίνακες συνδεδεμένους σε σχέση **ένα-προς-πολλά**.

**Πίνακας `categories`**

| Στήλη | Τύπος | Σημειώσεις |
|---|---|---|
| id | INTEGER | Πρωτεύον κλειδί, αυτόματη αρίθμηση |
| name | TEXT | Υποχρεωτικό |
| description | TEXT | Προαιρετικό |

**Πίνακας `expenses`**

| Στήλη | Τύπος | Σημειώσεις |
|---|---|---|
| id | INTEGER | Πρωτεύον κλειδί, αυτόματη αρίθμηση |
| description | TEXT | Προαιρετικό |
| amount | REAL | Υποχρεωτικό, σε ευρώ |
| category_id | INTEGER | Ξένο κλειδί → `categories.id` (ON DELETE CASCADE) |
| date_time | TEXT | Μορφή ISO 8601 |
| latitude | REAL | Προαιρετικό |
| longitude | REAL | Προαιρετικό |
| location_name | TEXT | Προαιρετικό |

Κατά την πρώτη εκκίνηση η βάση φορτώνεται αυτόματα με **8 κατηγορίες** και **33 δείγματα εξόδων** σε διάστημα 90 ημερών, με ρεαλιστικές αγορές (Mikel Coffee, Nike, Adidas, Cosmote TV, Netflix, Aegean Airlines, Tedi, Sklavenitis κ.ά.) και πραγματικές GPS συντεταγμένες Θεσσαλονίκης.

---

## Προαπαιτούμενα

Πριν την εγκατάσταση της εφαρμογής, απαιτούνται τα ακόλουθα εργαλεία:

- **Flutter SDK** 3.41.2 ή νεότερο
- **Android Studio** με Android SDK (API 33+)
- **Git** για την κλωνοποίηση του repository
- **IntelliJ IDEA** ή **Android Studio** ως IDE (προαιρετικό)

---

## Οδηγίες εγκατάστασης

### Βήμα 1 — Εγκατάσταση Flutter SDK

1. Λήψη του Flutter SDK από: https://flutter.dev/docs/get-started/install
2. Επιλογή πλατφόρμας **Windows** και λήψη του αρχείου zip
3. Εξαγωγή των περιεχομένων στον φάκελο `C:\flutter`
4. Προσθήκη του `C:\flutter\bin` στις **Environment Variables → Path** των Windows
5. Επιβεβαίωση της εγκατάστασης μέσω PowerShell:

```powershell
flutter --version
```

Το αποτέλεσμα θα πρέπει να αναφέρει την έκδοση Flutter (π.χ. `Flutter 3.41.2`).

### Βήμα 2 — Εγκατάσταση Android Studio

1. Λήψη από: https://developer.android.com/studio
2. Κατά την εγκατάσταση, επιβεβαίωση ότι περιλαμβάνεται το **Android SDK** και το **Android Virtual Device**
3. Άνοιγμα του Android Studio και μετάβαση στο **Tools → Device Manager**
4. Δημιουργία νέου Virtual Device με συσκευή **Pixel 6** και έκδοση **API 33** ή νεότερη
5. Εκκίνηση του emulator μέσω του κουμπιού ▶

### Βήμα 3 — Εγκατάσταση IDE (προαιρετικά)

Εάν επιλεγεί το IntelliJ IDEA αντί του Android Studio:

1. Λήψη της **Community Edition** από: https://www.jetbrains.com/idea/
2. Μετά την εγκατάσταση, μετάβαση στο **Settings → Plugins**
3. Αναζήτηση και εγκατάσταση του plugin **Flutter** (περιλαμβάνει αυτόματα και το Dart plugin)
4. Επανεκκίνηση του IntelliJ IDEA

### Βήμα 4 — Κλωνοποίηση του repository

Άνοιγμα PowerShell στον επιθυμητό φάκελο και εκτέλεση:

```powershell
git clone https://github.com/TechChefe/expense_app__.git
cd expense_app__
```

### Βήμα 5 — Εγκατάσταση εξαρτήσεων

```powershell
flutter pub get
```

### Βήμα 6 — Εκτέλεση εφαρμογής

Με τον emulator σε λειτουργία, εκτέλεση:

```powershell
flutter run
```

Η πρώτη εκκίνηση ενδέχεται να διαρκέσει 2–5 λεπτά για το build. Μετά την ολοκλήρωση, εμφανίζεται η οθόνη splash και η εφαρμογή φορτώνεται αυτόματα με τα προφορτωμένα δείγματα δεδομένων.

---

## Συντομεύσεις κατά την εκτέλεση

Κατά την εκτέλεση μέσω `flutter run`, μέσω του terminal είναι διαθέσιμες οι παρακάτω εντολές:

- `r` — Hot reload (γρήγορη ανανέωση κώδικα)
- `R` — Hot restart (πλήρης επανεκκίνηση)
- `q` — Έξοδος από την εφαρμογή

---
