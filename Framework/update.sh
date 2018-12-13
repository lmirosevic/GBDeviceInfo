scriptLocation="$(cd "$(dirname "$0")" && pwd)"

cd $scriptLocation

rm -r ./*.zip
rm -r ./GBJailbreakDetection*
curl -OL https://github.com/lmirosevic/GBJailbreakDetection/archive/1.3.0.zip
unzip -a 1.3.0.zip
