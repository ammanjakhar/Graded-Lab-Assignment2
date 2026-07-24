1. Create the C file in Linux
nano process_monitor.c

Save the file in Nano with Ctrl+O → Enter → Ctrl+X.

2. Compile the program
gcc process_monitor.c -o process_monitor

Explanation: gcc compiles process_monitor.c and creates the Linux executable process_monitor. If there are no compilation errors, the command normally produces no output.

3. Run the program
./process_monitor

The exact PID numbers and ordering of output may differ on your Linux machine because process scheduling and PID allocation are controlled by the operating system.

4. Check the processes

Run:

ps -ef | grep process_monitor

Explanation: ps -ef displays running processes and grep filters the result for process_monitor. After the program finishes, there should be no <defunct> child belonging to it, showing that terminated children were reaped.

Explanation of the Linux concepts

fork() creates a new Linux process. After a successful fork(), both parent and child continue execution. A return value of 0 identifies the child, while the parent receives the child's PID. The parent saves these PIDs so it can monitor each worker.

pid[i] = fork();

waitpid() allows the parent to monitor and collect terminated children. Using WNOHANG prevents the parent from blocking while a child is still running:

waitpid(pid[i], &status, WNOHANG);

This is particularly useful for a server because the parent needs to continue monitoring other workers rather than waiting indefinitely for one process.

When a child terminates, Linux retains a small process-table entry containing its exit information until the parent calls wait() or waitpid(). Such a terminated but unreaped process is called a zombie. Calling waitpid() retrieves its status and allows Linux to remove that entry.

If a child runs longer than the five-second timeout, the program treats it as unresponsive and sends:

kill(pid[i], SIGTERM);

SIGTERM requests termination of the process. After sending the signal, the parent calls waitpid() again to reap the terminated child and prevent it from becoming a zombie. In a production server, if a process ignores SIGTERM, the parent can wait for a grace period and then escalate to SIGKILL.

Thus, fork() creates workers → waitpid() monitors/reaps them → kill() with SIGTERM handles unresponsive workers → waitpid() collects them, preventing uncontrolled child processes and zombie accumulation on the Linux server.
