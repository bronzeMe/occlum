#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd )"

report_error() {
    RED=$(tput setaf 1)
    NO_COLOR=$(tput sgr0)

    cat <<EOF
${RED}error:${NO_COLOR} input is invalid

build_local_image
Build an Occlum Docker image for a specific OS using local source code

USAGE:
    build_local_image.sh <OCCLUM_LABEL> <OS_NAME>

<OCCLUM_LABEL>:
    An arbitrary string chosen by the user to describe the version of Occlum preinstalled in the Docker image, e.g., "latest", "0.12.0", "prerelease", and etc.

<OS_NAME>:
    The name of the OS distribution that the Docker image is based on. Currently, <OS_NAME> must be one of the following values:
        ubuntu22.04         Use Ubuntu 22.04 as the base image

The resulting Docker image will have "occlum/occlum:<OCCLUM_LABEL>-<OS_NAME>-local" as its label.
EOF
    exit 1
}

set -e

if [[ ( "$#" < 2 ) ]] ; then
    report_error
fi

occlum_label=$1
os_name=$2

function check_item_in_list() {
    item=$1
    list=$2
    [[ $list =~ (^|[[:space:]])$item($|[[:space:]]) ]]
}

check_item_in_list "$os_name" "ubuntu22.04" || report_error

# 切换到Occlum根目录，确保Docker构建上下文正确
cd "$script_dir/../.."
docker build -f "$script_dir/Dockerfile.$os_name-local-fast" -t "occlum/occlum:$occlum_label-$os_name-local-fast" .

