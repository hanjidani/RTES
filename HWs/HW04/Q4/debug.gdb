# Set breakpoints
break main
break 17

# Log file settings
set logging on
set logging file debug.txt
set logging overwrite on

# Run the program
run

# Commands to run when main breakpoint is hit
commands
  silent
  printf "Hit main breakpoint\n"
  printf "n = %d\n", n
  printf "i = %d\n", i
  printf "flag = %d\n", flag
  continue
end

# Commands to run when loop breakpoint is hit
commands 2
  silent
  printf "Iteration at line 17\n"
  printf "i = %d\n", i
  printf "n = %d\n", n
  printf "flag = %d\n", flag
  printf "input = %s\n", input
  printf "checkPrime(%d) = %d\n", i, checkPrime(i)
  printf "checkPrime(%d) = %d\n", n - i, checkPrime(n - i)
  continue
end

# Continue execution
continue
