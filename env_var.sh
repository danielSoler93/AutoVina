

MGL_TOOLS='/opt/mgltools_1.5.6/'
PYTHON_MGLTOOLS='/usr/local/MGLTools-1.5.6/bin/'

#Check env variables
if [ "$MGLTOOLS" == '' ]; then
	export MGLTOOLS=$MGL_TOOLS
elif [[ $(which pythonsh 2>&1 > /dev/null) != "" ]]; then
       PATH=$PATH:$PYTHON_MGLTOOLS
fi


