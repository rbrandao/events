clear;

NICKNAMES="rafael felippe alice bob"
PORT=55400
DIR=`pwd`

for i in $NICKNAMES; do
	echo Executando $DIR/chat.sh $i $PORT
	gnome-terminal -x bash -i -c "cd $DIR ; ./chat.sh $i $PORT" &

	PORT=$[PORT+5]
done

