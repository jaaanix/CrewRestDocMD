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
 Im Folgenden Praxisprojekt ist es Ziel die Cross-Plattform Applikation "CrewRest" für Windows 10, Android und iOS zu erstellen. Als Technologien soll Microsoft UWP und Xamarin zum Einsatz kommen. Somit soll aus einer gemeinsamen Codebasis eine Applikation, lauffähig auf verschiedenen Betriebssysteme erzeugt werden. Als Programmiersprache kommt C# zum Einsatz. Der fachliche Hintergrund ist es, ein System für die Mitarbeiter einer Luftfahrtgesellschaft zu entwickeln, um Urlaubsanträge oder allgemeiner: Anträge für Abwesenheiten erstellen zu können und dessen Status einsehen zu können. Bei Möglichkeit ist es erwünschenswert eine Art Kalenderüberischt in der Applikation anzuzeigen, welche die Abwesenheitslage aller Mitarbeiter darstellt, um mögliche Zeiträume für neue Abwesenheitsanträge sinnvoll anlegen zu können.
...
---
# Wie Xamarin funktioniert

# Erstellung einer Cross-Plattform Applikation
Als Entwicklungsumgebung für die Entwicklung der Apps für Android, iOS und Windows 10 kommt Visual Studio 2015 zum Einsatz. Alternativ kann auch Xamarin Studio eingesetzt werden. Bei der Erstellung eines neuen Cross-Plattform-Projekts, wird zwischen einer Blank App[^BlankApp] Xamarin.Forms Portable und Xamarin.Forms Shared unterschieden.

Im Falle der CrewRest Applikation wurde sich aufgrund von Unwissenheit für das standardmäßig ausgewählte PCL Projekt entschieden.

In beiden Fällen ist der in C# geschriebene Code Plattformübergreifend nutzbar, jedoch gibt er gewisse Unterschiede. Im Falle eines **Xamarin.Forms Portable (Portable Class Library (PCL))** Projekts ist der Code in einer dynamischen, verlinkten Codebibliothek zusammengefasst und wird von den plattformspezifischen Projekten referenziert und zu Laufzeit verfügbar gemacht. Bei einem **Xamarin.Forms Shared (Shared Asset Pro-ject (SAP))** Projekt hingegen, wird der gemeinsame Code jedem der einzelnen Projekte bei einem Buildvorgang hinzugefügt.[@MicrosoftXamarinBook S. 29-31]

|                                                                | PCL   | SAP  |
|----------------------------------------------------------------|-------|------|
| Komplettes .NET Framework nutzbar?                             | Nein  | Ja   |
| #if-Syntax[^ifOS] für plattformspezifischen Code nutzbar?      | Nein  | Ja   |
| plattformspezifischer Code benötigt IOC[^IOC]                  | Ja    | Nein |

Table: Unterschiede zwischen PCL und SAP Projekten
[@PCLvsSAPTable]

Ein mögliches Problem bei einem PCL Projekt sind die von Plattform zu Plattform teils unterschiedlich zugrundeliegenden .NET Klassen, z.B. unterscheiden sich die .NET Klassen für Windows 10 Apps teilweise von den .NET Klassen für iOS und Android. Das bedeutet, dass je nach gewünschten Zielplattformen eine eingeschränkte Version des .NET Frameworks genutzt wird. In manchen Fällen bedeutet das aber nicht, dass ein bestimmtes Feature gar nicht genutzt werden kann, gewisse Bibliotheken lassen sich z.B. in Form eines NuGet[^NuGet] Packages nachträglich installieren.

