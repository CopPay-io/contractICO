pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract CopPayToken is StandardToken, Ownable {
  string public name = 'CopPayToken';
  string public symbol = 'COP';
  uint public decimals = 18;

  uint public crowdsaleStartTime;
  uint public crowdsaleEndTime;

  uint public startTime;
  uint public endTime;
  uint public tokensSupply;
  uint public rate;
  address public wallet;

  uint public tokensSold;

  bool public stopped;
  event SaleStart();
  event SaleStop();

  modifier crowdsaleTransferLock() {
    require(now > crowdsaleEndTime);
    _;
  }

  function CopPayToken() {
    totalSupply = 2325000000 * (10**18);
    balances[msg.sender] = totalSupply;
    crowdsaleStartTime = 1509364800;
    crowdsaleEndTime = 1512302400;
    startTime = 1509278400;
    endTime = 1512043200;
    tokensSupply = 1250200000 * (10**18);
    rate = 19000;
    wallet = address(0xD6bd7B92f1f6ed1d429c5001D3786c4de0338b19);
    startSale();
  }

  function() payable {
    buy(msg.sender);
  }

  function buy(address buyer) public payable {
    require(!stopped);
    require(buyer != address(0));
    require(msg.value > 0);
    require(now >= startTime && now <= endTime);

    uint tokens = msg.value.mul(rate);
    assert(tokensSupply.sub(tokens) >= 0);

    balances[buyer] = balances[buyer].add(tokens);
    balances[owner] = balances[owner].sub(tokens);
    tokensSupply = tokensSupply.sub(tokens);
    tokensSold = tokensSold.add(tokens);

    assert(wallet.send(msg.value));
    Transfer(this, buyer, tokens);
  }

  function startSale() onlyOwner {
    stopped = false;
    SaleStart();
  }

  function stopSale() onlyOwner {
    stopped = true;
    SaleStop();
  }

  function migrate(address _to, uint _value) onlyOwner returns (bool) {
    require(now < crowdsaleStartTime);
    return super.transfer(_to, _value);
  }

  function transfer(address _to, uint _value) crowdsaleTransferLock returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) crowdsaleTransferLock returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}