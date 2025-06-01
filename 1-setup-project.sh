


# 1. Install
install() {
    sudo snap install charmcraft --classic
    sudo snap install juju --classic
    sudo snap install multipass
}

# 2. Create new project directory
create_dir() {
    mkdir snap-search-charm
    cd snap-search-charm
}


# 3. Initialize Charm Project
init_charm() {
    charmcraft init --profile machine
}


# 4. Build and Test
build_and_test() {
    charmcraft pack
}

# 5. Deploy and Test
deploy_and_test() {
    juju deploy ./snap-search_ubuntu-22.04-amd64.charm
    juju wait -wv
    juju run-action snap-search/0 search-pattern pattern="test" --wait
}

# 6. Run multi-architecture tests:
run_multi_arch_tests() {
    ./test-multi-arch.sh
}



install