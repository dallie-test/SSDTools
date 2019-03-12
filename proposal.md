# Projectvoorstel GPtools

## Achtergrond
Binnen de afdeling Stakeholder Strategy & Development worden meerdere rapportages periodiek opgeleverd. Een van deze periodieke rapportages is de gebruiksprognose. In het verleden zijn er meerdere scripts ontwikkeld om de gebruiksprognose systematisch te genereren. Er is een behoefte om deze scripts op een centrale plek samen te brengen.

## Uw vraag
U vraagt AerLabs één repository te maken voor het creëren en evalueren van de jaarlijkse gebruiksprognose, op basis van drie verschillende libraries.

Het eindresultaat is een Git repository met daarin een Python package dat gebruikt kan worden om a) nieuwe gebruiksprognoses te maken, b) gebruiksprognoses te evalueren en c) gebruiksprognoses op te halen.

## Aanpak

Het project is op te delen in de volgende werkzaamheden:

1. Creëren van Python package.
2. Samenvoegen _doc29lib.py_, _GPlib.py_ en _GPtools_matlab/lib_.
3. Data ophalen uit Casper en Daisy middels een API.
4. Scheiden van aanmaken gebruiksprognose en evaluatie gebruiksprognose.

### Werkpakket 1: Creëren van Python package

Om de repository te kunnen importeren vanuit andere Python projecten zal er een Python package van worden gemaakt. Dit werkpakket omvat het herstructureren van de repository om de repository beschikbaar te maken als Python package. Hoewel het eindresultaat van dit werkpakket een Python package is, deze zal pas functioneel zijn na afronden van werkpakket 2.

Het eindresultaat van werkpakket 1 is een Git repository met daarin een Python package dat als volgt gebruikt kan worden:
```bash
# Voer de volgende opdracht uit in je opdrachtprompt om de gebruiksprognose van 2018 te installeren. 
pip install git+ssh://github.com/Schiphol-Hub/GPtools@2018
```

Onderdelen van package:

- `data/` - map met hierin de data van de gebruiksprognoses. Bevat een map `input/` een map `output/`.
- `gptools/` - map met hierin de verschillende functies en objecten van GPtools.
- `tests/` - map met hierin de verschillende tests van GPtools.
- `readme.md` - bestand met hierin een beschrijving van de repository.
- `requirements.txt` - bestand met hierin de Python packages en versies waar GPtools van afhankelijk is.
- `setup.py` - bestand met de configuratie van de Python package.


### Werkpakket 2: Samenvoegen _doc29lib.py_, _GPlib.py_ en _GPtools_matlab/lib_

Om de repository functioneel te maken zullen de verschillende functies uit de bestaande Matlab en Python code worden samengevoegd. Dit betekent dat de verschillende Matlab functies die nog niet in _lib/GPlib.py_ en _lib/doc29lib.py_ beschikbaar zijn, zullen worden omgeschreven naar Python.

We starten dit werkpakket met een inventarisatie van de beschikbaarheid van de verschillende functies in de drie bestaande libraries. Daarna identificeren we de verschillende varianten van elk functie in de bestaande libraries. Per functie wordt er samen met de opdrachtgever bepaald welke variant er beschikbaar moet worden gemaakt en welke niet. In het geval van het omschrijven van Matlab code naar Python code zal de functionaliteit van de Python implementatie worden geverifieerd met de oude Matlab code.

De nieuwe Python code zal vervolgens worden opgesplitst per type functionaliteit: _collect_store_, _process_ en _visualize_. _collect_store_ omvat alle methodes om data op te halen en weg te schrijven, _process_ omvat alle methodes om data te verwerken en _visualize_ omvat alle methodes om data te visualiseren.

Het eindresultaat van werkpakket 2 is een Git repository met daarin een functionele Python package.

Ten opzichte van werkpakket 1 bevat het eindresultaat van werkpakket 2 de volgende nieuwe onderdelen:

- `gptools/collect_store.py` - bestand met hierin de verschillende functies en objecten om de data op te halen en weg te schrijven. 
- `gptools/process.py` - bestand met hierin de verschillende functies en objecten om de data te verwerken. 
- `gptools/visualize.py` - bestand met hierin de verschillende functies en objecten om de data te visualiseren.
- `tests/test_collect.py` - bestand met tests voor `gptools/collect.py`.
- `tests/test_process.py` - bestand met tests voor `gptools/process.py`.
- `tests/test_visualize.py` - bestand met tests voor `gptools/visualize.py`.
- `readme.md` - bestand met hierin een beschrijving van de repository, een handleiding voor het gebruik van de repository en richtlijnen voor het maken van een nieuwe gebruiksprognose.

### Werkpakket 3: Data ophalen uit Casper en Daisy middels een API

