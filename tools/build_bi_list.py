#!/usr/bin/env python3

import os
import sys
import json

default_skip_list = ['TensorRT']

def error_exit(msg):
    print(msg)
    sys.exit(1)

def check_file_exists(file):
    if not os.path.isfile(file):
        error_exit(f"File not found: {file}")

def check_file_readable(file):
    check_file_exists(file)
    if not os.access(file, os.R_OK):
        error_exit(f"File not readable: {file}")

def check_dir_exists(dir):
    if not os.path.isdir(dir):
        error_exit(f"Directory not found: {dir}")

def isBlank(string):
    return not (string and string.strip())

def load_bi(file):
    check_file_readable(file)
    lines = []
    with open(file, 'r') as f:
        lines = f.readlines()

    # Process each non empty line and split the = separated key value pairs
    bi = {}
    for line in lines:
        # ignore empty lines
        if line is not isBlank(line):
            if line.strip():
                key, value = line.split('=')
                bi[key.strip()] = value.strip()

    if 'CoreAI_BUILD' not in bi:
        error_exit(f"CoreAI_BUILD not found in {file}")

    return bi['CoreAI_BUILD'], bi

def extract_file_details(file):
    # BuildDetails/25a01/ctpo-12.6.3_2.18.1_2.6.0_4.11.0/BuildInfo.txt

    # Split the file path into components
    path_split = file.split('/')
    if len(path_split) != 4:
        error_exit(f"Invalid file path: {file} [path: {path_split}]]")
    
    release = path_split[1]
    build_info = path_split[2]

    path_value = os.path.join(path_split[0], release, build_info)

    # remove "coreai-" from build_info
    build_info = build_info[7:]

    # then split the remaining string
    components = build_info.split('-')
    headers = components[0]
    versions = components[1].split('_')

    if len(headers) != len(versions):
        error_exit(f"Invalid build info: {file}")

    # Split the build info into components
    cuda_version = None
    if 'c' in headers:
        cuda_location = headers.index('c')
        cuda_version = versions[cuda_location]

    tensorflow_version = None
    if 't' in headers:
        tensorflow_location = headers.index('t')
        tensorflow_version = versions[tensorflow_location]

    pytorch_version = None
    if 'p' in headers:
        pytorch_location = headers.index('p')
        pytorch_version = versions[pytorch_location]

    opencv_version = None
    if 'o' in headers:
        opencv_location = headers.index('o')
        opencv_version = versions[opencv_location]

    return path_value, components[0], components[1], release, cuda_version, tensorflow_version, pytorch_version, opencv_version

def get_dir_list(dir):
    dir_list = []
    check_dir_exists(dir)
    dir_list = [d for d in os.listdir(dir) if os.path.isdir(os.path.join(dir, d))]
    # remove any directory ending in "-built"
    dir_list = [d for d in dir_list if not d.endswith("-built")]
#    print(f" -- Found {len(dir_list)} directories in {dir}")
    return dir_list

def process_BuildDetails(dir):
    print(f" -- Getting release list from {dir}")
    release_list = get_dir_list(dir)

    all_build_info = {}
    for release in sorted(release_list):
        print(f" -- Getting build info list for release: {release}")
        build_info_list = get_dir_list(os.path.join(dir, release))
        for build_info_dir in sorted(build_info_list):
            if any(w in build_info_dir for w in default_skip_list):
                print(f" |  -- SKIPPING build info for build: {build_info_dir}")
                continue

            print(f" |  -- Getting build info for build: {build_info_dir}")
            build_info_file = os.path.join(dir, release, build_info_dir, 'BuildInfo.txt')
            if os.path.isfile(build_info_file):
                path_value, build_comp, version_comp, release_version, cuda_version, tensorflow_version, pytorch_version, opencv_version = extract_file_details(build_info_file)
                build_type, bi = load_bi(build_info_file)
                if build_type not in all_build_info:
                    all_build_info[build_type] = {}
                if build_comp not in all_build_info[build_type]:
                    all_build_info[build_type][build_comp] = {}
                if release_version not in all_build_info[build_type][build_comp]:
                    all_build_info[build_type][build_comp][release_version] = {}
                if version_comp not in all_build_info[build_type][build_comp][release_version]:
                    all_build_info[build_type][build_comp][release_version][version_comp] = {}
                all_build_info[build_type][build_comp][release_version][version_comp] = { 'path': path_value, 'cuda_version': cuda_version, 'tensorflow_version': tensorflow_version, 'pytorch_version': pytorch_version, 'opencv_version': opencv_version, 'bi': bi }
            else:
                print(f" |!!!! Build info file NOT found: {build_info_file}   !!!!!!!!!!!")
    
    return all_build_info