Die Nutzung eines eingeschränkten .NET Frameworks erschwert die Umsetzung der Cross-Plattform Applikation "CrewRest", welche einen SOAP Service (siehe Kapitel [SOAP]) konsumiert. Im Falle eine Single-Plattform Applikation (ggf. auch mehr als eine Zielplattform) bietet die IDE Visual Studio 2015 einen Meachanismus an, welcher aus  einer gegebenen URL unter der SOAP Services erreichbar sind, eine Komplette Abbildung der Daten, welche die SOAP Services liefern zu generieren. Der Entwickler muss sich dann nicht mehr um das Parsen von SOAP Requests und Responses kümmern. Bei der Cross-Plattform Applikation CrewRest ist dies jedoch nicht möglich, da nicht gewährleistet werden kann, dass zur Laufzeit alle benötigten .NET Funktionalitäten auf jeder Plattform zu Verfügung stehen. Aus diesem Grund ist es nötig die benötigten Klassen zur Abbildung der genutzten Daten selbst zu erstellen und aus einem erhaltenen deserialisirten XML-Objekt zur Laufzeit eine Instanz der passenden Klasse zu erstellen. Das gleiche gilt für das senden von Requests an einen SOAP Serivce, für welchen erst ein Objekt zu XML serialisiert werden muss.

[^ifOS]: Meachanismus in SAP Projekten um plattformspezifischen Code auszuführen
[^IOC]: Inversion Of Control, Alternative zu #if-Syntax für plattformspezifischen Code in PCL Projekten.
[^NuGet]: Packet Verwaltung von Visual Studio 2015.
[^BlankApp]: Ein neues, leeres Projekt für mehrere Zielbetriebssyssteme.

# Eingesetzte Hardware
Zum Entwickeln und Testen der zu erstellenden Cross-Plattform-Applikation ist folgende Hardware zum Einsatz gekommen.

| Gerät           | OS                         | Version         | Zweck                                  |
|-----------------|------------------------|-----------------|----------------------------------------|
| iPhone 5        | iOS                    | 9.3.1           | Testen der App auf iOS                 |
| Asus Nexus 7    | Android                | 6.0 Marshmallow | Testen der App auf Android             |
| Virtual Machine | Win 10 Insider Preview | Build 1511      | Entwickeln & Testen der App auf Win 10 |
| MacBook Pro     | Mac OSX                | ???             | Kompilieren & deployen der App für iOS |

Table: Hardware und Betriebssysteme

# Benötigte Software (APIs, Tools, IDEs, Emulatoren, Simulatoren)

| Software           | Art | Version                | Zweck                                         |
|--------------------|-----|------------------------|-----------------------------------------------|
| Viusal Studio 2015 | IDE | 14.0.25123.00 Update 2 | Entwicklung der Applikation                   |
| Android API        | API | API Level 23           | Benötigt für Deployment auf Android Plattform |
| iOS API            | API | ???                    | Benötigt für Deployment auf iOS Plattform     |

Table: Eingesetzte Software und APIs

# SOAP
Das benötigte Backend zur Erstellung der gewünschten Prototyp-App für die Luftfahrtgesellschaft ist in Form von SOAP[^soap] Services gegeben. Der Zugriff auf die Services erfolgt über das HTTP Protokoll. Diese SOAP Services bieten Operationen zum Austausch von Daten zwischen Anwendung und Datenbasis an. Jede dieser Operationen kann mit einem Request im XML-Format[^xmlFormat] über eine URL angesprochen werden. Dabei kann jede Operationen ein oder mehrere optionale und nicht optionale Übergabeparameter fordern. Ist die gesendete Request syntaktisch und semantisch fehlerfrei, antwortet der SOAP Service mit einem Response (ebenfalls im XML-Format) welcher aus belibigen Attributen bestehen kann. Ist der Request nicht fehlerfrei gewesen, sendet der genutzte SOAP Service entweder einen leeren Fault-Response[^faultResponse] zurück oder einen Fault-Respone mit Informationen, wenn ein semantischer Fehler vorliegt. Der Fault Response welcher durch semantische Fehler ausgelöst wurde, kann Informationen wie eine Fehlermeldung und/oder einen Fehlercode enthalten, falls dieser Fall im SOAP Service definiert ist.

