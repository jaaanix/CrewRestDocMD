---
toc: true
lang: de-DE
documentclass: scrreprt
bibliography: literatur.bib
csl: din-1505-2-numeric-alphabetical.csl
mainfont: Charis SIL
#mainfontoptions: BoldFont=Gentium Basic Bold
#mainfontoptions: ItalicFont=Gentium Basic Italic
#mainfontoptions: BoldItalicFont=Gentium Basic Bold Italic
fontsize: 12pt
---

# Erstellung einer Cross-Plattform Applikation
Als Entwicklungsumgebung für die Entwicklung der Apps für Android, iOS und Windows 10 kommt Visual Studio 2015 zum Einsatz. Alternativ kann auch Xamarin Studio eingesetzt werden. Bei der Erstellung eines neuen Cross-Plattform-Projekts, wird zwischen einer *Blank App*[^BlankApp] *Xamarin.Forms Portable* und *Xamarin.Forms Shared* unterschieden.

Im Falle der CrewRest[^CrewRest] Applikation wurde sich aufgrund von höherer Verbreitung von *Xamarin.Forms Portable (Portable Class Library (PCL))* Projekten im Internet, ebenfalls für diese Art von Projekt entschieden. Des Weiteren ist der Unterschied der beiden Projektarten nur marginal, denn in beiden Fällen ist es möglich einmal geschriebenen Code über die verschiedenen Plattformen hinweg zu nutzen.

**Xamarin.Forms Portable (Portable Class Library (PCL))**

Bei einem PCL Projekt, wird der gemeinsame Code in einer Bibliothek zusammengefasst, welche zur Laufzeit von der jeweiligen App referenziert und genutzt wird.

**Xamarin.Forms Shared (Shared Asset Project (SAP))**

Bei einem SAP Projekt, wird der gemeinsame Code jeweils während dem Buildvorgang der jeweiligen Plattform hinzugefügt, also auch speziell für die jeweilige Plattform kompiliert [@MicrosoftXamarinBook S. 29-31].

Eine tabellarische Gegenüberstellung von PCL und SAP Projekten, erstellt von Ken Ross, zeigt noch weitere Unterschiede der beiden Projektarten auf:

|                                                                | PCL   | SAP  |
|----------------------------------------------------------------|-------|------|
| komplettes .NET Framework nutzbar?                             | Nein  | Ja   |
| #if-Syntax[^ifOS] für plattformspezifischen Code nutzbar?      | Nein  | Ja   |
| plattformspezifischer Code benötigt IOC[^IOC]?                 | Ja    | Nein |

Table: Unterschiede zwischen PCL und SAP Projekten
[@PCLvsSAPTable]

\newpage

Ein mögliches Problem bei einem PCL Projekt sind die von Plattform zu Plattform teils unterschiedlich zugrundeliegenden .NET Klassen, z.B. unterscheiden sich die .NET Klassen für Windows 10 Apps teilweise von den .NET Klassen für iOS und Android. Das bedeutet, dass je nach gewünschten Zielplattformen eine eingeschränkte Version des .NET Frameworks genutzt wird. In manchen Fällen bedeutet das aber nicht, dass ein bestimmtes Feature gar nicht genutzt werden kann, gewisse Bibliotheken lassen sich z.B. in Form eines NuGet[^NuGet] Packages nachträglich installieren.

Die Nutzung eines eingeschränkten .NET Frameworks erschwert die Umsetzung der Cross-Plattform Applikation "CrewRest", welche einen SOAP Service (siehe Abschnitt [SOAP als Datenquelle]) konsumiert. Im Falle einer Single-Plattform Applikation mit entsprechendem .NET Framework (ggf. auch mehr als eine Zielplattform) bietet die IDE Visual Studio 2015 einen Mechanismus an, um SOAP Services in Klassen abzubilden. Dieser Mechanismus benötigt eine URL unter der SOAP Services erreichbar sind, um die Daten abbilden bzw. die Klassen generieren zu können, welche die SOAP Services liefern. Der Entwickler muss sich dann nicht mehr um das Parsen[^parsen] von SOAP Requests[^Request] und Responses[^Response] kümmern. Bei der Cross-Plattform Applikation CrewRest ist dies jedoch nicht möglich, da nicht gewährleistet werden kann, dass zur Laufzeit alle benötigten .NET Funktionalitäten auf jeder Plattform zu Verfügung stehen. Aus diesem Grund ist es nötig, die benötigten Klassen zur Abbildung der genutzten Daten selbst zu erstellen und aus einem erhaltenen deserialisierten XML-Objekt zur Laufzeit eine Instanz der passenden Klasse zu erstellen. Das gleiche gilt für das Senden von Requests an einen SOAP Serivce, für welchen erst ein Objekt zu XML serialisiert werden muss.

[^CrewRest]: Name der in diesem Praxisprojekt erstellten Applikation.
[^Response]: Im Kontext dieser Dokumentation eine Antwort eines SOAP-Service.
[^Request]: Im Kontext dieser Dokumentation eine Anfrage an einen SOAP-Service.
[^ifOS]: Mechanismus in SAP Projekten um plattformspezifischen Code auszuführen.
[^IOC]: Inversion Of Control, Alternative zu #if-Syntax für plattformspezifischen Code in PCL Projekten.
[^NuGet]: Packet Verwaltung von Visual Studio 2015.
[^BlankApp]: Ein neues, leeres Projekt für mehrere Ziel-Betriebssysteme.
[^parsen]: Das Umwandeln eines Input-Formats zur Weiterverarbeitung in ein geeignetes Format.

# Eingesetzte Hard- und Software
Zum Entwickeln und Testen der zu erstellenden Cross-Plattform-Applikation ist folgende Hardware zum Einsatz gekommen:

| Gerät           | OS                     | Version            | Zweck                                  |
|-----------------|------------------------|--------------------|----------------------------------------|
| iPhone 5        | iOS                    | 9.3.1              | Testen der App auf iOS                 |
| Asus Nexus 7    | Android                | 6.0 Marshmallow    | Testen der App auf Android             |
| Virtual Machine | Win 10 Insider Preview | Build 1511         | Entwickeln & Testen der App auf Win 10 |
| MacBook Pro     | OSX                    | 10.11.5 El Capitan | Kompilieren & Deployen der App für iOS |

