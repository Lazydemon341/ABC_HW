#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <thread>
#include <future>

using namespace std;

int determinant(int** matrix, int n) {
	int det = 0;
	int** submatrix = new int*[n];
	for (size_t i = 0; i < n; i++)
	{
		submatrix[i] = new int [n];
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


int main()
{
    int** slae = new int* [4];
	for (size_t i = 0; i < 4; i++)
	{
		slae[i] = new int[5];
	}

	for (size_t i = 0; i < 4; i++)
	{
		printf("Enter the %d line of the system:\n", (i + 1));
		scanf_s("%d %d %d %d %d", &slae[i][0], &slae[i][1], &slae[i][2], &slae[i][3], &slae[i][4]);
	}

	printf("Entered SLAE:\n");
	for (size_t i = 0; i < 4; i++)
	{
		for (size_t j = 0; j < 5; j++)
		{
			printf("%d\t", slae[i][j]);
		}
		printf("\n");
	}

	auto future =  async(getCramerDet, slae[0], slae[1], slae[2], slae[3]);
	int d0 = future.get();
	
	if (d0 == 0) {
		cout << "The d0 equals zero hence the Cramer's rule can't be applied!";
	}
	else {
		cout << "\n" << "delta0 = " << d0;
	}
}
