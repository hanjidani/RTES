#ifndef HARDWARE_MONITOR_H
#define HARDWARE_MONITOR_H

#include "ssh_connection.h"
#include <utility>
#include <string>

class HardwareMonitor {
public:
    HardwareMonitor(SSHConnection& sshConnection);
    std::pair<float, float> fetchUsage();
    int fetchHighestCpuUsageProcess();
    int fetchHighestMemoryUsageProcess();
    std::string fetchProcessorInfo();
    std::string fetchMemoryInfo();
    std::string fetchDiskUsage();
    std::string fetchActiveProcesses();
    std::string fetchCurrentTime();
    std::string fetchSSHInfo();
    void terminateProcess(int pid);
private:
    SSHConnection& ssh;
};

#endif
