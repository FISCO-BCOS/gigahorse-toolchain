import sys

# Ground true of test cases
ground_true_dict = {
    "Conflict_ConsConflict.csv":[
        ["0xd9fb343f", "0x679795a0195a1b76cdebb7c51d74e058aee92919b8c3389af86ef24535e8a28c"],
        ["0xe2a57b9a", "0x6"],
        ["0xd3619794", "0x0"],
        ["0xac0f72ac", "0x1"],
        ["0xb4a0b5e6", "0xe90b7bceb6e7df5418fb78d8ee546e97c83a08bbccc01a0644d599ccd2a7c2e0"],
        ["0x845aba0c", "0x6"],
        ["0x92bddf08", "0x1"],
        ["0x9ba2a7c2", "0x1"],
        ["0x9e935dc6", "0x1"],
        ["0x6a446b88", "0xabd6e7cb50984ff9c2f3e18a2660c3353dadf4e3291deeb275dae2cd1e44fe05"],
        ["0x7ea33fd1", "0x5"],
        ["0x398fbc22", "0x0"],
        ["0x4db0cdb2", "0x5"],
        ["0x11eaad06", "0x2e174c10e159ea99b867ce3205125c24a42d128804e4070ed6fcc8cc98166aa0"]
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
        ["0xc158e6ef", "1", "MAP++[0x2]++0"],
        ["0xac0f72ac", "0", "ARRAY++[0x1]++0"],
        ["0x9e935dc6", "0", "ARRAY++[0x1]++0"],
        ["0x1bfdff", "0", "MAP++[0x2]++0"]
    ],
    "Conflict_MixConflict.csv":[
        ["0x5ed8a780", "MAP++[0x2]++0"],
        ["0x92bddf08", "ARRAY++[0x1]++0"],
        ["0x9ba2a7c2", "ARRAY++[0x1]++0"],
        ["0x7ea33fd1", "ARRAY++[0x5]++0"],
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
    with open("./.temp/conflict_analysis-opt/out/" + file_name, "r") as f:
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