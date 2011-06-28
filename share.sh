clear;

# ./chat.lua nickname port 
# ele vai usar a porta indicada e a próxima.

lua share.lua S $1 $(( $2 + 1 )) &
lua share.lua C $1 $2  


