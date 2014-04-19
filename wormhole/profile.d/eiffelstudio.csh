# http://docs.eiffel.com/book/eiffelstudio/eiffelstudio-linux
if [ -d /usr/local/Eiffel* ]; then
  export ISE_EIFFEL=$(ls -d /usr/local/Eiffel* | sort -u | tail -1)
  arch=$(uname -m)
  case $arch in
    x86_64 ) ISE_PLATFORM="linux-x86-64" ;;
    *      ) ISE_PLATFORM="linux-x86"    ;;
  esac
  setenv ISE_EIFFEL $EIFFEL
  setenv ISE_PLATFORM $PLATFORM
  set path = ($path $ISE_EIFFEL/studio/spec/$ISE_PLATFORM/bin)
fi
