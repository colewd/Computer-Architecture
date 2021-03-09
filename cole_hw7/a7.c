// need these include files
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/resource.h>

// need just a main function, no args
int main(void) {
    // some local variables 
    pid_t   pid, ppid;
    int     ruid, rgid, euid, egid;
    int     priority;
    char    msg_buf[100];
    char    msg_buf2[100];
    int     msg_pipe[2];

    // use the pipe() system call to create the pipe
    if(pipe(msg_pipe) == -1){
        perror("failed in Parent pipe creation:");
        exit(7);
    }

    // use various system calls to collect and print process details
    printf("\nThis is the Parent process report:\n");
    pid  = getpid();
    ppid = getppid();
    ruid = getuid();
    euid = geteuid();
    rgid = getgid();
    egid = getegid();
    priority = getpriority(PRIO_PROCESS, 0);

    printf("\nPARENT PROG:  Process ID is:\t\t%d\nPARENT PROC:  Process parent ID is:\t%d\nPARENT PROC:  Real UID is:\t\t%d\nPARENT PROC:  Real GID is:\t\t%d\nPARENT PROC:  Effective UID is:\t\t%d\nPARENT PROC:  Effective GID is:\t\t%d\nPARENT PROC:  Process priority is:\t%d\n", pid, ppid, ruid, rgid, euid, egid, priority);
	printf("\nPARENT PROC: will now create child, write pipe,\n and do a normal termination\n");

    // use the sprintf() call to build a message to write into the pipe
    // and dont forget to write the message into the pipe before parent exits
    sprintf(msg_buf, "This is the pipe message from the parent with PID %d", pid);


    // now use the fork() call to create the child:
	switch (pid = fork()){
       case -1: // if the call fails
            printf("Fork call failed...\n");
            exit(1);
       default: // this is the parent's case  
                // parent must write message to pipe and
                // do a normal exit

            printf("PARENT PROG: created Child with %d PID\n", pid);
            sprintf(msg_buf2, "%s\nPARENT PROG: created Child with %d PID\n", msg_buf, pid);
            write(msg_pipe[1], msg_buf, 100); 

            exit(0);
       case 0:  // this is the child's case
		        // child must create and print report
                // child must read pipe message and print 
		        // a modified version of it to output
		        // child must do a normal exit
            pid  = getpid();
            ppid = getppid();
            ruid = getuid();
            euid = geteuid();
            rgid = getgid();
            egid = getegid();
            priority = getpriority(PRIO_PROCESS, 0);
            read(msg_pipe[1], msg_buf, 100);

            printf("\nThis is the Child process report:\n\n");
            printf("CHILD PROC:  Process ID is:\t\t%d\nCHILD PROC:  Process parent ID is:\t%d\nCHILD PROC:  Real UID is:\t\t%d\nCHILD PROC:  Real GID is:\t\t%d\nCHILD PROC:  Effective UID is:\t\t%d\nCHILD PROC:  Effective GID is:\t\t%d\nCHILD PROC:  Process priority is:\t%d\n", pid, ppid, ruid, rgid, euid, egid, priority);
            printf("\nCHILD PROG: about to read pipe and report parent message:\n\n");
            printf("CHILD PROC: parent's msg is \n\t%s\n\n", msg_buf);
            printf("CHILD PROC: Process parent ID now is:   %d\n", getppid());
            printf("CHILD PROC: ### Goodbye ###\n");

            exit(0);
    } // switch and child end
}
