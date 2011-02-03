echo %0 "%1" %2 %3 "%4" "%5" > c:\temp.txt
c:\perl\bin\perl.exe -T "%1" %2 -s -r -D %3 > "%4"
echo Done > "%5"