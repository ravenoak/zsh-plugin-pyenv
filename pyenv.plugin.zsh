
function _homebrew-installed() {
    type brew &> /dev/null
}

function _pyenv-from-homebrew-installed() {
    brew --prefix pyenv &> /dev/null
}

function setup_pyenv() {
	export PYENV_ROOT="${1}"
	export PATH="${PYENV_ROOT}/bin:${PATH}"
	eval "$(pyenv init --no-rehash - zsh)"
}

function define_pyenv_prompt() {
	function pyenv_prompt_info() {
		if ! ((${+PYENV_VERSION})); then
			export PYENV_VERSION="$(pyenv version | sed 's/ (set by .*version)//')"
		fi
		printf "%s%s%s%s%s" "${OMZSH_PLUGIN_PYENV_PROMPT_PREFIX:-[}" "${OMZSH_PLUGIN_PYENV_PROMT_NAME:-pyenv}" "${OMZSH_PLUGIN_PYENV_PROMPT_SEPARATOR:-:}" "${PYENV_VERSION:- }" "${OMZSH_PLUGIN_PYENV_PROMPT_SUFFIX:-]}"
	}
}

local FOUND_PYENV=0
if ((${+PYENV_ROOT})); then
	if [[ -d ${PYENV_ROOT}/bin && -x ${PYENV_ROOT}/bin/pyenv ]]; then
		FOUND_PYENV=1
		if ! ((${+OMZSH_PLUGIN_PYENV_DISABLE_SETUP})); then
			setup_pyenv ${PYENV_ROOT}
		fi
		define_pyenv_prompt
	fi
elif ! ((${+PYENV_ROOT})) && [[ ${FOUND_PYENV} -eq 0 ]]; then
	if ((${+OMZSH_PLUGIN_PYENV_SEARCH_DIRS})); then
		pyenvdirs=${OMZSH_PLUGIN_PYENV_SEARCH_DIRS}
	elif _homebrew-installed && _pyenv-from-homebrew-installed; then
		pyenvdirs=($(brew --prefix pyenv) "${pyenvdirs[@]}")
	else
		pyenvdirs=("${HOME}/.pyenv" "${HOME}/.lib/pyenv" "/usr/local/pyenv" "/opt/pyenv")
	fi
	for pyenvdir in "${pyenvdirs[@]}" ; do
		FOUND_PYENV=1
		if ! ((${+OMZSH_PLUGIN_PYENV_DISABLE_SETUP})); then
			setup_pyenv ${PYENV_ROOT}
		fi  
		define_pyenv_prompt
		break
	done
	unset pyenvdir
else
	export PY_VERSION=$(python -V 2>&1 | cut -f 2 -d ' ')
fi
unset FOUND_PYENV