Table: Hardware und Betriebssysteme

Außerdem wurde folgende Software verwendet:

| Software           | Art | Version                | Zweck                                            |
|--------------------|-----|------------------------|--------------------------------------------------|
| Viusal Studio 2015 | IDE | 14.0.25123.00          | Entwicklung der Applikation                      |
| Android API        | API | API Level 23           | Benötigt für Deployment[^deployment] auf Android |
| iOS API            | API | 9.3                    | Benötigt für Deployment auf iOS                  |
| XCode              | IDE | 7.3                    | Benötigt für Deployment auf iOS                  |
| Xamarin Studio     | IDE | 5.1.0                  | Benötigt für Deployment auf iOS                  |

Table: Eingesetzte Software und APIs

[^deployment]: Installieren einer kompilierten Applikation auf einem Zielsystem.

# SOAP als Datenquelle
Das benötigte Backend zur Erstellung der gewünschten Prototyp-App für die Luftfahrtgesellschaft ist in Form von SOAP[^soap] Services gegeben. Der Zugriff auf die Services erfolgt über das HTTP Protokoll. Diese SOAP Services bieten Operationen zum Austausch von Daten zwischen Anwendung und Datenbasis an. Jede dieser Operationen kann mit einem Request im XML-Format[^xmlFormat] über eine URL angesprochen werden. Dabei kann jede Operation ein oder mehrere optionale und nicht optionale Übergabeparameter fordern. Ist die gesendete Request syntaktisch und semantisch fehlerfrei, antwortet der SOAP Service mit einem Response (ebenfalls im XML-Format) welcher aus beliebigen Attributen bestehen kann. Ist der Request nicht fehlerfrei gewesen, sendet der genutzte SOAP Service entweder einen leeren Fault-Response[^faultResponse] zurück oder einen Fault-Respone mit Informationen, wenn ein semantischer Fehler vorliegt. Der Fault Response welcher durch semantische Fehler ausgelöst wurde, kann Informationen wie eine Fehlermeldung und/oder einen Fehlercode enthalten, falls dieser Fall im SOAP Service definiert ist.

[^xmlFormat]: Extensible Markup Language Format, ist eine Auszeichnungssprache für den plattform- und implementationsunabhängigen Austausch von Daten zwischen Computersystemen [@XML].
[^faultResponse]: XML-Format Respone vom SOAP Service, welcher einen fehler im Request signalisiert.
[^soap]: Simple Object Access Protocol [@SOAP].

# Projekt- und Verzeichnisstruktur
Um im Softwareprojekt einen gewissen Grad von Modularität zu gewährleisten und von Grund auf verschiedene Softwarekontexte voneinander zu trennen, sind im PCL-Projekt mehrere Verzeichnisse angelegt worden.

- **Data**
    - Enthält C#-Code Logik zum ansprechen/konsumieren der SOAP Services, ermöglicht also das Empfangen und Senden von Request und Response.
- **Models**
    - Enthält C# Klassen mit Properties zum Abbilden von verwendeten Daten, welche aus den SOAP-Services erhalten werden. Nach dem Parsen der jeweiligen XML-Objekte, werden Instanzen der passenden Model-Klassen erzeugt.
- **Views**
    - Enthält die in CrewRest benötigten XAML-Pages und deren C# Code-Behind Klassen[^codeBehind] in denen die Logik der jeweiligen Page liegt.
    - Bei der Erstellung einer neuen Page entstehen also immer zwei Dateien, zum Beispiel: `Page1.xaml` und `Page1.xaml.cs`.