Op dit moment moet de data uit Casper en Daisy worden opgehaald middels meerdere Bash scripts. Om het gebruiksgemak en de leesbaarheid van de code te verhogen, en daarmee de kans op fouten te verminderen, is het wenselijk om deze Bash scripts te vervangen door API calls vanuit Python.

We starten dit werkpakket met een inventarisatie van de verschillende data die vanuit Casper en Daisy moet komen om de gebruiksprognose te maken. Vervolgens wordt er gekeken hoe deze data nu vanuit de Bash scripts wordt opgehaald en hoe deze Bash scripts kunnen worden omgeschreven naar Python. Mocht er data uit Daisy en Casper moeten worden gehaald waar nog geen Bash script voor is, dan kan er worden gekeken of de API wel beschikbaar is. Zo ja, dan kan er alsnog een methode in Python worden gecreëerd om deze data op te halen. Zo niet, dan kan er in overleg met de opdrachtgever en de leverancier van Casper en Daisy een nieuwe API worden ontwikkeld voor deze data.

Het eindresultaat van werkpakket 3 is een update van de verschillende functies en objecten in `gptools/`.

Ten opzichte van werkpakket 2 bevat het eindresultaat van werkpakket 3 de volgende nieuwe onderdelen:

- `gptools/collect_casper.py` - bestand met hierin de verschillende functies en objecten om data uit Casper en Daisy te halen.
- `tests/test_collect_casper.py` - bestand met hierin de tests voor `gptools/collect_casper.py`.
- `config.py` - bestand met hierin de verschillende configuratie- en inloggegevens om verbinding te maken met Casper en Daisy. 

### Werkpakket 4: Scheiden van aanmaken gebruiksprognose en evaluatie gebruiksprognose.

De werkzaamheden uit de vorige werkpakketen leiden tot een Python package met daarin de verschillende methodes die nodig zijn om een gebruiksprognose te maken en te evalueren. Dit werkpakket omvat de werkzaamheden om een script te maken voor het aanmaken van nieuwe gebruiksprognoses en een methode om deze intern te publiceren. Daarnaast bevat dit werkpakket ook de werkzaamheden om tot een script te komen dat in staat is om oude gebruiksprognoses te evalueren.

We starten dit werkpakket met het bekijken van de stappen die in het verleden zijn gevolgd om een nieuwe gebruiksprognose te maken. Op basis hiervan wordt het proces opnieuw samengevoegd in één script voor het aanmaken van nieuwe gebruiksprognoses. Dezelfde methode kan ook worden gebruikt om het evaluatieproces van gebruiksprognoses in kaart te brengen en vervolgens te implementeren in een script. Een belangrijk onderdeel van het eindresultaat is de bijbehorende documentatie, zodat de procedure ook in de toekomst door anderen te volgen en te gebruiken is.     

Het eindresultaat is een update van de verschillende bestanden in `gptools`.

Ten opzichte van werkpakket 3 bevat het eindresultaat van werkpakket 4 de volgende nieuwe onderdelen:

- `readme.md` - bestand met hierin een beschrijving van de repository, een handleiding voor het gebruik van de repository en richtlijnen voor het maken van een nieuwe gebruiksprognose. Uitsplitsing van aanmaken nieuwe gebruiksprognose en evaluatie van gebruiksprognose.
- `create.py` -  bestand met hierin de methode om een nieuwe gebruiksprognose te maken.
- `evaluate.py` - bestand met hierin de methode om een gebruiksprognose te evalueren.

### Planning

|Werkpakket|Startdatum|Bijeenkomst|
|---|---|---|
|1|4 maart 2019|12 maart 2019|
|2|4 maart 2019|12 maart 2019|
|3|25 maart 2019|26 maart 2019 en/of 2 april 2019|
|4|8 april 2019|9 april 2019 en/of 16 april 2019|

## Uitgangspunten
- De implementatie zal worden getest in Python 3.6.
- PEP8 als standaard stijl voor de Python code.
- Intellectueel eigendom van de software is van de opdrachtgever.
- De geraamde inzet van werkpakket 3 omvat alleen het omschrijven van de bestaande Bash scripts. Mogelijke uitbreidingen kunnen tegen hetzelfde tarief worden uitgevoerd.   

## Organisatie
Vanuit AerLabs zal Robert Koster het project leiden en uitvoeren met hulp van Richard Janssen.

Robert Koster heeft in het verleden voor AerLabs ECAC Doc 29 geïmplementeerd en heeft hiermee expertise opgebouwd op het gebied van vliegtuiggeluid en het ontwikkelen van efficiënte Python applicaties.

Richard Janssen heeft zowel tijdens als na zijn studie Air Transport and Operations gewerkt aan het optimaliseren van de inzet van resources op en rondom de luchthaven. O.a. bij KLM heeft hij Python applicaties ontwikkeld met het oog op het verbeteren van de processen. Deze kennis gebruikt hij nu bij AerLabs om de software producten te verbeteren.

