#include <REGX51.H>
sbit Lmotor_P = P2^0;
sbit Lmotor_N = P2^1;
sbit Rmotor_P = P2^2;
sbit Rmotor_N = P2^3;

sbit Left_S = P1^0;
sbit Right_S = P1^1;
sbit Front_S = P1^2;

void main(void)
{
	Left_S = 0;
	Right_S = 0;
	Front_S = 0;

   while(1) 
	 {
		if(Left_S == 1 && Right_S == 0 && Front_S == 0)
		{
		Lmotor_P = 1;
		Lmotor_N = 0;
		Rmotor_P = 0;
		Rmotor_N = 1;        // RIGHT MOVE
		}
		else if(Left_S == 0 && Right_S == 1 && Front_S == 0)
		{
		Lmotor_P = 0;
		Lmotor_N = 1;
		Rmotor_P = 1;
		Rmotor_N = 0;        // LEFT MOVE
		}
		else if(Left_S == 0 && Right_S == 0 && Front_S == 1)
		{
		Lmotor_P = 0;
		Lmotor_N = 1;
		Rmotor_P = 0;
		Rmotor_N = 1;        // ROBOT Back
		}
		else
		{
		Lmotor_P = 1;
		Lmotor_N = 0;
		Rmotor_P = 1;
		Rmotor_N = 0;  	// forward
		}
	 }
 }
 
 