with(Groebner):
with(PolynomialIdeals):
J := PolynomialIdeal({x1*x2*x10 + x1*x10 + x2*x3*x10 + x3*x4*x10 + x4*x5*x10 + x5*x6*x10 + x6*x7*x10 + x7*x8*x10 + x8*x9*x10 - 1, x1*x3*x10 + x2*x4*x10 + x2*x10 + x3*x5*x10 + x4*x6*x10 + x5*x7*x10 + x6*x8*x10 + x7*x9*x10 - 2, x1*x4*x10 + x2*x5*x10 + x3*x6*x10 + x3*x10 + x4*x7*x10 + x5*x8*x10 + x6*x9*x10 - 3, x1*x5*x10 + x2*x6*x10 + x3*x7*x10 + x4*x8*x10 + x4*x10 + x5*x9*x10 - 4, x1*x6*x10 + x2*x7*x10 + x3*x8*x10 + x4*x9*x10 + x5*x10 - 5, x1*x7*x10 + x2*x8*x10 + x3*x9*x10 + x6*x10 - 6, x1*x8*x10 + x2*x9*x10 + x7*x10 - 7, x1*x9*x10 + x8*x10 - 8, x9*x10 - 9, x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + 1}):
st := time[real]():
Basis(J, tdeg(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10), charactesistic=2^31-1):
time[real]() - st;


J := PolynomialIdeal({x1*x2*x11 + x1*x11 + x2*x3*x11 + x3*x4*x11 + x4*x5*x11 + x5*x6*x11 + x6*x7*x11 + x7*x8*x11 + x8*x9*x11 + x9*x10*x11 - 1, x1*x3*x11 + x2*x4*x11 + x2*x11 + x3*x5*x11 + x4*x6*x11 + x5*x7*x11 + x6*x8*x11 + x7*x9*x11 + x8*x10*x11 - 2, x1*x4*x11 + x2*x5*x11 + x3*x6*x11 + x3*x11 + x4*x7*x11 + x5*x8*x11 + x6*x9*x11 + x7*x10*x11 - 3, x1*x5*x11 + x2*x6*x11 + x3*x7*x11 + x4*x8*x11 + x4*x11 + x5*x9*x11 + x6*x10*x11 - 4, x1*x6*x11 + x2*x7*x11 + x3*x8*x11 + x4*x9*x11 + x5*x10*x11 + x5*x11 - 5, x1*x7*x11 + x2*x8*x11 + x3*x9*x11 + x4*x10*x11 + x6*x11 - 6, x1*x8*x11 + x2*x9*x11 + x3*x10*x11 + x7*x11 - 7, x1*x9*x11 + x2*x10*x11 + x8*x11 - 8, x1*x10*x11 + x9*x11 - 9, x10*x11 - 10, x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + 1}):
st := time[real]():
Basis(J, tdeg(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11), characteristic=2^31-1):
time[real]() - st;                                                                                              
