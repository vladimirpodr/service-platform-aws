#!/bin/bash
#
# This script is intended to run Terraform consistently.
#
# Based on input arguments it calculates required paths.
# There is no need to execute this script from within the 'bin' folder.
#
# Usage example: bin/terraform.sh -e dev -c core -a plan [-o dev.core.tfplan]
#

function error_and_die {
  echo -e "[ERROR] ${1}" >&2;
  exit 1;
}

function usage() {
  cat <<EOF
Usage: ${0} \\
  -e/--environment   [project environment] \\
  -c/--component     [Environment component] \\
  -a/--action        [Terraform action] \\
  -o/--output-plan   [Terraform plan output file] \\
  -- \\
  <additional arguments to forward to the terraform binary call>
EOF
};

# Test Getopt
getopt_out=$(getopt -T)
if (( $? != 4 )) && [[ -n $getopt_out ]]; then
  error_and_die "Non GNU getopt detected. If you're using a Mac then try 'brew install gnu-getopt'.";
fi

# Process arguments
readonly raw_arguments="${*}";
ARGS=$(getopt \
  -o he:c:a:o: \
  -l "help,environment:,component:,action:,output-plan:" \
  -n "${0}" \
  -- \
  "$@"
);

# Bad arguments
if [ $? -ne 0 ]; then
  usage;
  error_and_die "command line argument parse failure";
fi;

eval set -- "${ARGS}";

declare environment_arg;
declare components_root_folder_name="components";
declare component_arg;
declare action;

while true; do
  case "${1}" in
    -h|--help)
      usage;
      exit 0;
      ;;
    -e|--environment)
      shift;
      if [ -n "${1}" ]; then
        environment_arg="${1}";
        shift;
      fi;
      ;;
    -c|--component)
      shift;
      if [ -n "${1}" ]; then
        component_arg="${1}";
        shift;
      fi;
      ;;
    -a|--action)
      shift;
      if [ -n "${1}" ]; then
        action="${1}";
        shift;
      fi;
      ;;
    -o|--output-plan)
      shift;
      declare output_plan;
      if [ -n "${1}" ]; then
        output_plan="$1";
        shift;
      fi;
      ;;
    --)
      shift;
      break;
      ;;
  esac;
done;

# All arguments supplied after "--"
declare extra_args="${@}";

# Where am I?
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
base_path="${script_path%%\/bin}";
project_name_default="${base_path##*\/}";

status=0;

echo "Args: ${raw_arguments}";

trap echo EXIT;
echo;

# Check arguments and compute paths
## Environment
[ -n "${environment_arg}" ] \
  || error_and_die "Required argument missing: -e/--environment";
declare environment;
environment="${environment_arg}";

# echo "[DEBUG] Environment name: ${environment}"

declare environment_path;
env_file_path="${base_path}/etc/${environment}.tfvars";
[ -f "${env_file_path}" ] || error_and_die "Environment file path ${env_file_path} does not exist";

# echo "[DEBUG] Environment file path: ${env_file_path}"

## Component
[ -n "${component_arg}" ] \
  || error_and_die "Required argument missing: -c/--component";
readonly component="${component_arg}";

declare component_path;
component_path="${base_path}/${components_root_folder_name}/${component}";

