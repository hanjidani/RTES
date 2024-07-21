#include "hardware_monitor.h"
#include <sstream>
#include <iostream>
#include <linux/rtnetlink.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string>
#include <iomanip>
#include <net/if.h>
#include <arpa/inet.h>

HardwareMonitor::HardwareMonitor(SSHConnection& sshConnection) : ssh(sshConnection) {
}

std::pair<float, float> HardwareMonitor::fetchUsage() {
    std::string cpuUsageCommand = "top -bn1 | grep 'Cpu(s)' | " 
                                  "sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | "
                                  "awk '{print 100 - $1}'";
    std::string memUsageCommand = "free | grep Mem | awk '{print $3/$2 * 100.0}'";

    std::string cpuUsageOutput = ssh.executeCommand(cpuUsageCommand);
    std::string memUsageOutput = ssh.executeCommand(memUsageCommand);

    float cpuUsage = std::stof(cpuUsageOutput);
    float memUsage = std::stof(memUsageOutput);

    return {cpuUsage, memUsage};
}

int HardwareMonitor::fetchHighestCpuUsageProcess() {
    std::string command = "ps -eo pid,pcpu --sort=-pcpu | head -2 | tail -1 | awk '{print $1}'";
    std::string result = ssh.executeCommand(command);
    return std::stoi(result);
}

int HardwareMonitor::fetchHighestMemoryUsageProcess() {
    std::string command = "ps -eo pid,pmem --sort=-pmem | head -2 | tail -1 | awk '{print $1}'";
    std::string result = ssh.executeCommand(command);
    return std::stoi(result);
}

void HardwareMonitor::terminateProcess(int pid) {
    std::string command = "kill -9 " + std::to_string(pid);
    ssh.executeCommand(command);
}

std::string HardwareMonitor::fetchCurrentTime() {
    std::string command = "date +\"%Y-%m-%d %H:%M:%S\"";
    return ssh.executeCommand(command);
}

std::string HardwareMonitor::fetchProcessorInfo() {
    std::string command = "lscpu";
    return ssh.executeCommand(command);
}

std::string HardwareMonitor::fetchMemoryInfo() {
    std::string command = "free -h";
    return ssh.executeCommand(command);
}

std::string HardwareMonitor::fetchDiskUsage() {
    std::string command = "df -h";
    return ssh.executeCommand(command);
}

std::string HardwareMonitor::fetchActiveProcesses() {
    std::string command = "top -b -n 1";
    return ssh.executeCommand(command);
}

std::string HardwareMonitor::fetchSSHInfo() {
    std::string command = "ip addr";
    return ssh.executeCommand(command);
}
