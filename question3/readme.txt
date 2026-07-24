or this Linux lab question, you can implement a C program using Linux system calls. It creates an employee file, writes fixed-size records, updates one record directly with lseek(), and retrieves a selected record without reading the whole file.
1. Create the C program

In the Linux terminal:

nano employee_records.c

Paste the following code:

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/types.h>

struct Employee
{
    int id;
    char name[50];
    float salary;
};

int main()
{
    int fd;
    ssize_t bytes;
    struct Employee employees[3] = {
        {101, "Aman", 35000.0},
        {102, "Rahul", 40000.0},
        {103, "Priya", 45000.0}
    };

    struct Employee emp;

    /* Step 1: Create/Open the employee file */
    fd = open("employees.dat",
              O_CREAT | O_RDWR | O_TRUNC,
              0600);

    if (fd == -1)
    {
        perror("open");
        exit(EXIT_FAILURE);
    }

    /* Step 2: Write employee records */
    bytes = write(fd, employees, sizeof(employees));

    if (bytes != sizeof(employees))
    {
        perror("write");
        close(fd);
        exit(EXIT_FAILURE);
    }

    printf("Employee records written successfully.\n");

    /*
     * Step 3: Update employee record 2 directly.
     * Record 2 starts at offset 1 * sizeof(Employee).
     */
    off_t offset = 1 * sizeof(struct Employee);

    if (lseek(fd, offset, SEEK_SET) == -1)
    {
        perror("lseek");
        close(fd);
        exit(EXIT_FAILURE);
    }

    struct Employee updated = {
        102,
        "Rahul",
        50000.0
    };

    bytes = write(fd, &updated, sizeof(updated));

    if (bytes != sizeof(updated))
    {
        perror("write");
        close(fd);
        exit(EXIT_FAILURE);
    }

    printf("Employee record 2 updated successfully.\n");

    /*
     * Step 4: Retrieve record 3 directly.
     * Record 3 starts at offset 2 * sizeof(Employee).
     */
    offset = 2 * sizeof(struct Employee);

    if (lseek(fd, offset, SEEK_SET) == -1)
    {
        perror("lseek");
        close(fd);
        exit(EXIT_FAILURE);
    }

    bytes = read(fd, &emp, sizeof(emp));

    if (bytes == -1)
    {
        perror("read");
        close(fd);
        exit(EXIT_FAILURE);
    }

    if (bytes == sizeof(emp))
    {
        printf("\nRetrieved Employee Record:\n");
        printf("ID     : %d\n", emp.id);
        printf("Name   : %s\n", emp.name);
        printf("Salary : %.2f\n", emp.salary);
    }

    /* Step 5: Close the file */
    if (close(fd) == -1)
    {
        perror("close");
        exit(EXIT_FAILURE);
    }

    printf("\nFile closed successfully.\n");

    return 0;
}

Save using Ctrl+O → Enter → Ctrl+X.

2. Compile the program
gcc employee_records.c -o employee_records

Explanation:
gcc compiles the C source code and generates the executable file employee_records. If the code compiles successfully, the command normally produces no output.

3. Run the program
./employee_records

Expected output will be similar to:

Employee records written successfully.
Employee record 2 updated successfully.

Retrieved Employee Record:
ID     : 103
Name   : Priya
Salary : 45000.00

File closed successfully.

Explanation:
The program creates employees.dat, stores three employee records, directly updates Rahul's salary, and retrieves Priya's record. Fixed-size records allow the program to access a particular employee without reading the entire file.

4. Check that the file was created
ls -l employees.dat

Example:

-rw------- 1 user user 180 Jul 25 10:30 employees.dat

Explanation:
ls -l confirms that employees.dat was created. The 0600 permission passed to open() gives only the file owner read and write permission, which is appropriate for employee information.

Role of Linux system calls

open() — Create and open the file

fd = open("employees.dat",
          O_CREAT | O_RDWR | O_TRUNC,
          0600);

open() returns a file descriptor, which is used by subsequent Linux system calls. O_CREAT creates the file if it does not exist, O_RDWR enables reading and writing, and O_TRUNC starts with an empty file. 0600 restricts access to the owner.

write() — Store records

write(fd, employees, sizeof(employees));

write() transfers employee data from memory to the file. Because every employee uses the same struct Employee format, the records have fixed sizes.

lseek() — Random access

The most important part of the solution is:

lseek(fd, offset, SEEK_SET);

It changes the current file position. For fixed-size records, the location of a record can be calculated as:

Offset = (Record Number - 1) × sizeof(struct Employee)

For example:

Record 1 → 0 × record size
Record 2 → 1 × record size
Record 3 → 2 × record size

Therefore, the program can jump directly to any employee record.

read() — Retrieve a record

read(fd, &emp, sizeof(emp));

After lseek() positions the file descriptor at the required location, read() retrieves only that record. The entire employee database does not need to be loaded.

close() — Release the file descriptor

close(fd);

close() releases the file descriptor and associated kernel resources after processing is complete.

How the system calls work together

The complete file-processing sequence is:

open()
   ↓
Create/Open employees.dat
   ↓
write()
   ↓
Store employee records
   ↓
lseek()
   ↓
Move directly to required record
   ↓
write()
   ↓
Update that record
   ↓
lseek()
   ↓
Move directly to another record
   ↓
read()
   ↓
Retrieve the selected record
   ↓
close()
