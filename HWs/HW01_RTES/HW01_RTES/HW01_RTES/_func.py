# Public libraries:
import math
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
import os

def file_reader(path):
    char_map={'[':'', ' ':'', ']':'', '\n':''}
    with open(Path(path), "r") as file:
        out = []
        for line in file:
            l = list(filter(None, line.translate(str.maketrans(char_map)).split(';')))
            out.append([list(map(int, list(filter(None, e.split(','))))) for e in l])
    return out


def file_writer(results, path):
    with open(Path(path), "w") as file:
        for result in results:
            line = ""
            for task in result:
                e_str = ""
                for e in task: e_str += str(e) + ","
                line += f"[{e_str}];"
            file.write(line + "\n")


def save_figs_ed(examples, results, title, path, time_limit = 40):
    # Your code goes here.
    for i in range(len(examples)):
        exp = examples[i]
        T, C, D = exp[0], exp[1], exp[2]
        n = len(T)
        result = results[i]
        n_res = len(result)
        # if n_res == n + 1:
        fig, gnt = plt.subplots()
        gnt.set_xlabel('Real-Time Clock')
        gnt.set_ylabel('Tasks')
        gnt.set_title(title)
        gnt.set_ylim(-1.5, n)
        gnt.set_xlim(0, time_limit)
        gnt.set_yticks(range(n))
        gnt.set_yticklabels(['Task' + str(n - x + 1) +'(C='+str(C[n-x])+')' for x in range(1,n+1)])
        gnt.grid(True)
        result = result[::-1]
        for j in range(1, n + 1):
            for t in range(time_limit):
                if result[j][t] == 1:
                    if result[0][t] == 1:
                        gnt.broken_barh([(t, 1)], (-1.5+j, 1), facecolors='orange')
                        # gnt.add_line()
                    else:
                        gnt.broken_barh([(t, 1)], (-1.5+j, 1), facecolors='green')
            # for dl in DLs[j]:
                # gnt.axvline(x=dl,ymin=-1.5+j, ymax=-0.5+j, color='red', linestyle='-', linewidth=1)
        T = T[::-1]
        D = D[::-1]
        for t in range(time_limit):
            for j in range(len(T)):
                if t % T[j] == 1:
                    gnt.broken_barh([(t - 1, 0.25)], (j, 0.5), facecolors = 'black')
                    gnt.broken_barh([(t - 1 + D[j], 0.25)], (-0.5+j, 0.5), facecolors = 'red')
        plt.tight_layout()
        plt.savefig(os.path.join(path, title))
        

def save_figs_rm(examples, results, title, path, time_limit = 40):
    # Your code goes here.
    for i in range(len(examples)):
        exp = examples[i]
        T, C, D = exp[0], exp[1], exp[2]
        n = len(T)
        result = results[i]
        print(result)
        n_res = len(result)
        # elif n_res == n + 2:
        fig, gnt = plt.subplots()
        gnt.set_title(title)
        gnt.set_xlabel('Real-Time Clock')
        gnt.set_ylabel('Tasks')
        gnt.set_ylim(-1.5, n+1)
        gnt.set_xlim(0, time_limit)
        gnt.set_yticks(range(n+1))
        gnt.set_yticklabels(['Task' + str(n - x + 1) +'(C='+str(C[n - x])+')' for x in range(1,n+1)]+['Aperiodic Tasks'])
        gnt.grid(True)
        result = result[::-1]
        for j in range(2, n + 2):
            # print(result[2])
            for t in range(time_limit):
                if result[j][t] == 1:
                    if result[0][t] == 1:
                        gnt.broken_barh([(t, 1)], (-2.5+j, 1), facecolors='orange')
                        # gnt.add_line()
                    else:
                        gnt.broken_barh([(t, 1)], (-2.5+j, 1), facecolors='green')
        print(T)
        T = T[::-1]
        for t in range(time_limit):
            if result[1][t] == 1:
                gnt.broken_barh([(t, 1)], (len(T) - 0.5, 1), facecolors='red')
            for j in range(len(T)):
                if t % T[j] == 1:
                    gnt.broken_barh([(t - 1, 0.25)], (-0.5+j, 1), facecolors = 'black')
        plt.tight_layout()
        plt.savefig(os.path.join(path, title))
        # plt


