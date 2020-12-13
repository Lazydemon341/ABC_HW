#define _CRT_SECURE_NO_WARNINGS

#define HAVE_STRUCT_TIMESPEC
#include <pthread.h>
#include <semaphore.h>

#ifdef _WIN32
#include <Windows.h>
#define usleep(n) Sleep(n/1000)
#else
#include <unistd.h>
#endif

#include <vector>
#include <cstdlib>
#include <chrono>
#include <string>

using namespace std;
using namespace chrono;

unsigned N; // Number of read and write repetitions.
vector<string> database;
sem_t write_semaphore;
vector<pthread_t> writers, readers;

void* reader(void* arg)
{
	for (size_t i = 0; i < N; i++)
	{
		// Set seed depending on current time.
		srand((unsigned)duration_cast<nanoseconds>(steady_clock::now().time_since_epoch()).count());
		int index = rand() % database.size(); // Choose index of data to read.

		printf("reader №%d reads data cell №%d: '%s'\n", (int)arg, index + 1, database[index].c_str());
	}
	return 0;
}

void* writer(void* arg)
{
	for (size_t i = 0; i < N; i++)
	{
		// Set seed depending on current time.
		srand((unsigned)duration_cast<nanoseconds>(steady_clock::now().time_since_epoch()).count());
		int index = rand() % database.size(); // Choose index of data cell.

		printf("writer №%d is trying to access the database...\n", (int)arg);
		sem_wait(&write_semaphore); // Lock the database to other writers.

		string prevValue = database[index];
		database[index] += to_string((int)arg);
		printf("writer №%d has changed data cell №%d from '%s' to '%s'\n", (int)arg, index + 1, prevValue.c_str(), database[index].c_str());
		usleep(3);

		printf("writer №%d has finished working with the data\n", (int)arg);
		sem_post(&write_semaphore); // Release the database to other writers.
	}
	return 0;
}

int getUserInput(string msg, unsigned* arg) {
	printf("%s\n", msg.c_str());

	if (scanf("%u", arg) != 1 || *arg < 1) {
		printf("Incorrect input!");
		return -1;
	}
	return 0;
}

int main()
{
	unsigned numOfDataCells;
	unsigned numOfThreads;

	if (getUserInput("Input a number of data cells:", &numOfDataCells) != 0 ||
		getUserInput("Input a number of readers and writers:", &numOfThreads) != 0 ||
		getUserInput("Input a number of repetitions:", &N) != 0) {
		return -1;
	}
	printf("\n");

	database = vector<string>(numOfDataCells);
	for (size_t i = 0; i < database.size(); i++)
	{
		// Initialize the data.
		database[i] = "data" + to_string(i + 1);
	}

	sem_init(&write_semaphore, 0, 1);

	readers = vector<pthread_t>(numOfThreads);
	writers = vector<pthread_t>(numOfThreads);

	for (size_t i = 0; i < numOfThreads; i++)
	{
		pthread_create(&readers[i], NULL, reader, (void*)(i + 1));
		pthread_create(&writers[i], NULL, writer, (void*)(i + 1));
	}

	for (size_t i = 0; i < numOfThreads; i++)
	{
		pthread_join(readers[i], NULL);
		pthread_join(writers[i], NULL);
	}

	return 0;
}