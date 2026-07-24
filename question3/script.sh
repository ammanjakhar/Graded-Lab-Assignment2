
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

struct Employee {
    int id;
    char name[50];
    float salary;
};

void create_file(const char* filename) {
    int fd = open(filename, O_CREAT | O_RDWR, 0644);
    // Error handling
    close(fd);
}

void write_record(int fd, struct Employee* emp) {
    lseek(fd, 0, SEEK_END);  // Go to end of file
    write(fd, emp, sizeof(struct Employee));
}

void update_record(int fd, int id, struct Employee* new_data) {
    // Search for record with given id
    struct Employee emp;
    off_t offset = 0;
    
    lseek(fd, 0, SEEK_SET);
    while (read(fd, &emp, sizeof(emp)) == sizeof(emp)) {
        if (emp.id == id) {
            // Found! Update this record
            lseek(fd, -sizeof(emp), SEEK_CUR);
            write(fd, new_data, sizeof(struct Employee));
            break;
        }
    }
}

void read_record(int fd, int id) {
    struct Employee emp;
    lseek(fd, 0, SEEK_SET);
    while (read(fd, &emp, sizeof(emp)) == sizeof(emp)) {
        if (emp.id == id) {
            // Found the record
            break;
        }
    }
}
