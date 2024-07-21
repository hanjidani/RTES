#include "ssh_connection.h"
#include <libssh/libssh.h>
#include <iostream>

SSHConnection::SSHConnection(const std::string& host, const std::string& user, const std::string& pass)
    : hostname(host), username(user), password(pass), sshSession(nullptr) {
}

bool SSHConnection::establishConnection() {
    sshSession = ssh_new();
    if (sshSession == nullptr) return false;

    ssh_options_set(sshSession, SSH_OPTIONS_HOST, hostname.c_str());
    ssh_options_set(sshSession, SSH_OPTIONS_USER, username.c_str());

    int rc = ssh_connect(sshSession);
    if (rc != SSH_OK) {
        std::cerr << "Error connecting to " << hostname << ": " << ssh_get_error(sshSession) << std::endl;
        return false;
    }

    rc = ssh_userauth_password(sshSession, nullptr, password.c_str());
    if (rc != SSH_AUTH_SUCCESS) {
        std::cerr << "Authentication failed: " << ssh_get_error(sshSession) << std::endl;
        return false;
    }

    return true;
}

std::string SSHConnection::executeCommand(const std::string& command) {
    ssh_channel sshChannel = ssh_channel_new(sshSession);
    if (sshChannel == nullptr) return "";

    int rc = ssh_channel_open_session(sshChannel);
    if (rc != SSH_OK) {
        ssh_channel_free(sshChannel);
        return "";
    }

    rc = ssh_channel_request_exec(sshChannel, command.c_str());
    if (rc != SSH_OK) {
        ssh_channel_close(sshChannel);
        ssh_channel_free(sshChannel);
        return "";
    }

    char buffer[256];
    std::string result;
    int nbytes;

    while ((nbytes = ssh_channel_read(sshChannel, buffer, sizeof(buffer), 0)) > 0) {
        result.append(buffer, nbytes);
    }

    ssh_channel_close(sshChannel);
    ssh_channel_free(sshChannel);

    return result;
}

SSHConnection::~SSHConnection() {
    if (sshSession != nullptr) {
        ssh_disconnect(sshSession);
        ssh_free(sshSession);
    }
}
