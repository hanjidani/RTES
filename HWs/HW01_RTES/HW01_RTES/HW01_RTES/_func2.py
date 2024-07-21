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

def rm_scheduler(examples,time_limit = 40):
    results = []
    for exp in examples:
        T, C, D , R= exp[0], exp[1], exp[2], exp[3]
        n = len(T)
        time = 1
        result = np.zeros((n+1, time_limit))
        tasks = []
        DLs = []
        pris = []
        tasks_timer = []
        reses = []
        current_task = -1
        task_timer = -1
        deadline = -1
        res = -1
        pri = -1
        pres_user = []
        pres_timer = []
        pres_dead = []
        ta = False
        while time <= time_limit:
            for i in range(n):
                if time % T[i] == 1:
                    if current_task != -1:
                        tasks.insert(0, current_task)
                        tasks_timer.insert(0, task_timer)
                        DLs.insert(0, deadline)
                        pris.insert(0, pri)
                        reses.insert(0, res)
                        current_task = -1
                        task_timer = -1
                        deadline = -1
                        pri = -1
                        res = -1
                    tasks.append(i)
                    DLs.append(time + T[i])
                    pris.append(T[i])
                    tasks_timer.append(C[i])
                    reses.append(R[i])
            if current_task == -1:
                if len(tasks) != 0:
                    edi = np.argmin(pris)
                    current_task = tasks.pop(edi)
                    task_timer = tasks_timer.pop(edi)
                    deadline = DLs.pop(edi)
                    pri = pris.pop(edi)
                    res = reses.pop(edi)
                    ta = True
            if len(pres_user)>0:print(pres_user,T[pres_user[0]],pri,pres_timer, time)
            if len(pres_user)>0 and (T[pres_user[0]] <= pri or current_task in pres_user or pri == -1):
                # print("in")
                result[pres_user[0]][time - 1] = 1
                if time>= pres_dead[0]:
                    result[n][time - 1] = 1
                pres_timer[0] = pres_timer[0] - 1
                if pres_timer[0] == 0:
                    pres_timer.pop(0)
                    pres_user.pop(0)
                    pres_dead.pop(0)
            elif task_timer > 0 and ta: 
                result[current_task][time - 1] = 1
                if time>= deadline:
                    result[n][time - 1] = 1
                task_timer = task_timer - 1
                if task_timer == 0:
                    if res > 0 :
                        pres_user.append(current_task)
                        pres_timer.append(res)
                        pres_dead.append(deadline)
                    current_task = -1
                    task_timer = -1
                    deadline = -1
                    pri = -1
                    ta = False
            time = time + 1
            
        # missed = []
        # result = []
        # result.append(missed)
        results.append(result)
    return np.array(results, np.uint)
def rm_schedulerp(examples,time_limit = 40):
    results = []
    for exp in examples:
        T, C, R = exp[0], exp[1], exp[3]
        n = len(T)
        time = 1
        result = np.zeros((n+1, time_limit))
        tasks = []
        DLs = []
        pris = []
        tasks_timer = []
        reses = []
        current_task = -1
        task_timer = -1
        deadline = -1
        res = -1
        pri = -1
        pres_user = []
        pres_timer = []
        pres_dead = []
        prires = -1
        ta = False
        while time <= time_limit:
            for i in range(n):
                if time % T[i] == 1:
                    if current_task != -1:
                        tasks.insert(0, current_task)
                        tasks_timer.insert(0, task_timer)
                        DLs.insert(0, deadline)
                        pris.insert(0, pri)
                        reses.insert(0, res)
                        current_task = -1
                        task_timer = -1
                        deadline = -1
                        pri = -1
                        res = -1
                    tasks.append(i)
                    DLs.append(time + T[i])
                    pris.append(T[i])
                    tasks_timer.append(C[i])
                    reses.append(R[i])
            if current_task == -1:
                if len(tasks) != 0:
                    edi = np.argmin(pris)
                    current_task = tasks.pop(edi)
                    task_timer = tasks_timer.pop(edi)
                    deadline = DLs.pop(edi)
                    pri = pris.pop(edi)
                    res = reses.pop(edi)
                    ta = True
            print(pri)
            if len(pres_user)>0:print(pres_user,T[pres_user[0]],pri,pres_timer, time)
            if (prires <= pri or pri == -1) and prires != -1 and len(pres_user) > 0:
                result[pres_user[0]][time - 1] = 1
                if time >= pres_dead[0]:
                    result[n][time - 1] = 1
                pres_timer[0] = pres_timer[0] - 1
                if pres_timer[0] == 0:
                    pres_timer.pop(0)
                    pres_user.pop(0)
                    pres_dead.pop(0)
                if len(pres_timer) == 0:
                    prires = -1
            elif task_timer > 0 and ta: 
                result[current_task][time - 1] = 1
                if time>= deadline:
                    result[n][time - 1] = 1
                task_timer = task_timer - 1
                if task_timer == 0:
                    if res > 0:
                        pres_user.append(current_task)
                        pres_timer.append(res)
                        pres_dead.append(deadline)
                        prires = pri
                    current_task = -1
                    task_timer = -1
                    deadline = -1
                    pri = -1
                    ta = False

            time = time + 1
            
        # missed = []
        # result = []
        # result.append(missed)
        results.append(result)
    return np.array(results, np.uint)


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
        print(result)
        # n_res = len(result)
        # if n_res == n + 1:
        fig, gnt = plt.subplots()
        gnt.set_xlabel('Real-Time Clock')
        gnt.set_ylabel('Tasks')
        gnt.set_title(title)
        gnt.set_ylim(-1.5, n)
        gnt.set_xlim(0, time_limit)
        gnt.set_yticks(range(n))
        gnt.set_yticklabels(['Task' + str(x) +'(C='+str(C[n-x])+')' for x in range(1,n+1)])
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
                    # gnt.broken_barh([(t - 1 + D[j], 0.25)], (-0.5+j, 0.5), facecolors = 'red')
        plt.tight_layout()
        plt.savefig(os.path.join(path, title))



if __name__ == '__main__':
    # save_figs_ed(file_reader('input.txt'), rm_scheduler(file_reader('input.txt'), [2, 0, 3]), 'Resource Scheduler','')
    # save_figs_ed(file_reader('input.txt'), rm_schedulerp(file_reader('input.txt'), [2, 0, 3]), 'Resource Scheduler with priority','')
    file_writer(rm_scheduler(file_reader('inputs.txt')), "out2.txt")
    file_writer(rm_schedulerp(file_reader('inputs.txt')), "out2p.txt")