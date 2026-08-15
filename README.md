# Mini-Cut Tracker

App iOS native en SwiftUI — carnet de suivi quotidien pour une phase de perte de poids (poids, nutrition, pas, activité). Application strictement personnelle : pas de compte, pas de backend, toutes les données restent sur l'appareil.

## Ouvrir le projet

Ouvrir `MiniCutTracker.xcodeproj` dans Xcode 15+ (iOS 17 minimum). Au premier lancement, choisir votre équipe de signature dans l'onglet **Signing & Capabilities** de la cible `MiniCutTracker` (`CODE_SIGN_STYLE` est réglé sur *Automatic* mais aucune équipe n'est présélectionnée). L'identifiant de bundle par défaut est `com.stephanesls.MiniCutTracker` — à adapter si besoin.

> Ce projet a été généré et n'a **pas pu être compilé** dans cet environnement (pas de toolchain Xcode/Swift disponible côté serveur). Ouvrez-le dans Xcode pour lancer un premier build ; signalez-moi toute erreur de compilation pour que je la corrige.

## Structure

```
MiniCutTracker/
  MiniCutTrackerApp.swift   — point d'entrée, ModelContainer SwiftData
  Models/                   — DailyEntry, Targets (SwiftData @Model)
  Design/                   — Theme (palette/typo), WeightTapeView (bande altimètre),
                               InstrumentGaugeView / GaugeBar (jauges instrument)
  Services/                 — CSVExporter, ShareSheet
  Views/                    — RootTabView, DayView, TrendView, HistoryView, SettingsView
  Assets.xcassets/          — AppIcon (image à fournir), AccentColor
```

Pas de dossier `ViewModels/` séparé : chaque écran pilote son état via `@Query`/`@State` SwiftData directement (équivalent idiomatique à un ViewModel pour ce genre d'app).

## Fonctionnalités livrées

- Écran du jour : navigation par date, bande de poids façon altimètre, jauges calories/protéines/lipides/glucides/pas éditables, toggle musculation, minutes Zone 2. Sauvegarde immédiate à chaque modification (`modelContext.save()`).
- Tendance : graphique Swift Charts (poids quotidien + moyenne mobile 7 jours + ligne d'objectif), cartes résumé, indicateur de tendance.
- Historique : liste des jours renseignés, édition en tapant une ligne, suppression au swipe.
- Réglages : cibles nutritionnelles/pas, poids de départ/objectif, export CSV via la feuille de partage iOS.

## Non inclus (à valider avant ajout)

HealthKit (lecture poids/pas) et notifications locales (rappel de pesée) ne sont pas implémentés — ils nécessitent d'activer des capacités/permissions dans le projet Xcode. Dites-moi si vous voulez que je les ajoute.

## Icône d'application

`AppIcon.appiconset` est vide (catalogue universel 1024×1024 déclaré, sans image). Ajoutez votre icône dans Xcode avant de soumettre à l'App Store — ce n'est pas bloquant pour tester sur simulateur/appareil.
