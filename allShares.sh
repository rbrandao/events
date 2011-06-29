clear;

PEERS=5
PORT=55500
DIR=`pwd`

for i in `seq $PEERS`; do
	echo Executando $DIR/share.sh $PORT
	gnome-terminal -x bash -i -c "cd $DIR ; ./share.sh $PORT" &

	PORT=$[PORT+5]
done

