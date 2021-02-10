// SPDX-License-Identifier: MIT
// pragma solidity ^0.5.12;
pragma solidity 0.6.11;                                                             // LG : verrouiler le pragma et utiliser une version plus récente de solidity
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol"; // LG : importer la librairie SafeMath
    
contract Crowdsale {
    using SafeMath for uint256;
    
    address /*public*/ private owner;                                               // LG : n'a pas besoin d'être public
    address /*public*/ private escrow; // wallet to collect raised ETH              // LG : ne pas exposer le wallet ou les fonds sont stockés
    uint256 public savedBalance /*= 0*/; // Total amount raised in ETH              // LG : pas besoin d'initialiser à 0 pour sauvegarder du gas
    mapping (address => uint256) public balances; // Balances in incoming Ether
    
    event DepositReceived(address _address);                                        // LG : utiliser les event pour surveiller l'activité
    event PaymentWithdrawed(address _address);
    
    // Initialization
    /*function Crowdsale(address _escrow) public{
       owner = tx.origin;                                                           // LG : ne pas utiliser tx.origin
       // add address of the specific contract
       escrow = _escrow;
    }*/
    
    constructor(address _escrow) public {                                           // LG : utiliser de préférence un constructeur
        owner = msg.sender;
        escrow = _escrow;
    }
    
    // function to receive ETH
    /*function() public {
       balances[msg.sender] = balances[msg.sender].add(msg.value);
       savedBalance = savedBalance.add(msg.value);
       escrow.send(msg.value);
    }*/
    
    function deposit() payable external {                                           // LG : de préférence, implémenter une fonction deposit, à appeler pour revevoir des ETH
        require(msg.sender != address(0), "You cannot deposit for the address zero");

        balances[msg.sender] = balances[msg.sender].add(msg.value);
        savedBalance = savedBalance.add(msg.value);
        
        // escrow.send(msg.value); 
        escrow.transfer(msg.value);                                                 // LG : utiliser plutot la fonction transfer qui lève une exception
    }
    
    fallback() payable external {                                                   // LG : il faut implémenter la fonction fallback pour recevoir des ETH
        require(msg.data.length == 0);                                              // LG : pour vérifier que la fonction fallback n’est pas appelée par erreur
        emit DepositReceived(msg.sender); 
    }
    
    
    // refund investisor
    function withdrawPayments() /*public*/ external {                               // LG : il vaut mieux utiliser external que public
        //address payee = msg.sender;
        //uint256 payment = balances[payee];                                        // LG : consomme du gas pour rien
       
        require(balances[msg.sender] != 0);                                         // LG : ajout d'un require pour tester la balances
        require(savedBalance >= balances[msg.sender]);

        // payee.send(payment);
        savedBalance = savedBalance.sub(balances[msg.sender]);
        balances[msg.sender] = 0;
       
        msg.sender.transfer(balances[msg.sender]);                                  // LG : utiliser plutot la fonction transfer qui lève une exception et transférer après le changement d'état
       
        emit DepositReceived(msg.sender); 
    }
}
