clear;

# ./chat.lua nickname port 
# ele vai usar a porta indicada e a próxima.

lua chat.lua S $1 $(( $2 + 1 )) &
lua chat.lua C $1 $2  

kill $!

