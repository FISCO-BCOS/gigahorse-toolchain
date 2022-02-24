#!/bin/bash
set -e

OS=
use_sm3=
analysis_tools_path="$HOME/.fisco/static_analysis_tools/"
tools_tar="${analysis_tools_path}/tools.tar.gz"
main_bin="${analysis_tools_path}/main_compiled"
function_inliner_bin="${analysis_tools_path}/function_inliner_compiled"
simple_conflict_analysis_bin="${analysis_tools_path}/simple_conflict_analysis_compiled"
gigahorse_generate="${analysis_tools_path}/generatefacts"
conflicts_info_parse="${analysis_tools_path}/conflicts_info_parse"
local_arch="$(uname -m)"

LOG_WARN() {
    local content=${1}
    echo -e "\033[31m[WARN] ${content}\033[0m"
}

LOG_INFO() {
    local content=${1}
    echo -e "\033[32m[INFO] ${content}\033[0m"
}

LOG_ERROR() {
    local content=${1}
    echo -e "\033[31m[Error] ${content}\033[0m"
    exit 1
}

check_env() {
    local local_platform="$(uname)"
    if [ "$local_platform" != "${OS}" ];then
        LOG_ERROR "The target OS is ${OS}, but the current OS is ${local_platform}"
    fi
}

parse_params() {
    while getopts "a:b:go:h" option;do
        case $option in
        a) abi_json=$OPTARG;;
        b) opcodes=$OPTARG;;
        g) use_sm3="-g";;
        o) temp_ouput_dir="$OPTARG";;
        h) help;;
        esac
    done
}

prepare_analysis_tools() {
    if [[ ! -f "${main_bin}" || ! -f "${function_inliner_bin}" || ! -f "${simple_conflict_analysis_bin}" || ! -f "${gigahorse_generate}" ]];then
        mkdir -p "${analysis_tools_path}"
        base64_aarch64_tar=
        base64_x86_64_tar=
        if [[ "${local_arch}" == "x86_64" ]];then
            echo "The current arch is ${local_arch} should be x86_64"
            base64_tar="${base64_x86_64_tar}"
        else # aarch64
            echo "The current arch is ${local_arch} should be aarch64"
            base64_tar="${base64_aarch64_tar}"
        fi
        echo ${base64_tar} | base64 -d - > ${tools_tar}
        tar -jxf ${tools_tar} -C "${analysis_tools_path}" && rm ${tools_tar}
        chmod u+rx ${main_bin} ${function_inliner_bin} ${simple_conflict_analysis_bin} ${gigahorse_generate}
        if [ "${OS}" == "Darwin" ];then
            xattr -d com.apple.quarantine ${main_bin} ${function_inliner_bin} ${simple_conflict_analysis_bin} ${gigahorse_generate} || :
        fi
    fi
}

help() {
    cat << EOF
Usage:
    -a file          [Required] path of contract abi json file
    -b file          [Required] path of contract bin file
    -g               [Optional] if use sm3 as hash algorithm
    -h Help
e.g
    $0 -a HelloWorld.abi -b HelloWorld.bin
EOF

exit 0
}

parse_runtime_codes() {
    local codes=$1
    local codes_str="$(cat ${codes})"
    codes_str=${codes_str#*6000396000f3}
    runtime_code_str=${codes_str:2}
}

main() {
    check_env
    parse_params $@
    if [ -z "${temp_ouput_dir}" ];then
        temp_ouput_dir="${analysis_tools_path}/analysis_result"
        rm -rf "${temp_ouput_dir}"
        mkdir -p ${temp_ouput_dir}
    fi
    runtime_code="${temp_ouput_dir}/runtime_bin"
    rm -rf "${temp_ouput_dir}" && mkdir -p ${temp_ouput_dir}
    parse_runtime_codes $opcodes
    echo ${runtime_code_str} > ${runtime_code}
    prepare_analysis_tools
    ${gigahorse_generate} ${runtime_code} ${temp_ouput_dir}/
    echo "8" > ${temp_ouput_dir}/MaxContextDepth.csv
    result_dir="${temp_ouput_dir}/result_csvs"
    mkdir -p ${result_dir}
    ln -s ${temp_ouput_dir}/bytecode.hex ${result_dir}/bytecode.hex
    ${main_bin} --facts=${temp_ouput_dir}/ --output=${result_dir}
    for i in {0..3}; do
        ${function_inliner_bin} --facts=${result_dir} --output=${result_dir}
    done
    ${simple_conflict_analysis_bin} --facts=${result_dir} --output=${result_dir}
    ${conflicts_info_parse} -p ${result_dir} -a ${abi_json} ${use_sm3}
}

main $@
