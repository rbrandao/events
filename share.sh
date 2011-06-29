clear;

# ./share.lua port 
# ele vai usar a porta indicada e a próxima.

lua share.lua S $1 $(( $1 + 1 )) &
lua share.lua C $1 $1  