[^xmlFormat]: Extensible Markup Language Format, ist eine Auszeichnungssprache für den plattform- und implementationsunabhängigen Austausch von Daten zwischen Computersystemen [@XML].
[^faultResponse]: XML-Format Respone vom SOAP Service, welcher einen fehler im Request signalisiert.
[^soap]: Simple Object Access Protocol [@SOAP].


- Simple Object Access Protocol
- XML-Format
- Operations
- Request/Response


# Projektarchitektur
- **Data**
    - Enthält Logik zum ansprechen/konsumieren der SOAP Services.
- **Models**
    - Enthält C# Klassen mit Properties für die benötigten Attribute aus validen XML-Objekten für Requests und Responses.
- **Views**
    - Enthält in der die in CrewRest benötigten XAML Pages und deren C# Code-Behind Klassen[^codeBehind]

[^codeBehind]: Einer XAML Page zugehörige C# Klasse um dessen Logik zu implementieren.

# XAML vs. Code
Xamarin.Forms erlaubt das designen von Oberflächen bzw. Pages auf zwei unterschiedliche Arten, entweder die Pages werden via XAML deklarativ entworfen oder aber sie werden in C# erzeugt. Beide Fälle bieten die Möglichkeit jegliche vorhandenen UI-Elemente zu nutzen. XAML nutzt die Auszeichnungssprache XML als Syntax. XAML ist noch vor C# von Microsoft entwickelt worden und kommt schon seit dem Einsatz von Windows Presentation Foundation[^wpf] (WPF) zum Einsatz. Es erlaubt Entwicklern ein Set von UI-Elementen deklarativ, statt programmatisch zu erzeugen. Welche UI-Elemente genutzt werden können, hängt in beiden Fällen immer vom eingsetzten Framework ab. Durch die hierachische Form von XML in XAML, ist es besonders bei komplexen Layouts einfacher das bereits Umgesetzte zu überblicken und zu warten. Grundsätzlich lässt sich durch den Einsatz von XAML zum designen von Pages und C# zur Implementierung der Logik eine klare Trennung zwischen Oberfläche und Anwendungsverhalten schaffen, jedoch ist eine strikte Trennung nicht immer sinnvoll [@MicrosoftXamarinBook, S. 131]. Für die Enwticklung von CrewRest kommt so viel wie Möglich XAML für Designaufgaben zum Einsatz. Des Weiteren lässt sich auch eine gewisse Logik in XAML leichter definieren, z.B. DataTrigger können so bis zu einer gewissen Komplexheit angelegt werden (siehe Kapitel [DataTrigger]).

[^wpf]: Ein von Microsoft angebotenes GUI Framework auf Basis von .NET [@WPF].

# Page Layouts
Xamarin.Forms bietet mit der Subklasse `Layouts` (der Oberklasse `View`) folgende Layouts zum Darstellen von UI-Elementen. In den Layouts können wiederum UI-Elemente vom Typ `Views` wie z.B. Button, InputText oder ListView dargestellt werden oder auch weitere verschachtelte Layouts der Klasse `Layouts`.

![XamarinFormsLayouts](img/xamarin_layouts.png "Xamarin.Forms Layouts")

[@Layouts]

