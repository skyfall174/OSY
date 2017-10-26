#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/wait.h>
#include <stdlib.h>


#define R_END 0
#define W_END 1

volatile sig_atomic_t finish_it = 0;

// Funkce pro ukonceni/interupt
void interupt(int signum) {
    finish_it = 1;
}

void err(){
	fprintf(stdout, "ERROR");
}
int main(int argc, char const *argv[])
{
	pid_t this_p, gen_p;
	int files_descriptor[2] = {0,0};
	
	//Vytvorime pipu

	if(pipe(files_descriptor)){
		err();
		return 2;
	}

	// Vytvorime Fork a bereme jeho process id 
	this_p = fork();

	// Jestli se jedna o 0 neboli o GEN
	if(this_p == (pid_t) 0){

		if(dup2(files_descriptor[W_END], STDOUT_FILENO) == -1){//Chyba pri dup2
		    exit(2);
		}

		// Nechceme cist 2x ten samy file
		close(files_descriptor[W_END]);
		close(files_descriptor[R_END]);

		// starosti kolo preruseni
		struct sigaction action;
		memset(&action, 0, sizeof(action));
		sigemptyset(&action.sa_mask);
		action.sa_handler = interupt;
		action.sa_flags = SA_SIGINFO | SA_RESTART;
		sigaction(SIGTERM, &action, NULL);

		// generujeme randomni cisla do preruseni
		while(!finish_it){
			printf("%d %d\n", rand(), rand());
			fflush(stdout);
			sleep(1);
		}

		fprintf(stderr, "GEN TERMINATED\n");
		
	}else if ( this_p > (pid_t) 0){ // NSD
		
		gen_p = this_p;
		this_p = fork();
		
		if( this_p < (pid_t) 0) { //ERROR
			err();
			return 2;

		}else if(this_p==(pid_t)0){// this is NSD
			
			if(dup2(files_descriptor[R_END], STDIN_FILENO) == -1){

			        exit(2);
			    }
			    close(files_descriptor[R_END]);
			    close(files_descriptor[W_END]);

			    execl("./nsd", "./nsd", (char *) NULL);
		
		}else{
			//Zavirame fily (nechceme cist)
			close(files_descriptor[W_END]);
			close(files_descriptor[R_END]);
			
			sleep(5);

			kill(gen_p, SIGTERM);

			//Chekame na exit cody
			int gen_code,nsd_code;
			waitpid(gen_p,&gen_code,0);
			waitpid(this_p,&nsd_code,0);

			if(gen_code!=0||nsd_code!=0){
				fprintf(stdout, "ERROR");
				return 1;
			}else{
				fprintf(stdout, "OK");
				return 0;
			}
		}



	}else{ // Spatny kod (chyba)
		err();
		return 2;
	}

	return 0;
} 