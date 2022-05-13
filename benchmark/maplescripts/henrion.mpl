with(Groebner):
with(PolynomialIdeals):

J := PolynomialIdeal({2*f1*f2*f3*f4*f5 - 9823275,
5*f1*f2*f3*f4 + 24/5*f1*f2*f3*f5 + 21/5*f1*f2*f4*f5 + 16/5*f1*f3*f4*f5 + 9/5*f2*f3*f4*f5 - 4465125,
4*f1*f2*f3 + 6*f1*f2*f4 + 18/5*f1*f2*f5 + 6*f1*f3*f4 + 24/5*f1*f3*f5 + 14/5*f1*f4*f5 + 4*f2*f3*f4 + 18/5*f2*f3*f5 + 14/5*f2*f4*f5 + 8/5*f3*f4*f5 - 441486,
3*f1*f2 + 4*f1*f3 + 4*f1*f4 + 12/5*f1*f5 + 3*f2*f3 + 4*f2*f4 + 12/5*f2*f5 + 3*f3*f4 + 12/5*f3*f5 + 7/5*f4*f5 - 15498,
2*f1 + 2*f2 + 2*f3 + 2*f4 + 6/5*f5 - 215,
f1 + 2*f2 + 3*f3 + 4*f4 + 5*f5 + 6*t}):
st := time[real]():
Basis(J, tdeg(f1,f2,f3,f4,f5,t), characteristic=2^31-1):
time[real]() - st;

J := PolynomialIdeal({2*f1*f2*f3*f4*f5*f6 - 1404728325,
6*f1*f2*f3*f4*f5 + 35/6*f1*f2*f3*f4*f6 + 16/3*f1*f2*f3*f5*f6 + 9/2*f1*f2*f4*f5*f6 + 10/3*f1*f3*f4*f5*f6 + 11/6*f2*f3*f4*f5*f6 - 648336150,
5*f1*f2*f3*f4 + 8*f1*f2*f3*f5 + 14/3*f1*f2*f3*f6 + 9*f1*f2*f4*f5 + 7*f1*f2*f4*f6 + 4*f1*f2*f5*f6 + 8*f1*f3*f4*f5 + 7*f1*f3*f4*f6 + 16/3*f1*f3*f5*f6 + 3*f1*f4*f5*f6 + 5*f2*f3*f4*f5 + 14/3*f2*f3*f4*f6 + 4*f2*f3*f5*f6 + 3*f2*f4*f5*f6 +
5/3*f3*f4*f5*f6 - 67597623,
4*f1*f2*f3 + 6*f1*f2*f4 + 6*f1*f2*f5 + 7/2*f1*f2*f6 + 6*f1*f3*f4 + 8*f1*f3*f5 + 14/3*f1*f3*f6 + 6*f1*f4*f5 + 14/3*f1*f4*f6 + 8/3*f1*f5*f6 + 4*f2*f3*f4 + 6*f2*f3*f5 + 7/2*f2*f3*f6 + 6*f2*f4*f5 + 14/3*f2*f4*f6 + 8/3*f2*f5*f6 + 4*f3*f4*f5 + 7/2*f3*f4*f6 + 8/3*f3*f5*f6 +
3/2*f4*f5*f6 - 2657700,
3*f1*f2 + 4*f1*f3 + 4*f1*f4 + 4*f1*f5 + 7/3*f1*f6 + 3*f2*f3 + 4*f2*f4 + 4*f2*f5 + 7/3*f2*f6 + 3*f3*f4 + 4*f3*f5 + 7/3*f3*f6 + 3*f4*f5 + 7/3*f4*f6 + 4/3*f5*f6 - 46243,
2*f1 + 2*f2 + 2*f3 + 2*f4 + 2*f5 + 7/6*f6 - 358}):
st := time[real]():
Basis(J, tdeg(f1,f2,f3,f4,f5,f6), characteristic=2^31-1):
time[real]() - st;

