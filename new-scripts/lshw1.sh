git clone https://github.com/lyonel/lshw.git
cd lshw
# Enable static build
sed -i 's|all clean|all static clean|g' Makefile
# uClibc doesn't has libresolve
sed -i 's|-lresolv|-lintl -liconv|g' src/Makefile 
# Remove old databases in order to update them during make install stage
rm src/manuf.txt src/oui.txt src/pci.ids src/usb.ids
files=$(grep -rl /usr/local "$PWD")
for i in $files
do
sed -i 's|/usr/local|/ffp|g' "$i"
done
files=$(grep -rl /usr "$PWD")
for i in $files
do
sed -i 's|/usr|/ffp|g' "$i"
done
# Correct search path
sed -i 's|/ffp/share/misc|/ffp/share/lshw|g' src/core/pci.cc src/core/usb.cc
make SBINDIR=/ffp/bin static
make DESTDIR=/root SBINDIR=/ffp/bin install

cat version
rename static
