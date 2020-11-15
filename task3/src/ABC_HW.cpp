#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <thread>
#include <future>

using namespace std;

int determinant(int** matrix, int n) {
	int det = 0;
	int** submatrix = new int* [n];
	for (size_t i = 0; i < n; i++)
	{
		submatrix[i] = new int[n];
	}

	if (n == 2)
		return ((matrix[0][0] * matrix[1][1]) - (matrix[1][0] * matrix[0][1]));
	else {
		for (int x = 0; x < n; x++) {
			int subi = 0;
			for (int i = 1; i < n; i++) {
				int subj = 0;
				for (int j = 0; j < n; j++) {
					if (j == x)
						continue;
					submatrix[subi][subj] = matrix[i][j];
					subj++;
				}
				subi++;
			}
			det = det + (pow(-1, x) * matrix[0][x] * determinant(submatrix, n - 1));
		}
	}
	return det;
}

int getCramerDet(int* a1, int* a2, int* a3, int* a4) {
	int** matrix = new int* [4];
	matrix[0] = a1;
	matrix[1] = a2;
	matrix[2] = a3;
	matrix[3] = a4;

	return determinant(matrix, 4);
}

void printSLAE(int** slae) {
	for (size_t i = 0; i < 4; i++)
	{
		for (size_t j = 0; j < 5; j++)
		{
			printf("%d\t", slae[j][i]);
		}
		printf("\n");
	}
}

void getSolutions(int** slae, int d) {
	// Count deltas 1-4
	future<int>* farr = new future<int>[4];
	farr[0] = async(launch::async, getCramerDet, slae[4], slae[1], slae[2], slae[3]);
	farr[1] = async(launch::async, getCramerDet, slae[0], slae[4], slae[2], slae[3]);
	farr[2] = async(launch::async, getCramerDet, slae[0], slae[1], slae[4], slae[3]);
	farr[3] = async(launch::async, getCramerDet, slae[0], slae[1], slae[2], slae[4]);

	int* delta = new int[5];
	delta[0] = d;
	for (size_t i = 1; i < 5; i++)
	{
		delta[i] = farr[i - 1].get();
		printf("Delta%d = %d\n", i, delta[i]);
	}

	cout << "\nSolutions:\n";
	for (size_t i = 1; i < 5; i++)
	{
		printf("x%d = %.3f\n", i, delta[i] / (double)delta[0]);
	}
}


int main()
{
	bool isCorrectInput = true;;

	int** slae = new int* [5];
	for (size_t i = 0; i < 5; i++)
	{
		// Initialize the SLAE' columns
		slae[i] = new int[4];
	}

	for (size_t i = 0; i < 4; i++)
	{
		printf("Enter the %d line of the system:\n", (i + 1));
		if (scanf_s("%d %d %d %d %d", &slae[0][i], &slae[1][i], &slae[2][i], &slae[3][i], &slae[4][i]) != 1) {
			isCorrectInput = false;
			break;
		}
	}

	if (!isCorrectInput) {
		cout << "\nIncorrect input!";
	}
	else {

		printf("\nEntered system:\n");
		printSLAE(slae);

		// Count the main delta
		int d = getCramerDet(slae[0], slae[1], slae[2], slae[3]);

		if (d == 0) {
			cout << "\nDelta0 equals zero hence the Cramer's rule can't be applied!";
		}
		else {
			cout << "\n" << "Delta0 = " << d << "\n";

			getSolutions(slae, d);
		}
	}
}
