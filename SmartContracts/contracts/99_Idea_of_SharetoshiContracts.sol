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
    string requestedResourceName = "Rent a bike";               //Bezeichnung des Austauschvertrages
    enum requestedResourceCategory {social, environmental, other}           //the field in which the transaction takes place (to detect what external effects need to be con-sidered and where the compensation payment should be invested)
    uint requestedResourceCategoryAccount = 0;
    uint requestedResourceBasePrice = 100;            //Basispreis of the requested Resource
    uint requestedResourceCompensationRequired = 2; //The amount to pay to cover indirectly caused negative external effects in connection with the contract, if applicable (e.g. the production of the resource may have superor-dinate effects such as environmental pollution)
    uint voluntaryAmountResourceSeeker = 1;         //The ResourceSeeker can decide to pay more than the minimum required Deposit, in order to gain FairToshi
    uint fairToshiDiscountClaimAmount = 1;          //wie viele FairToshis will/kann der käufer zur Preiszahlung hinzuzählen, um weniger Sharetoshis bezahlen zu müssen

    //ShareToshi-Bestände
    uint sharetoshiBallanceResourceSeeker = 1000;      
    uint sharetoshiBallanceResourceProvider = 35563;
    uint SHRTotalSupply = 1000000000;

    //FairToshi-Bestände
    uint fairtoshiBallanceResourceSeeker = 12;      
    uint fairtoshiBallanceResourceProvider = 512;

    //RepuToshi-Bestände
    uint reputoshiBallanceResourceSeeker = 1024;      
    uint reputoshiBallanceResourceProvider = 2048;

    uint errorCount;

    //weitere Attribute, die eigentlich in einer separaten klasse sein müssten
    // uint sharetoshiUndistributed = 1000000000;

    uint purchasePricePayment;
    uint totalDepositRequired;
    uint totalDepositActual;

    
    function getCalculatedDeposit()public view returns(uint){
        return totalDepositRequired;
    }
    function getTotalDepositActual() public view returns (uint){
        return totalDepositActual;
    }

    function getBallance_sharetoshi_seeker () public view returns (uint){
        return sharetoshiBallanceResourceSeeker;
    }

    function getBallance_sharetoshi_provider()public view returns (uint){
        return sharetoshiBallanceResourceProvider;
    }
    function getBallance_fairtoshi_seeker () public view returns (uint){
        return fairtoshiBallanceResourceSeeker;
    }
    function getBallance_fairtoshi_provider () public view returns (uint){
        return fairtoshiBallanceResourceProvider;
    }
    function getBallance_reputoshi_seeker () public view returns (uint){
        return reputoshiBallanceResourceSeeker;
    }
    function getBallance_reputoshi_provider () public view returns (uint){
        return reputoshiBallanceResourceProvider;
    }
    function get_SHRTotalSupply () public view returns (uint){
        return SHRTotalSupply;
    }






    function burnTokens (uint burnAmount) private pure returns(uint){
        return burnAmount;
    }

    function mintTokens (uint mintAmount) private pure returns(uint){
        return mintAmount;
    }

    //habe jetzt halt keine klasse gebaut für das konto inkl kontoreferenz sowie saldo etc. die konten sind uint, welcher dem saldo entspricht
    //hier gibt es zahlreiche muster, mit professionelleren funktionen für transaktionen, habe ich aber alle nicht wirklich begriffen, aber allenfalls reicht es auch so rudimentär
    // function transactTokens (uint fromBallance, uint toBallance, uint transactionAmount) private pure{
    //     toBallance += transactionAmount;                                            
    //     fromBallance -= transactionAmount;                              

    // }

    function transactTokens (uint transactionAmount) public returns (uint){
        //need to calculate the gross deposit with burn and network Fee
        uint grossDeposit = calculateDeposit(transactionAmount);

        sharetoshiBallanceResourceProvider += transactionAmount;                                            
        sharetoshiBallanceResourceSeeker -= grossDeposit;                              

        return grossDeposit;
    }

    function calculateDeposit(uint transactionNet) private returns (uint){
        purchasePricePayment = transactionNet + requestedResourceCompensationRequired; //als Preis für eine Resource werden standardmässig auch die mit ihr verbundenen externen negativen effekte eingerechnet -> muss dadurch vom Käufer bezahlt werden und Verkäufer muss den Betrag zwingend für die Kompensation der entstandenen Schäden einsetzen
        uint sharetoshiNetworkFee = purchasePricePayment / 1000;       //networkFee sowie...
        uint sharetoshiBurnAmount = purchasePricePayment / 1000;       //...burnAmount werden ausgehend vom purchasePricePayment berechnet
        totalDepositRequired = purchasePricePayment + sharetoshiNetworkFee + sharetoshiBurnAmount + voluntaryAmountResourceSeeker;   //alle diese Beträge zusammen ergeben das notwendige zu hinterlegende Deposit, welches hinterlegt werden muss, bevor die Transaktion initiiert werden kann
        return totalDepositRequired;
    }




    // function calculateDeposit() public payable returns (uint){
    //     purchasePricePayment = requestedResourceBasePrice + requestedResourceCompensationRequired; //als Preis für eine Resource werden standardmässig auch die mit ihr verbundenen externen negativen effekte eingerechnet -> muss dadurch vom Käufer bezahlt werden und Verkäufer muss den Betrag zwingend für die Kompensation der entstandenen Schäden einsetzen
    //     uint sharetoshiNetworkFee = purchasePricePayment / 1000;       //networkFee sowie...
    //     uint sharetoshiBurnAmount = purchasePricePayment / 1000;       //...burnAmount werden ausgehend vom purchasePricePayment berechnet
    //     totalDepositRequired = purchasePricePayment + sharetoshiNetworkFee + sharetoshiBurnAmount + voluntaryAmountResourceSeeker;   //alle diese Beträge zusammen ergeben das notwendige zu hinterlegende Deposit, welches hinterlegt werden muss, bevor die Transaktion initiiert werden kann
    //     return totalDepositRequired;
    // }

    function gatherDeposit() public payable{
        uint shareToshiCharges = totalDepositRequired - fairToshiDiscountClaimAmount;
       //Solidity also supports exception handling in the form of try/catch-statements, but only for external function calls and contract creation calls. -> https://docs.soliditylang.org/en/v0.6.0/control-structures.html
        sharetoshiBallanceResourceSeeker -= shareToshiCharges;                                     //der verbleibende sharetoshibetrag wird dem ressourcen-nachfrager belastet... und dem temporären depositkonto gutgeschrieben
        totalDepositActual = totalDepositActual + mintTokens(fairToshiDiscountClaimAmount);     //für den fehlbetrag (entsprechend fairToshiDiscountClaimAmount) werden im gegenzug neue tokens zu gunsten des depositkontos geminted, sodass nun totalDepositRequired == totalDepositActual sein sollte.
        totalDepositActual += shareToshiCharges;
        fairtoshiBallanceResourceSeeker = fairtoshiBallanceResourceSeeker - burnTokens(fairToshiDiscountClaimAmount);              //die entsprechend für den rabatt verwendeten fairtoshi werden dabei verbrannt
    }
    
    //hier einfachheitshalber lediglich die werte der ausgangsparameter gesetzt, damit der happy path durchläuft, ohne dass vertrag erfüllt/bzw. auch noch ausprogrammiert werden muss
