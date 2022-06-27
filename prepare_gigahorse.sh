#!/bin/bash
set -e

script_dir="$(cd "$(dirname "$0")" && pwd)"
current_dir="$(pwd)"
output_dir=${script_dir}/bin/
flags="-static -fopenmp"
sed_cmd="sed -i"
base64_cmd="base64 -w0"
OS=$(uname)
arch=$(uname -m)
base64_str_var_name="base64_${arch}_tar"

if [ "$(uname)" == "Darwin" ];then
    flags=""
    sed_cmd="sed -i .bak"
    base64_cmd="base64"
    if [ "$(uname -m)" == "arm64" ];then
        base64_str_var_name="base64_aarch64_tar"
    fi
fi

download_compile_souffle() {
    echo "Downloading and compiling Souffle"
    if [ ! -f souffle-2.2.tar.gz ]; then
        wget https://codeload.github.com/souffle-lang/souffle/tar.gz/refs/tags/2.2 -O souffle-2.2.tar.gz
        tar -zxf souffle-2.2.tar.gz
    fi
    cd souffle-2.2
    ${sed_cmd} 's/-Werror/-Wno-error/g' src/CMakeLists.txt
    mkdir -p build && cd build
    cmake -DSOUFFLE_USE_SQLITE=off -DSOUFFLE_USE_ZLIB=off -DBUILD_TESTING=off -DSOUFFLE_USE_CURSES=off \
        -DSOUFFLE_ENABLE_TESTING=off -DSOUFFLE_USE_OPENMP=on -DCMAKE_BUILD_TYPE=Release ..
    make -j4
    cd $current_dir
}

compile_gigahorse() {
    echo "Compiling gigahorse Souffle-addon"
    cp souffle_addon_Makefile souffle-addon/Makefile
    cd souffle-addon
    make -j2
    cd $current_dir
    mkdir -p "${output_dir}"
    files=("clientlib/function_inliner.dl" "logic/main.dl" "clients/simple_conflict_analysis.dl")
    for file in "${files[@]}";do
        target="$(basename $file .dl)"
        if [ ! -f "${output_dir}/${target}_compiled" ];then
            souffle -g "${output_dir}/$target.cpp" "${file}"
            echo "Compiling $target"
            c++ -O3 -std=c++17 ${flags} -o "${output_dir}/${target}_compiled" "${output_dir}/$target.cpp" -I$current_dir/souffle-2.2/src/include -lpthread -ldl $current_dir/souffle-addon/libfunctors.a
            strip "${output_dir}/${target}_compiled"
            rm "${output_dir}/$target.cpp"
        fi
    done
}

generate_static_analysis_script() {
    cp -r dist/generatefacts ${output_dir}/
    cd ${output_dir}/..
    tar -jcf tools.tar.bz2 -C ${output_dir} .
    base64_str="$(${base64_cmd} tools.tar.bz2)"
    cd $current_dir
    ${sed_cmd} -f /dev/stdin evm_static_analysis.sh <<EOF
s#${base64_str_var_name}=#${base64_str_var_name}=\"${base64_str}\"#g
EOF
    ${sed_cmd} -f /dev/stdin evm_static_analysis.sh <<EOF
s#OS=#OS=\"${OS}\"#g
EOF
}

compile_conflict_analysis() {
    echo "Compiling conflict analysis"
    cd tools/conflicts_info_parse
    cargo build --release -j2
    cp target/release/conflicts_info_parse ${output_dir}/conflicts_info_parse
    cd $current_dir
}

main() {
    pip3 install pyinstaller
    pyinstaller -s generatefacts
    export PATH=$current_dir/souffle-2.2/build/src:$PATH
    if [ ! -f $current_dir/souffle-2.2/build/src/souffle ];then
        download_compile_souffle
    fi
    compile_gigahorse
    compile_conflict_analysis
    generate_static_analysis_script
}

main
