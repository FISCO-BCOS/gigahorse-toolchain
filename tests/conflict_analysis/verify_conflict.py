import sys
import os

# Ground true of test cases
ground_true_dict = {
    "Conflict_BasicVarConsConflict.csv":[
        ["0xe2a57b9a", "0x7"],
        ["0xd3619794", "0x0"],
        ["0xac0f72ac", "0x1"],
        ["0xb4a0b5e6", "0xe90b7bceb6e7df5418fb78d8ee546e97c83a08bbccc01a0644d599ccd2a7c2e0"],
        ["0x7ea33fd1", "0x6"],
        ["0x845aba0c", "0x7"],
        ["0x92bddf08", "0x1"],
        ["0x9ba2a7c2", "0x1"],
        ["0x9e935dc6", "0x1"],
        ["0x6a446b88", "0x1471eb6eb2c5e789fc3de43f8ce62938c7d1836ec861730447e2ada8fd81017b"],
        ["0x398fbc22", "0x0"],
        ["0x4db0cdb2", "0x6"],
        ["0x11eaad06", "0xa9bc9a3a348c357ba16b37005d7e6b3236198c0e939f4af8c5f19b8deeb8ebc0"],
        ["0x9aa88eec", "0x149a91bf4c41725a2a136ad8d174381b837c1dc936a6e6bdd39f733175126b28"],
        ["0x5d3c131c", "0x679795a0195a1b76cdebb7c51d74e058aee92919b8c3389af86ef24535e8a28c"]
    ],
    "Conflict_DynaVarConsConflict.csv":[
        ["0x92bddf08", "ARRAY++[0x1]++0", "0x0"],
        ["0x9ba2a7c2", "ARRAY++[0x1]++0", "0x1"],
        ["0xf40f719f", "MAP++[0x4]++0", "0x7465737400000000000000000000000000000000000000000000000000000000"]
    ],
    "Conflict_EnvConflict.csv":[
        ["0xa8f3ceeb", "NUMBER", "MAP++[0x2]++0"],
        ["0xe9f93afd", "CALLER", "MAP++[0x3]++0"],
        ["0xe9f93afd", "ORIGIN", "MAP++[0x3]++0"],
        ["0xe9f93afd", "ADDRESS", "MAP++[0x3]++0"],
        ["0xe9f93afd", "NUMBER", "MAP++[0x2]++0"],
        ["0xe9f93afd", "TIMESTAMP", "MAP++[0x2]++0"],
        ["0xe6c96f77", "CALLER", "MAP++[0x3]++0"],
        ["0xe6c96f77", "ORIGIN", "MAP++[0x3]++0"],
        ["0xe6c96f77", "ADDRESS", "MAP++[0x3]++0"],
        ["0xe6c96f77", "NUMBER", "MAP++[0x2]++0"],
        ["0xe6c96f77", "TIMESTAMP", "MAP++[0x2]++0"]
    ],
    "Conflict_FunArgConflict.csv":[
        ["0xeba52dda", "0", "MAP++[0x2]++0"],
        ["0xe407048d", "2", "MAP++[0x2]++0"],
        ["0xe407048d", "0", "MAP++[0x2]++0"],
        ["0xc158e6ef", "1", "MAP++[0x2]++0"],
        ["0xac0f72ac", "0", "ARRAY++[0x1]++0"],
        ["0xb0e58bbc", "1", "MAP++[0x2]++0"],
        ["0x9e935dc6", "0", "ARRAY++[0x1]++0"],
        ["0x1bfdff", "0", "MAP++[0x2]++0"]
    ],
    "Conflict_MixConflict.csv":[
        ["0x5ed8a780"],
        ["0xd62c3d7c"],
        ["0x74d19b4b"],
        ["0x3894de57"]
    ],
    "Conflict_NoConflict.csv":[
        ["0x16c5ae5e"]
    ],
    "Conflict_NoStorageAccessHasContractCalling.csv":[
        ["0xe7ba68d0"]
    ]
}
num_success_analysis = 0
for file_name in ground_true_dict.keys():
    num_match_ground_true = 0
    
    with open(os.environ['HOME'] + "/.fisco/static_analysis_tools/analysis_result/result_csvs/" + file_name, "r") as f:
        lines = f.readlines()
    for i in range(len(ground_true_dict[file_name])):
        stop_flag = True
        gt = "\t".join(ground_true_dict[file_name][i])
        for line in lines:
            if gt in line:
                stop_flag = False
                break
        if stop_flag:
            print("Error: " + file_name + " not as expected.")
            break
        else:
            num_match_ground_true += 1
    if num_match_ground_true == len(ground_true_dict[file_name]):
        num_success_analysis +=1
    else:
        break

if num_success_analysis == len(ground_true_dict):
    sys.exit(0)
else:
    sys.exit(1)