# http://docs.eiffel.com/book/eiffelstudio/eiffelstudio-linux
if [ -d /usr/local/Eiffel* ]; then
  export ISE_EIFFEL=$(ls -d /usr/local/Eiffel* | sort -u | tail -1)
  arch=$(uname -m)
  case $arch in
    x86_64 ) ISE_PLATFORM="linux-x86-64" ;;
    *      ) ISE_PLATFORM="linux-x86"    ;;
  esac
  export ISE_PLATFORM
  export PATH=$PATH:$ISE_EIFFEL/studio/spec/$ISE_PLATFORM/bin
fi
