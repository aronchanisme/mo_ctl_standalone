#!/bin/bash
# deploy

function git_clone()
{
    # 1. git clone
    rc=0
    mo_version=$1
    force=$2

    try_times=10


    if [[ -d "${MO_PATH}" ]] && [[ "`ls ${MO_PATH} | wc -l`" != "0" ]]; then
        if [[ "${force}" != "force" ]]; then
            add_log "INFO" "${MO_PATH} already exists and not empty, will skip git clone and check out"
            return 0
        fi
    fi 

    if [[ "${MO_PATH}" != "" ]] ; then
        cd ${MO_PATH} && rm -rf ./* && rm -rf ./.* >/dev/null 2>&1
    fi

    mkdir -p ${MO_PATH}
    add_log "INFO" "Deploying mo on path ${MO_PATH}"
    for ((i=1;i<=${try_times};i++));do
        add_log "INFO" "Try number: $i"
        add_log "INFO" "cd ${MO_PATH}/.. && git clone ${MO_GIT_URL}"
        if cd ${MO_PATH}/.. && git clone ${MO_GIT_URL};then
            add_log "INFO" "Git clone succeeded."
            add_log "INFO" "checking out to version ${mo_version}"
            if cd ${MO_PATH} && git checkout ${mo_version}; then
                add_log "INFO" "Check out succeeded."
            else
                add_log "ERROR" "Check out failed, please check mo version, exiting"
                rc="1"                     
            fi
            # git clone ok, breaking the loop
            break;
        fi

        if [[ "${rc}" == "1" ]] ;then
            # checkout failed, breaking the loop
            break;
        fi
    done

    if [[ "${rc}" == "1" ]] ;then
        add_log "ERROR" "All tries on git clone have failed. Exiting"
    fi

    return ${rc}


}


function build_mo_service()
{
    # mo-service
    add_log "INFO" "Try to build mo-service: make build"
    if cd ${MO_PATH}/ && make build ; then
        add_log "INFO" "Build succeeded"
    else
        add_log "ERROR" "Build failed"
        return 1
    fi


}

function build_mo_dump()
{
    add_log "INFO" "Try to build mo-dump: make build modump"
    if cd ${MO_PATH}/ && make build modump; then
        add_log "INFO" "Build succeeded"
    else
        add_log "ERROR" "Build failed"
        return 1
    fi
}


function build()
{
    force=$1

    if [[ "${GOPROXY}" != "" ]]; then
        go env -w GOPROXY=https://goproxy.cn,direct
    fi

    if [[ "${force}" == "force" ]]; then
        build_mo_service
        build_mo_dump
    else
        if [[ -f "${MO_PATH}/mo-service" ]]; then
            add_log "INFO" "mo-service is already built on ${MO_PATH}, no need to build"
        else
            build_mo_service
        fi

        if [[ -f "${MO_PATH}/mo-dump" ]]; then
            add_log "INFO" "mo-dump is already built on ${MO_PATH}, no need to build"
        else
            build_mo_dump
        fi
    fi
}

function deploy()
{
    mo_version=$1
    force=$2

    # set default version
    if [[ ${mo_version} == "" ]]; then 
        mo_version=${MO_DEFAULT_VERSION}
    elif [[ ${mo_version} == "force" ]]; then
        mo_version=${MO_DEFAULT_VERSION}
        force="force"        
    fi


    # 0. Precheck
    if ! precheck; then
        add_log "INFO" "Precheck failed, exiting"
        return 1
    else
        add_log "INFO" "Precheck passed, deploying mo now"
    fi

    # 1. Install
    if ! git_clone ${mo_version} ${force}; then
        return 1
    fi

    # 2. Build
    if ! build ${force}; then
        return 1
    fi

    # 3. Create logs folder
    add_log "INFO" "Creating mo logs path in case it does not exist"
    mkdir -p ${MO_LOG_PATH}
    add_log "INFO" "Deoloy succeeded"

}