All diese Verzeichnisse liegen (wie in Abbildung [ProjektmappenExplorer](#ProjektmappenExplorer) zu sehen) im *Shared Project* "CrewRest (Portable)" der Anwendung und werden von den einzelnen Plattformen genutzt.

\begin{figure}[h]
    \centering
    \includegraphics[width=0.3\textwidth]{img/projektmappen_eaxplorer.png}
    \caption{Projektmappen-Explorer}
\end{figure}

[^codeBehind]: Einer XAML Page zugehörige C# Klasse um dessen Logik zu implementieren.

# XAML vs. Code
Xamarin.Forms erlaubt das Entwerfen von Oberflächen auf zwei unterschiedliche Arten, entweder die Pages werden via XML auf einer XAML-Page deklarativ angelegt oder aber sie werden in C# erzeugt. Beide Fälle bieten die Möglichkeit jegliche vorhandenen UI-Elemente zu nutzen. XAML nutzt die Auszeichnungssprache XML als Syntax. XAML ist noch vor C# von Microsoft entwickelt worden und kommt schon seit dem Einsatz von Windows Presentation Foundation[^wpf] (WPF) zum Einsatz. Es erlaubt Entwicklern ein Set von UI-Elementen deklarativ, statt programmatisch zu erzeugen. Welche UI-Elemente genutzt werden können, hängt in beiden Fällen immer vom eingesetzten Framework ab. Durch die hierarchische Form von XML in XAML, ist es besonders bei komplexen Layouts einfacher das bereits Umgesetzte zu überblicken und zu warten. Grundsätzlich lässt sich durch den Einsatz von XAML zum Designen von Pages und C# zur Implementierung der Logik eine klare Trennung zwischen Oberfläche und Anwendungsverhalten schaffen, jedoch ist eine strikte Trennung nicht immer sinnvoll [@MicrosoftXamarinBook, S. 131]. Für die Entwicklung von CrewRest kommt so oft wie Möglich XAML für Designaufgaben zum Einsatz. Des Weiteren lässt sich auch eine gewisse Logik in XAML leichter definieren, z.B. ein DataTrigger kann so leichter erstellt werden (siehe Abschnitt [Trigger in CrewRest]).

\newpage

Die folgenden Code-Ausschnitte zeigen beispielhaft die Erstellung eines Buttons mit jeweils den gleichen Attributen in XML (XAML) und C# (Code):

**Button in XML**
```xml
<Button Text="Hello"
    Clicked="OnHelloBtnClicked"
    VerticalOptions="Center"
    HorizontalOptions="CenterAndExpand">
<!-- ... -->
</Button>
```

**Xamarin Button in C#**
```{#XamarinButtonInCode .cs .numberLines startFrom="1"}
// Normale Form
Button helloBtn = new Button();
helloBtn.Text = "Hello";
helloBtn.VerticalOptions = LayoutOptions.Center;
helloBtn.HorizontalOptions = LayoutOptions.CenterAndExpand;
helloBtn.Clicked += OnHelloBtnClicked(...);

// Etwas kuerzere Form
Button helloBtn = new Button() {
    Text = "Hello",
    VerticalOptions = LayoutOptions.Center,
    HorizontalOptions = LayoutOptions.CenterAndExpand };
helloBtn.Clicked += OnHelloBtnClicked(...);
```

[^wpf]: Ein von Microsoft angebotenes GUI Framework auf Basis von .NET [@WPF].

# Page Layouts
Xamarin.Forms bietet mit der Subklasse `Layouts` (der Oberklasse `View`) folgende Layouts zum Darstellen von UI-Elementen. In den Layouts können wiederum UI-Elemente vom Typ `Views` wie z.B. Button, InputText oder ListView dargestellt werden oder auch weitere verschachtelte Layouts der Klasse `Layouts`.

\begin{figure}[h]
    \centering
    \includegraphics[width=0.8\textwidth]{img/xamarin_layouts.png}
    \caption{Xamarin.Forms Layouts}
\end{figure}
[@Layouts]

Die in der Grafik [Xamarin.Forms Layouts](#Xamarin.Forms Layouts) abgebildeten Layouts unterliegen wiederum einem der in der folgenden Abbildung [Xamarin.Forms Pages](#Xamarin.Forms Pages) dargestellten Anordnungsseiten der Klasse `Pages` [@MicrosoftXamarinBook S. 1020]:

\newpage

\begin{figure}[h]
    \centering
    \includegraphics[width=1.0\textwidth]{img/xamarin_pages.png}
    \caption{Xamarin.Forms Pages}
\end{figure}
[@Pages]

Die verschiedenen UI-Elemente und Layouts haben jeweils eine Parent-Child-Beziehung[^parentChild], bei welcher der folgende Grundsatz für die Anordnungsbeziehung gilt:
"Children have requests, but parents lay down the law." [@MicrosoftXamarinBook S.  1055].

Das in CrewRest am häufigsten verwendete Layout ist das StackLayout, in welchem sich über das Property "Orientation" die Ausrichtung festlegen lässt, "horizontal" oder "vertical". Die im StackLayout liegenden UI-Elemente werden darin entweder horizontal oder vertikal aneinandergereiht.

Im folgenden Beispiel der CrewRest App lässt sich die hierarchische Anordnung von UI-Elementen erkennen. Dargestellt ist ein gekürzter Ausschnitt des XML-Codes der Seite `AntraegeUeberischt.xaml`, welche aus einer *MasterDetailPage* mit den einzelnen Abschnitten `<MasterDetailPage.Master>` und `<MasterDetailPage.Detail>` besteht. Die aus der XAML-Page resultierende Ansicht zur Laufzeit ist im Screenshot [Antraege Ueberischt unter Win 10](#AntraegeUeberischt) zu sehen.

\begin{figure}[h]
    \centering
    \includegraphics[width=0.7\textwidth]{img/antraege_uebersicht.png}
    \caption{Antraege Ueberischt unter Win 10}
\end{figure}

\newpage

**AntraegeUeberischt.xaml Page**
```xml
<?xml version="1.0" encoding="utf-8" ?>
<MasterDetailPage>
  <MasterDetailPage.Master>
    <ContentPage Title="Filter">
      <StackLayout Orientation="Vertical">
        <Picker Title="Jahr" x:Name="jahrFilterPicker"
                SelectedIndexChanged="OnJahrPickerSelectionChanged" />
        <!-- weitere UI-Elemente... -->
      </StackLayout>
    </ContentPage>
  </MasterDetailPage.Master>
  <MasterDetailPage.Detail>
    <ContentPage>
     <!-- weitere UI-Elemente... -->
      <StackLayout>
        <ListView>
          <ListView.Header>
          <ListView.ItemTemplate>
            <DataTemplate x:Name="masterDataTemplate">
              <ViewCell>
                <ContentView>
                  <StackLayout Orientation="Vertical">
                    <StackLayout Orientation="Horizontal">
                      <Label Text="{Binding antragsart}"
                             VerticalOptions="CenterAndExpand" />
                      <!-- weitere UI-Elemente... -->
                    </StackLayout>
                    <StackLayout Orientation="Horizontal">
                      <Label Text="{Binding beantragtVon,
                                    StringFormat='{0:dd.MM.yy}'}" />
                      <!-- weitere UI-Elemente... -->
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
\newpage

[^parentChild]: hierarchische Anordnung von UI-Elemten.

# Deployen der App für die unterschiedlichen Plattformen
Um die App auf den verschiedenen Plattformen zu installieren, sind je nach Betriebssystem andere Schritte, sowie unterschiedliche Hard- und Software nötig. Besonders unter iOS gestaltet sich der Deployment-Prozess auf ein echtes Gerät aufwendig, da ein Apple Developer Account angelegt und konfiguriert werden muss. Im Folgenden wird der Vorgang des Xamarin Frameworks um eine App vorzubereiten und zu deployen für die jeweilige Plattform genauer erklärt.  

## Android
![Android Deployment](img/android_deployment.pdf)

Um aus einer Xamarin Cross-Plattform-App eine Android Applikation zu bauen, wird der implementierte C#-Code in Common Intermediate Language[^IL] übersetzt. Anschließend wird mit Hilfe von Mono[^mono] ein Android Package gepackt, welches mit Hilfe von JIT'ing[^jit] ausgeführt werden kann. Während dieser Prozesse werden ungenutzte Klassen automatisch entfernt, um die App zu optimieren [@Deployment].

Für die technische Umsetzung wird das Android Tablet im USB-Debug-Mode via USB mit dem Windows 10 verbunden wodurch ein direktes Deployment auf dem Gerät aus der Entwicklungsumgebung heraus möglich ist.

## iOS
![iOS Deployment](img/ios_deployment.pdf)

Für das iOS Deployment wird der C#-Code mittels Ahead-of-time-Compiler[^aotc] in ARM Assembly Code übersetzt und anschließend zu einer iOS App gepackt. Auch hier wird während dem Kompiliervorgang dafür gesorgt, dass nicht benötigte Klassen entfernt werden, um die Größe der App zu reduzieren [@Deployment].

Für ein Deplyoment muss außerdem der Windows 10 PC via Remote Login mit dem Mac OSX Gerät mit installiertem XCode sowie Xamarin Studio verbunden sein.

## Windows 10
![Windows 10 Deployment](img/windows10_deployment.pdf)

Für das Bereitstellen der App auf Windows 10, wird der C#-Code in Common Intermediate Language übersetzt und in der .NET Laufzeitumgebung ausgeführt [@Deployment].

[^jit]: Just-in-time-Kompilierung, Code wird zur Laufzeit in nativen Maschinencode übersetzt. [@JIT]
[^mono]: Open Source Implementierung des .NET Frameworks. [@Mono]
[^IL]: Intermediate Language, eine Zwischensprache in die C# Applikationen übersetzt werden. [@CIL]
[^aotc]: Kompiliert den Code vollständig vor der Ausführung, also nicht zur Laufzeit. [@AOTC]

# Implementierung
In den folgenden Abschnitten wird der Zweck der implementierten Komponenten erklärt und es wird auf Details der Implementierung von Komponenten der CrewRest App eingegangen.

## SOAP Zugriff - XML Parsing - (De)serialisieren
Der Zugriff auf SOAP Services ist für die Anzeige und Erstellung von Daten in  der App CrewRest nötig. Um den Zugriff zu realisieren, wird die Klasse `System.Net.Http.HttpClient` genutzt. Diese Klasse ermöglicht den Datenaustausch zwischen App und Diensten auf Basis des HTTP Protokolls zu nutzen.

Um speziell einen SOAP Service zu konsumieren, werden einer Instanz der Klasse `HttpClient` Request Header Informationen bestehend aus *Name* und *SOAP Operationname* zugewiesen. Anschließend wird asynchron eine HTTP Methode vom Typ POST mit URL und einem `string` im vom Service erwarteten XML-Format an den SOAP Service gesendet (der Request) um einen SOAP Response zu erhalten.

**SOAP Http Client Zugriff in C#**
```{#SOAPHttpClientZugriff .cs .numberLines startFrom="1"}
//...
var client = new System.Net.Http.HttpClient();
client.DefaultRequestHeaders.Add("SOAPAction", soapOperationName);
var content =
    new System.Net.Http.StringContent(soapString,Encoding.UTF8,"text/xml");
var response = await client.PostAsync(uri, content);
//...
```

Der erhaltene Response wird anschließend auf seinen Status überprüft, um zu entscheiden ob ein Fault Response oder der erwartete Response mit den gewünschten Daten vorliegt. Je nach Response Typ muss dieser dann entsprechend geparsed und anschließend deserialisiert werden. Dazu werden .NET Framework Klassen `XDocument`, `XNamespace` und `XmlSerializer` genutzt.

Aus dem erhaltenen Response vom Typ `string` wird mit Hilfe der statischen Methode `Parse` der Klasse `XDocument` ein automatisches parsing durchgeführt. Anschließend werden die vom SOAP Service definierten Namespaces abgefragt und gespeichert. Nun kann der eigentliche Inhalt, also die gewünschten Informationen aus dem Response gefiltert werden, da die SOAP Serivce Metadaten mit Hilfe der zuvor abgefragten Namespaces lokalisiert und entfernt werden können. Aus dem erhaltenen, gefilterten `string` wird schließlich ein durch deserialisieren ein Objekt der passenden Klassen erzeugt.

**SOAP Response Parsing in C#**
```{#SoapResponseParsing .cs .numberLines startFrom="1"}
// parsen des string SOAP Responses
var xmlContent = XDocument.Parse(response);
XNamespace soap =
        XNamespace.Get("http://schemas.xmlsoap.org/soap/envelope/");
XNamespace ns2 =
        XNamespace.Get("http://www.dlh.de/clh/Urlaub_V01");
// entfernen des SOAP Headers
// um anschliessend den reinen
// Inhalt deserialisieren zu koennen
var responseXML = xmlContent.
    Element(soap + "Envelope").
    Element(soap + "Body").
    Element(ns2 + responseType).
    Elements("urlaubsantrag");
XmlSerializer serializer = new XmlSerializer(typeof(urlaubsantrag));

// Erstellen einer Liste von Urlaubsantraegen
ObservableCollection<urlaubsantrag> urlaubsantraege =
    new ObservableCollection<urlaubsantrag>();
for (int i = 0; i < responseXML.Count(); i++)
{
    // Deserialisieren des XMLs und Erstellen eines Urlaubsantrages
    urlaubsantraege.Add((urlaubsantrag)serializer.Deserialize(
        responseXML.ElementAt(i).CreateReader())
        );
}
return urlaubsantraege;
```

Um einen Request an den SOAP Service im XML-Format senden zu können, wird ein analoges Verfahren angewendet, wobei in diesem Fall kein erhaltener Response deserialisiert wird sondern ein von der App erzeugtes Objekt (z.B. einen Urlaubsantrag) serialisiert wird.

\newpage

## Plattformspezifisches Verhalten via XAML Konfigurieren
In manchen Fällen ist ein plattformspezifisches Verhalten der App unumgänglich. Ein Beispiel dafür ist das Top-Padding[^TopPadding] unter iOS. Wird das Top-Padding nicht gezielt eingestellt, werden die am oberen Rand angezeigten UI-Elemente teilweise von der Statusleiste des Betriebssystems verdeckt. Konkret bedeutet das, dass unter iOS UI-Elemente von z.B. der Uhrzeit- oder Empfangsanzeige verdeckt werden.

Xamarin bietet eine einfache Möglichkeit solche plattformabhängigen Anzeigeeinstellungen mit dem XAML-Tag <OnPlatform> zu festzulegen. Im folgenden Beispiel ist ein Padding für eine Seite vom Typ `ContentPage` festgelegt. Konfiguriert ist ein Top-Padding von 20px für iOS und ein Padding von 20px für alle Seiten auf Windows Phone 8.1. Die Abbildung [On Platform Padding auf iOS](#On Platform Padding iOS) zeigt einen Vergleich mit (grün markiert) und ohne (rot markiert) Top-Padding in der CrewRest App.

**Plattformspezifisches Padding in XML**
```xml
<ContentPage>
  <ContentPage.Padding>
    <OnPlatform x:TypeArguments="Thickness"
                iOS="0, 20, 0, 0"
                WinPhone="20,20,20,20" />
  </ContentPage.Padding>
  <!-- weitere UI-Elemente... -->
</ContentPage>
```

![On Platform Padding auf iOS](img/on_platform_padding_ios.png)

[^TopPadding]: Der Abstand von UI-Elementen vom oberen Bildrand.

\newpage

## Data Bindings
Ein Data Binding stellt in Xamarin eine Beziehungen zwischen Properties von zwei Objekten dar, was in den meisten Fällen die Beziehungen zwischen einer UI-Komponente (z.B. ein TextLabel) und Daten-Objekten definiert. Dieser Mechanismus bewirkt, dass ein Objekt durch ein Event eine Änderung des verbundenen Objekts erfährt. Es wird hier von der Verbindung zwischen Properties von zwei Objekten gesprochen, weil auch eine UI-Komponente, die auf einer XAML-Page angelegt wird zur Laufzeit der App ein Objekt ist [@DataBindings].

Ein gutes Beispiel für ein sogenanntes View-to-View Binding[^ViewToView] liefert der Xamarin Online Guide. Im diesem Beispiel handelt es sich um zwei UI-Elemente (ein Label und ein Schieberegler) welche teilweise voneinander abhängige Eigenschaften (Properties) besitzen. Die Eigenschaft `Rotation` des Labels ist an die Eigenschaft `Value` des Sliders gebunden. Wird nun der Wert der Sliders durch den Benutzer geändert, dreht sich das Label entsprechend. Wichtig ist ebenfalls das Festlegen der Eigenschaft `BindingContext` mit dem Wert `x:Reference...` was einen Verweis auf die Instanz der angezeigten Page darstellt und auf die Eigenschaft `x:Name` des Sliders verweist.

**View-to-View Binding Code**
```xml
<Label Text="ROTATION"
           BindingContext="{x:Reference Name=slider}"
           Rotation="{Binding Path=Value}"
           FontAttributes="Bold"
           FontSize="Large"
           HorizontalOptions="Center"
           VerticalOptions="CenterAndExpand" />

<Slider x:Name="slider"
           Maximum="360"
           VerticalOptions="CenterAndExpand" />
```

Nach dem gleichen Prinzip lässt sich ein Data Binding auch für ein C# Property der jeweiligen Code-Behind Klasse der jeweiligen Page definieren. Im Fall der Liste mit Urlaubsanträgen in CrewRest ist dieser Mechanismus umgesetzt. Zu diesem Zweck ist die Collection `urlaubsantraegeListe` vom Typ `ObservableCollection<urlaubsantrag>`, gefüllt mit den Urlaubsanträgen, über das Property `ItemsSource` an die ListView Komponente gebunden:
`urlaubsantraegeListeView.ItemsSource = urlaubsantraegeListe;`
Durch diese Zuweisung ist es wiederum möglich direkt auf der XAML-Page auf die Attribute der Collection zuzugreifen. Im folgenden XAML-Page Ausschnitt ist der Zugriff auf die einzelnen Attribute *antragsart*, *antragsstatus*, *beantragtVon* und *beantragtBis* zu sehen.

\newpage

**DataBinding in XML Beispiel in CrewRest**
```xml
<ListView x:Name="urlaubsantraegeListeView"
            BindingContext="{x:Reference Name=AntraegeUeberischt}"
            ItemTapped="UrlaubsantragItemTapped">
<!-- weitere ListView Parameter -->
  <ListView.ItemTemplate>
    <DataTemplate x:Name="masterDataTemplate">
      <ViewCell>
        <ContentView>
          <StackLayout Orientation="Vertical">
            <StackLayout Orientation="Horizontal">
              <Label Text="{Binding antragsart}"
                  VerticalOptions="CenterAndExpand" />
              <Label Text="{Binding antragsstatus}"
                  VerticalOptions="CenterAndExpand" />
            </StackLayout>
            <StackLayout Orientation="Horizontal">
              <Label Text="{Binding beantragtVon,
                  StringFormat='{0:dd.MM.yy}'}" />
              <Label Text=" - " />
              <Label Text="{Binding beantragtBis,
                  StringFormat='{0:dd.MM.yy}'}}" />
            </StackLayout>
          </StackLayout>
        </ContentView>
      </ViewCell>
    </DataTemplate>
  </ListView.ItemTemplate>
</ListView>
```

[^ViewToView]: Binding zwischen zwei UI-Komponenten auf derselben Page.

\newpage

### Aktualisieren von Daten im User Interface
Um eine UI-Komponente zu aktualisieren wenn ihr Wert an ein Property im Code-Behind gebunden ist, ist es nötig das Getter und Setter für das gebundene Property implementiert sind.

**UI Update in C#**
```{#UpdateUIData .cs .numberLines startFrom="1"}
private string meinText;
public string MeinText
{
    set
    {
        if (meinText != value) { // impliziter Parameter 'value'
            meinText = value;
            OnPropertyChanged("MeinText");
        }
    }
    get {
        return meinText;
    }
}
```

Ist das Binding einer UI-Komponente wie der ListView in CrewRest an eine Collection vom Typ `ObservableCollection<T>` gebunden, ist es nicht nötig das Updaten der angezeigten Daten durch Getter und Setter zu forcieren. Die Klasse `ObservableCollection<T>` implementiert das Interface `INotifyCollectionChanged`. Ist dieses Interface implementiert, feuert die Collection bei jedem Hinzufügen oder Entfernen von Items (Einträgen) der Collection ein `CollectionChanged` Event. Die ListView in Xamarin ist so implementiert, dass sie sich im Falle eines `CollectionChanged` Events automatisch aktualisiert [@MicrosoftXamarinBook, S.551-552].

## Filtern der Urlaubsanträge Liste
Die Urlaubsanträge Liste zeigt dem User standardmäßig alle Urlaubsanträge eines bestimmten Jahres. Des Weiteren bietet die App die Möglichkeit die angezeigten Urlaubsanträge nach Monat (1-12) und Status (*beantragt, geloescht, genehmigt, abgelehnt*) zu filtern. Die Ausgewählten Werte der drei Filter werden mit einer AND-Beziehung kombiniert.

### Das Filtern nach Jahren
Um die Urlaubsanträge eines bestimmten Jahres in CrewRest anzuzeigen, werden im Gegensatz zu den Filtern für Monat und Status keine vorhandenen Daten gefiltert, sondern es wird ein neuer SOAP-Request an den entsprechenden Service gesendet. Das hat den Grund, dass die genutzte SOAP-Operation des Services die Parameter *TLC* und *JAHR* benötigt, um einen Urlaubsanträge Response zu erhalten. Das heißt es können immer nur Urlaubsanträge eines gesamten Jahres erhalten werden.

### Das Filtern nach Monat und Status
Wird ein Monat oder Status ausgewählt, wird dem jeweiligen Property (FilterMonat oder FilterStatus) der gewählte Wert der Auswahlliste zugewiesen. Anschließend wird die eigentliche Filterung durch die Methode `urlaubsantraegeFiltern` ausgeführt. Die Methode `urlaubsantraegeFiltern` speichert dann alle gefilterten Urlaubsanträge in eine neue Liste vom Typ `List<urlaubsantrag>`, welche schließlich dem `ItemSource` Property des ListView UI-Elements zugewiesen wird, um die gefilterten Urlaubsanträge anzuzeigen.

Der Button "Reset" setzt die Indizes der Auswahllisten zurück und setzt die das `ItemSource` Property der ListView Komponente wieder auf die ungefilterte Collection zurück. Die Liste wird dann wieder ungefiltert angezeigt.

**Antäge Filter in C#**
```{#UrlaubsantraegeFilter .cs .numberLines startFrom="1"}
void OnMonatPickerSelectionChanged(object sender, EventArgs args)
{
    Picker picker = (Picker)sender;
    int selectedIndex = picker.SelectedIndex;
    string selectedItem =
        selectedIndex != -1 ? picker.Items[selectedIndex] : null;
    FilterMonat = selectedItem;
    urlaubsantraegeFiltern();
}

void OnStatusPickerSelectionChanged(object sender, EventArgs args)
{
    Picker picker = (Picker)sender;
    int selectedIndex = picker.SelectedIndex;
    string selectedItem =
        selectedIndex != -1 ? picker.Items[selectedIndex] : null;
    FilterStatus = selectedItem;
    urlaubsantraegeFiltern();
}

/// <summary>
/// Filtert die angezeigten Urlaubsantraege basierend auf
/// Status und Monat Filtern in AND-Kombination
/// </summary>
void urlaubsantraegeFiltern()
{
    List<urlaubsantrag> _gefilterteUrlaubsantraege =
            new List<urlaubsantrag>();
    foreach (urlaubsantrag antrag in urlaubsantraegeListe.ToList())
    {
        if ((antrag.antragsstatus == FilterStatus ||
            FilterStatus == null) &&
            (antrag.beantragtVon.Month.ToString() ==
                FilterMonat || FilterMonat == null) &&
            (antrag.beantragtBis.Month.ToString() ==
                FilterMonat || FilterMonat == null))
        {
            _gefilterteUrlaubsantraege.Add(antrag);
        }
    }
    urlaubsantraegeListeView.ItemsSource = _gefilterteUrlaubsantraege;
}
```

Die folgende Abbildung [Urlaubsanträge gefiltert nach Monat](#Urlaubsanträge gefiltert nach Monat) zeigt die CrewRest App auf Android mit den Urlaubsanträgen aus 2013 gefiltert nach Monat Mai, aus der Sicht eines bestimmten Mitarbeiters.

\begin{figure}[h]
    \centering
    \includegraphics[width=0.8\textwidth]{img/antraege_filter_monat.png}
    \caption{Urlaubsanträge gefiltert nach Monat}
\end{figure}

## Dynamisches hinzufügen von Komponenten
Die Page[^Page] "AntraegeHinzufuegen" der CrewRest App besteht zu einem großen Teil aus dynamischen UI-Komponenten, d.h. sie beinhaltet viele Komponenten die nur unter bestimmten Voraussetzungen anzuzeigen sind. In diesem Fall ist es nötig die betroffenen Komponenten im Code-Behind der entsprechend Page anzulegen. Um sich trotz der dynamischen Komponenten nicht mit deren Anordnung auseinandersetzen zu müssen, ist es sinnvoll die statischen Komponenten und Layouts vorher auf der XAML-Page zu definieren.

Für diese Anforderung ist eine XAML-Page mit einer `<TableView>` Komponente angelegt, welche wiederum `<TableSection>` Elemente beinhaltet. Jeder dieser Abschnitte in der `<TableView>` besitzt einen Identifier und wird aus dem Code-Behind angesprochen, um während der Laufzeit von CrewRest UI-Elemente hinzuzufügen oder zu entfernen.

Es folgt ein kurzer Ausschnitt der XAML-Page sowie des Code-Behind, um die Beziehung zwischen XAML-Page und Code-Behind zu verdeutlichen.

In folgendem XML Code ist der `<TableView>` Abschnitt mit dem Identifier "variabelTableSection" definiert. Des Weiteren sind auch Identifier für die Komponenten `ViewCell` und `StackLayout` definiert, welche in der C# Methode `VariabelSwitchCell_OnChanged(...)` genutzt werden um UI-Komponenten basierend auf der Benutzereingabe hinzuzufügen bzw. zu entfernen.

**TableView mit Identifiern in XML**
```xml
<TableSection x:Name="variabelTableSection">
    <ViewCell x:Name="wunschStartdatumCell">
        <StackLayout x:Name="wunschStartdatumStack"
                     Orientation="Horizontal">
            <StackLayout.Padding>
                <OnPlatform x:TypeArguments="Thickness"
                    iOS="15, 0, 0, 0"
                    Android="15, 0, 0, 0"/>
            </StackLayout.Padding>
        </StackLayout>
    </ViewCell>
</TableSection>
```

**Dynmaische Erstellung von UI-Elementen in C#**
```{#DynamicUIComponent .cs .numberLines startFrom="1"}
private void VariabelSwitchCell_OnChanged(object sender, ToggledEventArgs e)
{
    if (e.Value == true)
    {
        variabelTableSection.Title = "Variabler Zeitraum";
        // UI-Elemente fuer Variablen Urlaubsantrag anzeigen
        anzahlTageEntry = new EntryCell() {
            Label = "Anzahl Tage",
            Keyboard = Keyboard.Numeric };
        minAnzahlTageEntry = new EntryCell() {
            Label = "mindestens",
            Keyboard = Keyboard.Numeric };
        Label wunschStartdatumLabel = new Label() {
            Text = "Wunsch Startdatum",
            VerticalOptions = LayoutOptions.Center,
            HorizontalOptions = LayoutOptions.StartAndExpand };
        wunschStartdatumDatePicker = new DatePicker();
        wunschStartdatumDatePicker.DateSelected += compareVonBis;
        wunschStartdatumStack.Children.Add(wunschStartdatumLabel);
        wunschStartdatumStack.Children.Add(wunschStartdatumDatePicker);
        wunschStartdatumCell.View = wunschStartdatumStack;
        variabelTableSection.Add(anzahlTageEntry);
        variabelTableSection.Add(minAnzahlTageEntry);
    }
    else if (e.Value == false)
    {
        // UI-Elemente und Titel der TableSection entfernen
        variabelTableSection.Clear();
        variabelTableSection.Title = "";
    }

}
```
[^Page]: Die Ansicht einer Seite in der CrewRest App.

## Dynamisches UI Verhalten und Validierung von Eingaben
In CrewRest werden "Trigger" und "Behavior" zur Sicherstellung korrekter Eingaben eingesetzt. Trigger haben grundsätzlich die Aufgabe Änderungen in der UI zu bewirken, wenn sich ein Property Wert ändert oder ein bestimmtes Event ausgelöst wird [@MicrosoftXamarinBook, S. 835 - 836]. Ein häufiger Anwendungsfall für einen solchen Mechanismus ist das Aktivieren und Deaktivieren von Button oder anderen UI-Elementen, basierend auf einer Eingabe oder Auswahl eines Benutzers. Xamarin bietet vier Arten von Triggern an, welche sowohl deklarativ in XAML definiert werden können, als auch programmatisch in C#. Die möglichen Trigger Arten und deren Zweck sind folgende:

\newpage

- Trigger
    - zum Setzen von Properties bei Änderung eines anderen Property
- EventTrigger
    - zum Ausführen von Code in Abhängigkeit von einem Event
- DataTrigger
    - zum Setzen von Properties bei Änderung eines gebundenen Property (DataBinding)
    - *unterscheidet sich von den Anderen Trigger Arten, da hier ein Property eines anderen Objektes "überwacht" wird* [@MicrosoftXamarinBook, S. 853]
- MultiTrigger
    - zum Setzen einer Properties bei Änderung einer Menge von anderen Properties

[@MicrosoftXamarinBook, S. 836]

Behaviors unterscheiden sich von Triggern durch ihre erweiterte Funktionalität. Ein Behavior kann alles was auch ein Trigger kann. Ein Behavior benötigt im Gegensatz zu Triggern aber immer eine programmatische Implementierung in C#. Ist die Umsetzung eines dynamischen UI Verhaltens oder einer Restriktion also mit einem Trigger möglich, wird empfohlen auch einen Trigger statt eines Behaviors zu nutzen [@MicrosoftXamarinBook, S. 868].

### Trigger in CrewRest
In CrewRest ist ein DataTrigger angelegt, um beim Hinzufügen von Urlaubsanträgen nur dann das Speichern via *Speichern*-Button zu erlauben, wenn alle Pflichtfelder ausgefüllt sind. Dazu hat der im Button integrierte DataTrigger eine Referenz auf die Textlänge eines Eingabefelds (in diesem Fall auf das Kommentarfeld) und ein Property `Value` mit dem Wert 0. Außerdem einen Setter, welcher die Aktion festlegt wenn der definierte Fall (Textlänge = 0) eintritt. Der `Setter` bewirkt also das Setzen des `IsEnabled` Property des Button auf `False` wenn das Eingabefeld für *Kommentar* leer ist.

```{caption="CrewRest DataTrigger" .xml}
<!-- ... -->
<EntryCell x:Name="kommentarExtEC" Label="Kommentar" />
<!-- ... -->
<Button Text="Speichern" Clicked="OnSpeichernBtnClicked">
  <Button.Triggers>
    <DataTrigger TargetType="Button"
     Binding="{Binding Source={x:Reference kommentarExtEC},
               Path=Text.Length}"
     Value="0">
      <Setter Property="IsEnabled" Value="False" />
    </DataTrigger>
  </Button.Triggers>
</Button>
<!-- ... -->
```

### Behavior in CrewRest
In CrewRest ist ein Behavior zum Validieren von Datumseingaben implementiert. Ist eine Datumsauswahl erfolgt, wird überprüft ob Datum ein bereits vergangenes ist oder ob das "von Datum" hinter dem "bis Datum" liegt. Trifft eine dieser Bedingungen zu, wird die Hintergrundfarbe des Datumeingabefelds auf Orange oder Rot gesetzt. Die Validation erfolgt in einer extra dafür angelegten Klasse `AntragszeitraumValidator` die die generische Klasse `Behavior<DatePicker>` erweitert, um ein UI-Element vom Typ `DatePicker` prüfen zu können. Die überschriebene Methode `OnAttachedTo(BindableObject)` verweist dann auf die Methode `HandleDateChanged(...)` und übergibt das BindableObject[^BindableObject](die DatePicker Komponente) um die eigentliche Validierungslogik aufzurufen. Um der UI-Komponente *vonDatePicker* vom Typ `DatePicker` ein Behavior zuzuweisen, wird der Name der Klasse über den XML-Tag `<DatePicker.Behaviors>` angegeben. Das Prefix `local` beinhaltet den Namespace in welchem sich die Klasse `AntragszeitraumValidator` befindet und wird im Header der XAML-Page angegeben.

**Behavior in XML**
```xml
<DatePicker x:Name="vonDatePicker" DateSelected="compareVonBis">
    <DatePicker.Behaviors>
        <local:AntragszeitraumValidator/>
    </DatePicker.Behaviors>
</DatePicker>
```

**Datumsauswahl Behavior in C#**
```{#DatePickerBehavior .cs .numberLines startFrom="1"}
void HandleDateChanged(object sender, DateChangedEventArgs e)
        {
            if (((DatePicker)sender).BackgroundColor == Color.Red)
                return;
            else if (e.NewDate < DateTime.Today)
                ((DatePicker)sender).BackgroundColor =
                        Color.FromHex("FFA500");
            else
                ((DatePicker)sender).BackgroundColor =
                        Color.Default;
        }
```

[^BindableObject]: Objekt welches die Zuweisung eines Data Bindings ermöglicht (z.B. eine Xamarin UI-Komponente) [@MicrosoftXamarinBook, S. 234].

## Hinzufügen von EmbeddedResources zum Anzeigen von Bildern
Um in einer Xamarin App ein Bild anzuzeigen wird die `Image` Komponente genutzt. Diese Komponente besitzt das Property `Source`, welcher ein Objekt vom Typ `ImageSource` zugewisen wird, um die Quelle des anzuzeigendes Bilds festzulegen. Eine Bild kann aus verschiedene Quellen eingebunden werden, dazu bietet die Klasse `ImageSource` vier unterschiedliche statische Methoden an [@MicrosoftXamarinBook, S. 283]:

- `FromUri`
    - um ein Bild aus dem Web zu laden und anzuzeigen
- `FromResource`
    - um ein Bild anzuzeigen welches als EmbeddedResource[^EmbeddedResource] in der PCL abgelegt ist
- `FromFile`
    - um ein Bild aus dem jeweiligen gespeichert auf der jeweiligen Plattform anzuzeigen
- `FromStream`
    - um ein Bild erhalten aus einem `Stream` Objekt des .NET Framewoks anzuzeigen

In CrewRest werden Bilderquellen über die Methode `FromResource` festgelegt. Durch diese Vorgehensweise ist es möglich, die benötigten Bilder in der PCL abzulegen, was dazu führt das die Bilder während dem Buildvorgang an die benötigte Stelle in der Verzeichnisstruktur der jeweiligen App abgelegt werden und somit zugreifbar sind. Würde stattdessen die Methode `FromFile` genutzt, wäre es nötig, die benötigten Bilder redundant in den jeweiligen Projekten für die Plattformen abzulegen. Die beiden Methoden haben ihre Vor- und Nachteile. Ist es beispielsweise gewünscht auf jeder Plattform unterschiedliche Bilder anzuzeigen, macht es mehr Sinn die Methode `FromFile` zu nutzen und die entsprechenden Bilder in den jeweiligen Projekten für die Plattformen abzulegen.

Damit das plattformübergreifende Verwenden von Bilder funktioniert und die Bilder während dem Buildvorgang für die jeweilige Plattform integriert werden, müssen alle Bilder via Visual Studio 2015 als "Eingebettete Ressource" angegeben werden. Des Weiteren muss in der Code-Behind Datei der Page auf der ein Bild angezeigt werden soll, ein Property vom Typ `ImageSource` angelegt werden [@MicrosoftXamarinBook, S. 289].

[^EmbeddedResource]: Ressource die während dem Buildvorgang in die Verzeichnisstruktur der jeweiligen Plattform integriert wird.

## Einschränkungen und Probleme bei der Cross-Plattform Entwicklung
Während der Entwicklung von CrewRest traten verschieden Probleme auf, welche den Implementierungsprozess erschwert und/oder verlangsamt haben.

**Fehlende ListView Details unter Windows 10**

Die anfänglich verwendete Version des Xamarin.Forms Framework hatte zur Folge das die durch das Property `Details` festgelegten Werte/Daten nicht in der ListView Komponente angezeigt wurden, während unter Android und iOS keine Probleme auftraten. Durch ein Update des Frameworks, welches via NuGet installiert wurde, konnte das Fehlverhalten behoben werden.

**Unerwartetes Verhalten MasterDetailPage**

In der anfänglichen Implementierung der MasterDetailPage trat ein Problem auf, welches dazu führte das die gesamte MasterDetailPage nicht angzeigt wurde. Der Auslöser des Problems war die fehlende Angabe des Property *Titel* der in der MasterDetailPage liegenden ContentPage. Dieses Verhalten trat während der späteren Entwicklung nicht mehr auf und wurde ggf. auch durch ein Update des Xamarin.Forms Framework beseitigt.

## Einbindung einer Drittanbieter Kalender UI-Komponente
Eine Anforderung an die CrewRest App ist das Anzeigen eines Kalenders in einer Montas- oder Wochenansicht mit speziell gekennzeichneten Tagen. Dieses Feature soll dem Anwender dabei helfen, die Abwesenheitslage von anderen Mitarbeitern überblicken zu können, um gezielt Urlaubsanträge in Zeiträumen mit geringer Anzahl anwesender Mitarbeiter zu verhindern.

Zu diesem Zweck wird eine Drittanbieter-Komponente getestet, welche einen Kalender in Monatsansicht darstellt, da Xamarin.Forms keine solche Komponente bietet. Der Anbieter der genutzten Kalender-Komponente ist das Open Source Projekt [Xamarin Froms Labs](https://github.com/XLabs/Xamarin-Forms-Labs), welches auf GitHub gehostet ist. Um die Features von Xamarin.Forms Labs in CrewRest verfügbar zu machen, ist das Projekt über NuGet dem CrewRest Projekt hinzugefügt. Des Weiteren sind einige Konfigurationsschritte nötig, um die zusätzlichen Features nutzbar zu machen, welche sehr knapp durch die Dokumentation des open source Projekts beschrieben werden. Nach einigen Versuchen, die Kalender-Komponente von Xamarin.Forms Labs zu nutzen, bleibt die Frage ob es für die gegebenen Anforderungen nutzbar ist noch offen. Der jetzige Stand von CrewRest zeigt die Kalender-Komponente unter iOS und Android an, unter Windows 10 jedoch wird diese nicht gerendert.

# Literatur und Internetquellen
