n4vn337@navneet:~/Desktop$ cat script.sh
#!/usr/bin/bash

# functions
echo -e "\e[1;31m            _  _              _______________\e[0m"
echo -e "\e[1;31m      _ __ | || |__   ___ __ |___ /___ /___  |\e[0m"
echo -e "\e[1;31m     | '_ \| || |\ \ / / '_ \  |_ \ |_ \  / /\e[0m"
echo -e "\e[1;31m     | | | |__   _\ V /| | | |___) |__) |/ /\e[0m"
echo -e "\e[1;31m     |_| |_|  |_|  \_/ |_| |_|____/____//_/\e[0m    \e[33;5mBy: Navneet Anand\e[0m"

echo -e "\n\n\n"
#scripting
echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mcreating directory ==> $1\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
mkdir -p $1
cd $1
mkdir final-results

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mhey hacker lets scan\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
cowsay $1

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5msubdomain enumeration\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using amass"
amass enum --passive -d $1 |tee amass.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using assetfinder"
assetfinder -subs-only $1 |tee assetfinder.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using sublist3r"
python3 ~/tools/Sublist3r/sublist3r.py -d $1 |tee sublist3r.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mmerging ==> amass + assetfinder + sublist3r\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
touch all-subs.txt
cat amass.txt>>all-subs.txt
cat assetfinder.txt>>all-subs.txt
cat sublist3r.txt>>all-subs.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mtotal subdomains found on $1\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
wc all-subs.txt
cp all-subs final-results

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mremoving duplicate subdomains\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using dpline"
dpline all-subs.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mgreping out valid domains\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using httpx"
cat all-subs.txt |httpx -silent |tee httpx.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using httprobe"
cat all-subs.txt |httprobe -silent|tee httprobe.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mmerging ==> httpx + httprobe\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[96m[\e[0m/\e[96m]\e[0m "
touch valid-subs.txt
cat httpx.txt>>valid-subs.txt
cat httprobe.txt>>valid-subs.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mremoving duplicate value\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using dpline"
dpline valid-subs.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mvalid subs collected\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[96m[\e[0m/\e[96m]\e[0m total valid subs"
wc valid-subs.txt
cp valid-subs.txt final-results

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mscreenshot timeee\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using gowitness"
gowitness file -f valid-subs.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mChecking for Subdomain Takeover\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using subOver"
/home/n4vn337/go/bin/subjack -w valid-subs.txt -t 100 -timeout 30 -o results.txt -ssl

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mPort Scan\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using naabu"
~tools/portscan.sh/portscan.sh -o port-scan -p valid-subs.txt -s valid-subs.txt -n valid-subs.txt -m valid-subs.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mLooking out forr WAFs\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using wafw00f"
python3 ~/tools/wafw00f/wafw00f/bin/wafw00f https://$1

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mparameter scan\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using arjun"
python3 ~/tools/Arjun/arjun.py --get -t 22 --urls valid-subs.txt
echo -e "\e[93m[\e[0m+\e[93m]\e[0m"
python3 ~/tools/ParamSpider/paramspider.py --exclude woff,css,js,png,svg,php,jpg --output paramspider.txt --domain $1

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mlooking forrr js files\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using jsfscan"


echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mcrawllllliiiinngggg\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using xssstrike"
python3 ~/tools/XSStrike/xsstrike.py -l 3 --seeds valid-subs.txt|tee xsstrike.txt

echo -e "\e[96m[\e[0m \e[35m-----\e[0m \e[31;5mgau\e[0m \e[35m-----\e[0m \e[96m]\e[0m"
echo -e "\e[93m[\e[0m+\e[93m]\e[0m using gau"
cat valid-subs.txt |gau|tee gau-results.txt
