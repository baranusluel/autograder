function[p_final,v_final]=freefall(time)
a=.5.*9.807*time.^2;
p_final= round(a,3);
 b=9.807.*time;
 v_final=round(b,3);