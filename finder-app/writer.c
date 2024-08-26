#include <stdio.h>
#include <syslog.h>

int main(int argc, char*argv[])
{
    char* filepath = NULL;
    char* txt_to_enter = NULL;
    //Check for input arguments
    openlog("writer",LOG_PID, LOG_USER);
    if(argc < 3)
    {
        printf("Needs 2 arguements filepath and text to write\n");
        syslog(LOG_ERR,"Needs 2 arguements filepath and text to write");
        return 1;
    }
    else
    {
        filepath = argv[1];
        txt_to_enter = argv[2]; 
    }

    // Open file with fileptr
    FILE*fileptr = fopen(filepath,"w+");
    //Error Checking
    if(NULL == fileptr)
    {
        syslog(LOG_ERR,"File not created");
        return 1;
    }
    //Write to file
    syslog(LOG_DEBUG,"Writing %s to %s file",txt_to_enter, filepath);
    fprintf(fileptr,"%s", txt_to_enter);


    //close pointer to file
    fclose(fileptr);
    return 0;
}