// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;



//TODO:
//1)
//uc1 ContractInitiation mittels einer funktion abbilden, welcher die nötigen parameter übergeben werden können, und welche dann die entsprechenden funktionen aufruft
//uc2 ist aktuell eine dummyFunktion "transactionFulfillment", die einfach die vairablen setzt: vielleicht könnte man diese einfach triggern, sobald uc1 abgeschlossen ist. also dass ab dann die parameter via "gui" gesetzt werden köknnen. und wenn die parameter gesetzt wurden, wird der letzte 3. UC ausgeführt
//uc3 ContractTermination mittels einer funktion abbilden, welcher die parameter aus uc1 und uc2 übernimmt und dann und welche dann die entsprechenden funktionen aufruft, um den prozess abzuschliessen.

//2) 
//--> try/catch funktioniert nicht
//--> schauen ob der rest ausführbar ist

//3)
//--> danach mal schauen, welche parameter und funktionen public oder private sein müssen, dass nur auf die jeweiligen zugegriffen werden kann via "gui"
//--> dann compiilen und mit blabla (London) deployen und testen.

contract Transactions {
    string requestedResourceName;               //Bezeichnung des Austauschvertrages
    enum requestedResourceCategory {social, environmental, other}           //the field in which the transaction takes place (to detect what external effects need to be con-sidered and where the compensation payment should be invested)
    uint requestedResourceBasePrice;            //Basispreis of the requested Resource
    uint requestedResourceCompensationRequired; //The amount to pay to cover indirectly caused negative external effects in connection with the contract, if applicable (e.g. the production of the resource may have superor-dinate effects such as environmental pollution)
    uint voluntaryAmountResourceSeeker;         //The ResourceSeeker can decide to pay more than the minimum required Deposit, in order to gain FairToshi
    uint fairToshiDiscountClaimAmount;          //wie viele FairToshis will/kann der käufer zur Preiszahlung hinzuzählen, um weniger Sharetoshis bezahlen zu müssen

    //ShareToshi-Bestände
    uint sharetoshiBallanceResourceSeeker;      
    uint sharetoshiBallanceResourceProvider;
    uint totalDepositActual;
    uint sharetoshiUndistributed;

    //FairToshi-Bestände
    uint fairtoshiBallanceResourceSeeker;      
    uint fairtoshiBallanceResourceProvider;

    //RepuToshi-Bestände
    uint reputoshiBallanceResourceSeeker;      
    uint reputoshiBallanceResourceProvider;

    uint errorCount;

    function burnTokens (uint xtoshiAccountBallanceSource, uint burnAmount) public {
        xtoshiAccountBallanceSource -= burnAmount;
    }

    function mintTokens (uint xtoshiAccountBallanceTarget, uint mintAmount) public {
        xtoshiAccountBallanceTarget += mintAmount;
    }

    //habe jetzt halt keine klasse gebaut für das konto inkl kontoreferenz sowie saldo etc. die konten sind uint, welcher dem saldo entspricht
    //hier gibt es zahlreiche muster, mit professionelleren funktionen für transaktionen, habe ich aber alle nicht wirklich begriffen, aber allenfalls reicht es auch so rudimentär
    function transactTokens (uint fromBallance, uint toBallance, uint transactionAmount) public {
        fromBallance -= transactionAmount;                              
        toBallance += transactionAmount;                                            
    }

    function calculateDeposit(uint requestedResourceBasePrice, uint requestedResourceCompensationRequired, uint voluntaryAmountResourceSeeker) public returns (uint){
        uint purchasePricePayment = requestedResourceBasePrice + requestedResourceCompensationRequired; //als Preis für eine Resource werden standardmässig auch die mit ihr verbundenen externen negativen effekte eingerechnet -> muss dadurch vom Käufer bezahlt werden und Verkäufer muss den Betrag zwingend für die Kompensation der entstandenen Schäden einsetzen
        uint sharetoshiNetworkFee = purchasePricePayment /1000;       //networkFee sowie...
        uint sharetoshiBurnAmount = purchasePricePayment /1000;       //...burnAmount werden ausgehend vom purchasePricePayment berechnet
        // uint totalDepositRequired = purchasePricePayment + networkFee + burnAmount + voluntaryAmountServicereceiver;   //alle diese Beträge zusammen ergeben das notwendige zu hinterlegende Deposit, welches hinterlegt werden muss, bevor die Transaktion initiiert werden kann
        uint totalDepositRequired = purchasePricePayment + sharetoshiNetworkFee + sharetoshiBurnAmount + voluntaryAmountResourceSeeker;   //alle diese Beträge zusammen ergeben das notwendige zu hinterlegende Deposit, welches hinterlegt werden muss, bevor die Transaktion initiiert werden kann
        return totalDepositRequired;
    }

    function gatherDeposit(uint totalDepositRequired, uint fairToshiDiscountClaimAmount) public {
        uint shareToshiCharges = totalDepositRequired - fairToshiDiscountClaimAmount;
        //Solidity also supports exception handling in the form of try/catch-statements, but only for external function calls and contract creation calls. -> https://docs.soliditylang.org/en/v0.6.0/control-structures.html
        // try {                                                                                   //da uint eine positive Zahl ist, würde zu tiefer sharetoshi saldo crashen, wenn sharetoshicharges belastet werden
        // transactTokens(sharetoshiBallanceResourceSeeker, totalDepositActual, shareToshiCharges); //der verbleibende sharetoshibetrag wird dem ressourcen-nachfrager belastet... und dem temporären depositkonto gutgeschrieben
        // totalDepositActual += mintTokens(totalDepositActual, fairToshiDiscountClaimAmount);     //für den fehlbetrag (entsprechend fairToshiDiscountClaimAmount) werden im gegenzug neue tokens zu gunsten des depositkontos geminted, sodass nun totalDepositRequired == totalDepositActual sein sollte.
        // burnTokens(fairtoshiBallanceResourceSeeker, fairToshiDiscountClaimAmount);              //die entsprechend für den rabatt verwendeten fairtoshi werden dabei verbrannt
        // } catch {
        //     errorCount++;
        // }

        transactTokens(sharetoshiBallanceResourceSeeker, totalDepositActual, shareToshiCharges); //der verbleibende sharetoshibetrag wird dem ressourcen-nachfrager belastet... und dem temporären depositkonto gutgeschrieben
        totalDepositActual += mintTokens(totalDepositActual, fairToshiDiscountClaimAmount);     //für den fehlbetrag (entsprechend fairToshiDiscountClaimAmount) werden im gegenzug neue tokens zu gunsten des depositkontos geminted, sodass nun totalDepositRequired == totalDepositActual sein sollte.
        burnTokens(fairtoshiBallanceResourceSeeker, fairToshiDiscountClaimAmount); 
    }
    
    //hier einfachheitshalber lediglich die werte der ausgangsparameter gesetzt, damit der happy path durchläuft, ohne dass vertrag erfüllt/bzw. auch noch ausprogrammiert werden muss
    function transactionFulfillment() public {
        bool sharetoshiContractFulfilled = true;    //die Erbrachte Leistung wurde akzeptiert
        bool ResourceSeekerDonatesDeposit = true;   //entweder werden die übrigen 0.1 an resourceseeker zurückerstattet oder sie werden verdoppelt (1x seeker, zusätzlich 1x provider) und belastet. Default ist true, kann der nutzer aber überschreiben
        bool ratingsCompleted = true;               //alle Vertragspartner haben sich gegenseitig gerated
        uint contractualPartnersNumber = 2;         //Anzahl Vertragspartner könnten theoretisch auch mehr als nur Käufer/Verkäufer sein
        uint evaluationScoreAssignedToSeeker = 7;   //diese anzahl reputoshi wird dann geminted zugunsten nachfrager
        uint evaluationScoreAssignedToProvider = 12;//diese anzahl reputoshi wird dann geminted zugunsten anbieter
        uint additionalAdministrativeCosts = 0;     //DisputeCosts, otherCostsDuringFulfillment, ...
        // uint totalDepositActual -= additionalAdministrativeCosts; // geht nicht, weil bei instantierung (uint ...) der Wert "totalDepositActual" noch keinen Wert hat, darum auch nicht -= sein kann
        uint totalDepositActual = additionalAdministrativeCosts;
    }

    function performPayment(uint totalDepositActual, uint purchasePricePayment) public returns (uint yyy) {
        //just for debugging reasons...
        bool ResourceSeekerDonatesDeposit = true; 
        uint additionalAdministrativeCosts = 0;
        uint requestedResourceCategory_donationAccount = 1;
        //just for debugging reasons end...
        
        
        burnTokens(totalDepositActual, purchasePricePayment /1000);                                                           //erst mit verteilung des Deposits werden die 0.1% verbrannt
        transactTokens (totalDepositActual, sharetoshiUndistributed, purchasePricePayment /1000);                               //abzug Fee fürs Netzwerk
        // transactTokens (totalDepositActual, requestedResourceCategory.donationAccount, requestedResourceCompensationRequired);   //abzug der obligatorischen, vertraglich definierten kompensationszahlung
        transactTokens (totalDepositActual, requestedResourceCategory_donationAccount, requestedResourceCompensationRequired);

        

        //abzug der im deposit enthaltenen standardmässigen 0.001, falls diese für einen guten zweck gespendet werden möchte, wobei derselbe satz auf der anbieterseite analog auch abgezogen wird        
        if (ResourceSeekerDonatesDeposit == true) {
            if (additionalAdministrativeCosts < purchasePricePayment /500){                                                      //wenn noch nicht individuell belastete kosten, werden zu gleichen teilen den vertragspartnern belastet.
                // transactTokens (totalDepositActual, requestedResourceCategory.donationAccount, purchasePricePayment /500);       //requestedResourceCategory.donationAccount, wo dann die kompensationszahlungen erstmal hinfliessen würden, habe ich noch nicht gebaut
                transactTokens (totalDepositActual, requestedResourceCategory_donationAccount, purchasePricePayment /500);
                mintTokens (fairtoshiBallanceResourceSeeker, purchasePricePayment /1000);
                mintTokens (fairtoshiBallanceResourceProvider, purchasePricePayment /1000);
            }else{
                errorCount++;       // zahlung nicht ausführbar, seekingUser muss zuerst mehr kapital auf dem totalDepositActual zur verfügung stellen, damit die gebühren allen vertragspartnern zu gleichen teilen belastet werden können.
            }
            //abzug der freiwilligen zuwendung des nachfragers
            if (voluntaryAmountResourceSeeker > 0){
                // transactTokens (totalDepositActual, requestedResourceCategory.donationAccount, voluntaryAmountResourceSeeker);
                transactTokens (totalDepositActual, requestedResourceCategory_donationAccount, voluntaryAmountResourceSeeker);
                mintTokens (fairtoshiBallanceResourceSeeker, voluntaryAmountResourceSeeker);
            }
        }else{
            transactTokens(totalDepositActual, sharetoshiBallanceResourceSeeker, ((purchasePricePayment /1000) +voluntaryAmountResourceSeeker));       // zahlung nicht ausführbar, seekingUser muss zuerst mehr kapital auf dem totalDepositActual zur verfügung stellen, damit die gebühren allen vertragspartnern zu gleichen teilen belastet werden können.
        }
        //Depot-bestandteile auf Nachfrager-Seite sind nun geregelt, der restbetrag steht also dem provider zu
        transactTokens (totalDepositActual, sharetoshiBallanceResourceProvider, totalDepositActual);
        // function transactTokens (totalDepositActual, sharetoshiBallanceResourceProvider, totalDepositActual);
    }
}