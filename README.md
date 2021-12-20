# ShareToshi Smart Contract Implementation

This project contains the implementation of the ERC20 tokens on solidity as well as the website mockup

## Smart Contracts
goto: http://remix.ethereum.org/

either copy the smart contracts (.sol-files) to the workspace or use the plugin "DGIT" to connect with this github repo.

### 10_SHRContracts.sol
Smart Contract for Sharetoshi SHR token. It's an ERC20 Token with in initial supply of 1'000'000 SHR. In theory the supply is capped, but due to some issues we allowed new users to mint additional 10'000 SHR when they use "getInitialSupply", so they can start using the mockup.

The ERC20 Token contains standard methods, is mintable, burnable and fungible.

The Token will be used for payments on the sharetoshi platform.

In addition it contains these methods:

#### getInitialSupply
Takes an address for the recipients as argument.

if the balance of the recipient is below 10'000 he can mint that amount of tokens to be able to use the mockup

#### performSHRTransaction
Takes an address for the recipient and the amount that should be transacted.

- it transfers the netto-amount (from the argument) to the recipient using default ERC20 method
- it will calculate burn-amount (0.001%) and burn it from the sender
- it will calculate the network-fee (0.001%) and transfer it to the Sharetoshi network

#### calculateGrossDeposit
calculates the gross deposit of an amount (given as argument). See amounts above. It will state the user how much is the gross deposit he needs to pay.

### 11_RPTContracts.sol
Smart Contract for Reputoshi RPT token. It's an ERC20 Token with uncapped supply. 

The Token will be used to represent Reputation of contributors.

The ERC20 Token contains standard methods, is mintable, burnable and fungible.

### 12_FRTContracts.sol
Smart Contract for Fairtoshi FRT token. It's an ERC20 Token with uncapped supply. 

The Token can be claimed by users who did something good for the environment.

The ERC20 Token contains standard methods, is mintable, burnable and fungible.

### 99_Idea_of_SharetoshiContracts.sol
Contains additional code of the basic idea we had to implement. However, we did not manage to implement it in the given time.


## Website
Contains the implementation of the website mockup. The website has been deployed to: https://sharetoshi.s3.eu-central-1.amazonaws.com/index.html

### index.html
Is a basic static mockup-website based on bootstrap.
The body will load the smart contracts when the website is loaded. 
It contains a basic mockup of the navbar with the amount of tokens that the user have.
It contains a mockup of 3 exchange resources (rent-a-bike, mow lawn, book a flight) that are implemented as cards and will execute the transaction when clicked on it. When you hover over it, it will show an overlay defined in styles.css.
On the bottom there is a debug panel showing the basic infos about the smart contracts and buttons to claim tokens.

### SmartContractInteraction.js
Contains the javascript code that basically interacts with the Smart contracts.

Therefore it relies on the Web3.js library.

For all 3 contracts, it contains their ABI and Address (HEX), as well as hardcoded addresses for the provider (mocked up) and the Sharetoshi network. In theory it may have made more sense to implement it on the smart contract side.

All methods that interact with the smart contracts should be implemented as async functions.

Methods:
- updateElement - takes an id of a html control and the content-string as argument. It will log the content to the console and display the given content on the site.
- loadShareToshiSolution - will load the 3 smart contracts, stores the Address from the account who logged in to Metamask and displays all the content (like totalSupply) on the website
- loadWeb3 - enables Web3 Ethereum
- loadContractSHR - loads the SHR smart contract
- loadContractRPT - loads the RPT smart contract
- loadContractFRT - loads the FRT smart contract
- getCurrentAccount - gets the Address of the accoun that logged in to metamask
- updateContent - contains submethods to display the content of the website from the smartcontracts
- getBalance - takes an address and a string (you, provider or network) as argument and will then display the SHR balance of that adress and displays it to the website
- getYouSHR - takes a balance (amount of SHR) as argument and will display it to the given html-controls.
- getProvSHR - takes a balance (amount of SHR) as argument and will display it to the given html-controls.
- getNetwSHR - takes a balance (amount of SHR) as argument and will display it to the given html-controls.
- getTotalSupply - Will display the total supply of SHR to the website
- performTransaction - takes an recipient address and the amount as argument. Will then open an alert to display the gross deposit to be transferred and if okay transfer that amount of SHR to the recipient
- ExchangeResource - takes and amount and item(string) as input. Will then log the item to the console and perform the transaction
- calcGrossDeposit - takes an amount and calculates the gross deposit that will be needed to transfer.
- formatSHR - takes an amount of SHR and transfers it to a more readable string.

- getRPTBalance - takes an address and who (you, provider) as argument. It will then cal the balance of RPT from that address and displays it to the website
- getYouRPT - takes a balance as input and will show the balance to the website.
- getProvRPT - takes a balance as input and will show the balance to the website.
- claimRPT - will mint an additional RPT token.

- getFRTBalance - takes an address and who (you, provider) as argument. It will then cal the balance of FRT from that address and displays it to the website
- getYouFRT - takes a balance as input and will show the balance to the website.
- getProvFRT - takes a balance as input and will show the balance to the website.
- claimFRT - will mint an additional FRT token.

### styles.css
Contains additional css-styles for the website.