def rm_scheduler(examples, ap_task_time, ap_task_jobs,time_limit = 40):
    results = []
    for exp in examples:
        T, C = exp[0], exp[1]
        n = len(T)
        time = 1
        result = np.zeros((n+2, time_limit))
        tasks = []
        DLs = []
        pris = []
        tasks_timer = []
        intrupt = False
        current_task = -1
        task_timer = -1
        deadline = -1
        pri = -1
        while time <= time_limit:
            for i in range(n):
                if time % T[i] == 1:
                    if current_task != -1:
                        tasks.insert(0, current_task)
                        tasks_timer.insert(0, task_timer)
                        DLs.insert(0, deadline)
                        pris.insert(0, pri)
                        current_task = -1
                        task_timer = -1
                        deadline = -1
                        pri = -1
                    tasks.append(i)
                    DLs.append(time + T[i])
                    pris.append(T[i])
                    tasks_timer.append(C[i])
            if intrupt:
                ap_task_jobs = ap_task_jobs - 1
                if ap_task_jobs == 0:
                    intrupt = False
                result[n][time - 1] = 1
            else:
                if current_task == -1:
                    if len(tasks) != 0:
                        edi = np.argmin(pris)
                        current_task = tasks.pop(edi)
                        task_timer = tasks_timer.pop(edi)
                        deadline = DLs.pop(edi)
                        pri = pris.pop(edi)
                    else:
                        time = time + 1
                        continue
                if task_timer > 0:
                    result[current_task][time - 1] = 1
                    if time>= deadline:
                        result[n+1][time - 1] = 1
                    task_timer = task_timer - 1
                    if task_timer == 0:
                        current_task = -1
                        task_timer = -1
                        deadline = -1
                        pri = -1
            if time == ap_task_time:
                intrupt = True
            time = time + 1
            
        # missed = []
        # result = []
        # result.append(missed)
        results.append(result)
    
    return np.array(results, np.uint)
def dm_scheduler(examples, time_limit = 40):
    results = []
    for exp in examples:
        T, C, D = exp[0], exp[1], exp[2]
        n = len(T)
        time = 1
        result = np.zeros((n+1, time_limit))
        tasks = []
        DLs = []
        pris = []
        tasks_timer = []
        intrupt = False
        current_task = -1
        task_timer = -1
        deadline = -1
        pri = -1
        while time <= time_limit:
            # print(pris)
            for i in range(n):
                if time % T[i] == 1:
                    if current_task != -1:
                        tasks.insert(0, current_task)
                        tasks_timer.insert(0, task_timer)
                        DLs.insert(0, deadline)
                        pris.insert(0, pri)
                        current_task = -1
                        task_timer = -1
                        deadline = -1
                        pri = -1
                    tasks.append(i)
                    DLs.append(time + D[i])
                    pris.append(D[i])
                    tasks_timer.append(C[i])
            if current_task == -1:
                if len(tasks) != 0:
                    edi = np.argmin(pris)
                    current_task = tasks.pop(edi)
                    task_timer = tasks_timer.pop(edi)
                    deadline = DLs.pop(edi)
                    pri = pris.pop(edi)
                else:
                    time = time + 1
                    continue
            if task_timer > 0:
                result[current_task][time - 1] = 1
                if time>= deadline:
                    print(deadline)
                    result[n][time - 1] = 1
                task_timer = task_timer - 1
                if task_timer == 0:
                    current_task = -1
                    task_timer = -1
                    deadline = -1
                    pri = -1
            time = time + 1
            
        # missed = []
        # result = []
        # result.append(missed)
        results.append(result)
    return np.array(results, np.uint)
def ed_scheduler(examples, time_limit = 40):
    results = []
    for exp in examples:
        T, C, D = exp[0], exp[1], exp[2]
        # your code goes here :: Start
        n = len(T)
        # print(DLs[1][3])
        time = 1
        result = np.zeros((n + 1,time_limit))
        # missed = np.zeros((time_limit))
        # add all on startup
        tasks = []
        DLs = []
        # for i in range(n):
        #     tasks.append(i)
        #     DLs.append(D[i])
        current_task = -1
        task_timer = -1
        deadline = -1
        # The processor simulation with time unit
        while time <= time_limit:
            # print(tasks, DLs)
            # New task arrival
            for i in range(n):
                if time % T[i] == 1:
                    tasks.append(i)
                    DLs.append(time + D[i])
            # Check system status
            if current_task == -1:
                if not len(tasks) == 0:
                    # find earliest dedline
                    edi = np.argmin(DLs)
                    current_task = tasks.pop(edi)
                    task_timer = C[current_task]
                    deadline = DLs.pop(edi)
                    # print(current_task, task_timer, deadline)
                else:
                    time = time + 1
                    # print('con')
                    continue
            # do the task
            if task_timer > 0:
                result[current_task][time - 1] = 1
                if time >= deadline:
                    # print(time, deadline)
                    result[n][time - 1] = 1
                task_timer = task_timer - 1
            if task_timer == 0:
                current_task = -1
                task_timer = -1
                deadline = -1
            time = time + 1
        # your code goes here :: End
        # print(result)
        # result.append(missed)
        results.append(result)
    return np.array(results, np.uint)
if __name__ == '__main__':
    # save_figs_rm(file_reader('inputs.txt'), rm_scheduler(file_reader('inputs.txt'), 3, 8), 'AP Scheduling', '')
    file_writer(rm_scheduler(file_reader('input.txt'), 3, 8), "out1rm.txt")
    file_writer(dm_scheduler(file_reader('input.txt')), "out1dm.txt")
    file_writer(ed_scheduler(file_reader('input.txt')), "out1edd.txt")
    # save_figs_ed(file_reader('inputs.txt'), dm_scheduler(file_reader('inputs.txt')), 'DM Scheduling', '')
    # save_figs_ed(file_reader('inputs.txt'), ed_scheduler(file_reader('inputs.txt')), 'EDF Scheduling', '')
