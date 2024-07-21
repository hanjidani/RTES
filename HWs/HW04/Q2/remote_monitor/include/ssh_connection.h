#ifndef SSH_CONNECTION_H
#define SSH_CONNECTION_H

#include <string>
#include <libssh/libssh.h>

class SSHConnection {
public:
    SSHConnection(const std::string& host, const std::string& user, const std::string& pass);
    bool establishConnection();
    std::string executeCommand(const std::string& command);
    ~SSHConnection();

private:
    std::string hostname;
    std::string username;
    std::string password;
    ssh_session sshSession;
};

#endif