if [[ "${component_path}" != /* ]]; then
  component_path="$(cd "$(pwd)/${component_path}" && pwd)";
else
  component_path="$(cd "${component_path}" && pwd)";
fi;

[ -d "${component_path}" ] || error_and_die "Component path ${component_path} does not exist";

# echo "[DEBUG] Component path: ${component_path}"

## Backend
readonly backend_path="${base_path}/backends/${environment}.${component}";
[ -f "${backend_path}" ] || error_and_die "Backend path ${backend_path} does not exist";

# echo "[DEBUG] Backend path: ${backend_path}"

## Action
[ -n "${action}" ] \
  || error_and_die "Required argument missing: -a/--action";

case "${action}" in
  apply)
    refresh="-refresh=true";
    tf_plan_output="${output_plan}";
    ;;
  destroy)
    destroy='-destroy';
    refresh="-refresh=true";
    ;;
  plan)
    refresh="-refresh=true";
    tf_plan_output="-out=${output_plan}";
    ;;
  plan-destroy)
    action="plan";
    destroy="-destroy";
    refresh="-refresh=true";
    ;;
  *)
    ;;
esac;

# Configure the plugin-cache location so plugins are not downloaded to individual components
declare default_plugin_cache_dir="$(pwd)/plugin-cache";
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${default_plugin_cache_dir}}"
mkdir -p "${TF_PLUGIN_CACHE_DIR}" \
  || error_and_die "Failed to created the plugin-cache directory (${TF_PLUGIN_CACHE_DIR})";
[ -w "${TF_PLUGIN_CACHE_DIR}" ] \
  || error_and_die "plugin-cache directory (${TF_PLUGIN_CACHE_DIR}) not writable";

# Clear cache, safe enough as we enforce plugin cache
rm -rf ${component_path}/.terraform;

export TF_IN_AUTOMATION="true";

# Make sure we're running in the component directory
pushd "${component_path}";

# Check TFenv & install
tfenv_bin="$(which tfenv 2>/dev/null)";
if [[ -n "${tfenv_bin}" && -x "${tfenv_bin}" && -f .terraform-version ]]; then
  ${tfenv_bin} install;
fi;

# Compute .tfvars paths
readonly global_vars_file_name="global.tfvars";
readonly global_vars_file_path="${base_path}/etc/${global_vars_file_name}";

declare -a tf_var_file_paths;
[ -f "${global_vars_file_path}" ] && tf_var_file_paths+=("${global_vars_file_path}");
tf_var_file_paths+=("${env_file_path}");

# Warn on duplication for awareness
duplicate_variables="$(cat "${tf_var_file_paths[@]}" | sed -n -e 's/\(^[a-zA-Z0-9_\-]\+\)\s*=.*$/\1/p' | sort | uniq -d)";
[ -n "${duplicate_variables}" ] \
&& echo -e "
################################################
#                   WARNING                    #
################################################
The following variables appear to be duplicated:

${duplicate_variables}

################################################";

# Build up the tfvars arguments
declare tf_var_params;

if [[ "${action}" != "apply" ]] || ([[ "${action}" == "apply" && -z "${output_plan}" ]]); then
  for file_path in "${tf_var_file_paths[@]}"; do
    tf_var_params+=" -var-file=${file_path}";
  done;
fi;

# echo "[DEBUG] TFvars params: ${tf_var_params}"
# echo "[DEBUG] PWD: $(pwd)"

# Let's go!
terraform init -upgrade \
  -backend-config=${backend_path} \
  || error_and_die "Terraform init failed";

case "${action}" in
  'plan')
    terraform "${action}" \
      -input=false \
      ${refresh} \
      ${tf_var_params} \
      ${extra_args} \
      ${destroy} \
      ${tf_plan_output} \
      -parallelism=300;

    status="${?}";

    if [ "${status}" -eq 1 ]; then
      error_and_die "Terraform plan failed";
    fi;

    exit ${status};
    ;;
  'apply'|'destroy')
    echo "Adding to Terraform arguments: -auto-approve=true";
    extra_args+=" -auto-approve=true";

    terraform "${action}" \
      -input=false \
      ${refresh} \
      ${tf_var_params} \
      -parallelism=300 \
      ${extra_args} \
      ${tf_plan_output};
    exit_code=$?;

    if [ ${exit_code} -ne 0 ]; then
      error_and_die "Terraform ${action} failed with exit code ${exit_code}";
    fi;
    ;;
  *)
    error_and_die "Terraform '${action}' action is not supported";
    ;;
esac;

popd;

exit 0;
