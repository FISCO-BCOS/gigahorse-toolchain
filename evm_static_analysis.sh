#!/bin/bash
set -e

OS=
use_sm3=
analysis_tools_path="$HOME/.fisco/static_analysis_tools/"
tools_tar="${analysis_tools_path}/tools.tar.gz"
main_bin="${analysis_tools_path}/main_compiled"
function_inliner_bin="${analysis_tools_path}/function_inliner_compiled"
simple_conflict_analysis_bin="${analysis_tools_path}/simple_conflict_analysis_compiled"
gigahorse_generate="${analysis_tools_path}/generate"
force_aarch64=""

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
    local local_OS=$(uname)
    local local_arch=$(uname -m)
    if [ "$local_OS" != "${OS}" ];then
        LOG_ERROR "The target OS is ${OS}, but the current OS is ${local_OS}"
    fi
    # if [ "$local_arch" != "${arch}" ];then
    #     LOG_ERROR "The target arch is ${arch}, but the current arch is ${local_arch}"
    # fi
}

parse_params() {
    while getopts "a:b:gA" option;do
        case $option in
        a) abi_json=$OPTARG;;
        b) opcodes=$OPTARG;;
        g) use_sm3="true";;
        A) force_aarch64="true";;
        h) help;;
        esac
    done
}

prepare_analysis_tools() {
    if [[ ! -f "${main_bin}" || ! -f "${function_inliner_bin}" || ! -f "${simple_conflict_analysis_bin}" || ! -f "${gigahorse_generate}" ]];then
        mkdir -p "${analysis_tools_path}"
        if [[ "arch" == "aarch64" || ! -z "${force_aarch64}" ]];then
            base64_aarch64_tar=
            base64_tar="${base64_aarch64_tar}"
        else # x86_64
            base64_x86_64_tar=
            base64_tar="${base64_x86_64_tar}"
        fi
        echo ${base64_tar} | base64 -d - > ${tools_tar}
        tar -zxf ${tools_tar} -C "${analysis_tools_path}" && rm ${tools_tar}
        chmod a+rx ${main_bin} ${function_inliner_bin} ${simple_conflict_analysis_bin} ${gigahorse_generate}
    fi
}

help() {
    cat << EOF
Usage:
    -a file          [Required] path of contract abi json file
    -b file          [Required] path of contract bin file
    -g               [Optional] if use sm3 as hash algorithm
    -A               [Optional] force script to consider the platform is aarch64
    -h Help
e.g
    $0 -a HelloWorld.abi -b HelloWorld.bin
EOF

exit 0
}

main() {
    check_env
    parse_params "$@"
    # TODO: analysis process
    temp_ouput_dir="${analysis_tools_path}/temp"
    rm -rf "${temp_ouput_dir}" && mkdir -p ${temp_ouput_dir}
    ${gigahorse_generate} ${opcodes} ${temp_ouput_dir}/
    mkdir -p ${temp_ouput_dir}/out
    ln -s ${temp_ouput_dir}/bytecode.hex ${temp_ouput_dir}/out/bytecode.hex
    ${main_bin} --facts=${temp_ouput_dir}/ --output=${temp_ouput_dir}/out
    for i in {0..3};do
        ${function_inliner_bin} --facts=${temp_ouput_dir}/out --output=${temp_ouput_dir}/out
    done
    ${simple_conflict_analysis_bin} --facts=${temp_ouput_dir}/out --output=${temp_ouput_dir}/out
}

