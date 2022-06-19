pragma solidity >=0.5.0;

contract SimpleStorage {
  uint storedData;

  function set(uint x, uint y) public {
    storedData = x + y;
  }

  function get() public view returns (uint) {
    return storedData;
  }
}
