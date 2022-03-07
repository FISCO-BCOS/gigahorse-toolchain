pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

struct S {
    uint256 a;
    uint256 b;
}

struct SS {
    string a;
    S b;
    string c;
}

struct SSS {
    uint256 a;
    SS b;
    uint256 c;
}

contract BeCalledContract {
    function getTime() public returns (uint256) {
        return block.timestamp;
    }
}

contract ConflictTest {
    uint256 public fixedSizeVar;
    uint256[] public dynaArray;
    mapping(uint256 => uint256) public simpleMap;
    mapping(address => uint256) public simpleMapForTestEnv;
    mapping(string => uint256) public simpleMapForTestConsStr;
    mapping(uint256 => S) public complexMap;
    string public str;
    S public simpleStruct;

    constructor() public {
        fixedSizeVar = 1;
        dynaArray.push(1);
        simpleMap[1] = 1;
        complexMap[2] = S(1, 2);
        str = "abc";
        simpleStruct = S(1, 2);
    }

    // Fixed-sized（Booleans/Integers/Fixed Point Numbers/Address/Fixed-size byte arrays/...）
    function fixedSizeVarRead() public returns (uint256) {
        return fixedSizeVar; //4, BasicVarConsConflict
    }

    function fixedSizeVarWrite() public {
        fixedSizeVar = 2; //4, BasicVarConsConflict
    }

    // Dynamically-sized (Dynamic Array/Mapping)
    function dynaArrayReadWithConsKey() public returns (uint256) {
        return dynaArray[0]; //4, BasicVarConsConflict DynaVarConsConflict
    }

    function dynaArrayWriteWithConsKey() public {
        dynaArray[1] = 3; //4, BasicVarConsConflict DynaVarConsConflict
    }

    function dynaArrayReadWithFuncArgKey(uint256 i) public returns (uint256) {
        return dynaArray[i]; //3, FunArgConflict 4, BasicVarConsConflict 
    }

    function dynaArrayWriteWithFuncArgKey(uint256 i) public {
        dynaArray[i] = 1; //3, FunArgConflict 4, BasicVarConsConflict 
    }

    function simpleMapReadWithConsKey() public returns (uint256) {
        return simpleMap[1]; //4, BasicVarConsConflict 
    }

    function simpleMapWriteWithIntConsKey() public {
        simpleMap[2] = 3; //4, BasicVarConsConflict 
    }

    function simpleMapWriteWithAddressConsKey() public {
        simpleMapForTestEnv[address(0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359)] = 1;  //4, BasicVarConsConflict 
    }

    function simpleMapWriteWithStringConsKey() public {
        simpleMapForTestConsStr["test"] = 1; //DynaVarConsConflict
    }

    function simpleMapReadWithEnvKey(uint256 x) public returns (uint256) {
        if (x == 1) {
            return simpleMapForTestEnv[msg.sender]; //2, EnvConflict(CALLER)
        } else {
            if (x == 2) {
                return simpleMapForTestEnv[tx.origin]; //2, EnvConflict(ORIGIN)
            } else {
                if (x == 3) {
                    return simpleMapForTestEnv[address(this)]; //2, EnvConflict(ADDRESS)
                } else {
                    if (x == 4) {
                        return simpleMap[block.number]; //2, EnvConflict(NUMBER)
                    } else {
                        return simpleMap[block.timestamp]; //2, EnvConflict(TIMESTAMP)
                    }
                }
            }
        }
    }

    function simpleMapWriteWithEnvKey() public {
        simpleMapForTestEnv[msg.sender] = 1; //2, EnvConflict(CALLER)
        simpleMapForTestEnv[tx.origin] = 2; //2, EnvConflict(ORIGIN)
        simpleMapForTestEnv[address(this)] = 3; //2, EnvConflict(ADDRESS)
        simpleMap[block.number] = 4; //2, EnvConflict(NUMBER)
        simpleMap[block.timestamp] = 5; //2, EnvConflict(TIMESTAMP)
    }

    function simpleMapReadWithFuncArgKey(uint256 i) public returns (uint256) {
        return simpleMap[i]; //3, FunArgConflict
    }

    function simpleMapWriteWithFuncArgKey(uint256 i) public {
        simpleMap[i] = 1; //3, FunArgConflict
    }

    function simpleMapWriteWithPartStructFuncArgKey(S calldata s) public {
        simpleMap[s.b] = 1; //3, FunArgConflict
    }

    function simpleMapWriteWithPartStructFuncArgKey2(uint256 x, S calldata s)
        public
    {
        simpleMap[s.b] = 1; //3, FunArgConflict
        simpleMap[x] = 2; //3, FunArgConflict
    }

    function simpleMapWriteWithPartStructFuncArgKey3(uint256 x, SS calldata ss)
        public
    {
        simpleMap[ss.b.b] = 1; //0, MixConflict
    }

    function simpleMapWriteWithPartStructFuncArgKey3(
        uint256 a,
        SSS calldata sss,
        uint256 c
    ) public {
        simpleMap[sss.b.b.b] = 1; //0, MixConflict
    }

    function simpleMapWriteWithPartStructFuncArgKey4(
        uint256 a,
        uint256[] calldata b,
        uint256 c
    ) public {
        simpleMap[b[0]] = 1; //0, MixConflict
    }

    function simpleMapWriteWithPartStructFuncArgKey5(
        uint256 a,
        uint256[5] calldata b,
        uint256 c
    ) public {
        simpleMap[b[0]] = 1; //3, FunArgConflict
    }

    function simpleMapIndirectWriteWithEnvKey() public {
        uint256 a = block.number;
        simpleMap[a] = 1; //2, EnvConflict(NUMBER)
    }

    function simpleMapWriteWithMixKey(uint256 x) public {
        simpleMap[block.number + x] = 1; //0, MixConflict
    }

    function complexMapReadWithConsKey() public returns (uint256) {
        return complexMap[1].a; //4, BasicVarConsConflict
    }

    function complexMapWriteWithConsKey() public {
        complexMap[3] = S(1, 2); //4, BasicVarConsConflict
    }

    // Special (Struct/String)
    function StrRead() public returns (string memory) {
        return str; //4, BasicVarConsConflict
    }

    function StrWrite() public {
        str = "efg"; //4, BasicVarConsConflict
    }

    function simpleStructRead() public returns (uint256) {
        return simpleStruct.a; //4, BasicVarConsConflict
    }

    function simpleStructWrite() public {
        simpleStruct.a = 2; //4, BasicVarConsConflict
    }

    // No storage access
    function noStorageAccessAndContractCalling(uint256 x)
        public
        returns (uint256)
    {
        return x; //5, NoConflict
    }

    function noStorageAccessHasContractCalling(address addr)
        public
        returns (uint256)
    {
        return BeCalledContract(addr).getTime(); //0, NoStorageAccessHasContractCalling
    }
}