Die in der Grafik [XamarinFormsLayouts](#XamarinFormsLayouts) abgebildeten Layouts unterliegen wiederum einem der in der folgenden Abbildung [XamarinFormsPages](#XamarinFormsPages) dargestellten Anordungsseiten der Klasse `Pages` [@MicrosoftXamarinBook S. 1020]:

![XamarinFormsPages](img/xamarin_pages.png "Xamarin.Forms Pages")

[@Pages]

Die verschiedenen UI-Elemente und Layouts haben jeweils eine Parent-Child-Beziehung[^parentChild], bei welcher der folgende Grundsatz für die Anordungsbeziehung gilt:
"Children have requests, but parents lay down the law." [@MicrosoftXamarinBook S.  1055].

Das in CrewRest am häufigsten verwendete Layout ist das StackLayout, in welchem sich über das Property "Orientation" die Ausrichtung festlegen lässt, "horizontal" oder "vertical". Die im StackLayout liegenden UI-Elemente werden darin entweder horizontal oder vertikal aneinandergreiht.

Im folgenden Beispiel der CrewRest App lässt sich die hierachische Anordnung von UI-Elementen erkennen. Dargestellt ist die Seite `AntraegeUeberischt.xaml`, welche aus einer *MasterDetailPage* mit den einzelnen Abschnitten `<MasterDetailPage.Master>` und `<MasterDetailPage.Detail>` besteht und dessen Ansicht zur Lauftzeit in Form eines Screenshots [AntraegeUeberischt](#AntraegeUeberischt).

```xml
<?xml version="1.0" encoding="utf-8" ?>
<MasterDetailPage xmlns="http://xamarin.com/schemas/2014/forms"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             x:Class="CrewRest.Views.AntraegeUeberischt"
             x:Name="AntraegeUeberischt" Title="Urlaubsanträge">
  <MasterDetailPage.Master>
    <ContentPage Title="Filter">
      <StackLayout Orientation="Vertical">
        <Picker Title="Jahr" x:Name="jahrFilterPicker" SelectedIndexChanged="OnJahrPickerSelectionChanged" />
        <Picker Title="Monat" x:Name="monatFilterPicker" SelectedIndexChanged="OnMonatPickerSelectionChanged" />
        <Picker Title="Status" x:Name="statusFilterPicker" SelectedIndexChanged="OnStatusPickerSelectionChanged" />
        <Button Text="Reset" Clicked="OnFilterResetButtonClicked" />
      </StackLayout>
    </ContentPage>
  </MasterDetailPage.Master>
  <MasterDetailPage.Detail>
    <ContentPage>
      <ContentPage.Padding>
        <OnPlatform x:TypeArguments="Thickness" iOS="0, 20, 0, 0" WinPhone="20,20,20,20" />
      </ContentPage.Padding>
      <StackLayout>
        <ListView x:Name="urlaubsantraegeListeView" BindingContext="{x:Reference Name=AntraegeUeberischt}"
                  ItemTapped="UrlaubsantragItemTapped">
          <ListView.Header>
            <StackLayout Padding="0,0,0,0" />
          </ListView.Header>
          <ListView.Footer>
            <StackLayout Padding="0,0,0,0" />
          </ListView.Footer>
          <ListView.ItemTemplate>
            <DataTemplate x:Name="masterDataTemplate">
              <ViewCell>
                <ContentView>
                  <StackLayout Orientation="Vertical">
                    <StackLayout Orientation="Horizontal">
                      <Label Text="{Binding antragsart}" VerticalOptions="CenterAndExpand" />
                      <Label Text="{Binding antragsstatus}" VerticalOptions="CenterAndExpand" />
                    </StackLayout>
                    <StackLayout Orientation="Horizontal">
                      <Label Text="{Binding beantragtVon, StringFormat='{0:dd.MM.yy}'}" />
                      <Label Text=" - " />
                      <Label Text="{Binding beantragtBis, StringFormat='{0:dd.MM.yy}'}}" />
                    </StackLayout>
                  </StackLayout>
                </ContentView>
              </ViewCell>
            </DataTemplate>
          </ListView.ItemTemplate>
        </ListView>
      </StackLayout>
    </ContentPage>
  </MasterDetailPage.Detail>
</MasterDetailPage>
```

![AntraegeUeberischt](img/antraege_uebersicht.png "Anträge Übersicht Page")

[^parentChild]: hierachische Anordnung von UI-Elemten.

# Wie funktioniert das native Deployment der unterschiedlichen Betriebssysteme/Plattformen
- Windows UWP direkt auf Windows 10
- Android via USB-Debug Mode
- iOS via Remote Login auf Mac OSX und installiertem XCode sowie Xamarin Studio

[@Deployment]

## Android
Um aus einer Xamarin Cross-Plattform App eine Android Applikation zu bauen wird der implementierte C#-Code in Common Intermediate Language[^IL] übersetzt. Anschließend wird mit Hilfe von Mono[^mono] ein Android Package gepackt, welcher mit Hilfe von JIT'ing[^jit] ausgeführt werden kann. Während dieser Prozesse werden ungenutzte Klassen automatisch entfernt um die App zu optimieren.

## iOS
Für das iOS Deployment wird der C#-Code mittels Ahead-of-time-Compiler[^aotc] in ARM Assembly Code übersetzt und anschließend zu einer iOS App gepackt. Auch hier wird während dem Kompiliervorgang dafür gesorgt, dass nicht benötigte Klassen entfernt werden um die Größe der App zu reduzieren.

## Windows 10
Für das Bereitstellen der App auf Windows 10, wird der C#-Code in Common Intermediate Language übersetzt und in der .NET Laufzeitumgebung ausgeführt.

[^jit]: Just-in-time-Kompilierung, Code wird zur Laufzeit in nativen Maschinencode übersetzt. [@JIT]
[^mono]: Open Source Implementierung des .NET Frameworks. [@Mono]
[^IL]: Intermediate Language, eine Zwischensprache in die C# Applikationen übersetzt werden. [@CIL]
[^aotc]: Kompiliert den Code vollständig vor der Ausführung, also nicht zur Laufzeit [@AOTC]

# Implementierung
In den folgenden Abschnitten wird der Zweck der implementierten Komponenten erklärt und es wird auf Details der Implementierung von Komponenten der CrewRest App eingegangen.

```csharp
public void lol(int i) {
private ImageSource bildquelle;
}
```

## SOAP Zugriff
Der Zugriff auf SOAP Services ist für die Anzeige und Erstellung von Daten in  der App CrewRest nötig. Um den Zugriff zu realisieren wird die Klasse `System.Net.Http.HttpClient` genutzt. Diese Klasse ermöglicht den Datenaustausch zwischen App und Diensten auf Basis des HTTP Protokolls zu nutzen.

Um speziell einen SOAP Service zu konsumieren, werden einer Instanz der Klasse `HttpClient` Request Header Informationen bestehend aus *Name* und *SOAP Operationname* zugewiesen. Anschließend wird asynchron eine Http Methode vom Typ POST mit URL und SOAP-XML-Objekt an den SOAP Service gesendet um einen SOAP Response zu erhalten.

```csharp
//...
var client = new System.Net.Http.HttpClient();
client.DefaultRequestHeaders.Add("SOAPAction", soapOperationName);
var content = new System.Net.Http.StringContent(soapString, Encoding.UTF8, "text/xml");
var response = await client.PostAsync(uri, content);
//...
```

Der erhaltene Response wird anschließend auf seinen Status überprüft um zu entscheiden ob ein Fault Response oder der erwartete Response mit den gewünschten Daten vorliegt. Je nach Response Typ muss dieser dann entsprechend geparsed und deserialisiert werden. Dazu wird... klasse xyz benutzt xml geparsed, objektinstanz erstellt usw ???

- HTTPClient
- Aus Objekten XML parsen und SOAP-Request senden
- Aus SOAP-Response XML zu Objekt parsen

## Plattformspezifisches Verhalten in XAML
- XAML OnPlatform Tag
- Probleme durch häufig wechselnde Versionen der verschiedenen Systeme

## Bindings
text

## Updaten von Daten
text

## Anträge ListView
text

## Filtern der Liste
text

## Dynamisches hinzufügen von Komponenten
text

## Validierung von Eingaben
text

### DataTrigger
text

### Behavior
text

## EmbeddedResource
Plattformübergreifendes Anzeigen von Bildern

## Einschränkungen und Probleme bei der Cross-Plattform Entwicklung
- Anfang Probleme beim Darstellen von ListView Details, erst mit Update behoben

# Literatur