//    function transactionFulfillment() public {
        bool sharetoshiContractFulfilled = true;    //die Erbrachte Leistung wurde akzeptiert
        bool resourceSeekerDonatesDeposit = true;   //entweder werden die übrigen 0.1 an resourceseeker zurückerstattet oder sie werden verdoppelt (1x seeker, zusätzlich 1x provider) und belastet. Default ist true, kann der nutzer aber überschreiben
        bool ratingsCompleted = true;               //alle Vertragspartner haben sich gegenseitig gerated
        uint contractualPartnersNumber = 2;         //Anzahl Vertragspartner könnten theoretisch auch mehr als nur Käufer/Verkäufer sein
        uint evaluationScoreAssignedToSeeker = 7;   //diese anzahl reputoshi wird dann geminted zugunsten nachfrager
        uint evaluationScoreAssignedToProvider = 12;//diese anzahl reputoshi wird dann geminted zugunsten anbieter
        uint additionalAdministrativeCosts = 0;     //DisputeCosts, otherCostsDuringFulfillment, ...
 //   }

    function performPayment () public payable {
        totalDepositActual = totalDepositActual - burnTokens(purchasePricePayment / 1000);   //erst mit verteilung des Deposits werden die 0.1% verbrannt
        totalDepositActual = totalDepositActual - purchasePricePayment / 1000;               //abzug Fee fürs Netzwerk
        SHRTotalSupply += purchasePricePayment / 1000;
        totalDepositActual -= additionalAdministrativeCosts;
        totalDepositActual -= requestedResourceCompensationRequired;                            //abzug der obligatorischen, vertraglich definierten kompensationszahlung
        requestedResourceCategoryAccount = requestedResourceCategoryAccount + requestedResourceCompensationRequired;
        reputoshiBallanceResourceSeeker += evaluationScoreAssignedToSeeker;
        reputoshiBallanceResourceProvider += reputoshiBallanceResourceProvider;

        //abzug der im deposit enthaltenen standardmässigen 0.001, falls diese für einen guten zweck gespendet werden möchte, wobei derselbe satz auf der anbieterseite analog auch abgezogen wird        
        if (resourceSeekerDonatesDeposit == true) {
            if (additionalAdministrativeCosts < purchasePricePayment / 1000 * 2) {                                                      //wenn noch nicht individuell belastete kosten, werden zu gleichen teilen den vertragspartnern belastet.
                requestedResourceCategoryAccount += purchasePricePayment / 1000 * 2;       
                totalDepositActual -= purchasePricePayment / 1000 * 2; //requestedResourceCategory.donationAccount, wo dann die kompensationszahlungen erstmal hinfliessen würden, habe ich noch nicht gebaut
                fairtoshiBallanceResourceSeeker = fairtoshiBallanceResourceSeeker + mintTokens (purchasePricePayment / 1000);
                fairtoshiBallanceResourceProvider = fairtoshiBallanceResourceProvider - mintTokens (purchasePricePayment / 1000);
            //abzug der freiwilligen zuwendung des nachfragers
            }
            if (voluntaryAmountResourceSeeker > 0){
                totalDepositActual = totalDepositActual - voluntaryAmountResourceSeeker;
                requestedResourceCategoryAccount = requestedResourceCategoryAccount + voluntaryAmountResourceSeeker;
                fairtoshiBallanceResourceSeeker = fairtoshiBallanceResourceSeeker - mintTokens (voluntaryAmountResourceSeeker);
            }
        }else{
            totalDepositActual = totalDepositActual - purchasePricePayment / 1000 - voluntaryAmountResourceSeeker;       // zahlung nicht ausführbar, seekingUser muss zuerst mehr kapital auf dem totalDepositActual zur verfügung stellen, damit die gebühren allen vertragspartnern zu gleichen teilen belastet werden können.
            sharetoshiBallanceResourceSeeker = sharetoshiBallanceResourceSeeker + purchasePricePayment / 1000 + voluntaryAmountResourceSeeker;
        }
        //Depot-bestandteile auf Nachfrager-Seite sind nun geregelt, der restbetrag steht also dem provider zu
        sharetoshiBallanceResourceProvider += totalDepositActual;
        totalDepositActual-= totalDepositActual;
    }
}