J := PolynomialIdeal({2*f1*f2*f3*f4*f5*f6*f7 - 273922023375, 7*f1*f2*f3*f4*f5*f6 + 48/7*f1*f2*f3*f4*f5*f7 + 45/7*f1*f2*f3*f4*f6*f7 + 40/7*f1*f2*f3*f5*f6*f7 + 33/7*f1*f2*f4*f5*f6*f7 + 24/7*f1*f3*f4*f5*f6*f7 + 13/7*f2*f3*f4*f5*f6*f7 - 127830277575,
6*f1*f2*f3*f4*f5 + 10*f1*f2*f3*f4*f6 + 40/7*f1*f2*f3*f4*f7 + 12*f1*f2*f3*f5*f6 + 64/7*f1*f2*f3*f5*f7 + 36/7*f1*f2*f3*f6*f7 + 12*f1*f2*f4*f5*f6 + 72/7*f1*f2*f4*f5*f7 + 54/7*f1*f2*f4*f6*f7 + 30/7*f1*f2*f5*f6*f7 + 10*f1*f3*f4*f5*f6 + 64/7*f1*f3*f4*f5*f7 + 54/7*f1*f3*f4*f6*f7 + 40/7*f1*f3*f5*f6*f7 + 22/7f1*f4*f5*f6*f7 + 6*f2*f3*f4*f5*f6 + 40/7*f2*f3*f4*f5*f7 + 36/7*f2*f3*f4*f6*f7 + 30/7*f2*f3*f5*f6*f7 + 22/7*f2*f4*f5*f6*f7 + 12/7*f3*f4*f5*f6*f7 - 13829872635,
5*f1*f2*f3*f4 + 8*f1*f2*f3*f5 + 8*f1*f2*f3*f6 + 32/7*f1*f2*f3*f7 + 9*f1*f2*f4*f5 + 12*f1*f2*f4*f6 + 48/7*f1*f2*f4*f7 + 9*f1*f2*f5*f6 + 48/7*f1*f2*f5*f7 + 27/7*f1*f2*f6*f7 + 8*f1*f3*f4*f5 + 12*f1*f3*f4*f6 +
48/7*f1*f3*f4*f7 + 12*f1*f3*f5*f6 + 64/7*f1*f3*f5*f7 + 36/7*f1*f3*f6*f7 + 8*f1*f4*f5*f6 + 48/7*f1*f4*f5*f7 + 36/7*f1*f4*f6*f7 + 20/7*f1*f5*f6*f7 + 5*f2*f3*f4*f5 + 8*f2*f3*f4*f6 + 32/7*f2*f3*f4*f7 + 9*f2*f3*f5*f6 + 48/7*f2*f3*f5*f7 + 27/7*f2*f3*f6*f7 + 8*f2*f4*f5*f6 + 48/7*f2*f4*f5*f7 + 36/7*f2*f4*f6*f7 + 20/7*f2*f5*f6*f7 + 5*f3*f4*f5*f6 + 32/7*f3*f4*f5*f7 + 27/7*f3*f4*f6*f7 + 20/7*f3*f5*f6*f7 + 11/7*f4*f5*f6*f7 - 585849123,
4*f1*f2*f3 + 6*f1*f2*f4 + 6*f1*f2*f5 + 6*f1*f2*f6 + 24/7*f1*f2*f7 + 6*f1*f3*f4 + 8*f1*f3*f5 + 8*f1*f3*f6 + 32/7*f1*f3*f7 + 6*f1*f4*f5 + 8*f1*f4*f6 + 32/7*f1*f4*f7 + 6*f1*f5*f6 + 32/7*f1*f5*f7 + 18/7*f1*f6*f7 + 4*f2*f3*f4 + 6*f2*f3*f5 + 6*f2*f3*f6 + 24/7*f2*f3*f7 + 6*f2*f4*f5 + 8*f2*f4*f6 + 32/7*f2*f4*f7 + 6*f2*f5*f6 + 32/7*f2*f5*f7 + 18/7*f2*f6*f7 + 4*f3*f4*f5 + 6*f3*f4*f6 + 24/7*f3*f4*f7 + 6*f3*f5*f6 + 32/7*f3*f5*f7 + 18/7*f3*f6*f7 + 4*f4*f5*f6 + 24/7*f4*f5*f7 + 18/7*f4*f6*f7 + 10/7*f5*f6*f7 - 11675085,
3*f1*f2 + 4*f1*f3 + 4*f1*f4 + 4*f1*f5 + 4*f1*f6 + 16/7*f1*f7 + 3*f2*f3 + 4*f2*f4 + 4*f2*f5 + 4*f2*f6 + 16/7*f2*f7 + 3*f3*f4 + 4*f3*f5 + 4*f3*f6 + 16/7*f3*f7 + 3*f4*f5 + 4*f4*f6 + 16/7*f4*f7 + 3*f5*f6 + 16/7*f5*f7 + 9/7*f6*f7 - 116053,
2*f1 + 2*f2 + 2*f3 + 2*f4 + 2*f5 + 2*f6 + 8/7*f7 - 553}):
st := time[real]():
Basis(J, tdeg(f1,f2,f3,f4,f5,f6,f7), characteristic=2^31-1):
time[real]() - st;
