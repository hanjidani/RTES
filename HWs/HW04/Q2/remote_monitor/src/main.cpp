#include <iostream>
#include <thread>
#include <chrono>
#include "ssh_connection.h"
#include "hardware_monitor.h"

int CPU_USAGE_MAX = std::stoi(CPU);  // Example threshold
int MEMORY_USAGE_MAX = std::stoi(MEM);  // Example threshold
const int MONITOR_DELAY = 30;  // Monitor every 30 seconds
const std::string remoteHost = RH;
const std::string username = UN;
const std::string password = PASS;
void monitorSystem(SSHConnection& sshConnection) {
    HardwareMonitor monitor(sshConnection);

    while (true) {
        auto [cpuUsage, memoryUsage] = monitor.fetchUsage();
        
        std::cout << "[" << monitor.fetchCurrentTime() << "]\n";
        std::cout << "CPU Usage: " << cpuUsage << "%\n";
        std::cout << "Memory Usage: " << memoryUsage << "%\n";
        
        std::cout << "SSH Information:\n" << monitor.fetchSSHInfo() << "\n";
        std::cout << "Processor Information:\n" << monitor.fetchProcessorInfo() << "\n";
        std::cout << "Memory Information:\n" << monitor.fetchMemoryInfo() << "\n";
        std::cout << "Disk Usage:\n" << monitor.fetchDiskUsage() << "\n";
        std::cout << "Active Processes:\n" << monitor.fetchActiveProcesses() << "\n";

        if (cpuUsage > CPU_USAGE_MAX) {
            std::cout << "Warning: CPU usage exceeds threshold!\n";
            int pid = monitor.fetchHighestCpuUsageProcess();
            std::cout << "Killing process with PID: " << pid << " due to high CPU usage.\n";
            monitor.terminateProcess(pid);
        }

        if (memoryUsage > MEMORY_USAGE_MAX) {
            std::cout << "Warning: Memory usage exceeds threshold!\n";
            int pid = monitor.fetchHighestMemoryUsageProcess();
            std::cout << "Killing process with PID: " << pid << " due to high memory usage.\n";
            monitor.terminateProcess(pid);
        }

        std::this_thread::sleep_for(std::chrono::seconds(MONITOR_DELAY));
    }
}

int main() {
    std::cout << CPU_USAGE_MAX<<std::endl;
    std::cout << MEMORY_USAGE_MAX<<std::endl;
    std::cout << remoteHost<<std::endl;
    std::cout << username<<std::endl;
    std::cout << password<<std::endl;

    SSHConnection sshConnection(remoteHost, username, password);

    if (!sshConnection.establishConnection()) {
        std::cerr << "Failed to establish SSH connection!" << std::endl;
        return 1;
    }

    std::cout << "SSH connection established and authenticated successfully!\n";

    monitorSystem(sshConnection);

    return 0;
}
