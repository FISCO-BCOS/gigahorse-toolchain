pragma solidity ^0.8.0;

contract TestConsConflict{
    mapping (address => uint256) public map1;
    mapping (uint256 => uint256) public map2;

    function setWithEnv() public {
        map1[msg.sender] = 1;
        map1[tx.origin] = 2;
        map1[address(this)] = 3;
        map2[block.number] = 4;
        map2[block.timestamp] = 5;
    }

    function getWithEnv(uint x) public returns (uint256) {
        if(x == 1){
            return map1[msg.sender];
        }else{
            if(x == 2){
                return map1[tx.origin];
            }else{
                if(x == 3){
                    return map1[address(this)];
                }else{
                    if(x == 4){
                        return map2[block.number];
                    }else{
                        return map2[block.timestamp];
                    }
                }
            }
        }
    }

    function indirectSet() public {
        uint a = block.number;
        map2[a] = 1;
    }

    function dirtySet(uint x) public {
        uint a = block.number + x;
        map2[a] = 1;
    }
}