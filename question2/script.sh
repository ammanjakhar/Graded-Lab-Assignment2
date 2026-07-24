#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <time.h>

#define CHILDREN 3
#define TIMEOUT 5

int main()
{
    pid_t pid[CHILDREN];
    time_t start[CHILDREN];
    int completed[CHILDREN] = {0};
    int status;
    int remaining = CHILDREN;

    /* Create child processes */
    for (int i = 0; i < CHILDREN; i++)
    {
        pid[i] = fork();

        if (pid[i] < 0)
        {
            perror("fork failed");
            exit(1);
        }

        if (pid[i] == 0)
        {
            printf("Child %d started, PID = %d\n",
                   i + 1, getpid());

            /* Third child simulates an unresponsive process */
            if (i == 2)
            {
                printf("Child %d is unresponsive...\n", i + 1);

                while (1)
                    sleep(1);
            }

            /* Normal children perform some work */
            sleep(i + 2);

            printf("Child %d completed normally.\n", i + 1);

            exit(0);
        }
        else
        {
            /* Parent stores starting time */
            start[i] = time(NULL);

            printf("Parent created Child %d, PID = %d\n",
                   i + 1, pid[i]);
        }
    }

    printf("\nParent monitoring children...\n");

    /* Monitor all children */
    while (remaining > 0)
    {
        for (int i = 0; i < CHILDREN; i++)
        {
            if (completed[i])
                continue;

            /*
             * WNOHANG checks child status without
             * blocking the parent process.
             */
            pid_t result = waitpid(pid[i], &status, WNOHANG);

            if (result > 0)
            {
                printf("Child PID %d finished and was collected.\n",
                       pid[i]);

                completed[i] = 1;
                remaining--;
            }
            else if (result == 0)
            {
                /* Check for timeout */
                if (difftime(time(NULL), start[i]) >= TIMEOUT)
                {
                    printf("Child PID %d is unresponsive.\n",
                           pid[i]);

                    printf("Sending SIGTERM to PID %d...\n",
                           pid[i]);

                    kill(pid[i], SIGTERM);

                    /*
                     * Wait for terminated child.
                     * This prevents a zombie process.
                     */
                    waitpid(pid[i], &status, 0);

                    printf("Child PID %d terminated and collected.\n",
                           pid[i]);

                    completed[i] = 1;
                    remaining--;
                }
            }
        }

        sleep(1);
    }

    printf("\nAll child processes handled successfully.\n");
    printf("No zombie processes remain.\n");

    return 0;
}
