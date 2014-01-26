# Title: PicMonicr - Easy way to download and parse cards from Picmonic
# Author: Nick Honko (2014-01-17)
# Notes:
# View source in browser, then save source and send that as the only arugment when executing.
# Must have ImageMagick installed for resizing/recompressing of images

# Finds base URL for image downloads:
URL=`cat $1 | grep '"panel"' | grep '"url"' | sed 's/"panel"/%/g' | cut -f2 -d\% | cut -d: -f5 | cut -f1 -d\" | sed 's/\\\\//g'`
echo $URL

# Finds image filenames and saves them to images.txt
cat $1 | grep -e "var[ ]*panelImages" | sed 's/,/\
/g' | sed 's/(/\
/g' | sed 's/)/\
/g' | grep jpg | sed "s/\"//g" | sed "s/[ ]*//g" > images.txt

# Reads image filenames from images.txt and combines them with base URL to download
# then resizes and recompresses them to be nice for Anki
while read r
do
curl -O "http:$URL/$r"
echo curl -O "http:$URL/$r"
convert $r -resize 640 -quality 70 $r
done < images.txt

# Grabs card titles with mnemonics and saves to .txt files
cat $1 | grep -e "var[ ]*panelSummarys" | sed 's/\", \"/\
/g' | sed 's/");//g' | sed 's/var panelSummarys = new Array("//g' > mnemonicTitles.txt
cat $1 | grep -e "var[ ]*panelTitles" | sed 's/\", \"/\
/g' | sed 's/");//g' | sed 's/var panelTitles = new Array("//g' > titles.txt

# Grabs all other card data and saves to .txt files
for x in attributes attributeOverview attributeDetail
do
cat $1 | grep -e "$x\[" | sed "s/$x//g" | sed 's/new Array//g' | sed 's/(//g' | sed 's/)//g' | sed 's/\[//g' | sed 's/\]//g' > $x.txt
sed -i .bk 's/[0-9]*[ ]*=/\
\
/g' $x.txt
#sed -i 's/"//g' $x.txt
sed -i .bk 's/"[ ]*,[ ]*"/\
/g' $x.txt
sed -i .bk 's/"//g' $x.txt
sed -i .bk 's/<sup>/\^/g' $x.txt
sed -i .bk 's/<\/sup>/\^/g' $x.txt
sed -i .bk 's/\&nbsp;//g' $x.txt
sed -i .bk 's/;//g' $x.txt
sed -i .bk 's/\\//g' $x.txt
done

# Remove all the backup files required by sed in OS X
rm -f *.bk