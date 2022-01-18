pragma solidity ^0.8.0;

struct S {
    uint256 a;
    uint256 b;
}

contract TestFucArgConflict{
    uint256[] array;
    mapping (uint256 => uint256) public map1;
    mapping (uint256 => S) public map2;

    function set1(uint256 i) public {
        array[i] = 1;
    }
    function get1(uint256 i) public returns (uint) {
        return array[i];
    }

    function set2(uint256 i) public {
        map1[i] = 1;
    }
    function get2(uint256 i) public returns (uint) {
        return map1[i];
    }

    function set3(S calldata s) public {
        map1[s.a] = 1;
    }

    function set4(uint256 i) public {
        map1[i + block.timestamp] = 1;
    }
}