def get_wanted_columns(build_comp):
# Bi structure:
# CoreAI_FROM=nvidia/cuda:12.6.3-devel-ubuntu24.04
# CoreAI_BUILD=GPU
# CoreAI_TENSORFLOW_VERSION=2.18.1
# CoreAI_PYTORCH_VERSION=2.6.0
# CoreAI_CUDA_VERSION=12.6.3
# CoreAI_OPENCV_VERSION=4.11.0
# CoreAI_RELEASE=25a01
# FOUND_UBUNTU=24.04
# OpenCV_built=4.11.0
# CUDA_found=12.6.85
# cuDNN_found=9.5.1
# TensorFlow_pip=2.18.1
# FFmpeg_built=7.1.1
# PyTorch_pip=2.6.0+cu126
# TorchVision_pip=0.21.0+cu126
# TorchAudio_pip=2.6.0+cu126
# TorchData_pip=0.11.0+cpu



    if build_comp == 'to':
        return ['TensorFlow', 'OpenCV', 'FFmpeg', 'Ubuntu'], { 'TensorFlow': 'TensorFlow', 'OpenCV': 'OpenCV', 'FFmpeg': 'FFmpeg', 'Ubuntu': 'FOUND_UBUNTU' }
    elif build_comp == 'po':
        return ['PyTorch', 'OpenCV', 'FFmpeg', 'Ubuntu'], { 'PyTorch': 'PyTorch', 'OpenCV': 'OpenCV', 'FFmpeg': 'FFmpeg', 'Ubuntu': 'FOUND_UBUNTU' }
    elif build_comp == 'tpo':
        return ['TensorFlow', 'PyTorch', 'OpenCV', 'FFmpeg', 'Ubuntu'], { 'TensorFlow': 'TensorFlow', 'PyTorch': 'PyTorch', 'OpenCV': 'OpenCV', 'FFmpeg': 'FFmpeg', 'Ubuntu': 'FOUND_UBUNTU' }
    elif build_comp == 'cto':
        return ['CUDA', 'cuDNN', 'TensorFlow', 'OpenCV', 'FFmpeg', 'Ubuntu'], { 'CUDA': 'CUDA_found', 'cuDNN': 'cuDNN_found', 'TensorFlow': 'TensorFlow', 'OpenCV': 'OpenCV', 'FFmpeg': 'FFmpeg', 'Ubuntu': 'FOUND_UBUNTU' }
    elif build_comp == 'cpo':
        return ['CUDA', 'cuDNN', 'PyTorch', 'OpenCV', 'FFmpeg', 'Ubuntu'], { 'CUDA': 'CUDA_found', 'cuDNN': 'cuDNN_found', 'PyTorch': 'PyTorch', 'OpenCV': 'OpenCV', 'FFmpeg': 'FFmpeg', 'Ubuntu': 'FOUND_UBUNTU' }
    elif build_comp == 'ctpo':
        return ['CUDA', 'cuDNN', 'TensorFlow', 'PyTorch', 'OpenCV', 'FFmpeg', 'Ubuntu'], { 'CUDA': 'CUDA_found', 'cuDNN': 'cuDNN_found', 'TensorFlow': 'TensorFlow', 'PyTorch': 'PyTorch', 'OpenCV': 'OpenCV', 'FFmpeg': 'FFmpeg', 'Ubuntu': 'FOUND_UBUNTU' }
    else:
        error_exit(f" Unknown build type: {build_comp}")

