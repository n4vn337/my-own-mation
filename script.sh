#!/bin/bash

#functions
dirsearch(){
	python3 ~/tools/dirsearch/dirsearch.py -u 
}
dirsearch-one(){
	cat valid-subs.txt | awk '{print \"dirsearch \"\$1 \" -e \"}'
}
openredirect(){
	cat valid-subs.txt | awk '{print \"dirsearch \"\$1 \" -w ~/tools/dirsearch/db/open_redirect_wordlist.txt -e \"}'
}
arjun(){
	python3 ~/tools/Arjun/arjun.py --get -t 22 --urls 
}
paramspider(){
	python3 ~/tools/ParamSpider/paramspider.py --exclude woff,css,js,png,svg,php,jpg --output paramspider.txt --domain 
}
jsfscan(){
	~/tools/JSFScan.sh/JSFScan.sh -e -s -m 
}
jsfinder(){
	python3 ~/tools/JSFinder/JSFinder.py 
}
wafw00f(){
	python3 ~/tools/wafw00f/wafw00f/bin/wafwoof
}
#scripting
echo -e "\e[96m[\e[0m/\e[96m]\e[0m mkdir $1"
mkdir $1
cd $1
mkdir final-results

echo -e "\e[96m[\e[0m/\e[96m]\e[0m hey hacker lets scan"
figlet $1

echo -e "\e[96m[\e[0m/\e[96m]\e[0m subdomain enumeration"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using amass"
amass enum --passive -d $1 |tee amass.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using assetfinder"
assetfinder -subs-only $1 |tee assetfinder.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using sublist3r"
sublist3r -d $1 |tee sublist3r.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m merging ==> amass + assetfinder + sublist3r"
touch all-subs.txt
cat amass.txt>>all-subs.txt
cat assetfinder.txt>>all-subs.txt
cat sublist3r.txt>>all-subs.txt

echo -e "total subdomains found on $1"
wc all-subs.txt
cp all-subs final-results

echo -e "\e[96m[\e[0m/\e[96m]\e[0m removing duplicate subdomains"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using dpline"
dpline all-subs.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m greping out valid domains"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using httpx"
cat all-subs.txt |httpx -silent |tee httpx.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using httprobe"
cat all-subs.txt |httprobe -silent|tee httprobe.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m merging ==> httpx + httprobe"
touch valid-subs.txt
cat httpx.txt>>valid-subs.txt
cat httprobe.txt>>valid-subs.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m removing duplicate value"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using dpline"
dpline valid-subs.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m valid subs collected"
echo -e "\e[96m[\e[0m/\e[96m]\e[0m total valid subs"
wc valid-subs.txt
cp valid-subs.txt final-results

echo -e "\e[96m[\e[0m/\e[96m]\e[0m screenshot timeee"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using gowitness"
gowitness -f valid-subs.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m Run dirsearch on the domains file"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using dirsearch-alias"
dirsearch-one |dirsearch.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m Check forr open redirects using dirsearch on the valid-subs file"
echo -e "\e[96m[\e[0m/\e[96m]\e[0m open redirect-alias"
openredirect |tee openredirect.txt

echo -e "\e[96m[\e[0m/\e[96m]\e[0m Port Scan"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using naabu"
#naabu -iL valid-subs.txt -p - -exclude-ports 80,443

echo -e "\e[96m[\e[0m/\e[96m]\e[0m Looking out forr WAFs"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using wafw00f"
wafw00f https://$1

echo -e "\e[96m[\e[0m/\e[96m]\e[0m parameter scan"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using arjun"
arjun valid-subs.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m"
paramspider $1

echo -e "\e[96m[\e[0m/\e[96m]\e[0m looking forrr js files"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using jsfscan"
jsfscan -l valid-subs.txt -o jsfscan
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using jsfinder"
jsfinder -f valid-subs.txt |tee jsfinder.txt
