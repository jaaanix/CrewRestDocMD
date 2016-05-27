---
title: Praxisprojekt
subtitle: CrewRest
author: Janis Saritzoglou
email: janis.saritzoglou@opitz-consulting.com
toc: true
lang: de-DE
documentclass: scrreprt
bibliography: literatur.bib
csl: din-1505-2.csl
abstract: |
 Im Folgenden Praxisprojekt ist es Ziel eine Cross-Plattform Applikation für Windows 10, Android und iOS zu erstellen. Als Technologien soll Microsoft UWP und Xamarin zum Einsatz kommen. Somit soll aus einer gemeinsamen Codebasis eine Applikation, lauffähig auf verschiedenen Betriebssysteme erzeugt werden. Als Programmiersprache kommt C# zum Einsatz. Der fachliche Hintergrund ist es, ein System für die Mitarbeiter einer Luftfahrtgesellschaft zu entwickeln, um Urlaubsanträge oder allgemeiner: Anträge für Abwesenheiten erstellen zu können und dessen Status einsehen zu können. Bei Möglichkeit ist es erwünschenswert eine Art Kalenderüberischt in der Applikation anzuzeigen, welche die Abwesenheitslage aller Mitarbeiter darstellt, um mögliche Zeiträume für neue Abwesenheitsanträge sinnvoll anlegen zu können.
...
---


# Erstellung einer Cross-Plattform Applikation
Als Entwicklungsumgebung für die Entwicklung der Apps für Android, iOS und Windows 10 kommt Visual Studio 2015 zum Einsatz. Alternativ kann auch Xamarin Studio eingesetzt werden. Bei der Erstellung eines neuen Cross-Plattform-Projekts, wird zwischen einer Blank App[^BlankApp] Xamarin.Forms Portable und Xamarin.Forms Shared unterschieden [@MicrosoftXamarinBook S. 29-31].

In beiden Fällen ist der in C# geschriebene Code Platformübergreifend nutzbar, jedoch gibt er gewisse Unterschiede. Im Falle eines **Xamarin.Forms Portable (Portable Class Library (PCL))** Projekts ist der Code in einer dynamischen, verlinkten Codebibliothek zusammengefasst und wird von den platformspezifischen Projekten referenziert und zu Laufzeit verfügbar gemacht. Bei einem **Xamarin.Forms Shared (Shared Asset Pro-ject (SAP))** Projekt hingegen, wird der gemeinsame Code jedem der einzelnen Projekte bei einem Buildvorgang hinzugefügt.

Ein mögliches Problem bei einem PCL Projekt sind die von Platform zu Platform teils unterschiedlich zugrundeliegenden .NET Klassen, z.B. unterscheiden sich die .NET Klassen für Windows 10 Apps teilweise von den .NET Klassen für iOS und Android. Das bedeutet, dass je nach Zielplatformen eine nur sehr eingeschränkte Version des .NET Frameworks genutzt werden kann. In manchen Fällen bedeutet das aber nicht, dass ein bestimmtes Feature gar nicht genutzt werden kann. Zum Beispiel der in CrewRest verwendete HTTPClient wurde via einem NuGet[^NuGet] Package nachinstalliert.

|                                           | PCL | SAP |
|-------------------------------------------|-----|-----|
| Full Access to .NET Framework             | No  | Yes |
| #ifdef for platform-specific code         | No  | Yes |
| Platform-specific code requires IOC[^IOC] | Yes | No  |
Table: Unterschiede zwischen PCL und SAP Projekten
[@PCLvsSAPTable]

Im Falle der CrewRest Applikation wurde sich aufgrund von Unwissenheit für das standardmäßig ausgewählte PCL Projekt entschieden.

## Wann kommt PCL und wann kommt SAP zum Einsatz?
...

[^IOC]: Inversion Of Control, Alternative zu #ifdef für platformspezifischen Code.
[^NuGet]: Packet Verwaltung von Visual Studio 2015.
[^BlankApp]: Ein neues, leeres Projekt für mehrere Zielbetriebssyssteme.

# Eingesetzte Hardware

Zum Entwickeln und Testen der zu erstellenden Cross-Plattform-Applikation ist folgende Hardware zum Einsatz gekommen.

| Gerät           | OS                         | Version   |
|-----------------|----------------------------|-----------|
| iPhone 5        | iOS                        | xxx       |
| Asus Nexus 7    | Android                    | xxx       |
| Virtual Machine | Windows 10 Insider Preview | Build xxx |
| MacBook Pro     | Mac OSX                    | xxx       |

Table: Hardware und Betriebssysteme

# Benötigte Software (APIs, Tools, IDEs, Emulatoren, Simulatoren)

| Software           | Art | Version             | Zweck                                        |
|--------------------|-----|---------------------|----------------------------------------------|
| Viusal Studio 2015 | IDE | 2015 xxx            | Entwicklung der Applikation                  |
| Android API        | API | 6.0 Marshmallow xxx | Benötigt für Deployment auf Android Platform |
| iOS API            | API | xxx                 | Benötigt für Deployment auf iOS Platform     |

Table: Eingesetzte Software und APIs

![checkmark](img/Checked-50.png "Checked")

# Projektarchitektur
# Wie funktioniert das native Deployment der unterschiedlichen Betriebssysteme/Platformen
## Android
## Win10
## iOS
# PCL
# XAML vs. Code
# Page Layouts
# Implementierung
```csharp
public void lol(int i) {
private ImageSource bildquelle;
}
```
## SOAP
## Platformspezifisches Verhalten
## Bindings
## Updaten von Daten
## Anträge ListView
## Filtern der Liste
## Dynamisches hinzufügen von Komponenten
## Validierung von Eingaben
## DataTrigger
## EmbeddedResource
# Literatur
