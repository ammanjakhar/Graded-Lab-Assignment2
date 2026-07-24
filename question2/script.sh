#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include <time.h>

#define MAX_CHILDREN 10
#define TIMEOUT 5  // seconds

pid_t child_pids[MAX_CHILDREN];
int child_count = 0;

// Signal handler for child termination
void handle_sigchld(int sig) {
    int status;
    pid_t pid;
    // Use waitpid with WNOHANG to prevent blocking
    while ((pid = waitpid(-1, &status, WNOHANG)) > 0) {
        // Child exited, handle cleanup
    }
}

// Signal handler for timeout/alarm
void handle_alarm(int sig) {
    // Terminate unresponsive child processes
    for (int i = 0; i < child_count; i++) {
        if (child_pids[i] > 0) {
            kill(child_pids[i], SIGKILL);
        }
    }
}

int main() {
    // Set up signal handlers
    signal(SIGCHLD, handle_sigchld);
    signal(SIGALRM, handle_alarm);
    
    // Create child processes
    for (int i = 0; i < MAX_CHILDREN; i++) {
        pid_t pid = fork();
        if (pid == 0) {
            // Child process: do some work
            // Could simulate a task that might hang
            exit(0);
        } else if (pid > 0) {
            child_pids[child_count++] = pid;
        }
    }
    
    // Set alarm for timeout
    alarm(TIMEOUT);
    
    // Wait for children to complete
    while (child_count > 0) {
        pause();  // Wait for signals
    }
    
    return 0;
}