def generate_markdown(abi):
    print(" -- Generating markdown")

    title = "# Available CoreAI Container Images\n"
    toc = ""
    body = ""

    bt_long = {
        'to': 'TensorFlow + OpenCV',
        'po': 'PyTorch + OpenCV',
        'tpo': 'TensorFlow + PyTorch + OpenCV',
        'cto': 'CUDA + TensorFlow + OpenCV',
        'cpo': 'CUDA + PyTorch + OpenCV',
        'ctpo': 'CUDA + TensorFlow + PyTorch + OpenCV',
    }

    auth_search = ["_found", "_built", "_pip"]

    for build_type in sorted(abi.keys()):
        body += f"## {build_type}\n"
        toc += f"  - [{build_type}](#{build_type})\n"
        for build_comp in sorted(abi[build_type].keys()):
            body += f"### {bt_long[build_comp]}\n"
            toc += f"    - [{bt_long[build_comp]}](#{build_comp})\n"
            wanted_cols, wanted_match = get_wanted_columns(build_comp)
            wanted = ['Docker tag'] + wanted_cols
            body += f"| {' | '.join(wanted)} |\n"
            body += f"| {' | '.join(['---' for i in range(len(wanted))])} |\n"
            for release_version in sorted(abi[build_type][build_comp].keys(), reverse=True):
                files = {}
                for version_comp in sorted(abi[build_type][build_comp][release_version].keys()):
                    print(f"  - {build_type} {build_comp} {release_version} {version_comp}")
                    path = abi[build_type][build_comp][release_version][version_comp]['path']

                    dockerfile = os.path.join(path, 'Dockerfile')
                    check_file_readable(dockerfile)

                    ffmpeg_txt = os.path.join(path, 'FFmpeg--Details.txt')
                    check_file_readable(ffmpeg_txt)
                    files['FFmpeg'] = ffmpeg_txt

                    opencv_txt = os.path.join(path, 'OpenCV--Details.txt')
                    check_file_readable(opencv_txt)
                    files['OpenCV'] = opencv_txt

                    torch_txt = os.path.join(path, 'PyTorch--Details.txt')
                    check_file_readable(torch_txt)
                    files['PyTorch'] = torch_txt

                    system_txt = os.path.join(path, 'System--Details.txt')
                    check_file_readable(system_txt)
                    files['Ubuntu'] = system_txt

                    tensorflow_txt = os.path.join(path, 'TensorFlow--Details.txt')
                    check_file_readable(tensorflow_txt)
                    files['TensorFlow'] = tensorflow_txt

                    bi = abi[build_type][build_comp][release_version][version_comp]['bi']

                    line_cols = []
                    for wanted_col in wanted:
                        if wanted_col == wanted[0]:
                            line_cols.append(f"[{version_comp}-{release_version}]({dockerfile})")
                            continue
                        wanted_it = wanted_col
                        if wanted_col in wanted_match:
                            if wanted_match[wanted_col] in bi:
                                wanted_it = wanted_match[wanted_col]
                            else:
                                for add in auth_search:
                                    if wanted_col + add in bi:
                                        wanted_it = wanted_col + add
                                        break

                        if wanted_it not in bi:
                            error_exit(f"Column {wanted_it} not found in {bi}")

                        value = bi[wanted_it]

                        if wanted_col not in files:
                            line_cols.append(value)
                        else:
                            _,x = wanted_it.split("_")
                            y = f"_{x}"
                            p = value
                            if not isBlank(x) and y in auth_search:
                                p += f" ({x})"
                            line_cols.append(f"[{p}]({files[wanted_col]})")

                    body += f"| {' | '.join(line_cols)} |\n"
            body += "\n"

    return title + toc + body

def main():
    if len(sys.argv) != 3:
        error_exit("Usage: build_bi_list.py <BuildDetails dir> <output.md>")
    
    dir = sys.argv[1]
    mdfile = sys.argv[2]

    abi = process_BuildDetails(dir)
# Structure of abi: 
#     abi[build_type][build_comp][release_version][version_comp] = { 'cuda_version': cuda_version, 'tensorflow_version': tensorflow_version, 'pytorch_version': pytorch_version, 'opencv_version': opencv_version, 'bi': bi }
# ex: abi[CPU][tensorflow_pytorch_opencv][20230704][2.12.0_2.0.1_4.7.0] = { "cuda_version": null, "tensorflow_version": "2.12.0", "pytorch_version": "2.0.1", "opencv_version": "4.7.0", "bi": { "CoreAI_FROM": "ubuntu:22.04", ...
#    print(json.dumps(abi, indent=2))

    md = generate_markdown(abi)

    with open(mdfile, 'w') as f:
        f.write(md)
        print(f" -- Markdown written to {mdfile}")
    check_file_readable(mdfile)

    print("Done")
    sys.exit(0)

if __name__ == "__main__":
    main()
