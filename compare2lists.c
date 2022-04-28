#include <iostream>
#include <fstream>
void compare2lists(std::string file1 = "/usatlas/u/cher97/flow/runlist.txt", std::string file2 = "/atlasgpfs01/usatlas/data/cher97/spmethod/tots/lists.txt", std::string out="")
{
    unordered_map<int, pair<string, string>> maps; //int is run number, pair is PC and CC counts;
    std::string line;
    ifstream filein1(file1);
    ifstream filein2(file2);
ofstream fileout(out);
    //file 1 contains list of files file 2 contains list of PC and CC outputs
int count = 0;
    while (getline(filein1, line))
    {
        if (line.find("data18") == std::string::npos)
        {
            continue;
        }
        int run = stoi(line.substr(line.find(".00")+3,6));
//cout << run << endl;
//cout << line << endl;
if (maps.find(run)==maps.end()){
        maps[run]=std::make_pair("","");
count++;}
    }//end file1in
filein1.close();
cout << "Total files: " << count << endl;

    while (getline(filein2, line))
    {
        if (line.find("tot.root") == std::string::npos)
        {
            continue;
        }
        int run = stoi(line.substr(line.find(".calibration")- 6, 6));
        int cent = line.substr(line.find("PEB") - 2, 2) == "PC" ? 0 : 1;
        if (maps.find(run) == maps.end())
        {
            cout << line << endl;
            cout << "not in input list" << endl;
fileout << to_string(run) << "," << line.substr(line.find("PEB") - 2, 5) << ",not in list," << line << endl;
            continue;
        }
        if (cent)
        {
            if (maps[run].second != "")
            {
                cout << "more than one CC file exist: " << maps[run].second << endl;
                cout << "and found: " << line << endl;
		fileout << to_string(run) << ",CCPEB," << maps[run].second << "," << line << endl;
                continue;
            }
            maps[run].second=line;
        }
        else
        {
            if (maps[run].first != "")
            {
                cout << "more than one PC file exist: " << maps[run].first << endl;
                cout << "and found: " << line << endl;
fileout << to_string(run) << ",PCPEB," << maps[run].first << "," << line << endl;
                continue;
            }
            maps[run].first=line;
        }
    }//end file2in 
filein2.close();
    for (const auto &it:maps){
        if (it.second.first==""){
            cout << it.first << " PC not found" << endl;
fileout << to_string(it.first) << ",PCPEB" << endl;
        }
        if (it.second.second==""){
            cout << it.first << " CC not found" << endl;
fileout << to_string(it.first) << ",CCPEB" << endl;
        }
    }//end maps
fileout.close();
}
