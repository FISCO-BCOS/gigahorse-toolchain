pragma solidity ^0.8.0;

struct S {
    uint256 a;
    uint256 b;
}

contract TestConsConflict{
    uint256 public common;
    S public struct1;
    mapping (uint256 => uint256) public map1;
    mapping (uint256 => S) public map2;
    uint256[] public array;
    string public str;

    constructor() {
        common = 1;
        struct1 = S(1,2);
        map1[1] = 1;
        map2[2] = S(1,2);
        array.push(1);
        str = "abc";
    }
    
    function commonRead() public returns (uint256){
        return common;
    }
    function commonWrite() public {
        common = 2;
    }

    function structRead() public returns (uint256){
        return struct1.a;
    }
    function structWrite() public {
        struct1.a = 2;
    }

    function strRead() public returns (string memory){
        return str;
    }
    function strWrite() public {
        str = "efg";
    }

    function map1Read() public returns (uint256){
        return map1[1];
    }
    function map1Write() public {
        map1[2] = 3;
    }

    function arrayRead() public returns (uint256){
        return array[0];
    }
    function arrayWrite() public {
        array[0] = 3;
    }

    function map2Read() public returns (uint256){
        return map2[1].a;
    }
    function map2Write() public {
        map2[3] = S(1,2);
    }
}