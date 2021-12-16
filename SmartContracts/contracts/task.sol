pragma solidity >=0.4.0 <0.7.0;

contract Task {
	address public owner;
	uint public minAmount;
	uint private salt;
	mapping(bytes32 => uint256) public secrets;
	mapping(uint8 => uint256) public amount;

    //Function to deploy the contract
	constructor (uint _salt) public {
		owner = msg.sender;
		minAmount = 0.8 ether;
		salt = _salt;

	}
	
	//Only the creator can set the secrets
	function set_secrets(uint8[] memory _keys, uint256[] memory _values) public {
	    assert(msg.sender == owner);
        for (uint8 i=0; i < _keys.length; i++) {
            secrets[keccak256(abi.encode(_keys[i],salt))] = _values [i]; 
        }
    }

    //Your deposit needs to be larger than minAmount to get your secret number
    function get_number(uint8 _key) public view returns (uint256) {
        require(amount[_key] >= minAmount);
        uint256 value =  secrets[keccak256(abi.encode(_key,salt))];
        return value;
    }
    
    //Here you can top up your deposit
    function deposit_ether(uint8 _key) public payable {
        amount[_key]=msg.value;
    }

}