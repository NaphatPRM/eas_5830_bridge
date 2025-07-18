// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./BridgeToken.sol";

contract Destination is AccessControl {
    bytes32 public constant WARDEN_ROLE = keccak256("BRIDGE_WARDEN_ROLE");
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
  // the address (on the source chain) of the token that is being wrapped 
  // So this is a map from the wrapped token to the underlying one
	mapping( address => address) public underlying_tokens; 
  // Map fro the underlying token to the wrapped
	mapping( address => address) public wrapped_tokens;
	address[] public tokens;

	event Creation( address indexed underlying_token, address indexed wrapped_token );
	event Wrap( address indexed underlying_token, address indexed wrapped_token, address indexed to, uint256 amount );
	event Unwrap( address indexed underlying_token, address indexed wrapped_token, address frm, address indexed to, uint256 amount );

    constructor( address admin ) {
        admin = admin // or use address(this) not sure if this works
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(CREATOR_ROLE, admin);
        _grantRole(WARDEN_ROLE, admin);
    }

	function wrap(address _underlying_token, address _recipient, uint256 _amount ) public onlyRole(WARDEN_ROLE) {
		// YOUR CODE HERE
    // Address standards
    require(_underlying_token != address(0), "ERC20: underlying token is the zero address");
    require(_recipient != address(0), "ERC20: cannot have recipient from the zero address");
    // Amount have to be more than 0 
    require(_amount != 0, "Amount more than 0");

    // Lookup the BridgeToken that corresponds to the underlying
    address lookup_token = underlying_tokens[_underlying_token]
    // Checking the conditions : Must already call the createToken
    require(lookup_token != address(0), "Must exist the address");
    // The wrap function should emit a Wrap event.
    emit Wrap(_underlying_token, address indexed wrapped_token, _recipient, _amount);
    // mint the correct amount of BridgeTokens to the recipient.
    BridgeToken(lookup_token).mint(_recipient, _amount)
	}

	function unwrap(address _wrapped_token, address _recipient, uint256 _amount ) public {
		//　YOUR CODE HERE
    require(_wrapped_token != address(0), "ERC20: wrapped token is the zero address");
    require(_recipient != address(0), "ERC20: cannot have recipient from the zero address");
    // Get the underlying token
    address lookup_underlying = wrapped_tokens[_wrapped_token]
    // Checking the conditions : Must already call the createToken
    require(lookup_underlying != address(0), "Must exist the address");
    // Emit a function of Unwrap
    emit Unwrap(lookup_underlying, _wrapped_token, admin, _recipient, _amount);
    // Burn the token
    BridgeToken(lookup_token).clawBack(_recipient, _amount)
	}

	function createToken(address _underlying_token, string memory name, string memory symbol ) public onlyRole(CREATOR_ROLE) returns(address) {
		//YOUR CODE HERE
    // Checking the conditions : address 
    require(_underlying_token != address(0), "ERC20: create token from the zero address");
    // The createToken function should emit a Creation event.
    emit Creation(_underlying_token, address indexed wrapped_token );

    // the owner of the destination contract will need create 
    // new BridgeToken instance on the destination chain.
    BridgeToken bridge_token = new BridgeToken(_underlying_token, name, symbol, admin)
    // add to the corresponding map?
    underlying_tokens[_underlying_token] = address(bridge_token)
    wrapped_tokens[address(bridge_token)] = _underlying_token
    
    // return the address of the newly created contract.
    return address(bridge_token)
	}

}


